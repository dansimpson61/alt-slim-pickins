page .title
  stylesheet "/assets/slim-pickins.css"
  sidebar_layout
    vocabulary
    scroll
      prose plain, .overview
      each result
        section .name
          badge .state
          prose markdown, .fenced
