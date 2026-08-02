# Bug log

> A self-learning record of every bug that took non-trivial time to find or
> fix on the Laratik Schools mobile client. Every entry is a short postmortem:
> **what broke → how we found it → what the root cause was → the fix → how to
> prevent the next agent from re-tripping on it.**
>
> ## Self-learning rule (binding)
>
> When you fix a bug in this repo, **append a new entry to this file in the
> same commit** that lands the fix. No exceptions.
>
> - The entry should be small (≤ 12 lines) and follow the template below.
> - If the fix is a code change, reference the file/line so the next agent
>   can jump straight to it.
> - If the bug exposed a **process gap** (missing check, wrong default,
>   missing test), fix the gap in the same commit — don't just log it.
> - If a related test was missing, add the test in the same commit.
>
> Skipping the entry because "it's a small thing" is the #1 way bugs
> re-appear. Future-you is the next agent.
>
> ## Template
>
> ```markdown
> ### YYYY-MM-DD — <one-line summary>
>
> Symptom: …
> Root cause: …
> Fix: … (commit / file:line)
> Prevention: …
> ```
>
> ## Entries
>
> ### 2026-07-31 — Dev flavor `baseUrl` pointed at the wrong port
>
> Symptom: From the Android emulator, the app's API calls returned uvicorn
> 400 "Invalid HTTP request received" instead of Frappe responses. The bench
> itself answered correctly on `127.0.0.1:8700` from the host.
>
> Root cause: `lib/config/flavor_config.dart` set the `dev` flavor baseUrl
> to `http://10.0.2.2:8000`, but the dev bench container
> (`laratik-erpnext-dev-bench-1`) maps **host 8700 → container 8000**. Host
> port 8000 is already taken by the `meta_ads_ops.api:app` uvicorn from
> the sibling `meta-ads-agent` repo, so `10.0.2.2:8000` from the emulator
> hit the wrong process entirely.
>
> Fix: `lib/config/flavor_config.dart` — `dev` and `local` flavors now use
> `http://10.0.2.2:8700` and `http://192.168.1.42:8700` respectively, with
> an inline comment that points future agents to this entry.
>
> Prevention:
> - The runbook at `docs/local-dev.md` now calls out the host port 8000
>   collision explicitly.
> - `scripts/check_dev_backend.sh` (added in the same change) does a one-line
>   `curl` against the configured `baseUrl` from inside the emulator and
>   fails loudly if the response is not `frappe.ping → pong`.

### 2026-07-31 — "Not eligible" on every exam despite the API returning eligible

Symptom: After a fresh login, the dashboard's "Acting as" card shows
`Ahmad Barmada / STU-00001` (the cold-start current-student resolver
picks the head of `get_school_students`). Tapping the
Arithmetic Practice Quiz, however, lands on the "Not eligible / The
server says you cannot take this exam" page. The same call to
`get_school_online_exam_eligibility?exam_plan=EXM-00009&school_student=STU-00001&school_enrollment=ENR-00002`
returns `{"eligible":true}` when invoked directly with a session cookie.

Root cause: `currentStudentProvider` was resolving the active
enrollment by walking the published exam plans' audience snapshot
(`plan.raw['audience']`). The v1 `_normalize_exam_plan` in
`laratik_schools/laratik_schools/core/exam_plans.py` does NOT expose
the `audience` child table or the `audience_snapshot_json` field on
the wire — so the resolver always saw an empty list and cached
`enrollmentId: null`. The attempt screen then forwarded
`school_enrollment: ''` to the eligibility endpoint, which
short-circuits to `eligible: false` on the empty string.

Fix:
- `lib/features/assessment/data/assessment_repository.dart` — added
  `listEnrollments` and an `Enrollment` model that reads
  `enrollment_name`, `school_student`, `enrollment_status`, and
  `school_branch` from the wire.
- `lib/features/assessment/data/current_student_provider.dart` —
  `_findActiveEnrollment` now calls the dedicated
  `get_school_enrollments` v1 endpoint first (filtering client-side
  for `school_student == me && enrollment_status == "Active"`) and
  falls back to the exam-plan audience scan only when the
  enrollments list is empty.
