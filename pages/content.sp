page pattern, pattern.title
  badge .category
  badge .status

  fact origin, .origin_project
  fact source, .origin_file

  section "Conceptual specification and thinking"
    prose .content

  aside
    section "Applied in projects"
      empty "No other projects declare this pattern yet."
      list plain
        each project
          item
            link show, .path
            note quiet, .purpose

    section "Agent lore snippet"
      note quiet, "Feed this to any agent before beginning development."
      snippet .lore

