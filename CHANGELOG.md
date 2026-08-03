# Changelog

All notable changes to the Laratik Schools mobile client are recorded
here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Privacy request submit form (parent + student write
  flow).** New 5-tab choice-chip form at
  `/shell/governance/submit/:requesterType/:subjectType/:subject`
  for submitting a data access / rectification / erasure /
  consent_withdrawal / legal_hold request. Calls
  `submit_school_privacy_request` with a canonical
  `SubmitSchoolPrivacyRequestPayload` (request type +
  requester type + subject type + subject id + requested
  categories list + school branch + authority reference
  + fresh `client_request_id` UUID v4 so a retry of the
  same submit is safe to send again). The repository mints
  a separate fresh UUID for the `Idempotency-Key` header.
  Two new home tiles launch the form — `Submit a privacy
  request` on the parent home + the same tile on the
  student home (disabled until a current student is
  resolved). The locale test grew from 22 to 23 to pin
  the new keys in both English and Modern Standard Arabic.
  The form's locale + RTL pass: category chip labels
  extracted to ARB keys, ChoiceChip strip + FilterChip
  strip + summary card + success card + summary rows all
  honor `EdgeInsetsDirectional`. Closes the
  parent + student write-flow gap of the privacy roadmap.

- **Student + parent "Fee invoices" tile.** New
  `My fee invoices` (student) + `Fee invoices` (parent)
  tile on the role home, both launching the read-only
  fee plans list at `/shell/fees/plans`. The previous
  capability gate (`can_view_fees`, admin-only) on
  the parent tile was wrong — the v1 server is
  expected to filter `get_school_student_fee_plans` to
  the current user's children when the session is a
  parent role, so the tile is now rendered for every
  parent. Closes roadmap #7 for the student + parent
  read-only fee surface.
