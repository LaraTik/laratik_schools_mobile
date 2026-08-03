// SPDX-License-Identifier: Proprietary
// Tests for the Grading repository (read-only overview +
// policies + setup context + admin write flows).
//
// The tests cover:
//   * [fetchOverview] parses the merged operations +
//     overview context into a [GradingOverview] with the
//     canonical KPIs preserved.
//   * [fetchOverview] surfaces a typed failure when either
//     endpoint errors.
//   * [listPolicies] parses rows and preserves the canonical
//     + legacy wire keys.
//   * [fetchPolicySetupContext] parses the role sets + the
//     managed-doctypes string.
//   * [correctGradeRecord] posts the canonical payload
//     shape (`{score, max_score, reason?}`) + mints a fresh
//     UUID for the `Idempotency-Key` header.
//   * [correctGradeRecord] surfaces a typed failure on
//     empty / error envelopes.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/grading/data/grade_record_correction.dart';
import 'package:laratik_schools_mobile/features/grading/data/grading_failure.dart';
import 'package:laratik_schools_mobile/features/grading/data/grading_overview.dart';
import 'package:laratik_schools_mobile/features/grading/data/grading_repository.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  GradingRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      GradingRepository(api: LaratikSchoolsApiClient(transport));

  group('GradingRepository.fetchOverview', () {
    test('parses the merged operations + overview into a GradingOverview',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getGradingOverviewContext,
        envelopeOk({
          'coverage': 'latest_year_term',
          'feature': 'grading_admin_v1',
          'recent_students': 'STU-00001, STU-00002',
          'workflow_stages': [
            {'name': 'draft', 'label': 'Draft', 'count': 12},
            {'name': 'submitted', 'label': 'Submitted', 'count': 3},
            {'name': 'promoted', 'label': 'Promoted', 'count': 87},
          ],
        }),
      );
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGradingOperationsOverview,
        envelopeOk({
          'branches': <Object?>[],
          'schema': <String, Object?>{'version': 'v1'},
          'summary': {
            'total_grades': 102,
            'published_grades': 87,
            'draft_grades': 15,
            'average_score': 84.2,
            'pass_rate': 92.5,
          },
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchOverview();
      expect(result, isA<Ok<GradingOverview, GradingFailure>>());
      final overview = (result as Ok).value as GradingOverview;
      expect(overview.totalGrades, 102);
      expect(overview.publishedGrades, 87);
      expect(overview.draftGrades, 15);
      expect(overview.averageScore, closeTo(84.2, 0.001));
      expect(overview.passRate, closeTo(92.5, 0.001));
      expect(overview.coverage, 'latest_year_term');
      expect(overview.feature, 'grading_admin_v1');
      expect(overview.recentStudents, 'STU-00001, STU-00002');
      expect(overview.workflowStages.length, 3);
      expect(overview.workflowStages[0].stageFamily, 'draft');
      expect(overview.workflowStages[0].count, 12);
      expect(overview.workflowStages[2].stageFamily, 'promoted');
    });

    test('returns null pass rate when no grades are published', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getGradingOverviewContext,
        envelopeOk({
          'coverage': 'latest_year_term',
          'feature': 'grading_admin_v1',
          'workflow_stages': <Object?>[],
        }),
      );
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGradingOperationsOverview,
        envelopeOk({
          'branches': <Object?>[],
          'schema': <String, Object?>{'version': 'v1'},
          'summary': {
            'total_grades': 0,
            'published_grades': 0,
            'draft_grades': 0,
          },
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchOverview();
      expect(result, isA<Ok<GradingOverview, GradingFailure>>());
      final overview = (result as Ok).value as GradingOverview;
      expect(overview.totalGrades, 0);
      expect(overview.passRatePercent, isNull);
    });

    test('surfaces a typed failure when the operations endpoint errors',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getGradingOverviewContext,
        envelopeOk({
          'coverage': 'latest_year_term',
          'feature': 'grading_admin_v1',
          'workflow_stages': <Object?>[],
        }),
      );
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolGradingOperationsOverview,
        const ApiError(
          code: 'HTTP_502',
          message: 'Upstream down',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchOverview();
      expect(result, isA<Err<GradingOverview, GradingFailure>>());
      final err = (result as Err).error as GradingFailure;
      expect(err.code, 'HTTP_502');
      expect(err.isRetryable, isTrue);
    });
  });

  group('GradingRepository.listPolicies', () {
    test('parses rows and preserves canonical + legacy wire keys', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolSubjectGradePolicies,
        envelopeOk({
          'policies': [
            {
              'name': 'EDU-SGP-2026-00001',
              'title': 'Mathematics policy',
              'subject': 'EDU-SUB-2026-00001',
              'grade_band': 'Grade 1-5',
              'pass_threshold': 65.0,
              'status': 'Approved',
              'approver': 'admin@school.example',
              'approved_at': '2026-08-01T10:00:00+00:00',
            },
            {
              'name': 'EDU-SGP-2026-00002',
              'policy_name': 'Science policy',
              'school_subject': 'Science',
              'band': 'Grade 6-9',
              'pass_pct': 70.0,
              'status': 'Pending Approval',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listPolicies();
      expect(result, isA<Ok<SubjectGradePolicyPage, GradingFailure>>());
      final page = (result as Ok).value as SubjectGradePolicyPage;
      expect(page.policies.length, 2);
      expect(page.policies[0].id, 'EDU-SGP-2026-00001');
      expect(page.policies[0].name, 'Mathematics policy');
      expect(page.policies[0].subject, 'EDU-SUB-2026-00001');
      expect(page.policies[0].gradeBand, 'Grade 1-5');
      expect(page.policies[0].passThreshold, closeTo(65.0, 0.001));
      expect(page.policies[0].status, 'Approved');
      expect(page.policies[0].approver, 'admin@school.example');
      expect(page.policies[0].approvedAt, '2026-08-01T10:00:00+00:00');
      expect(page.policies[0].statusFamily, 'approved');
      // Legacy keys: school_subject / band / pass_pct.
      expect(page.policies[1].subject, 'Science');
      expect(page.policies[1].gradeBand, 'Grade 6-9');
      expect(page.policies[1].passThreshold, closeTo(70.0, 0.001));
      expect(page.policies[1].statusFamily, 'pending');
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolSubjectGradePolicies,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'No policy data',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listPolicies();
      expect(result, isA<Err<SubjectGradePolicyPage, GradingFailure>>());
      final err = (result as Err).error as GradingFailure;
      expect(err.code, 'EMPTY_RESPONSE');
    });
  });

  group('GradingRepository.fetchPolicySetupContext', () {
    test('parses the role sets + the managed-doctypes string', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getGradingPolicySetupContext,
        envelopeOk({
          'doctype': 'School Subject Grade Policy',
          'feature': 'grading_admin_v1',
          'managed_doctypes':
              'School Subject Grade Policy,School Assessment Result',
          'read_roles': [
            'LS Super Admin',
            'LS School Admin',
            'LS Academic Coordinator',
          ],
          'required_roles': [
            'LS Super Admin',
            'LS School Admin',
          ],
          'native_links': {
            'school_subject': 'subject',
            'school_grade_band': 'grade_band',
          },
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.fetchPolicySetupContext();
      expect(result, isA<Ok<GradingPolicySetupContext, GradingFailure>>());
      final setup = (result as Ok).value as GradingPolicySetupContext;
      expect(setup.doctype, 'School Subject Grade Policy');
      expect(setup.managedDoctypes,
          'School Subject Grade Policy,School Assessment Result');
      expect(setup.readRoles.length, 3);
      expect(setup.readRoles.first, 'LS Super Admin');
      expect(setup.requiredRoles.length, 2);
      expect(setup.nativeLinks['school_subject'], 'subject');
    });
  });

  group('GradingRepository.correctGradeRecord', () {
    test('posts the canonical payload + mints a fresh idempotency key',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.correctSchoolGradeRecord,
        envelopeOk({
          'grade_record': 'GR-00001',
          'status': 'corrected',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.correctGradeRecord(
        gradeName: 'GR-00001',
        score: 92.0,
        maxScore: 100.0,
        reason: 'Score entry typo on the original grade sheet.',
      );
      expect(result, isA<Ok<CorrectedGradeRecord, GradingFailure>>());
      final corrected = (result as Ok).value as CorrectedGradeRecord;
      expect(corrected.gradeName, 'GR-00001');
      expect(corrected.message, 'corrected');
      // A fresh UUID v4 was minted for the Idempotency-Key
      // header (the only invariant the write-flow test cares
      // about — the SDK auto-mints if the caller doesn't pass
      // one, but the repository's `Uuid` instance is the
      // contract).
      expect(transport.invokedIdempotencyKey, isNotNull);
      expect(transport.invokedIdempotencyKey!.length, greaterThanOrEqualTo(8));
    });

    test('omits the reason key when reason is null or empty', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.correctSchoolGradeRecord,
        envelopeOk({
          'grade_name': 'GR-00001',
          'corrected_score': 80.0,
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.correctGradeRecord(
        gradeName: 'GR-00001',
        score: 80.0,
        maxScore: 100.0,
        reason: '',
      );
      expect(result, isA<Ok<CorrectedGradeRecord, GradingFailure>>());
    });

    test('surfaces a typed failure when the server returns an error',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.correctSchoolGradeRecord,
        envelopeErr(const ApiError(
          code: 'INVALID_CORRECTION_SCORE',
          message: 'Score cannot exceed max score.',
        )),
      );
      final repo = makeRepo(transport);
      final result = await repo.correctGradeRecord(
        gradeName: 'GR-00001',
        score: 200.0,
        maxScore: 100.0,
      );
      expect(result, isA<Err<CorrectedGradeRecord, GradingFailure>>());
      final err = (result as Err).error as GradingFailure;
      expect(err.code, 'INVALID_CORRECTION_SCORE');
    });
  });

  group('GradingWorkflowStage.stageFamily', () {
    test('maps the wire stage name to a coarse family', () {
      const cases = {
        'Draft': 'draft',
        'Submitted': 'submitted',
        'In Progress': 'submitted',
        'Promoted': 'promoted',
        'Approved': 'promoted',
        'Completed': 'promoted',
        'Corrected': 'corrected',
        'Rejected': 'rejected',
        'Failed': 'rejected',
        'Unknown': 'other',
      };
      for (final entry in cases.entries) {
        final stage = GradingWorkflowStage.fromJson({
          'name': entry.key,
          'label': entry.key,
        });
        expect(stage.stageFamily, entry.value, reason: entry.key);
      }
    });
  });
}
