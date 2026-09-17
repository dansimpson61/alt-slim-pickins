# A word's page, as a state of the workbench rather than a page of its own.
#
# The library shelf keeps the word's contract, its implementation and the real
# sentences that use it; picking an example seeds the editor beside them. This
# is why there is one editor: the classic UI's `try_it` pane was a second copy
# of this form, and a copy is where a decision gets a second home.
page .title
  word_docs
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
                link_to "Try it in the editor", to: try, path: .try_path
            choose
              when .note
                note quiet, .note
    panes
      editor
      output
