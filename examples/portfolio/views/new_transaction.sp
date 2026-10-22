activity, "Record Transaction"
  actions
    link back, "← Back to account", to: "/accounts/#{activity.account_id}"
  form to: "/accounts/#{activity.account_id}/transactions"
    choose
      when .errors?
        note error, "Please correct the errors below."
    field date, "Transaction Date", placeholder: "YYYY-MM-DD", required: true
    field merchant, "Merchant / Payee", placeholder: "e.g. Trader Joe's, Shell", required: true
    field category, "Category", placeholder: "e.g. Groceries, Dining, Gas", required: true
    field amount, "Amount ($)", placeholder: "e.g. -45.00 for expense, 500.00 for deposit", required: true
    field description, "Description / Notes", placeholder: "Optional notes"
    actions
      button "Record transaction"
      link cancel, "Cancel", to: "/accounts/#{activity.account_id}"
