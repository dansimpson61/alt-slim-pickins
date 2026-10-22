holding, "Edit position"
  actions
    link back, "← Back to account", to: "/accounts/#{holding.account_id}"
  form method: put, to: "/holdings/#{holding.id}"
    choose
      when .errors?
        note error, "Please correct the errors below."
    field symbol, "Ticker Symbol", placeholder: "e.g. VTI", required: true
    field shares, "Number of Shares", placeholder: "0.00", required: true
    field cost_basis, "Cost Basis ($)", placeholder: "0.00", required: true
    field current_price, "Current Price ($)", placeholder: "0.00", required: true
    actions
      button "Save changes"
      link cancel, "Cancel", to: "/accounts/#{holding.account_id}"
