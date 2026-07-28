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
