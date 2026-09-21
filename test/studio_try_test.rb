# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../studio/docs_helper'
require_relative '../studio/pages'

# The try-it's acceptance: every word's first example, seeded and rendered
# exactly as the try-it would. A useful word must show the word's own
# effect — the word's class by default, a named needle where the effect is
# an element or a content line — and the structural words carry their note
# and no link at all. Re-measured 2026-09-15: 62 useful, 2 structural, 0
# refusals; a regression flips a row, and this test is the ledger.
class StudioTryTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  STRUCTURAL = %w[contents children].freeze

  # Words whose effect is not their own class — an element tag, a content
  # line, or a note beside a working link.
  NEEDLES = {
    'page' => '<body',
    'stylesheet' => '<link',
    'script' => '<script',
    'hidden' => 'type="hidden"',
    'input' => '<input',
    'search' => '<input',
    'textarea' => '<textarea',
    'checkbox' => 'type="checkbox"',
    'choice' => '<select',
    'option' => '<option',
    'chart' => 'svg',
    'band' => 'svg',
    'line' => 'svg',
    'level' => 'svg',
    'each' => 'Traditional IRA',
    'choose' => 'Allocation has drifted.',
    'when' => 'Allocation has drifted.',
    'column' => 'Symbol',
    'total' => '<tfoot',
    'figcaption' => '<figcaption',
    'summary' => '<summary',
    'flash' => 'A page waiting for its ruling.'
  }.freeze

  # Words whose seed works but shows itself only under data the pre-fill
  # does not carry — they keep the link, beside the note.
  NOTED = %w[empty otherwise].freeze

  def vocabulary
    File.read(File.join(ROOT, 'VOCABULARY.md')).scan(/^### `([a-z_]+)`/).flatten
  end

  def test_every_words_try_it_yields
    # The studio's own boot is a clean process that owns its registry; in
    # this shared suite, rebuilding the merged library at use time is what
    # makes the studio's words the studio's words (last compile wins).
    library = StudioPages.merge_libraries([*StudioPages.library_dirs, Uis['classic'].views],
                                          words: [AppWords, ClassicWords])
    assert_equal 62, vocabulary.size - STRUCTURAL.size, 'the yield moved — re-measure'

    vocabulary.each do |word|
      ex = StudioDocs.examples_of(word) { |p, c| StudioPages.data_json_for(p, c) }.first
      refute_nil ex, "#{word} has no example"

      if STRUCTURAL.include?(word)
        assert_nil ex.try_path, "#{word} is structural and must not link"
        refute_empty ex.note, "#{word} carries no note"
        next
      end

      refute_nil ex.try_path, "#{word} has no try-it"
      html = SlimPickins.render(StudioDocs.seed_for(word, 0), path: 'try.sp',
                                locals: StudioPages.playground_locals(ex.data.to_s),
                                library: library)
      if NOTED.include?(word)
        refute_empty ex.note, "#{word}'s demonstration note is missing"
        next
      end

      needle = NEEDLES[word] || %(class="#{word})
      assert_includes html, needle, "#{word}'s try-it does not show the word"
    end
  end
end
