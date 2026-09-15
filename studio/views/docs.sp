page .title
  stylesheet "/assets/slim-pickins.css"
  script "/assets/stimulus.umd.js"
  script "/assets/studio_controller.js"
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
                snippet sp, .context
                note quiet, .where
                choose
                  when .try_path
                    link "Try it", to: .try_path
                choose
                  when .note
                    note quiet, .note
      try_it
