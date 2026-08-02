// SPDX-License-Identifier: Proprietary
// Tests for the Teachers repository (My classes + class detail).
//
// The tests cover:
//   * [listMyClasses] parses v1 envelope rows into
//     [TeachingAssignment]s with class name + subject name +
//     primary flag preserved.
//   * [listMyClasses] surfaces an EMPTY_RESPONSE failure when the
//     wire returns no data block.
//   * [TeachingAssignment.fromJson] is forward-compatible: legacy
//     keys (`staff`, `class_group`, `subject`) and canonical keys
//     (`school_staff`, `school_class_group`, `subject_name`) both
//     resolve to the same value.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/teachers/data/teachers_failure.dart';
import 'package:laratik_schools_mobile/features/teachers/data/teachers_repository.dart';
import 'package:laratik_schools_mobile/features/teachers/data/teaching_assignment.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  TeachersRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      TeachersRepository(api: LaratikSchoolsApiClient(transport));

  group('TeachersRepository.listMyClasses', () {
    test('parses rows and preserves primary + status flags', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolTeachingAssignments,
        envelopeOk({
          'teaching_assignments': [
            {
              'name': 'TA-00001',
              'school_staff': 'EDU-STF-2026-00001',
              'staff_name': 'Aisha Hassan',
              'school_class_group': 'EDU-CG-2026-00001',
              'class_group_name': 'Grade 3-A',
              'subject': 'EDU-SUB-2026-00007',
              'subject_name': 'Mathematics',
              'academic_year': '2025/2026',
              'status': 'Active',
              'is_primary': true,
            },
            {
              'name': 'TA-00002',
              'school_staff': 'EDU-STF-2026-00001',
              'staff_name': 'Aisha Hassan',
              'school_class_group': 'EDU-CG-2026-00002',
              'class_group_name': 'Grade 4-B',
              'subject': 'EDU-SUB-2026-00007',
              'subject_name': 'Mathematics',
              'academic_year': '2025/2026',
              'status': 'Active',
              'is_primary': false,
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listMyClasses();
      final page =
          (result as Ok<TeachingAssignmentPage, TeachersFailure>).value;
      expect(page.assignments, hasLength(2));
      expect(page.assignments.first.classLabel, 'Grade 3-A');
      expect(page.assignments.first.subjectLabel, 'Mathematics');
      expect(page.assignments.first.isPrimary, isTrue);
      expect(page.assignments.first.isActive, isTrue);
      expect(page.assignments.last.classLabel, 'Grade 4-B');
      expect(page.assignments.last.isPrimary, isFalse);
    });

    test('accepts legacy wire keys (staff, class_group, subject)', () async {
      // Some sites predate the v1 normalized names. The mobile
      // still parses the row so the surface doesn't fall over.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolTeachingAssignments,
        envelopeOk({
          'teaching_assignments': [
            {
              'name': 'TA-00099',
              'staff': 'EDU-STF-2026-00099',
              'class_group': 'EDU-CG-2026-00099',
              'class_group_name': 'Grade 1-A',
              'subject': 'EDU-SUB-2026-00001',
              'status': 'Active',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listMyClasses();
      final page =
          (result as Ok<TeachingAssignmentPage, TeachersFailure>).value;
      expect(page.assignments, hasLength(1));
      expect(page.assignments.first.staff, 'EDU-STF-2026-00099');
      expect(page.assignments.first.classGroup, 'EDU-CG-2026-00099');
      expect(page.assignments.first.classLabel, 'Grade 1-A');
      expect(page.assignments.first.isPrimary, isFalse);
    });

    test('returns EMPTY_RESPONSE when the envelope has no data', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolTeachingAssignments,
        const ApiError(
          code: 'EMPTY_RESPONSE',
          message: 'No data',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listMyClasses();
      expect(result, isA<Err<TeachingAssignmentPage, TeachersFailure>>());
    });
  });

  group('TeachingAssignment.fromJson', () {
    test('inactive rows surface isActive=false', () {
      final a = TeachingAssignment.fromJson(<String, Object?>{
        'name': 'TA-X',
        'class_group': 'EDU-CG-2026-00001',
        'status': 'Completed',
      });
      expect(a.isActive, isFalse);
      expect(a.status, 'Completed');
    });

    test('isPrimary parses 1/0 ints and true/false bools', () {
      final asTrue = TeachingAssignment.fromJson(<String, Object?>{
        'name': 'TA-1',
        'class_group': 'EDU-CG-1',
        'is_primary': 1,
      });
      expect(asTrue.isPrimary, isTrue);
      final asZero = TeachingAssignment.fromJson(<String, Object?>{
        'name': 'TA-2',
        'class_group': 'EDU-CG-1',
        'is_primary': 0,
      });
      expect(asZero.isPrimary, isFalse);
      final asBool = TeachingAssignment.fromJson(<String, Object?>{
        'name': 'TA-3',
        'class_group': 'EDU-CG-1',
        'primary': true,
      });
      expect(asBool.isPrimary, isTrue);
    });
  });
}
