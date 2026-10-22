# Daytrip 0.9.0g — Holdings CRUD & Account Detail Console Elevation (RIF 1)

**Date:** 2026-10-22  
**Roadmap:** [ROADMAP-0.9.md](../../ROADMAP-0.9.md) (RIF 1 of Portfolio Workbench Expansion)

## Premise & Measurement

1. **Analytical Depth & Entity Mutation:** While basic account CRUD existed, individual financial positions (holdings) could not be created, edited, or liquidated.
2. **Account View Elevation:** The existing `account.sp` view was an empty shell displaying only a video and two links, failing to present the rich financial data already loaded by the SQLite repository.
3. **Ergonomics & Visual Polish:** Every step must leave the app easier on the eyes, better looking, and more gracefully presenting information so the user can easily see and synthesize their wealth standing.

## What Changed

1. **Elevated Account Detail View (`examples/portfolio/views/account.sp`):**
   - Transformed into an analytical console:
     - Header identity with `title .name` and breadcrumb actions (`← All accounts`, `Edit account`, `Close account`).
     - Executive metrics grid: `Total value`, `Cash balance`, and `Unrealized gain`.
     - Full holdings matrix with shares, cost basis, price, market value, unrealized gain, and portfolio weight.
     - Manage positions section with individual position cards and direct `Edit position` and `Liquidate` actions.
     - Account activity ledger showing recent transactions.
     - Action toolbar with `+ Add holding`.

2. **Holdings Mutation Views & Routes (`examples/portfolio/`):**
   - `GET /accounts/:id/holdings/new` → `new_holding.sp`: Form with 422 validation diagnostics.
   - `POST /accounts/:id/holdings`: Inserts holding, logs purchase activity, recalculates account value, redirects with flash notice.
   - `GET /holdings/:id/edit` → `edit_holding.sp`: Prefilled form with method override support.
   - `PUT /holdings/:id`: Updates position and rebalances account cash/gains.
   - `GET /holdings/:id/sell` → `confirm_sell.sp`: Safe 2-step destructive confirmation showing shares and estimated cash proceeds.
   - `DELETE /holdings/:id`: Liquidates holding, converts to cash, logs sell activity.

3. **Spatial Posture Enhancement (`examples/portfolio/portfolio.layout`):**
   - Added `zone box frame quiet` to compile subtle card borders and quiet background contrast for position cards.

4. **Census & Verification:**
   - Advanced verified pages from **33 to 36** across census, docs, and test runners (`verify_pages.rb`, `studio/pages.rb`, `test/fixtures.rb`).
   - Added integration test `test_holdings_crud_lifecycle_and_account_elevation` in `test/phase6_test.rb`.
   - All 12 gate legs 100% green: 665 runs, 7,166 assertions, 0 failures.
