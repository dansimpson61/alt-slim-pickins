page .title
  nav
    link "← Back to Library", to: "/library"
    link "← Back to Studio", to: "/"
  badge neutral, .category_name
  choose
    when .emerging
      badge pending, "emerging"
    otherwise
      badge ok, "canonical"
  paragraph .origin_line
  choose
    when .notice
      flash .notice
  grid cards, columns: 2
    section "Conceptual Specification & Thinking"
      card
        prose markdown, .content
    section "Pattern Applications & Agent Lore"
      card
        title "Applied in Projects"
        choose
          when .has_projects
            each project, from: .projects
              card
                title .path
                paragraph .purpose
                actions
                  link "Open Project", to: "/projects/#{project.path}"
          otherwise
            paragraph "No other projects declare this pattern yet."
      card
        title "Agent Lore Snippet"
        paragraph "Feed this conceptual lore to any AI agent before beginning development:"
        snippet .lore
