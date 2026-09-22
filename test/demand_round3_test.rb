# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

class DemandRound3Test < Minitest::Test
  # --- G7: search route override ---------------------------------------------

  def test_search_uses_default_search_route_when_to_omitted
    html = SlimPickins.render("page \"P\"\n  search placeholder: \"Find...\"\n")
    assert_includes html, 'action="/search"'
  end

  def test_search_accepts_custom_destination_via_to_modifier
    html = SlimPickins.render("page \"P\"\n  search to: \"/\", placeholder: \"Find...\"\n")
    assert_includes html, 'action="/"'
  end

  # --- G9: choice radio variant ----------------------------------------------

  def test_choice_radio_emits_fieldset_with_radio_inputs
    exam = Struct.new(:q1).new(:b)
    source = <<~SP
      page exam
        choice radio, q1, "Question 1"
          option a, "First"
          option b, "Second"
    SP
    html = SlimPickins.render(source, locals: { exam: exam })
    assert_includes html, '<fieldset class="choice choice--radio">'
    assert_includes html, '<legend>Question 1</legend>'
    assert_includes html, '<input type="radio" name="q1" id="q1_a" value="a">'
    assert_includes html, '<input type="radio" name="q1" id="q1_b" value="b" checked="checked">'
    assert_includes html, 'First</label>'
    assert_includes html, 'Second</label>'
    refute_includes html, '<select'
  end

  def test_choice_radio_with_attribute_name
    exam = Struct.new(:q1).new('first')
    source = <<~SP
      page exam
        choice radio, q1
          option "first", "First Option"
          option "second", "Second Option"
    SP
    html = SlimPickins.render(source, locals: { exam: exam })
    assert_includes html, '<fieldset class="choice choice--radio">'
    assert_includes html, '<input type="radio" name="q1" id="q1_first" value="first" checked="checked">'
    assert_includes html, '<input type="radio" name="q1" id="q1_second" value="second">'
  end

  # --- G11: choice with each for dynamic options -----------------------------

  def test_choice_enclosing_each_dynamically_registers_options
    question = Struct.new(:id, :selected_opt, :options).new(
      :q_dyn, 'opt_b', ['opt_a', 'opt_b', 'opt_c']
    )
    source = <<~SP
      page question
        choice radio, .id
          each opt, from: .options
            option .to_s, .to_s
    SP
    html = SlimPickins.render(source, locals: { question: question })
    assert_includes html, '<fieldset class="choice choice--radio">'
    assert_includes html, 'value="opt_a"'
    assert_includes html, 'value="opt_b"'
    assert_includes html, 'value="opt_c"'
    assert_includes html, '<input type="radio" name="q_dyn" id="q_dyn_opt_a" value="opt_a">'
  end

  def test_dropdown_choice_with_each
    question = Struct.new(:id, :color, :options).new(
      :color, 'blue', ['red', 'green', 'blue']
    )
    source = <<~SP
      page question
        choice .id, "Select Color"
          each c, from: .options
            option .to_s, .to_s
    SP
    html = SlimPickins.render(source, locals: { question: question })
    assert_includes html, '<select id="color" name="color">'
    assert_includes html, '<option value="red">red</option>'
    assert_includes html, '<option value="green">green</option>'
    assert_includes html, '<option value="blue" selected="selected">blue</option>'
  end

  # --- G25: textarea readonly modifier ---------------------------------------

  def test_textarea_supports_readonly_modifier
    snippet = Struct.new(:lore_body).new("Council wisdom\nKeep it simple")
    source = <<~SP
      page snippet
        textarea lore_body, "Lore Snippet", readonly: true, rows: 6
    SP
    html = SlimPickins.render(source, locals: { snippet: snippet })
    assert_includes html, '<textarea id="lore_body" name="lore_body" rows="6" readonly="readonly">'
    assert_includes html, "Council wisdom\nKeep it simple"
  end
end
