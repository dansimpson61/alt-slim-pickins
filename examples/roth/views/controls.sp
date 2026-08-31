page "Directional Roth Conversion Sketch"
  note "Approximate multi-year impact; coarse assumptions; not tax advice."

  form controls, to: "/run"
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
      select conversion_strategy
        option fixed, "Fixed amount"
        option fill_bracket, "Fill bracket"
      field conversion_value
    actions
      button primary, "Run"

  grid metrics, columns: 3
    pending lifetime_taxes_primary, "Lifetime taxes (primary)"
    pending lifetime_taxes_baseline, "Lifetime taxes (baseline)"
    pending tax_delta, "Tax delta"
    pending final_roth_primary, "Final Roth % (primary)"
    pending final_roth_baseline, "Final Roth % (baseline)"
    pending roth_delta, "Roth % delta"

  section "Income & taxes"
    check show_baseline
    balance_chart

  disclosure "Show raw JSON"
    raw_output

  footer "This tool provides approximate directional estimates. It omits many tax nuances (credits, deductions, capital gains, phaseouts, state tax). Use for planning ranges only."

  stylesheet "/assets/slim-pickins.css"
  stylesheet "/css/roth.css"
  script "/js/app.js"
