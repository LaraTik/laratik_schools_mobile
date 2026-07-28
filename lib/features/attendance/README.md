# Attendance feature (Phase 1+)

Daily attendance capture, period attendance, and offline drafts.

Backend model: `School Attendance Record` + offline draft review via
`review_school_offline_attendance_draft` and `submit_school_offline_mutation`.

Redesign plan:

- Operator-first capture: tap-to-mark grid, swipe to mark-all-present, hold
  for absent. Heavy reuse of the operator layout (no marketing-style cards).
- Offline-first: writes land in a local outbox, replayed on reconnect with
  the server-assigned mutation id.
- The `get_school_offline_pull` SDK call provides a keyset-paginated dataset
  for the active class group.
