page scenario, "Directional Roth Conversion Sketch"
  form to: run, method: post
    group ages
      field age_primary, "Age (primary)"
      field age_spouse, "Age (spouse)"
    group balances
      field trad_balance, "Traditional balance"
      field roth_balance
      field base_income
    group social_security
      field ss_primary_start_year, "SS start (years from now)"
      field ss_primary_amount, "SS annual amount"
      field ss_spouse_start_year, "Spouse SS start (years from now)"
      field ss_spouse_amount, "Spouse SS annual amount"
    disclosure "Show advanced assumptions"
      field growth_rate
      field inflation_rate, "Inflation"
      field horizon_years, "Horizon (years)"
    group conversion, "Conversion strategy"
      select conversion_strategy, "Strategy"
        option fixed, "Fixed amount"
        option fill_bracket, "Fill bracket"
      field conversion_value, "Strategy value"
    actions
      button primary, "Run"
