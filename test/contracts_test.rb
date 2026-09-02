# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The seven slots as objects: each word declares what it takes, what it
# holds, and where it may live, and the contract says so before anything
# renders. These are the government rules the old checker could not see,
# because it looked at lines and never built the tree.
class ContractsTest < Minitest::Test
  def complaints(source)
    tree = SlimPickins::Transform.tree(source, path: 'contracts.sp')
    walk = lambda do |nodes, ancestry|
      nodes.flat_map do |node|
        SlimPickins::Contracts.complaints(node, ancestry) + walk.call(node.children, ancestry + [node.word])
      end
    end
    walk.call(tree, [])
  end

  def assert_complaint(source, message)
    assert complaints(source).any? { |c| c.include?(message) },
           "expected a complaint containing #{message.inspect}, got #{complaints(source).inspect}"
  end

  def test_every_word_has_a_contract
    missing = SlimPickins::Builder::WORDS - SlimPickins::CONTRACTS.keys
    assert_empty missing
  end

  # --- government -------------------------------------------------------

  def test_when_belongs_inside_choose
    assert_complaint("when .x\n", '`when` belongs inside `choose`')
  end

  def test_otherwise_belongs_inside_choose
    assert_complaint("otherwise\n", '`otherwise` belongs inside `choose`')
  end

  def test_option_belongs_inside_choice
    assert_complaint("option fixed, \"Fixed\"\n", '`option` belongs inside `choice`')
  end

  def test_column_belongs_inside_table
    assert_complaint("column name\n", '`column` belongs inside `table`')
  end

  def test_item_belongs_inside_list
    assert_complaint("item\n", '`item` belongs inside `list`')
  end

  def test_a_registering_word_reached_through_each_still_counts_as_inside
    source = "chart years\n  each bracket\n    level .ceiling, .label\n"
    assert_empty complaints(source)
  end

  def test_a_valid_page_has_no_complaints
    source = <<~PAGE
      page portfolio
        section holdings
          empty "No holdings yet."
          table holdings
            column symbol
            total market_value
        form to: save, method: post
          choice account_id, "Account"
            option fixed, "Fixed amount"
    PAGE
    assert_empty complaints(source)
  end

  # --- the word's own slots ---------------------------------------------

  def test_a_word_with_no_name_slot_refuses_a_name
    assert_complaint("money primary, .balance\n", '`money` takes no name')
  end

  # nav was the word with no content slot; grid and the other variant words
  # now accept data as a derived variant, so a partial can pass its own name
  # through. nav still refuses.
  def test_a_word_with_no_content_slot_refuses_data
    assert_complaint("nav .cards\n", '`nav` takes no content or data')
  end

  def test_a_variant_word_accepts_a_derived_variant
    assert_empty complaints("grid .name\n")
  end

  def test_an_unknown_modifier_is_named
    assert_complaint("band base_income, from: .other\n", '`band` has no `from:` modifier')
  end

  def test_if_is_universal
    assert_empty complaints("money .total, if: .paid?\n")
  end

  def test_a_parent_may_not_hold_what_it_does_not_declare
    assert_complaint("table holdings\n  column name\n  link show\n", '`table` may not hold `link`')
  end

  def test_a_word_with_no_children_slot_holds_nothing
    assert_complaint("title \"x\"\n  text \"y\"\n", '`title` holds nothing')
  end
end
