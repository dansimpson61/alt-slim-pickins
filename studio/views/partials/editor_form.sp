# Live rendering — the recorded burr's resolution, and its natural end.
# The burr's why, preserved: one form can target only one iframe natively,
# so the studio once needed two Render buttons. A Stimulus controller now
# renders as the writer types and once on load, so no button remains —
# dan's ruling (2026-09-15): live rendering made it redundant, and what a
# change makes redundant gets cut. Rendering now requires JavaScript,
# which the studio says rather than hides.

wired_form
  textarea source, rows: 4, required: true
  textarea data, "Data (JSON)", rows: 2
