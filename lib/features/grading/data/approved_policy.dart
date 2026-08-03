// SPDX-License-Identifier: Proprietary
// Forward-compat result model for the
// `approve_school_subject_grade_policy` write flow.
//
// The v1 wire shape is `{policy, status}` where
// `status` is the new policy status (typically
// `approved`). The mobile flattens the well-known
// fields into named accessors and preserves the full
// envelope on `raw` so future schema additions
// (e.g. `approved_by`, `approved_at`, `notes`) flow
// through without an app update.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

@immutable
class ApprovedPolicy extends Equatable {
  const ApprovedPolicy({
    required this.raw,
    required this.policy,
    this.status,
  });

  /// Forward-compat factory. Walks the canonical
  /// `policy` key first, then the legacy `name` /
  /// `policy_name` aliases. The v1 SDK is strict-cast
  /// on the response data block so the canonical key
  /// is the only one the live wire path will use; the
  /// aliases are here for tests + future schema
  /// migrations.
  factory ApprovedPolicy.fromJson(JsonMap json) {
    return ApprovedPolicy(
      raw: json,
      policy: _readString(json, const ['policy', 'name', 'policy_name']) ?? '',
      status: _readString(json, const ['status', 'state', 'result']),
    );
  }

  final JsonMap raw;
  final String policy;
  final String? status;

  bool get isApproved =>
      status == 'approved' || status == 'Approved' || status == 'active';

  bool get hasPolicy => policy.isNotEmpty;

  @override
  List<Object?> get props => [raw, policy, status];
}

String? _readString(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
