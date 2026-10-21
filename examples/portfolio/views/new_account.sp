account, "Open New Account"
  form to: "/accounts"
    choose
      when .errors?
        note error, "Please correct the errors below."
    field name, placeholder: "e.g. Vanguard Brokerage", required: true
    field institution, placeholder: "e.g. Vanguard", required: true
    choice account_type, "Account Type"
      option "brokerage", "Taxable Brokerage"
      option "roth_ira", "Roth IRA"
      option "traditional_ira", "Traditional IRA"
      option "savings", "High-Yield Savings"
    actions
      button "Open Account"
      link cancel, "Cancel", to: "/"
