import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:meta/meta.dart';

/// Attendance status. The wire shape is a free string; the well-known
/// values are mapped to a [AttendanceTone] for the UI. Unknown values
/// fall back to neutral.
enum AttendanceTone { present, absent, late, excused, neutral }

class AttendanceStatus {
  const AttendanceStatus._(this.value, this.tone);
  final String value;
  final AttendanceTone tone;

  static const present = AttendanceStatus._('Present', AttendanceTone.present);
  static const absent = AttendanceStatus._('Absent', AttendanceTone.absent);
  static const late = AttendanceStatus._('Late', AttendanceTone.late);
  static const excused = AttendanceStatus._('Excused', AttendanceTone.excused);
  static const neutral = AttendanceStatus._('—', AttendanceTone.neutral);

  static AttendanceStatus fromWire(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'present':
        return present;
      case 'absent':
        return absent;
      case 'late':
        return late;
      case 'excused':
        return excused;
      default:
        return AttendanceStatus._(raw ?? '—', AttendanceTone.neutral);
    }
  }
}

/// A single attendance record.
@immutable
class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.attendanceDate,
    required this.status,
    required this.period,
    required this.classGroup,
    required this.notes,
    required this.recordedAt,
    required this.recordedBy,
    required this.raw,
  });

  factory AttendanceRecord.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    return AttendanceRecord(
      id: pickString('name') ?? pickString('id') ?? '',
      studentId: pickString('school_student') ??
          pickString('student') ??
          '',
      studentName: pickString('student_name') ?? '',
      attendanceDate: pickString('attendance_date') ?? pickString('date'),
      status: AttendanceStatus.fromWire(pickString('attendance_status')),
      period: pickString('period') ?? pickString('session'),
      classGroup: pickString('class_group'),
      notes: pickString('notes'),
      recordedAt: pickString('recorded_at') ?? pickString('creation'),
      recordedBy: pickString('recorded_by') ?? pickString('owner'),
      raw: json,
    );
  }

  final String id;
  final String studentId;
  final String studentName;
  final String? attendanceDate;
  final AttendanceStatus status;
  final String? period;
  final String? classGroup;
  final String? notes;
  final String? recordedAt;
  final String? recordedBy;
  final JsonMap raw;

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        attendanceDate,
        status.value,
        period,
        classGroup,
        notes,
        recordedAt,
        recordedBy,
      ];
}

/// Aggregate row used by the operator capture screen: a student plus the
/// [AttendanceStatus] the operator picked for today.
@immutable
class AttendanceMark {
  const AttendanceMark({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.guardianName,
  });

  final String studentId;
  final String studentName;
  final AttendanceStatus status;
  final String? guardianName;

  AttendanceMark copyWith({AttendanceStatus? status}) {
    return AttendanceMark(
      studentId: studentId,
      studentName: studentName,
      status: status ?? this.status,
      guardianName: guardianName,
    );
  }
}
