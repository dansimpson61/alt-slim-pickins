# frozen_string_literal: true

# The workbench: the studio rewritten around the person making a page.
#
# The design's argument, in one line: a UI has three intents — what you draw
# on (the library), what you write (the editor), and what you look at (the
# artifact) — and each gets a size that follows from what it is rather than
# an equal fraction. The frame is the language's own: `layout.sp` declares the
# assets and the chrome once, and `page` infers it, so no page here mentions
# either.
#
# `/docs/:word` is a state of this workbench, not a page: a word's contract
# and its examples join the library shelf, and picking one fills the editor.
# Its own path templates say so.
module UIWorkbench
  TITLE = 'Workbench'
  DESIGN = <<~DESIGN
    One workbench, the library a movable shelf. A menu names where you are;
    one shelf holds the words, the repo's pages and the guides; the editor
    holds two texts and one artifact, and nothing else competes with them.
    The frame is `layout.sp` — inferred by `page`, never mentioned by a page —
    so the assets and the chrome have one home. A word's docs are a state of
    the shelf rather than a page of their own, which is what lets the editor
    be one editor.
  DESIGN

  def self.paths = {
    home: '/?ui=:ui',
    load: '/?load=:id&ui=:ui',
    word: '/docs/:word?ui=:ui',
    try: '/docs/:word?try=:n&ui=:ui',
    guide: '/guides/:name?ui=:ui',
    status: '/status?ui=:ui',
    switch: '/ui/:name'
  }
end
