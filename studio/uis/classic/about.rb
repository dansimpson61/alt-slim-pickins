# frozen_string_literal: true

# The classic UI: the studio as it stood when the picker arrived.
#
# Kept whole rather than refactored, because it is the control in the
# experiment — the interface we already know the shape of, against which a
# new UI can be judged. Its design is recorded honestly: the playground
# above, the words in a sidebar, the docs on their own page with a try-it
# pane that duplicates the playground's editor.
#
# Its paths say `?ui=classic`, so `path` agrees with the routes in every
# mode: a visitor who selected this UI from the picker has it named in the
# URL, and a visitor who never picked gets the same UI from the default.
module UIClassic
  TITLE = 'Studio'
  DESIGN = <<~DESIGN
    One page, two surfaces. The workbench (`/`) carries the census palette
    above the editor and the artifact in tabs beside it; a word's docs
    (`/docs/:word`) is a page of its own — contract, implementation and
    "In the wild" prose above a try-it pane that repeats the editor. Guides
    and the live status page are separate routes with the same sidebar.
  DESIGN

  def self.paths = {
    home: '/?ui=:ui',
    load: '/?load=:id&ui=:ui',
    word: '/docs/:word?ui=:ui',
    try: '/docs/:word?try=:n&ui=:ui',
    guide: '/guides/:name?ui=:ui',
    status: '/status?ui=:ui',
    refusal: '/refusal?ui=:ui',
    switch: '/ui/:name'
  }
end
