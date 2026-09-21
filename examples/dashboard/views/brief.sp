page .page_title
  nav
    link "← Back to Project", to: .project_href
    link "← Back to Studio", to: "/"
  paragraph "Session resume card and architectural orientation"
  actions
    link "Raw Text (for curl)", to: .raw_href
    link "Edit Card", to: .project_href
  choose
    when .notice
      flash .notice
  card
    prose markdown, .brief_markdown
