import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import 'exam.dart';
import 'package:meta/meta.dart';

@immutable
class ExamPlanPage {
  const ExamPlanPage({required this.plans, this.nextCursor});
  final List<ExamPlan> plans;
  final String? nextCursor;
  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
}

@immutable
class EligibilityResult {
  const EligibilityResult({
    required this.eligible,
    required this.examPlanId,
  });
  final bool eligible;
  final String examPlanId;
}

@immutable
class StartAttemptResult {
  const StartAttemptResult({
    required this.attemptId,
    required this.status,
    required this.endsAt,
    required this.revision,
    required this.questions,
    required this.questionOrder,
  });
  final String attemptId;
  final String status;
  final String? endsAt;
  final int? revision;
  final List<ExamQuestion> questions;
  final List<String> questionOrder;
}

@immutable
class AttemptStatus {
  const AttemptStatus({
    required this.attemptId,
    required this.status,
  });
  final String attemptId;
  final String status;
}

@immutable
class AttemptResult {
  const AttemptResult({
    required this.attemptId,
    required this.state,
    required this.score,
    required this.maxScore,
  });
  final String attemptId;
  final String state;
  final double? score;
  final double? maxScore;
}

class AssessmentRepository {
  AssessmentRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  final Uuid _uuid;

  Future<Result<ExamPlanPage, PersonFailure>> listExamPlans({
    String? cursor,
    int? limit,
    String? subject,
    bool publishedOnly = true,
  }) async {
    try {
      final response = await _api.getSchoolExamPlans(
        cursor: cursor,
        limit: limit,
      );
      final data = response.data;
      if (response.error != null || data == null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data.plans ?? const <JsonMap>[];
      final plans = rows
          .where((row) => _matchesFilters(row, subject, publishedOnly))
          .map(ExamPlan.fromJson)
          .toList(growable: false);
      return Ok(value: ExamPlanPage(
        plans: plans,
        nextCursor: _nextCursorFromMeta(response.meta),
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<EligibilityResult, PersonFailure>> checkEligibility({
    required String examPlanId,
    required String studentId,
  }) async {
    try {
      final response = await _api.getSchoolOnlineExamEligibility(
        examPlan: examPlanId,
        schoolStudent: studentId,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(error: PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no eligibility data.',
        ));
      }
      return Ok(value: EligibilityResult(
        eligible: data.eligible ?? false,
        examPlanId: data.examPlan ?? examPlanId,
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Start a new attempt. The server returns the question set inline
  /// so the attempt screen does not need a follow-up fetch.
  Future<Result<StartAttemptResult, PersonFailure>> startAttempt({
    required String examPlanId,
    required String studentId,
  }) async {
    try {
      final response = await _api.startSchoolExamAttempt(
        payload: <String, Object?>{
          'exam_plan': examPlanId,
          'school_student': studentId,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(error: PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no attempt data.',
        ));
      }
      final questions = (data.questions ?? const <JsonMap>[])
          .map(ExamQuestion.fromJson)
          .toList(growable: false);
      return Ok(value: StartAttemptResult(
        attemptId: data.attempt ?? '',
        status: data.status ?? 'In Progress',
        endsAt: data.endsAt,
        revision: data.revision,
        questions: questions,
        questionOrder: data.questionOrder ?? const <String>[],
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<AttemptStatus, PersonFailure>> autosave({
    required String attemptId,
    required int revision,
    required Map<String, Object?> answers,
  }) async {
    try {
      final response = await _api.autosaveSchoolExamAttempt(
        payload: <String, Object?>{
          'attempt': attemptId,
          'revision': revision,
          'answers': answers,
        },
        idempotencyKey: _uuid.v4(),
      );
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      return Ok(value: AttemptStatus(
        attemptId: attemptId,
        status: 'In Progress',
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<AttemptStatus, PersonFailure>> submit({
    required String attemptId,
    required int revision,
    required Map<String, Object?> answers,
  }) async {
    try {
      final response = await _api.submitSchoolExamAttempt(
        payload: <String, Object?>{
          'attempt': attemptId,
          'revision': revision,
          'answers': answers,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(error: PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no submission data.',
        ));
      }
      return Ok(value: AttemptStatus(
        attemptId: data.attempt ?? attemptId,
        status: data.status ?? 'Submitted',
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<AttemptResult, PersonFailure>> getResult(String attemptId) async {
    try {
      final response = await _api.getSchoolExamAttemptResult(
        attempt: attemptId,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(error: PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no result data.',
        ));
      }
      return Ok(value: AttemptResult(
        attemptId: data.attempt ?? attemptId,
        state: data.state ?? 'Graded',
        score: data.score,
        maxScore: data.maxScore,
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  Future<Result<AttemptStatus, PersonFailure>> abandon(String attemptId) async {
    try {
      final response = await _api.abandonSchoolExamAttempt(
        attempt: attemptId,
        idempotencyKey: _uuid.v4(),
      );
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      return Ok(value: AttemptStatus(
        attemptId: attemptId,
        status: 'Abandoned',
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  bool _matchesFilters(JsonMap row, String? subject, bool publishedOnly) {
    if (subject != null && subject.isNotEmpty) {
      final rowSubject = row['subject'] ?? row['subject_name'];
      if (rowSubject is String && rowSubject != subject) return false;
      if (rowSubject is! String) return false;
    }
    if (publishedOnly) {
      final published = row['published'];
      final isPublished = published is bool
          ? published
          : published is String
              ? published.toLowerCase() == 'true'
              : false;
      if (!isPublished) return false;
    }
    return true;
  }

  String? _nextCursorFromMeta(ApiMeta meta) {
    final raw = meta.values;
    for (final key in const ['next_cursor', 'nextCursor', 'cursor']) {
      final v = raw[key];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
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
