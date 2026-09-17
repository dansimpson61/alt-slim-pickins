# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# Literals in a modifier's value (dan's ruling, 2026-09-17).
#
# A bare number has always been legal *there* and illegal as a positional
# argument, and the recorded reason is a division of labour rather than a
# grammar rule: a modifier's value is configuration, a positional argument is
# content, and content belongs to the app. `true`, `false` and `nil` join the
# numbers on the same argument. It closes a silent wrongness — `required: false`
# used to arrive as the truthy *name* `:false`, so saying false meant saying
# true — and it lets `if:` be said false, which the guard work made possible.
class LiteralTest < Minitest::Test
  Item = Struct.new(:name, :done, :note, keyword_init: true)

  def render(source, **locals)
    SlimPickins.render(source, path: 'literal.sp', locals: locals)
  end

  # --- they are literals where it counts -------------------------------------

  def test_false_means_false
    html = render("page \"P\"\n  field name, required: false\n", name: 'x')

    refute_includes html, 'required'
  end

  def test_true_means_true
    html = render("page \"P\"\n  field name, required: true\n", name: 'x')

    assert_includes html, 'required="required"'
  end

  def test_nil_means_nothing
    html = render("page \"P\"\n  box open: nil\n    note \"x\"\n")

    refute_includes html, 'open='
  end

  # The silent wrongness this closed: `open: false` rendered `open="open"`.
  def test_a_false_attribute_is_not_rendered
    html = render("page \"P\"\n  box open: false\n    note \"x\"\n")

    refute_includes html, 'open'
  end

  def test_the_guard_can_be_said_false
    assert_includes render("page \"P\"\n  note \"KEEP\", if: true\n"), 'KEEP'
    refute_includes render("page \"P\"\n  note \"KEEP\", if: false\n"), 'KEEP'
  end

  # --- and the name position is untouched ------------------------------------

  # A bare word is language, not a value. `true` where a *name* belongs is still
  # the name `true` — which means a word must still refuse it if it takes no
  # name, and the variant check must still find it unstylable.
  def test_a_name_position_still_reads_a_bare_word_as_a_name
    assert_equal "with_line(1) do\n  note(:true, \"x\")\nend\n",
                 SlimPickins.compile("note true, \"x\"\n")
  end

  def test_a_bare_number_is_still_refused_where_content_belongs
    error = assert_raises(SlimPickins::SyntaxError) do
      SlimPickins.compile("note 3, \"x\"\n")
    end

    assert_match(/bare number/, error.message)
  end
end
