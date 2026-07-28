# Changelog

All notable changes to the Laratik Schools mobile client are recorded
here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Greenfield Flutter client foundation (Phase 0 of the
  `rewrite-flutter-mobile-client` OpenSpec change):
  - `lib/app/{app,bootstrap,router}.dart` composition root.
  - `lib/core/{result,clock,logging}.dart` functional plumbing.
  - `lib/ui/design_tokens.dart` Material 3 token bundle (light + dark,
    44dp touch target, 8px spacing scale, RTL-safe).
  - `lib/platform/transport.dart` HTTP transport that implements the
    generated SDK's `LaratikSchoolsTransport` contract (bearer auth,
    timeout, retry, idempotency key, Frappe envelope unwrap).
  - `lib/auth/oauth_pkce.dart` PKCE S256 + state helpers (RFC 7636).
  - `lib/auth/session.dart` persistent session store + `TokenProvider`
    + `SessionListenable` for router redirects.
  - `lib/features/boot/` role-aware boot context, service, and
    splash screen.
  - Stub folders for the 10+ feature modules (people, academics,
    attendance, grading, assessment, communication, fees, analytics,
    imports, governance, operations).
  - `test/bootstrap_test.dart` smoke test covering bootstrap graph,
    unauth redirect, and authed redirect.
  - `.github/workflows/ci.yml` with `flutter analyze`, `flutter test`,
    `dart format` check, and a contract-drift job that fails if
    `BACKEND_CONTRACT_SHA` does not match the sibling
    `laratik_schools` repo's HEAD.
  - `docs/adr/0001..0005` for OS support matrix, Flutter/Dart pin,
    app identifiers, package choices, and branding/store/telemetry.

### Pinned

- Generated v1 contract SDK at `BACKEND_CONTRACT_SHA`
  `33340ff86997f23b0574418bf45f3916c9a32544`.
- Flutter `>=3.24.0 <4.0.0`; Dart `^3.5.0`; toolchain pinned via
  `.fvmrc` to **Flutter 3.35.7 stable** (ADR 0006). CI reads `.fvmrc`
  and fails the build if the installed version drifts.

## [0.1.0+1] - 2026-07-27

### Added

- Initial repository scaffold (this commit). No user-facing features
  yet; the app boots, builds the dependency graph, and renders a
  splash / login / shell placeholder.

## [0.2.0+1] - 2026-07-28

### Added

- Phase 1 — People (Students) feature end-to-end:
  - `lib/features/people/data/person.dart` — typed `Person` model that
    narrows the forward-compatible `JsonMap` rows from
    `get_school_students`; surfaces the §1.3
    `country_was_defaulted` and `residential_country_mismatch` flags.
  - `lib/features/people/data/person_failure.dart` — typed failure with
    retryable classification.
  - `lib/features/people/data/person_repository.dart` — list / detail /
    setup-context / create wrappers over the v1 SDK; the create call
    auto-mints the idempotency key.
  - `lib/features/people/data/student_form_payload.dart` — immutable
    form state with the empty-field-drop wire shape.
  - `lib/features/people/data/person_providers.dart` — Riverpod wiring
    (`apiClientProvider`, `personRepositoryProvider`, `studentsListProvider`,
    `studentProfileProvider`, `studentSetupContextProvider`).
  - `lib/features/people/ui/widgets/person_card.dart` — list row with
    avatar, name, subtitle, status chip.
  - `lib/features/people/ui/students_list_screen.dart` — server-paginated
    list with debounced search, grade + class-group filters, pull-to-refresh.
  - `lib/features/people/ui/student_detail_screen.dart` — identity card,
    country-warning card, enrollment, identity & contact, guardians, recent
    grades.
  - `lib/features/people/ui/student_create_screen.dart` — form with the
    §1.3 country defaults surfaced as a success-card warning; two-column
    layout above 720dp.
- Shared UI primitives in `lib/ui/widgets/`:
  - `ls_button.dart` (primary / secondary / ghost / danger, 48dp target,
    loading state).
  - `ls_text_field.dart` (label + visible-required indicator + per-field
    error + 48dp height).
  - `ls_search_bar.dart` (debounced).
  - `ls_status_chip.dart` (six tones, optional icon).
  - `ls_empty_state.dart` (loading / empty / error surfaces in one shape).
