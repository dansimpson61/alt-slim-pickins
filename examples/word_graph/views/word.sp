page .word_name
  card
    title .word_name
    choose
      when .is_gatherer
        badge ok, "Gatherer"
      when .is_register
        badge neutral, "Register"
      when .is_control
        badge warning, "Control Flow"
      otherwise
        badge neutral, .shape_name
    grid metrics, columns: 3
      metric connections_count, "Connections"
      metric in_degree, "Parents"
      metric out_degree, "Children"

  section "Contract Specifications"
    fact speech_name
    fact subject_name
    fact parents_summary
    fact children_summary
    fact conventions_summary
    fact modifiers_summary

  section "Enclosing Parents"
    choose
      when .has_explicit_parents
        grid cards, columns: 2
          each parent, from: .parents
            card
              title .word_name
              badge neutral, .shape_name
              actions
                link "Inspect", to: "/words/#{parent.word_name}"
      otherwise
        paragraph "Nests inside any enclosing container (page, section, box, card, etc.)."

  section "Enclosed Children"
    choose
      when .has_explicit_children
        grid cards, columns: 2
          each child, from: .children
            card
              title .word_name
              badge neutral, .shape_name
              actions
                link "Inspect", to: "/words/#{child.word_name}"
      otherwise
        choose
          when .is_leaf
            paragraph "Leaf element — holds no nested children."
          otherwise
            paragraph "Container element — holds any valid child element."

  section "Shape Peers"
    grid cards, columns: 3
      each peer, from: .peers
        card
          title .word_name
          badge neutral, .shape_name
          actions
            link "Inspect", to: "/words/#{peer.word_name}"

  actions
    link "Back to Word Graph", to: "/"
