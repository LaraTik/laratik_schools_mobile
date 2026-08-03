// SPDX-License-Identifier: Proprietary
// Teacher exam repository — wraps the v1 endpoints the
// "Exam authoring + manual grading" surface needs.
//
// Today (teacher exam authoring + manual grading):
//   * `get_school_exam_plans` → list exam plans (server-
//     side filter to the current teacher when the session
//     is a teacher role; the mobile does not (and should
//     not) issue a "my exam plans" query). The mobile
//     requests `publishedOnly: false` so the teacher sees
//     drafts + closed plans, not just the student-visible
//     open set.
//   * `get_school_questions` → the question catalog
//     filtered to a specific subject so the per-plan
//     detail can show the question text + marks.
//   * `grade_school_exam_attempt` (write) — submit per-
//     question scores for an attempt. The mobile mints a
//     fresh UUID for the `Idempotency-Key` header; the
//     server returns the new total score.
//   * `create_school_exam_plan` (write) — the
//     create-exam-plan form action.
//
// The `create_school_question` + `create_school_question_version`
// + `publish_school_question` + `publish_school_online_exam`
// write flows are part of the full exam authoring flow;
// the mobile currently only supports the
// `create_school_exam_plan` shell (the question editor
// + per-question publishing is a future follow-up
// because the question authoring form is the largest
// single form in the app and deserves its own turn).
// The `promote_school_exam_attempt` write flow (per
// graded attempt → grade record) is also deferred to
// the follow-up turn because it depends on the per-grade
// policy catalog the grading surface already surfaces.

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../assessment/data/assessment_repository.dart' show ExamPlanPage;
import '../../assessment/data/exam.dart';
import '../../people/data/person_failure.dart';

/// A flat row from `get_school_questions`. The v1 SDK
/// doesn't expose a typed question class outside of
/// `ExamQuestion` (the student-side, on-attempt shape);
/// the teacher-side listing is permissive so a future
/// server-side schema growth (randomisation policy,
/// difficulty tag, etc.) flows through without an app
/// update.
class TeacherExamQuestion {
  const TeacherExamQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.marks,
  });

  /// The `School Question` id. The mobile uses this as the
  /// key in the per-question scores map passed to
  /// `grade_school_exam_attempt`.
  final String id;
  final String questionText;
  final String questionType;
  final int marks;
}

/// The typed result of a `grade_school_exam_attempt` call.
class TeacherExamAttemptGrade {
  const TeacherExamAttemptGrade({
    required this.attempt,
    required this.score,
    required this.status,
  });

  final String attempt;
  final double? score;
  final String status;
}

@immutable
class TeacherExamRepository {
  const TeacherExamRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

