# Analytics feature (Phase 1+)

Academic analytics surfaces: `get_school_academic_analytics`,
`rebuild_school_academic_analytics`, `export_school_academic_analytics`.

Redesign plan:

- The analytics dataset is server-driven; the UI is a renderer.
- Export uses the typed analytics envelope; the SDK exposes a typed
  `Academic Analytics` data class.
- Charts: prefer the existing chart primitives in `lib/ui/`; do not
  introduce a chart library ad-hoc per screen.
