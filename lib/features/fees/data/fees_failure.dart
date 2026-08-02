// SPDX-License-Identifier: Proprietary
// Typed failure for the Fees feature (read-only fee plan + ops
// overview + future invoice / payment surfaces).
//
// Mirrors the v1 envelope's `code` so feature code can switch on
// a stable value rather than scraping message strings. The
// original [ApiError.code] is preserved on [code] and the
// optional [fieldErrors] map helps the form layer surface
// per-field errors.

import 'package:equatable/equatable.dart';

class FeesFailure extends Equatable implements Exception {
  const FeesFailure({
    required this.code,
    required this.message,
    this.fieldErrors = const {},
  });

  /// Stable wire code, e.g. `EMPTY_RESPONSE`,
  /// `FEE_PLAN_NOT_FOUND`, `NETWORK_FAILURE`, `HTTP_502`. Switch
  /// on this for typed handling.
  final String code;

  /// User-safe message. Never the raw server cause or stack
  /// trace.
  final String message;

  /// Per-field errors keyed by the form field name. Unused by the
  /// read-only fee-plan surface today, but the field is here so
  /// the shape stays consistent with PersonFailure and a future
  /// "create fee plan" form can drop in without a model change.
  final Map<String, List<String>> fieldErrors;

  /// True when the failure should let the user try again
  /// (network, timeout, server unavailable). False for permanent
  /// validation or authorization problems.
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
  String toString() => 'FeesFailure($code): $message';

  @override
  List<Object?> get props => [code, message, fieldErrors];
}
