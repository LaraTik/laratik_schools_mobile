# Changelog

All notable changes to the Laratik Schools mobile client are recorded
here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed (laratik_schools backend, with user approval)

- **`School Exam Attempt` + `School Outbox Event` Datetime columns
  rejected tz-aware ISO 8601.** In
  `laratik_schools/laratik_schools/core/online_assessments.py`,
  the insert dict used `timestamp.isoformat()` where `timestamp`
  came from `_utc(now)` — the resulting `2026-07-31T12:45:54.216061+00:00`
  string is rejected by MySQL strict mode with `ERROR 1292`. Same
  shape at 7 call sites (lines 268, 355, 369, 431, 493, 555, 725,
  807). A second instance of the bug lived in
  `core/outbox.py:_record_to_mapping` — `available_at`,
  `lease_expires_at`, `processed_at` were forwarded as raw tz-aware
  `datetime`s. Both fixed with a `_naive_iso(value)` / `_to_frappe_datetime(value)`
  helper that emits `YYYY-MM-DD HH:MM:SS` (the shape Frappe's
  plain `Datetime` columns want). Verified with a full E2E:
  `School Exam Attempt EXAT-00001` now lands in ERPNext with
  `state: Pending Manual Grading, started_at, submitted_at,
  max_score, revision: 2`. Documented in `docs/bug-log.md`
  2026-07-31 "Backend `School Exam Attempt.started_at` rejects
  tz-aware ISO 8601".

## [Unreleased]

### Fixed

- **HTTP transport wire format diverged from the OpenAPI v1 contract.**
  `lib/platform/transport.dart` was wrapping every body in
  `{"args": ...}` and always using POST, which broke:
  - **GET endpoints** with `in: query` parameters (e.g.
    `get_school_online_exam_eligibility`) — the server's whitelisted-method
    dispatcher saw `form_dict = {"args": <dict>}`, dropped the kwargs
    (not in the function signature), and returned a stub
    (`{"eligible": false, "exam_plan": null}`).
  - **POST endpoints with the `payload` convention** (e.g.
    `start_school_exam_attempt`) — the generated SDK already wraps the
    caller's `payload` under a `payload` key; the transport wrapped a
    second time, so `coerce_payload(form_dict["payload"])` returned the
    inner wrapper instead of the user's args.
  - **Idempotency-Key header** was set as `X-Idempotency-Key` but the
    contract declares `Idempotency-Key` (no `X-` prefix); the server
    rejected every mutating call with "Idempotency-Key header is required".
  The transport now honours the contract: GET→query string, POST→
  `arguments` as the JSON body (the SDK owns the per-operation envelope
  shape), and the header is `Idempotency-Key`. See
  `docs/bug-log.md` 2026-07-31 "Transport wire format diverged from
  the OpenAPI v1 contract".

- **`startAttempt` missing `client_mutation_id`.** The server's
  `start_attempt()` requires this in the payload (it is the in-DB
  dedupe key for the attempt row) but it is not in the OpenAPI
  schema's `required` list because the payload uses
  `additionalProperties: true`. The repository now reuses the same
  UUID for the payload `client_mutation_id` and the
  `Idempotency-Key` header so request- and row-level dedupe are
  aligned.

- **`get_school_enrollments` is the canonical source for the active
  enrollment.** `currentStudentProvider._findActiveEnrollment` now
  calls it first (client-side filtered for
  `school_student == me && enrollment_status == "Active"`) and only
  falls back to the exam-plan audience scan when the enrollments list
  is empty. The v1 `_normalize_exam_plan` does not expose the
  `audience` child table, so the audience-only path was silently
  returning `enrollmentId: null` and producing a "Not eligible" screen
  for every exam. See `docs/bug-log.md` 2026-07-31 "Not eligible on
  every exam despite the API returning eligible".

### Added

- `AGENTS.md` at the repo root — landing doc for AI coding agents and new
  contributors. Links to ADRs, runbook, and the self-learning bug log.
- `docs/local-dev.md` — full local-dev runbook (start bench container,
  start emulator, bridge ports, drive the OAuth login, E2E smoke for the
  assessment flow, troubleshooting matrix).
