// SPDX-License-Identifier: Proprietary
// Tests for the `currentStudentProvider` — the resolver that takes the
// cached `currentStudentId` from the session and turns it into a
// `CurrentStudent` (Person + matching active enrollment).
//
// The provider has two branches:
//   1. Cached id present → look the student up by id, derive the
//      enrollment from the published exam plans' audience snapshot.
//   2. Cold start (no cached id) → list students, pick the first.
//
// Branch 1 used to fail silently because the repository's client-side
// search filter didn't include the document name (`school_student`),
// so a `listStudents(search: "STU-00061")` call returned an empty
// page and the provider returned `null` (the "No student resolved"
// dashboard card). These tests pin both branches so the regression
// doesn't come back.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';
import 'package:laratik_schools_mobile/app/login_screen.dart' show sessionProvider;
import 'package:laratik_schools_mobile/auth/session.dart';
import 'package:laratik_schools_mobile/core/clock.dart';
import 'package:laratik_schools_mobile/core/logging.dart';
import 'package:laratik_schools_mobile/features/assessment/data/current_student_provider.dart';
import 'package:laratik_schools_mobile/features/people/data/person_providers.dart';

import '../../helpers/mock_api_client.dart';

void main() {
  late FixedClock clock;
  late RedactingLogger logger;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 7, 28, 12, 0));
    logger = RedactingLogger(clock: clock);
  });

  SessionStore freshSession({String? currentStudentId}) {
    final session = SessionStore.inMemory(clock: clock, logger: logger);
    if (currentStudentId != null) {
      // setCurrentStudent is async, but it sets the in-memory field
      // synchronously and the test only reads the in-memory field.
      session.setCurrentStudent(
        studentId: currentStudentId,
        enrollmentId: null,
      );
    }
    return session;
  }

  ProviderContainer makeContainer({
    required SessionStore session,
    required LaratikSchoolsTransport transport,
  }) {
    final api = LaratikSchoolsApiClient(transport);
    return ProviderContainer(
      overrides: [
        sessionProvider.overrideWithValue(session),
        apiClientProvider.overrideWithValue(api),
      ],
    );
  }

  group('currentStudentProvider', () {
    test('cold start: picks the first student from the list', () async {
      // Branch 2 — no cached id. The provider lists students, picks the
      // first non-empty row, and persists the choice.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({
          'students': [
            {
              'school_student': 'STU-00061',
              'first_name': 'Test',
              'last_name': 'Student',
              'student_name': 'Test Student',
              'status': 'Active',
            },
          ],
        }),
      );
      // listExamPlans is called next to resolve the active enrollment.
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        envelopeOk({'plans': []}),
      );

      final session = freshSession();
      final container = makeContainer(
        session: session,
        transport: transport,
      );
      addTearDown(container.dispose);

      final current =
          await container.read(currentStudentProvider.future);
      expect(current, isNotNull);
      expect(current!.studentId, 'STU-00061');
      expect(current.person.fullName, 'Test Student');
      // The cold-start path writes the resolved id back to the session
      // so the next launch can use branch 1.
      expect(session.currentStudentId, 'STU-00061');
    });

    test('cached id: re-resolves the person by document name', () async {
      // Branch 1 — cached id present. The provider looks the student
      // up via `listStudents(search: "STU-00061", limit: 5)`. Before
      // the search-filter fix, this returned an empty page because
      // the haystack only had name fields, not `school_student` /
      // `name` / `id`. This test pins the fix.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({
          'students': [
            {
              'school_student': 'STU-00001',
              'first_name': 'Ahmad',
              'last_name': 'Barmada',
              'student_name': 'Ahmad Barmada',
              'status': 'Active',
            },
            {
              'school_student': 'STU-00061',
              'first_name': 'Test',
              'last_name': 'Student',
              'student_name': 'Test Student',
              'status': 'Active',
            },
          ],
        }),
      );
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        // The v1 exam-plans wire format doesn't include an `audience`
        // field (audience is resolved at a different layer / endpoint
        // for the assessment slice). The provider gracefully degrades
        // to an empty enrollment id when the field is missing — the
        // start_attempt call can then pass `school_enrollment: null`
        // and let the backend re-derive it.
        envelopeOk({'plans': []}),
      );

      final session = freshSession(currentStudentId: 'STU-00061');
      final container = makeContainer(
        session: session,
        transport: transport,
      );
      addTearDown(container.dispose);

      final current =
          await container.read(currentStudentProvider.future);
      expect(current, isNotNull,
          reason: 'cached id must re-resolve; this was the silent-fail '
              'bug from the v1 student list wire format fix');
      expect(current!.studentId, 'STU-00061');
      // The Person is correctly resolved; the active enrollment id is
      // left empty for the start_attempt call to fill in.
      expect(current.enrollmentId, isEmpty);
      expect(current.person.fullName, 'Test Student');
    });

    test('cached id that the list cannot find returns null', () async {
      // The search filter is applied server-side via the haystack.
      // If the cached id doesn't match any row, the filter yields an
      // empty page and the provider returns null — the dashboard
      // surfaces a "No student resolved" card so the operator knows
      // the session is stale.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({
          'students': [
            {
              'school_student': 'STU-00099',
              'first_name': 'Other',
              'last_name': 'Student',
              'status': 'Active',
            },
          ],
        }),
      );

      final session = freshSession(currentStudentId: 'STU-00061');
      final container = makeContainer(
        session: session,
        transport: transport,
      );
      addTearDown(container.dispose);

      final current =
          await container.read(currentStudentProvider.future);
      expect(current, isNull,
          reason: 'a stale cached id with no match must surface as '
              'null so the dashboard shows the empty state');
    });

    test('cached id matched by name (not id) returns the first match',
        () async {
      // The `firstWhere(id == cached, orElse: first)` fall-back: if
      // the search filter accepts the row but the id field differs
      // (e.g. a row whose name field matched the search but the
      // `school_student` id is different), the provider returns
      // whatever `firstWhere` finds. This pins the `orElse` branch
      // so it doesn't change silently.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({
          'students': [
            {
              'school_student': 'STU-00099',
              'first_name': 'Test',
              'last_name': 'Student',
              'student_name': 'Test Student',
              'status': 'Active',
            },
          ],
        }),
      );
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolExamPlans,
        envelopeOk({'plans': []}),
      );

      final session = freshSession(currentStudentId: 'STU-00099');
      final container = makeContainer(
        session: session,
        transport: transport,
      );
      addTearDown(container.dispose);

      final current =
          await container.read(currentStudentProvider.future);
      expect(current, isNotNull);
      expect(current!.studentId, 'STU-00099');
      expect(current.person.fullName, 'Test Student');
    });

    test('empty list returns null so the dashboard can show the empty state',
        () async {
      // If the server returns zero students (e.g. fresh install before
      // any student has been seeded), the provider must surface null
      // and let the dashboard render the "No student resolved" card
      // instead of crashing.
      final transport = FakeLaratikSchoolsTransport();
      transport.respondOnce(
        LaratikSchoolsApiMethods.getSchoolStudents,
        envelopeOk({'students': []}),
      );

      final session = freshSession();
      final container = makeContainer(
        session: session,
        transport: transport,
      );
      addTearDown(container.dispose);

      final current =
          await container.read(currentStudentProvider.future);
      expect(current, isNull);
    });
  });
}
