# Fees feature (Phase 1+)

Fee structures, invoices, and payments.

Backend model: ERPNext `Sales Invoice` and `Customer` are reused. v1
wrappers are read-mostly in Phase 1; payments are surfaced via
`/api/method/erpnext.accounts.doctype.payment_entry.payment_entry.submit`
in later phases, gated by the `fees` capability.

Redesign plan:

- Read-only invoice list + detail in Phase 1.
- Teller/cashier surfaces added once the `fees` capability is registered.
