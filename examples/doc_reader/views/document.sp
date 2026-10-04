page document, .title
  card
    grid metrics, columns: 3
      metric word_count
      metric reading_minutes
      metric changed_on
    choose
      when .history?
        badge warning, "History — not needed to learn the language"
      when .for_users?
        badge ok, "Start here"
      otherwise
        badge pending, "For people changing the language"
  section chapters
    empty "No chapters."
    list
      each chapter
        item .text
  prose markdown, .content
