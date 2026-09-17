# The frame's own vitals, stated once and truthfully.
#
# Every number here is the record's, held in `studio/vitals.rb` so the footer
# has one home; the instruments that measure them are the gate's legs, and the
# status page runs them live. This is not a second instrument — it is the frame
# telling you what you are working in.
#
# The partial is `foot`, not `studio_footer`: a partial that says its own name
# calls itself, and this one did until it overflowed the stack.
footer
  fact words, .word_count
  fact conventions, .convention_count
  fact promises, .promise_count
  note quiet, "One sentence: word arguments. Indentation nests it."
