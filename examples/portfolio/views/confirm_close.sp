account, "Close Account"
  card
    title "Are you sure you want to close this account?"
    text "Closing this account will delete all holdings and transaction history. This action cannot be undone."
    form to: "/accounts/#{account.id}", method: delete
      actions
        button danger, "Yes, Close Account"
        link cancel, "Never mind", to: "/accounts/#{account.id}"
