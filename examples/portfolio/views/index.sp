portfolio, "Your retirement"
  actions
    link open, "Open new account", to: "/accounts/new"
    link ledger, "Activity Ledger", to: "/transactions"
  section "Executive Balance Sheet"
    grid metrics, columns: 4
      metric .net_worth, "Net worth", as: money
      metric .total_assets, "Total assets", as: money
      metric .total_debt, "Total liabilities", as: money
      metric .liquid_cash, "Liquid reserves", as: money
  section "Performance & Projected Yield"
    grid metrics, columns: 2
      metric .ytd_return, "YTD return", as: percent
      metric .annual_income, "Projected annual income", as: money
  section banking_accounts, "Cash & Liquid Reserves"
    empty "No cash or banking accounts linked."
    each banking_account
      card
        actions
          link show, "Details", to: "/accounts/#{banking_account.id}"
          link record, "+ Record transaction", to: "/accounts/#{banking_account.id}/transactions/new"
  section investment_accounts, "Investments & Retirement"
    empty "No investment accounts linked."
    each investment_account
      card
        actions
          link show, "Details", to: "/accounts/#{investment_account.id}"
          link add_pos, "+ Add holding", to: "/accounts/#{investment_account.id}/holdings/new"
  section liability_accounts, "Debts & Liabilities"
    empty "No debt or liability accounts linked."
    each liability_account
      card
        actions
          link show, "Details", to: "/accounts/#{liability_account.id}"
          link record, "+ Record payment / charge", to: "/accounts/#{liability_account.id}/transactions/new"
