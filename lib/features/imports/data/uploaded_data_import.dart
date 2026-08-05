// SPDX-License-Identifier: Proprietary
// Forward-compat result model for the
// `upload_school_data_import_package` write flow.
//
// The v1 wire shape is
// `{batch, counts, package_hash, status}`. The
// `batch` is the Frappe name of the new data import
// batch the server created; `counts` is a per-doctype
// row-count map; `package_hash` is the SHA-256 of the
// uploaded package; `status` is the new batch's
// lifecycle status (typically `Submitted` or
// `Validated`).
//
// The mobile flattens the well-known fields into named
// accessors and preserves the full envelope on `raw` so
// future schema additions (e.g. `warnings`, `dry_run_id`)
// flow through without an app update.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

@immutable
class UploadedDataImport extends Equatable {
  const UploadedDataImport({
    required this.raw,
    required this.batch,
    required this.counts,
    this.packageHash,
    this.status,
  });

  /// Forward-compat factory. Walks the canonical `batch`
  /// key first, then the legacy `name` / `batch_name`
  /// aliases. `counts` is exposed as a map of
  /// `<doctype> -> <row count>`.
  factory UploadedDataImport.fromJson(JsonMap json) {
    return UploadedDataImport(
      raw: json,
      batch: _readString(json, const ['batch', 'name', 'batch_name']) ?? '',
      counts: _readCounts(json['counts']),
      packageHash: _readString(json, const [
        'package_hash',
        'hash',
        'packageHash',
      ]),
      status: _readString(json, const ['status', 'state', 'result']),
    );
  }

  final JsonMap raw;
  final String batch;
  final Map<String, int> counts;
  final String? packageHash;
  final String? status;

  bool get isSubmitted =>
      status == 'submitted' ||
      status == 'Submitted' ||
      status == 'validated' ||
      status == 'Validated';

  bool get hasBatch => batch.isNotEmpty;

  @override
  List<Object?> get props => [raw, batch, counts, packageHash, status];
}

String? _readString(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

Map<String, int> _readCounts(Object? raw) {
  if (raw is! Map) return const <String, int>{};
  final out = <String, int>{};
  raw.forEach((key, value) {
    if (value is num) {
      out['$key'] = value.toInt();
    } else if (value is String && int.tryParse(value) != null) {
      out['$key'] = int.parse(value);
    }
  });
  return out;
}
