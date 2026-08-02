// SPDX-License-Identifier: Proprietary
// Tests for the Attendance repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/attendance/data/attendance_record.dart';
import 'package:laratik_schools_mobile/features/attendance/data/attendance_repository.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';
import 'package:laratik_schools_mobile/features/people/data/person_repository.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  AttendanceRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      AttendanceRepository(
        api: LaratikSchoolsApiClient(transport),
        personRepository:
            PersonRepository(api: LaratikSchoolsApiClient(transport)),
      );

  group('AttendanceStatus.fromWire', () {
    test('maps the four well-known tones and falls back to neutral', () {
      expect(AttendanceStatus.fromWire('Present').tone, AttendanceTone.present);
      expect(AttendanceStatus.fromWire('absent').tone, AttendanceTone.absent);
      expect(AttendanceStatus.fromWire('LATE').tone, AttendanceTone.late);
      expect(AttendanceStatus.fromWire('Excused').tone, AttendanceTone.excused);
      expect(AttendanceStatus.fromWire(null).tone, AttendanceTone.neutral);
      expect(AttendanceStatus.fromWire('Pending').tone, AttendanceTone.neutral);
    });
  });

  group('AttendanceRepository.listRecords', () {
    test('parses rows and maps attendance_status into AttendanceStatus',
        () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolAttendanceRecords,
        envelopeOk({
          'records': [
            {
              'name': 'EDU-ATT-2026-00001',
              'school_student': 'EDU-STU-2026-00001',
              'student_name': 'Layla Hassan',
              'attendance_date': '2026-07-28',
              'attendance_status': 'Present',
              'class_group': 'A',
            },
            {
              'name': 'EDU-ATT-2026-00002',
              'school_student': 'EDU-STU-2026-00002',
              'student_name': 'Ahmad Saleh',
              'attendance_date': '2026-07-28',
              'attendance_status': 'Absent',
              'class_group': 'A',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listRecords();
      final page = (result as Ok<AttendancePage, PersonFailure>).value;
      expect(page.records, hasLength(2));
      expect(page.records.first.status.tone, AttendanceTone.present);
      expect(page.records.last.status.tone, AttendanceTone.absent);
    });
  });

  group('AttendanceRepository.loadRoster', () {
    test('wraps students in AttendanceMark with default Present', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({
          'students': [
            {
              'name': 'EDU-STU-2026-00001',
              'first_name': 'Layla',
              'last_name': 'Hassan',
              'class_group': 'A',
            },
            {
              'name': 'EDU-STU-2026-00002',
              'first_name': 'Ahmad',
              'last_name': 'Saleh',
              'class_group': 'A',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.loadRoster(classGroupId: 'A');
      expect(result, isA<Ok<List<AttendanceMark>, PersonFailure>>());
      final roster = (result as Ok<List<AttendanceMark>, PersonFailure>).value;
      expect(roster, hasLength(2));
      expect(roster.first.studentName, 'Layla Hassan');
      expect(roster.first.status.tone, AttendanceTone.present);
    });
  });

  group('AttendanceRepository.submitMark', () {
    test('returns the new attendance record id', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.createSchoolAttendanceRecord,
        envelopeOk({
          'attendance_record': 'EDU-ATT-2026-00010',
          'attendance_status': 'Present',
          'school_student': 'EDU-STU-2026-00001',
          'student_name': 'Layla Hassan',
          'status': 'Submitted',
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.submitMark(
        mark: const AttendanceMark(
          studentId: 'EDU-STU-2026-00001',
          studentName: 'Layla Hassan',
          status: AttendanceStatus.present,
        ),
        attendanceDate: '2026-07-28',
        classGroup: 'A',
      );
      expect(result, isA<Ok<AttendanceMarkResult, PersonFailure>>());
      final created = (result as Ok<AttendanceMarkResult, PersonFailure>).value;
      expect(created.attendanceRecord, 'EDU-ATT-2026-00010');
      expect(created.attendanceStatus, 'Present');
    });
  });
}
