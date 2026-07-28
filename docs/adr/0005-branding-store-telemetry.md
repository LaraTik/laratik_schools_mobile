# ADR 0005: Branding, Store Presence, and Telemetry

- Status: Accepted
- Date: 2026-07-27
- Phase: 0 (foundation)

## Context

Branding decides the launch icon, in-app typography, primary color,
and the visual identity the user sees on the splash screen and store
listings. The OpenSpec requires English-first copy, Arabic/RTL
readiness, no emoji icons, and a 44x44 minimum touch target (see
`docs/agents/ui-ux.md` for the staff-portal counterparts).

Store presence decides the listing copy, screenshots, and account
ownership. The user is the sole maintainer of the GitHub org
`LaraTik` and ships under the `io.laratik.schools` bundle ID
(ADR 0003).

Telemetry decides what data leaves the device. The platform rules
treat every school as production-like and forbid leaking
student/guardian/payment data, so any analytics or crash report must
be PII-free by construction.

## Decision

Branding — the foundation:

- Display name: **Laratik Schools**.
- Wordmark: text-only ("Laratik Schools") rendered with the
  system font for Phase 0; a hand-tuned wordmark is added when
  brand assets are signed off.
- Brand color: **calm indigo-blue `#1F4D8C`** (light) and
  **`#8AB4F8`** (dark). Tinted containers and the teal
  **`#1E7A6E`** accent are reserved for live indicators and
  sparingly used.
- Type: system font for Phase 0 (`-apple-system` / `Roboto`).
  Custom font picks are deferred to Phase 1.
- Iconography: Material Symbols Outlined via the standard
  `Icons.*` set; no emoji. Custom SVG icon set is deferred to
  Phase 1 when the visual identity is finalized.
- Light + dark themes both shipped; default follows system.
- Empty / loading / error / pending states are explicit on every
  surface (per the staff-portal UI rules).

Store presence — the foundation:

- Apple Developer account: not yet created; placeholder. The user
  owns the decision; when the account exists, the bundle ID
  `io.laratik.schools` is registered under it.
- Google Play Console: same; placeholders. Listing copy is
  English-only for v1, with Arabic mirroring once the Arabic
  locale is wired in.
- Internal distribution: Firebase App Distribution (Android) +
  TestFlight (iOS) when ready. Not part of the foundation.

Telemetry — the foundation:

- No analytics SDK in the foundation. Boot / API / auth events are
  logged locally via `RedactingLogger` and never leave the device.
- Crash reporting is deferred to Phase 1+ and, when adopted, must
  be PII-free (no student name, no guardian contact, no payment
  data) — the only fields shipped are `request_id`, route, error
  class, and stack frames.
- Push delivery (FCM / APNS) is server-driven, registered via
  `register_school_mobile_device`, and is not a telemetry concern.

## Consequences

- The foundation ships with no third-party SDK beyond the listed
  packages, which keeps the trust surface small and the install size
  honest.
- The Arabic locale is layered in when the brand assets and the
  Arabic copy are signed off — keeping English-first in Phase 0
  avoids the cost of retrofitting translations into screens that
  are still being designed.
- The brand color is calm and operator-friendly; the user can
  revisit it in Phase 1 when actual product screens are in
  front of real users.

## Follow-ups

- Brand asset delivery (logo, splash, store icon) — the user owns
  the asset pipeline.
- Apple / Google account creation, signing keys, and store listing
  copy.
- A "Telemetry" ADR is required the moment any analytics or crash
  SDK is added.
