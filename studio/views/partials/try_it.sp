# The docs page's try-it pane: the same editor and outputs the playground
# uses, minus the palette, with the two outputs side by side.
#
# The burr is gone (2026-09-15): one form used to need two Render buttons
# because a form can target only one iframe natively; a Stimulus controller now
# renders live, debounced, once on load, so no button remains. This comment
# said otherwise until 2026-09-17 — its sibling in editor_form.sp was updated
# when the burr was resolved and this copy was not, which is what a second home
# for a decision costs.

box
  section .editor_title
    editor_form
    note quiet, .data_note
    grid columns: 2
      preview
      html_preview
