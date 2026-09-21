# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class DashboardAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    DashboardPort::App
  end

  def default_env
    { 'HTTP_HOST' => 'localhost' }
  end

  def test_root_redirects_to_triage
    get '/', {}, default_env
    assert_equal 302, last_response.status
    assert_equal 'http://localhost/triage', last_response.location
  end

  def test_triage_renders
    get '/triage', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Triage'
  end

  def test_brief_html_renders_markdown_surface
    get '/brief/alt-slim-pickins', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'alt-slim-pickins — Brief'
    assert_includes last_response.body, '<div class="prose">'
    assert_includes last_response.body, 'Raw Text (for curl)'
    assert_includes last_response.body, 'Session resume card'
  end

  def test_brief_raw_text
    get '/brief/alt-slim-pickins?format=text', {}, default_env
    assert_equal 200, last_response.status
    assert_equal 'text/plain;charset=utf-8', last_response.content_type
    assert_includes last_response.body, '# alt-slim-pickins'
    assert_includes last_response.body, '> **Purpose:**'
  end

  def test_brief_not_found
    get '/brief/nonexistent-project-xyz-404', {}, default_env
    assert_equal 404, last_response.status
  end

  def test_doc_renders_markdown_surface
    get '/projects/alt-slim-pickins/docs/README.md', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="prose">'
    assert_includes last_response.body, 'alt-slim-pickins/README.md'
  end

  def test_doc_not_found
    get '/projects/alt-slim-pickins/docs/missing-doc-404.md', {}, default_env
    assert_equal 404, last_response.status
  end

  def test_pattern_renders_split_surface
    patterns = Library.all_patterns rescue []
    skip 'No patterns found' if patterns.empty?

    pattern = patterns.first
    get "/patterns/#{pattern[:id]}", {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, pattern[:title]
    assert_includes last_response.body, '<div class="prose">'
    assert_includes last_response.body, 'Conceptual Specification &amp; Thinking'
    assert_includes last_response.body, 'Applied in Projects'
    assert_includes last_response.body, 'Agent Lore Snippet'
  end

  def test_pattern_not_found
    get '/patterns/nonexistent-pattern-xyz-404', {}, default_env
    assert_equal 404, last_response.status
  end
end
