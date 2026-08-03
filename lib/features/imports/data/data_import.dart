// SPDX-License-Identifier: Proprietary
// Data import models — read-only "School Data Import Batch" +
// "School Data Import Record" (per-row reconciliation entry) +
// "School Score Import" + "School Score Reconciliation".
//
// The v1 contract is forward-compat: the
// `get_school_data_import_batches` envelope returns a
// `batches` JSON **string** (a serialized array — see the SDK
// signature at `LaratikSchoolsApiMethods.getSchoolDataImportBatches`),
// the `get_school_data_import_reconciliation` envelope returns
// a `records` array of arbitrary maps, and the
// `get_school_score_imports` envelope returns a `score_imports`
// JSON string. The factories below parse the canonical + legacy
// wire keys and preserve the full map on `raw` so a future
// schema bump flows through without an app update.
//
// The mobile does NOT run its own validation — the README
// (`lib/features/imports/README.md`) says the UI surfaces the
// server's pre-validated payload. The "Data imports" + "Score
// imports" surfaces are therefore read-only listings of past
// batches + reconciliations + score imports, with a detail
// screen per record so the operator can audit the
// reconciliation. The full upload + dry-run + review + approve
// + commit wizard is deferred to a follow-up turn because the
// `upload_school_data_import_package` endpoint expects a
// pre-uploaded `package_file` (Frappe's file API) which is
// outside the v1 SDK scope today.

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// A single data import batch. The wire shape is open
/// (`additionalProperties: true` on the server) so the model
/// preserves the full row on [raw] and surfaces the
/// well-known fields as named accessors.
@immutable
class DataImportBatch extends Equatable {
  const DataImportBatch({
    required this.name,
    required this.status,
    required this.sourceLabel,
    required this.packageHash,
    required this.createdAt,
    required this.rowCounts,
    required this.raw,
  });

  factory DataImportBatch.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    JsonMap? pickMap(String key) {
      final v = json[key];
      if (v is Map) return Map<String, Object?>.from(v);
      return null;
    }

    // Row counts may live on the top-level batch doc as
    // `counts` / `row_counts` / `summary` (open schema), or
    // be missing entirely. The mobile renders whatever the
    // server sends.
    final counts = pickMap('counts') ??
        pickMap('row_counts') ??
        pickMap('summary') ??
        const <String, Object?>{};

    return DataImportBatch(
      name: pickString('name') ??
          pickString('batch') ??
          pickString('id') ??
          '',
      status: pickString('status') ??
          pickString('state') ??
          'unknown',
      sourceLabel: pickString('source_label') ??
          pickString('source') ??
          pickString('package_file') ??
          '',
      packageHash: pickString('package_hash') ?? '',
      createdAt: pickString('created_at') ??
          pickString('creation') ??
          pickString('submitted_at') ??
          '',
      rowCounts: counts,
      raw: json,
    );
  }

  /// The DocType id. The mobile uses this as the row key
  /// and as the deep-link slug (`/shell/imports/:batchId`).
  final String name;

  /// Lifecycle status — `received` / `dry_run_queued` /
  /// `dry_run_completed` / `reviewing` / `approved` /
  /// `commit_queued` / `committed` / `failed` / `cancelled` /
  /// `unknown`. The mobile renders this as a chip with a
  /// color tone per family.
  final String status;

  /// Human-readable source label (e.g. the file name the
  /// package was uploaded from, or a friendly alias). Falls
  /// back to the private file name on the v1 wire.
  final String sourceLabel;

  /// The server-computed SHA-256 of the package. The mobile
  /// renders this as a 12-character monospace chip so the
  /// operator can correlate with the desktop.
  final String packageHash;

  /// When the batch was submitted (server ISO timestamp).
  final String createdAt;

  /// Per-Doctype row counts from the dry-run step. Keys are
  /// the wire-defined DocType names (e.g. `Student`, `Staff`,
  /// `Subject`); values are typically `num`. The mobile
  /// renders the top 4 entries as a small chip strip on the
  /// row.
  final JsonMap rowCounts;

  final JsonMap raw;

  /// A coarse family for the chip tone. The mobile maps:
  ///   * `committed` / `approved` → success
  ///   * `failed` / `cancelled` → error
  ///   * `*queued` → info
  ///   * `received` / `dry_run_completed` / `reviewing` →
  ///     warning
  ///   * anything else → neutral
  String get statusFamily {
    final s = status.toLowerCase();
    if (s == 'committed' || s == 'approved') return 'success';
    if (s == 'failed' || s == 'cancelled') return 'error';
    if (s.endsWith('_queued') || s == 'queued') return 'info';
    if (s == 'received' ||
        s == 'dry_run_completed' ||
        s == 'reviewing' ||
        s == 'dry_run_in_progress') {
      return 'warning';
    }
    return 'neutral';
  }

  /// Short hash display (first 12 chars) for the row.
  /// Empty when the server returned no hash.
  String get shortHash {
    if (packageHash.isEmpty) return '';
    if (packageHash.length <= 12) return packageHash;
    return packageHash.substring(0, 12);
  }

  @override
  List<Object?> get props => [
        name,
        status,
        sourceLabel,
        packageHash,
        createdAt,
        rowCounts,
      ];
}

