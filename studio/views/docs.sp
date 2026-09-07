page .title
  stylesheet "/assets/slim-pickins.css"
  sidebar_layout
    vocabulary
    scroll
      note warning, "The contract renders completely. The implementation's source is shown, but code blocks are not yet formatted as code — prose learns fences in roadmap 0.2, Phase 5. Only the code's shape is early."
      section "Contract"
        prose markdown, .contract
      section "Implementation"
        prose markdown, .implementation
