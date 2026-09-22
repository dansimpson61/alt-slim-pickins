page "The Lore Reader"
  section stats, "Archive Overview"
    grid metrics, columns: 4
      metric total_entries, "Total Entries"
      metric distinct_authors, "Authors"
      metric first_date, "First Entry"
      metric last_date, "Latest Entry"
  search placeholder: "Search lore by topic, word, or author...", to: "/"
  section entries, "Timeline"
    empty "No entries found matching your search."
    each entry
      lore_card
