activity, "Delete Transaction"
  box
    title "Are you sure you want to delete this transaction?"
    text "Deleting this transaction will reverse its effect on your account cash balance. This action cannot be undone."
    grid metrics, columns: 3
      metric .date, "Date"
      metric .merchant, "Merchant / Payee"
      metric .amount, "Amount", as: money
    form method: delete, to: "/transactions/#{activity.id}"
      actions
        button danger, "Delete transaction"
        link cancel, "Never mind", to: "/accounts/#{activity.account_id}"