- **Student detail + create surface locale + RTL
  pass.** Hardcoded English strings on the student
  detail + create screens extracted to ARB keys in
  both English (source) + Modern Standard Arabic.
  ~40 new ARB keys cover the section headers (Current
  enrollment / Identity & contact / Guardians /
  Recent grades / Identity / Date of birth / Country
  & nationality / Guardian / Enrollment / Notes),
  the entry labels (Grade / Class group / Academic
  year / Status / Enrollment status / Activation /
  Nationality / Country / ERPNext customer), the
  field hints + the success modal copy ("Student
  created" / "Create another" / "Open record"), the
  country-warning chips + messages, and the loading /
  error states. The locale test grew from 13 to 14
  to pin the new keys in both locales. Closes
  roadmap #11 for the student detail + create
  surfaces.
- **Teacher exam authoring + per-question publish +
  exam publish flow.** New question authoring form at
  `/shell/teachers/exams/:examPlanId/questions/new`
  (text + type picker [Single Choice / Multiple
  Choice / True/False / Short Text / Long Text /
  Numeric] + marks + dynamic options list with per-
  option "correct" flag) calls `create_school_question`
  on submit. Each question card on the plan detail
  now ships a per-question **Publish** action that
  calls `publish_school_question`. The plan detail
  now also ships a **Publish exam** action that calls
  `publish_school_online_exam` to freeze the audience
  + question list. The new "Add question" + "Publish
  exam" + per-question "Publish" actions all mint a
  fresh UUID for the `Idempotency-Key` header. The
  full question editor + `promote_school_exam_attempt`
  (per graded attempt → grade record) write flows are
  deferred to a follow-up turn.
- **Teacher "Exams" surface — read-only exam plan
  catalog + manual grading form.** New
  `/shell/teachers/exams` route with the per-plan
  detail at `/shell/teachers/exams/:examPlanId` (shows
  status + subject + exam date + duration + max score
  + the subject's question catalog with marks) and the
  manual grade form at
  `/shell/teachers/exams/:examPlanId/grade` (attempt
  ID + per-question scores, validated to 0 ≤ score ≤
  marks, submitted via `grade_school_exam_attempt`).
  Reachable from a new "Exams" tile on the teacher
  home. Closes roadmap #6 for the read-only catalog +
  manual grading slice + the create-exam-plan shell
  (`create_school_exam_plan`). The full question
  editor + per-question publishing +
  `publish_school_online_exam` +
  `promote_school_exam_attempt` write flows are
  deferred to a follow-up turn.
- **`LsTextField` now supports `Form` integration.**
  Added an optional `validator` parameter +
  swapped the underlying `TextField` for
  `TextFormField` so the manual grade form can use
  `_formKey.currentState?.validate()` for inline
  per-field error reporting.
- **Admin "Data imports" surface — read-only "Batches" +
  "Score imports" catalog.** New `/shell/imports` route
  with two tabs (Batches + Score imports), the per-batch
  reconciliation detail at `/shell/imports/:batchId`, and
  the per-score-import detail at
  `/shell/imports/scores/:scoreImportId` (with working
  **Validate** + **Commit** buttons for the score
  import slice). Closes roadmap #9 for the data
  import catalog + the score import write flows. The
  full upload + dry-run + review + approve + commit
  wizard is deferred to a follow-up turn because the
  v1 SDK's `upload_school_data_import_package` endpoint
  expects a pre-uploaded `package_file` (Frappe's file
  API) which is outside the v1 SDK scope today.
- **New "Data imports" tile on the admin home.**
  Capability-gated on `can_manage_branches` (admin-only
  on the v1 wire; the v1 server does not yet expose a
  dedicated `can_view_imports` capability — see
  `docs/PROD_READINESS_AUDIT.md` §4 follow-up for the
  future hardening).
- **`FakeLaratikSchoolsTransport` now tracks the
  `Idempotency-Key` header** (`invokedIdempotencyKey` /
  `invokedIdempotencyKeys` getters) so future write-flow
  tests can assert "a fresh UUID v4 was minted for the
  `Idempotency-Key` header" without poking the transport
  internals. The new data import repository test exercises
  this for `validate_school_score_import` +
  `commit_school_score_import`.
- **Login + Notifications + Students list surfaces fully
  localized.** Closes the final leg of the #11
  follow-up on the highest-traffic surfaces. New ARB
  keys (login screen + SSO + OAuth + PKCE + in-app
  webview, notifications inbox title + filter chips +
  loading / error / empty copy, students list title +
  search + filters + new-student button + error copy)
  in both `app_en.arb` (English source) and `app_ar.arb`
  (Modern Standard Arabic).
- **RTL fix in the Students list AppBar.** The literal
  `EdgeInsets.only(right:)` on the "New student" button
  is replaced with `EdgeInsetsDirectional.only(end:)`
  so the button hugs the trailing edge in both
  directions. Combined with the localized strings, the
  surface now reads cleanly under Arabic.

### Changed

- `lib/app/login_screen.dart` — every hardcoded string
  (the "Laratik Schools" title, the "Sign in to continue"
  subtitle, the "OAuth + PKCE" + "S256, in-app webview"
  security card, the "Laratik SSO" chip, the
  "Sign in with Laratik" + "Opening browser…" button
  labels) is now locale-aware. The `WebViewOauthBrowserLauncher`
  title now uses the same localized label.
- `lib/features/communication/ui/notifications_screen.dart`
  — the AppBar back-button + refresh + filter chips
  (All / Unread) + loading / error / empty copy are now
  locale-aware.
- `lib/features/people/ui/students_list_screen.dart` —
  the AppBar title + refresh tooltip + "New student"
  button + search placeholder + filter chip labels
  (Grade / Class group / Clear) + filter sheet titles
  (Filter by grade / Filter by class group) + loading /
  empty / no-match / error copy are now locale-aware.

### Tests

- No new tests in this release (all changes are
  mechanical string replacements). Total test count
  unchanged: **126 passed, 5 pre-existing failures**.

## [Unreleased]

### Added

- **Admin grading write flow — `correct_school_grade_record`.**
  New screen at `/shell/grading/correct/:gradeName` that
  lets the admin correct the score + max score of an
  existing grade record (with a required `reason`).
  The repository mints a fresh UUID for the
  `Idempotency-Key` header; the controller invalidates
  the overview + policies providers on success so the
  next ref.watch re-fetches the new summary. Reachable
  from a new "Correct a grade" action on the Grading
  surface AppBar (which opens a quick prompt for the
  grade ID and pushes the form — same pattern as the
  teacher exam "manual grade entry" flow that asks for
  the attempt ID). The success card surfaces the
  corrected score + max + actor + timestamp chips.
  ~30 new ARB keys in en + ar. 3 new repository tests
  (canonical-payload shape + reason-omission + typed-
  error envelope) + 1 new locale test. The grading
  test count grew 7 → 10. The locale test count grew
  19 → 20. Closes the grading-write slice of roadmap
  #9. The remaining admin write flows
  (`approve_school_subject_grade_policy`,
  `promote_school_assessment_result`,
  `replay_school_delivery_event`,
  `receive_school_delivery_callback`,
  `approve_school_data_governance_settings`) are
  deferred to follow-up turns.

### Added

- **Locale + RTL pass on the 5 remaining secondary
  surfaces (closes roadmap #11).** Hardcoded English
  strings on the staff list / detail / create + the
  guardian list / detail / create + the academics
  3-tab screen + the subject create form + the
  attendance list / capture (incl. the per-row mark
  widget + the 4-way status segment + the per-status
  badge) + the exam list / attempt are extracted to
  ARB keys in both English (source) + Modern Standard
  Arabic with the six ICU plural categories where the
  strings carry counts. ~210 new ARB keys. The locale
  test grew 14 → 19 tests (one per release). The RTL
  pass replaces every `EdgeInsets.only(right:)` +
  every `EdgeInsets.symmetric(horizontal: ...)` +
  every `Icons.chevron_right` (raw `Icon` does not
  auto-mirror like `ListTile` does) with the
  `EdgeInsetsDirectional` / `Directionality.of(context)`
  counterparts. The per-row staff + guardian
  `chevron_right` is mirrored under RTL. The AppBar
  trailing-edge actions on the 6 new surfaces use
  `EdgeInsetsDirectional.only(end:)`. The "Submitted
  {count} record(s) for {date}" + the "{minutes, plural,
  =1{1 min} other{{minutes} min}}" + the "{marks, plural,
  =1{1 pt} other{{marks} pts}}" + the "Guardian: {name}"
  + the "Resolve student: {error}" interpolations are
  all wired to ICU plurals. The mobile is now fully
  locale-aware (en + ar, with 6 ICU plural categories
  for Arabic) end-to-end across every per-role home +
  every detail / create / capture / attempt surface.
  The hardening pass verified no
  `MediaQuery.platformBrightnessOf` call sites (only
  doc comments), no `EdgeInsets.only(left/right:)`
  survivors, no `Icons.chevron_left/right` without
  `Directionality.of(context)` guarding, and no
  `hasCapability('(student|staff|guardian|academics|attendance).read')`
  shorthand.

### Added

- **Admin "Grading" surface — read-only overview + policies.**

### Added

- **Admin "Grading" surface — read-only overview + policies.**
  Closes roadmap #8 for the grading slice. New files:
  - `lib/features/grading/data/grading_overview.dart` —
    typed `GradingOverview`, `SubjectGradePolicy`,
    `SubjectGradePolicyPage`, `GradingPolicySetupContext`,
    and `GradingWorkflowStage` models. `GradingOverview`
    flattens the operations + overview-context endpoints
    into a single typed model (total / published / draft
    / average / pass rate + coverage + feature + recent
    students + workflow stages). The wire field names
    are forward-compatibly parsed (canonical `total_grades`
    / `school_subject` / `grade_band` AND legacy `total` /
    `subject` / `band`). `GradingWorkflowStage.stageFamily`
    maps the wire stage name to a coarse family
    (draft / submitted / promoted / corrected / rejected /
    other) for the chip icon; `toneFamily` exposes the
    server-defined tone as a string for the UI to map.
    `GradingOverview.passRatePercent` returns null when
    no grades are published (avoids the "0% pass on a
    fresh school" lie).
  - `lib/features/grading/data/grading_failure.dart` —
    typed `GradingFailure` mirroring `FeesFailure` /
    `OperationsFailure` / `GovernanceFailure`.
  - `lib/features/grading/data/grading_repository.dart` —
    wraps the v1 endpoints `get_grading_overview_context`,
    `get_school_grading_operations_overview`,
    `get_school_subject_grade_policies`, and
    `get_grading_policy_setup_context` with the canonical
    `Result<T, E>` + `_failureFromApi` + `_exceptionFailure`
    pattern. The overview fetch fires the two endpoints
    in parallel and merges the results.
  - `lib/features/grading/data/grading_providers.dart` —
    `gradingRepositoryProvider` +
    `gradingOverviewProvider` +
    `gradingPolicySetupContextProvider` +
    `GradingPoliciesController` (the policies tab's
    combined view-model that fetches the policy list +
    the setup context in parallel and exposes them
    together).
  - `lib/features/grading/ui/grading_screen.dart` — the
    two-tab surface (Overview / Policies). The Overview
    tab renders the four headline KPIs (total / published
    / draft / average) as a 2x2 / 4-up responsive grid
    with status colors, then the workflow stages as a
    chip strip (success / warning / error / info / brand
    tones), then a feature / coverage / recent-students
    card for the support team to identify the version.
    The Policies tab renders the permissions card
    (managed-doctypes + read roles + required roles as
    separate chip strips) at the top, then the list of
    subject grade policies (subject / grade band / pass
    threshold / status chip with tone per family).
    Every user-facing string is locale-aware via
    `AppLocalizations.of(context)`. The chevron mirrors
    itself under RTL.
  - `test/features/grading/grading_repository_test.dart` —
    7 tests pinning the parse (canonical + legacy wire
    keys, the merged overview fetch, the null pass rate
    on a fresh school, the typed-failure path, the
    EMPTY_RESPONSE path, the policy setup context, the
    workflow stage family mapping).
  - **~25 new ARB keys** for the grading surface (screen
    title, tabs, loading / error / KPI labels + sub-titles,
    workflow header, feature / coverage / recent-students
    sub-lines, pass-threshold chip, permissions card
    headers + role labels) in both `app_en.arb` (English
    source) and `app_ar.arb` (Modern Standard Arabic).
- **"Grading" tile** on the admin dashboard,
  capability-gated on `can_manage_branches` (admin-only
  on the v1 wire; the v1 server does not yet expose a
  dedicated `can_view_grading` capability — see the
  audit's §4 follow-up for the future hardening).

### Changed

- `lib/app/router.dart` — added the `/shell/grading`
  route inside the existing `ShellRoute` so it keeps
  the chrome + the bottom nav.
- `lib/app/dashboard_screen.dart` — the admin
  quick-start now conditionally renders the "Grading"
  tile when the user can manage branches.

### Tests

- 7 new grading repository tests. Total test count:
  **126 passed, 5 pre-existing failures** (2 in
  `test/platform/transport_test.dart`, 3 in the user's
  in-flight `test/features/assessment/current_student_provider_test.dart`).

## [Unreleased]

### Added

- **Admin "Governance" surface — read-only privacy requests

### Added

- **Admin "Governance" surface — read-only privacy requests
  queue with per-row approve / process / set-legal-hold
  actions.** Closes roadmap #8 for the privacy slice. New
  files:
  - `lib/features/governance/data/governance_request.dart` —
    typed `PrivacyRequest`, `PrivacyRequestPage`, and
    `PrivacyRequestTimeline` models. `PrivacyRequest`
    parses the v1 envelope forward-compatibly (canonical
    `school_student` / `request_type` AND legacy
    `subject` / `type`). `PrivacyRequest.statusFamily`
    maps the wire status to a coarse family (pending /
    review / approved / rejected / hold / other) for the
    chip tone. `PrivacyRequest.typeFamily` maps the wire
    type to a coarse family (access / deletion / consent
    / legal_hold / governance / other) for the row icon.
  - `lib/features/governance/data/governance_failure.dart` —
    typed `GovernanceFailure` mirroring `FeesFailure` /
    `OperationsFailure`.
  - `lib/features/governance/data/governance_repository.dart` —
    wraps the v1 read endpoint
    `get_school_privacy_requests` and the write endpoints
    `approve_school_privacy_request`,
    `process_school_privacy_request`,
    `set_school_privacy_legal_hold`, and
    `evaluate_school_data_retention`. Each write mints
    a fresh UUID for the `Idempotency-Key` header.
  - `lib/features/governance/data/governance_providers.dart` —
    `governanceRepositoryProvider` +
    `PrivacyRequestsController` (with manual `refresh`) +
    four top-level helpers (`approvePrivacyRequest` /
    `processPrivacyRequest` / `setPrivacyLegalHold` /
    `evaluateRetention`) that take a `WidgetRef` and
    invalidate `privacyRequestsProvider` on success so
    the list re-fetches the latest state.
  - `lib/features/governance/ui/governance_screen.dart` —
    the read-only privacy requests queue + per-row
    action sheet. The list groups rows by lifecycle
    status (chip strip with success / warning / error /
    info / brand tones) and renders each row with a 44dp
    icon (the request-type family) + subject name + id
    + status chip + type chip + legal-hold chip + the
    requester's email + submitted-at sub-line. Tapping
    a row opens a modal bottom sheet with the per-row
    actions (Mark in review / Approve / Set hold /
    Release hold). All four actions are write flows;
    success shows a success-toned snackbar and closes
    the sheet; failure renders the typed error message
    inline.
  - `test/features/governance/governance_repository_test.dart` —
    7 tests pinning the parse (canonical + legacy wire
    keys), the wire-error path, the
    `approve_school_privacy_request` payload forwarding
    (request name + reason), the
    `set_school_privacy_legal_hold` payload forwarding
    (request name + hold + reason), the status-family
    mapping, and the type-family mapping.
  - **~15 new ARB keys** for the governance surface
    (screen title, loading / error / empty / queue
    header, status strip, action sheet, per-action
    labels + descriptions, retention snackbar copy) in
    both `app_en.arb` (English source) and `app_ar.arb`
    (Modern Standard Arabic, with the six ICU plural
    categories where the strings carry counts).
- **"Governance" tile** on the admin dashboard,
  capability-gated on `can_manage_branches` (admin-only
  on the v1 wire; the v1 server does not yet expose a
  dedicated `can_view_governance` capability — see the
  audit's §4 follow-up for the future hardening).

### Changed

- `lib/app/router.dart` — added the `/shell/governance`
  route inside the existing `ShellRoute` so it keeps
  the chrome + the bottom nav.
- `lib/app/dashboard_screen.dart` — the admin
  quick-start now conditionally renders the "Governance"
  tile when the user can manage branches.

### Tests

- 7 new governance repository tests (full coverage of the
  parse, the wire-error path, the write payload forwarding,
  and the family mapping). Total test count:
  **119 passed, 5 pre-existing failures** (2 in
  `test/platform/transport_test.dart`, 3 in the user's
  in-flight `test/features/assessment/current_student_provider_test.dart`).

## [Unreleased]

### Added

- **Admin "Operations" surface — read-only operations health +
  delivery health + auth audit events.** Closes roadmap #9

### Added

- **Admin "Operations" surface — read-only operations health +
  delivery health + auth audit events.** Closes roadmap #9
  for the operations slice. New files:
  - `lib/features/operations/data/operations_health.dart` —
    typed `OperationsHealth`, `DeliveryHealth`, and
    `AuthAuditEvent` models that parse the v1 envelope
    forward-compatibly (canonical keys AND the legacy
    `event` / `user_email` / `ip` aliases). `OperationsHealth`
    flattens the per-module KPI maps (`analytics` /
    `audit` / `delivery` / `imports` / `outbox`) into a
    single list of (module, key, value) triples for the
    on-screen grid. `DeliveryHealth.sortedCounts()` returns
    the per-status counts sorted by count (descending)
    for the bar chart. `AuthAuditEvent.family` maps the
    wire event type to a coarse family (login / logout /
    token_refresh / device_register / other) for the chip
    tone.
  - `lib/features/operations/data/operations_failure.dart` —
    typed `OperationsFailure` mirroring `FeesFailure` /
    `FamilyFailure` so a future "replay" / "approve
    privacy" / "set legal hold" write flow can drop in
    without a model change.
  - `lib/features/operations/data/operations_repository.dart` —
    wraps the v1 endpoints `get_school_operations_health`,
    `get_school_delivery_health`, and
    `get_school_auth_audit_events` with the canonical
    Result<T, E> + `_failureFromApi` + `_exceptionFailure`
    pattern.
  - `lib/features/operations/data/operations_providers.dart` —
    `operationsRepositoryProvider` +
    `operationsHealthProvider` +
    `deliveryHealthProvider` +
    `authAuditEventsController` (with manual `refresh`).
  - `lib/features/operations/ui/operations_health_screen.dart` —
    the three-tab surface (Health / Delivery / Audit).
    Every user-facing string is locale-aware via
    `AppLocalizations.of(context)`. The Health tab renders
    the top-level status as a colored chip +
    "Generated at {timestamp}" sub-line + the per-module
    KPI grid (each tile humanizes the wire key from
    `last_30d_failed` → `Last 30D Failed`). The Delivery
    tab renders the per-status counts as a stacked bar +
    per-status chips with color tones (success for
    completed / delivered, warning for pending / retry,
    error for failed / dead / dropped). The Audit tab
    renders each event with a 44dp icon + user +
    timestamp + source IP.
  - `test/features/operations/operations_repository_test.dart` —
    8 tests pinning the parse (per-module KPI flattening,
    per-status count sort, event type → family mapping),
    the EMPTY_RESPONSE path, the typed-error path, and
    the limit-query forwarding.
  - **~20 new ARB keys** for the operations surface
    (titles, tabs, status labels, module labels, empty
    states) in both `app_en.arb` (English source) and
    `app_ar.arb` (Modern Standard Arabic).
- **"Operations" tile** on the admin dashboard,
  capability-gated on `can_manage_branches` (the v1
  server does not yet expose a `can_view_operations`
  capability; the operations surface is admin-only by
  intent and `can_manage_branches` is already admin-only
  on the wire — see the audit's §4 follow-up for the
  future hardening).

### Changed

- `lib/app/router.dart` — added the `/shell/operations`
  route inside the existing `ShellRoute` so it keeps
  the chrome + the bottom nav.
- `lib/app/dashboard_screen.dart` — the admin
  quick-start now conditionally renders the "Operations"
  tile when the user can manage branches.

### Tests

- 8 new operations repository tests (full coverage of the
  parse, the empty / error paths, and the family mapping).
  Total test count: **112 passed, 5 pre-existing failures**
  (2 in `test/platform/transport_test.dart`, 3 in the
  user's in-flight `test/features/assessment/current_student_provider_test.dart`).

## [Unreleased]

### Added

- **Arabic + English locale support.** The mobile now supports
  both `en` and `ar` via the standard Flutter ARB-driven

### Added

- **Home + admin + family + child-detail + picker + classes +
  fees surfaces fully localized.** Closes the "home surface
  string extraction" half of roadmap #11. Every user-facing
  string on:
  * the role-routed home surfaces (parent / student / teacher /
    admin dashboard),
  * the family picker (`/shell/family`),
  * the per-child detail (`/shell/family/:id` and the
    student "My records" route),
  * the "Switch student" picker (`/shell/me/switch-student`),
  * the teacher "My classes" list + per-class detail, and
  * the read-only fees surfaces (fee plans list + per-plan
    detail + admin "Fee operations" overview)
  is now locale-aware via `AppLocalizations.of(context)`. ~80
  new ARB keys added to both `app_en.arb` (English source)
  and `app_ar.arb` (Modern Standard Arabic, with proper
  six-category ICU plurals where the strings carry counts).
- **RTL pass on every list tile + AppBar.** The literal
  `right: -2` on the notification badge dot was replaced with
  `Positioned.directional(textDirection: Directionality.of(context), end: -2)`
  so the badge stays in the top-trailing corner under both
  LTR and RTL. The literal `Icons.chevron_right` in every list
  row was replaced with a conditional per
  `Directionality.of(context) == TextDirection.rtl`. The
  AppBar date's literal `EdgeInsets.only(right:)` is now
  `EdgeInsetsDirectional.only(end:)` so the date hugs the
  trailing edge in both directions. The "Switch student" /
  "Refresh" / "Notifications" icon buttons all carry localized
  `tooltip:` strings via `commonRefresh` / `a11yNotificationsTooltip` /
  `a11ySwitchStudentTooltip`.

### Changed

- `lib/app/dashboard_screen.dart` — every hardcoded string
  in the admin quick-start grid (titles + descriptions +
  tooltips + the "Acting as" / "Resolving student" / "No
  student resolved" / "Student resolution failed" sub-states)
  is now locale-aware. The role chip uses
  `l.homeAdminSignedInAs(role.wire)`. The chevron in
  `_QuickCard` mirrors itself under RTL. `Semantics(button:
  true, label: item.label)` wraps the tile so screen readers
  announce the right thing.
- `lib/app/parent_home.dart` + `lib/app/student_home.dart` +
  `lib/app/teacher_home.dart` — every string already migrated
  to ARB in the prior turn; the chevron fix + a11y wrap
  (`Semantics(button: !disabled, label: title)` on the
  student `_SurfaceTile`) lands here.
- `lib/features/family/ui/family_home_screen.dart` — full
  localization pass: app-bar title, refresh tooltip, loading
  / error / empty copy, "as {relation}" / "ID {code}" rows,
  "Active" chip label. Chevron mirrors under RTL.
  `Semantics(button: true, label: member.studentName)` wraps
  the row.
- `lib/features/family/ui/child_detail_screen.dart` — full
  localization pass: app-bar title (own vs other voice), the
  four tab labels, the overview summary + KPI sub-lines (all
  six KPIs + the "All passed" / "X of Y passed" / "On track"
  / "Below target" / "No grades yet" / "No absences" / "X
  present · Y absent" / "No cards yet" / "Latest: …"
  variants), the grades / attendance / report-cards empty
  states, the grade row's "Assessment" / "Pass" / "Fail" /
  "Published {date}" copy, and the report-card row's fallback
  title + "Published {date}" copy.
- `lib/features/me/ui/acting_as_picker_screen.dart` — full
  localization pass: app-bar title, search placeholder, all
  four state paths (loading / error / empty-roster / no-
  results), the "Now acting as {name}" snackbar copy, the
  "Clear search" action label, the row's "Current" chip, the
  "ID {code}" subtitle, and the chevron mirror.
- `lib/features/teachers/ui/my_classes_screen.dart` +
  `lib/features/teachers/ui/class_detail_screen.dart` — full
  localization pass: app-bar title, refresh tooltip, loading
  / error / empty copy, the "Academic year {year}" sub-line,
  the "Homeroom" chip, the "{count, plural, … student(s)}"
  pill on the class detail, and the chevron mirror.
- `lib/features/fees/ui/fee_plans_screen.dart` +
  `lib/features/fees/ui/fee_plan_detail_screen.dart` +
  `lib/features/fees/ui/fee_operations_overview_screen.dart`
  — full localization pass: app-bar titles, refresh tooltips,
  loading / error / empty / not-found copy, the
  "{currency} {total} total · outstanding {currency}
  {outstanding}" amount line, the "{count, plural, … overdue}"
  / "partial" / "paid" status chips, the per-status
  breakdown chips on the operations screen, the "View fee
  plans" CTA, and the "Back to fee plans" not-found action.
  All three surfaces carry chevron mirrors + a11y `Semantics`
  wrappers.

### Tests

- `test/l10n/locale_test.dart` — expanded from 6 to 11 tests:
  * `English home + admin surfaces resolve the right keys`
    pins the exact English strings for the dashboard,
    parent / student / teacher home surfaces, the family
    picker, the "Acting as" + "Resolving student" copies.
  * `Arabic home + admin surfaces are non-empty + non-English`
    guards the "I forgot to translate" regression by
    asserting every new key under `ar` is both non-empty
    AND not equal to the English source.
  * `English pluralization rules behave correctly (0 / 1 / 2 / 5)`
    pins the singular / plural / zero shapes for
    `homeParentLinkedChildren`, `a11yUnreadNotifications`,
    `feePlansHeaderTotal`, `classDetailStudentCount`.
  * `Arabic pluralization rules behave correctly across the
    six ICU categories (zero / one / two / few / many /
    other)` asserts the Arabic strings resolve to non-empty
    values for counts 0, 1, 2, 5, 25, 101 — the six ICU
    plural categories Arabic uses — and are not equal to the
    English fallbacks.
  * `English family + picker + class detail copy is present`
    pins the new family / picker / class-detail strings.

## [Unreleased]

### Added

- **Arabic + English locale support.** The mobile now supports
  both `en` and `ar` via the standard Flutter ARB-driven

### Added

- **Arabic + English locale support.** The mobile now supports
  both `en` and `ar` via the standard Flutter ARB-driven
  localization pipeline. The `MaterialApp` resolves the locale
  from `supportedLocales` + the global delegates + the
  generated `AppLocalizations.delegate`. New files:
  - `l10n.yaml` — Flutter localization config.
  - `lib/l10n/app_en.arb` (English source) +
    `lib/l10n/app_ar.arb` (Modern Standard Arabic).
  - `lib/l10n/app_localizations.dart` + per-locale generated
    files (regenerated on every `flutter pub get`).
  - `test/l10n/locale_test.dart` — 6 tests pinning the
    locale pipeline (supported locales, English + Arabic
    non-empty strings, bottom-nav tab resolution per locale).

### Changed

- `pubspec.yaml` — `flutter: generate: true` so the `gen-l10n`
  step runs automatically on every `flutter pub get`.
- `lib/app/app.dart` — `MaterialApp` now uses
  `onGenerateTitle: (context) => AppLocalizations.of(context).appTitle`
  and `supportedLocales: AppLocalizations.supportedLocales`.
- `lib/app/router.dart` — `ShellTabX.labelFor(BuildContext)`
  resolves the right tab label per locale; the `_ShellScaffold`
  calls it when building the `NavigationDestination`s so a
  runtime locale switch updates the bottom nav in the next
  frame.

### Scope notes

The locale framework is in place and the bottom-nav tabs are
fully localized. The home surfaces (parent / student / teacher
/ admin dashboard) + the family / classes / child-detail /
fee-plans surfaces still carry ~150 hardcoded English strings
— the per-screen surface text + state-view titles + KPI
labels. The extraction is mechanical and lands in the next
turn, alongside the RTL-aware layout pass + a11y audit
(both also deferred per the audit's "next turn" note on
roadmap #11).

## [Unreleased]

### Added

- **Fees surface — read-only "Fee plans" + per-plan detail +
  admin "Fee operations" KPI overview.** Closes roadmap item
  #7 for the admin side and item #11 for the parent side
  ("Fee invoices for my children"). New files:
  - `lib/features/fees/data/fee_plan.dart` — typed `FeePlan`
    model that parses the v1 envelope forward-compatibly
    (canonical `school_student` / `total_amount` /
    `invoice_status` AND legacy `student` / `total` /
    `status`); preserves the `FeePlanItem` list for the
    detail breakdown. Also `FeeOperationsOverview` with
    `collectionRate` (null when total invoiced is zero — the
    "0% collected" lie on a fresh school is gone).
  - `lib/features/fees/data/fees_failure.dart` — typed
    failure mirroring `PersonFailure`.
  - `lib/features/fees/data/fees_repository.dart` — wraps
    `get_school_student_fee_plans` + `get_school_fee_operations_overview`.
  - `lib/features/fees/data/fees_providers.dart` —
    `feesRepositoryProvider` + `FeePlansController` +
    `feeOperationsOverviewProvider` (year-keyed family for
    a future per-year filter) + `feePlanDetailProvider`.
  - `lib/features/fees/ui/fee_plans_screen.dart` — list of
    fee plans with overdue / partial / paid status chips,
    per-row avatar, paid rows faded. Sorted overdue +
    partial + issued first, then draft + paid + cancelled.
  - `lib/features/fees/ui/fee_plan_detail_screen.dart` —
    identity card + per-line breakdown (Total / Paid /
    Outstanding totals + items list).
  - `lib/features/fees/ui/fee_operations_overview_screen.dart`
    — admin KPI card with collection rate + invoiced /
    collected / outstanding totals + status counts.
  - `test/features/fees/fees_repository_test.dart` — 7
    tests pinning the parse, legacy wire keys
    (`student`, `total`, `status`, `paid`, `outstanding`,
    `fee_components`), the EMPTY_RESPONSE path, the
    collection-rate math, and the null-on-zero-invoiced
    safety.

- **"Fee plans" + "Fee operations" tiles** on the admin
  dashboard, capability-gated on `can_view_fees`. A
  registrator without that capability won't see the tiles
  and the bottom-nav tab stays hidden.
- **"Fee invoices" tile** on the parent home,
  capability-gated on `can_view_fees`. Today the v1
  capability map doesn't grant `can_view_fees` to
  parents, so the tile stays hidden for them; when the
  backend grows a `can_view_own_fees` capability the tile
  will appear without a model change.

### Changed

- `lib/app/router.dart` — added the new `fees` tab to
  `ShellTab` (capability-gated on `can_view_fees`); added
  the `/shell/fees/plans` + `/shell/fees/plans/:id` +
  `/shell/fees/operations` routes. Updated the
  `ShellTab` doc comment to note the enum now carries 7
  entries (the Laratik UI rules prefer 5 for legibility;
  the capability + role gates typically leave a user with
  3-6 visible tabs).
- `lib/app/dashboard_screen.dart` — admin quick-start
  now conditionally renders the "Fee plans" + "Fee
  operations" tiles when the user has `can_view_fees`.
- `lib/app/parent_home.dart` — added the capability-gated
  "Fee invoices" tile for parents (hidden today; see
  above for the `can_view_own_fees` follow-up).

## [Unreleased]

### Added

- **Teacher surface — "My classes" + per-class detail.** The
  teacher role now lands on a dedicated home (instead of the
  registrar's "Quick start") and gets a real "My classes" tab in
  the bottom nav. New files:
  - `lib/features/teachers/data/teaching_assignment.dart` —
    typed model that parses the v1 envelope forward-compatibly
    (canonical `school_staff` / `school_class_group` /
    `subject_name` AND legacy `staff` / `class_group` / `subject`).
  - `lib/features/teachers/data/teachers_failure.dart` — typed
    failure mirroring `PersonFailure`.
  - `lib/features/teachers/data/teachers_repository.dart` —
    wraps `get_school_teaching_assignments`.
  - `lib/features/teachers/data/teachers_providers.dart` —
    repository + `MyClassesController` + `classRosterProvider`
    (family-scoped, filters `get_school_students` by
    `classGroupId`).
  - `lib/features/teachers/ui/my_classes_screen.dart` — list of
    assignments with active-first ordering, "Homeroom" chip on
    primary assignments, per-class subject chip.
  - `lib/features/teachers/ui/class_detail_screen.dart` — class
    identity card + student roster (read-only).
  - `lib/app/teacher_home.dart` — teacher home with a hero
    "My classes" tile (live count from `myClassesProvider`) +
    attendance + notifications tiles.
  - `test/features/teachers/teachers_repository_test.dart` — 5
    tests pinning the parse, legacy wire keys, EMPTY_RESPONSE
    path, and `isPrimary` (1/0 int + bool) handling.

- **Bottom nav fixed (pre-existing bug).** Every `ShellTab`'s
  `requiredCapability` now uses the canonical v1 wire name
  (`can_view_students`, `can_view_staff`, etc.) — the previous
  shorthand (`student.read`, `staff.read`, …) never matched
  the wire so the nav was silently empty for every role. See
  `docs/bug-log.md` 2026-08-03.

### Fixed

- **Bottom nav was silently empty.** Updated every `ShellTab`'s
  `requiredCapability` to the canonical v1 wire name
  (`can_view_students`, `can_view_staff`, `can_view_guardians`,
  `can_view_academics`). The previous shorthand names did not
  match the wire shape returned by `get_permission_context`, so
  every `hasCapability` lookup returned `false` and the shell
  fell through to the bare home dashboard for every role.
  Documented in `docs/bug-log.md` 2026-08-03.

### Changed

- `lib/app/router.dart` — added the `myClasses` tab with
  optional `role: 'teacher'` gate so it only shows for the
  teacher role (the v1 server has no
  `can_view_teaching_assignments` capability, so role-gating
  is the honest way to keep the teacher-only tab off the
  registrar's chrome). Added the new route
  `/shell/teachers/classes` + `/shell/teachers/classes/:id`.
  Shell filtering now reads the active role's primary role and
  applies the `role` gate before the capability check.
- `lib/app/dashboard_screen.dart` — `LaratikRole.teacher` now
  routes to `TeacherHomeScreen` (was previously routed to the
  registrar's `_AdminHomeScreen`).

## [Unreleased]

### Added

- **"Switch student" picker** at `/shell/me/switch-student`. The
  registrar / teacher / parent-operator who is reviewing a
  specific student's record now has a real way to change which
  student the mobile is "acting as" — full-screen picker with
  debounced search, avatar + name + student number per row, and
  a "Current" chip on the currently-acting student. Selection
  persists via `SessionStore.setCurrentStudent` and invalidates
  `currentStudentProvider` so the dashboard + student home
  re-render the new name on next frame. The picker's choice is
  deep-linkable and reachable from a new "Switch" icon button
  on the "Acting as" card in both the student home and the
  registrar dashboard.
- `lib/features/me/ui/acting_as_picker_screen.dart` — the
  picker widget.
- `lib/features/people/data/filter_options.dart` — the pure
  `deriveFilterOptions(people)` helper that the Students list
  now uses to populate its grade + class-group filter chips
  from the loaded roster (replacing the hard-coded
  `['Grade 1', 'Grade 2', ...]` and `['A', 'B', 'C', 'D']`
  that used to lie to the operator when the school uses a
  different naming scheme).
- `test/features/people/filter_options_test.dart` — 5 tests
  pinning the derivation logic (empty input, de-dup, case-
  insensitive sort, alternative catalog names like "Year 1" /
  "KG-2", null / empty grade / class-group handling).

### Changed

- `lib/features/people/ui/students_list_screen.dart` — the
  grade + class-group filter chips are now derived from the
  loaded students via `deriveFilterOptions(people)`, not
  hard-coded. When the student list is empty the chips render
  in a disabled state (taps are no-ops) instead of opening a
  bottom sheet of phantom options. Backend follow-up: add
  `get_school_grades` and `get_school_class_groups` so the
  mobile can pre-populate the chips without waiting for a
  student list.
- `lib/app/dashboard_screen.dart` + `lib/app/student_home.dart`
  — both `_ActingAsCard` widgets now expose a "Switch student"
  icon button that deep-links to `/shell/me/switch-student`.
- `lib/app/router.dart` — added the new route inside the
  existing `ShellRoute` so it keeps the chrome and the bottom
  nav.

## [Unreleased]

### Added

- **Family surface — parent "my children" + per-child detail.** The
  parent role can now pick from the children they're linked to as a
  guardian and drill into a per-child detail screen with four tabs:
  Overview (KPI summary), Grades (score bars + pass/fail chips),
  Attendance (date list + status chips), and Report cards (term
  summaries with average score). New files:
  - `lib/features/family/data/family_failure.dart` — typed failure
    mirroring `PersonFailure` so the rest of the app can swap
    surfaces without learning a new error contract.
  - `lib/features/family/data/family_repository.dart` — wraps
    `get_school_guardians`, `get_school_grade_records`,
    `get_school_attendance_records`, `get_school_report_cards`.
    Flattens the guardian link table into de-duplicated
    [FamilyMember]s (active wins over withdrawn duplicates) and
    filters the three record-list APIs client-side by `school_student`
    because the v1 SDK does not accept that filter on the wire.
  - `lib/features/family/data/family_providers.dart` — repository
    provider + `FamilyListController` (async notifier) +
    `childRecordsProvider` (family FutureProvider).
  - `lib/features/family/ui/family_home_screen.dart` — parent
    picker. Hero "My children" card on the parent home now reflects
    the live count from the family list.
  - `lib/features/family/ui/child_detail_screen.dart` — reusable
    detail surface used by both the parent deep link
    (`/shell/family/:studentId`) and the student "My records" route
    (`/shell/me/records`); `isOwnRecords` flag toggles the label
    voice and the overview sub-text.
  - `test/features/family/family_repository_test.dart` — 11 tests
    pinning the dedup logic, client-side student filter, the
    "first failure short-circuits the rest" path, and
    `FamilyFailure.isRetryable` classification.

- **Student "My records" surface.** The student home replaces the
  "next release" placeholder with a real "My records" tile that
  opens `ChildDetailScreen` for the active student (resolved via
  `currentStudentProvider`). The tile stays disabled with a
  "Resolving student…" sub-line while the provider is still
  loading.

- **New routes.** `/shell/family` (parent picker),
  `/shell/family/:studentId` (parent child detail),
  `/shell/me/records` (student own records). All three are deep-
  linkable, work even when the bottom-nav tab is hidden, and live
  inside the existing `ShellRoute` so they keep the chrome.

### Changed

- `lib/app/parent_home.dart` — replaced the "next release"
  placeholder with a real hero "My children" card that surfaces
  the live count from `familyListProvider` and the inbox card.
  The picker lives at `/shell/family` (deep linkable).
- `lib/app/student_home.dart` — added the "My records" tile and
  removed the dead `_FutureSurfaceCard` widget. `_SurfaceTile`
  now accepts a nullable `onTap` and renders a calm disabled
  state with `Semantics(button: false)` when the parent can't
  enable it.
- `lib/app/router.dart` — added the three new routes + a
  `_StudentRecordsRoute` resolver widget that reads
  `currentStudentProvider` and falls back to a friendly "no
  student resolved" state when the provider has not loaded.

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
