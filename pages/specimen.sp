page specimen, "slim-pickins — every word"
  section "Headings and prose"
    title "A title, one level down"
    text .blurb
    note "A plain note."
    note quiet, "A quiet note — smaller, fainter."
    note warning, "A warning note."
    prose .markdown

  section "Facts, badges, moments"
    fact origin, .origin
    fact reviewed_on
    badge ok, "canonical"
    badge warning, "emerging"
    badge blocker, "broken"
    text "Rendered on:"
    time .reviewed_on

  section "Numbers"
    grid metrics, columns: 4
      metric total_value, "Total value"
      metric ytd_return, "YTD return"
      metric holdings_count, "Holdings"
      metric worst_day, "Worst day"
    text "The same values as bare words rather than tiles:"
    list plain
      item
        money .total_value
      item
        percent .ytd_return
      item
        number .holdings_count
      item
        money .worst_day

  section "A table that writes no loop"
    table holdings
      column symbol
      column shares
      column market_value, "Value"
      column gain
      column weight
      total market_value, "Total"

  section "Situations"
    choose
      when .drifted?
        note warning, "Allocation has drifted."
      otherwise
        note quiet, "Allocation is on target."

  section nothing, "An empty section"
    empty "Nothing here yet — and the siblings are suppressed."
    text "You should not see this."

  section "Lists, cards and media"
    grid cards, columns: 2
      card
        title "A card"
        text .blurb
        actions
          link show, "Details"
          link edit
      card compact
        title "A compact card"
        list plain
          item
            icon blocker
            text "Blocks the task outright."
          item
            icon warning
            text "Works, but costs the reader."
          item
            icon polish
            text "Cosmetic."

  section "Figures and code"
    figure "A chart, captioned as a figure"
      chart line, .balances, over: .years
    chart pie, .allocation, label: "Allocation"
    snippet ruby, .example

  section "A form"
    form to: save, method: post
      group amounts
        field amount
        field rate
      group timing
        select frequency, "How often"
          option monthly, "Monthly"
          option quarterly, "Quarterly"
        check auto_invest, "Invest automatically"
      disclosure "Show advanced assumptions"
        field growth_rate
        field horizon_years
      actions
        button primary, "Save"
        link cancel, "Never mind"

  aside
    title "An aside"
    note quiet, "Everything not in an aside is the main column."
