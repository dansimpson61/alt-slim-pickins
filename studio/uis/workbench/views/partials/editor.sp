# Where the page is written: two texts and nothing else.
#
# `textarea`, not `field`: a page's source is many lines, and the language has
# a word for that. The two texts are pure language — the labels are content,
# the names are subjects — and the single `wired_form` around them is the
# shared render seam, so this is one editor, not a second copy of one.
box
  section .editor_title
  wired_form
    textarea source, "Page (Substance)", rows: 14
    textarea design, "Design Idiom (.design)", rows: 9
    textarea data, "Data (JSON)", rows: 5
    note quiet, .data_note
