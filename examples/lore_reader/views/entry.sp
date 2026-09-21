page entry, entry.title
  link home, "← Back to Timeline", to: "/"
  card
    time .date
    badge .author
    each tag, from: .tags
      badge .to_str
    prose markdown, .body
    section words, "Words Mentioned"
      empty "No vocabulary words indexed in this entry."
      each word
        badge .to_str