  /// List exam plans. The wire shape is the same as the
  /// student-facing `listExamPlans` on
  /// [AssessmentRepository]; the only difference is the
  /// `publishedOnly` filter, which defaults to `false`
  /// here so the teacher sees drafts + closed plans.
  Future<Result<ExamPlanPage, PersonFailure>> listExamPlans({
    String? cursor,
    int? limit,
    String? subject,
  }) async {
    try {
      final response = await _api.getSchoolExamPlans(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: PersonFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no exam plan data.',
          ),
        );
      }
      // Teacher view: include drafts + closed plans. The
      // server may have already filtered to plans the
      // current teacher owns (via
      // `_resolve_allowed_branches`); the mobile does NOT
      // issue a "my plans" query.
      final rows = data.plans ?? const <JsonMap>[];
      final plans = rows
          .where((row) => _matchesSubject(row, subject))
          .map(ExamPlan.fromJson)
          .toList(growable: false);
      return Ok(
        value: ExamPlanPage(
          plans: plans,
          nextCursor: _nextCursorFromMeta(response.meta),
        ),
      );
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// List the questions in the school's catalog, optionally
  /// filtered by subject. Used by the per-plan detail
  /// surface to render the question list + per-question
  /// marks.
  Future<Result<List<TeacherExamQuestion>, PersonFailure>>
      listQuestions({
    String? schoolBranch,
    String? schoolSubject,
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolQuestions(
        schoolBranch: schoolBranch,
        schoolSubject: schoolSubject,
        limit: limit ?? 50,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: PersonFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no question data.',
          ),
        );
      }
      // The v1 SDK's `GetSchoolQuestionsData` returns the
      // `questions` payload as a native `List<JsonMap>?`.
      // The mobile parses each row into a
      // [TeacherExamQuestion] with a permissive shape so
      // a future server-side schema growth flows through.
      final rows = data.questions ?? const <JsonMap>[];
      final questions = rows.map(_decodeQuestion).toList(
            growable: false,
          );
      return Ok(value: questions);
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Submit per-question scores for an attempt. The wire
  /// payload is `{ "attempt": <id>, "scores": { <qid>:
  /// <score>, ... } }`. The mobile mints a fresh UUID v4
  /// for the `Idempotency-Key` header so retrying the
  /// grade action on a flaky network does not double-
  /// record the scores server-side.
  Future<Result<TeacherExamAttemptGrade, PersonFailure>>
      gradeAttempt({
    required String attempt,
    required Map<String, double> scores,
  }) async {
    try {
      final response = await _api.gradeSchoolExamAttempt(
        payload: <String, Object?>{
          'attempt': attempt,
          'scores': scores,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: PersonFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no grade data.',
          ),
        );
      }
      return Ok(
        value: TeacherExamAttemptGrade(
          attempt: data.attempt ?? attempt,
          score: data.score,
          status: data.status ?? 'Graded',
        ),
      );
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Create a new exam plan shell (no questions yet). The
  /// full question editor + per-question publishing is a
  /// follow-up turn; this endpoint ships today so the
  /// teacher can at least create a plan row from the
  /// mobile.
  Future<Result<String, PersonFailure>> createExamPlan({
    required String title,
    String? schoolSubject,
    String? schoolBranch,
    String? schoolClassGroup,
    String? examDate,
    int? durationMinutes,
    int? maxScore,
  }) async {
    try {
      final response = await _api.createSchoolExamPlan(
        payload: <String, Object?>{
          'title': title,
          if (schoolSubject != null && schoolSubject.isNotEmpty)
            'school_subject': schoolSubject,
          if (schoolBranch != null && schoolBranch.isNotEmpty)
            'school_branch': schoolBranch,
          if (schoolClassGroup != null && schoolClassGroup.isNotEmpty)
            'school_class_group': schoolClassGroup,
          if (examDate != null && examDate.isNotEmpty) 'exam_date': examDate,
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
          if (maxScore != null) 'max_score': maxScore,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: PersonFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no exam plan data.',
          ),
        );
      }
      return Ok(value: data.examPlan ?? '');
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Add a new question to the school's question catalog
  /// (and to this exam plan, by way of the `exam_plan`
  /// field). The wire envelope is permissive
  /// (`additionalProperties: true` on the server) so the
  /// mobile forwards the canonical question fields + the
  /// optional `options` list (one entry per choice option
  /// for `Single Choice` / `Multiple Choice` / `True/False`
  /// questions) + the parent exam plan + subject + branch.
  Future<Result<String, PersonFailure>> createQuestion({
    required String examPlan,
    required String questionText,
    required String questionType,
    required int marks,
    String? schoolSubject,
    String? schoolBranch,
    List<JsonMap>? options,
  }) async {
    try {
      final response = await _api.createSchoolQuestion(
        payload: <String, Object?>{
          'exam_plan': examPlan,
          'question_text': questionText,
          'question_type': questionType,
          'marks': marks,
          if (schoolSubject != null && schoolSubject.isNotEmpty)
            'school_subject': schoolSubject,
          if (schoolBranch != null && schoolBranch.isNotEmpty)
            'school_branch': schoolBranch,
          if (options != null && options.isNotEmpty) 'options': options,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: PersonFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no question data.',
          ),
        );
      }
      return Ok(value: data.question ?? '');
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Publish a single question (server-side: marks the
  /// `School Question` as ready to be served to students).
  Future<Result<JsonMap, PersonFailure>> publishQuestion({
    required String question,
  }) async {
    try {
      final response = await _api.publishSchoolQuestion(
        question: question,
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: PersonFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no publish data.',
          ),
        );
      }
      return Ok(value: Map<String, Object?>.from(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Publish an exam plan — marks the whole exam
  /// (`School Online Exam`) as Published + freezes the
  /// audience (list of enrollment rows) + the question
  /// list. Once published, the plan becomes visible to
  /// the eligible students via `get_school_exam_plans`
  /// + `get_school_online_exam_eligibility`.
  Future<Result<JsonMap, PersonFailure>> publishExam({
    required String examPlan,
    List<String> questionIds = const [],
    List<String> audience = const [],
  }) async {
    try {
      final response = await _api.publishSchoolOnlineExam(
        payload: <String, Object?>{
          'exam_plan': examPlan,
          'questions': questionIds,
          'audience': audience,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
          error: PersonFailure(
            code: 'EMPTY_RESPONSE',
            message: 'The server returned no publish data.',
          ),
        );
      }
      return Ok(value: Map<String, Object?>.from(data.toJson()));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  bool _matchesSubject(JsonMap row, String? subject) {
    if (subject == null || subject.isEmpty) return true;
    final rowSubject =
        row['subject'] ?? row['subject_name'] ?? row['school_subject'];
    if (rowSubject is String) return rowSubject == subject;
    return false;
  }

  String? _nextCursorFromMeta(ApiMeta meta) {
    final raw = meta.values;
    for (final key in const ['next_cursor', 'nextCursor', 'cursor']) {
      final v = raw[key];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  TeacherExamQuestion _decodeQuestion(JsonMap m) {
    final id = (m['name'] ?? m['id'] ?? m['question'] ?? '') as String;
    final text = (m['question_text'] ?? m['text'] ?? '') as String;
    final type = (m['question_type'] ?? 'text') as String;
    final marks = (m['marks'] is num)
        ? (m['marks'] as num).toInt()
        : int.tryParse(m['marks']?.toString() ?? '') ?? 1;
    return TeacherExamQuestion(
      id: id,
      questionText: text,
      questionType: type,
      marks: marks,
    );
  }

  PersonFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const PersonFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return PersonFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  PersonFailure _exceptionFailure(Exception e) {
    return PersonFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
