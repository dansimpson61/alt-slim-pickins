portfolio, "Your retirement"
  section "Where you stand"
    grid metrics, columns: 3
      metric total_value, as: money
      metric ytd_return, "YTD return", as: percent
      metric annual_income, "Projected income", as: money
  section accounts, "Your accounts"
    empty "No accounts linked yet."
    each account
      card
        actions
          link show, "Details", to: "/accounts/#{account.id}"
  actions
    link open, "Open new account", to: "/accounts/new"
