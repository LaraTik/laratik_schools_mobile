# Grading feature (Phase 1+)

Grade records, weight configuration, and promotion decisions.

Backend model: `School Grade Record`, `School Assessment Result`. v1
wrappers: `get_school_grade_records`, `get_school_assessment_results`,
`promote_school_exam_attempt`.

The `.NET` parity scan flagged a known gap: the new backend deliberately
defers the composite-subjects promotion decision workflow (medium
priority — see `docs/agents/dotnet-parity-scan-2026-07-27.md`). The
Registrar/Operations team owns the call to add it.

Redesign plan:

- Read-mostly list surfaces; edit flows are scoped to authorized roles.
- Bulk-action on selected rows is the primary path; never have an
  off-screen action bar.
