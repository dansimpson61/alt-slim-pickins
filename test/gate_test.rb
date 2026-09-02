# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The gate — Phase 3's payload. A page may not render until the app has been
# proved able to answer it, and the first half of the proof is static: every
# sentence must satisfy its word's contract, refused before evaluation, in
# the same voice as a syntax error. What used to pass silently — `money
# name`, a dropped block under `title` — now fails with the word, the line,
# and the sentence.
class GateTest < Minitest::Test
  def render(source, library: nil, **locals)
    SlimPickins.render(source, path: 'form.sp', locals: locals, library: library)
  end

  def test_a_name_a_word_cannot_take_is_refused_not_rendered_blank
    error = assert_raises(SlimPickins::SyntaxError) do
      render("page p\n  money name\n", p: { name: 40 })
    end
    assert_match(/\A`money` takes no name — name\n  form\.sp, line 2\n    money name\z/, error.message)
  end

  def test_children_a_word_cannot_hold_are_refused_not_dropped
    error = assert_raises(SlimPickins::SyntaxError) do
      render("page p\n  title \"x\"\n    note \"y\"\n", p: {})
    end
    assert_match(/\A`title` holds nothing — a `note` has nowhere to go\n  form\.sp, line 2\n    title "x"\z/,
                 error.message)
  end

  def test_the_gate_names_the_guard_not_the_argument
    error = assert_raises(SlimPickins::SyntaxError) do
      render("page p\n  when .x\n    note \"y\"\n", p: {})
    end
    assert_match(/\A`when` belongs inside `choose`\n  form\.sp, line 2\n    when \.x\z/, error.message)
  end

  def test_a_violating_partial_names_the_partial
    library = SlimPickins::Library.new(layout: nil,
                                       partials: { account_card: "title .name\nmoney name\n" })
    error = assert_raises(SlimPickins::SyntaxError) do
      render("page account\n  account_card\n", library: library, account: { name: 'Roth' })
    end
    assert_match(/\A`money` takes no name — name\n  partials\/account_card\.sp, line 2\n    money name\z/,
                 error.message)
  end

  def test_a_violating_layout_names_the_layout
    layout = "money name\ncontents\n"
    error = assert_raises(SlimPickins::SyntaxError) do
      render("page account\n  text \"x\"\n", library: SlimPickins::Library.new(layout: layout),
             account: { name: 'Roth' })
    end
    assert_match(/\A`money` takes no name — name\n  layout\.sp, line 1\n    money name\z/, error.message)
  end

  def test_evaluate_is_gated_too
    assert_raises(SlimPickins::SyntaxError) do
      SlimPickins.evaluate("page p\n  money name\n", locals: { p: { name: 40 } })
    end
  end

  def test_an_app_word_without_a_contract_passes_the_gate
    words = Module.new do
      def stat(*args)
        name, label = arguments(args)
        emit_node([:metric, { name: name, label: label_for(name, label),
                              value: subject.fetch(name), kind: nil }, []])
      end
    end
    html = render("page p\n  stat total\n", library: SlimPickins::Library.new(words: words),
                  p: { total: 3 })
    assert_includes html, 'Total'
  end
end
