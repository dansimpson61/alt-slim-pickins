# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/lore'

class LoreTest < Minitest::Test
  def setup
    @lore = LoreReader::Lore.load
  end

  def test_dynamically_loads_entries_from_lore_md
    refute_empty @lore.all
    assert @lore.all.size >= 150
  end

  def test_entry_attributes
    entry = @lore.all.first
    assert entry.id
    assert_match(/\A\d{4}-\d{2}-\d{2}\z/, entry.date)
    refute_empty entry.author
    refute_empty entry.title
    refute_empty entry.body
  end

  def test_search_and_filter
    results = @lore.search('Claude')
    refute_empty results
    assert(results.all? { |e| e.author.include?('Claude') || e.body.include?('Claude') })
  end

  def test_stats
    stats = @lore.stats
    assert stats[:total_entries] >= 150
    assert stats[:distinct_authors] >= 1
    assert stats[:first_date] <= stats[:last_date]
  end
end
