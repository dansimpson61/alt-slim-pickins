# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require 'json'
require 'tmpdir'
require_relative '../lib/slim_pickins'
require_relative '../studio/pages'
require_relative '../studio/app'

Sinatra::Application.set :host_authorization, { permitted_hosts: [] }

class MintingTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_extract_definitions_with_various_signatures
    source = <<~SP
      page "Doc Reader"
        sidebar docs, "Documents"
        reading_pane selected_doc
        app_header

      def app_header
        box
          heading "Reader"

      def sidebar, documents, title
        box documents, title
          empty "No docs"

      def reading_pane, document
        box document
          empty "No doc"
    SP

    defs = StudioPages.extract_definitions(source)
    assert_equal 3, defs.size

    assert_equal 'app_header', defs[0][:word]
    assert_equal [], defs[0][:params]
    assert_includes defs[0][:body], 'heading "Reader"'
    assert_equal 6, defs[0][:start_line]

    assert_equal 'sidebar', defs[1][:word]
    assert_equal %w[documents title], defs[1][:params]
    assert_includes defs[1][:body], 'empty "No docs"'

    assert_equal 'reading_pane', defs[2][:word]
    assert_equal ['document'], defs[2][:params]
    assert_includes defs[2][:body], 'empty "No doc"'
  end

  def test_mint_partial_writes_to_disk_and_unindents_body
    Dir.mktmpdir do |dir|
      views_dir = File.join(dir, 'views', 'partials')
      FileUtils.mkdir_p(views_dir)

      body = "box documents, title\n  empty \"No docs\"\n"
      path = StudioPages.mint_partial!(dir, 'custom_sidebar', %w[documents title], body)

      assert File.exist?(path)
      content = File.read(path)
      expected = <<~SP
        def custom_sidebar, documents, title
          box documents, title
            empty "No docs"
      SP
      assert_equal expected, content
    end
  end

  def test_post_mint_endpoint_success
    source = <<~SP
      page "App"
        sidebar docs, "Docs"

      def sidebar, documents, title
        box documents, title
          empty "No docs"
    SP

    Dir.mktmpdir do |dir|
      post '/mint',
           JSON.generate({ word: 'sidebar', source: source, app: dir }),
           { 'CONTENT_TYPE' => 'application/json' }

      assert_equal 200, last_response.status
      data = JSON.parse(last_response.body)
      assert data['ok']
      assert_equal 'sidebar', data['word']
      assert_includes data['remaining_source'], 'page "App"'
      assert_includes data['remaining_source'], 'sidebar docs, "Docs"'
      refute_includes data['remaining_source'], 'def sidebar'
    end
  end

  def test_post_mint_endpoint_missing_word
    source = <<~SP
      page "App"
        note "Hello"
    SP

    post '/mint',
         JSON.generate({ word: 'nonexistent', source: source }),
         { 'CONTENT_TYPE' => 'application/json' }

    assert_equal 400, last_response.status
    data = JSON.parse(last_response.body)
    assert_includes data['error'], 'No definition found for word `nonexistent`'
  end

  def test_end_to_end_mint_and_render_flow
    Dir.mktmpdir do |dir|
      source = <<~SP
        page "Docs App"
          doc_card item

        def doc_card, item
          box item
            heading .name
      SP

      post '/mint',
           JSON.generate({ word: 'doc_card', source: source, app: dir }),
           { 'CONTENT_TYPE' => 'application/json' }

      assert_equal 200, last_response.status
      result = JSON.parse(last_response.body)
      remaining_source = result['remaining_source']

      # Now render remaining_source with the library created from that directory
      lib = SlimPickins::Library.from(dir)
      html = SlimPickins.render(remaining_source, locals: { item: { name: 'Joyful Ruby' } }, library: lib)
      assert_includes html, '<h2 class="heading">Joyful Ruby</h2>'
    end
  end
end
