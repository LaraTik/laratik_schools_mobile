import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../../core/result.dart';
import '../../guardians/data/guardian.dart';
import 'family_failure.dart';

/// A "family member" = a parent's linked child, viewed through the
/// guardian's `linked_students` link table. The mobile doesn't have
/// a dedicated "my child" DocType; the canonical list of children
/// for a parent is the union of `School Guardian.linked_students`
/// across every guardian record owned by the current user.
///
/// The v1 server is expected to filter `get_school_guardians` to
/// the current user when the session belongs to a parent role; the
/// mobile does not (and should not) issue a query for "guardians
/// linked to the current user" â€” that contract is the server's.
@immutable
class FamilyMember extends Equatable {
  const FamilyMember({
    required this.guardianId,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.relation,
    required this.grade,
    required this.status,
    required this.raw,
  });

  /// The guardian record this link belongs to. The parent may have
  /// multiple guardian records (mother + father) and the same child
  /// may show up twice â€” the family home de-duplicates by
  /// [studentId].
  final String guardianId;

  /// The School Student id (the Frappe primary key, e.g. STU-00001).
  final String studentId;

  /// Display name (preferring `student_name` from the link, falling
  /// back to the student's own `name`).
  final String studentName;

  /// The student's `student_code` (e.g. STU-00001 if it matches the
  /// id; some sites use different codes).
  final String? studentCode;

  /// The relation this guardian has to the child (e.g. "Mother",
  /// "Father", "Guardian"). May be null when the wire doesn't carry
  /// it. The mobile uses the first non-null value across all
  /// guardian records for a child.
  final String? relation;

  /// The grade the child is currently enrolled in (e.g. "Grade 3").
  /// Best-effort: derived from the `grade` field on the link or the
  /// student's record. The mobile does not block on this being
  /// present.
  final String? grade;

  /// The student's enrollment status, e.g. "Active", "Withdrawn".
  /// Used to fade out withdrawn students on the family home.
  final String status;

  final JsonMap raw;

  bool get isActive => status.toLowerCase() == 'active';

  @override
  List<Object?> get props => [
        guardianId,
        studentId,
        studentName,
        studentCode,
        relation,
        grade,
        status,
      ];
}

/// Paged list of family members. The v1 SDK doesn't expose a cursor
/// on `get_school_guardians`; the page is "everything we fetched".
class FamilyPage {
  const FamilyPage({required this.members, required this.guardians});

  /// De-duplicated by [FamilyMember.studentId]. The first
  /// non-withdrawn member wins (so a withdrawn child doesn't shadow
  /// an active duplicate).
  final List<FamilyMember> members;
  final List<FamilyMember> guardians;

  bool get hasMore => false;
}

/// A grade record row, narrowed from the v1 wire. Same shape for
/// student surface + parent child detail â€” re-skinned at the widget
/// level. The full row is preserved on [raw] for future schema
/// additions.
@immutable
class ChildGradeRecord extends Equatable {
  const ChildGradeRecord({
    required this.id,
    required this.student,
    required this.subject,
    required this.assessmentName,
    required this.score,
    required this.maxScore,
    required this.letterGrade,
    required this.passStatus,
    required this.publishedOn,
    required this.raw,
  });

