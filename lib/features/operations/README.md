# Operations feature (Phase 1+)

Operations health, delivery callbacks, replay, and auth audit events.

Backend model: `School Operations Health`, `School Delivery Health`,
`School Auth Audit Event`. v1 wrappers: `get_school_operations_health`,
`get_school_delivery_health`, `replay_school_delivery_event`,
`get_school_auth_audit_events`, `receive_school_delivery_callback`.

Redesign plan:

- Diagnostic surfaces, not user-facing product surfaces.
- Capability-gated; rendered under `/shell/ops/*`.
