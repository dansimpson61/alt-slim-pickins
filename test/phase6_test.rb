# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../lib/slim_pickins/template'
require_relative '../examples/portfolio/app'

# Phase 6: a `.sp` file renders the way a `.slim` one does, and an app that
# needs something the vocabulary has no word for adds a word rather than a
# construct.
class Phase6Test < Minitest::Test
  include Rack::Test::Methods

  Portfolio.set :host_authorization, { permitted_hosts: [] }

  def app = Portfolio

  # --- integration -------------------------------------------------------

  def test_sinatra_renders_a_page_from_a_file_on_disk
    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<!DOCTYPE html>'
    assert_includes last_response.body, 'Your retirement'
  end

  # The layout is ours, not Sinatra's — it says `contents`, not `yield`.
  def test_the_layout_beside_the_views_is_applied_without_the_page_asking
    get '/'
    refute_includes File.read(File.expand_path('../examples/portfolio/views/index.sp', __dir__)),
                    'layout'
    assert_includes last_response.body, '<nav class="nav"'
    assert_includes last_response.body, '<footer class="footer">'
  end

  def test_a_partial_beside_the_views_becomes_a_word
    get '/'
    assert_includes last_response.body, 'table--holdings'
  end

  def test_locals_reach_the_page
    get '/'
    assert_includes last_response.body, 'Traditional IRA'
    assert_includes last_response.body, '$1,284,506'
  end

  def test_a_second_route_renders_a_different_page
    get '/accounts/2'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Roth IRA'
  end

  def test_the_app_still_controls_its_own_routing
    get '/accounts/99'
    assert_equal 404, last_response.status
  end

  # --- the escape hatch --------------------------------------------------

  # The vocabulary has no word for an embedded video and should not gain one.
  # The app adds a word of its own, in Ruby, and the page says `video .tour_url`.
  def test_an_app_may_add_a_word_in_ruby
    get '/accounts/2'
    assert_includes last_response.body, '<video class="video" src="/tours/2.mp4"'
  end

  def test_the_call_site_does_not_reveal_where_a_word_came_from
    page = File.read(File.expand_path('../examples/portfolio/views/account.sp', __dir__))
    assert_includes page, 'video .tour_url'   # reads exactly like `image .url`
    refute_includes page, 'raw'
    refute_includes page, '<'
  end

  def test_a_ruby_word_may_not_shadow_a_slim_pickins_word
    shadow = Module.new { def table; end }
    error = assert_raises(SlimPickins::Error) do
      SlimPickins::Library.new(words: shadow)
    end
    assert_equal '`table` is already a slim-pickins word — an app cannot redefine it', error.message
  end

  def test_a_word_defined_twice_is_refused
    both = Module.new { def account_card; end }
    error = assert_raises(SlimPickins::Error) do
      SlimPickins::Library.new(partials: { account_card: 'title .name' }, words: both)
    end
    assert_equal '`account_card` is defined twice — as a partial and in Ruby', error.message
  end

  # The surface is the whole of what a word may use — the same surface the
  # vocabulary itself is written with. App words get the nutrients: the
  # subject, the contract's label_for and format_of, the gatherer stack, the
  # capture and pruning. What stays private is the evaluation plumbing no
  # word needs.
  def test_an_app_word_gets_the_same_surface_the_vocabulary_uses
    builder = SlimPickins::Builder.new(SlimPickins::Page.new(locals: {}))
    %i[token html element tag children arguments subject chain label_for format_of
       register! with_gatherer emit_node about prune evaluate capture].each do |m|
      assert_respond_to builder, m
    end
    %i[nest render_partial define_app_words].each do |m|
      refute_respond_to builder, m, "#{m} is evaluation plumbing, not a word's surface"
    end
  end

  # The AST pipeline's middle stage, exposed: a filter transforms the tree
  # between evaluation and the generator. The thumbnails question — count the
  # children, then present — is a filter over the tree.
  def test_a_filter_intercepts_the_tree_before_the_generator
    badge = ->(nodes) { [[:badge, { kind: :ok, label: 'filtered' }, []]] + nodes }
    html = SlimPickins.render("page p\n  text \"x\"\n", locals: { p: {} }, filter: badge)
    assert_includes html, '<span class="badge badge--ok">filtered</span>'
  end

  # An app word building a void element gets what the built-in `image` gets —
  # no closing tag. The thumbnails example surfaced the opposite: an app word
  # writing tag(:img) used to emit a closing tag the built-in never would.
  # (video is NOT void — it keeps its closing tag, as it should.)
  def test_an_app_tag_knows_void_elements
    html = SlimPickins.render("page p\n  photo .url\n", locals: { p: { url: '/t.png' } },
                              library: SlimPickins::Library.new(words: Module.new do
        def photo(*args)
          _, src = arguments(args)
          tag(:img, { class: token(:photo), src: src }, [])
        end
      end))
    refute_includes html, '</img>'
    assert_includes html, '<img class="photo" src="/t.png">'
  end
end
