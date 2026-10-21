section projection, "Your projection"
  each complaint
    note warning, .description

  grid metrics, columns: 3
    metric lifetime_taxes_primary
    metric lifetime_taxes_baseline
    metric tax_delta
    metric final_roth_primary
    metric final_roth_baseline
    metric roth_delta

  figure "Where each year's income comes from, and the tax it attracts"
    chart years
      level .standard_deduction, "Standard deduction"
      each bracket
        level .ceiling, .label
      band base_income
      band social_security
      band rmd
      band conversion
      line federal_tax
      line gross_income, "Do nothing", from: .baseline_years

  figure "Traditional against Roth, over the whole horizon"
    chart years
      band trad_end
      band roth_end

  table years, "Year by year"
    column year
    column age_primary
    column base_income
    column social_security
    column rmd
    column conversion
    column federal_tax
    column irmaa_applied_cost
    column trad_end
    column roth_end

  aside
    title "What this engine gets wrong"
    note quiet, "The architecture is ported; the arithmetic is roth's own, defects included."
    list plain
      each defect
        item .description
