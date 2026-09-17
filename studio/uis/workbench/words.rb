# frozen_string_literal: true

require_relative '../words'

# The workbench's own vocabulary. Like the classic UI's, it adds nothing yet:
# every word this UI needs was already the language's own, or the shared
# interface kata's. That is the finding to watch as the UIs multiply — a word
# one UI needs is that UI's business, a word two UIs need is evidence for the
# language, and neither UI asking for anything is evidence for the vocabulary.
module WorkbenchWords
  include StudioUI
end