/// Paged list of batches. The v1 endpoint returns the
/// `batches` payload as a serialized JSON **string** inside
/// the `GetSchoolDataImportBatchesData` envelope; the factory
/// below parses both that shape and a direct list for
/// forward-compat.
@immutable
class DataImportBatchPage extends Equatable {
  const DataImportBatchPage({required this.batches});

  factory DataImportBatchPage.fromJson(JsonMap json) {
    final raw = json['batches'];
    final rows = _decodeList(raw).map(DataImportBatch.fromJson).toList(
          growable: false,
        );
    return DataImportBatchPage(batches: rows);
  }

  final List<DataImportBatch> batches;

  bool get isEmpty => batches.isEmpty;

  @override
  List<Object?> get props => [batches];
}

/// A single reconciliation record (a row from the
/// per-batch `get_school_data_import_reconciliation` list).
/// The wire shape is open; the mobile renders the canonical
/// fields and preserves the full row on [raw].
@immutable
class DataImportRecord extends Equatable {
  const DataImportRecord({
    required this.name,
    required this.doctype,
    required this.rowIndex,
    required this.status,
    required this.message,
    required this.payload,
    required this.raw,
  });

  factory DataImportRecord.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    int? pickInt(String key) {
      final v = json[key];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    JsonMap? pickMap(String key) {
      final v = json[key];
      if (v is Map) return Map<String, Object?>.from(v);
      return null;
    }

    return DataImportRecord(
      name: pickString('name') ?? '',
      doctype: pickString('doctype') ??
          pickString('target_doctype') ??
          '',
      rowIndex: pickInt('row_index') ??
          pickInt('line') ??
          pickInt('row') ??
          0,
      status: pickString('status') ??
          pickString('decision') ??
          pickString('state') ??
          'unknown',
      message: pickString('message') ??
          pickString('error') ??
          pickString('note') ??
          '',
      payload: pickMap('payload') ??
          pickMap('row') ??
          pickMap('data') ??
          const <String, Object?>{},
      raw: json,
    );
  }

  /// The reconciliation record id. Empty when the server
  /// didn't assign one.
  final String name;

  /// The target DocType the row was meant to create / update
  /// (e.g. `Student`, `Staff`, `Subject`).
  final String doctype;

  /// The 1-based row index in the original package. The
  /// mobile renders this as a small "Row N" chip.
  final int rowIndex;

  /// Lifecycle status — `pending` / `approved` / `rejected` /
  /// `skipped` / `error` / `unknown`. The mobile renders
  /// this as a chip with a color tone per family.
  final String status;

  /// Human-readable note from the server (validation
  /// message, conflict reason, etc.). Empty when the server
  /// didn't attach one.
  final String message;

  /// The row's payload (the column → value map from the
  /// package). The mobile renders the first 3 keys as a
  /// compact key/value strip so the operator can scan the
  /// data without expanding the row.
  final JsonMap payload;

  final JsonMap raw;

  /// A coarse family for the chip tone. The mobile maps:
  ///   * `approved` → success
  ///   * `rejected` / `error` → error
  ///   * `skipped` → warning
  ///   * `pending` → info
  ///   * anything else → neutral
  String get statusFamily {
    final s = status.toLowerCase();
    if (s == 'approved') return 'success';
    if (s == 'rejected' || s == 'error') return 'error';
    if (s == 'skipped') return 'warning';
    if (s == 'pending') return 'info';
    return 'neutral';
  }

  @override
  List<Object?> get props => [name, doctype, rowIndex, status, message];
}

/// Paged list of reconciliation records.
@immutable
class DataImportRecordPage extends Equatable {
  const DataImportRecordPage({required this.records});

  factory DataImportRecordPage.fromJson(JsonMap json) {
    final raw = json['records'];
    final rows = _decodeList(raw).map(DataImportRecord.fromJson).toList(
          growable: false,
        );
    return DataImportRecordPage(records: rows);
  }

  final List<DataImportRecord> records;

  bool get isEmpty => records.isEmpty;

  @override
  List<Object?> get props => [records];
}

/// A single score import. The wire shape is open; the mobile
/// renders the canonical fields and preserves the full row on
/// [raw]. The companion `School Score Import Column` is a
/// child table; the mobile surfaces the column list as a
/// chip strip so the operator can audit the mapping.
@immutable
class ScoreImport extends Equatable {
  const ScoreImport({
    required this.name,
    required this.status,
    required this.sourceLabel,
    required this.fileHash,
    required this.createdAt,
    required this.columns,
    required this.counts,
    required this.raw,
  });

  factory ScoreImport.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    JsonMap? pickMap(String key) {
      final v = json[key];
      if (v is Map) return Map<String, Object?>.from(v);
      return null;
    }

