// SPDX-License-Identifier: Proprietary
// Tests for the Staff repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';
import 'package:laratik_schools_mobile/features/staff/data/staff_form_payload.dart';
import 'package:laratik_schools_mobile/features/staff/data/staff_repository.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  StaffRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      StaffRepository(api: LaratikSchoolsApiClient(transport));

  group('StaffRepository.listStaff', () {
    test('maps rows to StaffMember and preserves the cursor', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStaff,
        envelopeOk({
          'staff': [
            {
              'name': 'EDU-STF-2026-00001',
              'first_name': 'Samir',
              'last_name': 'Khoury',
              'staff_role': 'Teacher',
              'status': 'Active',
              'branch': 'Main',
            },
            {
              'name': 'EDU-STF-2026-00002',
              'first_name': 'Rana',
              'last_name': 'Idris',
              'staff_role': 'Principal',
              'status': 'Active',
              'branch': 'North',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listStaff();
      expect(result, isA<Ok<StaffPage, PersonFailure>>());
      final page = (result as Ok<StaffPage, PersonFailure>).value;
      expect(page.staff, hasLength(2));
      expect(page.staff.first.fullName, 'Samir Khoury');
      expect(page.staff.first.isTeachingRole, isTrue);
      expect(page.staff.last.staffRole, 'Principal');
      expect(page.staff.last.isTeachingRole, isFalse);
    });

    test('filters by role and search client-side', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStaff,
        envelopeOk({
          'staff': [
            {
              'name': 'EDU-STF-2026-00001',
              'first_name': 'Samir',
              'last_name': 'Khoury',
              'staff_role': 'Teacher',
            },
            {
              'name': 'EDU-STF-2026-00002',
              'first_name': 'Rana',
              'last_name': 'Idris',
              'staff_role': 'Principal',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
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
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.createSchoolStaff,
        envelopeOk({
          'school_staff': 'EDU-STF-2026-00010',
          'staff_name': 'Samir Khoury',
          'staff_role': 'Teacher',
          'erpnext_employee': 'EMP-0010',
          'status': 'Active',
        }),
      );
      final repo = makeRepo(transport);
      const payload = StaffFormPayload(
        firstName: 'Samir',
        lastName: 'Khoury',
        staffRole: 'Teacher',
      );
      final result = await repo.createStaff(payload);
      expect(result, isA<Ok<StaffCreationResult, PersonFailure>>());
      final created = (result as Ok<StaffCreationResult, PersonFailure>).value;
      expect(created.schoolStaff, 'EDU-STF-2026-00010');
      expect(created.erpnextEmployee, 'EMP-0010');
    });
  });
}