- `test/features/assessment/current_student_provider_test.dart` —
  added tests that pin the new "enrollments endpoint first" path
  and the "fallback to audience when empty" path. All 6 tests in
  the file pass; full test suite 66/66 green.

Prevention:
- The wire-format gap is now documented in this entry; future
  agents who add a resolver that needs a student/enrollment pair
  should hit `get_school_enrollments` first.
- The backend's `_normalize_exam_plan` should grow a one-line
  `return {..., "audience_snapshot_json": ...}` so the audience
  fallback is no longer best-effort. Logged as a follow-up on the
  `laratik_schools` side; not in scope for the mobile change.

### 2026-07-31 — Transport wire format diverged from the OpenAPI v1 contract

Symptom: GET endpoints (e.g. `get_school_online_exam_eligibility`)
returned stub responses like `{"eligible": false, "exam_plan": null}`
on the mobile but the correct `{"eligible": true, "exam_plan": "EXM-00009"}`
when invoked from a curl on the same session. POST endpoints
(`start_school_exam_attempt`) returned HTTP 500 *only* after the
request reached the server's `coerce_payload` call.

Root cause: `lib/platform/transport.dart` was doing two things the
contract did not ask for, every call:
  1. Wrapping every body in `{"args": arguments}` regardless of verb.
  2. Always using HTTP `POST`, even for endpoints the contract
     declares as `GET` with `in: query` parameters.
For GET endpoints, `form_dict` ended up as `{"args": <dict>}` and
`frappe.call(method, **form_dict)` filtered out every kwarg the
function signature didn't have (the function signatures are e.g.
`exam_plan=None, school_student=None, school_enrollment=None`), so
all the kwargs defaulted to `None` and the response was the stub.
For POST endpoints with the `payload` convention, the generated SDK
*also* wraps the caller's `payload` under a `payload` key — and the
transport wrapped a second time, so the server's
`coerce_payload(form_dict['payload'])` returned the inner wrapper
instead of the user's args, surfacing as
`exam_plan is required` or `client_mutation_id is required`.

A separate header bug: the transport set
`X-Idempotency-Key`, but the contract declares the header name as
`Idempotency-Key` (no `X-` prefix), so the server's
"Idempotency-Key header is required" check rejected every mutating
call.

Fix:
- `lib/platform/transport.dart` — split the wire format by verb:
  * GET → arguments as URL query string, no body.
  * POST → `arguments` JSON-encoded as the request body verbatim.
    The SDK already performs the per-operation envelope
    (`{payload: ...}` for payload-style methods, top-level keys
    for kwargs-style); the transport does not re-wrap.
  * Idempotency-Key → header name is now `Idempotency-Key`
    (matching `components/parameters` in the OpenAPI spec).
- `test/platform/transport_test.dart` (new file) — 4 tests pin
  the wire format: GET goes to query string, GET with no args
  sends no Authorization, POST sends the SDK-shaped body
  verbatim with the right `Idempotency-Key` header, and 401s
  surface as `TransportException(UNAUTHENTICATED)`.

Prevention:
- The transport now matches the OpenAPI spec to the letter; if
  a future SDK call has a different envelope shape, the test in
  `test/platform/transport_test.dart` is the safety net.
- The bench gotcha is captured here so the next agent does not
  re-spend 90 minutes on `frappe.ping → pong` from curl but
  `{"eligible": false}` from the device.
- `lib/features/assessment/data/assessment_repository.dart` —
  `startAttempt` now includes `client_mutation_id` in the
  payload (it is required by the server's `start_attempt()` and
  is not in the OpenAPI schema's `required` list because the
  schema uses `additionalProperties: true`). The same UUID is
  reused as the `Idempotency-Key` header to keep the request and
  row-level dedupe aligned.

### 2026-07-31 — Backend `School Exam Attempt.started_at` rejects tz-aware ISO 8601

