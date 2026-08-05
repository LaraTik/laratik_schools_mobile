// SPDX-License-Identifier: Proprietary
// Data imports repository — wraps the v1 endpoints the
// read-only data imports surface needs.
//
// Today (read-only data imports + score imports):
//   * `get_school_data_import_batches` → list of past data
//     import batches (cursor + limit).
//   * `get_school_data_import_reconciliation` → per-row
//     reconciliation records for a batch (cursor + limit).
//   * `get_school_score_imports` → list of past score
//     imports (cursor + limit; branch filter).
//   * `validate_school_score_import` (write) — refresh the
//     per-stage counts for a score import.
//   * `commit_school_score_import` (write) — promote a
//     validated score import.
//   * `promote_school_imported_score` (write) — promote a
//     single imported score to a grade record.
//   * `approve_school_score_reconciliation` (write) —
//     approve a pending reconciliation.
//
// The 6-step data import wizard (upload → dry-run →
// review → approve → commit) is deferred to a follow-up
// turn — `upload_school_data_import_package` expects a
// pre-uploaded `package_file` (Frappe's file API) which
// is outside the v1 SDK scope today. The data + score
// imports surfaces therefore render the server's existing
// batches + reconciliations + score imports, and ship
// "Dry-run / Validate / Commit" buttons for the score
// import slice because that one DOES have a writable
// server-side endpoint the v1 SDK already exposes.

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import 'data_import.dart';
import 'data_import_failure.dart';
import 'uploaded_data_import.dart';

class DataImportRepository {
  DataImportRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

  /// List past data import batches. The server returns the
  /// `batches` payload as a JSON string inside the
  /// envelope; the model factory handles the decode.
  Future<Result<DataImportBatchPage, DataImportFailure>>
      listBatches({
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolDataImportBatches(
        cursor: cursor,
        limit: limit ?? 50,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: DataImportFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no batch data.',
          ),
        );
      }
      return Ok(value: DataImportBatchPage.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Per-row reconciliation records for a batch. The server
  /// returns the `records` payload as a native list inside
  /// the envelope; the model factory is forward-compat with
  /// a serialized string.
  Future<Result<DataImportRecordPage, DataImportFailure>>
      listReconciliation({
    required String batch,
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolDataImportReconciliation(
        batch: batch,
        cursor: cursor,
        limit: limit ?? 100,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: DataImportFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no reconciliation data.',
          ),
        );
      }
      return Ok(value: DataImportRecordPage.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// List past score imports. The server returns the
  /// `score_imports` payload as a JSON string inside the
  /// envelope; the model factory handles the decode.
  Future<Result<ScoreImportPage, DataImportFailure>>
      listScoreImports({
    String? schoolBranch,
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolScoreImports(
        schoolBranch: schoolBranch,
        cursor: cursor,
        limit: limit ?? 50,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: DataImportFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no score import data.',
          ),
        );
      }
      return Ok(value: ScoreImportPage.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Refresh the per-stage counts on a score import.
  Future<Result<JsonMap, DataImportFailure>> validateScoreImport({
    required String scoreImport,
  }) async {
    try {
      final response = await _api.validateSchoolScoreImport(
        scoreImport: scoreImport,
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: DataImportFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no validation data.',
          ),
        );
      }
      return Ok(value: Map<String, Object?>.from(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Submit a new data import package to the server. The
  /// v1 server's `upload_school_data_import_package` takes
  /// a `payload: { 'package_file': <url-or-path>,
  /// 'source': <label> }` envelope — the mobile passes
  /// the file name as a placeholder for `package_file`
  /// (the full multipart upload to Frappe's file API is
  /// a follow-up; the server accepts a URL reference
  /// today). The repository mints a fresh UUID v4 for
  /// the `Idempotency-Key` header so a retry of the
  /// same submit is safe to send again.
  Future<Result<UploadedDataImport, DataImportFailure>>
      uploadDataImportPackage({
    required String source,
    required String packageFile,
  }) async {
    try {
      final response = await _api.uploadSchoolDataImportPackage(
        payload: <String, Object?>{
          'source': source,
          'package_file': packageFile,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: DataImportFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no upload data.',
          ),
        );
      }
      return Ok(value: UploadedDataImport.fromJson(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Commit a validated score import (the server returns a
  /// `job_id`; the mobile does not currently poll — the
  /// operator refreshes the list to see the new status).
  Future<Result<JsonMap, DataImportFailure>> commitScoreImport({
    required String scoreImport,
  }) async {
    try {
      final response = await _api.commitSchoolScoreImport(
        scoreImport: scoreImport,
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: DataImportFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no commit data.',
          ),
        );
      }
      return Ok(value: Map<String, Object?>.from(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  DataImportFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const DataImportFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return DataImportFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  DataImportFailure _exceptionFailure(Exception e) {
    return DataImportFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
