# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# Phase 1: the contract an app must satisfy to be renderable, and what happens
# when it does not. Every case here is a claim made in CONTRACT.md.
class ContractTest < Minitest::Test
  PAGE = "account\n  form\n    field name\n"

  Account = Struct.new(:name, keyword_init: true)

  # An app that knows its own vocabulary can say so. This is the whole of the
  # optional half of the contract.
  Nicknamed = Struct.new(:name, keyword_init: true) do
    def label_for(attribute) = { name: 'Account nickname' }[attribute]
  end

  def label(**locals)
    SlimPickins.render(PAGE, path: 'test.sp', **locals)[%r{<label[^>]*>([^<]*)</label>}, 1]
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
    html = SlimPickins.render("account\n  form\n    field opened_on\n",
                              locals: { account: { opened_on: Date.new(2026, 8, 30) } })
    assert_includes html, 'type="date"'
  end

  # --- the optional half ----------------------------------------------

  def test_an_app_may_answer_for_its_own_labels
    assert_equal 'Account nickname', label(locals: { account: Nicknamed.new(name: 'Roth') })
  end

  def test_the_page_still_wins_over_the_app
    html = SlimPickins.render(%(account\n  form\n    field name, "Just here"\n),
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

  # A subject that is nil is nothing, as an empty list is: the page shows its
  # empty situation rather than breaking. It used to raise "nothing to ask for
  # name — the subject is empty". dan ruled on 2026-10-10 that what only the
  # data can show gets a fallback, never a broken page.
  def test_an_empty_subject_shows_its_empty_situation
    html = SlimPickins.render("account\n  form\n    field name\n  empty \"No account linked\"\n",
                              path: 'test.sp', locals: { account: nil })
    assert_includes html, '<p class="empty">No account linked</p>'
    refute_includes html, '<form'
  end

  # `account` is the line at fault. Skipping quietly would report the
  # missing attribute three lines later, on a line that is not the cause.
  def test_a_named_subject_that_is_absent_fails_on_the_line_that_named_it
    error = assert_raises(SlimPickins::UnknownAttribute) { label(locals: {}) }
    assert_match(/\Athis page has no account\n  test\.sp, line 1\n    account\z/, error.message)
  end

  # --- the page is the outermost subject ------------------------------

  def test_helpers_are_page_attributes_like_any_other
    helpers = Class.new { def house_style = 'Ledger' }.new
    html = SlimPickins.render("account\n  form\n    field name\n",
                              locals: { account: { name: 'Roth' } }, helpers: helpers)
    assert_includes html, '>Name<'
    page = SlimPickins::Page.new(locals: {}, helpers: helpers)
    assert_equal 'Ledger', SlimPickins::Chain.new(page).current.fetch(:house_style)
  end

  # --- Daytrip 0.8.0f: Leveling the path for 0.9 CRUD -------------------

  def test_form_encloses_feedback_structure_and_composed_words
    source = <<~SP
      form account
        flash "Success"
        note "Please verify your email"
        section details, "Account Details"
          box
            field name
    SP
    html = SlimPickins.render(source, locals: { account: { details: { name: 'Roth' } } })
    assert_includes html, '<p class="flash">Success</p>'
    assert_includes html, '<p class="note">Please verify your email</p>'
    assert_includes html, '<section class="section section--details">'
    assert_includes html, '<input id="name" name="name" type="text" value="Roth">'
  end

  def test_field_and_input_modifier_harmonization
    source = <<~SP
      form account
        field email, placeholder: "you@example.com", required: true
        input token, placeholder: "xyz-123", required: true
    SP
    html = SlimPickins.render(source, locals: { account: { email: 'dan@example.com', token: 'secret' } })
    assert_includes html, '<input id="email" name="email" type="text" value="dan@example.com" placeholder="you@example.com" required="required">'
    assert_includes html, '<input id="token" name="token" type="text" value="secret" placeholder="xyz-123" required="required">'
  end

  def test_empty_pruning_scoped_to_collection_container_leaves_siblings_intact
    source = <<~SP
      portfolio
        actions
          button "Add Holding", to: "/holdings/new"
        section holdings, "Holdings"
          empty "No holdings yet."
          table
            column symbol
        form new_holding
          field symbol
          actions
            button "Create"
    SP
    html = SlimPickins.render(source, locals: { portfolio: { holdings: [], new_holding: { symbol: '' } } })
    assert_includes html, 'Add Holding'
    assert_includes html, '<p class="empty">No holdings yet.</p>'
    refute_includes html, '<table'
    assert_includes html, '<form class="form"'
    assert_includes html, '<input id="symbol" name="symbol" type="text"'
    assert_includes html, '<button type="submit" class="button">Create</button>'
  end
end
