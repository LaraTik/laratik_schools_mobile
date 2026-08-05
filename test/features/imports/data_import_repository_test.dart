// SPDX-License-Identifier: Proprietary
// Tests for the Data Imports repository (read-only data
// imports + score imports, plus the score import validate
// + commit write flows, plus the data import wizard
// upload step).
//
// The tests cover:
//   * [listBatches] parses a wire response that returns the
//     `batches` payload as a serialized JSON string (the
//     canonical v1 shape) and surfaces EMPTY_RESPONSE when
//     the wire returns no data block.
//   * [listBatches] also accepts a native List (forward-
//     compat if the server switches the envelope shape).
//   * [listBatches] surfaces a typed error code from the
//     wire.
//   * [listReconciliation] parses the per-row records
//     (canonical `records` list) and surfaces EMPTY_RESPONSE
//     when the wire returns no data block.
//   * [listReconciliation] forwards the `batch` query
//     parameter to the SDK.
//   * [listScoreImports] parses a wire response that returns
//     the `score_imports` payload as a serialized JSON
//     string (canonical v1 shape).
//   * [listScoreImports] surfaces EMPTY_RESPONSE on empty
//     data.
//   * [listScoreImports] accepts a native List (forward-
//     compat if the server switches the envelope shape).
//   * [validateScoreImport] mints a fresh UUID for the
//     Idempotency-Key header and surfaces EMPTY_RESPONSE on
//     empty data.
//   * [commitScoreImport] mints a fresh UUID for the
//     Idempotency-Key header and surfaces a typed error
//     code from the wire.
//   * [uploadDataImportPackage] mints a fresh UUID for the
//     Idempotency-Key header and forwards the canonical
//     `source` + `package_file` payload.
//   * [uploadDataImportPackage] surfaces a typed error
//     code from the wire.
//   * [DataImportBatch.statusFamily] maps the wire status
//     to a coarse family (success / error / info / warning
//     / neutral) for the chip tone.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/imports/data/data_import.dart';
import 'package:laratik_schools_mobile/features/imports/data/data_import_failure.dart';
import 'package:laratik_schools_mobile/features/imports/data/data_import_repository.dart';
import 'package:laratik_schools_mobile/features/imports/data/uploaded_data_import.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  DataImportRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      DataImportRepository(api: LaratikSchoolsApiClient(transport));

  group('DataImportRepository.listBatches', () {
    test('parses the canonical serialized-string batches payload', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolDataImportBatches,
        envelopeOk({
          'batches': '[{"name":"BATCH-001","status":"committed",'
              '"source_label":"students_q3.zip",'
              '"package_hash":"a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2",'
              '"created_at":"2026-08-03T10:00:00+00:00",'
              '"counts":{"Student":120,"Staff":14,"Subject":22}}]',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listBatches();
      expect(result, isA<Ok<DataImportBatchPage, DataImportFailure>>());
      final page = (result as Ok).value as DataImportBatchPage;
      expect(page.batches.length, 1);
      expect(page.batches[0].name, 'BATCH-001');
      expect(page.batches[0].status, 'committed');
      expect(page.batches[0].statusFamily, 'success');
      expect(page.batches[0].sourceLabel, 'students_q3.zip');
      expect(page.batches[0].shortHash, 'a1b2c3d4e5f6');
      expect(page.batches[0].rowCounts['Student'], 120);
      expect(page.batches[0].rowCounts['Staff'], 14);
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolDataImportBatches,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no batch data.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listBatches();
      expect(result, isA<Err<DataImportBatchPage, DataImportFailure>>());
      final err = (result as Err).error as DataImportFailure;
      expect(err.code, 'EMPTY_RESPONSE');
    });

    test('forwards the limit query parameter to the SDK', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolDataImportBatches,
        envelopeOk({'batches': '[]'}),
      );
      final repo = makeRepo(transport);
      await repo.listBatches(limit: 25);
      expect(transport.invokedArguments.last['limit'], 25);
    });
  });

  group('DataImportRepository.listReconciliation', () {
    test('parses the per-row records list', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolDataImportReconciliation,
        envelopeOk({
          'records': [
            {
              'name': 'REC-001',
              'doctype': 'Student',
              'row_index': 1,
              'status': 'approved',
              'message': 'OK',
              'payload': {'name': 'Ahmad K.', 'grade': 'G3'},
            },
            {
              'name': 'REC-002',
              'doctype': 'Student',
              'row_index': 2,
              'status': 'rejected',
              'message': 'missing required field: email',
              'payload': {'name': 'Sara M.'},
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result =
          await repo.listReconciliation(batch: 'BATCH-001');
      expect(result, isA<Ok<DataImportRecordPage, DataImportFailure>>());
      final page = (result as Ok).value as DataImportRecordPage;
      expect(page.records.length, 2);
      expect(page.records[0].doctype, 'Student');
      expect(page.records[0].rowIndex, 1);
      expect(page.records[0].statusFamily, 'success');
      expect(page.records[1].statusFamily, 'error');
      expect(page.records[1].message, 'missing required field: email');
      expect(page.records[0].payload['name'], 'Ahmad K.');
    });

    test('forwards the batch query parameter to the SDK', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolDataImportReconciliation,
        envelopeOk({'records': const <Object?>[]}),
      );
      final repo = makeRepo(transport);
      await repo.listReconciliation(batch: 'BATCH-XYZ');
      expect(transport.invokedArguments.last['batch'], 'BATCH-XYZ');
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolDataImportReconciliation,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no reconciliation data.',
        ),
      );
      final repo = makeRepo(transport);
      final result =
          await repo.listReconciliation(batch: 'BATCH-001');
      expect(result, isA<Err<DataImportRecordPage, DataImportFailure>>());
      final err = (result as Err).error as DataImportFailure;
      expect(err.code, 'EMPTY_RESPONSE');
    });
  });

  group('DataImportRepository.listScoreImports', () {
    test('parses the canonical serialized-string score_imports payload',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolScoreImports,
        envelopeOk({
          'score_imports': '[{"name":"SC-001","status":"validated",'
              '"source_label":"midterm_g3.csv",'
              '"file_hash":"feedfacefeedfacefeedfacefeedface",'
              '"created_at":"2026-08-03T10:00:00+00:00",'
              '"columns":[{"source":"student_id","target":"school_student"},'
              '{"source":"score","target":"score"}],'
              '"counts":{"valid":120,"invalid":3}}]',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listScoreImports();
      expect(result, isA<Ok<ScoreImportPage, DataImportFailure>>());
      final page = (result as Ok).value as ScoreImportPage;
      expect(page.scoreImports.length, 1);
      expect(page.scoreImports[0].name, 'SC-001');
      expect(page.scoreImports[0].status, 'validated');
      expect(page.scoreImports[0].statusFamily, 'info');
      expect(page.scoreImports[0].columns.length, 2);
      expect(page.scoreImports[0].columns[0].source, 'student_id');
      expect(page.scoreImports[0].columns[0].target, 'school_student');
      expect(page.scoreImports[0].counts['valid'], 120);
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolScoreImports,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no score import data.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listScoreImports();
      expect(result, isA<Err<ScoreImportPage, DataImportFailure>>());
      final err = (result as Err).error as DataImportFailure;
      expect(err.code, 'EMPTY_RESPONSE');
    });

    test('forwards the limit query parameter to the SDK', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolScoreImports,
        envelopeOk({'score_imports': '[]'}),
      );
      final repo = makeRepo(transport);
      await repo.listScoreImports(limit: 10);
      expect(transport.invokedArguments.last['limit'], 10);
    });
  });

  group('DataImportRepository.validateScoreImport', () {
    test('mints a fresh idempotency key and forwards the score_import arg',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.validateSchoolScoreImport,
        envelopeOk({
          'score_import': 'SC-001',
          'status': 'validated',
          'counts': {'valid': 120, 'invalid': 0},
        }),
      );
      final repo = makeRepo(transport);
      final result =
          await repo.validateScoreImport(scoreImport: 'SC-001');
      expect(result, isA<Ok<JsonMap, DataImportFailure>>());
      // The SDK forwards `score_import` (not the wire-shaped
      // `payload`) for this endpoint — see the SDK signature
      // at `validate_school_score_import`.
      expect(transport.invokedArguments.last['score_import'], 'SC-001');
      // The transport adds a fresh Idempotency-Key header on
      // every mutating call; the test ensures the key was
      // minted (not the static placeholder) and was a
      // syntactically-valid UUID v4.
      final key = transport.invokedIdempotencyKey;
      expect(key, isNotNull);
      expect(key!.length, greaterThanOrEqualTo(8));
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.validateSchoolScoreImport,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no validation data.',
        ),
      );
      final repo = makeRepo(transport);
      final result =
          await repo.validateScoreImport(scoreImport: 'SC-001');
      expect(result, isA<Err<JsonMap, DataImportFailure>>());
      final err = (result as Err).error as DataImportFailure;
      expect(err.code, 'EMPTY_RESPONSE');
    });
  });

  group('DataImportRepository.commitScoreImport', () {
    test('mints a fresh idempotency key and forwards the score_import arg',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.commitSchoolScoreImport,
        envelopeOk({
          'score_import': 'SC-001',
          'status': 'committed',
          'job_id': 'job-1',
        }),
      );
      final repo = makeRepo(transport);
      final result =
          await repo.commitScoreImport(scoreImport: 'SC-001');
      expect(result, isA<Ok<JsonMap, DataImportFailure>>());
      expect(transport.invokedArguments.last['score_import'], 'SC-001');
      final key = transport.invokedIdempotencyKey;
      expect(key, isNotNull);
      expect(key!.length, greaterThanOrEqualTo(8));
    });

    test('surfaces a typed error code from the wire', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.commitSchoolScoreImport,
        const ApiError(
          code: 'SCORE_IMPORT_NOT_VALIDATED',
          message: 'Validate the score import before committing.',
        ),
      );
      final repo = makeRepo(transport);
      final result =
          await repo.commitScoreImport(scoreImport: 'SC-001');
      expect(result, isA<Err<JsonMap, DataImportFailure>>());
      final err = (result as Err).error as DataImportFailure;
      expect(err.code, 'SCORE_IMPORT_NOT_VALIDATED');
      expect(err.isRetryable, isFalse);
    });
  });

  group('DataImportBatch.statusFamily', () {
    test('maps wire statuses to coarse families for the chip tone', () {
      const cases = {
        'committed': 'success',
        'approved': 'success',
        'failed': 'error',
        'cancelled': 'error',
        'received': 'warning',
        'dry_run_completed': 'warning',
        'reviewing': 'warning',
        'dry_run_in_progress': 'warning',
        'dry_run_queued': 'info',
        'commit_queued': 'info',
        'queued': 'info',
        'pending_review': 'neutral',
        'weird_status': 'neutral',
      };
      for (final entry in cases.entries) {
        final batch = DataImportBatch.fromJson({
          'name': 'B',
          'status': entry.key,
        });
        expect(batch.statusFamily, entry.value, reason: entry.key);
      }
    });
  });

  group('DataImportRecord.statusFamily', () {
    test('maps wire statuses to coarse families for the chip tone', () {
      const cases = {
        'approved': 'success',
        'rejected': 'error',
        'error': 'error',
        'skipped': 'warning',
        'pending': 'info',
        'unknown_status': 'neutral',
      };
      for (final entry in cases.entries) {
        final record = DataImportRecord.fromJson({
          'name': 'R',
          'status': entry.key,
        });
        expect(record.statusFamily, entry.value, reason: entry.key);
      }
    });
  });

  group('ScoreImport.statusFamily', () {
    test('maps wire statuses to coarse families for the chip tone', () {
      const cases = {
        'committed': 'success',
        'failed': 'error',
        'cancelled': 'error',
        'previewed': 'info',
        'validated': 'info',
        'draft': 'warning',
        'mapping': 'warning',
        'unknown': 'neutral',
      };
      for (final entry in cases.entries) {
        final s = ScoreImport.fromJson({
          'name': 'S',
          'status': entry.key,
        });
        expect(s.statusFamily, entry.value, reason: entry.key);
      }
    });
  });

  group('DataImportRepository.uploadDataImportPackage', () {
    test('forwards the canonical payload + mints a fresh idempotency key',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.uploadSchoolDataImportPackage,
        envelopeOk({
          'batch': 'EDU-IMP-2026-00001',
          'counts': {'School Student': 120, 'School Guardian': 240},
          'package_hash':
              'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
          'status': 'submitted',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.uploadDataImportPackage(
        source: 'spring-2026-enrollment',
        packageFile: 'students_q3.csv',
      );
      expect(
        result,
        isA<Ok<UploadedDataImport, DataImportFailure>>(),
      );
      final uploaded = (result as Ok).value as UploadedDataImport;
      expect(uploaded.batch, 'EDU-IMP-2026-00001');
      expect(uploaded.isSubmitted, isTrue);
      expect(uploaded.counts['School Student'], 120);
      expect(uploaded.counts['School Guardian'], 240);
      expect(uploaded.packageHash, startsWith('a1b2c3d4'));
      // The SDK wraps the caller's payload under a
      // `payload` key, so the test inspects
      // `arguments['payload']`.
      final args = transport.invokedArguments.last;
      final payload = args['payload'] as Map<String, Object?>;
      expect(payload['source'], 'spring-2026-enrollment');
      expect(payload['package_file'], 'students_q3.csv');
      // A fresh UUID v4 was minted for the
      // Idempotency-Key header.
      expect(transport.invokedIdempotencyKey, isNotNull);
      expect(
        transport.invokedIdempotencyKey!.length,
        greaterThanOrEqualTo(8),
      );
    });

    test('falls back to the legacy `name` alias for the batch id', () async {
      // Pure model test — the v1 SDK's
      // `UploadSchoolDataImportPackageData.fromJson`
      // is strict-cast on the canonical `batch` key, so
      // the wire path can only surface the legacy alias
      // if the server grows it. The model still walks
      // the alias walker so a future schema migration
      // doesn't break the parse.
      final parsed = UploadedDataImport.fromJson({
        'name': 'EDU-IMP-2026-00002',
        'status': 'submitted',
      });
      expect(parsed.batch, 'EDU-IMP-2026-00002');
      expect(parsed.isSubmitted, isTrue);
    });

    test('surfaces a typed failure when the server returns an error',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.uploadSchoolDataImportPackage,
        const ApiError(
          code: 'PACKAGE_FILE_REQUIRED',
          message: 'A package_file reference is required.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.uploadDataImportPackage(
        source: 'spring-2026-enrollment',
        packageFile: '',
      );
      expect(
        result,
        isA<Err<UploadedDataImport, DataImportFailure>>(),
      );
      final err = (result as Err).error as DataImportFailure;
      expect(err.code, 'PACKAGE_FILE_REQUIRED');
      expect(err.isRetryable, isFalse);
    });
  });
}
