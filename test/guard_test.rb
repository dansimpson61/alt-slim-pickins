# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# `if:` — the universal modifier, honoured since 2026-09-17.
#
# It was documented in DESIGN.md, VOCABULARY.md and PRIMER.md and consulted by
# no code at all: a promise with no reader, found by the promise ledger
# (DAYTRIP-0.3.0b) and ruled into life by dan. The transform hoists it into a
# guard rather than leaving it to the words, because a word does not always get
# a say — an app word added through the hatch is `extend`ed onto the builder and
# never passes through the dispatch. These tests hold the behaviour the docs
# promised, and the two choices that came with it.
class GuardTest < Minitest::Test
  Account = Struct.new(:name, :idle, keyword_init: true)

  def render(source, **locals)
    SlimPickins.render(source, path: 'guard.sp', locals: locals)
  end

  # --- what the docs promised ------------------------------------------------

  def test_a_guarded_sentence_renders_when_the_condition_holds
    html = render("page \"P\"\n  note \"KEEP\", if: .show\n", show: true)

    assert_includes html, 'KEEP'
  end

  def test_a_guarded_sentence_is_absent_when_the_condition_does_not_hold
    html = render("page \"P\"\n  note \"KEEP\", if: .show\n", show: false)

    refute_includes html, 'KEEP'
    assert_includes html, '<h1>P</h1>', 'the page itself still renders'
  end

  def test_a_guarded_word_takes_its_children_with_it
    html = render("page \"P\"\n  section \"S\", if: .show\n    note \"KEEP\"\n", show: false)

    refute_includes html, 'KEEP'
    refute_includes html, 'section', 'the guarded word never ran'
  end

  def test_the_guard_is_per_row_inside_each
    html = render("page \"P\"\n  each row\n    note \"KEEP\", if: .ok?\n",
                  rows: [{ ok?: false }, { ok?: true }, { ok?: false }])

    assert_equal 1, html.scan('KEEP').size, 'one of three rows is kept'
  end

  # --- the two choices the implementation made -------------------------------

  # The guard runs *before* the sentence's other arguments, which is the same
  # choice `when` makes for its condition. A guarded sentence therefore costs
  # nothing and evaluates nothing — including the attribute a reader might have
  # mistyped. Pinned because it is invisible and could be changed by accident.
  def test_a_false_guard_runs_before_the_arguments_it_guards
    html = render("page \"P\"\n  note .missing, if: .show\n", show: false)

    refute_includes html, 'missing'
  end

  # A hatch word is `extend`ed onto the builder, so the guard cannot live in the
  # dispatch that registry words pass through. This is the test that would fail
  # if someone moved it there.
  def test_a_word_added_through_the_hatch_is_guarded_too
    words = Module.new do
      def video(*args, poster: nil)
        _, source = arguments(args)
        tag(:video, { class: token(:video), src: source, poster: poster })
      end
    end
    library = SlimPickins::Library.new(words: words)

    kept = SlimPickins.render("page \"P\"\n  video .url, if: .ok?\n",
                              path: 'guard.sp', locals: { ok?: true, url: '/v.mp4' }, library: library)
    dropped = SlimPickins.render("page \"P\"\n  video .url, if: .ok?\n",
                                 path: 'guard.sp', locals: { ok?: false, url: '/v.mp4' }, library: library)

    assert_includes kept, '<video'
    refute_includes dropped, '<video'
  end

  # --- and it stays out of the page's way ------------------------------------

  def test_the_guard_is_hoisted_out_of_the_arguments
    ruby = SlimPickins.compile("page \"P\"\n  note \"x\", if: .ok?\n")

    refute_includes ruby, 'if:', 'the modifier must not reach the word'
    assert_includes ruby, 'next unless (subject.ok?)'
  end

  def test_the_gate_still_permits_it
    tree = SlimPickins::Transform.tree("money .total, if: .paid?\n")

    assert_empty SlimPickins::Contracts.complaints(tree.first, [])
  end

  def test_a_word_whose_modifier_is_unknown_is_still_refused
    error = assert_raises(SlimPickins::SyntaxError) do
      render("page \"P\"\n  note \"x\", style: \"red\"\n")
    end

    assert_match(/no `style:` modifier/, error.message)
  end
end
