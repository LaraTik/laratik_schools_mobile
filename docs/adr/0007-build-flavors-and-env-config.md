# ADR 0007: Build Flavors and Environment Configuration

- Status: Accepted
- Date: 2026-07-28
- Phase: 2 (post-Phase-1 refactor)

## Context

The client needs to build and run against multiple backends without
copy-pasting the URL into every feature:

- `dev`   — Android emulator on the same machine as the local Frappe
            dev server (Frappe serves on the host's `localhost:8000`).
- `local` — A physical phone on the same Wi-Fi as the dev host.
- `qa`    — A staging environment (not yet provisioned).
- `prod`  — The production tenant.

Three forces have to align:

1. **Engineering** — the active environment must drive `baseUrl`,
   OAuth `client_id`, OAuth redirect scheme, app display name, and
   Android bundle suffix. One file, one place to edit.
2. **Build system** — the same source has to produce side-by-side
   installable APKs (dev / local / qa) plus a single production APK,
   each with its own launcher icon label.
3. **Security** — cleartext HTTP is fine for the dev / local backend,
   but production must remain HTTPS-only with no debug override
   sneaking into the release build.

Two previous patterns were rejected:

- **Per-flavor entry points** (`main_dev.dart`, `main_prod.dart`, …)
  multiplies the entry-point surface and forces every downstream
  change to touch several files. Doesn't scale past a handful of envs.
- **`String.fromEnvironment` scattered through feature code** — works
  for a single value, but every feature ends up duplicating
  `String.fromEnvironment('BASE_URL')` and the indirection makes it
  hard to audit "what URL is this screen actually hitting?".

## Decision

Adopt a **single-flavor-source + `--dart-define`-selected registry**:

```
lib/config/
├── app_flavor.dart     enum AppFlavor { dev, local, qa, prod } + .id / .tag
├── app_config.dart     immutable AppConfig (baseUrl, oauthClientId, …)
├── flavor_config.dart  FlavorRegistry: the ONE place that maps flavor → AppConfig
└── flavor_loader.dart  reads --dart-define=APP_FLAVOR, returns AppConfig
                        + appConfigProvider for Riverpod
```

Resolution chain at startup:

```
--dart-define=APP_FLAVOR=qa   (compile-time constant)
   └─► FlavorLoader.load()
        └─► FlavorRegistry.of(AppFlavor.qa)
             └─► AppConfig(baseUrl: 'https://qa.laratik.app', …)
                  └─► bootstrap(config: appConfig)
                       └─► appConfigProvider.overrideWithValue(config)
```

Anything in feature code that needs an env-specific value reads it
from `appConfigProvider`:

```dart
final baseUrl = ref.watch(appConfigProvider).baseUrl;
```

No `String.fromEnvironment` calls outside `flavor_loader.dart`. The
compiler still tree-shakes unused flavor entries.

### Android side mirror

`android/app/build.gradle.kts` declares matching `productFlavors`:

| flavor | applicationIdSuffix | versionNameSuffix | launcher label           |
| ------ | ------------------- | ----------------- | ------------------------ |
| dev    | `.dev`              | `-dev`            | Laratik Schools (Dev)    |
| local  | `.local`            | `-local`          | Laratik Schools (Local)  |
| qa     | `.qa`               | `-qa`             | Laratik Schools (QA)     |
| prod   | *(none)*            | *(none)*          | Laratik Schools          |

`resValue("string", "app_name", …)` is consumed by the main
`AndroidManifest.xml` via `android:label="@string/app_name"`, so the
launcher label is per-flavor and there is no hard-coded label string
in the manifest.

### Network security

Two `network_security_config.xml` files, one per build variant:

- `src/main/res/xml/network_security_config.xml` — base config, HTTPS
  only (effectively the Android 9+ default, declared explicitly so
  we never get surprised by a manifest-merge default).
- `src/debug/res/xml/network_security_config.xml` — debug override
  that allows cleartext to `10.0.2.2`, `localhost`, `127.0.0.1`, and
  private RFC1918 ranges (`10.0.0.0/8`, `192.168.0.0/16`). Applied
  via `tools:replace="android:networkSecurityConfig"` in
  `src/debug/AndroidManifest.xml` so the release build is *never*
  marked as cleartext-permissive.

The release APK does not contain the debug XML, so the merge cannot
leak dev-only hosts into a Play Store artifact.

### Defaults

`APP_FLAVOR` is **optional** at runtime. If `--dart-define=APP_FLAVOR=…`
is omitted, `FlavorLoader` defaults to `dev` so a bare
`flutter run` (no flags) just works on the local emulator. Unknown
values throw `ArgumentError` at startup — the app refuses to launch
rather than silently pick the wrong backend.

### Adding a new environment

Three edits, all in code review visible spots:

1. `lib/config/app_flavor.dart` — add the enum value + `id` / `tag`.
2. `lib/config/flavor_config.dart` — add the const `AppConfig` and
   wire it into the `of` switch (compiler enforces the switch is
   exhaustive).
3. `android/app/build.gradle.kts` — add a matching `productFlavor`
   with `applicationIdSuffix` + `resValue("string", "app_name", …)`.

No changes to `bootstrap.dart`, `main.dart`, or any feature code.

## Consequences

Positive:

- One place to look when a backend URL changes (`flavor_config.dart`).
- One place to look when a new env goes live (add an enum value, an
  `AppConfig`, and a Gradle productFlavor — three small edits).
- `appConfigProvider` is the only legitimate source of env-specific
  values; static analysis / linter rules can enforce it later.
- Side-by-side installs: a tester can carry `Laratik Schools (Dev)`
  and `Laratik Schools (QA)` on the same phone.
- Production build is provably HTTPS-only (debug XML is not in the
  release variant).

Negative / follow-ups:

- Secrets (signing keys, API tokens) are still TODO. They should
  land via `--dart-define-from-file` + a per-env `*.env.json` that's
  git-ignored, layered on top of the same `AppConfig`. The current
  `AppConfig` only carries non-secret values.
- iOS still needs the per-flavor bundle id / display name + an
  associated `xcconfig` file. ADR is Android-only for now; the iOS
  work tracks separately.
- Per-flavor launcher icons (e.g. a colored badge for `dev`) would
  make installs visually obvious in the launcher. Not in scope.
- The `local` flavor's LAN IP (`192.168.1.42` placeholder) is brittle
  when the dev machine moves networks. A small bootstrap script that
  rewrites the IP at `flutter run` time would be a nice follow-up.

## Follow-ups

- Add iOS flavor configuration (`.xcconfig` files + Info.plist
  per-flavor build settings).
- Add per-flavor launcher icons with a colored badge so dev / qa
  installs are visually obvious.
- Add `--dart-define-from-file` plumbing so secrets (signing keys,
  device-registration shared secret) can live outside the repo.
- Wire CI to build dev / qa / prod APKs in parallel on every PR.
