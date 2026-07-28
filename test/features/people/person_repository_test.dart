import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';
import 'package:laratik_schools_mobile/features/people/data/person_repository.dart';
import 'package:laratik_schools_mobile/features/people/data/student_form_payload.dart';

class _FakeApiClient implements LaratikSchoolsApiClient {
  _FakeApiClient({
    this.studentsResponse,
    this.profileResponse,
    this.setupResponse,
    this.createResponse,
    this.throwOnStudents,
  });

  ApiEnvelope<GetSchoolStudentsData>? studentsResponse;
  ApiEnvelope<GetSchoolStudentProfileData>? profileResponse;
  ApiEnvelope<GetStudentSetupContextData>? setupResponse;
  ApiEnvelope<CreateSchoolStudentData>? createResponse;
  Object? throwOnStudents;

  // Unused in these tests.
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('PersonRepository.listStudents', () {
    test('maps the rows to Person and preserves the cursor', () async {
      final api = _FakeApiClient(
        studentsResponse: ApiEnvelope<GetSchoolStudentsData>(
          data: const GetSchoolStudentsData(students: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-STU-2026-00001',
              'first_name': 'Layla',
              'last_name': 'Hassan',
              'status': 'Active',
              'grade': 'Grade 3',
              'class_group': 'A',
            },
            <String, Object?>{
              'name': 'EDU-STU-2026-00002',
              'first_name': 'Mona',
              'last_name': 'Karim',
              'status': 'Inactive',
              'grade': 'Grade 2',
              'class_group': 'B',
            },
          ]),
          error: null,
          meta: const ApiMeta(
            apiVersion: 'v1',
            requestId: 'req-1',
            values: <String, Object?>{'next_cursor': 'cursor-2'},
          ),
          warnings: const <Object?>[],
        ),
      );
      final repo = PersonRepository(api: api);
      final result = await repo.listStudents();
      expect(result, isA<Ok<PersonPage, PersonFailure>>());
      final page = (result as Ok<PersonPage, PersonFailure>).value;
      expect(page.people, hasLength(2));
      expect(page.people.first.fullName, 'Layla Hassan');
      expect(page.people.last.status, 'Inactive');
      expect(page.nextCursor, 'cursor-2');
      expect(page.hasMore, isTrue);
    });

    test('filters by grade and class_group client-side', () async {
      final api = _FakeApiClient(
        studentsResponse: ApiEnvelope<GetSchoolStudentsData>(
          data: const GetSchoolStudentsData(students: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-STU-2026-00001',
              'first_name': 'Layla',
              'last_name': 'Hassan',
              'grade': 'Grade 3',
              'class_group': 'A',
            },
            <String, Object?>{
              'name': 'EDU-STU-2026-00002',
              'first_name': 'Mona',
              'last_name': 'Karim',
              'grade': 'Grade 2',
              'class_group': 'B',
            },
          ]),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        ),
      );
      final repo = PersonRepository(api: api);
      final result = await repo.listStudents(
        gradeId: 'Grade 3',
        classGroupId: 'A',
      );
      final page = (result as Ok<PersonPage, PersonFailure>).value;
      expect(page.people, hasLength(1));
      expect(page.people.first.firstName, 'Layla');
    });

    test('maps API errors to PersonFailure', () async {
      final api = _FakeApiClient(
        studentsResponse: ApiEnvelope<GetSchoolStudentsData>(
          data: null,
          error: const ApiError(
            code: 'STUDENT_LIST_FORBIDDEN',
            message: 'Caller is not allowed to see this list.',
            fieldErrors: <String, List<String>>{},
          ),
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        ),
      );
      final repo = PersonRepository(api: api);
      final result = await repo.listStudents();
      expect(result, isA<Err<PersonPage, PersonFailure>>());
      final failure = (result as Err<PersonPage, PersonFailure>).error;
      expect(failure.code, 'STUDENT_LIST_FORBIDDEN');
      expect(failure.isRetryable, isFalse);
    });

    test('maps transport exceptions to retryable PersonFailure', () async {
      final api = _FakeApiClient(throwOnStudents: 'socket');
      final repo = PersonRepository(api: api);
      final result = await repo.listStudents();
      expect(result, isA<Err<PersonPage, PersonFailure>>());
      final failure = (result as Err<PersonPage, PersonFailure>).error;
      expect(failure.code, 'EXCEPTION');
    });
  });

  group('PersonRepository.createStudent', () {
    test('surfaces §1.3 country flags from the response', () async {
      final api = _FakeApiClient(
        createResponse: ApiEnvelope<CreateSchoolStudentData>(
          data: const CreateSchoolStudentData(
            schoolStudent: 'EDU-STU-2026-00010',
            studentName: 'Layla Hassan',
            erpnextCustomer: 'CUST-00010',
            status: 'Active',
            countryWasDefaulted: 'true',
            residentialCountryMismatch: '1',
          ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        ),
      );
      final repo = PersonRepository(api: api);
      const payload = StudentFormPayload(
        firstName: 'Layla',
        lastName: 'Hassan',
        country: 'Jordan',
        nationality: 'Syrian',
      );
      final result = await repo.createStudent(payload);
      expect(result, isA<Ok<PersonCreationResult, PersonFailure>>());
      final created = (result as Ok<PersonCreationResult, PersonFailure>).value;
      expect(created.schoolStudent, 'EDU-STU-2026-00010');
      expect(created.countryWasDefaulted, isTrue);
      expect(created.residentialCountryMismatch, isTrue);
    });
  });
}