- Router shell with a `NavigationBar` of five destinations (Home,
  Students, Staff, Guardians, More). Students is live; the other four
  surface a "coming in the next release" placeholder for now.

## [0.3.0+1] - 2026-07-28

### Added

- Phase 1.1 — Staff feature end-to-end:
  - `lib/features/staff/data/staff_member.dart` — typed `StaffMember` that
    narrows `get_school_staff` rows; surfaces staff_role, branch, ERPNext
    employee link.
  - `lib/features/staff/data/staff_form_payload.dart` + `staff_repository.dart` +
    `staff_providers.dart` (Riverpod wiring).
  - `lib/features/staff/ui/{staff_list,staff_detail,staff_create}_screen.dart`
    + `lib/features/staff/ui/widgets/staff_card.dart`.
  - Router: `/shell/staff`, `/shell/staff/new`, `/shell/staff/:id`.
- Phase 1.2 — Guardians feature end-to-end:
  - `lib/features/guardians/data/{guardian,guardian_form_payload,guardian_repository,
    guardian_providers}.dart`.
  - `lib/features/guardians/ui/{guardians_list,guardian_detail,guardian_create}_screen.dart`
    + `lib/features/guardians/ui/widgets/guardian_card.dart`. The Guardian
    model preserves the `linked_students` link rows; the list shows a
    student-count chip and the detail shows the children list.
  - Router: `/shell/guardians`, `/shell/guardians/new`,
    `/shell/guardians/:id`.
- Phase 1.3 — Academics surface (Subjects, Timetable, Branches):
  - `lib/features/academics/data/{subject,academics_repository,academics_providers}.dart`.
    Subject, TimetableSlot, and Branch typed models; TimetableSlot exposes
    an `isRenderable` flag so the schedule grid can skip rows missing the
    day-of-week or time fields.
  - `lib/features/academics/ui/academics_screen.dart` — three-tab
    `DefaultTabController` (Subjects / Timetable / Branches); Subjects and
    Timetable get pull-to-refresh and load-more; the day-ordered Timetable
    grid groups slots Monday..Sunday and falls back to "Unscheduled".
  - `lib/features/academics/ui/subject_create_screen.dart`.
  - Router: `/shell/academics`, `/shell/academics/subjects/new`.
- Phase 1.4 — Attendance capture + dashboard home:
  - `lib/features/attendance/data/{attendance_record,attendance_repository,
    attendance_providers}.dart`. `AttendanceStatus` + `AttendanceTone` for
    the well-known Present / Absent / Late / Excused values; the repository
    reuses `PersonRepository` for the roster read and auto-mints the
    idempotency key per mark.
  - `lib/features/attendance/ui/widgets/{attendance_status_segment,
    attendance_mark_row}.dart` — 4-way segment selector + 64dp row.
  - `lib/features/attendance/ui/{attendance_capture,attendance_list}_screen.dart`
    — operator-first capture with live P / A / L / E counters, mark-all
    shortcuts, batch submit, and a read-only history with pull-to-refresh.
  - `lib/app/dashboard_screen.dart` — operator landing with a 2x2 (or 4-up
    on wide screens) quick-start grid of the most-used create / capture
    actions; today's date in the AppBar; live counters deferred to Phase 2
    alongside the operations health wiring.
- Bottom nav restructured (cap at 5 tabs per the Laratik UI rules): Home
  moves off the nav and onto the initial `/shell` route; the five
  feature tabs are now Students / Staff / Guardians / Academics /
  Attendance.

### Tests

- `test/features/staff/staff_repository_test.dart` — list mapping with
  cursor, role + search client-side filters, create returning the staff
  id and ERPNext employee link.
- `test/features/guardians/guardian_repository_test.dart` — list mapping,
  linked-students extraction, relation + search filters, create
  returning the guardian id.
- `test/features/academics/academics_repository_test.dart` — subject
  parsing with department + credit_hours, create returning the new
  subject id, timetable slot parsing with `isRenderable` flag.
- `test/features/attendance/attendance_repository_test.dart` —
  `AttendanceStatus` tone mapping + neutral fallback, list parsing,
  roster load with default Present, submit returning the new attendance
  record id.

### Tests

- `test/features/people/person_test.dart` — `Person.fromJson` parsing,
  §1.3 flag surfacing, alias fallback for `classgroup`.
- `test/features/people/student_form_payload_test.dart` — payload
  serialization, copyWith sentinel for null-clearing, defaults
  ingestion.
