# Daytrip 0.9.0h — Transaction Ledger & Transaction CRUD (RIF 2)

**Date:** 2026-10-22  
**Roadmap:** [ROADMAP-0.9.md](../../ROADMAP-0.9.md) (RIF 2 of Portfolio Workbench Expansion)

## Premise & Measurement

1. **Rich Dataset Activation:** The SQLite database contains ~4,000 real transactions across 40 accounts spanning 3 years (2023–2026) in categories such as Groceries, Dining, Travel, Gas, Shopping, Dividends, and Transfers. These records are currently locked behind single-account views with no global visibility or editing capability.
2. **Full Transaction CRUD:** Users must be able to record new transactions, edit categorization/amounts, and safely delete transactions with automatic account cash balance reconciliation.
3. **Information Synthesis & Visual Grace:** Provide an executive multi-account activity feed (`transactions.sp`) combining cash flow metrics (`Total Outflow`, `Total Inflow`, `Net Cash Flow`), category spending breakdowns, and high-density tabular ledgers.

## The Plan

1. **Domain & Repository Expansion (`examples/portfolio/repository.rb`):**
   - Enhance `Portfolio::Activity` with validation (`validate`: merchant, amount, date), `:errors`, and `:notice`.
   - Implement `find_transaction(id)`, `create_transaction(account_id, attrs)`, `update_transaction(id, attrs)`, `delete_transaction(id)`, and `recent_transactions(limit:, category:, account_id:)`.
   - Add `spending_summary(days:)` to synthesize top spending categories and cash flow totals.

2. **Routes & Mutation Handlers (`examples/portfolio/app.rb`):**
   - `GET /transactions` → `transactions.sp` (global ledger and category breakdown).
   - `GET /accounts/:id/transactions/new` → `new_transaction.sp`.
   - `POST /accounts/:id/transactions` (creates transaction, updates cash balance, redirects with flash).
   - `GET /transactions/:id/edit` → `edit_transaction.sp`.
   - `PUT /transactions/:id` (updates transaction, re-balances account).
   - `GET /transactions/:id/delete` → `confirm_delete_transaction.sp`.
   - `DELETE /transactions/:id` (reverses balance effect, deletes transaction).

3. **Views & Visual Presentation (`examples/portfolio/views/`):**
   - `transactions.sp`: Cash flow summary metrics, top spending categories grid/table, chronological transaction table with account links and actions.
   - `new_transaction.sp`: Input form for date, merchant, category, amount, description with 422 validation diagnostics.
   - `edit_transaction.sp`: Prefilled edit form.
   - `confirm_delete_transaction.sp`: Safe 2-step deletion confirmation.
   - `portfolio.frame`: Persistent navigation across Overview, Activity Ledger, and Open Account.
   - `account.sp`: Inline transaction actions (`Edit`, `Delete`) and `+ Record transaction` toolbar.

4. **Census & Verification:**
   - Register 4 new views in `verify_pages.rb` and `studio/pages.rb` (advancing verified pages from 36 to 40).
   - Update census vitals across docs and code.
   - Add integration tests in `test/phase6_test.rb`.
   - Run all 12 gate legs to ensure zero regressions.
