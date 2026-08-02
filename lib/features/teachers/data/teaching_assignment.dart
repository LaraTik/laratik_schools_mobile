// SPDX-License-Identifier: Proprietary
// A row from the `get_school_teaching_assignments` list.
//
// The School Teaching Assignment DocType ties a staff member to
// one or more (class group, subject) pairs. The mobile uses this
// to power the "My classes" surface for the teacher role: a list
// of the classes the teacher is currently assigned to, each
// tappable into the class detail (student roster + class info).
//
// The v1 contract returns each row as a forward-compatible
// [JsonMap]; the fields the mobile knows about are surfaced here
// as named accessors while the full map is preserved on [raw] so
// future schema additions flow through without an app update.

import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

@immutable
class TeachingAssignment extends Equatable {
  const TeachingAssignment({
    required this.id,
    required this.staff,
    required this.staffName,
    required this.classGroup,
    required this.classGroupName,
    required this.subject,
    required this.subjectName,
    required this.academicYear,
    required this.status,
    required this.isPrimary,
    required this.raw,
  });

  factory TeachingAssignment.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    bool pickBool(String key) {
      final v = json[key];
      if (v is bool) return v;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      // Some sites surface the "primary" flag as a 0/1 int.
      if (v is num) return v != 0;
      return false;
    }

    return TeachingAssignment(
      id: pickString('name') ?? pickString('id') ?? '',
      // `school_staff` is the Frappe link field on the assignment
      // child table; some sites use `staff` instead.
      staff: pickString('school_staff') ?? pickString('staff') ?? '',
      staffName:
          pickString('staff_name') ?? pickString('school_staff_name') ?? '',
      classGroup:
          pickString('school_class_group') ?? pickString('class_group') ?? '',
      classGroupName: pickString('class_group_name') ??
          pickString('school_class_group_name') ??
          '',
      subject: pickString('subject') ?? '',
      subjectName:
          pickString('subject_name') ?? pickString('school_subject_name') ?? '',
      academicYear: pickString('academic_year') ??
          pickString('school_academic_year') ??
          '',
      status: pickString('status') ?? 'Active',
      isPrimary: pickBool('is_primary') || pickBool('primary'),
      raw: json,
    );
  }

  /// The teaching assignment's Frappe primary key.
  final String id;

  /// The staff member the assignment is for (the teacher).
  final String staff;

  /// Display name for the staff member. The wire shape usually
  /// carries this directly; we fall back to a derived name
  /// computed in the screen layer.
  final String staffName;

  /// The class group the assignment is for (e.g. `EDU-CG-2026-00001`).
  final String classGroup;

  /// Display name for the class group (e.g. "Grade 3-A").
  final String classGroupName;

  /// The subject the teacher is assigned to teach in this class
  /// (e.g. `EDU-SUB-2026-00007`).
  final String subject;

  /// Display name for the subject (e.g. "Mathematics").
  final String subjectName;

  /// The academic year the assignment is for (e.g. "2025/2026").
  /// May be empty if the school does not scope assignments to a
  /// year — the screen layer falls back to the active year.
  final String academicYear;

  /// The assignment status. `Active` is the only value the mobile
  /// treats as "in service" today; `Inactive` / `Completed` rows
  /// are still rendered for reference, faded.
  final String status;

  /// `true` when this is the teacher's primary assignment for the
  /// class group (i.e. their homeroom class). Used to surface a
  /// "Homeroom" chip in the list.
  final bool isPrimary;

  final JsonMap raw;

  /// Stable human label for the row, used in the list subtitle and
  /// the search match. Falls back to the class group id when no
  /// name is on the wire.
  String get classLabel =>
      classGroupName.isNotEmpty ? classGroupName : classGroup;

  /// Stable human label for the subject. Same fallback rule.
  String get subjectLabel => subjectName.isNotEmpty ? subjectName : subject;

  bool get isActive => status.toLowerCase() == 'active';

  @override
  List<Object?> get props => [
        id,
        staff,
        staffName,
        classGroup,
        classGroupName,
        subject,
        subjectName,
        academicYear,
        status,
        isPrimary,
      ];
}

/// Paged list of teaching assignments. The v1 SDK does not expose
/// a cursor on `get_school_teaching_assignments` today, so the
/// page is "everything we fetched".
class TeachingAssignmentPage {
  const TeachingAssignmentPage({required this.assignments});

  final List<TeachingAssignment> assignments;
  bool get hasMore => false;
}
