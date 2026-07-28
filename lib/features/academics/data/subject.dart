import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

@immutable
class Subject extends Equatable {
  const Subject({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.department,
    required this.gradeLevel,
    required this.creditHours,
    required this.description,
    required this.status,
    required this.raw,
  });

  factory Subject.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    int? pickInt(String key) {
      final v = json[key];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      if (v is num) return v.toInt();
      return null;
    }

    return Subject(
      id: pickString('name') ?? pickString('id') ?? '',
      subjectName: pickString('subject_name') ?? '',
      subjectCode: pickString('subject_code') ?? pickString('code'),
      department: pickString('department'),
      gradeLevel: pickString('grade_level') ?? pickString('grade'),
      creditHours: pickInt('credit_hours'),
      description: pickString('description'),
      status: pickString('status') ?? 'Active',
      raw: json,
    );
  }

  final String id;
  final String subjectName;
  final String? subjectCode;
  final String? department;
  final String? gradeLevel;
  final int? creditHours;
  final String? description;
  final String status;
  final JsonMap raw;

  bool get isActive => status.toLowerCase() == 'active';

  @override
  List<Object?> get props => [
        id,
        subjectName,
        subjectCode,
        department,
        gradeLevel,
        creditHours,
        description,
        status,
      ];
}

@immutable
class TimetableSlot extends Equatable {
  const TimetableSlot({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.course,
    required this.instructor,
    required this.classGroup,
    required this.branch,
    required this.academicYear,
    required this.room,
    required this.status,
    required this.raw,
  });

  factory TimetableSlot.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    return TimetableSlot(
      id: pickString('name') ?? pickString('id') ?? '',
      dayOfWeek: pickString('day_of_week') ?? pickString('day'),
      startTime: pickString('start_time'),
      endTime: pickString('end_time'),
      subject: pickString('subject') ?? pickString('subject_name'),
      course: pickString('course') ?? pickString('course_name'),
      instructor: pickString('instructor') ?? pickString('staff_name'),
      classGroup: pickString('class_group'),
      branch: pickString('branch'),
      academicYear: pickString('academic_year'),
      room: pickString('room') ?? pickString('location'),
      status: pickString('status') ?? 'Active',
      raw: json,
    );
  }

  final String id;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? subject;
  final String? course;
  final String? instructor;
  final String? classGroup;
  final String? branch;
  final String? academicYear;
  final String? room;
  final String status;
  final JsonMap raw;

  /// True when all five primary fields are present; used by the schedule
  /// grid to decide whether to render the slot at all.
  bool get isRenderable =>
      (dayOfWeek ?? '').isNotEmpty &&
      (startTime ?? '').isNotEmpty &&
      (endTime ?? '').isNotEmpty;

  String get subtitle {
    final parts = <String>[];
    if (classGroup != null && classGroup!.isNotEmpty) parts.add(classGroup!);
    if (instructor != null && instructor!.isNotEmpty) parts.add(instructor!);
    if (room != null && room!.isNotEmpty) parts.add(room!);
    return parts.join(' · ');
  }

  @override
  List<Object?> get props => [
        id,
        dayOfWeek,
        startTime,
        endTime,
        subject,
        course,
        instructor,
        classGroup,
        branch,
        academicYear,
        room,
        status,
      ];
}

@immutable
class Branch extends Equatable {
  const Branch({
    required this.id,
    required this.branchName,
    required this.code,
    required this.city,
    required this.country,
    required this.status,
    required this.isPrimary,
    required this.raw,
  });

  factory Branch.fromJson(JsonMap json) {
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
      return false;
    }

    return Branch(
      id: pickString('name') ?? pickString('id') ?? '',
      branchName: pickString('branch_name') ?? '',
      code: pickString('code'),
      city: pickString('city'),
      country: pickString('country'),
      status: pickString('status') ?? 'Active',
      isPrimary: pickBool('is_primary'),
      raw: json,
    );
  }

  final String id;
  final String branchName;
  final String? code;
  final String? city;
  final String? country;
  final String status;
  final bool isPrimary;
  final JsonMap raw;

  @override
  List<Object?> get props => [
        id,
        branchName,
        code,
        city,
        country,
        status,
        isPrimary,
      ];
}
