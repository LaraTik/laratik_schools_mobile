# PROD-readiness audit — Laratik Schools Mobile

> Snapshot: 2026-08-02. The mobile is at `2acb8b5` (Phase 0–6 surface
> realignment + UI/UX polish). "PROD-ready" here means: every user
> role can do the things their role implies, the build is green, and
> the app degrades gracefully on the major failure modes (offline,
> expired token, capability not granted, version-policy block).

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
- **"Acting as" picker** — the mobile currently pins the session to
  whatever student the dev seed creates. A registrar who is logged
  in as `Administrator` but reviewing a particular student's record
  has no in-app way to switch.

### Student

- **"My grades"** — the mobile can read `get_school_grade_records`
  but doesn't show a per-student grade history. *(Phase 5.4 candidate.)*
- **"My attendance"** — no per-student attendance history view.
  *(Phase 1.4 left only the capture + global list surfaces.)*
- **"My report cards"** — the mobile never reads
  `get_school_report_cards` or `get_school_student_profile`. *(Phase
  7+ candidate.)*
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

- **"My children" picker** — the mobile has no parent-specific
  surface. A parent logged in today lands on the same registrar
  dashboard.
- **Child detail (grades + attendance + report cards)** — not built.
  The backend envelope is the same as a registrar reading
  `get_school_grade_records` and `get_school_attendance_records` for
  a specific student; the mobile just needs the right `student_id`
  filter and the role-aware entry point.
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
- **Hard-coded filter values** in `students_list_screen.dart`
  (`const ['Grade 1', 'Grade 2', ...]`) — will lie to the operator
  against real data. Needs a `get_school_grades` integration. Flagged
  in the previous review.
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
| 1 | **Foundation** | `bootContextProvider` + role-aware shell + role-routed dashboard | 1 turn | **shipped in `2acb8b6`** (this turn) |
| 2 | **CI** | Check out the sibling `laratik_schools` repo in `ci.yml` (4 lines) | 15 min | blocked — needs the user to confirm the cross-repo access |
| 3 | **Parent surface** | "My children" picker + child detail (grades + attendance) | 1 turn | next turn |
| 4 | **Foundation** | "Acting as" picker for the registrar to switch the active student | 1 turn | after #3 |
| 5 | **Student surface** | "My grades" + "My attendance" + "My report cards" | 1 turn | after #4 |
| 6 | **Teacher surface** | "My classes" + exam authoring + manual grading | 2 turns | after #5 |
| 7 | **Admin enhancements** | Fees (read invoices) + Analytics (KPIs) | 2 turns | after #6 |
| 8 | **Admin enhancements** | Governance (privacy + retention) + Grading (admin side) | 1 turn | after #7 |
| 9 | **Admin enhancements** | Data import wizard + Operations health | 2 turns | after #8 |
| 10 | **Quality** | Hard-coded filter values → real `get_school_grades` | 0.5 turn | after #9 |
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
- **Student** — *Partially.* They can take exams end-to-end, but
  cannot see their grades, attendance, or report cards on the
  phone. The exam flow is solid; everything else is desktop.
- **Teacher** — *No.* They get the registrar's chrome and no teacher
  surface. The exam-attempt flow is student-side; teachers cannot
  author exams or grade them.
- **Parent** — *No.* They get the registrar's chrome. No "my
  children" surface, no grade / attendance / invoice read for their
  kids.

The source bar is met (the team can scaffold against the v1 Dart
SDK and the foundation features work). The production bar is not.
