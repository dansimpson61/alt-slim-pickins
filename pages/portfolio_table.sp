page portfolio, "Your retirement"
  section "Where you stand"
    money .total_value
    percent .ytd_return
  section accounts, "Your accounts"
    empty "No accounts linked yet."
    each account
      title .name
      table holdings
        column symbol
        column shares
        column market_value, "Value"
        column gain
        column weight
        total market_value, "Account total"
