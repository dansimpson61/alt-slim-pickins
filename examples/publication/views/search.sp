query, "Search the publication"
  form to: "/search", method: get
    group "Look for"
      field q, "Words to find"
      field include_history, "Include the history"
    actions
      button "Search"
  section results
    empty "Nothing matched."
    each result
      document_card