- `test/features/people/person_repository_test.dart` — list / create
  mapping, client-side filters, error / exception mapping, §1.3 flags
  on create response.
- `test/bootstrap_test.dart` — graph wiring, session install id
  stability.

### CI

- `.github/workflows/ci.yml` now reads the Flutter version from
  `.fvmrc` and asserts the installed version matches the pin
  (defense in depth). The hardcoded `3.24.5` pin from the foundation
  commit is gone.

## [0.3.0+1] - 2026-07-28

### Added

- Phase 1.1 — Staff feature end-to-end:
  - `lib/features/staff/data/staff_member.dart` — typed `StaffMember`
    that narrows `get_school_staff` rows; surfaces staff_role,
    branch, ERPNext employee link.
  - `lib/features/staff/data/staff_form_payload.dart` +
    `staff_repository.dart` + `staff_providers.dart` (Riverpod wiring).
  - `lib/features/staff/ui/{staff_list,staff_detail,staff_create}_screen.dart`
    + `lib/features/staff/ui/widgets/staff_card.dart`.
  - Router: `/shell/staff`, `/shell/staff/new`, `/shell/staff/:id`.
- Phase 1.2 — Guardians feature end-to-end:
  - `lib/features/guardians/data/{guardian,guardian_form_payload,
    guardian_repository,guardian_providers}.dart`. The Guardian
    model preserves the `linked_students` link rows; the list shows a
    student-count chip and the detail shows the children list.
  - `lib/features/guardians/ui/{guardians_list,guardian_detail,
    guardian_create}_screen.dart` +
    `lib/features/guardians/ui/widgets/guardian_card.dart`.
  - Router: `/shell/guardians`, `/shell/guardians/new`,
    `/shell/guardians/:id`.
- Phase 1.3 — Academics surface (Subjects, Timetable, Branches):
  - `lib/features/academics/data/{subject,academics_repository,
    academics_providers}.dart`. Subject, TimetableSlot, and Branch
    typed models; TimetableSlot exposes an `isRenderable` flag so
    the schedule grid can skip rows missing the day-of-week or
    time fields.
  - `lib/features/academics/ui/academics_screen.dart` — three-tab
    `DefaultTabController` (Subjects / Timetable / Branches);
    Subjects and Timetable get pull-to-refresh and load-more; the
    day-ordered Timetable grid groups slots Monday..Sunday and falls
    back to "Unscheduled".
  - `lib/features/academics/ui/subject_create_screen.dart`.
  - Router: `/shell/academics`, `/shell/academics/subjects/new`.
- Phase 1.4 — Attendance capture + dashboard home:
  - `lib/features/attendance/data/{attendance_record,attendance_repository,
    attendance_providers}.dart`. `AttendanceStatus` + `AttendanceTone`
    for the well-known Present / Absent / Late / Excused values; the
    repository reuses `PersonRepository` for the roster read and
    auto-mints the idempotency key per mark.
  - `lib/features/attendance/ui/widgets/{attendance_status_segment,
    attendance_mark_row}.dart` — 4-way segment selector + 64dp row.
  - `lib/features/attendance/ui/{attendance_capture,attendance_list}_screen.dart`
    — operator-first capture with live P / A / L / E counters,
    mark-all shortcuts, batch submit, and a read-only history with
    pull-to-refresh.
  - `lib/app/dashboard_screen.dart` — operator landing with a
    quick-start grid of the most-used create / capture actions;
    today's date in the AppBar.
- Bottom nav restructured (cap at 5 tabs per the Laratik UI rules):
  Home moves off the nav and onto the initial `/shell` route; the
  five feature tabs are Students / Staff / Guardians / Academics /
  Attendance.

### Tests

- `test/features/staff/staff_repository_test.dart` — list mapping
  with cursor, role + search client-side filters, create returning
  the staff id and ERPNext employee link.
- `test/features/guardians/guardian_repository_test.dart` — list
  mapping, linked-students extraction, relation + search filters,
  create returning the guardian id.
- `test/features/academics/academics_repository_test.dart` —
  subject parsing with department + credit_hours, create returning
  the new subject id, timetable slot parsing with `isRenderable` flag.
- `test/features/attendance/attendance_repository_test.dart` —
  `AttendanceStatus` tone mapping + neutral fallback, list parsing,
  roster load with default Present, submit returning the new
  attendance record id.

