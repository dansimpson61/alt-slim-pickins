page scenario, "Directional Roth Conversion Sketch"
  form to: run, method: post
    group ages
      field age_primary
      field age_spouse
    group balances
      field trad_balance
      field roth_balance
      field base_income
    group social_security
      field ss_primary_start_year
      field ss_primary_amount
      field ss_spouse_start_year
      field ss_spouse_amount
    disclosure "Show advanced assumptions"
      field growth_rate
      field inflation_rate
      field horizon_years
    group conversion, "Conversion strategy"
      select conversion_strategy
        option fixed, "Fixed amount"
        option fill_bracket, "Fill bracket"
      field conversion_value
    actions
      button primary, "Run"
