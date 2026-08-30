page portfolio, "Your retirement"
  section "Where you stand"
    money .total_value
    percent .ytd_return
  section accounts, "Your accounts"
    empty "No accounts linked yet."
    each account
      account_card
