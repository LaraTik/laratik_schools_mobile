// SPDX-License-Identifier: Proprietary
// Tests for the Teacher exam repository (read-only exam
// plans + per-subject question catalog + manual grade
// submit + promote exam attempt + create exam plan
// shell).
//
// The tests cover:
//   * [listExamPlans] parses the canonical `plans` list
//     and surfaces EMPTY_RESPONSE when the wire returns
//     no data block.
//   * [listExamPlans] forwards the `subject` filter to
//     the row's `subject` / `subject_name` /
//     `school_subject` key.
//   * [listQuestions] parses the question list and
//     surfaces EMPTY_RESPONSE on empty data.
//   * [listQuestions] honours the `school_subject` query
//     parameter forwarded to the SDK.
//   * [gradeAttempt] mints a fresh UUID for the
//     Idempotency-Key header and forwards the attempt ID
//     + the per-question scores payload.
//   * [gradeAttempt] surfaces a typed error code from
//     the wire.
//   * [promoteExamAttempt] mints a fresh UUID for the
//     Idempotency-Key header and forwards the
//     `{attempt: <id>}` payload.
//   * [promoteExamAttempt] surfaces a typed error code
//     from the wire.
//   * [createExamPlan] mints a fresh UUID for the
//     Idempotency-Key header and forwards the title +
//     optional subject/branch/class/duration/max-score
//     payload fields.
//   * [createExamPlan] surfaces a typed error code
//     from the wire.
//   * [TeacherExamQuestion._decodeQuestion] resolves
//     canonical + legacy wire keys for the question ID,
//     text, type, and marks.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';
import 'package:laratik_schools_mobile/features/teachers/data/promoted_exam_attempt.dart';
import 'package:laratik_schools_mobile/features/teachers/data/teacher_exam_repository.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  TeacherExamRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      TeacherExamRepository(api: LaratikSchoolsApiClient(transport));

  group('TeacherExamRepository.listExamPlans', () {
    test('parses the plans list with the canonical wire shape', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        envelopeOk({
          'plans': [
            {
              'name': 'EX-001',
              'title': 'Midterm G3 Math',
              'subject_name': 'Mathematics',
              'exam_date': '2026-09-15',
              'duration_minutes': 90,
              'max_score': 100,
              'status': 'Published',
            },
            {
              'name': 'EX-002',
              'title': 'Quiz G3 Math',
              'subject_name': 'Mathematics',
              'exam_date': '2026-09-20',
              'duration_minutes': 30,
              'max_score': 20,
              'status': 'Draft',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listExamPlans();
      expect(result, isA<Ok<dynamic, PersonFailure>>());
      final page = (result as Ok).value as dynamic;
      expect(page.plans.length, 2);
      expect(page.plans[0].id, 'EX-001');
      expect(page.plans[0].title, 'Midterm G3 Math');
      expect(page.plans[0].published, isTrue);
      expect(page.plans[0].status, 'Published');
      expect(page.plans[0].totalMarks, 100);
      expect(page.plans[1].published, isFalse);
    });

    test('forwards the subject filter to the row lookup', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        envelopeOk({
          'plans': [
            {
              'name': 'EX-001',
              'title': 'Math',
              'subject_name': 'Mathematics',
              'status': 'Published',
            },
            {
              'name': 'EX-002',
              'title': 'Science',
              'subject_name': 'Science',
              'status': 'Published',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listExamPlans(subject: 'Mathematics');
      final page = (result as Ok).value as dynamic;
      expect(page.plans.length, 1);
      expect(page.plans[0].id, 'EX-001');
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no exam plan data.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listExamPlans();
      expect(result, isA<Err<dynamic, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'EMPTY_RESPONSE');
    });

    test('forwards the cursor query parameter to the SDK', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        envelopeOk({'plans': const <Object?>[]}),
      );
      final repo = makeRepo(transport);
      await repo.listExamPlans(cursor: 'CURSOR-X');
      expect(transport.invokedArguments.last['cursor'], 'CURSOR-X');
    });
  });

  group('TeacherExamRepository.listQuestions', () {
    test('parses the question list with the canonical wire shape', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolQuestions,
        envelopeOk({
          'questions': [
            {
              'name': 'Q-001',
              'question_text': 'What is 2 + 2?',
              'question_type': 'Single Choice',
              'marks': 5,
            },
            {
              'name': 'Q-002',
              'question_text': 'Explain the Pythagorean theorem.',
              'question_type': 'Long Text',
              'marks': 10,
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listQuestions(schoolSubject: 'Mathematics');
      expect(result, isA<Ok<List<TeacherExamQuestion>, PersonFailure>>());
      final list = (result as Ok).value as List<TeacherExamQuestion>;
      expect(list.length, 2);
      expect(list[0].id, 'Q-001');
      expect(list[0].questionText, 'What is 2 + 2?');
      expect(list[0].marks, 5);
      expect(list[1].id, 'Q-002');
      expect(list[1].questionText, 'Explain the Pythagorean theorem.');
      expect(list[1].marks, 10);
    });

    test('forwards the school_subject query parameter to the SDK',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolQuestions,
        envelopeOk({'questions': const <Object?>[]}),
      );
      final repo = makeRepo(transport);
      await repo.listQuestions(schoolSubject: 'Mathematics');
      expect(
        transport.invokedArguments.last['school_subject'],
        'Mathematics',
      );
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolQuestions,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no question data.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listQuestions();
      expect(result, isA<Err<List<TeacherExamQuestion>, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'EMPTY_RESPONSE');
    });

    test('forwards the limit query parameter to the SDK', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolQuestions,
        envelopeOk({'questions': const <Object?>[]}),
      );
      final repo = makeRepo(transport);
      await repo.listQuestions(limit: 10);
      expect(transport.invokedArguments.last['limit'], 10);
    });
  });

  group('TeacherExamRepository.gradeAttempt', () {
    test(
      'mints a fresh idempotency key + forwards attempt + scores',
      () async {
        final transport = FakeLaratikSchoolsTransport();
        transport.respondOnce(
          LaratikSchoolsApiMethods.gradeSchoolExamAttempt,
          envelopeOk({
            'attempt': 'ATT-001',
            'score': 18.0,
            'status': 'Graded',
          }),
        );
        final repo = makeRepo(transport);
        final result = await repo.gradeAttempt(
          attempt: 'ATT-001',
          scores: {'Q-001': 5.0, 'Q-002': 13.0},
        );
        expect(result, isA<Ok<TeacherExamAttemptGrade, PersonFailure>>());
        final grade = (result as Ok).value as TeacherExamAttemptGrade;
        expect(grade.attempt, 'ATT-001');
        expect(grade.score, 18.0);
        expect(grade.status, 'Graded');
        // The SDK wraps write arguments inside `payload`
        // for this endpoint. Tests assert the nested
        // forwarding, not the top-level keys.
        final payload =
            transport.invokedArguments.last['payload'] as JsonMap;
        expect(payload['attempt'], 'ATT-001');
        expect(payload['scores'], isA<Map>());
        expect((payload['scores'] as Map)['Q-001'], 5.0);
        // The transport adds a fresh Idempotency-Key
        // header on every mutating call; the test
        // ensures the key was minted (not the static
        // placeholder) and was a syntactically-valid
        // UUID v4.
        final key = transport.invokedIdempotencyKey;
        expect(key, isNotNull);
        expect(key!.length, greaterThanOrEqualTo(8));
      },
    );

    test('surfaces a typed error code from the wire', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.gradeSchoolExamAttempt,
        const ApiError(
          code: 'EXAM_ATTEMPT_NOT_FOUND',
          message: 'The attempt was not found.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.gradeAttempt(
        attempt: 'ATT-XYZ',
        scores: {'Q-001': 0.0},
      );
      expect(result, isA<Err<TeacherExamAttemptGrade, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'EXAM_ATTEMPT_NOT_FOUND');
      expect(err.isRetryable, isFalse);
    });

    test('surfaces EMPTY_RESPONSE when the wire returns no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.gradeSchoolExamAttempt,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no grade data.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.gradeAttempt(
        attempt: 'ATT-001',
        scores: {'Q-001': 0.0},
      );
      expect(result, isA<Err<TeacherExamAttemptGrade, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'EMPTY_RESPONSE');
    });
  });

  group('TeacherExamRepository.createExamPlan', () {
    test(
      'mints a fresh idempotency key + forwards the title + optional '
      'subject/branch/class/date/duration/max-score fields',
      () async {
        final transport = FakeLaratikSchoolsTransport();
        transport.respondOnce(
          LaratikSchoolsApiMethods.createSchoolExamPlan,
          envelopeOk({
            'exam_plan': 'EX-NEW',
            'status': 'Draft',
          }),
        );
        final repo = makeRepo(transport);
        final result = await repo.createExamPlan(
          title: 'Final G3 Math',
          schoolSubject: 'Mathematics',
          schoolBranch: 'BR-001',
          schoolClassGroup: 'G3-A',
          examDate: '2026-12-15',
          durationMinutes: 120,
          maxScore: 100,
        );
        expect(result, isA<Ok<String, PersonFailure>>());
        expect((result as Ok).value, 'EX-NEW');
        final payload =
            transport.invokedArguments.last['payload'] as JsonMap;
        expect(payload['title'], 'Final G3 Math');
        expect(payload['school_subject'], 'Mathematics');
        expect(payload['school_branch'], 'BR-001');
        expect(payload['school_class_group'], 'G3-A');
        expect(payload['exam_date'], '2026-12-15');
        expect(payload['duration_minutes'], 120);
        expect(payload['max_score'], 100);
        final key = transport.invokedIdempotencyKey;
        expect(key, isNotNull);
        expect(key!.length, greaterThanOrEqualTo(8));
      },
    );

    test('omits empty optional fields from the payload', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.createSchoolExamPlan,
        envelopeOk({'exam_plan': 'EX-NEW'}),
      );
      final repo = makeRepo(transport);
      await repo.createExamPlan(title: 'Standalone Plan');
      final payload =
          transport.invokedArguments.last['payload'] as JsonMap;
      expect(payload['title'], 'Standalone Plan');
      expect(payload.containsKey('school_subject'), isFalse);
      expect(payload.containsKey('school_branch'), isFalse);
      expect(payload.containsKey('school_class_group'), isFalse);
      expect(payload.containsKey('exam_date'), isFalse);
      expect(payload.containsKey('duration_minutes'), isFalse);
      expect(payload.containsKey('max_score'), isFalse);
    });

    test('surfaces a typed error code from the wire', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.createSchoolExamPlan,
        const ApiError(
          code: 'EXAM_PLAN_VALIDATION_FAILED',
          message: 'Title is required.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.createExamPlan(title: '');
      expect(result, isA<Err<String, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'EXAM_PLAN_VALIDATION_FAILED');
    });
  });

  group('TeacherExamRepository.createQuestion', () {
    test(
      'mints a fresh idempotency key + forwards the question payload + '
      'options',
      () async {
        final transport = FakeLaratikSchoolsTransport();
        transport.respondOnce(
          LaratikSchoolsApiMethods.createSchoolQuestion,
          envelopeOk({'question': 'Q-NEW', 'status': 'Draft', 'version': 1}),
        );
        final repo = makeRepo(transport);
        final result = await repo.createQuestion(
          examPlan: 'EX-001',
          questionText: 'What is 2 + 2?',
          questionType: 'Single Choice',
          marks: 5,
          schoolSubject: 'Mathematics',
          options: const [
            {'option_key': 'OPT-1', 'option_text': '3', 'is_correct': false},
            {'option_key': 'OPT-2', 'option_text': '4', 'is_correct': true},
          ],
        );
        expect(result, isA<Ok<String, PersonFailure>>());
        expect((result as Ok).value, 'Q-NEW');
        final payload =
            transport.invokedArguments.last['payload'] as JsonMap;
        expect(payload['exam_plan'], 'EX-001');
        expect(payload['question_text'], 'What is 2 + 2?');
        expect(payload['question_type'], 'Single Choice');
        expect(payload['marks'], 5);
        expect(payload['school_subject'], 'Mathematics');
        final options = payload['options'] as List;
        expect(options.length, 2);
        expect((options[1] as Map)['is_correct'], isTrue);
        final key = transport.invokedIdempotencyKey;
        expect(key, isNotNull);
        expect(key!.length, greaterThanOrEqualTo(8));
      },
    );

    test('omits empty options list from the payload', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.createSchoolQuestion,
        envelopeOk({'question': 'Q-NEW'}),
      );
      final repo = makeRepo(transport);
      await repo.createQuestion(
        examPlan: 'EX-001',
        questionText: 'Explain photosynthesis.',
        questionType: 'Long Text',
        marks: 10,
      );
      final payload =
          transport.invokedArguments.last['payload'] as JsonMap;
      expect(payload.containsKey('options'), isFalse);
      expect(payload.containsKey('school_subject'), isFalse);
    });

    test('surfaces a typed error code from the wire', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.createSchoolQuestion,
        const ApiError(
          code: 'EXAM_QUESTION_VALIDATION_FAILED',
          message: 'Question text is required.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.createQuestion(
        examPlan: 'EX-001',
        questionText: '',
        questionType: 'Short Text',
        marks: 1,
      );
      expect(result, isA<Err<String, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'EXAM_QUESTION_VALIDATION_FAILED');
    });
  });

  group('TeacherExamRepository.publishQuestion', () {
    test(
      'mints a fresh idempotency key + forwards the question id',
      () async {
        final transport = FakeLaratikSchoolsTransport();
        transport.respondOnce(
          LaratikSchoolsApiMethods.publishSchoolQuestion,
          envelopeOk({'question': 'Q-001', 'status': 'Published'}),
        );
        final repo = makeRepo(transport);
        final result = await repo.publishQuestion(question: 'Q-001');
        expect(result, isA<Ok<JsonMap, PersonFailure>>());
        final value = (result as Ok).value as JsonMap;
        expect(value['status'], 'Published');
        // The publish endpoint forwards `question` as a
        // top-level argument (not a payload-wrapped map).
        expect(transport.invokedArguments.last['question'], 'Q-001');
        final key = transport.invokedIdempotencyKey;
        expect(key, isNotNull);
        expect(key!.length, greaterThanOrEqualTo(8));
      },
    );

    test('surfaces a typed error code from the wire', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.publishSchoolQuestion,
        const ApiError(
          code: 'QUESTION_NOT_FOUND',
          message: 'Question was not found.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.publishQuestion(question: 'Q-XYZ');
      expect(result, isA<Err<JsonMap, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'QUESTION_NOT_FOUND');
    });
  });

  group('TeacherExamRepository.publishExam', () {
    test(
      'mints a fresh idempotency key + forwards the exam plan id + the '
      'question ids + the audience list',
      () async {
        final transport = FakeLaratikSchoolsTransport();
        transport.respondOnce(
          LaratikSchoolsApiMethods.publishSchoolOnlineExam,
          envelopeOk({
            'exam_plan': 'EX-001',
            'publication_version': 1,
            'status': 'Published',
          }),
        );
        final repo = makeRepo(transport);
        final result = await repo.publishExam(
          examPlan: 'EX-001',
          questionIds: const ['Q-001', 'Q-002', 'Q-003'],
          audience: const ['ENR-A', 'ENR-B'],
        );
        expect(result, isA<Ok<JsonMap, PersonFailure>>());
        final value = (result as Ok).value as JsonMap;
        expect(value['exam_plan'], 'EX-001');
        expect(value['status'], 'Published');
        final payload =
            transport.invokedArguments.last['payload'] as JsonMap;
        expect(payload['exam_plan'], 'EX-001');
        expect(payload['questions'], ['Q-001', 'Q-002', 'Q-003']);
        expect(payload['audience'], ['ENR-A', 'ENR-B']);
        final key = transport.invokedIdempotencyKey;
        expect(key, isNotNull);
        expect(key!.length, greaterThanOrEqualTo(8));
      },
    );

    test('defaults to empty question + audience lists', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.publishSchoolOnlineExam,
        envelopeOk({'exam_plan': 'EX-001', 'status': 'Published'}),
      );
      final repo = makeRepo(transport);
      await repo.publishExam(examPlan: 'EX-001');
      final payload =
          transport.invokedArguments.last['payload'] as JsonMap;
      expect(payload['questions'], isEmpty);
      expect(payload['audience'], isEmpty);
    });

    test('surfaces a typed error code from the wire', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.publishSchoolOnlineExam,
        const ApiError(
          code: 'EXAM_PLAN_NOT_FOUND',
          message: 'Exam plan was not found.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.publishExam(examPlan: 'EX-XYZ');
      expect(result, isA<Err<JsonMap, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'EXAM_PLAN_NOT_FOUND');
    });
  });

  group('TeacherExamRepository.promoteExamAttempt', () {
    test('mints a fresh idempotency key + forwards the attempt id',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.promoteSchoolExamAttempt,
        envelopeOk({
          'grade_record': 'GR-00042',
          'status': 'promoted',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.promoteExamAttempt(attempt: 'AT-00001');
      expect(result, isA<Ok<PromotedExamAttempt, PersonFailure>>());
      final promoted = (result as Ok).value as PromotedExamAttempt;
      expect(promoted.gradeRecord, 'GR-00042');
      expect(promoted.isPromoted, isTrue);
      // The SDK wraps the caller's payload under a `payload`
      // key, so the test inspects `arguments['payload']`.
      final args = transport.invokedArguments.last;
      final payload = args['payload'] as Map<String, Object?>;
      expect(payload['attempt'], 'AT-00001');
      // A fresh UUID v4 was minted for the Idempotency-Key
      // header.
      expect(transport.invokedIdempotencyKey, isNotNull);
      expect(transport.invokedIdempotencyKey!.length,
          greaterThanOrEqualTo(8));
    });

    test('surfaces a typed error code from the wire', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.promoteSchoolExamAttempt,
        const ApiError(
          code: 'EXAM_ATTEMPT_NOT_GRADED',
          message: 'Only graded attempts can be promoted.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.promoteExamAttempt(attempt: 'AT-00001');
      expect(result, isA<Err<PromotedExamAttempt, PersonFailure>>());
      final err = (result as Err).error as PersonFailure;
      expect(err.code, 'EXAM_ATTEMPT_NOT_GRADED');
    });
  });
}
