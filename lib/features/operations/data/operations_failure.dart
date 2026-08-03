// SPDX-License-Identifier: Proprietary
// Typed failure for the Operations feature (read-only operations
// health + delivery health + auth audit events).
//
// Mirrors the v1 envelope's `code` so feature code can switch on
// a stable value rather than scraping message strings. Same shape
// as FeesFailure / FamilyFailure / PersonFailure so a future
// "replay" / "legal hold" / "approve privacy" write flow can drop
// in without a model change.

import 'package:equatable/equatable.dart';

class OperationsFailure extends Equatable implements Exception {
  const OperationsFailure({
    required this.code,
    required this.message,
    this.fieldErrors = const {},
  });

  /// Stable wire code, e.g. `EMPTY_RESPONSE`,
  /// `NETWORK_FAILURE`, `HTTP_502`. Switch on this for typed
  /// handling.
  final String code;

  /// User-safe message. Never the raw server cause or stack
  /// trace.
  final String message;

  /// Per-field errors keyed by the form field name. Unused by
  /// the read-only operations health surface today, but the
  /// field is here so the shape stays consistent with the
  /// sibling failure types and a future "replay" / "approve
  /// privacy" form can drop in without a model change.
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
  String toString() => 'OperationsFailure($code): $message';

  @override
  List<Object?> get props => [code, message, fieldErrors];
}
