# ADR 0004: Package Choices

- Status: Accepted
- Date: 2026-07-27
- Phase: 0 (foundation)

## Context

The foundation needs a minimal but real set of packages. We are not
adopting "every useful Flutter package" — every dep is a commitment
that the maintainer has to keep working with future Flutter versions
and the generated SDK. The proposal explicitly defers most package
choices to "after the Phase 0 spike" — this ADR captures the
foundation's picks and the rules for evolving them.

Selection rules:

1. The package must be on pub.dev with active maintenance (commit in
   the last 6 months on its default branch).
2. It must support the Flutter 3.24 / Dart 3.5 pin from
   ADR 0002.
3. The license must be compatible with the project license
   (`LICENSE.md` in this repo).
4. Prefer official-team packages (`flutter.dev` publisher) and
   Flutter Favorite–badged packages. When a clear winner doesn't
   exist, prefer the smaller, narrower API.
5. Re-evaluate any package whose transitive deps grow past 30 —
   that's a sign the choice is dragging in a kitchen sink.

## Decision

Foundation picks (already in `pubspec.yaml`):

| Concern | Pick | Why |
| --- | --- | --- |
| Generated v1 contract client | `laratik_schools_api` (path dep) | Generated; frozen by the contract SHA check. |
| Routing | `go_router: ^14.2.7` | Official team package, deep-link friendly, supports shell route and refresh listenable. |
| State / DI | `riverpod: ^2.5.1` | Compile-time safe, no BuildContext gotchas, easy to scope per boot. |
| Immutable models | `freezed_annotation: ^2.4.4` + `freezed: ^2.5.7` (dev) | Union types for `Result` and boot states. |
| JSON decode (when not generated) | `json_annotation: ^4.9.0` + `json_serializable: ^6.8.0` (dev) | Generated code stays consistent with the SDK. |
| Functional plumbing | `result_dart: ^2.1.1` | Typed `Ok` / `Err` for the boot pipeline. |
| Value equality | `equatable: ^2.0.5` | Lightweight; used by `BootContext`. |
| HTTP client | `http: ^1.2.2` | Official team package; the only thing we need is `post` with timeout. |
| Crypto (PKCE S256) | `crypto: ^3.0.5` | Official team package. |
| Prefs (session persist) | `shared_preferences: ^2.3.2` | Official team package. The foundation persists the access token and installation id in `shared_preferences`; the refresh token is added via `flutter_secure_storage` in Phase 1 once the auth-code exchange lands. |
| Device info | `device_info_plus: ^10.1.2` | Standard for `installation_id` and platform gating. |
| App version | `package_info_plus: ^8.0.2` | Reads `pubspec.yaml` version for the version policy call. |
| UUID | `uuid: ^4.5.1` | Stable `installation_id` generation. |
| Lints | `flutter_lints: ^4.0.0` | Official team preset. |
| Test doubles | `mocktail: ^1.0.4` | No codegen, no `MockitoBuilder` ceremony. |
| Contract drift helper | *(removed 2026-07-28)* | Placeholder was never published. The actual drift check runs in CI via `BACKEND_CONTRACT_SHA`; this dep is gone. |

Explicit non-choices for the foundation:

- **No chart library yet.** The analytics feature is Phase 1+; the
  choice (e.g. `fl_chart` vs. `syncfusion_flutter_charts`) is made
  there with a comparison ADR.
- **No DI codegen.** Riverpod's plain providers are enough for the
  foundation. `riverpod_generator` lands when the number of providers
  exceeds the human-review threshold (~30).
- **No analytics / crash reporting SDK.** Branding / store ADR
  (0005) covers telemetry. We don't ship it in the foundation.
- **No state machine library.** Hand-rolled `enum`-based state
  machines are fine until a feature really needs xstate.

## Consequences

- The dep set is small enough to audit in one sitting.
- The two generated-code deps (`freezed` + `json_serializable`) mean
  the project needs `dart run build_runner build` in CI before
  analyze, but only after the first model is added in Phase 1+.
- A future feature that needs a heavier dep (e.g. a calendar widget,
  a PDF renderer) must come with a fresh ADR and a check on the
  transitive-dep size.

## Follow-ups

- When the first feature is added, add a `tools/lockfile-audit.sh`
  that diffs the lockfile and flags new direct deps.
- Remove `contract_checker` if it is still a placeholder by the end
  of Phase 1.