- `docs/bug-log.md` — self-learning record. **Binding rule:** every bug
  fix lands a 1-paragraph entry in the same commit (see AGENTS.md §7).
  First entry: dev flavor's `baseUrl` was pointing at host port 8000
  (occupied by `meta_ads_ops` uvicorn) instead of 8700 (the actual bench
  port). Fix landed in `lib/config/flavor_config.dart`.
- `docs/adr/0007-build-flavors-and-env-config.md` referenced from the
  README. The flavor registry now has a comment in
  `lib/config/flavor_config.dart` explaining the port-8700 choice.
- `test/platform/transport_test.dart` (new) — 4 tests pin the GET-as-
  query-string, GET-with-no-args, POST-as-JSON-body, and 401-→
  `UNAUTHENTICATED` invariants of the transport.

### Changed

- `lib/config/flavor_config.dart` — `dev` and `local` flavors now point
  at host port **8700** (not 8000) because the dev bench container maps
  host `8700 → container 8000` and host 8000 is taken by another service.
  See `docs/bug-log.md` 2026-07-31.
- `README.md` — layout section now matches reality (staff / guardians /
  device / assessment / communication modules are top-level under
  `lib/features/`). Status section notes Phase 1.x + Phase 2 + Phase 5 +
  Phase 6 are shipped today.
- **Theme tokens wired through `ThemeData` via a `ThemeExtension`.**
  Every shared widget (and every screen) used to read tokens with
  `DesignTokens.forBrightness(MediaQuery.platformBrightnessOf(context))`,
  which bypasses the app theme — dark mode was effectively non-functional
  because the widget picked the *device* brightness, not the
  MaterialApp's resolved theme. The new
  `lib/ui/app_theme.dart` exposes `LaratikTokens extends ThemeExtension`
  and a `context.laratik` ergonomic accessor. `app.dart` now uses
  `buildAppTheme(...)` so the extension is attached to both `theme` and
  `darkTheme`. **Every widget** (`ls_button`, `ls_text_field`,
  `ls_status_chip`, `ls_search_bar`, `ls_empty_state`, the dashboard,
  the exam attempt screen, every list/detail/create screen) was
  swept to use `context.laratik` (or `<var>.laratik` inside a sheet
  builder). The 50+ call sites are mechanical; net -200 / +60 lines
  once the unused `design_tokens.dart` imports land.
- **Operator dashboard cleanup.**
  - Removed the misleading "Live counters land in Phase 2" placeholder
    card (Phase 2 has shipped per the CHANGELOG; the card was lying
    to the operator).
  - Added an AppBar `IconButton` for Notifications with a tooltip and
    a new unread-count badge on the dashboard's Notifications quick
    card (driven by `notificationsListProvider`). The tone flips from
    `warning` to `error` while there are unread messages.
  - Added a `Semantics` wrapper around the new unread badge so screen
    readers announce "$N unread".
- **`_ErrorScreen` (the catch-all 404 page) is now a real state view.**
  Icon + headline + recovery body + "Back to home" primary action. Was
  a single line of "Something went wrong." with no recovery path.
- **Dead code in `lib/app/router.dart` removed.** The `/auth/callback`
  route and its placeholder `_OAuthCallbackScreen` were unreachable
  (the OAuth flow uses `Navigator.push` of `OauthWebViewScreen` on the
  root navigator, not a GoRouter route). The wrapper `_LoginScreen` was
  a 1-line pass-through to the real `LoginScreen`; inlined.
- **Debug `print` calls in `exam_attempt_screen.dart` removed.** Three
  `// ignore: avoid_print` statements were left in the build path from
  a debug session; the production wire now logs through the
  `RedactingLogger` instead.
- **`LsStateView` (shared empty/loading/error surface) now wraps its
  icon + title + message in a `Semantics` container** so the screen
  reader announces the state once instead of walking every line.

### Housekeeping

- Moved ~100 stray `*.png` artifacts (old `quiz_*`, `step_*`, `app_state*`,
  etc.) from the repo root into `docs/_artifacts/`. They were
  screenshots from a previous browser-driven run and were not meant to
  be tracked at the repo root.

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
