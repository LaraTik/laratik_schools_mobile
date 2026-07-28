import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';
import 'package:laratik_schools_mobile/features/staff/data/staff_form_payload.dart';
import 'package:laratik_schools_mobile/features/staff/data/staff_repository.dart';

class _FakeStaffApi implements LaratikSchoolsApiClient {
  ApiEnvelope<GetSchoolStaffData>? listResponse;
  ApiEnvelope<CreateSchoolStaffData>? createResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('StaffRepository.listStaff', () {
    test('maps rows to StaffMember and preserves the cursor', () async {
      final api = _FakeStaffApi()
        ..listResponse = ApiEnvelope<GetSchoolStaffData>(
          data: const GetSchoolStaffData(staff: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-STF-2026-00001',
              'first_name': 'Samir',
              'last_name': 'Khoury',
              'staff_role': 'Teacher',
              'status': 'Active',
              'branch': 'Main',
            },
            <String, Object?>{
              'name': 'EDU-STF-2026-00002',
              'first_name': 'Rana',
              'last_name': 'Idris',
              'staff_role': 'Principal',
              'status': 'Active',
              'branch': 'North',
            },
          ]),
          error: null,
          meta: const ApiMeta(
            apiVersion: 'v1',
            requestId: 'req-1',
            values: <String, Object?>{'next_cursor': 'cursor-2'},
          ),
          warnings: const <Object?>[],
        );
      final repo = StaffRepository(api: api);
      final result = await repo.listStaff();
      expect(result, isA<Ok<StaffPage, PersonFailure>>());
      final page = (result as Ok<StaffPage, PersonFailure>).value;
      expect(page.staff, hasLength(2));
      expect(page.staff.first.fullName, 'Samir Khoury');
      expect(page.staff.first.isTeachingRole, isTrue);
      expect(page.staff.last.staffRole, 'Principal');
      expect(page.staff.last.isTeachingRole, isFalse);
      expect(page.nextCursor, 'cursor-2');
      expect(page.hasMore, isTrue);
    });

    test('filters by role and search client-side', () async {
      final api = _FakeStaffApi()
        ..listResponse = ApiEnvelope<GetSchoolStaffData>(
          data: const GetSchoolStaffData(staff: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-STF-2026-00001',
              'first_name': 'Samir',
              'last_name': 'Khoury',
              'staff_role': 'Teacher',
            },
            <String, Object?>{
              'name': 'EDU-STF-2026-00002',
              'first_name': 'Rana',
              'last_name': 'Idris',
              'staff_role': 'Principal',
            },
          ]),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = StaffRepository(api: api);
      final result = await repo.listStaff(
        staffRole: 'Principal',
        search: 'rana',
      );
      final page = (result as Ok<StaffPage, PersonFailure>).value;
      expect(page.staff, hasLength(1));
      expect(page.staff.first.firstName, 'Rana');
    });
  });

  group('StaffRepository.createStaff', () {
    test('returns the new staff id and erpnext employee link', () async {
      final api = _FakeStaffApi()
        ..createResponse = ApiEnvelope<CreateSchoolStaffData>(
          data: const CreateSchoolStaffData(
            schoolStaff: 'EDU-STF-2026-00010',
            staffName: 'Samir Khoury',
            staffRole: 'Teacher',
            erpnextEmployee: 'EMP-0010',
            status: 'Active',
          ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = StaffRepository(api: api);
      const payload = StaffFormPayload(
        firstName: 'Samir',
        lastName: 'Khoury',
        staffRole: 'Teacher',
      );
      final result = await repo.createStaff(payload);
      expect(result, isA<Ok<StaffCreationResult, PersonFailure>>());
      final created =
          (result as Ok<StaffCreationResult, PersonFailure>).value;
      expect(created.schoolStaff, 'EDU-STF-2026-00010');
      expect(created.erpnextEmployee, 'EMP-0010');
    });
  });
}
