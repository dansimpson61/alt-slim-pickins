# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# Phase 1: the contract an app must satisfy to be renderable, and what happens
# when it does not. Every case here is a claim made in CONTRACT.md.
class ContractTest < Minitest::Test
  PAGE = "page account\n  form\n    field name\n"

  Account = Struct.new(:name, keyword_init: true)

  # An app that knows its own vocabulary can say so. This is the whole of the
  # optional half of the contract.
  Nicknamed = Struct.new(:name, keyword_init: true) do
    def label_for(attribute) = { name: 'Account nickname' }[attribute]
  end

  def label(**locals)
    SlimPickins.render(PAGE, path: '(test)', **locals)[%r{<label[^>]*>([^<]*)</label>}, 1]
  end

  # --- what satisfies it ----------------------------------------------

  def test_a_plain_struct_satisfies_the_contract_with_no_changes
    assert_equal 'Name', label(locals: { account: Account.new(name: 'Roth') })
  end

  def test_a_hash_satisfies_the_contract
    assert_equal 'Name', label(locals: { account: { name: 'Roth' } })
  end

  def test_a_hash_with_string_keys_satisfies_the_contract
    assert_equal 'Name', label(locals: { account: { 'name' => 'Roth' } })
  end

  def test_the_type_is_read_from_the_value_so_nothing_must_be_declared
    html = SlimPickins.render("page account\n  form\n    field opened_on\n",
                              locals: { account: { opened_on: Date.new(2026, 8, 30) } })
    assert_includes html, 'type="date"'
  end

  # --- the optional half ----------------------------------------------

  def test_an_app_may_answer_for_its_own_labels
    assert_equal 'Account nickname', label(locals: { account: Nicknamed.new(name: 'Roth') })
  end

  def test_the_page_still_wins_over_the_app
    html = SlimPickins.render(%(page account\n  form\n    field name, "Just here"\n),
                              locals: { account: Nicknamed.new(name: 'Roth') })
    assert_includes html, '>Just here<'
  end

  def test_without_label_for_the_language_humanises
    assert_equal 'Name', label(locals: { account: Account.new(name: 'Roth') })
  end

  # --- what happens when it is not satisfied --------------------------

  def test_a_missing_attribute_names_the_attribute_and_the_subject
    error = assert_raises(SlimPickins::UnknownAttribute) do
      label(locals: { account: Object.new })
    end
    assert_match(/\Athis account has no name\n/, error.message)
  end

  # The failure is that the subject is empty, not that it lacks an attribute,
  # and saying the second would send a reader looking in the wrong place.
  def test_an_empty_subject_says_so_rather_than_blaming_the_attribute
    error = assert_raises(SlimPickins::Nothing) { label(locals: { account: nil }) }
    assert_match(/\Anothing to ask for name — the subject is empty\n/, error.message)
  end

  # `page account` is the line at fault. Skipping quietly would report the
  # missing attribute three lines later, on a line that is not the cause.
  def test_a_named_subject_that_is_absent_fails_on_the_line_that_named_it
    error = assert_raises(SlimPickins::UnknownAttribute) { label(locals: {}) }
    assert_match(/\Athis page has no account\n  \(test\), line 1\n    page account\z/, error.message)
  end

  # --- the page is the outermost subject ------------------------------

  def test_helpers_are_page_attributes_like_any_other
    helpers = Class.new { def house_style = 'Ledger' }.new
    html = SlimPickins.render("page account\n  form\n    field name\n",
                              locals: { account: { name: 'Roth' } }, helpers: helpers)
    assert_includes html, '>Name<'
    page = SlimPickins::Page.new(locals: {}, helpers: helpers)
    assert_equal 'Ledger', SlimPickins::Chain.new(page).current.fetch(:house_style)
  end
end