## [0.4.0+1] - 2026-07-28

### Added

- Phase 2.1 — OAuth PKCE wire:
  - `lib/auth/oauth_browser.dart` — `FlutterWebAuthBrowserLauncher`
    wraps `flutter_web_auth_2` with `useWebview:false` (matches the
    Laratik mobile security configuration; embedded webviews would
    defeat the `pkce_required` invariant).
  - `lib/auth/oauth_flow.dart` — `OauthFlow` runs the PKCE dance:
    mint a fresh PkcePair + OauthState, open the system browser, parse
    the redirect (rejects on state mismatch), exchange the code at
    the token endpoint, scrub bearer / refresh tokens out of any
    error detail, and apply the tokens to the session.
  - `lib/app/login_screen.dart` — wired login screen. Reads the
    OAuth config from the bootstrap graph via Riverpod overrides
    (sessionProvider, clockProvider, loggerProvider) and runs the
    `OauthFlow` on tap. Shows a user-safe error card on failure.
  - `lib/app/bootstrap.dart` — `AppDependencies.riverpodOverrides`
    exposes the api client, session, clock, and logger as Riverpod
    overrides.
  - `pubspec.yaml` — `flutter_web_auth_2: ^2.1.0` +
    `url_launcher: ^6.3.0`.
- Phase 2.1 — Device registration + version policy:
  - `lib/features/device/data/device_service.dart` — wraps
    `get_school_mobile_version_policy`,
    `register_school_mobile_device`, and
    `revoke_school_mobile_device`. Returns typed `VersionPolicy`
    and `DeviceRegistrationResult`.
  - `lib/features/device/data/device_providers.dart` — Riverpod
    wiring (`deviceServiceProvider`, `versionPolicyProvider`).
- Phase 5 — Assessment (online exam lifecycle):
  - `lib/features/assessment/data/exam.dart` — `ExamPlan` +
    `ExamQuestion` + `ExamAttemptSummary` typed models.
    `ExamQuestion.questionType` uses a well-known constant set
    with a fallback for unknown types.
  - `lib/features/assessment/data/assessment_repository.dart` —
    `listExamPlans` (published-only by default), `checkEligibility`,
    `startAttempt`, `autosave`, `submit`, `getResult`, `abandon`.
    The repository auto-mints a UUIDv4 idempotency key per
    mutating call.
  - `lib/features/assessment/data/assessment_providers.dart` —
    Riverpod wiring.
  - `lib/features/assessment/ui/exams_list_screen.dart` — published
    exam plans list with pull-to-refresh + load-more.
  - `lib/features/assessment/ui/exam_attempt_screen.dart` — operator
    loop: eligibility gate, start (mints the attempt id from the
    server), 15-second autosave timer, type-aware question rendering
    (TextField / Radio / Checkbox), explicit Abandon + Submit
    actions with a confirm dialog.
  - Router: `/shell/academics/exams` +
    `/shell/academics/exams/:id?student=...`.
- Phase 6 — Communication (notifications inbox):
  - `lib/features/communication/data/notification.dart` — typed
    `NotificationItem` + `CommunicationLogEntry` models.
  - `lib/features/communication/data/communication_repository.dart`
    — `listNotifications` (with `unreadOnly` client-side filter) +
    `listCommunicationLogs`.
  - `lib/features/communication/data/communication_providers.dart` —
    Riverpod wiring.
  - `lib/features/communication/ui/notifications_screen.dart` —
    read-only inbox with pull-to-refresh + load-more and All /
    Unread filter chips in the AppBar bottom.
  - Router: `/shell/notifications`.
  - Dashboard quick-start grid gains a fifth card: Notifications
    (warning tone).

### Tests

- `test/features/auth/oauth_flow_test.dart` — `USER_CANCELLED` path,
  successful code-exchange path (asserts the tokens land on the
  session + roles are parsed), state-mismatch rejection, HTTP 500
  mapping, and the authorize URL contract (response_type=code,
  code_challenge_method=S256, PKCE challenge + state present).
- `test/features/assessment/assessment_repository_test.dart` —
  `listExamPlans` filtering out unpublished, `checkEligibility`
  mapping eligible + reason, `startAttempt` returning the new
  attempt id, `submit` returning the submitted attempt id.
- `test/features/communication/communication_repository_test.dart`
  — list mapping with priority + read flag, `unreadOnly` filter
  dropping read items.
