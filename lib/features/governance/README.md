# Data governance feature (Phase 1+)

Privacy requests, retention, legal hold, archive manifests.

Backend model: `School Privacy Request`, `School Data Archive Manifest`.

Redesign plan:

- Approver-only surfaces — capability-gated by `governance` in the
  permission context.
- Read + approve flows; mutations are idempotent and require explicit
  `reason` from the operator.
