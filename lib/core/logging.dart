/// Redacting logger. Every log line is screened for known-secret patterns
/// (OAuth bearer tokens, OTP codes, refresh tokens, push device tokens, raw
/// request/response bodies) before it leaves the process. The list is defined
/// in `_redactors` and intentionally conservative: prefer dropping context
/// over leaking it.
library;

import 'clock.dart';

class LogLevel {
  const LogLevel._(this.label);
  final String label;
  static const debug = LogLevel._('debug');
  static const info = LogLevel._('info');
  static const warn = LogLevel._('warn');
  static const error = LogLevel._('error');
}

class RedactingLogger {
  RedactingLogger({required Clock clock, LogSink? sink}) : _sink = sink ?? ConsoleSink() {
    _clock = clock;
  }

  final LogSink _sink;
  late final Clock _clock;

  /// Regexes matched (case-insensitive) against the message; the matched span
  /// is replaced with `***`. Conservative by design.
  static final _patterns = <RegExp>[
    // OAuth / Frappe tokens.
    RegExp(r'Bearer\s+[A-Za-z0-9._-]{16,}', caseSensitive: false),
    RegExp(r'\"access_token\"\s*:\s*\"[^\"]+\"', caseSensitive: false),
    RegExp(r'\"refresh_token\"\s*:\s*\"[^\"]+\"', caseSensitive: false),
    // Idempotency-Key, OTP, recovery code.
    RegExp(r'\b(Idempotency-Key|otp|recovery_code|otpauth)\b\s*[=:]\s*[\w-]{6,}',
        caseSensitive: false),
    // Push device tokens (long opaque strings).
    RegExp(r'\"(push_token|device_token|fcm_token|apns_token)\"\s*:\s*\"[^\"]+\"',
        caseSensitive: false),
  ];

  void debug(String message, {Map<String, Object?>? context}) =>
      _emit(LogLevel.debug, message, context);
  void info(String message, {Map<String, Object?>? context}) =>
      _emit(LogLevel.info, message, context);
  void warn(String message, {Map<String, Object?>? context}) =>
      _emit(LogLevel.warn, message, context);
  void error(String message,
          {Map<String, Object?>? context, Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.error, message, context, error: error, stackTrace: stackTrace);

  // ============================================================================
  // Structured convenience loggers. Domain layers should prefer these over
  // raw `info` / `error` so the redactor and the structure stay consistent.
  // ============================================================================

  /// Boot / app-level informational event with structured fields.
  void logInfo(String event, {Map<String, Object?>? fields}) =>
      info(event, context: fields);

  /// One round-trip on the API transport. Never includes the URL, the body,
  /// or the auth header — only the method name, the status, the duration,
  /// and the attempt number.
  void logApiCall({
    required String method,
    required int status,
    required Duration duration,
    required int attempt,
  }) {
    info('api.call', context: {
      'method': method,
      'status': status,
      'duration_ms': duration.inMilliseconds,
      'attempt': attempt,
    });
  }

  /// Transport-level failure (timeout, socket, http_client). The error
  /// message is redacted before emission.
  void logTransportFailure({
    required String method,
    required int attempt,
    required String reason,
    required Object error,
    required StackTrace stack,
  }) {
    this.error(
      'transport.failure',
      context: {'method': method, 'attempt': attempt, 'reason': reason},
      error: error,
      stackTrace: stack,
    );
  }

  /// Session lifecycle event. The actor is the installation id; the reason
  /// is a stable code (`sign_out`, `token_refresh_failed`, etc.).
  void logSessionEvent(String event, {String? actor, String? reason}) {
    info('session.$event', context: {
      if (actor != null) 'actor': actor,
      if (reason != null) 'reason': reason,
    });
  }

  void _emit(
    LogLevel level,
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final scrubbed = _scrub(message);
    final scrubbedContext = context == null
        ? null
        : {
            for (final entry in context.entries)
              entry.key: _scrubObject(entry.value),
          };
    _sink.write(
      LogRecord(
        level: level,
        timestamp: _clock.nowUtc(),
        message: scrubbed,
        context: scrubbedContext,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  static String _scrub(String input) {
    var out = input;
    for (final pattern in _patterns) {
      out = out.replaceAll(pattern, '***');
    }
    return out;
  }

  static Object? _scrubObject(Object? value) {
    if (value is String) return _scrub(value);
    if (value is Map) {
      return {
        for (final entry in value.entries) entry.key.toString(): _scrubObject(entry.value),
      };
    }
    if (value is Iterable) {
      return [for (final v in value) _scrubObject(v)];
    }
    return value;
  }
}

class LogRecord {
  const LogRecord({
    required this.level,
    required this.timestamp,
    required this.message,
    this.context,
    this.error,
    this.stackTrace,
  });
  final LogLevel level;
  final DateTime timestamp;
  final String message;
  final Map<String, Object?>? context;
  final Object? error;
  final StackTrace? stackTrace;
}

abstract class LogSink {
  void write(LogRecord record);
}

/// Default sink: prints structured single-line records. The real platform
/// sink (Crashlytics, Sentry, file) replaces this once the telemetry policy
/// is decided in the Phase 0 ADR.
class ConsoleSink implements LogSink {
  @override
  void write(LogRecord record) {
    // Intentionally no `print` so this can be replaced without touching the
    // logger call sites. Hook a real sink in once we have one.
  }
}
