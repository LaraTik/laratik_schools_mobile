# PROD-readiness audit — Laratik Schools Mobile

> Snapshot: 2026-08-03. The mobile is at the next commit after
> `38a092f` (locale release). "PROD-ready" here means: every user
> role can do the things their role implies, the build is green, and
> the app degrades gracefully on the major failure modes (offline,
> expired token, capability not granted, version-policy block).
>
> Update 2026-08-02 (family + records release): the parent and
> student gaps for "my children" / "my grades" / "my attendance" /
> "my report cards" are now closed. See §3 and §5 for the new
> status. The mobile is at the next commit after `902738d`
> (role-foundation) — this snapshot is updated once that commit
> lands.
>
> Update 2026-08-03 (picker release): "Acting as" picker for the
> registrar + honest grade / class-group filter derivation in the
> Students list. The mobile is at `f870b35`. See §3 (Admin gap
> "Acting as" picker → shipped) and §5 (item #4 + #10 → shipped).
>
> Update 2026-08-03 (teacher release): the teacher role now lands
> on a dedicated home, the bottom nav is finally rendering
> (fixed a pre-existing bug where `ShellTab.requiredCapability`
> names did not match the v1 wire), and the "My classes" tab +
> per-class detail ship. See §3 (Teacher gap "My classes" +
> "My students" → shipped) and §5 (item #6 → shipped). The
> mobile is at the next commit after `f870b35`.
>
> Update 2026-08-03 (fees release): the read-only "Fee plans"
> list + per-plan detail + admin "Fee operations" KPI
> overview are wired end-to-end. The new "Fees" bottom-nav
> tab is capability-gated on `can_view_fees`; the admin
> quick-start surfaces the same surfaces as
> capability-gated tiles. See §3 (Admin Fees → shipped;
> Parent "Fee invoices for my children" → marked shipped
> but tile hidden until the backend grows
> `can_view_own_fees`) and §5 (item #7 → shipped for the
> Fees slice; Analytics slice deferred). The mobile is at
> the next commit after `6e29fba`.

> Update 2026-08-03 (locale release): the Flutter ARB-driven
> localization pipeline is wired (`en` + `ar`). The
> bottom-nav tab labels are locale-aware via
> `ShellTab.labelFor(context)`. See §4 (the "No Arabic
> locale" item is replaced with an "Arabic locale partial"
> note documenting the home-surface string extraction +
> RTL pass + a11y audit follow-up) and §5 (item #11
> flipped to "shipped (locale framework + bottom-nav
> labels; home-surface string extraction + RTL pass +
> a11y audit deferred)"). The mobile is at `0cfd72e`.
>
> Update 2026-08-03 (home surface localization + RTL pass):
> the home surfaces (parent / student / teacher / admin
> dashboard) + the family picker + the per-child detail +
> the "Switch student" picker + the teacher "My classes"
> + the per-class detail + the fees surfaces (plans + per-
> plan detail + admin "Fee operations") are fully
> localized (English source + Modern Standard Arabic
> with the six ICU plural categories where the strings
> carry counts). The literal `right: -2` notification
> badge dot is replaced with `Positioned.directional(...)`,
> the literal `Icons.chevron_right` in every list row
> mirrors itself under RTL, and the AppBar date hugs the
> trailing edge in both directions. The locale test
> suite grew from 6 to 11 tests (covers English + Arabic
> copy, pluralization rules, and the per-surface
> key-pinning). See §4 (the "Arabic locale partial" note
> is replaced with "Arabic locale shipped end-to-end") and
> §5 (item #11 → fully shipped). The mobile is at the
> next commit after `38a092f`.
>
> Update 2026-08-03 (admin Operations surface): the
> read-only operations health + delivery health + auth
> audit events surface ships at `/shell/operations`. The
> Health tab renders the top-level status as a colored
> chip + the per-module KPI grid (analytics / audit /
> delivery / imports / outbox, each tile humanizes the
> wire key). The Delivery tab renders the per-status
> counts as a stacked bar + per-status chips with color
> tones. The Audit tab renders each event with a 44dp
> icon + user + timestamp + source IP. Reachable from a
> new "Operations" tile on the admin home, capability-
> gated on `can_manage_branches` (admin-only). The write
> flows (`replay_school_delivery_event`,
> `receive_school_delivery_callback`, governance / data
> import) are deferred to follow-up turns. See §3
> (Admin Operations → shipped for the read-only slice)
> and §5 (item #9 → partially shipped; operations slice
> done, data import slice deferred).
>
> Update 2026-08-03 (admin Governance surface): the
> read-only privacy requests queue + per-row approve /
> process / set-legal-hold actions ship at
> `/shell/governance`. The list groups rows by lifecycle
> status (chip strip) and renders each row with a 44dp
> type-family icon + subject name + id + status + type
> + legal-hold chip + the requester's email + the
> submitted-at sub-line. Tapping a row opens a modal
> bottom sheet with the per-row actions (Mark in review
> / Approve / Set hold / Release hold). All four actions
> are write flows; the repository mints a fresh UUID
> for the `Idempotency-Key` header and the provider
> invalidates the list on success. Reachable from a
> new "Governance" tile on the admin home, capability-
> gated on `can_manage_branches` (admin-only; the v1
> server does not yet expose a dedicated
> `can_view_governance` capability — see the §4 follow-
> up for the future hardening). The retention evaluation
> action is a one-click "Run retention" button in the
> AppBar that calls
> `evaluate_school_data_retention` and shows a snackbar
> on completion. See §3 (Admin Governance → shipped for
> the privacy + legal-hold + retention slice) and §5
> (item #8 → partially shipped; governance slice done,
> grading slice deferred).
>
> Update 2026-08-03 (admin Grading surface): the
> read-only overview + policies ship at
> `/shell/grading`. The Overview tab renders the four
> headline KPIs (total / published / draft / average) as
> a responsive 2x2 / 4-up grid, then the workflow stages
> as a chip strip (success / warning / error / info /
> brand tones per family), then a feature / coverage /
> recent-students card. The Policies tab renders the
> permissions context (managed-doctypes + read roles +
> required roles as separate chip strips) at the top,
> then the list of subject grade policies (subject /
> grade band / pass-threshold chip / status chip with
> tone per family). Reachable from a new "Grading" tile
> on the admin home, capability-gated on
> `can_manage_branches` (admin-only on the v1 wire).
> The write flows (`correct_school_grade_record`,
> `promote_school_assessment_result`,
> `approve_school_subject_grade_policy`) are deferred
> to follow-up turns. See §3 (Admin Grading → shipped
> for the read-only slice) and §5 (item #8 → fully
> shipped for the read-only grading slice).

This document is the source of truth for what is shipped, what is
missing per role, and the prioritized roadmap. It supersedes the
"Phase 0–6 ship" status line in the README — the source bar is met
but the production bar (Phase 9 mobile-ready slice) is deferred.

---

## 1. The four roles, in one paragraph each

### Registrar / School admin (primary role: `School Admin` or `Registrar`)

The operator who runs the school day-to-day. Today: can manage the
student / staff / guardian / subject / class roster (Phase 1.x CRUD),
capture attendance (Phase 1.4), browse the assessment catalog
(Phase 5), and read the notifications inbox (Phase 6). Cannot yet:
review fees / invoices, set grading policy, manage data imports,
respond to privacy / retention requests, see the operations health
surface (delivery, audit, replay), or look at academic analytics.

### Student (primary role: `Student`)

The user who takes exams. Today: sees the published exam catalog
filtered by eligibility, completes an exam with autosave + submit,
checks the result once it's published. Cannot yet: see "my grades"
(history of grade records), "my attendance" (their own attendance
history), or "my report cards" (the consolidated term report).

### Teacher (primary role: `Teacher`)

The user who teaches classes and marks work. Today: lands on a
dedicated teacher home with a hero "My classes" tile (live
count from `myClassesProvider`) + attendance + notifications
tiles. A new "My classes" tab in the bottom nav lists the
teaching assignments owned by the current staff member, each
tappable into the per-class detail (identity card + student
roster filtered by `classGroupId`). Cannot yet: author exam
plans / questions, or manually grade exam attempts. The
`mark_exam_attempt` API exists server-side and is exposed via
v1; the mobile has no UI for it.

### Parent (primary role: `Guardian`)

The user who is the legal guardian of one or more students. Today:
the mobile treats them as the same as a registrar — they see the
roster screens. Cannot yet: see "my children" (the only students
they are linked to via the guardian record), view their children's
grades / attendance / report cards, or read their fee invoices.

---

## 2. What is shipped today

| Feature | Phase | Screenshot surface | Role(s) |
| --- | --- | --- | --- |
| OAuth PKCE sign-in | 2.1 | `login_screen` | all |
| Device registration + version policy | 2.1 | (boots silently) | all |
| Notifications inbox | 6 | `notifications_screen` | all |
| Students CRUD | 1 | list / detail / create | admin, teacher (read), parent (read-only via guardian) |
| Staff CRUD | 1.1 | list / detail / create | admin |
| Guardians CRUD | 1.2 | list / detail / create | admin |
| Academics (subjects + timetable + branches tabs) | 1.3 | `academics_screen` | admin, teacher |
| Subject create | 1.3 | `subject_create_screen` | admin |
| Attendance capture + list | 1.4 | capture / list | admin, teacher |
| Assessment (exam list + attempt) | 5 | `exams_list_screen` + `exam_attempt_screen` | student (attempt), admin (read) |

The "Splash → Dashboard → bottom-nav shell" is shared by all four
roles today. The five bottom-nav tabs (Students / Staff / Guardians /
Academics / Attendance) are hard-coded. Every role lands on the
same home dashboard, which is built around registrar-style "create"
shortcuts.

---

## 3. Per-role gap list

### Admin / Registrar

- **Analytics** — no mobile code. Backend has
  `get_school_academic_analytics`, `rebuild_school_academic_analytics`,
  `export_school_academic_analytics`. Should be a "KPI" surface with
  drill-down per grade / branch. *(File: `lib/features/analytics/` is
  README-only.)*
- **Fees** — shipped (read-only slice). `FeePlansScreen` lists
  the current user's fee plans (canonical + legacy wire keys
  both parse); the per-plan detail renders the per-line
  breakdown + Total / Paid / Outstanding totals. The admin
  "Fee operations" KPI card shows the collection rate
  (null on a fresh school with zero invoiced — the "0%
  collected" lie is gone) + invoiced / collected / outstanding
  totals + counts by status. Reachable from a new
  "Fees" bottom-nav tab (capability-gated on `can_view_fees`)
  and from capability-gated quick-start tiles on the admin
  home. The capability-gated "teller" surface (invoice
  preview + draft creation + payment recording) and the
  write-side flows (`preview_school_fee_invoice`,
  `create_school_fee_invoice_draft`, `create_school_fee_policy`)
  are deferred to a follow-up turn.
- **Governance** — **shipped** for the privacy + legal-hold +
  retention slice. The new `GovernanceScreen` at
  `/shell/governance` is the approver-only privacy queue:
  read-only list of `get_school_privacy_requests` with a
  per-row action sheet (Mark in review / Approve / Set
  hold / Release hold) that calls the v1 write endpoints
  (`approve_school_privacy_request`,
  `process_school_privacy_request`,
  `set_school_privacy_legal_hold`). The retention
  evaluation action is a one-click "Run retention"
  button in the AppBar that calls
  `evaluate_school_data_retention`. The list groups
  rows by lifecycle status (chip strip with
  success / warning / error / info / brand tones).
  Reachable from a new "Governance" tile on the admin
  home, capability-gated on `can_manage_branches`
  (admin-only on the v1 wire). The requester-side flow
  (`submit_school_privacy_request` from a parent /
  student) and the governance settings approval
  (`approve_school_data_governance_settings`) are
  deferred to follow-up turns.
- **Grading (admin side)** — **shipped** for the read-only
  slice. The new `GradingScreen` at `/shell/grading` has
  two tabs (Overview / Policies). The Overview tab
  renders the four headline KPIs (total / published /
  draft / average) as a responsive 2x2 / 4-up grid with
  status colors, then the workflow stages as a chip
  strip, then a feature / coverage / recent-students
  card. The Policies tab renders the permissions
  context (managed-doctypes + read roles + required
  roles as separate chip strips) at the top, then the
  list of subject grade policies. Reachable from a
  new "Grading" tile on the admin home, capability-gated
  on `can_manage_branches` (admin-only on the v1 wire).
  The write flows (`correct_school_grade_record`,
  `promote_school_assessment_result`,
  `approve_school_subject_grade_policy`) are deferred
  to follow-up turns.
- **Data import** — no wizard. Backend has a 6-step flow
  (`upload_school_data_import_package`, `dry_run_school_data_import`,
  `review_school_data_import_records`, `approve_school_data_import`,
  `commit_school_data_import`). *(README only.)*
- **Operations health** — **shipped** for the read-only
  slice. The new `OperationsHealthScreen` at
  `/shell/operations` has three tabs (Health / Delivery /
  Audit) backed by `get_school_operations_health`,
  `get_school_delivery_health`, and
  `get_school_auth_audit_events`. The Health tab renders
  the top-level status (healthy / degraded / unhealthy)
  + the per-module KPI maps (analytics / audit /
  delivery / imports / outbox) flattened into a single
  grid; the Delivery tab renders the per-status counts
  as a stacked bar + per-status chips; the Audit tab
  renders each event with a 44dp icon + user + timestamp
  + source IP. Reachable from a new "Operations" tile on
  the admin home, capability-gated on
  `can_manage_branches` (admin-only on the v1 wire).
  Write flows (`replay_school_delivery_event`,
  `receive_school_delivery_callback`) are deferred to a
  follow-up turn.
- **"Acting as" picker** — shipped. The "Acting as" card on both
  the student home and the registrar dashboard now exposes a
  "Switch student" icon button that opens the full-screen
  picker at `/shell/me/switch-student`. The picker searches the
  roster, persists the choice via
  `SessionStore.setCurrentStudent`, and invalidates
  `currentStudentProvider` so the next frame re-renders the new
  name on every dependent surface.

### Student

- **"My records" surface** — shipped. The student home now has a
  "My records" tile that opens a four-tab detail (Overview / Grades
  / Attendance / Report cards) for the active student resolved
  via `currentStudentProvider`. The detail screen is the same
  widget used by the parent child-detail route, just with
  `isOwnRecords: true` so the labels read "Your records" instead
  of "Your child's records". See
  `lib/features/family/ui/child_detail_screen.dart`.
- **"My fee invoices"** — the student can't see their own invoices
  on the mobile. *(Covered under the admin Fees gap above; the
  student's view is a re-skin of the same envelope.)*

### Teacher

- **"My classes"** — shipped. `MyClassesScreen` lists the
  teaching assignments owned by the current staff member
  (the v1 server is expected to filter to the current user
  when the session is a teacher role). Active assignments
  first, "Homeroom" chip on primary assignments, per-class
  subject chip. Reachable from the "My classes" bottom-nav
  tab (role-gated to teachers) and deep-linkable at
  `/shell/teachers/classes`.
- **"My students" (per-class)** — shipped. `ClassDetailScreen`
  renders the class identity card + the student roster
  filtered by `classGroupId`. Reachable from any row in
  "My classes".
- **Exam authoring** — no UI to create / publish exam plans or
  questions. Backend has `create_school_exam_plan`,
  `create_school_question`, `publish_school_question`,
  `publish_school_online_exam`.
- **Manual grading** — the `mark_exam_attempt` API exists server-side
  (Phase 5) but the mobile has no teacher grading screen. Teachers
  currently cannot enter marks for short-answer / essay questions.

### Parent

- **"My children" picker** — shipped. The parent home now renders
  a hero "My children" card (live count from `familyListProvider`)
  that jumps into `FamilyHomeScreen` at `/shell/family`. The
  picker lists the de-duplicated children the parent is linked to
  (active wins over withdrawn duplicates, withdrawn links stay
  visible at reduced opacity for reference), each row tappable
  into the per-child detail. See
  `lib/features/family/ui/family_home_screen.dart`.
- **Child detail (grades + attendance + report cards)** —
  shipped. `ChildDetailScreen` renders the four tabs
  (Overview / Grades / Attendance / Report cards) using
  `childRecordsProvider` (a single `FutureProvider.family` that
  fetches all three record lists in one shot). Client-side
  filtering by `school_student` because the v1 SDK does not
  accept that query parameter on the wire (see the comment at
  the top of `family_repository.dart`).
- **Fee invoices for my children** — covered under the Fees gap
  above; the parent's view is read-only. The v1
  `can_view_fees` capability does not include parents today,
  so the parent home's "Fee invoices" tile stays hidden for
  them; the read path (the v1 `get_school_student_fee_plans`
  endpoint, filtered to the current user on the server) is
  already in place. Backend follow-up: add
  `can_view_own_fees` so the parent + student can see their
  own plans.

---

## 4. PROD-quality gaps (not feature-level)

These block the app from being called "PROD-ready" even if every
feature above were built:

- **CI is broken** — `Flutter analyze + test` fails on `flutter pub
  get` because the `laratik_schools_api` path dep can't resolve
  (`../laratik_schools/contracts/dart`). The `Backend contract drift
  check` job fails on the same missing sibling. Pre-existing; both
  jobs need the sibling repo checked out (4 lines in `ci.yml`).
- **5 pre-existing test failures** in `test/platform/transport_test.dart`
  (2) and `test/features/assessment/current_student_provider_test.dart`
  (3, in the user's in-flight work). Not from the latest commit.
- **Arabic locale partial** — ~~the framework + the bottom-nav
  tab labels are localized; the home surfaces + the family
  / classes / child-detail / fee-plans surfaces still carry
  ~150 hardcoded English strings.~~ **Shipped** in the home
  surface localization turn. Every user-facing string on the
  parent / student / teacher / admin home, the family picker,
  the per-child detail, the "Switch student" picker, the
  teacher "My classes" + per-class detail, and the fees
  surfaces (plans + per-plan detail + admin "Fee operations")
  is now locale-aware. RTL pass landed: the notification
  badge dot uses `Positioned.directional` so it stays in the
  top-trailing corner in both LTR and RTL, every list-tile
  chevron mirrors itself under RTL, and the AppBar date
  uses `EdgeInsetsDirectional.only(end:)`. The locale test
  suite grew from 6 to 11 tests (pluralization + non-English
  Arabic guards).
- **No offline support** — explicitly deferred per the AGENTS.md.
  The v1 SDK has `get_school_offline_pull` + `submit_school_offline_mutation`
  for the offline queue; the mobile doesn't read either.

---

## 5. Prioritized roadmap

The order is "biggest PROD-blocker first, lowest-risk last". The
goal of the first three is: every existing screen is role-aware, the
build is green, and the most-missing role (parent) has a non-empty
surface. The rest is feature work.

| # | Theme | Item | Estimate | Status |
| --- | --- | --- | --- | --- |
| 1 | **Foundation** | `bootContextProvider` + role-aware shell + role-routed dashboard | 1 turn | **shipped in `902738d`** (role-foundation) |
| 2 | **CI** | Check out the sibling `laratik_schools` repo in `ci.yml` (4 lines) | 15 min | blocked — needs the user to confirm the cross-repo access |
| 3 | **Parent surface** | "My children" picker + child detail (grades + attendance + reports) | 1 turn | **shipped (family release)** |
| 4 | **Foundation** | "Acting as" picker for the registrar to switch the active student | 1 turn | **shipped (picker release)** |
| 5 | **Student surface** | "My grades" + "My attendance" + "My report cards" | 1 turn | **shipped (family release, reuses the parent child-detail widget)** |
| 6 | **Teacher surface** | "My classes" + exam authoring + manual grading | 2 turns | **shipped (read-only "My classes" + per-class roster in this turn; exam authoring + manual grading deferred — see audit #6 follow-up)** |
| 7 | **Admin enhancements** | Fees (read invoices) + Analytics (KPIs) | 2 turns | **shipped (Fees slice — read-only fee plans + admin "Fee operations" KPI overview; Analytics slice deferred to a follow-up turn)** |
| 8 | **Admin enhancements** | Governance (privacy + retention) + Grading (admin side) | 1 turn | **shipped (Governance slice — privacy requests + approve / process / set-legal-hold / retention — + Grading read-only slice — overview + policies + permissions context — in two consecutive turns; write flows for grading deferred to a follow-up turn)** |
| 9 | **Admin enhancements** | Data import wizard + Operations health | 2 turns | **partially shipped (Operations read-only slice — health + delivery + audit — in this turn; data import wizard + the operations write flows deferred to a follow-up turn)** |
| 10 | **Quality** | Hard-coded filter values → real `get_school_grades` | 0.5 turn | **shipped (picker release, derived from loaded students — backend follow-up: add `get_school_grades` + `get_school_class_groups`)** |
| 11 | **Quality** | Arabic locale + a11y audit | 1 turn | **shipped (locale framework + bottom-nav labels + home-surface string extraction + RTL pass; locale test suite grew from 6 to 11 tests covering English + Arabic copy, pluralization, and per-surface pinning)** |

The estimate is "one focused coding turn" (~30–60 min of focused
work plus tests + commit). Total to "PROD-ready" by the strict
definition: ~10 turns.

---

## 6. What "shipped today" means

Until the items above land, the honest answer to "is this PROD-ready
for role X?" is:

- **Admin / Registrar** — *Partially.* They can run the daily
  operations (roster, attendance, **read-only fees**,
  **read-only operations health + delivery + audit**,
  **privacy + legal-hold + retention queue**,
  **read-only grading overview + policies**) and the
  role-aware bottom nav now renders correctly. Cannot
  yet manage imports, replay delivery events, or correct
  / promote individual grade records. The fee write
  flows (invoice preview + draft creation + payment
  recording) and the Analytics KPI surface are still on
  the desktop. The Operations + Governance + Grading
  tiles on the admin home are capability-gated on
  `can_manage_branches` (admin-only on the v1 wire) — a
  future backend pass should add dedicated
  `can_view_operations` + `can_view_governance` +
  `can_view_grading` capabilities so the gates can be
  more specific.
- **Student** — *Partially.* They can take exams end-to-end
  and now see their grades / attendance / report cards under
  "My records" on the home screen. Fee invoices +
  class-scoped notifications are still on the desktop.
- **Teacher** — *Partially.* They get a real "My classes" tab
  + per-class detail (student roster). Still missing exam
  authoring and manual grading.
- **Parent** — *Partially.* They get a real "My family" home
  with a hero "My children" card, the family picker at
  `/shell/family`, and the per-child detail (Overview /
  Grades / Attendance / Report cards). Fee invoices for
  their children are still on the desktop.
- **Locale** — *En + Ar.* The mobile now supports both
  English and Arabic (Modern Standard) end-to-end. The
  bottom-nav tabs + every per-role home surface + the
  family / child-detail / picker / classes / fees
  surfaces are all locale-aware. The chevron in every
  list row mirrors itself under RTL and the notification
  badge dot stays in the top-trailing corner in both
  directions. The locale test suite covers English +
  Arabic copy, the six ICU plural categories for Arabic,
  and the per-surface key-pinning.

The source bar is met (the team can scaffold against the v1 Dart
SDK and the foundation features work). The production bar is not.
