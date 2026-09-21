# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class WordGraphAppTest < Minitest::Test
  include Rack::Test::Methods

  WordGraph::App.set :host_authorization, { permitted_hosts: [] }

  def app
    WordGraph::App
  end

  def test_index_renders_overview_and_all_words
    get '/'
    assert last_response.ok?
    assert_includes last_response.body, 'The Word Graph'
    assert_includes last_response.body, 'Total Words'
    assert_includes last_response.body, '64'
    assert_includes last_response.body, 'table'
    assert_includes last_response.body, 'column'
    assert_includes last_response.body, 'chart'
    assert_includes last_response.body, 'each'
  end

  def test_index_search_filter
    get '/?q=table'
    assert last_response.ok?
    assert_includes last_response.body, 'table'
    assert_includes last_response.body, 'column'
    refute_includes last_response.body, 'money'
  end

  def test_index_shape_filter
    get '/?shape=gathers'
    assert last_response.ok?
    assert_includes last_response.body, 'table'
    assert_includes last_response.body, 'chart'
    assert_includes last_response.body, 'choice'
    assert_includes last_response.body, 'choose'
    refute_includes last_response.body, '<h4 class="title">paragraph</h4>'
  end

  def test_index_speech_filter
    get '/?speech=verb'
    assert last_response.ok?
    assert_includes last_response.body, 'choose'
    refute_includes last_response.body, 'table'
  end

  def test_word_detail_for_gatherer
    get '/words/table'
    assert last_response.ok?
    assert_includes last_response.body, 'table'
    assert_includes last_response.body, 'Gatherer'
    assert_includes last_response.body, 'column'
    assert_includes last_response.body, 'total'
    assert_includes last_response.body, 'choose'
    assert_includes last_response.body, 'each'
    assert_includes last_response.body, 'table_rows'
  end

  def test_word_detail_for_register
    get '/words/column'
    assert last_response.ok?
    assert_includes last_response.body, 'column'
    assert_includes last_response.body, 'Register'
    assert_includes last_response.body, 'Enclosing Parents'
    assert_includes last_response.body, 'table'
    assert_includes last_response.body, 'column_registration'
  end

  def test_word_detail_not_found
    get '/words/nonexistent_word_xyz'
    assert_equal 404, last_response.status
  end

  def test_shapes_page_renders_distribution_chart_and_cards
    get '/shapes'
    assert last_response.ok?
    assert_includes last_response.body, 'Structural Shapes of alt-slim-pickins'
    assert_includes last_response.body, '<svg class="chart"'
    assert_includes last_response.body, 'Encloses'
    assert_includes last_response.body, 'Presents'
    assert_includes last_response.body, 'Says'
    assert_includes last_response.body, 'Registers'
    assert_includes last_response.body, 'Document'
    assert_includes last_response.body, 'Gathers'
    assert_includes last_response.body, 'Iterates'
  end

  def test_matrix_page_renders_connection_table
    get '/matrix'
    assert last_response.ok?
    assert_includes last_response.body, 'Vocabulary Connection Matrix'
    assert_includes last_response.body, '<table class="table'
    assert_includes last_response.body, 'table'
    assert_includes last_response.body, 'column'
    assert_includes last_response.body, 'chart'
    assert_includes last_response.body, 'band'
  end
end
