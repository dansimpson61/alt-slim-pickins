title .name
choose
  when .holdings
    table holdings
      column symbol
      column shares, as: number
      column market_value, "Value", as: money
      column gain, as: money
      column weight, as: percent
      total market_value, "Account total"
  otherwise
    grid metrics, columns: 2
      metric .institution, "Institution"
      metric .display_balance, "Balance", as: money
contents
