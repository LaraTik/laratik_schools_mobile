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
