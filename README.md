# Laratik Schools Mobile

Greenfield Flutter application for the Laratik Schools platform. Consumes the
[frozen v1 contract](../laratik_schools/contracts/openapi/laratik-schools-v1.json)
emitted by [`laratik_schools`](../laratik_schools) (Frappe/ERPNext backend) and
replaces the legacy School_app Flutter client + the .NET API it was paired with.

This is a **separate repository** from the backend. The contract is the only
approved client boundary; the mobile app never reads or writes DocType JSON
or raw `/api/resource` endpoints.

## Status

Active, started 2026-07-27. The backend change
[`rewrite-flutter-mobile-client`](../laratik_schools/openspec/changes/rewrite-flutter-mobile-client/)
is the authoritative OpenSpec for the work; this repo is its implementation
home.

**Source bar (met)** — the team can scaffold against the v1 Dart SDK.
**Production bar (deferred)** — accepted named-site Phase 9 mobile-ready slice
(144-API authenticated smoke + OAuth/MFA + branch-scope + ERPNext side effects).

## Layout

```text
laratik_schools_mobile/
├── lib/
│   ├── main.dart                  # entry point
│   ├── app/                       # composition root: app, bootstrap, router
│   ├── core/                      # result, clock, logging
│   ├── platform/                  # transport (HTTP), will grow to include
│   │                              #   secure storage, push, deep links
│   ├── auth/                      # OAuth PKCE, session store
│   ├── ui/                        # design tokens, theming
│   └── features/                  # one folder per feature module
│       ├── boot/                  # role-aware boot context + splash
│       ├── people/                # Phase 1+
│       ├── academics/             # Phase 1+
│       ├── attendance/            # Phase 1+
│       ├── grading/               # Phase 1+
│       ├── assessment/            # Phase 1+
│       ├── communication/         # Phase 1+
│       ├── fees/                  # Phase 1+
│       ├── analytics/             # Phase 1+
│       ├── imports/               # Phase 1+
│       ├── governance/            # Phase 1+
│       └── operations/            # Phase 1+
├── test/                          # cross-cutting smoke + integration tests
├── docs/adr/                      # Phase 0 decisions (see ADRs 0001-0006)
├── pubspec.yaml
├── analysis_options.yaml
├── BACKEND_CONTRACT_SHA           # pinned contract revision; CI fails on drift
├── LICENSE.md
├── CHANGELOG.md
└── .github/workflows/ci.yml
```

The layout is flat (one Dart package) for the foundation. If a feature
module grows past ~5 files, it is split out into its own sub-package in
Phase 1+ (see ADR 0004 for the dep-bloat threshold).

## Backend contract

The generated Dart SDK at
[`laratik_schools/contracts/dart`](../laratik_schools/contracts/dart) is
consumed as a `path:` dependency. `BACKEND_CONTRACT_SHA` records the expected
backend commit SHA. CI fails if `git -C ../laratik_schools rev-parse HEAD`
does not match. When the backend contract changes, the SHA file is bumped
and a contract-freshness commit is required.

## Quick start

The toolchain is pinned via [FVM](https://fvm.app). `.fvmrc` is the single
source of truth for the Flutter version; both local dev and CI read it.

```bash
# 1. Install FVM (one-time, on the dev machine). Requires Dart on PATH.
dart pub global activate fvm

# 2. Get the backend SDK in place — it lives in the sibling laratik_schools repo.
#    Required for the `laratik_schools_api` path: dep and the CI contract check.

# 3. From the project root, install the pinned Flutter and fetch packages.
fvm install                # reads 3.35.7 from .fvmrc
fvm flutter pub get

# 4. Run the foundation tests (analyze + test, no build).
fvm flutter analyze
fvm flutter test

# 5. Open the app against a non-production site (after OAuth + boot are wired).
fvm flutter run --dart-define=SITE=laratik.localhost
```

> The toolchain is pinned to **Flutter 3.35.7 stable** (ADR 0006). CI uses
> the same pin by reading `.fvmrc`. If `flutter --version` reports a
> different version locally, run `fvm install` again.

## Phase 0 decisions

Six ADRs are recorded in `docs/adr/`:

1. `0001-os-support-matrix.md` — Android 8+, iOS 15+.
2. `0002-flutter-dart-pin.md` — *Superseded by 0006.* Original Flutter 3.24.5 / Dart 3.5+ pin.
3. `0003-app-identifiers.md` — `io.laratik.schools` bundle id, `laratik-mobile` OAuth client.
4. `0004-package-choices.md` — go_router, riverpod, http, crypto, etc.
5. `0005-branding-store-telemetry.md` — calm indigo brand, no third-party telemetry in the foundation.
6. `0006-fvm-and-flutter-3-35-7.md` — Adopt FVM, pin Flutter 3.35.7 to match the four sibling repos; CI reads `.fvmrc`.

## License

Proprietary — see [`LICENSE.md`](./LICENSE.md).
