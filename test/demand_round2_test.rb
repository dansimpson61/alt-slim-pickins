# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

class DemandRound2Test < Minitest::Test
  # --- G1: Library#render ----------------------------------------------------

  def test_library_render_renders_view_directly
    lib = SlimPickins::Library.from('examples/lore_reader/views')
    lore = Struct.new(:id, :date, :author, :title, :body, :words, :tags).new(
      '2026-08-29-1', '2026-08-29', 'Claude', 'Test Entry', 'Body prose', ['page'], ['tag']
    )
    html = lib.render(:entry, locals: { entry: lore })
    assert_includes html, 'Test Entry'
    assert_includes html, 'Body prose'
  end

  # --- G3: Subject#to_s and Subject#to_str -----------------------------------

  def test_subject_to_s_delegates_to_underlying_object
    sub = SlimPickins::Subject.new('active')
    assert_equal 'active', sub.to_s
    assert_equal 'active', sub.to_str

    html = SlimPickins.render("page \"P\"\n  each row, from: rows\n    badge .to_s\n", locals: { rows: ['running'] })
    assert_includes html, 'running'
    refute_includes html, '#<SlimPickins::Subject:'
  end

  # --- G12: Hash predicate methods (e.g. .done?) -----------------------------

  def test_hash_predicate_fallback_strips_question_mark
    task = { 'name' => 'Design DSL', 'done' => true }
    sub = SlimPickins::Subject.new(task)
    assert sub.has?(:done?)
    assert_equal true, sub.fetch(:done?)

    html = SlimPickins.render("page \"P\"\n  note \"DONE\", if: .done?\n", locals: task)
    assert_includes html, 'DONE'

    task_not_done = { 'name' => 'Design DSL', 'done' => false }
    html_not_done = SlimPickins.render("page \"P\"\n  note \"DONE\", if: .done?\n", locals: task_not_done)
    refute_includes html_not_done, 'DONE'
  end

  # --- G14: Irregular plurals in Inference -----------------------------------

  def test_inference_irregular_plurals
    assert_equal 'children', SlimPickins::Inference.plural(:child)
    assert_equal :child, SlimPickins::Inference.singular(:children)

    assert_equal 'people', SlimPickins::Inference.plural(:person)
    assert_equal :person, SlimPickins::Inference.singular(:people)

    assert_equal 'data', SlimPickins::Inference.plural(:datum)
    assert_equal :datum, SlimPickins::Inference.singular(:data)
  end

  # --- G15: Bare symbol in from: ---------------------------------------------

  def test_each_accepts_bare_symbol_in_from
    family = Struct.new(:children).new(['Alice', 'Bob'])
    html = SlimPickins.render("page family\n  each child, from: children\n    text .to_s\n",
                              locals: { family: family })
    assert_includes html, 'Alice'
    assert_includes html, 'Bob'
  end

  # --- G8: Truthiness in choose / when ---------------------------------------

  def test_when_treats_empty_string_and_empty_collection_as_falsy
    source = <<~SP
      page "P"
        choose
          when .q
            note "HAS_QUERY"
          otherwise
            note "NO_QUERY"
    SP
    html_empty = SlimPickins.render(source, locals: { q: '' })
    refute_includes html_empty, 'HAS_QUERY'
    assert_includes html_empty, 'NO_QUERY'

    html_present = SlimPickins.render(source, locals: { q: 'ruby' })
    assert_includes html_present, 'HAS_QUERY'
    refute_includes html_present, 'NO_QUERY'
  end

  # --- G2 & G16: metric and fact expression safety ---------------------------

  def test_metric_with_evaluated_expression_and_dotted_data
    stats = Struct.new(:total_entries).new(42)
    html = SlimPickins.render("page \"P\"\n  metric stats.total_entries, \"Total\"\n",
                              locals: { stats: stats })
    assert_includes html, '42'
    assert_includes html, 'Total'

    html_dotted = SlimPickins.render("page stats\n  metric .total_entries, \"Total\"\n",
                                     locals: { stats: stats })
    assert_includes html_dotted, '42'
    assert_includes html_dotted, 'Total'
  end

  def test_fact_with_evaluated_expression_and_dotted_data
    word = Struct.new(:speech_name).new('noun')
    html = SlimPickins.render("page word\n  fact .speech_name\n",
                              locals: { word: word })
    assert_includes html, 'noun'
  end

  # --- G17: title accepts bare identifier attribute --------------------------

  def test_title_with_bare_identifier_resolves_subject_attribute
    node = Struct.new(:word_name).new('each')
    html = SlimPickins.render("page node\n  title word_name\n",
                              locals: { node: node })
    assert_includes html, '<h2 class="title">each</h2>'
  end
end
