import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/core/result.dart';
import 'package:laratik_schools_mobile/features/academics/data/academics_repository.dart';
import 'package:laratik_schools_mobile/features/academics/data/subject.dart';
import 'package:laratik_schools_mobile/features/people/data/person_failure.dart';

class _FakeAcademicsApi implements LaratikSchoolsApiClient {
  ApiEnvelope<GetSchoolSubjectsData>? subjectsResponse;
  ApiEnvelope<GetSchoolTimetableSlotsData>? slotsResponse;
  ApiEnvelope<GetSchoolBranchesData>? branchesResponse;
  ApiEnvelope<CreateSchoolSubjectData>? createSubjectResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  group('AcademicsRepository.listSubjects', () {
    test('parses rows and filters by department and search', () async {
      final api = _FakeAcademicsApi()
        ..subjectsResponse = ApiEnvelope<GetSchoolSubjectsData>(
          data: const GetSchoolSubjectsData(subjects: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-SUB-2026-00001',
              'subject_name': 'Mathematics',
              'subject_code': 'MATH-101',
              'department': 'Sciences',
              'credit_hours': 4,
            },
            <String, Object?>{
              'name': 'EDU-SUB-2026-00002',
              'subject_name': 'Arabic',
              'subject_code': 'ARB-101',
              'department': 'Humanities',
              'credit_hours': 3,
            },
          ]),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = AcademicsRepository(api: api);
      final result = await repo.listSubjects(department: 'Sciences');
      final page = (result as Ok<SubjectPage, PersonFailure>).value;
      expect(page.subjects, hasLength(1));
      expect(page.subjects.first.subjectName, 'Mathematics');
      expect(page.subjects.first.creditHours, 4);
    });
  });

  group('AcademicsRepository.createSubject', () {
    test('returns the new subject id', () async {
      final api = _FakeAcademicsApi()
        ..createSubjectResponse = ApiEnvelope<CreateSchoolSubjectData>(
          data: const CreateSchoolSubjectData(
            subject: 'EDU-SUB-2026-00010',
            subjectName: 'Mathematics',
            status: 'Active',
          ),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = AcademicsRepository(api: api);
      final result = await repo.createSubject(
        subjectName: 'Mathematics',
        subjectCode: 'MATH-101',
        department: 'Sciences',
        creditHours: 4,
      );
      expect(result, isA<Ok<SubjectCreationResult, PersonFailure>>());
      final created =
          (result as Ok<SubjectCreationResult, PersonFailure>).value;
      expect(created.subjectId, 'EDU-SUB-2026-00010');
      expect(created.status, 'Active');
    });
  });

  group('AcademicsRepository.listTimetable', () {
    test('parses slots and exposes a renderable flag', () async {
      final api = _FakeAcademicsApi()
        ..slotsResponse = ApiEnvelope<GetSchoolTimetableSlotsData>(
          data: const GetSchoolTimetableSlotsData(slots: <JsonMap>[
            <String, Object?>{
              'name': 'EDU-TTL-2026-00001',
              'day_of_week': 'Monday',
              'start_time': '08:00',
              'end_time': '09:00',
              'subject': 'Mathematics',
              'instructor': 'Samir Khoury',
              'class_group': 'A',
              'room': 'B-101',
            },
            <String, Object?>{
              'name': 'EDU-TTL-2026-00002',
              // Missing day_of_week — should be isRenderable=false.
              'start_time': '09:00',
              'end_time': '10:00',
              'subject': 'Arabic',
            },
          ]),
          error: null,
          meta: const ApiMeta(apiVersion: 'v1', requestId: 'req-1'),
          warnings: const <Object?>[],
        );
      final repo = AcademicsRepository(api: api);
      final result = await repo.listTimetable();
      final page = (result as Ok<TimetablePage, PersonFailure>).value;
      expect(page.slots, hasLength(2));
      expect(page.slots.first.isRenderable, isTrue);
      expect(page.slots.last.isRenderable, isFalse);
      expect(page.slots.first.subtitle, 'A · Samir Khoury · B-101');
    });
  });
}
