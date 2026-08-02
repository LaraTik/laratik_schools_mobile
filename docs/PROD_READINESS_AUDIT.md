# PROD-readiness audit — Laratik Schools Mobile

> Snapshot: 2026-08-02. The mobile is at `2acb8b5` (Phase 0–6 surface
> realignment + UI/UX polish). "PROD-ready" here means: every user
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

The user who teaches classes and marks work. Today: the surface
treats them as the same as a registrar — they get the same
Students / Staff / Guardians / Academics / Attendance tabs. The
auth flow lands them on the same dashboard. Cannot yet: see "my
classes" (their teaching assignments), see the students in their
own classes, author exam plans / questions, or manually grade
exam attempts. The `mark_exam_attempt` API exists server-side and is
exposed via v1; the mobile has no UI for it.

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
- **Fees** — no mobile code. Backend has
  `get_school_fee_policies`, `get_school_student_fee_plans`,
  `preview_school_fee_invoice`, `create_school_fee_invoice_draft`.
  Read-only invoice list + detail is the Phase 1 slice; the
  capability-gated "teller" surface is deferred. *(README only.)*
- **Governance** — no mobile code. Backend has
  `submit_school_privacy_request`, `process_school_privacy_request`,
  `approve_school_privacy_request`, `get_school_privacy_requests`,
  `set_school_privacy_legal_hold`, plus the governance settings
  DocType. The mobile needs an approver-only surface. *(README only.)*
- **Grading (admin side)** — no grading-policy or grade-record admin
  surface. The grade records are *promoted* by
  `promote_school_exam_attempt` (Phase 5) but the admin can't review /
  supersede / correct them from the mobile. *(README only; backend
  exposes `correct_school_grade_record` and
  `approve_school_subject_grade_policy`.)*
- **Data import** — no wizard. Backend has a 6-step flow
  (`upload_school_data_import_package`, `dry_run_school_data_import`,
  `review_school_data_import_records`, `approve_school_data_import`,
  `commit_school_data_import`). *(README only.)*
- **Operations health** — no diagnostic surface. Backend has
  `get_school_operations_health`, `get_school_delivery_health`,
  `replay_school_delivery_event`, `get_school_auth_audit_events`,
  `receive_school_delivery_callback`. *(README only.)*
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

- **"My classes"** — no teaching-assignments surface. Backend has
  `get_school_teaching_assignments`, `get_school_academic_structures`.
- **"My students"** — the teacher sees the *whole* student roster,
  not the roster of students in their own classes. *(The backend
  `is_eligible` check is per-attempt; the mobile pre-attempt list
  should also be class-scoped.)*
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
  above; the parent's view is read-only.

---

## 4. PROD-quality gaps (not feature-level)

These block the app from being called "PROD-ready" even if every
feature above were built:

- **Role-aware navigation is hard-coded.** The shell has a fixed
  `ShellTab` enum of 5 tabs. The boot context *already* returns
  `primaryRole`, `roles`, `capabilities`, and `navigation` — the
  mobile just doesn't consume them. The single biggest PROD blocker.
- **CI is broken** — `Flutter analyze + test` fails on `flutter pub
  get` because the `laratik_schools_api` path dep can't resolve
  (`../laratik_schools/contracts/dart`). The `Backend contract drift
  check` job fails on the same missing sibling. Pre-existing; both
  jobs need the sibling repo checked out (4 lines in `ci.yml`).
- **5 pre-existing test failures** in `test/platform/transport_test.dart`
  (2) and `test/features/assessment/current_student_provider_test.dart`
  (3, in the user's in-flight work). Not from the latest commit.
- **No Arabic locale** — explicitly deferred to a later phase per
  the README. English-only today.
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
| 6 | **Teacher surface** | "My classes" + exam authoring + manual grading | 2 turns | next turn |
| 7 | **Admin enhancements** | Fees (read invoices) + Analytics (KPIs) | 2 turns | after #6 |
| 8 | **Admin enhancements** | Governance (privacy + retention) + Grading (admin side) | 1 turn | after #7 |
| 9 | **Admin enhancements** | Data import wizard + Operations health | 2 turns | after #8 |
| 10 | **Quality** | Hard-coded filter values → real `get_school_grades` | 0.5 turn | **shipped (picker release, derived from loaded students — backend follow-up: add `get_school_grades` + `get_school_class_groups`)** |
| 11 | **Quality** | Arabic locale + a11y audit | 1 turn | after #10 |

The estimate is "one focused coding turn" (~30–60 min of focused
work plus tests + commit). Total to "PROD-ready" by the strict
definition: ~10 turns.

---

## 6. What "shipped today" means

Until the items above land, the honest answer to "is this PROD-ready
for role X?" is:

- **Admin / Registrar** — *No.* They can run the daily operations
  (roster, attendance) but cannot review fees, manage imports, see
  the operations health, or respond to privacy requests. Half of
  their job is on the desktop, not the phone.
- **Student** — *Partially.* They can take exams end-to-end and
  now see their grades / attendance / report cards under "My
  records" on the home screen. Fee invoices + class-scoped
  notifications are still on the desktop.
- **Teacher** — *No.* They get the registrar's chrome and no teacher
  surface. The exam-attempt flow is student-side; teachers cannot
  author exams or grade them.
- **Parent** — *Partially.* They get a real "My family" home
  with a hero "My children" card, the family picker at
  `/shell/family`, and the per-child detail (Overview / Grades /
  Attendance / Report cards). Fee invoices for their children are
  still on the desktop.

The source bar is met (the team can scaffold against the v1 Dart
SDK and the foundation features work). The production bar is not.
