holding, "Liquidate holding"
  box
    title "Are you sure you want to liquidate this position?"
    text "This will sell all shares and add the cash proceeds to your account balance. This action cannot be undone."
    grid metrics, columns: 2
      metric shares, "Shares to sell", as: number
      metric market_value, "Estimated proceeds", as: money
    form method: delete, to: "/holdings/#{holding.id}"
      actions
        button danger, "Liquidate position"
        link cancel, "Keep position", to: "/accounts/#{holding.account_id}"
