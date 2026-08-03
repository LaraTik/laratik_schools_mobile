// SPDX-License-Identifier: Proprietary
// Forward-compat result model for the
// `approve_school_data_governance_settings` write flow.
//
// The v1 wire shape is `{policy_version, status}` where
// `policy_version` is the integer version of the new
// approved settings. The mobile flattens the well-known
// fields into named accessors and preserves the full
// envelope on `raw` so future schema additions
// (e.g. `approved_by`, `approved_at`, `effective_from`)
// flow through without an app update.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

@immutable
class ApprovedGovernanceSettings extends Equatable {
  const ApprovedGovernanceSettings({
    required this.raw,
    required this.policyVersion,
    this.status,
  });

  /// Forward-compat factory. Reads `policy_version` first
  /// (the v1 canonical key — the SDK strict-casts this as
  /// a `num`); the legacy `version` / `policyVersion` keys
  /// are also walked for tests + future schema migrations.
  factory ApprovedGovernanceSettings.fromJson(JsonMap json) {
    int? version;
    final direct = json['policy_version'];
    if (direct is num) {
      version = direct.toInt();
    } else if (direct is String && int.tryParse(direct) != null) {
      version = int.parse(direct);
    } else {
      final legacy = json['version'] ?? json['policyVersion'];
      if (legacy is num) {
        version = legacy.toInt();
      } else if (legacy is String && int.tryParse(legacy) != null) {
        version = int.parse(legacy);
      }
    }
    return ApprovedGovernanceSettings(
      raw: json,
      policyVersion: version,
      status: _readString(json, const ['status', 'state', 'result']),
    );
  }

  final JsonMap raw;
  final int? policyVersion;
  final String? status;

  bool get isApproved =>
      status == 'approved' ||
      status == 'Approved' ||
      status == 'active' ||
      status == 'activated';

  bool get hasVersion => policyVersion != null;

  @override
  List<Object?> get props => [raw, policyVersion, status];
}

String? _readString(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
