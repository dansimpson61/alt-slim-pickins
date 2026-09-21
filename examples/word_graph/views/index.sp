page "The Word Graph"
  card
    title "The Word Graph"
    paragraph "Explore the 64 words of alt-slim-pickins, their structural shapes, parts of speech, and contract relationships."
    grid metrics, columns: 4
      metric total_words, "Total Words"
      metric total_shapes, "Shapes"
      metric gatherers_count, "Gatherers"
      metric registers_count, "Registers"
      metric nouns_count, "Nouns"
      metric non_nouns_count, "Control Flow"
      metric total_conventions, "Conventions"
      metric explicit_edges_count, "Explicit Edges"

  section "Filter Vocabulary"
    form
      input q, placeholder: "Search word, shape, speech, modifier, convention..."
      actions
        button "Search"

  section "Structural Shape Distribution"
    paragraph "The 64 words partition into 7 structural shapes. View the distribution chart and shape analysis."
    actions
      link "View Shapes & Distribution Chart", to: "/shapes"
      link "View Tabular Connection Matrix", to: "/matrix"

  section "Vocabulary Words"
    empty "No words matched your query."
    grid cards, columns: 2
      each word
        word_card
