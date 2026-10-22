account, "Account detail"
  title .name
  actions
    link back, "← All accounts", to: "/"
    link edit, "Edit account", to: "/accounts/#{account.id}/edit"
    link close, "Close account", to: "/accounts/#{account.id}/close"
  section "Account overview"
    grid metrics, columns: 3
      metric total_value, "Total value", as: money
      metric cash_balance, "Cash balance", as: money
      metric gain, "Unrealized gain", as: money
  section "Portfolio holdings"
    table holdings
      column symbol, "Symbol"
      column shares, "Shares", as: number
      column cost_basis, "Cost basis", as: money
      column current_price, "Current price", as: money
      column market_value, "Market value", as: money
      column gain, "Gain / Loss", as: money
      column weight, "Weight", as: percent
      total market_value, "Account total"
  actions
    link add_holding, "+ Add holding", to: "/accounts/#{account.id}/holdings/new"
  section "Manage positions"
    each holding
      box
        title holding.symbol
        grid metrics, columns: 3
          metric shares, "Shares", as: number
          metric market_value, "Value", as: money
          metric gain, "Gain", as: money
        actions
          link edit, "Edit position", to: "/holdings/#{holding.id}/edit"
          link sell, "Liquidate", to: "/holdings/#{holding.id}/sell"
  section "Recent activity"
    empty "No transactions recorded for this account yet."
    table transactions
      column date, "Date"
      column merchant, "Merchant / Payee"
      column category, "Category"
      column description, "Description"
      column amount, "Amount", as: money
  actions
    link add_tx, "+ Record transaction", to: "/accounts/#{account.id}/transactions/new"
  section "Account tour"
    video .tour_url
