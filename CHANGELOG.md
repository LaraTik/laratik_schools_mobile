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
- Flutter `>=3.24.0 <4.0.0`; Dart `^3.5.0`; CI pins `3.24.5 stable`.

## [0.1.0+1] - 2026-07-27

### Added

- Initial repository scaffold (this commit). No user-facing features
  yet; the app boots, builds the dependency graph, and renders a
  splash / login / shell placeholder.
