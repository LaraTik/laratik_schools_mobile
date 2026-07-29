import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import 'app_flavor.dart';
import 'flavor_config.dart';

/// Resolves the active [AppConfig] from compile-time inputs.
///
/// Resolution order:
///   1. `String.fromEnvironment('APP_FLAVOR')` — set via
///      `--dart-define=APP_FLAVOR=<id>` at build/run time.
///   2. If unset, defaults to [AppFlavor.dev] so a bare `flutter run` (no
///      flags) picks up the local dev backend and just works.
///
/// Examples:
///   flutter run --dart-define=APP_FLAVOR=dev
///   flutter run --dart-define=APP_FLAVOR=local
///   flutter run --dart-define=APP_FLAVOR=qa
///   flutter build apk --dart-define=APP_FLAVOR=prod
class FlavorLoader {
  const FlavorLoader._();

  static const String _envKey = 'APP_FLAVOR';

  /// Read `--dart-define=APP_FLAVOR=…` (compile-time constant) and return
  /// the matching [AppConfig] from [FlavorRegistry]. Throws
  /// [ArgumentError] for unknown values so misconfigurations fail loudly
  /// at startup instead of silently picking the wrong backend.
  static AppConfig load() {
    const raw = String.fromEnvironment(_envKey);
    final flavor = AppFlavorX.fromString(raw.isEmpty ? null : raw);
    return FlavorRegistry.of(flavor);
  }
}

/// Riverpod entry point for the active [AppConfig]. `main.dart` overrides
/// this with the loaded value at the root [ProviderScope] so every
/// feature can read it via `ref.watch(appConfigProvider)`. The default
/// throw guarantees a clear error if the override is ever forgotten.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError(
    'appConfigProvider was read before main.dart installed the override. '
    'Make sure ProviderScope(overrides: [appConfigProvider.overrideWithValue(...)]) '
    'is set up around LaratikSchoolsApp.',
  );
});
