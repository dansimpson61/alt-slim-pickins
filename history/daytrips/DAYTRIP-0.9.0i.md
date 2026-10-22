# Daytrip 0.9.0i — Executive Net Worth & Multi-Tier Portfolio Overview (RIF 3)

**Date:** 2026-10-22  
**Roadmap:** [ROADMAP-0.9.md](../../ROADMAP-0.9.md) (RIF 3 of Portfolio Workbench Expansion)

## Premise & Measurement

1. **Rich Dataset Activation:** The database contains 38 accounts across 10 institutions (Ally, Fidelity, Schwab, American Express, Real Estate / Loan, etc.) with diverse financial natures:
   - **Cash & Liquid Reserves:** `checking`, `savings`, `cash` accounts (~$16.3k).
   - **Investments & Retirement:** `brokerage`, `traditional_ira`, `roth_ira` (~$10.1k in equities/funds).
   - **Debts & Liabilities:** `credit` (-$5.4k) and `mortgage` (-$136.4k) totaling -$141.7k in obligations.
2. **Cognitive Synthesis & Visual Grace:** The existing `index.sp` renders a flat list of accounts and an undifferentiated `total_value`. Presenting 38 accounts in an unsegmented stream creates visual clutter and hides crucial personal finance insights (such as debt-to-asset ratio, liquid cash cushion, and net worth).
3. **Executive Balance Sheet Structure:**
   - Present a clear executive metrics strip: `Net Worth`, `Total Assets`, `Total Debt`, `Liquid Cash`.
   - Segment accounts into 3 elegant tiers:
     - *Liquid Cash & Banking*
     - *Investments & Retirement*
     - *Debts & Obligations*
   - Each tier displays its sub-total metric and high-density, gracefully formatted account cards with direct links to account consoles.

## The Plan

1. **Domain & Repository Expansion (`examples/portfolio/repository.rb`):**
   - Upgrade `Portfolio::PortfolioSummary`:
     - Add `net_worth`, `total_assets`, `total_debt`, `liquid_cash`, `total_investments`.
     - Add tiered collections: `banking_accounts`, `investment_accounts`, `liability_accounts`.
   - Update `repo.portfolio_summary`:
     - Partition accounts into asset vs. liability classes.
     - Calculate accurate net worth (`total_assets - total_debt`).
     - Calculate sub-totals for liquid cash and investments.

2. **Test Fixtures Alignment (`test/fixtures.rb`):**
   - Update `Fixtures.portfolio` to populate `net_worth`, `total_assets`, `total_debt`, `liquid_cash`, `total_investments`, `banking_accounts`, `investment_accounts`, `liability_accounts`.
   - Ensure complete JSON serialization (`plainify`) compatibility for Studio page verification.

3. **View Elevation (`examples/portfolio/views/index.sp`):**
   - Replace flat stream with a structured executive balance sheet:
     - **Top Metrics Grid (4 columns):** `Net Worth`, `Total Assets`, `Total Debt`, `Liquid Cash`.
     - **Executive Quick Actions:** `Open Account`, `Record Transaction`, `Activity Ledger`.
     - **Section: Cash & Liquid Reserves:** Sub-total metric, accounts grid with institution, balance, and quick view.
     - **Section: Investments & Retirement:** Sub-total metric, accounts grid with holdings count, market value, and tax treatment.
     - **Section: Debts & Liabilities:** Sub-total metric, liability accounts with outstanding balances and credit status.

4. **Integration Testing & 12 Gate Verification:**
   - Enhance `test/phase6_test.rb` to assert executive net worth calculation, tiered account rendering, and balance-sheet integrity.
   - Run all 12 gate legs to ensure zero regressions across grammar, styles, layouts, promises, conventions, vitals, and tests.
