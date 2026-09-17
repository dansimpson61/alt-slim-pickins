# frozen_string_literal: true

# The studio's own vitals: the numbers the footer states about the language
# you are working in.
#
# These are the *record's* numbers, held here so the footer has one source
# rather than a literal scattered in a view. They are not measured by this
# module — the instruments measure them — so they carry the date they were
# read, and a session that changes one of them is the session that re-reads
# them. A vitals line that drifts is a vitals line that lies, which is the
# whole subject of DAYTRIP-0.3.0b.
module StudioVitals
  MEASURED = '2026-09-17'

  WORDS = 64
  CONVENTIONS = 38
  PROMISES = 32
end