    final columnsRaw = json['columns'];
    final columns = <ScoreImportColumn>[];
    if (columnsRaw is List) {
      for (final c in columnsRaw) {
        if (c is Map) {
          columns.add(
            ScoreImportColumn.fromJson(
              Map<String, Object?>.from(c),
            ),
          );
        }
      }
    }

    return ScoreImport(
      name: pickString('name') ??
          pickString('score_import') ??
          pickString('id') ??
          '',
      status: pickString('status') ?? 'unknown',
      sourceLabel: pickString('source_label') ??
          pickString('source') ??
          pickString('file_name') ??
          '',
      fileHash: pickString('file_hash') ?? '',
      createdAt: pickString('created_at') ??
          pickString('creation') ??
          pickString('submitted_at') ??
          '',
      columns: List.unmodifiable(columns),
      counts: pickMap('counts') ??
          pickMap('summary') ??
          const <String, Object?>{},
      raw: json,
    );
  }

  /// The DocType id. The mobile uses this as the row key
  /// and as the deep-link slug
  /// (`/shell/imports/scores/:scoreImportId`).
  final String name;

  /// Lifecycle status — `draft` / `mapping` / `previewed` /
  /// `validated` / `committed` / `failed` / `cancelled` /
  /// `unknown`. The mobile renders this as a chip with a
  /// color tone per family.
  final String status;

  /// Human-readable source label (the uploaded file name
  /// or a friendly alias).
  final String sourceLabel;

  /// The server-computed SHA-256 of the file. The mobile
  /// renders this as a 12-character monospace chip.
  final String fileHash;

  /// When the score import was submitted.
  final String createdAt;

  /// The mapped columns (source column → target field). The
  /// mobile renders these as a chip strip on the detail
  /// screen so the operator can audit the mapping at a
  /// glance.
  final List<ScoreImportColumn> columns;

  /// Per-stage counts from the validate step. The mobile
  /// renders these as a small KPI strip on the detail
  /// screen.
  final JsonMap counts;

  final JsonMap raw;

  /// A coarse family for the chip tone.
  String get statusFamily {
    final s = status.toLowerCase();
    if (s == 'committed') return 'success';
    if (s == 'failed' || s == 'cancelled') return 'error';
    if (s == 'previewed' || s == 'validated') return 'info';
    if (s == 'draft' || s == 'mapping') return 'warning';
    return 'neutral';
  }

  /// Short hash display (first 12 chars) for the row.
  String get shortHash {
    if (fileHash.isEmpty) return '';
    if (fileHash.length <= 12) return fileHash;
    return fileHash.substring(0, 12);
  }

  @override
  List<Object?> get props => [
        name,
        status,
        sourceLabel,
        fileHash,
        createdAt,
        columns,
        counts,
      ];
}

/// A single column mapping on a [ScoreImport] (source
/// column → target field).
@immutable
class ScoreImportColumn extends Equatable {
  const ScoreImportColumn({
    required this.source,
    required this.target,
  });

  factory ScoreImportColumn.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    return ScoreImportColumn(
      source: pickString('source') ??
          pickString('source_column') ??
          pickString('column') ??
          '',
      target: pickString('target') ??
          pickString('target_field') ??
          pickString('field') ??
          '',
    );
  }

  final String source;
  final String target;

  @override
  List<Object?> get props => [source, target];
}

/// Paged list of score imports. The v1 endpoint returns the
/// `score_imports` payload as a serialized JSON **string**
/// inside the `GetSchoolScoreImportsData` envelope; the
/// factory below parses both that shape and a direct list
/// for forward-compat.
@immutable
class ScoreImportPage extends Equatable {
  const ScoreImportPage({required this.scoreImports});

  factory ScoreImportPage.fromJson(JsonMap json) {
    final raw = json['score_imports'];
    final rows = _decodeList(raw).map(ScoreImport.fromJson).toList(
          growable: false,
        );
    return ScoreImportPage(scoreImports: rows);
  }

  final List<ScoreImport> scoreImports;

  bool get isEmpty => scoreImports.isEmpty;

  @override
  List<Object?> get props => [scoreImports];
}

/// Helper: decode a wire value that may be a List, a
/// JSON-encoded String, or `null` into a `List<JsonMap>`. The
/// v1 SDK returns the batch + score-import listings as
/// `String?` (a serialized array), so the mobile has to
/// parse them before iterating. The `List` and `null`
/// fallthroughs keep the factory forward-compat if the
/// server later switches to a native array.
List<JsonMap> _decodeList(Object? raw) {
  if (raw == null) return const <JsonMap>[];
  if (raw is List) {
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, Object?>.from(e))
        .toList(growable: false);
  }
  if (raw is String) {
    if (raw.isEmpty) return const <JsonMap>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => Map<String, Object?>.from(e))
            .toList(growable: false);
      }
    } on FormatException {
      // fall through to empty
    }
  }
  return const <JsonMap>[];
}
