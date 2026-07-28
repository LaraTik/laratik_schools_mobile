# Online assessment feature (Phase 1+)

Online exam attempt lifecycle: eligibility, start, autosave, submit, grade,
promote, abandon, and result retrieval.

Backend model: `School Online Exam`, `School Question`,
`School Question Version`, `School Exam Attempt`. v1 wrappers cover the
full state machine.

Redesign plan:

- Attempt UI must support autosave without disrupting the active question.
- Promote on completion is server-driven; the UI never writes promotion
  state directly.
- Question rendering uses a typed widget per `question_type` (the SDK
  narrows each `School Question` payload).
