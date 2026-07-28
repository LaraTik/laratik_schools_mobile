// SPDX-License-Identifier: Proprietary
// Tests for the Guardian repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/guardians/data/guardian_form_payload.dart';
import 'package:laratik_schools_mobile/features/guardians/data/guardian_repository.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  GuardianRepository makeRepo(FakeLaratikSchoolsTransport transport) =>
      GuardianRepository(api: LaratikSchoolsApiClient(transport));

  group('GuardianRepository.listGuardians', () {
    test('parses rows and exposes linked students', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGuardians,
        envelopeOk({
          'guardians': [
            {
              'name': 'EDU-GRD-2026-00001',
              'guardian_name': 'Aisha Hassan',
              'relation': 'Mother',
              'phone': '+962791234567',
              'students': [
                {'name': 'EDU-STU-2026-00001'},
              ],
            },
            {
              'name': 'EDU-GRD-2026-00002',
              'guardian_name': 'Omar Hassan',
              'relation': 'Father',
              'phone': '+962791234568',
              'students': [
                {'name': 'EDU-STU-2026-00001'},
                {'name': 'EDU-STU-2026-00002'},
              ],
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listGuardians();
      final page = (result as Ok<GuardianPage, PersonFailure>).value;
      expect(page.guardians, hasLength(2));
      expect(page.guardians.first.guardianName, 'Aisha Hassan');
      expect(page.guardians.first.linkedStudents, hasLength(1));
      expect(page.guardians.last.linkedStudents, hasLength(2));
      expect(page.guardians.first.subtitle, 'Mother');
    });

    test('filters by relation and search client-side', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolGuardians,
        envelopeOk({
          'guardians': [
            {
              'name': 'EDU-GRD-2026-00001',
              'guardian_name': 'Aisha Hassan',
              'relation': 'Mother',
            },
            {
              'name': 'EDU-GRD-2026-00002',
              'guardian_name': 'Omar Hassan',
              'relation': 'Father',
            },
          ],
        }),
      );
      final repo = makeRepo(transport);
      final result = await repo.listGuardians(
        relation: 'Father',
        search: 'omar',
      );
      final page = (result as Ok<GuardianPage, PersonFailure>).value;
      expect(page.guardians, hasLength(1));
      expect(page.guardians.first.guardianName, 'Omar Hassan');
    });
  });

  group('GuardianRepository.createGuardian', () {
    test('returns the new guardian id', () async {
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.createSchoolGuardian,
        envelopeOk({
          'school_guardian': 'EDU-GRD-2026-00010',
          'guardian_name': 'Aisha Hassan',
          'status': 'Active',
        }),
      );
      final repo = makeRepo(transport);
      const payload = GuardianFormPayload(
        guardianName: 'Aisha Hassan',
        relation: 'Mother',
        phone: '+962791234567',
      );
      final result = await repo.createGuardian(payload);
      final created =
          (result as Ok<GuardianCreationResult, PersonFailure>).value;
      expect(created.schoolGuardian, 'EDU-GRD-2026-00010');
      expect(created.guardianName, 'Aisha Hassan');
    });
  });
}
