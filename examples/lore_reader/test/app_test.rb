# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class LoreAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    LoreReader::App
  end

  def default_env
    { 'HTTP_HOST' => 'localhost' }
  end

  def test_index_renders_overview_and_timeline
    get '/', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'The Lore Reader'
    assert_includes last_response.body, 'Archive Overview'
    assert_includes last_response.body, 'Total Entries'
    assert_includes last_response.body, 'Authors'
    assert_includes last_response.body, 'Search'
    assert_includes last_response.body, 'Timeline'
    assert_includes last_response.body, 'Read entry'
  end

  def test_index_search_filter
    get '/?q=Claude', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Claude'
  end

  def test_index_empty_state
    get '/?q=nonexistent_xyz_query_404', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'No entries found matching your search.'
    refute_includes last_response.body, 'Read entry'
  end

  def test_entry_detail_renders_article_and_prose
    lore = LoreReader::Lore.load
    entry = lore.all.first
    get "/entries/#{entry.id}", {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, '← Back to Timeline'
    assert_includes last_response.body, '<div class="prose">'
    assert_includes last_response.body, 'Words Mentioned'
  end

  def test_entry_not_found
    get '/entries/missing-id-999', {}, default_env
    assert_equal 404, last_response.status
  end
end
