import 'package:equatable/equatable.dart';

/// Typed failure for the People feature.
///
/// Mirrors the v1 envelope's `code` so feature code can switch on a stable
/// value rather than scraping message strings. The original [ApiError.code]
/// is preserved on [code] and the optional [fieldErrors] map helps the form
/// layer surface per-field errors.
class PersonFailure extends Equatable implements Exception {
  const PersonFailure({
    required this.code,
    required this.message,
    this.fieldErrors = const {},
  });

  /// `STUDENT_VALIDATION_FAILED`, `GUARDIAN_REQUIRED`, etc.
  final String code;

  /// User-safe message. Never the raw server cause.
  final String message;

  /// Per-field errors keyed by the form field name.
  final Map<String, List<String>> fieldErrors;

  /// True when the failure should let the user try again (network, timeout,
  /// server unavailable). False when the failure is a permanent validation
  /// or authorization problem.
  bool get isRetryable {
    switch (code) {
      case 'TIMEOUT':
      case 'NETWORK_UNREACHABLE':
      case 'NETWORK_FAILURE':
      case 'INVALID_RESPONSE':
      case 'EMPTY_RESPONSE':
      case 'UNREACHABLE':
      case 'HTTP_502':
      case 'HTTP_503':
      case 'HTTP_504':
        return true;
      default:
        return false;
    }
  }

  @override
  String toString() => 'PersonFailure($code): $message';

  @override
  List<Object?> get props => [code, message, fieldErrors];
}
