import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import 'exam.dart';

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
    required this.reason,
    required this.examPlanId,
    required this.studentId,
  });
  final bool eligible;
  final String reason;
  final String examPlanId;
  final String studentId;
}

@immutable
class AttemptResult {
  const AttemptResult({
    required this.attemptId,
    required this.status,
    required this.score,
    required this.totalMarks,
  });
  final String attemptId;
  final String status;
  final double? score;
  final int? totalMarks;
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
        return Err(_failureFromApi(response.error, data));
      }
      final rows = data.plans ?? const <JsonMap>[];
      final plans = rows
          .where((row) =>
              _matchesFilters(row, subject, publishedOnly))
          .map(ExamPlan.fromJson)
          .toList(growable: false);
      return Ok(ExamPlanPage(
        plans: plans,
        nextCursor: _nextCursorFromMeta(response.meta),
      ));
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
    }
  }

  Future<Result<EligibilityResult, PersonFailure>> checkEligibility({
    required String examPlanId,
    required String studentId,
  }) async {
    try {
      final response = await _api.getSchoolOnlineExamEligibility(
        payload: <String, Object?>{
          'exam_plan': examPlanId,
          'school_student': studentId,
        },
      );
      final data = response.data;
      if (response.error != null) {
        return Err(_failureFromApi(response.error, data));
      }
      if (data == null) {
        return const Err(PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no eligibility data.',
        ));
      }
      return Ok(EligibilityResult(
        eligible: data.eligible == 'true' || data.eligible == '1',
        reason: data.reason ?? '',
        examPlanId: examPlanId,
        studentId: studentId,
      ));
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
    }
  }

  Future<Result<AttemptResult, PersonFailure>> startAttempt({
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
        return Err(_failureFromApi(response.error, data));
      }
      if (data == null) {
        return const Err(PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no attempt data.',
        ));
      }
      return Ok(AttemptResult(
        attemptId: data.attempt ?? '',
        status: data.status ?? 'In Progress',
        score: null,
        totalMarks: null,
      ));
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
    }
  }

  Future<Result<bool, PersonFailure>> autosave({
    required String attemptId,
    required Map<String, Object?> answers,
  }) async {
    try {
      final response = await _api.autosaveSchoolExamAttempt(
        payload: <String, Object?>{
          'attempt': attemptId,
          'answers': answers,
        },
        idempotencyKey: _uuid.v4(),
      );
      if (response.error != null) {
        return Err(_failureFromApi(response.error, response.data));
      }
      return const Ok(true);
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
    }
  }

  Future<Result<AttemptResult, PersonFailure>> submit({
    required String attemptId,
    required Map<String, Object?> answers,
  }) async {
    try {
      final response = await _api.submitSchoolExamAttempt(
        payload: <String, Object?>{
          'attempt': attemptId,
          'answers': answers,
        },
        idempotencyKey: _uuid.v4(),
      );
      final data = response.data;
      if (response.error != null) {
        return Err(_failureFromApi(response.error, data));
      }
      if (data == null) {
        return const Err(PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no submission data.',
        ));
      }
      return Ok(AttemptResult(
        attemptId: data.attempt ?? attemptId,
        status: data.status ?? 'Submitted',
        score: null,
        totalMarks: null,
      ));
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
    }
  }

  Future<Result<AttemptResult, PersonFailure>> getResult(String attemptId) async {
    try {
      final response = await _api.getSchoolExamAttemptResult(
        attempt: attemptId,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(_failureFromApi(response.error, data));
      }
      if (data == null) {
        return const Err(PersonFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no result data.',
        ));
      }
      return Ok(AttemptResult(
        attemptId: data.attempt ?? attemptId,
        status: data.status ?? 'Graded',
        score: _toDouble(data.score),
        totalMarks: data.totalMarks,
      ));
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
    }
  }

  Future<Result<bool, PersonFailure>> abandon(String attemptId) async {
    try {
      final response = await _api.abandonSchoolExamAttempt(
        attempt: attemptId,
      );
      if (response.error != null) {
        return Err(_failureFromApi(response.error, response.data));
      }
      return const Ok(true);
    } on Exception catch (e) {
      return Err(_exceptionFailure(e));
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

  double? _toDouble(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  PersonFailure _failureFromApi(ApiError? error, JsonMap? data) {
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
