# Academics feature (Phase 1+)

Academic year, semester, grade, subject, course, and course-schedule surfaces.

Backend model: `Academic Year`, `School Semester`, `School Grade`, `School Subject`,
`School Course`, `School Course Schedule`. v1 wrappers under
`laratik_schools.api.v1.*_school_*`.

The OpenSpec has a known parity gap here — `.NET` supports composite subjects
(see `docs/agents/dotnet-parity-scan-2026-07-27.md`) and the new backend
deliberately defers this until the Registrar/Operations team asks for it.

Redesign plan:

- Calendar-first view for the active academic year.
- Schedule grid (periods × days) for `School Course Schedule`; reuses the
  `lib/ui/` table primitives being added in Phase 1.
- Conflict detection runs client-side for visible rows; the server remains
  the source of truth.
