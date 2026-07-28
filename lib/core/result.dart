/// Result<T, E> — explicit success/failure type for the transport layer.
///
/// Repositories return [Result] instead of throwing across boundaries. The UI
/// layer pattern-matches and renders either the data or the user-safe error
/// (never the stack trace, never the raw payload).
library;

sealed class Result<T, E> {
  const Result();

  /// Pattern-match helper. [onOk] runs on success, [onErr] on failure.
  R fold<R>(R Function(T ok) onOk, R Function(E err) onErr) => switch (this) {
        Ok<T, E>(value: final value) => onOk(value),
        Err<T, E>(error: final error) => onErr(error),
      };

  /// True when the result is [Ok].
  bool get isOk => this is Ok<T, E>;

  /// True when the result is [Err].
  bool get isErr => this is Err<T, E>;
}

final class Ok<T, E> extends Result<T, E> {
  const Ok({required T value}) : _value = value;
  final T _value;
  T get value => _value;
}

final class Err<T, E> extends Result<T, E> {
  const Err({required E error}) : _error = error;
  final E _error;
  E get error => _error;
}

/// User-safe error categories. Never log or render the raw cause; the message
/// is user-safe, the [code] is stable, and [requestId] ties it to the server
/// log line for support.
class AppError {
  const AppError({
    required this.code,
    required this.message,
    this.requestId,
    this.cause,
  });

  /// Stable code from the v1 envelope (e.g. `STUDENT_VALIDATION_FAILED`,
  /// `INVALID_CURSOR_SCOPE`).
  final String code;

  /// User-safe message. Never includes payload bodies, names, IDs, or
  /// provider secrets.
  final String message;

  /// Server-issued request id; included in support reports.
  final String? requestId;

  /// Internal-only underlying cause. Never logged with the user-safe
  /// message; the redacting logger strips it.
  final Object? cause;

  @override
  String toString() => 'AppError($code, $message)';
}
