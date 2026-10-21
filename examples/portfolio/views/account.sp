account, "Account detail"
  card
    actions
      link edit, "Edit account", to: "/accounts/#{account.id}/edit"
      link close, "Close account", to: "/accounts/#{account.id}/close"
  video .tour_url
