page portfolio, "Your retirement"
  section "Where you stand"
    grid metrics, columns: 3
      metric total_value, "Total value"
      metric ytd_return, "YTD return"
      metric annual_income, "Projected income"
  section accounts, "Your accounts"
    empty "No accounts linked yet."
    each account
      card
        account_card
        actions
          link show, "Details"
