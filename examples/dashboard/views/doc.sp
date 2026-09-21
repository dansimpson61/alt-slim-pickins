page .page_title
  nav
    link "← Back to Project", to: .project_href
    link "← Back to Studio", to: "/"
  paragraph .doc_path
  choose
    when .notice
      flash .notice
  card
    prose markdown, .content
