page .title
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
                    link_to "Try it", to: try, path: .try_path
                choose
                  when .note
                    note quiet, .note
      try_it
