# ADR 0002: Flutter / Dart Pin

- Status: Superseded by ADR 0006
- Date: 2026-07-27 (superseded 2026-07-28)
- Phase: 0 (foundation)

## Context

The foundation scaffold must run on a known-stable Flutter / Dart pair
that is present on the maintainer's local machine, installable on CI
without extra approval, and compatible with the generated v1 SDK at
`laratik_schools/contracts/dart` (SDK constraint `>=3.3.0 <4.0.0`).

The legacy `School_app` repo declares `environment: { sdk: '3.5.3' }`
and was built against Flutter 3.24.x. The generated SDK has no upper
bound beyond Dart 4.0.0. CI on GitHub-hosted runners ships Flutter
3.24.5 stable.

We don't want a floating `^` constraint on `environment.flutter`
because that lets CI silently pick a newer Flutter that breaks
generated code (build_runner, native plugins, etc.). We also don't
want to over-constrain to a single patch release — that blocks
security patches.

## Decision

- `environment.sdk: ^3.5.0` — matches the legacy `School_app` line.
- `environment.flutter: ">=3.24.0 <4.0.0"` — wide enough to accept
  any 3.24.x+ stable release on the same major, narrow enough to
  prevent a 4.0 jump.
- CI pins the exact Flutter version to `3.24.5 stable` so the build
  is reproducible. The local machine is free to use a newer 3.24.x
  build, but the CI result is the source of truth.
- Generated SDK is consumed as a `path:` dep, not a `git:` dep, so
  its revision is whatever is in the sibling `laratik_schools`
  repo. Drift is caught by the BACKEND_CONTRACT_SHA check.
- Tool versions are listed in the README's "Prerequisites" section
  and re-checked by CI.

## Consequences

- Anyone running `flutter pub get` against the foundation gets a
  consistent result on Flutter 3.24.x.
- The maintainer's local machine (Windows, no Flutter SDK installed
  yet) needs the Flutter 3.24.5 install to exercise the foundation
  locally; CI does the validation until then.
- Future Flutter major versions (4.0) require an explicit ADR bump
  + a regeneration of the SDK + a coordinated release.

## Follow-ups

- Add a `tools/version-check.sh` script that fails the build if the
  installed Flutter doesn't satisfy the constraint.
- When we adopt any plugin that requires a newer Flutter (e.g. an
  Impeller-only feature), this ADR must be revised before the dep
  lands.
