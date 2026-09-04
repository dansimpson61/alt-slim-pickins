# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The primitives the exam negotiated — Round A: what a form carries
# (hidden), what a form asks (input, textarea), what a card is titled with,
# where a link stands (active), how big a button is (size), and the widened
# form that holds action buttons. Each test is a page the triage port needs.
class UiWordsTest < Minitest::Test
  Account = Struct.new(:name, :notes, :q, keyword_init: true)

  def render(source, **locals)
    SlimPickins.render(source, path: '(test)', locals: locals)
  end

  def test_a_form_can_carry_an_action_button_and_hidden_inputs
    html = render(%(page account
  form to: "/actions/commit", method: post
    hidden path, .name
    hidden return_to, "/triage"
    button "Commit"
),
                  account: Account.new(name: 'ode-to-joy'))
    assert_includes html, '<form class="form" action="/actions/commit" method="post">'
    assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
    assert_includes html, '<input type="hidden" name="return_to" value="/triage">'
    assert_includes html, '<button type="submit" class="button">Commit</button>'
  end

  def test_hidden_reads_the_subject_when_no_value_is_said
    html = render(%(page account
  form to: "/x", method: post
    hidden name
), account: Account.new(name: 'Roth'))
    assert_includes html, '<input type="hidden" name="name" value="Roth">'
  end

  def test_textarea_is_fields_multiline_sibling
    html = render(%(page account
  form
    textarea notes, "What changed?", rows: 3, required: true
), account: Account.new(notes: 'Lots.'))
    assert_includes html, '<label for="notes">What changed?</label>'
    assert_includes html, '<textarea id="notes" name="notes" rows="3" required="required">Lots.</textarea>'
  end

  def test_input_is_a_bare_field_with_a_placeholder
    html = render(%(page account
  input q, placeholder: "search…"
), account: Account.new(q: 'tax'))
    assert_includes html, '<input id="q" name="q" type="text" value="tax" placeholder="search…">'
    refute_includes html, '<label'
  end

  def test_a_card_takes_a_title
    html = render(%(page account
  card "Holdings"
    text "VTI"
), account: Account.new(name: 'Roth'))
    assert_includes html, '<h2 class="card-title">Holdings</h2>'
  end

  def test_a_link_can_say_where_you_are
    html = render(%(page account
  nav
    link home, active: true
    link library
), account: {})
    assert_includes html, '<a href="/home" class="link link--active" aria-current="page">Home</a>'
    assert_includes html, '<a href="/library" class="link">Library</a>'
  end

  def test_a_button_takes_a_size
    html = render(%(page account
  button "Save", size: sm
), account: {})
    assert_includes html, '<button type="button" class="button button--sm">Save</button>'
  end

  def test_hidden_still_refuses_to_stand_outside_a_form
    error = assert_raises(SlimPickins::SyntaxError) { render(%(page account\n  hidden path, .name\n), account: {}) }
    assert_match(/`hidden` belongs inside `form`/, error.message)
  end
end
