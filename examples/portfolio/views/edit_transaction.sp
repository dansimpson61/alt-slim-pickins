activity, "Edit Transaction"
  actions
    link back, "← Back to account", to: "/accounts/#{activity.account_id}"
  form method: put, to: "/transactions/#{activity.id}"
    choose
      when .errors?
        note error, "Please correct the errors below."
    field date, "Transaction Date", placeholder: "YYYY-MM-DD", required: true
    field merchant, "Merchant / Payee", placeholder: "e.g. Trader Joe's, Shell", required: true
    field category, "Category", placeholder: "e.g. Groceries, Dining, Gas", required: true
    field amount, "Amount ($)", placeholder: "e.g. -45.00", required: true
    field description, "Description / Notes", placeholder: "Optional notes"
    actions
      button "Save changes"
      link cancel, "Cancel", to: "/accounts/#{activity.account_id}"
