# The docs page's try-it pane: the same editor and outputs the playground
# uses, minus the palette, with the two outputs side by side. The form's two
# buttons target the two iframes — the burr's pattern, deliberate here too:
# one click renders one output. The burr's resolution, when it lands,
# obviates both buttons on both pages.

box
  section .editor_title
    editor_form
    note quiet, .data_note
    grid columns: 2
      preview
      html_preview
