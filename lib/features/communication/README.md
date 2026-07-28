# Communication feature (Phase 1+)

Notifications, announcements, and direct messaging.

Backend model: notifications, `School Mobile Notification` (delivered via
push and polled via `get_school_mobile_notifications`).

Redesign plan:

- Inbox + per-channel filters; mark-read is idempotent on the server.
- Push delivery is best-effort; the inbox is the source of truth.
- Push tokens are registered via `register_school_mobile_device` and
  rotated on sign-in.
