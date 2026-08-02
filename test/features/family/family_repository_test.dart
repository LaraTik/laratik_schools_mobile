// SPDX-License-Identifier: Proprietary
// Tests for the Family repository (parent "my children" + child
// records).
//
// The tests cover:
//   * [listFamily] de-duplicates links by student id and prefers
//     active rows over withdrawn ones.
//   * [listFamily] surfaces an EMPTY_RESPONSE failure when the wire
//     returns no data block.
//   * [listGradesForStudent] / [listAttendanceForStudent] /
//     [listReportCardsForStudent] filter the wire rows client-side
//     by the requested student id (the v1 SDK doesn't accept a
//     `school_student` query parameter on those endpoints).
//   * [listAllRecordsForStudent] surfaces the first failure it
//     sees and stops fetching the rest of the bundle.
//   * The data models parse the v1 envelope forward-compatibly
//     (legacy + canonical wire keys, defensive doubles / strings).

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/family/data/family_failure.dart';
import 'package:laratik_schools_mobile/features/family/data/family_repository.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  FamilyRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      FamilyRepository(api: LaratikSchoolsApiClient(transport));

  group('FamilyRepository.listFamily', () {
    test('flattens guardian link rows into de-duplicated members', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGuardians,
        envelopeOk({
          'guardians': [
            {
              'name': 'EDU-GRD-2026-00001',
              'guardian_name': 'Aisha Hassan',
              'relation': 'Mother',
              'students': [
                {
                  'school_student': 'EDU-STU-2026-00001',
                  'student_name': 'Yusuf Hassan',
                  'student_code': 'STU-00001',
                  'grade': 'Grade 3',
                },
              ],
            },
            {
              'name': 'EDU-GRD-2026-00002',
              'guardian_name': 'Omar Hassan',
              'relation': 'Father',
              'students': [
                {
                  // Same child — should de-duplicate.
                  'school_student': 'EDU-STU-2026-00001',
                  'student_name': 'Yusuf Hassan',
                  'student_code': 'STU-00001',
                },
                {
                  'school_student': 'EDU-STU-2026-00002',
                  'student_name': 'Lina Hassan',
                  'grade': 'Grade 1',
                },
              ],
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listFamily();
      final page = (result as Ok<FamilyPage, FamilyFailure>).value;
      expect(page.members, hasLength(2));
      final ids = page.members.map((m) => m.studentId).toList();
      expect(ids, containsAll(['EDU-STU-2026-00001', 'EDU-STU-2026-00002']));
      expect(page.members.first.isActive, isTrue);
    });

    test('prefers active link over withdrawn duplicate', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGuardians,
        envelopeOk({
          'guardians': [
            {
              'name': 'EDU-GRD-2026-00001',
              'relation': 'Mother',
              'students': [
                {
                  'school_student': 'EDU-STU-2026-00001',
                  'student_name': 'Yusuf',
                  'status': 'Withdrawn',
                },
              ],
            },
            {
              'name': 'EDU-GRD-2026-00002',
              'relation': 'Father',
              'students': [
                {
                  'school_student': 'EDU-STU-2026-00001',
                  'student_name': 'Yusuf',
                  'status': 'Active',
                },
              ],
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listFamily();
      final page = (result as Ok<FamilyPage, FamilyFailure>).value;
      expect(page.members, hasLength(1));
      expect(page.members.first.isActive, isTrue);
      expect(page.members.first.guardianId, 'EDU-GRD-2026-00002');
    });

    test('returns EMPTY_RESPONSE when the envelope has no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      // Use envelopeErr with a benign code to drive the "no data"
      // branch (the data factory runs but the error is non-null).
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGuardians,
        envelopeErr(const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'No data',
        )),
      );
      final repo = makeRepo(transport);
      final result = await repo.listFamily();
      expect(result, isA<Err<FamilyPage, FamilyFailure>>());
    });
  });

  group('FamilyRepository.listGradesForStudent', () {
    test('filters wire rows by student id', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGradeRecords,
        envelopeOk({
          'records': [
            {
              'name': 'GR-00001',
              'school_student': 'STU-00001',
              'subject_name': 'Math',
              'assessment_name': 'Quiz 1',
              'score': 18,
              'max_score': 20,
              'letter_grade': 'A',
              'pass_status': 'Pass',
            },
            {
              'name': 'GR-00002',
              'school_student': 'STU-00002',
              'subject_name': 'Math',
              'assessment_name': 'Quiz 1',
              'score': 12,
              'max_score': 20,
              'pass_status': 'Fail',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listGradesForStudent('STU-00001');
      final page =
          (result as Ok<ChildRecordsPage<ChildGradeRecord>, FamilyFailure>)
              .value;
      expect(page.items, hasLength(1));
      expect(page.items.first.student, 'STU-00001');
      expect(page.items.first.letterGrade, 'A');
      expect(page.items.first.percentage, 90.0);
      expect(page.items.first.passed, isTrue);
    });

    test('returns empty page when no rows match', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGradeRecords,
        envelopeOk({
          'records': [
            {
              'name': 'GR-00099',
              'school_student': 'STU-99999',
              'subject_name': 'Other',
              'score': 0,
              'max_score': 10,
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listGradesForStudent('STU-00001');
      final page =
          (result as Ok<ChildRecordsPage<ChildGradeRecord>, FamilyFailure>)
              .value;
      expect(page.items, isEmpty);
    });
  });

  group('FamilyRepository.listAttendanceForStudent', () {
    test('filters wire rows by student id', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolAttendanceRecords,
        envelopeOk({
          'records': [
            {
              'name': 'AT-00001',
              'school_student': 'STU-00001',
              'date': '2026-07-20',
              'status': 'Present',
              'class_group': 'Grade 3-A',
            },
            {
              'name': 'AT-00002',
              'school_student': 'STU-00002',
              'date': '2026-07-20',
              'status': 'Absent',
            },
            {
              'name': 'AT-00003',
              'school_student': 'STU-00001',
              'date': '2026-07-21',
              'status': 'Late',
              'class_group': 'Grade 3-A',
              'notes': 'Bus delay',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listAttendanceForStudent('STU-00001');
      final page =
          (result as Ok<ChildRecordsPage<ChildAttendanceRecord>, FamilyFailure>)
              .value;
      expect(page.items, hasLength(2));
      expect(page.items.every((r) => r.student == 'STU-00001'), isTrue);
      expect(page.items.map((r) => r.status), containsAll(['Present', 'Late']));
    });
  });

  group('FamilyRepository.listReportCardsForStudent', () {
    test('filters wire rows by student id', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolReportCards,
        envelopeOk({
          'report_cards': [
            {
              'name': 'RC-00001',
              'school_student': 'STU-00001',
              'academic_term': 'Term 1',
              'academic_year': '2025/2026',
              'published_on': '2026-02-15',
              'average_score': 87.5,
            },
            {
              'name': 'RC-00002',
              'school_student': 'STU-00002',
              'academic_term': 'Term 1',
              'academic_year': '2025/2026',
              'published_on': '2026-02-15',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listReportCardsForStudent('STU-00001');
      final page =
          (result as Ok<ChildRecordsPage<ChildReportCard>, FamilyFailure>)
              .value;
      expect(page.items, hasLength(1));
      expect(page.items.first.term, 'Term 1');
      expect(page.items.first.academicYear, '2025/2026');
      expect(page.items.first.averageScore, 87.5);
    });
  });

  group('FamilyRepository.listAllRecordsForStudent', () {
    test('combines grades + attendance + report cards', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGradeRecords,
        envelopeOk({
          'records': [
            {
              'name': 'GR-00001',
              'school_student': 'STU-00001',
              'subject_name': 'Math',
              'score': 9,
              'max_score': 10,
              'pass_status': 'Pass',
            },
          ],
        }),
      );
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolAttendanceRecords,
        envelopeOk({
          'records': [
            {
              'name': 'AT-00001',
              'school_student': 'STU-00001',
              'date': '2026-07-20',
              'status': 'Present',
            },
          ],
        }),
      );
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolReportCards,
        envelopeOk({
          'report_cards': [
            {
              'name': 'RC-00001',
              'school_student': 'STU-00001',
              'academic_term': 'Term 1',
              'average_score': 90.0,
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listAllRecordsForStudent('STU-00001');
      final page = (result as Ok<StudentRecordsPage, FamilyFailure>).value;
      expect(page.grades.items, hasLength(1));
      expect(page.attendance.items, hasLength(1));
      expect(page.reportCards.items, hasLength(1));
    });

    test('surfaces the first failure without fetching the rest', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolGradeRecords,
        const ApiError(
          code: 'NETWORK_FAILURE',
          message: 'lost connection',
        ),
      );
      // Attendance + report cards would also be called in a
      // successful run; we deliberately don't queue them. If the
      // bug regresses (e.g. continues fetching after the first
      // failure), the fake will throw StateError("No stub queued")
      // and the test will fail loudly.
      final repo = makeRepo(transport);
      final result = await repo.listAllRecordsForStudent('STU-00001');
      expect(result, isA<Err<StudentRecordsPage, FamilyFailure>>());
      final failure = (result as Err<StudentRecordsPage, FamilyFailure>).error;
      expect(failure.code, 'NETWORK_FAILURE');
    });
  });

  group('FamilyFailure', () {
    test('isRetryable covers network + 5xx codes', () {
      const f = FamilyFailure(code: 'NETWORK_FAILURE', message: 'x');
      expect(f.isRetryable, isTrue);
    });

    test('isRetryable is false for validation errors', () {
      const f = FamilyFailure(
        code: 'STUDENT_VALIDATION_FAILED',
        message: 'x',
      );
      expect(f.isRetryable, isFalse);
    });
  });
}