  factory ChildGradeRecord.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      return v is String && v.isNotEmpty ? v : null;
    }

    double? pickDouble(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return ChildGradeRecord(
      id: pickString('name') ?? pickString('id') ?? '',
      student: pickString('school_student') ?? '',
      subject: pickString('subject_name') ?? pickString('subject') ?? '',
      assessmentName: pickString('assessment_name') ??
          pickString('exam_name') ??
          pickString('title') ??
          '',
      score: pickDouble('score') ?? 0,
      maxScore: pickDouble('max_score') ?? pickDouble('total_marks') ?? 0,
      letterGrade: pickString('letter_grade') ?? '',
      passStatus: pickString('pass_status') ?? '',
      publishedOn: pickString('published_on') ?? pickString('creation'),
      raw: json,
    );
  }

  final String id;
  final String student;
  final String subject;
  final String assessmentName;
  final double score;
  final double maxScore;
  final String letterGrade;
  final String passStatus;
  final String? publishedOn;
  final JsonMap raw;

  /// Score as a 0..100 percentage. The wire carries `score` and
  /// `max_score` separately; the percentage is computed here.
  double? get percentage {
    if (maxScore <= 0) return null;
    final p = (score / maxScore) * 100;
    return p.isFinite ? double.parse(p.toStringAsFixed(1)) : null;
  }

  bool get passed => passStatus.toLowerCase() == 'pass';

  @override
  List<Object?> get props => [
        id,
        student,
        subject,
        assessmentName,
        score,
        maxScore,
        letterGrade,
        passStatus,
        publishedOn,
      ];
}

/// A single attendance record row, narrowed from the v1 wire.
@immutable
class ChildAttendanceRecord extends Equatable {
  const ChildAttendanceRecord({
    required this.id,
    required this.student,
    required this.date,
    required this.status,
    required this.notes,
    required this.classGroup,
    required this.raw,
  });

  factory ChildAttendanceRecord.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      return v is String && v.isNotEmpty ? v : null;
    }

    return ChildAttendanceRecord(
      id: pickString('name') ?? pickString('id') ?? '',
      student: pickString('school_student') ?? '',
      date: pickString('date') ?? '',
      status: pickString('status') ?? 'Present',
      notes: pickString('notes'),
      classGroup: pickString('class_group') ?? pickString('section'),
      raw: json,
    );
  }

  final String id;
  final String student;
  final String date;
  final String status;
  final String? notes;
  final String? classGroup;
  final JsonMap raw;

  bool isPresent() => status.toLowerCase() == 'present';
  bool isAbsent() => status.toLowerCase() == 'absent';
  bool isLate() => status.toLowerCase() == 'late';
  bool isExcused() => status.toLowerCase() == 'excused';

  @override
  List<Object?> get props => [id, student, date, status, notes, classGroup];
}

/// A report card row, narrowed from the v1 wire. Report cards are
/// the consolidated term-summary the school publishes per student.
@immutable
class ChildReportCard extends Equatable {
  const ChildReportCard({
    required this.id,
    required this.student,
    required this.term,
    required this.academicYear,
    required this.publishedOn,
    required this.averageScore,
    required this.raw,
  });

  factory ChildReportCard.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      return v is String && v.isNotEmpty ? v : null;
    }

    double? pickDouble(String key) {
      final v = json[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return ChildReportCard(
      id: pickString('name') ?? pickString('id') ?? '',
      student: pickString('school_student') ?? '',
      term: pickString('academic_term') ?? pickString('term') ?? '',
      academicYear: pickString('academic_year') ?? '',
      publishedOn: pickString('published_on') ?? pickString('creation'),
      averageScore:
          pickDouble('average_score') ?? pickDouble('percentage_score'),
      raw: json,
    );
  }

  final String id;
  final String student;
  final String term;
  final String academicYear;
  final String? publishedOn;
  final double? averageScore;
  final JsonMap raw;

  @override
  List<Object?> get props => [
        id,
        student,
        term,
        academicYear,
        publishedOn,
        averageScore,
      ];
}

/// Paged list of records. The v1 SDK doesn't expose a cursor for
/// these endpoints today, so the page is "everything we fetched".
/// Client-side filtering by [studentId] narrows it down.
class ChildRecordsPage<T> {
  const ChildRecordsPage({required this.items});
  final List<T> items;
  bool get hasMore => false;
}

/// Paged + student-filtered view used by the parent / student
/// "my records" surface.
class StudentRecordsPage {
  const StudentRecordsPage({
    required this.grades,
    required this.attendance,
    required this.reportCards,
  });
  final ChildRecordsPage<ChildGradeRecord> grades;
  final ChildRecordsPage<ChildAttendanceRecord> attendance;
  final ChildRecordsPage<ChildReportCard> reportCards;
}

