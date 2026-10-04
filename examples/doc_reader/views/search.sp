page query, "Search the documents"
  form to: "/search", method: get
    group "Look for"
      field q
      field include_history
    actions
      button "Search"
  section results
    empty "Nothing matched."
    each result
      document_card
