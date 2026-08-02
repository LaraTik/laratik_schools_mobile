// SPDX-License-Identifier: Proprietary
// Tests for the derived grade + class-group filter options used
// by the Students list.
//
// The mobile derives these options from the loaded PersonPage
// because the v1 SDK does not expose a "list grades" / "list
// class groups" endpoint. The previous hard-coded
// `['Grade 1', 'Grade 2', ...]` and `['A', 'B', 'C', 'D']` lists
// lied to the operator when the school used a different catalog;
// the derived list is honest about what is in the data.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_mobile/features/people/data/filter_options.dart';
import 'package:laratik_schools_mobile/features/people/data/person.dart';

Person _makePerson({
  required String id,
  String? grade,
  String? classGroup,
}) {
  return Person(
    id: id,
    firstName: 'A',
    lastName: 'B',
    fullName: 'A B',
    studentName: 'A B',
    guardianName: null,
    grade: grade,
    classGroup: classGroup,
    academicYear: '2025/2026',
    status: 'Active',
    enrollmentStatus: 'Active',
    activationStatus: null,
    nationality: null,
    country: null,
    countryWasDefaulted: false,
    residentialCountryMismatch: false,
    erpnextCustomer: null,
    photoUrl: null,
    raw: const <String, Object?>{},
  );
}

void main() {
  group('deriveFilterOptions', () {
    test('returns empty when no students are provided', () {
      final result = deriveFilterOptions(const <Person>[]);
      expect(result.grades, isEmpty);
      expect(result.classGroups, isEmpty);
      expect(result.isEmpty, isTrue);
    });

    test('de-duplicates grade and class-group values', () {
      final people = [
        _makePerson(id: 'STU-1', grade: 'Grade 1', classGroup: 'A'),
        _makePerson(id: 'STU-2', grade: 'Grade 1', classGroup: 'B'),
        _makePerson(id: 'STU-3', grade: 'Grade 2', classGroup: 'A'),
        _makePerson(id: 'STU-4', grade: 'Grade 3', classGroup: 'A'),
      ];
      final result = deriveFilterOptions(people);
      expect(result.grades, ['Grade 1', 'Grade 2', 'Grade 3']);
      expect(result.classGroups, ['A', 'B']);
    });

    test('sorts case-insensitively', () {
      final people = [
        _makePerson(id: 'STU-1', grade: 'grade 3'),
        _makePerson(id: 'STU-2', grade: 'Grade 1'),
        _makePerson(id: 'STU-3', grade: 'GRADE 2'),
      ];
      final result = deriveFilterOptions(people);
      expect(result.grades, ['Grade 1', 'GRADE 2', 'grade 3']);
    });

    test('handles alternative catalog names (Year 1, KG-2, etc.)', () {
      // This is the test that proves the previous hard-coded
      // `['Grade 1', 'Grade 2', ...]` was a lie for schools that
      // use a different naming scheme.
      final people = [
        _makePerson(id: 'STU-1', grade: 'Year 1', classGroup: 'Maple'),
        _makePerson(id: 'STU-2', grade: 'Year 2', classGroup: 'Oak'),
        _makePerson(id: 'STU-3', grade: 'KG-2', classGroup: 'Sunflower'),
      ];
      final result = deriveFilterOptions(people);
      expect(result.grades, ['KG-2', 'Year 1', 'Year 2']);
      expect(result.classGroups, ['Maple', 'Oak', 'Sunflower']);
    });

    test('skips students with null or empty grade / class group', () {
      final people = [
        _makePerson(id: 'STU-1', grade: null, classGroup: null),
        _makePerson(id: 'STU-2', grade: '', classGroup: ''),
        _makePerson(id: 'STU-3', grade: 'Grade 1', classGroup: 'A'),
      ];
      final result = deriveFilterOptions(people);
      expect(result.grades, ['Grade 1']);
      expect(result.classGroups, ['A']);
    });
  });
}
