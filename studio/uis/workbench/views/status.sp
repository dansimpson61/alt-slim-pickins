# The gate, live. Each leg renders as a badge whose class the stylesheet
# marks, and its output through a fence — the same shape the classic UI uses,
# because a leg's state is one fact and this is one page.
page .title
  panes
    scroll
      prose plain, .overview
      each result
        section .name
          badge .state
          prose markdown, .fenced
