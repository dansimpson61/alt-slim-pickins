# frozen_string_literal: true

module SlimPickins
  # `icon warning` referenced a sprite symbol and nothing defined it, so the
  # word rendered an empty box. The vocabulary names these variants, so the
  # vocabulary ships them: `page` emits the sprite once, the way it emits the
  # doctype — inferable, and therefore never written in a page.
  module Icons
    SYMBOLS = {
      warning: '<path d="M12 2 1 21h22z" fill="none" stroke="currentColor" stroke-width="2"/>' \
               '<path d="M12 9v5M12 17.5v.5" stroke="currentColor" stroke-width="2"/>',
      blocker: '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>' \
               '<path d="M6 6 18 18" stroke="currentColor" stroke-width="2"/>',
      polish: '<circle cx="12" cy="12" r="4" fill="currentColor"/>',
      ok: '<path d="M4 13l5 5L20 6" fill="none" stroke="currentColor" stroke-width="2"/>',
      error: '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>' \
             '<path d="M12 7v6M12 16.5v.5" stroke="currentColor" stroke-width="2"/>',
      pending: '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>' \
               '<path d="M12 7v5l3 3" fill="none" stroke="currentColor" stroke-width="2"/>',
      neutral: '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>'
    }.freeze

    # Only the symbols a page actually uses. `page` renders its children
    # first, so by the time the document is assembled it knows which.
    def self.sprite(used)
      wanted = SYMBOLS.slice(*Array(used).uniq)
      return '' if wanted.empty?

      '<svg xmlns="http://www.w3.org/2000/svg" style="display:none" aria-hidden="true">' +
        wanted.map { |name, body| %(<symbol id="icon-#{name}" viewBox="0 0 24 24">#{body}</symbol>) }.join +
        '</svg>'
    end
  end
end
