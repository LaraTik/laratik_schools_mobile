# ADR 0003: App Identifiers and Store Presence

- Status: Accepted
- Date: 2026-07-27
- Phase: 0 (foundation)

## Context

The app must register unique identifiers with each store, match
ERPNext's mobile-platform configuration, and use a reverse-DNS scheme
that doesn't collide with the legacy `School_app` package
(`com.schoolapp`) or with the future internal-only builds.

The OpenSpec requires the iOS / Android bundle identifiers to match
the OAuth client_id values registered server-side, and the
`School Mobile Device` DocType's `installation_id` to be a stable
per-install UUID (the app mints it on first launch and stores it in
`shared_preferences`).

The user has the `laratik_schools` repo on GitHub under `LaraTik/*`
and is the sole maintainer.

## Decision

| Surface | Identifier |
| --- | --- |
| Dart package name | `laratik_schools_mobile` |
| Android applicationId | `io.laratik.schools` |
| Android namespace | `io.laratik.schools` |
| iOS bundle identifier | `io.laratik.schools` |
| Universal links domain | `laratik.app` (placeholder until DNS is wired) |
| OAuth client_id (mobile) | `laratik-mobile` |
| Push sender (Android) | FCM project `laratik-schools` (placeholder) |
| Push sender (iOS) | APNS topic `io.laratik.schools` |

Reverse-DNS scheme follows the org: `io.laratik.*`. The first-party
public client is `io.laratik.schools`; future private-label builds can
append a suffix (`.lara`, `.admin`, etc.) without colliding.

Installation ID:

- Generated via `uuid` v4 on first launch.
- Stored in `shared_preferences` (not secure storage — it is not
  sensitive on its own, but it is paired with the secure refresh
  token).
- Sent to the backend on `register_school_mobile_device` and on
  every `get_school_mobile_boot_context` call (so the server can
  reconcile offline drafts and pushed notifications).

## Consequences

- The first reverse-DNS segment is `io` because the user has not
  registered a `laratik.*` domain yet. When the public domain
  `laratik.app` (or similar) is registered, this ADR is reopened and
  identifiers are migrated as part of the public release.
- Server-side OAuth client_id and DocType `School Mobile Version
  Policy` config must accept `io.laratik.schools` and
  `laratik-mobile` before the first device registration.

## Follow-ups

- Wire DNS + APNS topic + FCM project once the user picks the
  production domain.
- Register the bundle IDs with Apple / Google after the first
  internal build is signed and uploaded.
- Reopen this ADR if the app becomes multi-tenant and requires
  per-tenant OAuth clients.
