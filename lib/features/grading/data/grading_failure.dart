// SPDX-License-Identifier: Proprietary
// Typed failure for the Grading feature (read-only overview
// + policies + setup context + future correct / promote /
// approve write flows).
//
// Mirrors the v1 envelope's `code` so feature code can switch
// on a stable value rather than scraping message strings.
// Same shape as FeesFailure / FamilyFailure / OperationsFailure
// so a future "correct a grade" / "promote a grade" /
// "approve a policy" write flow can drop in without a model
// change.

import 'package:equatable/equatable.dart';

class GradingFailure extends Equatable implements Exception {
  const GradingFailure({
    required this.code,
    required this.message,
    this.fieldErrors = const {},
  });

  /// Stable wire code, e.g. `EMPTY_RESPONSE`,
  /// `GRADE_POLICY_NOT_FOUND`, `NETWORK_FAILURE`, `HTTP_502`.
  /// Switch on this for typed handling.
  final String code;

  /// User-safe message. Never the raw server cause or stack
  /// trace.
  final String message;

  /// Per-field errors keyed by the form field name. Unused
  /// by the read-only overview today, but the field is here
  /// so the shape stays consistent with the sibling failure
  /// types and a future "correct a grade" form can drop in
  /// without a model change.
  final Map<String, List<String>> fieldErrors;

  /// True when the failure should let the user try again
  /// (network, timeout, server unavailable). False for
  /// permanent validation or authorization problems.
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
  String toString() => 'GradingFailure($code): $message';

  @override
  List<Object?> get props => [code, message, fieldErrors];
}
