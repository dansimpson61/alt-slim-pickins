# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# What happens when words *meet*.
#
# Every other test file here asks whether a word renders what it should. None
# of them asked what happens when two words combine in a way no page has yet
# used — and 133 tests found nothing, because every one of them is a happy path
# over a page somebody wrote on purpose.
#
# Five minutes of adversarial probing found two crashes, both of which failed
# with a Ruby error rather than one that speaks the language. This file is the
# guard that was missing: it crosses the words that hold state against each
# other, on the assumption that the next such defect arrives the same way.
class CombinationTest < Minitest::Test
  Row = Struct.new(:name, :qty, :rows, keyword_init: true)

  INNER = [Row.new(name: 'a', qty: 1), Row.new(name: 'b', qty: 2)].freeze
  OUTER = [Row.new(name: 'X', qty: 9, rows: INNER)].freeze
  LOCALS = { outers: OUTER, inner: INNER, yes: true, no: false }.freeze

  def draw(source, **extra) = SlimPickins.render(source, locals: LOCALS.merge(extra))

  # --- the gathering words, nested through `when` -------------------------
  #
  # `when` is the only word that both lives inside a gatherer and takes
  # arbitrary children, so it is the one route by which a gatherer can end up
  # inside another. `choose` saved and restored its collection; `table` and
  # `chart` cleared theirs, which took the outer one's with it.

  GATHERERS = {
    'table' => "table %s\n  column name",
    'chart' => "chart %s, over: name\n  band qty",
    'choose' => "choose\n  when .yes\n    text \"x\""
  }.freeze

  def test_every_gathering_word_survives_every_other_nested_inside_it
    GATHERERS.each do |outer, outer_src|
      GATHERERS.each do |inner, inner_src|
        nested = inner_src.gsub('%s', 'inner').gsub("\n", "\n      ")
        source = if outer == 'choose'
                   "choose\n  when .yes\n    #{inner_src.gsub('%s', 'inner').gsub("\n", "\n    ")}\n"
                 else
                   "#{outer_src.gsub('%s', 'outers')}\n  choose\n    when .yes\n      #{nested}\n"
                 end
        draw(source)
      rescue StandardError => e
        flunk "#{inner} inside #{outer}: #{e.class}: #{e.message}"
      end
    end
  end

  def test_a_table_inside_a_table_keeps_both_sets_of_columns
    html = draw(<<~PAGE)
      table outers
        column name
        choose
          when .yes
            table inner
              column qty
    PAGE
    assert_equal 2, html.scan('<table').size
    assert_includes html, '<th>Name</th>'
    assert_includes html, 'Qty'
  end

  def test_a_conditional_column_registers_into_the_table_around_it
    with = draw("table outers\n  column name\n  choose\n    when .yes\n      column qty\n")
    without = draw("table outers\n  column name\n  choose\n    when .no\n      column qty\n")

    assert_equal %w[Name Qty], with.scan(%r{<th[^>]*>([^<]*)</th>}).flatten
    assert_equal %w[Name], without.scan(%r{<th[^>]*>([^<]*)</th>}).flatten
  end

  # --- the binding namespace and the word namespace -----------------------

  # `each` binds its name so an inner loop can reach back out, and that
  # reaching is served by `method_missing`. A word is a real method, so for 23
  # of the 50 words the word answered instead and handed back its own output —
  # `each item` made `item.name` raise about a String.
  def test_a_loop_may_not_bind_a_name_the_language_already_uses
    error = assert_raises(SlimPickins::Error) { draw("each item\n  text .name\n", items: INNER) }
    assert_includes error.message, 'it is a word of the language'
    assert_includes error.message, 'from:'
  end

  def test_the_refusal_names_the_way_through
    error = assert_raises(SlimPickins::Error) { draw("each card\n  text .name\n", cards: INNER) }
    assert_includes error.message, 'each row, from: .cards'
  end

  def test_a_loop_over_a_name_that_is_not_a_word_still_reaches_back_out
    html = draw("each holding\n  text holding.name\n", holdings: INNER)
    assert_includes html, '<p>a</p>'
  end

  # --- the words that carry state for their children ----------------------

  def test_a_select_inside_a_form_does_not_leak_its_selection
    html = draw(<<~PAGE, scenario: Row.new(name: 'b', qty: 1))
      form scenario
        select name
          option a
          option b
        field qty
    PAGE
    assert_includes html, '<option value="b" selected="selected">'
    assert_equal 1, html.scan('selected="selected"').size
  end

  def test_registering_words_refuse_to_stand_alone
    { 'column name' => 'column belongs inside a table',
      'band qty' => 'band belongs inside a chart',
      'level .qty, "x"' => 'level belongs inside a chart',
      'when .yes' => 'when belongs inside a choose' }.each do |source, message|
      error = assert_raises(SlimPickins::Error) { draw("#{source}\n", qty: 1) }
      assert_equal message, error.message
    end
  end

  # --- nothing here may fail in Ruby --------------------------------------

  # The project's strongest claim is that errors speak the language and never
  # the implementation. Both defects this file was written for broke it.
  def test_a_wall_is_always_a_language_error
    [
      "table outers\n  column nope\n",
      "chart outers, over: name\n  band nope\n",
      "each nope\n  text .name\n",
      "section nope\n  text \"x\"\n"
    ].each do |source|
      draw(source)
      flunk "#{source.inspect} should not have rendered"
    rescue SlimPickins::Error
      # the language speaking, which is the point
    rescue StandardError => e
      flunk "#{source.inspect} failed in Ruby, not in the language: #{e.class}: #{e.message}"
    end
  end
end
