// SPDX-License-Identifier: Proprietary
// Teachers repository — wraps the v1 endpoints the teacher
// surface needs.
//
// Today (read-only "My classes" + class detail + student roster):
//   * `get_school_teaching_assignments` → list of assignments for
//     the current staff member (the server is expected to filter
//     to the active staff when the session is a teacher role).
//   * `get_school_students` (already in PersonRepository) — used
//     to populate the per-class roster filtered by `classGroupId`.
//
// Future (deferred to a follow-up turn per
// docs/PROD_READINESS_AUDIT.md #6):
//   * `create_school_teaching_assignment` — admin-only surface
//     for assigning a teacher to a (class, subject) pair.
//   * `update_school_teaching_assignment` — edit an existing
//     assignment.
//   * `deactivate_school_teaching_assignment` — end an
//     assignment.
//   * `grade_school_exam_attempt` — manual grading of
//     short-answer / essay questions.

import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import 'teachers_failure.dart';
import 'teaching_assignment.dart';

class TeachersRepository {
  TeachersRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        // Kept for parity with the other repositories; not
        // currently used because the teacher read-only APIs do
        // not take an idempotency key.
        // ignore: unused_field
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  // ignore: unused_field
  final Uuid _uuid;

  /// List the current staff member's teaching assignments. The
  /// v1 server is expected to filter to the current user when
  /// the session is a teacher role; the mobile does not (and
  /// should not) issue a query for "teaching assignments linked
  /// to the current user" — that contract is the server's.
  Future<Result<TeachingAssignmentPage, TeachersFailure>> listMyClasses({
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolTeachingAssignments(
        limit: limit ?? 50,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
            error: TeachersFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no teaching assignment data.',
        ));
      }
      final rows = data.teachingAssignments ?? const <JsonMap>[];
      final assignments =
          rows.map(TeachingAssignment.fromJson).toList(growable: false);
      return Ok(value: TeachingAssignmentPage(assignments: assignments));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  TeachersFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const TeachersFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return TeachersFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  TeachersFailure _exceptionFailure(Exception e) {
    return TeachersFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