Symptom: After the transport fix above, `start_school_exam_attempt`
reaches the server and runs through `start_attempt()`, but the
`doc.insert()` call in `gateway.insert_attempt` raises
`MySQLdb.OperationalError: (1292, "Incorrect datetime value:
'2026-07-31T12:45:54.216061+00:00' for column
`tabSchool Exam Attempt`.`started_at` at row 1")`. The whole
attempt lifecycle (start → answer → autosave → submit → result)
is blocked on this single insert.

Root cause: In `laratik_schools/laratik_schools/core/online_assessments.py:369`
the insert dict uses `timestamp.isoformat()` where `timestamp = _utc(now)`
returns a tz-aware `datetime`. The resulting string carries the
`+00:00` offset (and microseconds); the `School Exam Attempt`
DocType's `started_at` column is a plain `Datetime` (no tz) and
the MySQL strict mode rejects the value. Same shape at lines 268,
355, 431, 493, 555, 725, 807. A second instance of the bug lived
in `laratik_schools/laratik_schools/core/outbox.py:_record_to_mapping`
— the gateway was forwarding tz-aware `datetime`s directly into
`School Outbox Event.available_at` (and the lease / processed
fields) and MySQL rejected the same way.

Fix (applied after the user explicitly unblocked backend work):
- `core/online_assessments.py:1033-1054` — added `_naive_iso(value)`
  helper that strips tz and microseconds and emits the
  `YYYY-MM-DD HH:MM:SS` shape Frappe's `Datetime` columns want.
  Replaced all 7 call sites (lines 268, 355, 369, 431, 493, 555,
  725, 807) to use it.
- `core/outbox.py:_record_to_mapping` — `available_at`,
  `lease_expires_at`, `processed_at` are now run through a local
  `_to_frappe_datetime(value)` helper with the same shape. Keeps
  the in-memory `OutboxRecord` tz-aware (the lease / retry logic
  needs the tz for arithmetic) and only normalises at the wire
  boundary.
- Re-ran the E2E (login → exam list → eligibility → start
  attempt → 5 answers → autosave → submit). The
  `School Exam Attempt EXAT-00001` row now lands in ERPNext
  end-to-end with `state: Pending Manual Grading`,
  `started_at: 2026-07-31 12:57:36`, `submitted_at: 2026-07-31
  13:06:25`, `max_score: 6.0`, `revision: 2`. Verified via
  `scripts/drive_exam_api.py` (the same wire the mobile uses).

Prevention:
- The bug is logged here so the next agent does not chase
  the transport, the SDK, or the auth flow for a 500 they
  cannot fix from the mobile side.
- The rule for any future server-side datetime write: if the
  DocType field is `Datetime` (not `Datetime(6)`, not timezone-
  aware), use the `_naive_iso` helper (or equivalent) instead
  of `datetime.isoformat()`. The microsecond + tz combination
  is the exact string MySQL strict mode rejects with 1292.
- Consider centralising in `frappe.utils.now_datetime()` and
  passing the `datetime` object to `get_doc({...}).insert()` —
  Frappe's controller handles the wire shape. The current
  inline helper is fine for now; a follow-up to switch to
  `now_datetime()` is a one-line refactor per call site.

### 2026-08-02 — Dark mode was non-functional: every shared widget read the device brightness, not the app theme

Symptom: When the OS was set to light and the user toggled
`ThemeMode.system` in dev, the app rendered *dark* tokens
(anywhere `DesignTokens.forBrightness(MediaQuery.platformBrightnessOf(context))`
was called) — and vice versa. Toggling the system theme had no
visible effect; widgets were stuck on the brightness the
*device* reported at the moment they were built.

