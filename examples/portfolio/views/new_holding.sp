holding, "Add position"
  actions
    link back, "← Back to account", to: "/accounts/#{holding.account_id}"
  form to: "/accounts/#{holding.account_id}/holdings"
    choose
      when .errors?
        note error, "Please correct the errors below."
    field symbol, "Ticker Symbol", placeholder: "e.g. VTI, AAPL", required: true
    field shares, "Number of Shares", placeholder: "0.00", required: true
    field cost_basis, "Cost Basis ($)", placeholder: "0.00", required: true
    field current_price, "Current Price ($)", placeholder: "Optional (defaults to cost basis)"
    actions
      button "Add position"
      link cancel, "Cancel", to: "/accounts/#{holding.account_id}"
