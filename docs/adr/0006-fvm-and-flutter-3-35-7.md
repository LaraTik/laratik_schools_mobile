# ADR 0006: FVM Adoption and Flutter 3.35.7 Pin

- Status: Accepted
- Date: 2026-07-28
- Phase: 0 (foundation)
- Supersedes: ADR 0002 (Flutter / Dart Pin, 2026-07-27)

## Context

ADR 0002 chose `environment.flutter: ">=3.24.0 <4.0.0"` and pinned CI to
Flutter `3.24.5 stable`. That decision was correct on 2026-07-27: the CI
runner shipped 3.24.5, the generated SDK had no upper bound beyond Dart 4,
and the maintainer's machine had no Flutter SDK yet, so the CI pin was the
only reproducibility lever.

Two facts changed on 2026-07-28:

1. **Cross-repo consistency.** The maintainer already runs four other
   Flutter repos (`mobile-customer-app`, `mobile-admin-app`, `mobile-dms-app`,
   `School_app`) on Flutter `3.35.7` via FVM (`{ "flutter": "3.35.7" }` in
   each `.fvmrc`). The new `laratik_schools_mobile` repo was the odd one
   out. Jumping between repos on different Flutter majors means different
   analyzer diagnostics, different `build_runner` output, and different
   native plugin ABI behaviour. That drift is a tax the solo maintainer
   does not need to pay.

2. **FVM is now the established local pattern.** All four sibling repos
   use FVM and gitignore `.fvm/`. Not adopting FVM here would re-introduce
   the "global Flutter on the dev machine" problem ADR 0002 explicitly
   tried to avoid by pinning CI.

ADR 0002's "CI is the source of truth" line is no longer accurate: `.fvmrc`
is now the source of truth, and CI reads it back.

The generated SDK constraint (`laratik_schools_api`'s
`sdk: ">=3.3.0 <4.0.0"`) is unchanged and still satisfied by Dart 3.9.x
(bundled with Flutter 3.35.7).

## Decision

- **Adopt FVM (Flutter Version Management) for local development.**
  `.fvmrc` at the project root pins the Flutter version. `.fvm/` (the
  per-machine SDK cache and the per-project symlink) is gitignored.
- **Pin Flutter to `3.35.7` stable** in `.fvmrc`. Matches the four sibling
  repos and is the most recent stable release the maintainer has validated
  end-to-end on the other projects.
- **`pubspec.yaml` constraints stay as written in ADR 0002.**
  - `environment.sdk: ^3.5.0` — satisfied by Dart 3.9.x (bundled with
    Flutter 3.35.7).
  - `environment.flutter: ">=3.24.0 <4.0.0"` — wide enough to accept
    3.35.7; narrow enough to keep a 4.0 jump an explicit decision.
- **CI reads the version from `.fvmrc`.** `subosito/flutter-action@v2`
  takes `flutter-version: ${{ steps.pin.outputs.version }}`, where
  `steps.pin` extracts `flutter` from `.fvmrc` with `jq`. A second step
  asserts the installed version matches the pin (defense in depth).
- **Single source of truth.** When the version needs to change, edit
  `.fvmrc` and commit. CI picks it up automatically; the local developer
  runs `fvm install`.

## Consequences

- Local development and CI are now guaranteed to use the same Flutter
  build. No more "works on CI, fails on my machine" from Flutter
  major-minor drift.
- The maintainer needs FVM installed locally. Install once via
  `dart pub global activate fvm`, then `fvm install` inside the project
  reads `.fvmrc` and pulls `3.35.7`. `fvm flutter ...` (or setting
  `.fvm/flutter_sdk/bin` on PATH) is the day-to-day command surface.
- `.fvm/` is per-machine; not committing it keeps the repo small and
  prevents a stale symlink from being checked in.
- The Flutter constraint in `pubspec.yaml` is intentionally wider than
  the FVM pin so that an external consumer of this package (none today,
  but possible) is not artificially restricted to 3.35.7.
- The 25k-student load-test harness documented in ADR 0001 will run on
  Flutter 3.35.7; if any benchmark numbers from the legacy `School_app`
  (Flutter 3.24.x) are reused, the comparison must note the Flutter
  delta.

## Follow-ups

- Add a one-line `make` / `tools/with-fvm.sh` wrapper that runs Flutter
  through FVM so shell users don't need to remember the prefix.
- Re-evaluate when the next Flutter major lands (4.0): the wider
  `<4.0.0` ceiling in `pubspec.yaml` will need to be raised in this
  ADR's successor.
- The Windows-machine Flutter bootstrap script in `tools/` (deferred in
  ADR 0002) is now obsolete — FVM replaces it. Remove any leftover
  reference when the tools directory is created.
- Confirm the four sibling repos still pass on 3.35.7 after this repo
  lands; if any sibling is on a different version, this decision has
  not actually unified the toolchain.
