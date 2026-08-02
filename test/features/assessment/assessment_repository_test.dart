// SPDX-License-Identifier: Proprietary
// Tests for the Assessment repository, using a `FakeLaratikSchoolsTransport`
// behind the production `LaratikSchoolsApiClient`.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/assessment/data/assessment_repository.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  AssessmentRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      AssessmentRepository(api: LaratikSchoolsApiClient(transport));

  group('AssessmentRepository.listExamPlans', () {
    test('publishedOnly accepts plans with status=Published (v1 wire shape)',
        () async {
      // Regression: the v1 `get_school_exam_plans` wire format does
      // not expose a `published` boolean; the only "is this visible
      // right now" signal is the `status` string. Plans with
      // `status: 'Published'` and no `published` field must still
      // surface so the dashboard's exams list isn't empty.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        envelopeOk({
          'plans': [
            {
              'exam_plan': 'EXM-00002',
              'exam_name': 'Arithmetic Practice Quiz',
              'school_subject': 'SUB-Mathematics-Main-Campus',
              'subject_name': 'Mathematics',
              'exam_date': '2026-07-28',
              'duration_minutes': 30,
              'max_score': 6.0,
              'status': 'Published',
              // no `published` boolean in v1
            },
            {
              'exam_plan': 'EXM-00003',
              'exam_name': 'Closed Quiz',
              'status': 'Closed',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listExamPlans();
      final page = (result as Ok<ExamPlanPage, PersonFailure>).value;
      expect(page.plans, hasLength(1));
      expect(page.plans.first.id, 'EXM-00002');
      expect(page.plans.first.title, 'Arithmetic Practice Quiz');
      expect(page.plans.first.published, isTrue);
    });

    test('parses published plans and filters unpublished', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        envelopeOk({
          'plans': [
            {
              'name': 'EDU-EXM-2026-00001',
              'title': 'Midterm · Mathematics',
              'subject': 'Mathematics',
              'exam_date': '2026-08-01',
              'duration_minutes': 60,
              'total_marks': 40,
              'status': 'Published',
              'published': true,
            },
            {
              'name': 'EDU-EXM-2026-00002',
              'title': 'Draft · Arabic',
              'subject': 'Arabic',
              'duration_minutes': 30,
              'total_marks': 20,
              'status': 'Draft',
              'published': false,
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listExamPlans();
      final page = (result as Ok<ExamPlanPage, PersonFailure>).value;
      expect(page.plans, hasLength(1));
      expect(page.plans.first.title, 'Midterm · Mathematics');
      expect(page.plans.first.published, isTrue);
    });
  });

  group('AssessmentRepository.checkEligibility', () {
    test('maps eligible=true to EligibilityResult.eligible', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolOnlineExamEligibility,
        envelopeOk({
          'eligible': true,
          'exam_plan': 'EDU-EXM-2026-00001',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.checkEligibility(
        examPlanId: 'EDU-EXM-2026-00001',
        studentId: 'EDU-STU-2026-00001',
      );
      expect(result, isA<Ok<EligibilityResult, PersonFailure>>());
      final eligibility =
          (result as Ok<EligibilityResult, PersonFailure>).value;
      expect(eligibility.eligible, isTrue);
    });

    test('maps ineligible correctly', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolOnlineExamEligibility,
        envelopeOk({
          'eligible': false,
          'exam_plan': 'EDU-EXM-2026-00001',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.checkEligibility(
        examPlanId: 'EDU-EXM-2026-00001',
        studentId: 'EDU-STU-2026-00001',
      );
      final eligibility =
          (result as Ok<EligibilityResult, PersonFailure>).value;
      expect(eligibility.eligible, isFalse);
    });

    test(
        'forwards schoolEnrollment on the wire so the v1 is_eligible '
        'server check can match the audience row', () async {
      // Regression: the v1 `is_eligible` short-circuits to False when
      // `school_enrollment` is empty. The mobile resolves the active
      // enrollment from the dashboard's "Acting as" card and must
      // forward it through the eligibility call; dropping it on the
      // floor would always yield `not eligible` even for legitimate
      // students.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolOnlineExamEligibility,
        envelopeOk({
          'eligible': true,
          'exam_plan': 'EDU-EXM-2026-00001',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.checkEligibility(
        examPlanId: 'EDU-EXM-2026-00001',
        studentId: 'EDU-STU-2026-00001',
        schoolEnrollment: 'EDU-ENR-2026-00002',
      );
      expect(result, isA<Ok<EligibilityResult, PersonFailure>>());
      // The fake records the last `arguments` map the SDK passed
      // through; check the eligibility method's call had the
      // enrollment id on it.
      final eligibilityIndex = transport.invokedMethods.indexOf(
        LaratikSchoolsApiMethods.getSchoolOnlineExamEligibility,
      );
      expect(eligibilityIndex, isNonNegative);
      final args = transport.invokedArguments[eligibilityIndex];
      expect(args['school_enrollment'], 'EDU-ENR-2026-00002');
      expect(args['school_student'], 'EDU-STU-2026-00001');
      expect(args['exam_plan'], 'EDU-EXM-2026-00001');
    });

    test('omits schoolEnrollment from the wire when not supplied', () async {
      // The wire contract allows the field to be optional (older
      // clients don't pass it). Verify we don't accidentally emit
      // an empty string and trip server-side truthiness checks.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolOnlineExamEligibility,
        envelopeOk({
          'eligible': false,
          'exam_plan': 'EDU-EXM-2026-00001',
        }),
      );
      final repo = makeRepo(transport);
      await repo.checkEligibility(
        examPlanId: 'EDU-EXM-2026-00001',
        studentId: 'EDU-STU-2026-00001',
      );
      final eligibilityIndex = transport.invokedMethods.indexOf(
        LaratikSchoolsApiMethods.getSchoolOnlineExamEligibility,
      );
      final args = transport.invokedArguments[eligibilityIndex];
      expect(args.containsKey('school_enrollment'), isFalse);
    });
  });

  group('AssessmentRepository.startAttempt', () {
    test('returns the new attempt id + question set', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.startSchoolExamAttempt,
        envelopeOk({
          'attempt': 'EDU-ATMPT-2026-00001',
          'status': 'In Progress',
          'ends_at': '2026-08-01T10:30:00Z',
          'revision': 1,
          'question_order': ['q-1', 'q-2'],
          'questions': [
            {
              'name': 'q-1',
              'question_text': 'What is 2 + 2?',
              'question_type': 'text',
              'marks': 5,
            },
            {
              'name': 'q-2',
              'question_text': 'Pick the prime number.',
              'question_type': 'multi_choice',
              'marks': 3,
              'options': [
                {'name': 'A', 'label': '4'},
                {'name': 'B', 'label': '7'},
              ],
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.startAttempt(
        examPlanId: 'EDU-EXM-2026-00001',
        studentId: 'EDU-STU-2026-00001',
      );
      expect(result, isA<Ok<StartAttemptResult, PersonFailure>>());
      final started = (result as Ok<StartAttemptResult, PersonFailure>).value;
      expect(started.attemptId, 'EDU-ATMPT-2026-00001');
      expect(started.status, 'In Progress');
      expect(started.revision, 1);
      expect(started.questions, hasLength(2));
      expect(started.questionOrder, <String>['q-1', 'q-2']);
      expect(started.questions.first.marks, 5);
    });
  });

  group('AssessmentRepository.submit', () {
    test('returns the submitted attempt id', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.submitSchoolExamAttempt,
        envelopeOk({
          'attempt': 'EDU-ATMPT-2026-00001',
          'status': 'Submitted',
          'revision': 1,
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.submit(
        attemptId: 'EDU-ATMPT-2026-00001',
        revision: 1,
        answers: <String, Object?>{'q-1': 'My answer.'},
      );
      final submitted = (result as Ok<AttemptStatus, PersonFailure>).value;
      expect(submitted.attemptId, 'EDU-ATMPT-2026-00001');
      expect(submitted.status, 'Submitted');
    });
  });
}
