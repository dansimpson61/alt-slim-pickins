page "Triage"
  text "One project at a time, hardest first."
  choose
    when .notice
      flash .notice
  choose
    when .unreviewed
      unreviewed_card
  queue
