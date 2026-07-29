// SPDX-License-Identifier: Proprietary
// Tests for the People repository, using a `FakeLaratikSchoolsTransport`
// behind the production `LaratikSchoolsApiClient`. The transport is
// the test seam; feature code never touches it directly.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';
import 'package:laratik_schools_mobile/features/people/data/person_repository.dart';
import 'package:laratik_schools_mobile/features/people/data/student_form_payload.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  PersonRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      PersonRepository(api: LaratikSchoolsApiClient(transport));

  group('PersonRepository.listStudents', () {
    test('maps the rows to Person and preserves the cursor', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({
          'students': [
            {
              'name': 'EDU-STU-2026-00001',
              'first_name': 'Layla',
              'last_name': 'Hassan',
              'status': 'Active',
              'grade': 'Grade 3',
              'class_group': 'A',
            },
            {
              'name': 'EDU-STU-2026-00002',
              'first_name': 'Mona',
              'last_name': 'Karim',
              'status': 'Inactive',
              'grade': 'Grade 2',
              'class_group': 'B',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listStudents();
      expect(result, isA<Ok<PersonPage, PersonFailure>>());
      final page = (result as Ok<PersonPage, PersonFailure>).value;
      expect(page.people, hasLength(2));
      expect(page.people.first.fullName, 'Layla Hassan');
      expect(page.people.last.status, 'Inactive');
    });

    test('filters by grade and classGroup client-side', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({
          'students': [
            {
              'name': 'EDU-STU-2026-00001',
              'first_name': 'Layla',
              'last_name': 'Hassan',
              'grade': 'Grade 3',
              'class_group': 'A',
            },
            {
              'name': 'EDU-STU-2026-00002',
              'first_name': 'Mona',
              'last_name': 'Karim',
              'grade': 'Grade 2',
              'class_group': 'B',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listStudents(
        gradeId: 'Grade 3',
        classGroupId: 'A',
      );
      final page = (result as Ok<PersonPage, PersonFailure>).value;
      expect(page.people, hasLength(1));
      expect(page.people.first.firstName, 'Layla');
    });

    test('maps API errors to PersonFailure', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondError(
        LaratikSchoolsApiMethods.getSchoolStudents,
        const ApiError(
          code: 'STUDENT_LIST_FORBIDDEN',
          message: 'Caller is not allowed to see this list.',
        ),
      );
      final repo = makeRepo(transport);
      final result = await repo.listStudents();
      expect(result, isA<Err<PersonPage, PersonFailure>>());
      final failure = (result as Err<PersonPage, PersonFailure>).error;
      expect(failure.code, 'STUDENT_LIST_FORBIDDEN');
    });

    test('search matches the document name (school_student)', () async {
      // The v1 list endpoint returns the Frappe primary key under
      // `school_student`. Callers like `currentStudentProvider` look
      // up a cached id with `listStudents(search: <id>)`; if the
      // search filter ignores the document name, the lookup returns
      // empty and the provider silently fails. Regression guard.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({
          'students': [
            {
              'school_student': 'STU-00001',
              'first_name': 'Ahmad',
              'last_name': 'Barmada',
              'status': 'Active',
            },
            {
              'school_student': 'STU-00061',
              'first_name': 'Test',
              'last_name': 'Student',
              'status': 'Active',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listStudents(search: 'STU-00061');
      expect(result, isA<Ok<PersonPage, PersonFailure>>());
      final page = (result as Ok<PersonPage, PersonFailure>).value;
      expect(page.people, hasLength(1));
      expect(page.people.first.id, 'STU-00061');
    });
  });

  group('PersonRepository.createStudent', () {
    test('surfaces §1.3 country flags from the response', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.createSchoolStudent,
        envelopeOk({
          'school_student': 'EDU-STU-2026-00010',
          'student_name': 'Layla Hassan',
          'erpnext_customer': 'CUST-00010',
          'status': 'Active',
          'country_was_defaulted': 'true',
          'residential_country_mismatch': '1',
        }),
      );
      final repo = makeRepo(transport);
      const payload = StudentFormPayload(
        firstName: 'Layla',
        lastName: 'Hassan',
        country: 'Jordan',
        nationality: 'Syrian',
      );
      final result = await repo.createStudent(payload);
      expect(result, isA<Ok<PersonCreationResult, PersonFailure>>());
      final created =
          (result as Ok<PersonCreationResult, PersonFailure>).value;
      expect(created.schoolStudent, 'EDU-STU-2026-00010');
      expect(created.countryWasDefaulted, isTrue);
      expect(created.residentialCountryMismatch, isTrue);
    });
  });
}
