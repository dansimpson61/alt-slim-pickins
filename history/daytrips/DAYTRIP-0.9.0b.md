# Daytrip 0.9.0b — SQLite Domain & Persistence in Portfolio

**Date:** 2026-10-21  
**Roadmap:** [ROADMAP-0.9.md](../../ROADMAP-0.9.md) (Phase 2 of 6, Authentic SQLite Domain & CRUD Persistence)

## Premise & Measurement

1. **Local Financial Data Privacy:** Authentic financial exports (`Balances_*.csv` and `Transactions_*.csv`) were provided to seed the portfolio database. These contain authentic account numbers, balances, and transaction histories. To protect privacy, all raw CSVs and the generated SQLite database must be strictly local and shielded from ever being tracked, staged, committed, or pushed.
2. **Persistence & Relational Domain:** Previously, `examples/portfolio` relied on hardcoded static structs in `Fixtures.portfolio`. A true CRUD stretch exam requires real relational SQLite persistence with tables for `accounts`, `holdings`, and `transactions`, dynamic recalculation of market values and weights, and server-side validation error handling.

## What Changed

1. **Git Protection for Local Financial Data:**
   - Moved CSV files into `examples/portfolio/data/`.
   - Updated `.gitignore` to permanently ignore `*.csv`, `*.sqlite3`, `*.db`, `.~lock.*`, and `examples/portfolio/data/`.
   - Verified with `git status` that no personal financial files are tracked or visible to git.

2. **Built `Portfolio::Repository` (`examples/portfolio/repository.rb`):**
   - **Schema:** Created SQLite tables for `accounts`, `holdings`, and `transactions` with foreign key cascades and auto-incrementing IDs.
   - **Domain Structs:** Defined pure Ruby models (`Account`, `Holding`, `Activity`, `PortfolioSummary`) with validation methods (`validate` returning `{}`) and computed metrics (`total_value`, `gain`, `cash_balance`, `weight`).
   - **Seeder:** Automatically parses the local CSV exports when present, extracting 16 active accounts ($2.0M total valuation) and 4,553 transactions, while allocating representative index holdings (VTI, VXUS, BND, SPAXX) for investment accounts. Falls back to a clean demo portfolio if CSVs are absent.
   - **CRUD Operations:** Implemented transactional `create_account`, `update_account`, `delete_account`, `create_holding`, `update_holding`, and `delete_holding`, updating balances and logging transactions on every write.

3. **Suite & Census Verification:**
   - Created `test/portfolio_repository_test.rb` covering account validation, CRUD, holding weight and balance recalculation, and CSV seeding.
   - Updated census test files count (55 -> 56) in `HANDOFF.md`.

## Verification

- All 12 gate legs: **0 problems** (12/12 PASS).
- 30 verified pages: **0 problems**.
- Full test suite: **650 runs, 6,955 assertions, 0 failures, 0 errors, 0 skips**.
