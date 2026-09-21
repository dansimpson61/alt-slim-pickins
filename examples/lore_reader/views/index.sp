page "The Lore Reader"
  section stats, "Archive Overview"
    grid metrics, columns: 4
      metric total_entries, "Total Entries"
      metric distinct_authors, "Authors"
      metric first_date, "First Entry"
      metric last_date, "Latest Entry"
  form to: "/", method: get
    input q, placeholder: "Search lore by topic, word, or author..."
    button "Search"
  section entries, "Timeline"
    empty "No entries found matching your search."
    each entry
      lore_card
