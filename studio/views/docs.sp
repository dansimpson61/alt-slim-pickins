page .title
  stylesheet "/assets/slim-pickins.css"
  sidebar_layout
    vocabulary
    split_pane
      scroll
        section "Contract"
          prose markdown, .contract
        section "Implementation"
          prose markdown, .implementation
        section "In the wild"
          list
            each example, from: .examples
              item
                snippet sp, .body
                note quiet, .where
                link "Try it", to: .try_path
      try_it
