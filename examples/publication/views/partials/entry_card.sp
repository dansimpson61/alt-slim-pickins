card
  title .title
  time .date
  badge .author
  each word, from: .words
    badge .to_s
  actions
    link entry, "Read", to: "/entries/#{entry.id}"
