import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/guardians/data/guardian.dart';
import 'package:laratik_schools_mobile/features/guardians/data/guardian_form_payload.dart';
import 'package:laratik_schools_mobile/features/guardians/data/guardian_repository.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';

class _FakeGuardianApi implements LaratikSchoolsApiClient {
  ApiEnvelope<GetSchoolGuardiansData>? listResponse;
  ApiEnvelope<CreateSchoolGuardianData>? createResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('GuardianRepository.listGuardians', () {
    test('parses rows and exposes linked students', () async {
      final api = _FakeGuardianApi()
        ..listResponse = ApiEnvelope<GetSchoolGuardiansData>(
          data: const GetSchoolGuardiansData(guardians: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-GRD-2026-00001',
              'guardian_name': 'Aisha Hassan',
              'relation': 'Mother',
              'phone': '+962791234567',
              'students': <JsonMap>[
                <String, Object?>{'name': 'EDU-STU-2026-00001'},
              ],
            },
            <String, Object?>{
              'name': 'EDU-GRD-2026-00002',
              'guardian_name': 'Omar Hassan',
              'relation': 'Father',
              'phone': '+962791234568',
              'students': <JsonMap>[
                <String, Object?>{'name': 'EDU-STU-2026-00001'},
                <String, Object?>{'name': 'EDU-STU-2026-00002'},
              ],
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
      final repo = GuardianRepository(api: api);
      final result = await repo.listGuardians();
      expect(result, isA<Ok<GuardianPage, PersonFailure>>());
      final page = (result as Ok<GuardianPage, PersonFailure>).value;
      expect(page.guardians, hasLength(2));
      expect(page.guardians.first.guardianName, 'Aisha Hassan');
      expect(page.guardians.first.linkedStudents, hasLength(1));
      expect(page.guardians.last.linkedStudents, hasLength(2));
      expect(page.guardians.first.subtitle, 'Mother');
      expect(page.nextCursor, 'cursor-2');
    });

    test('filters by relation and search client-side', () async {
      final api = _FakeGuardianApi()
        ..listResponse = ApiEnvelope<GetSchoolGuardiansData>(
          data: const GetSchoolGuardiansData(guardians: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-GRD-2026-00001',
              'guardian_name': 'Aisha Hassan',
              'relation': 'Mother',
            },
            <String, Object?>{
              'name': 'EDU-GRD-2026-00002',
              'guardian_name': 'Omar Hassan',
              'relation': 'Father',
            },
          ]),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = GuardianRepository(api: api);
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
      final api = _FakeGuardianApi()
        ..createResponse = ApiEnvelope<CreateSchoolGuardianData>(
          data: const CreateSchoolGuardianData(
            schoolGuardian: 'EDU-GRD-2026-00010',
            guardianName: 'Aisha Hassan',
            status: 'Active',
          ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = GuardianRepository(api: api);
      const payload = GuardianFormPayload(
        guardianName: 'Aisha Hassan',
        relation: 'Mother',
        phone: '+962791234567',
      );
      final result = await repo.createGuardian(payload);
      expect(result, isA<Ok<GuardianCreationResult, PersonFailure>>());
      final created =
          (result as Ok<GuardianCreationResult, PersonFailure>).value;
      expect(created.schoolGuardian, 'EDU-GRD-2026-00010');
      expect(created.guardianName, 'Aisha Hassan');
    });
  });
}
