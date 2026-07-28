import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/assessment/data/assessment_repository.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';

class _FakeAssessmentApi implements LaratikSchoolsApiClient {
  ApiEnvelope<GetSchoolExamPlansData>? plansResponse;
  ApiEnvelope<GetSchoolOnlineExamEligibilityData>? eligibilityResponse;
  ApiEnvelope<StartSchoolExamAttemptData>? startResponse;
  ApiEnvelope<SubmitSchoolExamAttemptData>? submitResponse;
  ApiEnvelope<GetSchoolExamAttemptResultData>? resultResponse;
  ApiEnvelope<AbandonSchoolExamAttemptData>? abandonResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('AssessmentRepository.listExamPlans', () {
    test('parses published plans and filters unpublished', () async {
      final api = _FakeAssessmentApi()
        ..plansResponse = ApiEnvelope<GetSchoolExamPlansData>(
          data: const GetSchoolExamPlansData(plans: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-EXM-2026-00001',
              'title': 'Midterm · Mathematics',
              'subject': 'Mathematics',
              'exam_date': '2026-08-01',
              'duration_minutes': 60,
              'total_marks': 40,
              'status': 'Published',
              'published': true,
            },
            <String, Object?>{
              'name': 'EDU-EXM-2026-00002',
              'title': 'Draft · Arabic',
              'subject': 'Arabic',
              'duration_minutes': 30,
              'total_marks': 20,
              'status': 'Draft',
              'published': false,
            },
          ]),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = AssessmentRepository(api: api);
      final result = await repo.listExamPlans();
      final page = (result as Ok<ExamPlanPage, PersonFailure>).value;
      expect(page.plans, hasLength(1));
      expect(page.plans.first.title, 'Midterm · Mathematics');
      expect(page.plans.first.published, isTrue);
    });
  });

  group('AssessmentRepository.checkEligibility', () {
    test('maps eligible=true to EligibilityResult.eligible', () async {
      final api = _FakeAssessmentApi()
        ..eligibilityResponse = ApiEnvelope<GetSchoolOnlineExamEligibilityData>(
          data: const GetSchoolOnlineExamEligibilityData(
            eligible: 'true',
            reason: '',
            examPlan: 'EDU-EXM-2026-00001',
            schoolStudent: 'EDU-STU-2026-00001',
          ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = AssessmentRepository(api: api);
      final result = await repo.checkEligibility(
        examPlanId: 'EDU-EXM-2026-00001',
        studentId: 'EDU-STU-2026-00001',
      );
      expect(result, isA<Ok<EligibilityResult, PersonFailure>>());
      final eligibility =
          (result as Ok<EligibilityResult, PersonFailure>).value;
      expect(eligibility.eligible, isTrue);
    });

    test('maps ineligible + reason correctly', () async {
      final api = _FakeAssessmentApi()
        ..eligibilityResponse = ApiEnvelope<GetSchoolOnlineExamEligibilityData>(
          data: const GetSchoolOnlineExamEligibilityData(
            eligible: 'false',
            reason: 'Exam window has not opened yet.',
            examPlan: 'EDU-EXM-2026-00001',
            schoolStudent: 'EDU-STU-2026-00001',
          ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = AssessmentRepository(api: api);
      final result = await repo.checkEligibility(
        examPlanId: 'EDU-EXM-2026-00001',
        studentId: 'EDU-STU-2026-00001',
      );
      final eligibility =
          (result as Ok<EligibilityResult, PersonFailure>).value;
      expect(eligibility.eligible, isFalse);
      expect(eligibility.reason, 'Exam window has not opened yet.');
    });
  });

  group('AssessmentRepository.startAttempt', () {
    test('returns the new attempt id', () async {
      final api = _FakeAssessmentApi()
        ..startResponse = ApiEnvelope<StartSchoolExamAttemptData>(
          data: const StartSchoolExamAttemptData(
            attempt: 'EDU-ATMPT-2026-00001',
            status: 'In Progress',
            examPlan: 'EDU-EXM-2026-00001',
            schoolStudent: 'EDU-STU-2026-00001',
          ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = AssessmentRepository(api: api);
      final result = await repo.startAttempt(
        examPlanId: 'EDU-EXM-2026-00001',
        studentId: 'EDU-STU-2026-00001',
      );
      expect(result, isA<Ok<AttemptResult, PersonFailure>>());
      final started = (result as Ok<AttemptResult, PersonFailure>).value;
      expect(started.attemptId, 'EDU-ATMPT-2026-00001');
      expect(started.status, 'In Progress');
    });
  });

  group('AssessmentRepository.submit', () {
    test('returns the submitted attempt id', () async {
      final api = _FakeAssessmentApi()
        ..submitResponse = ApiEnvelope<SubmitSchoolExamAttemptData>(
          data: const SubmitSchoolExamAttemptData(
            attempt: 'EDU-ATMPT-2026-00001',
            status: 'Submitted',
            examPlan: 'EDU-EXM-2026-00001',
            schoolStudent: 'EDU-STU-2026-00001',
            submittedAt: '2026-08-01T10:30:00Z',
          ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = AssessmentRepository(api: api);
      final result = await repo.submit(
        attemptId: 'EDU-ATMPT-2026-00001',
        answers: <String, Object?>{'q-1': 'My answer.'},
      );
      final submitted = (result as Ok<AttemptResult, PersonFailure>).value;
      expect(submitted.attemptId, 'EDU-ATMPT-2026-00001');
      expect(submitted.status, 'Submitted');
    });
  });
}
