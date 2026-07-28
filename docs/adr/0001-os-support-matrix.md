# ADR 0001: OS Support Matrix

- Status: Accepted
- Date: 2026-07-27
- Phase: 0 (foundation)

## Context

The new mobile client is a greenfield replacement for `D:\Projects\School_app`
(Flutter package `school_app` v2.2.5+12). The legacy client ships for
Android and iOS only. We need an explicit, written OS support matrix so
contributors don't quietly pull in Windows / macOS / Linux / web builds
into the contract scope.

Constraints from the proposal (`openspec/changes/rewrite-flutter-mobile-client/proposal.md`):

- The client must interoperate with the Laratik Schools backend running
  on ERPNext/Frappe, OAuth 2.0 authorization code + PKCE, push delivery.
- Operator-first UX (school staff, teachers, registrars, principals).
- English-first copy, Arabic/RTL readiness required by the platform rules.
- The build must run on the same `flutter` stable toolchain as the legacy
  app until the cutover.

User context: 2026-07 the user runs the backend on Windows + Docker; the
Flutter dev machine is Windows; iOS builds require a Mac. The CI runs
on GitHub-hosted Linux.

## Decision

Tier 1 — required, ship blocker:

- Android 8.0 (API 26) and newer, x86_64, arm64-v8a.
- iOS 15.0 and newer, arm64.

Tier 2 — supported, no extra engineering effort, smoke-tested in CI:

- iPadOS 15+ (universal iOS build, no iPad-specific code path needed for
  Phase 0; iPad-only affordances are deferred to Phase 1+).

Tier 3 — out of scope, explicitly not supported in v1:

- Android 7.x and earlier (Frappe push, OAuth, and Flutter platform
  channels assume modern Android).
- iOS 14 and earlier.
- Windows, macOS, Linux, web — Frappe's whitelisted-method + CSRF
  contract was not designed for browser CORS, and Frappe push only
  targets APNS/FCM. Mobile-web is deferred until the backend exposes
  a first-class browser endpoint.
- Android TV, Wear OS, iPad-only layouts, foldables (handled by general
  responsive layout; no per-device tuning in v1).
- China-region stores / HarmonyOS / AOSP forks.

Tier 4 — out of scope until v2:

- VisionOS, CarPlay, Android Auto.

## Consequences

- `pubspec.yaml` `environment.flutter >= 3.24.0` matches the legacy
  app's stable line. No Flutter beta needed for v1.
- `pubspec.yaml` does not pin desktop platform code; macOS/Windows
  folders stay out of the repo to keep the platform set honest.
- The CI matrix runs Android (Gradle) + iOS (Xcode) lint jobs. Linux
  runs `flutter analyze` + `flutter test` only.
- Push notification work assumes APNS (iOS) and FCM (Android) — no
  third-party vendor in v1.

## Follow-ups

- Add Play Store + App Store metadata when the apps are enrolled.
- Document the 25k-student load test harness in
  `docs/agents/load-testing.md` once we have a non-prod backend.
- Reopen this ADR if the backend ever ships a first-class browser
  endpoint that justifies a web target.
