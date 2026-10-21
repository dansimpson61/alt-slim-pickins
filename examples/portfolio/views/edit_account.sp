account, "Edit Account"
  form to: "/accounts/#{account.id}", method: patch
    choose
      when .errors?
        note error, "Please correct the errors below."
    field name, required: true
    field institution, required: true
    choice account_type, "Account Type"
      option "brokerage", "Taxable Brokerage"
      option "roth_ira", "Roth IRA"
      option "traditional_ira", "Traditional IRA"
      option "savings", "High-Yield Savings"
    actions
      button "Save Changes"
      link cancel, "Cancel", to: "/accounts/#{account.id}"
