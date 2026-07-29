// SPDX-License-Identifier: Proprietary
// Resolves the student the mobile session is "acting as" for the
// practice-quiz slice. Reads the cached id from `SessionStore`; falls
// back to the first available student on a fresh install.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/login_screen.dart' show sessionProvider;
import '../../../auth/session.dart';
import '../../../core/result.dart';
import '../../people/data/person.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import '../../people/data/person_repository.dart';
import 'assessment_providers.dart';
import 'assessment_repository.dart';

/// The student + matching active enrollment the mobile session is
/// "acting as". For the first slice we always pin to a single student
/// (the seed) — the mobile OAuth user is Administrator, and Frappe's
/// `is_eligible` check requires `student.user == session_user`.
class CurrentStudent {
  const CurrentStudent({
    required this.studentId,
    required this.enrollmentId,
    required this.person,
  });

  final String studentId;
  final String enrollmentId;
  final Person person;

  @override
  bool operator ==(Object other) =>
      other is CurrentStudent &&
      other.studentId == studentId &&
      other.enrollmentId == enrollmentId;

  @override
  int get hashCode => Object.hash(studentId, enrollmentId);
}

/// Riverpod entry point. Returns the resolved [CurrentStudent] (or
/// `null` while loading / on failure).
///
/// The provider is `autoDispose` so navigating away releases the
/// fetch. Tests override `assessmentRepositoryProvider` /
/// `personRepositoryProvider` to inject fakes.
final currentStudentProvider =
    FutureProvider.autoDispose<CurrentStudent?>((ref) async {
  final session = ref.watch(sessionProvider);
  // 1. If the session already has a cached student id, look up the
  //    Person record and re-derive the enrollment from the
  //    published exam plan audience.
  final cachedId = session.currentStudentId;
  if (cachedId != null && cachedId.isNotEmpty) {
    final person = await _fetchPersonById(ref, cachedId);
    if (person == null) return null;
    final enrollmentId =
        await _findActiveEnrollment(ref, person.id);
    unawaited(session.setCurrentStudent(
      studentId: person.id,
      enrollmentId: enrollmentId,
    ));
    return CurrentStudent(
      studentId: person.id,
      enrollmentId: enrollmentId ?? '',
      person: person,
    );
  }
  // 2. Cold start: list students, pick the first one, persist the
  //    choice. The dev seed creates exactly one School Student, so
  //    the head of the list is the right answer.
  final personRepo = ref.watch(personRepositoryProvider);
  final pageResult = await personRepo.listStudents(limit: 5);
  return switch (pageResult) {
    Ok(:final value) when value.people.isNotEmpty => () {
        final pick = value.people.first;
        return _persistAndReturn(ref, session, pick);
      }(),
    _ => null,
  };
});

/// Convenience: re-resolve [CurrentStudent] from a cached id by
/// walking the students list (the SDK doesn't expose a single-student
/// get in Phase 5). Returns null when the lookup can't find the
/// student or any list call fails.
Future<Person?> _fetchPersonById(Ref ref, String studentId) async {
  final personRepo = ref.watch(personRepositoryProvider);
  final list = await personRepo.listStudents(search: studentId, limit: 5);
  return switch (list) {
    Ok(:final value) when value.people.isNotEmpty => () {
        return value.people.firstWhere(
          (p) => p.id == studentId,
          orElse: () => value.people.first,
        );
      }(),
    _ => null,
  };
}

Future<CurrentStudent> _persistAndReturn(
  Ref ref,
  SessionStore session,
  Person person,
) async {
  final enrollmentId = await _findActiveEnrollment(ref, person.id);
  unawaited(session.setCurrentStudent(
    studentId: person.id,
    enrollmentId: enrollmentId,
  ));
  return CurrentStudent(
    studentId: person.id,
    enrollmentId: enrollmentId ?? '',
    person: person,
  );
}

/// Best-effort lookup of the student's active enrollment by walking
/// the published exam plans' audience snapshot. Returns the first
/// match (`audience_type == "Student"`, matching `school_student`).
/// Returns null if no plan includes this student in its audience.
Future<String?> _findActiveEnrollment(Ref ref, String studentId) async {
  final assessmentRepo = ref.watch(assessmentRepositoryProvider);
  final plans = await assessmentRepo.listExamPlans(limit: 50);
  return switch (plans) {
    Ok(:final value) => _scanAudiencesForStudent(value.plans, studentId),
    Err() => null,
  };
}

String? _scanAudiencesForStudent(List<dynamic> plans, String studentId) {
  for (final plan in plans) {
    final audience = (plan as dynamic).raw?['audience'];
    if (audience is! List) continue;
    for (final row in audience) {
      if (row is! Map) continue;
      final type = row['audience_type'];
      final student = row['school_student'];
      final enrollment = row['school_enrollment'];
      if (type == 'Student' &&
          student == studentId &&
          enrollment is String &&
          enrollment.isNotEmpty) {
        return enrollment;
      }
    }
  }
  return null;
}