/// Family repository â€” parent / student "my records" data layer.
///
/// Wraps the four v1 endpoints the parent / student surfaces need
/// (`get_school_guardians`, `get_school_grade_records`,
/// `get_school_attendance_records`, `get_school_report_cards`) and
/// does the per-student filtering client-side because the v1 SDK
/// doesn't accept a `school_student` query parameter on those
/// endpoints (see the TODO at the top of the file).
class FamilyRepository {
  FamilyRepository({required LaratikSchoolsApiClient api, Uuid? uuid})
      : _api = api,
        _uuid = uuid ?? const Uuid();

  final LaratikSchoolsApiClient _api;
  // Kept for parity with the other repositories; not currently
  // used because the family APIs are all read-only.
  // ignore: unused_field
  final Uuid _uuid;

  /// Load the current user's guardian records and turn the link
  /// rows into de-duplicated [FamilyMember]s. The v1 server is
  /// expected to filter to the current user when the session is a
  /// parent; the mobile does not (and should not) issue a query for
  /// "guardians linked to the current user" â€” that contract is the
  /// server's.
  Future<Result<FamilyPage, FamilyFailure>> listFamily({
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolGuardians(limit: limit ?? 50);
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      if (data == null) {
        return const Err(
            error: FamilyFailure(
          code: 'EMPTY_RESPONSE',
          message: 'The server returned no guardian data.',
        ));
      }
      final guardians = (data.guardians ?? const <JsonMap>[])
          .map(Guardian.fromJson)
          .toList(growable: false);

      // Flatten link rows, then de-duplicate by student id. The
      // first non-withdrawn member wins so a withdrawn child
      // doesn't shadow an active duplicate.
      final all = <FamilyMember>[];
      for (final g in guardians) {
        for (final link in g.linkedStudents) {
          all.add(_familyMemberFromLink(guardian: g, link: link));
        }
      }
      final deduped = <String, FamilyMember>{};
      for (final m in all) {
        if (m.studentId.isEmpty) continue;
        final existing = deduped[m.studentId];
        if (existing == null) {
          deduped[m.studentId] = m;
        } else if (!existing.isActive && m.isActive) {
          deduped[m.studentId] = m;
        }
      }
      return Ok(
          value: FamilyPage(
        members: deduped.values.toList(growable: false),
        guardians: all,
      ));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Fetch + client-side filter the grade records for a single
  /// student. The v1 SDK doesn't accept a `school_student` filter
  /// on the wire (it takes only `cursor`, `limit`, `since_date`).
  Future<Result<ChildRecordsPage<ChildGradeRecord>, FamilyFailure>>
      listGradesForStudent(String studentId, {int? limit}) async {
    try {
      final response = await _api.getSchoolGradeRecords(
        limit: limit ?? 200,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data?.records ?? const <JsonMap>[];
      final all = rows.map(ChildGradeRecord.fromJson).toList(growable: false);
      final filtered = all
          .where((r) =>
              studentId.isEmpty ||
              r.student == studentId ||
              r.student.contains(studentId))
          .toList(growable: false);
      return Ok(value: ChildRecordsPage(items: filtered));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Fetch + client-side filter the attendance records for a
  /// single student. See [listGradesForStudent] for the why.
  Future<Result<ChildRecordsPage<ChildAttendanceRecord>, FamilyFailure>>
      listAttendanceForStudent(
    String studentId, {
    int? limit,
  }) async {
    try {
      final response = await _api.getSchoolAttendanceRecords(
        limit: limit ?? 200,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data?.records ?? const <JsonMap>[];
      final all =
          rows.map(ChildAttendanceRecord.fromJson).toList(growable: false);
      final filtered = all
          .where((r) =>
              studentId.isEmpty ||
              r.student == studentId ||
              r.student.contains(studentId))
          .toList(growable: false);
      return Ok(value: ChildRecordsPage(items: filtered));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Fetch + client-side filter the report cards for a single
  /// student. See [listGradesForStudent] for the why.
  Future<Result<ChildRecordsPage<ChildReportCard>, FamilyFailure>>
      listReportCardsForStudent(String studentId, {int? limit}) async {
    try {
      final response = await _api.getSchoolReportCards(
        limit: limit ?? 100,
      );
      final data = response.data;
      if (response.error != null) {
        return Err(error: _failureFromApi(response.error));
      }
      final rows = data?.reportCards ?? const <JsonMap>[];
      final all = rows.map(ChildReportCard.fromJson).toList(growable: false);
      final filtered = all
          .where((r) =>
              studentId.isEmpty ||
              r.student == studentId ||
              r.student.contains(studentId))
          .toList(growable: false);
      return Ok(value: ChildRecordsPage(items: filtered));
    } on Exception catch (e) {
      return Err(error: _exceptionFailure(e));
    }
  }

  /// Convenience: one shot to populate the child detail screen.
  /// Returns the first failure it sees and stops fetching the rest
  /// of the bundle so the surface can render a single error instead
  /// of partial data.
  Future<Result<StudentRecordsPage, FamilyFailure>> listAllRecordsForStudent(
      String studentId,
      {int? limit}) async {
    final gradesResult = await listGradesForStudent(studentId, limit: limit);
    if (gradesResult
        is Err<ChildRecordsPage<ChildGradeRecord>, FamilyFailure>) {
      return Err<StudentRecordsPage, FamilyFailure>(
        error: gradesResult.error,
      );
    }
    final attendanceResult =
        await listAttendanceForStudent(studentId, limit: limit);
    if (attendanceResult
        is Err<ChildRecordsPage<ChildAttendanceRecord>, FamilyFailure>) {
      return Err<StudentRecordsPage, FamilyFailure>(
        error: attendanceResult.error,
      );
    }
    final reportCardsResult =
        await listReportCardsForStudent(studentId, limit: limit);
    if (reportCardsResult
        is Err<ChildRecordsPage<ChildReportCard>, FamilyFailure>) {
      return Err<StudentRecordsPage, FamilyFailure>(
        error: reportCardsResult.error,
      );
    }
    final grades =
        (gradesResult as Ok<ChildRecordsPage<ChildGradeRecord>, FamilyFailure>)
            .value;
    final attendance = (attendanceResult
            as Ok<ChildRecordsPage<ChildAttendanceRecord>, FamilyFailure>)
        .value;
    final reportCards = (reportCardsResult
            as Ok<ChildRecordsPage<ChildReportCard>, FamilyFailure>)
        .value;
    return Ok(
      value: StudentRecordsPage(
        grades: grades,
        attendance: attendance,
        reportCards: reportCards,
      ),
    );
  }

  FamilyMember _familyMemberFromLink({
    required Guardian guardian,
    required JsonMap link,
  }) {
    String? pick(String key) {
      final v = link[key];
      return v is String && v.isNotEmpty ? v : null;
    }

    final studentId = pick('school_student') ?? pick('student') ?? '';
    final studentName = pick('student_name') ??
        pick('student_full_name') ??
        pick('name') ??
        studentId;
    final relation = pick('relation') ?? guardian.relation;
    return FamilyMember(
      guardianId: guardian.id,
      studentId: studentId,
      studentName: studentName,
      studentCode: pick('student_code') ?? pick('student_id'),
      relation: relation,
      grade: pick('grade') ?? pick('class_group'),
      status: pick('status') ?? 'Active',
      raw: link,
    );
  }

  FamilyFailure _failureFromApi(ApiError? error) {
    if (error == null) {
      return const FamilyFailure(
        code: 'EMPTY_RESPONSE',
        message: 'The server returned no data.',
      );
    }
    return FamilyFailure(
      code: error.code,
      message: error.message,
      fieldErrors: error.fieldErrors,
    );
  }

  FamilyFailure _exceptionFailure(Exception e) {
    return FamilyFailure(
      code: 'EXCEPTION',
      message: e.toString(),
    );
  }
}
