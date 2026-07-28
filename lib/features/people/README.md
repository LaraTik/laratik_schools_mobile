# People feature (Phase 1+)

Staff and student directory surfaces. Source of truth: the `laratik_schools` backend's
`School Student`, `School Staff`, and `School Guardian` DocTypes and their v1 API
wrappers in `laratik_schools.api.v1.*`.

Redesign plan (replaces `School_app/lib/screens/{students,teachers,add_student,edit_student,...}.dart`):

- List + filter + detail pattern, server-side keyset pagination.
- Branch-scoped (caller's primary branch + scoped branches from the permission context).
- No emoji icons; use Material Symbols outlined.
- 48dp primary action target; row height 56dp; 44dp minimum.
- Inline editing for non-privileged fields; guarded edits for privileged fields.
- English-first copy; Arabic mirrors automatically.

`get_school_students` and `get_school_staff` already exist in the v1 contract — see
`docs/adr/0004-package-choices.md` for the package decisions around state and form handling.
