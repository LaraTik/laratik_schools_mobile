# Data import feature

Score imports + bulk data imports (read-only catalog today; the
wizard-style flow is in scope as a follow-up turn).

Backend model: `School Score Import`, `School Data Import Batch`,
`School Data Import Record`, `School Score Import Column`,
`School Score Reconciliation`, `School Imported Assessment`,
`School Imported Score`.

## What's shipped today (read-only)

- `/shell/imports` — the "Data imports" surface, two tabs:
  - **Batches** — list of past data import batches from
    `get_school_data_import_batches`. Each row shows status
    chip, source label, package hash, row-count chip strip, +
    created-at sub-line. Tapping a row opens the per-batch
    reconciliation detail.
  - **Score imports** — list of past score imports from
    `get_school_score_imports`. Each row shows status chip,
    source label, file hash, column count, + created-at
    sub-line. Tapping a row opens the per-import detail.
- `/shell/imports/:batchId` — per-batch reconciliation detail.
  Renders the batch's top-line summary (status, source label,
  package hash, created-at) + the per-row reconciliation
  records from `get_school_data_import_reconciliation` (one
  card per record with doctype, row index, status chip,
  message, + the first 3 payload key/value pairs).
- `/shell/imports/scores/:scoreImportId` — per-score-import
  detail. Renders the import's top-line summary (status,
  source label, file hash, created-at) + the mapped columns
  (source → target) as a chip strip + the per-stage counts
  from the validate step. Ships a **Validate** button (calls
  `validate_school_score_import`) and a **Commit** button
  (calls `commit_school_score_import`); both mint a fresh
  UUID for the `Idempotency-Key` header and the controller
  invalidates the list on success.

The data + score import surfaces are read-only catalog
displays; the future data import wizard (upload → dry-run
→ review → approve → commit) is deferred to a follow-up
turn because the v1 SDK's
`upload_school_data_import_package` endpoint expects a
pre-uploaded `package_file` (Frappe's file API) which is
outside the v1 SDK scope today. The admin home ships a
"Data imports" tile that is capability-gated on
`can_manage_branches` (admin-only on the v1 wire; the
v1 server does not yet expose a dedicated
`can_view_imports` capability — see the audit's §4
follow-up for the future hardening).

## Future (deferred)

- The 6-step data import wizard (upload → map → preview →
  validate → approve → commit). The wizard needs:
  1. A `file_picker` dep to grab the user's package.
  2. A `dio` / `http` multipart call to Frappe's
     `/api/method/upload_file` to push the file to the
     server (the SDK doesn't expose this).
  3. A `Stepper` widget for the wizard UX.
  4. The per-row review surface (each reconciliation row
     gets an `approve` / `reject` action that calls
     `review_school_data_import_records`).
- `create_school_data_archive_manifest` (the post-commit
  archive manifest write flow).
- The `promote_school_imported_score` write flow (per
  imported score → grade record).