Root cause: `MaterialApp.theme` and `MaterialApp.darkTheme` were
both passed `buildTheme(DesignTokens.forBrightness(...))` with a
hard-coded `Brightness`, but the tokens themselves were never
attached to the `ThemeData`. Every shared widget then
re-derived the brightness from `MediaQuery.platformBrightnessOf`
(aka "what does the device say?") instead of
`Theme.of(context).brightness` (aka "what did the MaterialApp
resolve?"). The two diverged the moment `themeMode` was anything
other than the device default, and the two diverged silently
because `tokens.brand.primary` (light indigo) and the dark
indigo are both "purple" at a glance — no contrast alarm was
raised in code review.

Fix:
- `lib/ui/app_theme.dart` (new) — `LaratikTokens extends ThemeExtension`
  wraps the existing `DesignTokens` bundle. `LaratikTokens.of(context)`
  reads `Theme.of(context).extension<LaratikTokens>()`; the
  `context.laratik` extension is the ergonomic accessor.
  `buildAppTheme(tokens)` attaches the extension to a `ThemeData`
  in one call.
- `lib/app/app.dart` — both `theme:` and `darkTheme:` now go through
  `buildAppTheme(...)`. The MaterialApp is now the single source
  of truth for which brightness the widgets render in.
- 50+ call sites swept — every `DesignTokens.forBrightness(
  MediaQuery.platformBrightnessOf(<var>))` replaced with
  `<var>.laratik` (`context.laratik` at the top of the build,
  `sheetContext.laratik` inside `showModalBottomSheet` builders).
  Files touched: all 5 shared widgets, the dashboard, the exam
  attempt screen, every list / detail / create screen in
  `people / staff / guardians / attendance / academics / assessment /
  communication`.

Prevention:
- The new `context.laratik` extension is the canonical accessor for
  any new widget. `DesignTokens.forBrightness` still exists as a
  legacy escape hatch but should not appear in new code.
- A future hardening pass should grep for
  `MediaQuery.platformBrightnessOf` (returns the device value,
  not the app value) and route the hits through
  `Theme.of(context).brightness` (or `context.laratik.brightness`).
- If/when the app grows a "follow system" / "always light" /
  "always dark" toggle, the theme plumbing is now ready for it
  — the toggle is a one-line `themeMode:` change in `app.dart`.

### 2026-08-02 — `FamilyRepository.listAllRecordsForStudent` cast the wrong result type

Symptom: After the family surface commit, the new
`listAllRecordsForStudent` failed to type-check: `fvm flutter analyze`
reported `'Err<Never, FamilyFailure>' is not a subtype of
'Err<ChildRecordsPage<ChildGradeRecord>, FamilyFailure>'` at
`family_repository.dart:469`. The corresponding test
`FamilyRepository.listAllRecordsForStudent surfaces the first
failure without fetching the rest` also failed with the same cast
mismatch.

Root cause: The original short-circuit used the
`is Err<Never, FamilyFailure>` idiom to extract the error from the
sealed `Result`:
```dart
if (grades is Err) {
  return Err(error: (grades as Err<Never, FamilyFailure>).error);
}
```
The `is Err` narrowed to the raw class but the cast target
`Err<Never, FamilyFailure>` was a *type-erased* generic that didn't
match the actual `Err<ChildRecordsPage<ChildGradeRecord>, FamilyFailure>`.
`Result` is sealed, so the safe pattern is to type-narrow on the
*concrete* generic instantiation.

Fix: `lib/features/family/data/family_repository.dart` — re-typed the
short-circuit to `if (gradesResult is Err<ChildRecordsPage<ChildGradeRecord>, FamilyFailure>)`
and three sibling `is Err<...>` checks. The analyzer and the
11-test repository suite now both go green.

Prevention:
- The sealed `Result<T, E>` pattern means: never `as Err<Never, E>`;
  always narrow on the concrete `T` you declared in the function
  signature. A future repo that chains `Result` short-circuits should
  copy the family repository's idiom directly.
- The test `listAllRecordsForStudent surfaces the first failure
  without fetching the rest` is the safety net — it deliberately
  does NOT queue the attendance / report-card stubs so a regression
  to the broken short-circuit (or a regression that keeps fetching
  after the first failure) fails loudly with a "No stub queued" error
  from `FakeLaratikSchoolsTransport`.
