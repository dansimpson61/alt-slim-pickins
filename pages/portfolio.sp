page portfolio, "Your retirement"
  section "Where you stand"
    time .as_of
    grid metrics, columns: 4
      metric total_value, "Total value"
      metric ytd_return, as: percent
      metric annual_income, "Projected income"
      metric years_to_rmd, "Years to RMD"

  section "Allocation"
    chart pie, .allocation, label: "By asset class"

    choose
      when .drifted?
        note warning, "Your allocation has drifted more than five percent."
      otherwise
        note quiet, "Allocation is on target."

    table targets
      column asset_class, "Asset class"
      column target, as: percent
      column actual, as: percent
      column drift, as: percent

  section accounts, "Your accounts"
    empty "No accounts linked yet."

    each account
      card
        title .name

        grid metrics, columns: 3
          metric balance
          metric contribution_room, "Room this year"
          metric tax_treatment, "Tax treatment"

        table holdings
          column symbol
          column shares, as: number
          column market_value, "Value"
          column gain, as: money
          column weight, as: percent
          total market_value, "Account total"

        actions
          link show, "Details"
          link rebalance

  section "Projections"
    chart line, .balances, over: .years

    disclosure "Show advanced assumptions"
      field growth_rate, step: 0.01
      field inflation_rate, step: 0.01
      field horizon_years

    note "Coarse assumptions. Directional estimates only. Not tax advice."

  section contribution, "Make a contribution"
    form to: contribute, method: post
      group amounts
        field amount
        select account_id, "Account"
      group timing
        field frequency
        check auto_invest, "Invest automatically"
      actions
        button primary, "Contribute"
        link cancel, "Never mind"

