page "Directional Roth Conversion Sketch"
  note "Approximate multi-year impact; coarse assumptions; not tax advice."

  form scenario, to: "/projection"
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
    disclosure "Show advanced assumptions"
      field growth_rate
      field inflation_rate
      field horizon_years
    group conversion, "Conversion strategy"
      choice conversion_strategy
        option fixed, "Fixed amount"
        option fill_bracket, "Fill bracket"
      field conversion_value
    actions
      button primary, "Run"

  report

  footer "This tool provides approximate directional estimates. It omits many tax nuances (credits, deductions, capital gains, phaseouts, state tax). Use for planning ranges only."

  stylesheet "/assets/slim-pickins.css"
  stylesheet "/css/roth.css"
  script "/js/app.js"
