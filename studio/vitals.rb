# frozen_string_literal: true

require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/census'

# The studio's own vitals: the numbers the footer states about the language
# you are working in.
#
# They are read from `SlimPickins::Census`, which computes them from the tree,
# rather than kept here as literals. They used to be literals — `WORDS = 64`,
# `PROMISES = 32`, dated `2026-09-17` — and by 2026-09-26 they were wrong: the
# vocabulary had come down to 62 and the ledger up to 35, so the studio's own
# footer stated counts the census disagreed with. A hand-kept copy of a live
# number is the drift this project keeps writing down and keeps committing
# anyway; the fix is not to re-read the literal but to stop having one.
#
# The catalogue numbers are deliberately *not* here: `StudioPages::PAGES` is
# the shelf's own list and changes when the shelf does, which is why the
# footer's page count is computed at the call site rather than stated here.
module StudioVitals
  WORDS = SlimPickins::Census.words[:total].size
  CONVENTIONS = SlimPickins::Census.conventions_count
  PROMISES = SlimPickins::Census.promises_count
end
