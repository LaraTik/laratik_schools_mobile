# Data import feature (Phase 1+)

Score imports + bulk data imports (upload, dry-run, review, approve,
commit).

Backend model: `School Score Import`, `School Data Import Batch`.

Redesign plan:

- Wizard-style flow: upload → map → preview → validate → approve → commit.
- Each step is server-driven; the UI surfaces the server's pre-validated
  payload rather than running its own validation.
- Review screens use the shared table primitive in `lib/ui/`.
