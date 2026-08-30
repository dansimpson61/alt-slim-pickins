# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# Phase 0's done-conditions, as tests. The bodies double as a phrasebook:
# every page here is exemplary usage of the language.
class Phase0Test < Minitest::Test
  Account = Struct.new(:name, :balance, :holdings, keyword_init: true)
  Holding = Struct.new(:symbol, :shares, keyword_init: true)

  def render(source, **locals)
    SlimPickins.render(source, path: '(test)', locals: locals)
  end

  # --- the transform --------------------------------------------------

  def test_indentation_becomes_blocks
    ruby = SlimPickins.compile(<<~PAGE)
      page account
        form to: save
          field name
    PAGE
    assert_equal <<~RUBY, ruby
      page(:account) do
        form(to: :save) do
          field(:name)
        end
      end
    RUBY
  end

  def test_the_five_argument_kinds_each_have_one_spelling
    ruby = SlimPickins.compile('field name, "Label", type: text')
    assert_equal %(field(:name, "Label", type: :text)\n), ruby

    assert_equal %(title(subject.name)\n), SlimPickins.compile('title .name')
    assert_equal %(note(order.number)\n), SlimPickins.compile('note order.number')
  end

  # --- errors speak the language --------------------------------------

  def test_a_bad_argument_names_the_line_and_what_was_expected
    error = assert_raises(SlimPickins::SyntaxError) do
      SlimPickins.compile("field name, %bogus%\n", path: 'form.sp')
    end
    assert_includes error.message, 'form.sp, line 1'
    assert_includes error.message, 'is not an argument'
    refute_includes error.message, 'NoMethodError'
  end

  def test_an_unknown_attribute_raises_naming_the_attribute_and_the_subject
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render("page account\n  form\n    field nmae\n",
             account: Account.new(name: 'Roth', balance: 1))
    end
    assert_equal 'this account has no nmae', error.message
  end

  # --- the subject chain ----------------------------------------------

  def test_the_page_is_the_outermost_subject
    chain = SlimPickins::Chain.new(SlimPickins::Page.new(locals: { signed_in?: true }))
    assert_equal true, chain.current.fetch(:signed_in?)
    assert_equal 'this page', chain.current.describe
  end

  def test_a_dot_means_the_innermost_subject_at_three_levels
    page = SlimPickins::Page.new(locals: { account: Account.new(name: 'Roth', balance: 10) })
    chain = SlimPickins::Chain.new(page)
    account = chain.current.fetch(:account)

    chain.with(account, described_as: 'this account') do
      assert_equal 'Roth', chain.current.fetch(:name)
      chain.with(Holding.new(symbol: 'VTI', shares: 3)) do
        assert_equal 'VTI', chain.current.fetch(:symbol)
        assert_equal 3, chain.depth
      end
      assert_equal 'Roth', chain.current.fetch(:name)
    end
  end

  # --- inference: the whole bet ---------------------------------------

  def test_one_word_derives_label_name_value_and_type
    html = render("page account\n  form\n    field balance\n",
                  account: Account.new(name: 'Roth', balance: 1500))
    assert_includes html, '<label for="balance">Balance</label>'
    assert_includes html, 'name="balance"'
    assert_includes html, 'value="1500"'
    assert_includes html, 'type="number"'
  end

  def test_the_type_comes_from_the_value_not_from_a_schema
    assert_equal :number, SlimPickins::Inference.input_type(3)
    assert_equal :text,   SlimPickins::Inference.input_type('fixed')
    assert_equal :date,   SlimPickins::Inference.input_type(Date.today)
    assert_equal 0.01,    SlimPickins::Inference.step_for(0.05)
    assert_nil            SlimPickins::Inference.step_for(30)
  end

  def test_labels_humanise_the_attribute_name
    assert_equal 'Base income', SlimPickins::Inference.label(:base_income)
    assert_equal 'Signed in',   SlimPickins::Inference.label(:signed_in?)
    assert_equal 'Updated',     SlimPickins::Inference.label(:updated_at)
  end

  # --- conventions are overridable ------------------------------------

  def test_every_inference_can_be_overridden_by_saying_the_thing
    html = render(%(page account\n  form\n    field balance, "What you have", type: text\n),
                  account: Account.new(name: 'Roth', balance: 1500))
    assert_includes html, '<label for="balance">What you have</label>'
    assert_includes html, 'type="text"'
  end
end
