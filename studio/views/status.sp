page .title
  stylesheet "/assets/slim-pickins.css"
  sidebar_layout
    vocabulary
    scroll
      prose plain, .overview
      each result
        section .name
          list plain
            item
              icon .state
              badge .state
          prose markdown, .fenced
