// Lint check: ban hardcoded `laratik.localhost` (and similar) in `lib/`.
//
// The hostname is configuration — it lives in `lib/config/flavor_config.dart`
// and nowhere else. Hardcoding it elsewhere re-creates the bug we hit
// during the dev-flavor OAuth rollout (the screen sent Chrome to
// `https://laratik.localhost/...` instead of the configured base URL).
//
// Usage:
//   dart run tool/lint_no_hardcoded_hosts.dart
//   dart run tool/lint_no_hardcoded_hosts.dart --fix   # strip offending lines
//
// The script is intentionally small and dependency-free so it runs in
// CI, locally, and on a fresh checkout without a `pub get` step.

import 'dart:io';

/// Hostnames the script bans. Add to this list only if a new environment
/// constant is created in `lib/config/flavor_config.dart`.
const _bannedHosts = <String>{
  'laratik.localhost',
  'laratik.app',
};

/// Files that are allowed to mention the banned hosts. Keep this list
/// short — every entry is an exception to the rule.
const _allowList = <String>{
  'lib/config/flavor_config.dart',
};

Future<int> main(List<String> args) async {
  final fix = args.contains('--fix');
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('lint_no_hardcoded_hosts: no lib/ directory at ${Directory.current.path}');
    return 2;
  }

  final violations = <_Violation>[];
  await for (final file in libDir.list(recursive: true)) {
    if (file is! File) continue;
    if (!file.path.endsWith('.dart')) continue;
    final rel = _relative(file.path);
    if (_allowList.contains(rel)) continue;
    final lines = file.readAsLinesSync();
    var inDocComment = false;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Skip /// doc comments and any block they're inside.
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('///')) {
        continue;
      }
      if (trimmed.startsWith('/*')) {
        inDocComment = !trimmed.contains('*/');
        continue;
      }
      if (inDocComment) {
        if (trimmed.contains('*/')) inDocComment = false;
        continue;
      }
      for (final host in _bannedHosts) {
        if (line.contains(host)) {
          violations.add(
            _Violation(
              file: rel,
              line: i + 1,
              text: line.trim(),
              host: host,
            ),
          );
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('lint_no_hardcoded_hosts: OK (0 violations)');
    return 0;
  }

  stderr.writeln(
    'lint_no_hardcoded_hosts: ${violations.length} violation(s). '
    'Read the host from AppConfig (lib/config/flavor_config.dart) — '
    'do not hard-code it.',
  );
  for (final v in violations) {
    stderr.writeln('  ${v.file}:${v.line}  [${v.host}]  ${v.text}');
  }

  if (fix) {
    stderr.writeln('--fix is not implemented; fix the offenders manually.');
  }
  return 1;
}

String _relative(String path) {
  var normalized = path;
  // Normalize to forward slashes so the allowlist and CI scripts work
  // the same way on Windows and POSIX hosts.
  if (Platform.pathSeparator == r'\') {
    normalized = normalized.replaceAll(r'\', '/');
  }
  final cwd = Directory.current.path.replaceAll(r'\', '/');
  if (normalized.startsWith(cwd)) {
    final stripped = normalized.substring(cwd.length);
    return stripped.startsWith('/') ? stripped.substring(1) : stripped;
  }
  return normalized;
}

class _Violation {
  _Violation({
    required this.file,
    required this.line,
    required this.text,
    required this.host,
  });
  final String file;
  final int line;
  final String text;
  final String host;
}
