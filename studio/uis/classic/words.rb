# frozen_string_literal: true

require_relative '../words'

# The classic UI's vocabulary. Its one word is the render seam, which every
# UI needs; the shared module holds it, so this file exists to say that this
# UI adds nothing of its own — which is itself a fact worth reading, because
# the classic UI is the one that never asked the language for anything.
#
# `include`, not `extend`: the Builder `extend`s this module to make its words
# real methods on itself, and only an *ancestor* travels that road. `extend`
# here would put StudioUI in this module's singleton chain, which no Builder
# will ever walk — a mistake this round made and paid for once.
module ClassicWords
  include StudioUI
end

