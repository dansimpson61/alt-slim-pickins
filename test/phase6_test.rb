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

  Portfolio.set :environment, :test
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

  def test_a_ruby_word_may_shadow_a_slim_pickins_word
    shadow = Module.new { def table; end }
    lib = SlimPickins::Library.new(words: shadow)
    assert_includes lib.shadowed_words, :table
  end

  def test_a_word_defined_twice_is_refused
    both = Module.new { def test_account_card; end }
    error = assert_raises(SlimPickins::Error) do
      SlimPickins::Library.new(partials: { test_account_card: 'title .name' }, words: both)
    end
    assert_equal '`test_account_card` is defined twice — as a partial and in Ruby', error.message
  end

  # The surface is the whole of what a word may use — the same surface the
  # vocabulary itself is written with. App words get the nutrients: the
  # subject, the contract's label_for and format_of, the gatherer stack, the
  # capture and pruning. What stays private is the evaluation plumbing no
  # word needs.
  def test_an_app_word_gets_the_same_surface_the_vocabulary_uses
    builder = SlimPickins::Builder.new(SlimPickins::Page.new(locals: {}))
    %i[token html element tag arguments subject chain label_for format_of
       register! with_gatherer emit_node about prune evaluate capture].each do |m|
      assert_respond_to builder, m
    end
    %i[nest define_app_words with_line eval_with locate].each do |m|
      refute_respond_to builder, m, "#{m} is evaluation plumbing, not a word's surface"
    end
  end

  # The AST pipeline's middle stage, exposed: a filter transforms the tree
  # between evaluation and the generator. The thumbnails question — count the
  # children, then present — is a filter over the tree.
  def test_a_filter_intercepts_the_tree_before_the_generator
    badge = lambda do |nodes|
      [SlimPickins::Node[:span, { class_base: :badge, variant: :ok, body: 'filtered' }, []]] + nodes
    end
    html = SlimPickins.render("p\n  text \"x\"\n", locals: { p: {} }, filter: badge)
    assert_includes html, '<span class="badge badge--ok">filtered</span>'
  end

  # dan's word-not-power decision: the favicon is a page modifier, absorbed
  # like the doctype — written where the page begins, landed in the head.
  def test_a_page_modifier_favicon_lands_in_the_head
    html = SlimPickins.render("p, favicon: \"/x.ico\"\n  text \"hi\"\n", locals: { p: {} })
    assert_includes html, '<link rel="icon" href="/x.ico">'
    refute_includes html[html.index('</head>')..], 'rel="icon"'
  end

  # An app word building a void element gets what the built-in `image` gets —
  # no closing tag. The thumbnails example surfaced the opposite: an app word
  # writing tag(:img) used to emit a closing tag the built-in never would.
  # (video is NOT void — it keeps its closing tag, as it should.)
  def test_an_app_tag_knows_void_elements
    html = SlimPickins.render("p\n  photo .url\n", locals: { p: { url: '/t.png' } },
                              library: SlimPickins::Library.new(words: Module.new do
        def photo(*args)
          _, src = arguments(args)
          tag(:img, { class: token(:photo), src: src }, [])
        end
      end))
    refute_includes html, '</img>'
    assert_includes html, '<img class="photo" src="/t.png">'
  end

  # --- Wall 2 & CRUD Validation (Daytrip 0.9.0d) -------------------------

  def test_new_account_form_renders_cleanly
    get '/accounts/new'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Open New Account'
    assert_includes last_response.body, '<form class="form" action="/accounts" method="post">'
    assert_includes last_response.body, '<input id="name" name="name" type="text"'
  end

  def test_create_account_re_renders_422_with_validation_diagnostics
    post '/accounts', { name: '', institution: '', account_type: 'brokerage' }
    assert_equal 422, last_response.status
    assert_includes last_response.body, 'Please correct the errors below.'
    assert_includes last_response.body, '<div class="field field--invalid">'
    assert_includes last_response.body, 'aria-invalid="true"'
    assert_includes last_response.body, 'aria-describedby="name-error"'
    assert_includes last_response.body, '<span class="field-error" id="name-error">Name can&#39;t be blank</span>'
  end

  def test_create_account_succeeds_and_redirects
    post '/accounts', { name: 'Emergency Fund', institution: 'Ally', account_type: 'savings', balance: '15000' }
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Emergency Fund'
  end

  def test_edit_account_form_renders_with_existing_values
    account = Portfolio::Repository.new.all_accounts.first
    get "/accounts/#{account.id}/edit"
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Edit Account'
    assert_includes last_response.body, '<input type="hidden" name="_method" value="patch">'
    assert_includes last_response.body, %(value="#{account.name}")
  end

  def test_update_account_re_renders_422_on_invalid_patch
    account = Portfolio::Repository.new.all_accounts.first
    patch "/accounts/#{account.id}", { name: '', institution: '' }
    assert_equal 422, last_response.status
    assert_includes last_response.body, 'Please correct the errors below.'
    assert_includes last_response.body, '<div class="field field--invalid">'
    assert_includes last_response.body, 'aria-invalid="true"'
  end

  def test_update_account_succeeds_and_redirects_on_valid_patch
    account = Portfolio::Repository.new.all_accounts.first
    patch "/accounts/#{account.id}", { name: 'Renamed Account', institution: account.institution, account_type: account.account_type }
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Renamed Account'
  end

  # --- Wall 3: Flash Lifecycle & Empty State Healing (Daytrip 0.9.0e) ---

  def test_flash_lifecycle_displays_notice_after_creation_and_clears_on_subsequent_request
    post '/accounts', { name: 'Growth Brokerage', institution: 'Schwab', account_type: 'brokerage' }
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<p class="flash">Account &quot;Growth Brokerage&quot; was successfully opened.</p>'

    # Subsequent request on the same account should not show the flash message
    get last_request.path
    assert_equal 200, last_response.status
    refute_includes last_response.body, 'was successfully opened'
  end

  def test_flash_lifecycle_displays_notice_after_deletion
    account = Portfolio::Repository.new.all_accounts.first
    delete "/accounts/#{account.id}"
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'was successfully closed.'

    # Subsequent request on overview should clear the notice
    get '/'
    refute_includes last_response.body, 'was successfully closed.'
  end

  def test_empty_accounts_state_renders_message_and_actions
    empty_portfolio = Portfolio::PortfolioSummary.new(
      accounts: [], total_value: 0.0, gain: 0.0, ytd_return: 0.0, annual_income: 0.0, cash_balance: 0.0
    )
    views_dir = File.expand_path('../examples/portfolio/views', __dir__)
    html = SlimPickins.render(File.read(File.join(views_dir, 'index.sp')),
                              path: File.join(views_dir, 'index.sp'),
                              locals: { portfolio: empty_portfolio },
                              library: SlimPickins::Library.from(views_dir, words: AppWords))
    assert_includes html, '<p class="empty">No accounts linked yet.</p>'
    assert_includes html, '<div class="actions"><a href="/accounts/new" class="link">Open new account</a></div>'
  end

  # --- Wall 5: Spatial Posture & Workbench Companions (Daytrip 0.9.0f) ---

  def test_portfolio_links_and_serves_spatial_and_style_companions
    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<link rel="stylesheet" href="/assets/portfolio.css">'
    assert_includes last_response.body, '<link rel="stylesheet" href="/assets/portfolio.style.css">'

    get '/assets/portfolio.css'
    assert_equal 200, last_response.status
    assert_includes last_response.content_type, 'text/css'
    assert_includes last_response.body, 'container-name: portfolio;'
    assert_includes last_response.body, 'font-variant-numeric: tabular-nums;'

    get '/assets/portfolio.style.css'
    assert_equal 200, last_response.status
    assert_includes last_response.content_type, 'text/css'
    assert_includes last_response.body, '--measure: 72ch;'
    assert_includes last_response.body, '--gap: 0.5rem;'
    assert_includes last_response.body, '--lead: 1.35;'
  end

  # --- Holdings CRUD & Account Detail Elevation (RIF 1) ---

  def test_holdings_crud_lifecycle_and_account_elevation
    repo = Portfolio::Repository.new
    acc, = repo.create_account(name: 'Integration Brokerage', institution: 'TestBank', balance: 5000.0)
    assert acc.id

    # 1. View account detail
    get "/accounts/#{acc.id}"
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Portfolio holdings'
    assert_includes last_response.body, '+ Add holding'
    assert_includes last_response.body, 'Recent activity'

    # 2. View new holding form
    get "/accounts/#{acc.id}/holdings/new"
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Add position'
    assert_includes last_response.body, 'Ticker Symbol'

    # 3. Validation failure (422)
    post "/accounts/#{acc.id}/holdings", { symbol: '', shares: '0', cost_basis: '0' }
    assert_equal 422, last_response.status
    assert_includes last_response.body, 'Please correct the errors below.'

    # 4. Create valid holding
    post "/accounts/#{acc.id}/holdings", { symbol: 'SCHD', shares: '50', cost_basis: '28.50', current_price: '30.00' }
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'SCHD'
    assert_includes last_response.body, 'Added 50.0 shares of SCHD.'

    holding = repo.holdings_for_account(acc.id).find { |h| h.symbol == 'SCHD' }
    assert holding

    # 5. Edit holding form
    get "/holdings/#{holding.id}/edit"
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Edit position'
    assert_includes last_response.body, 'value="SCHD"'

    # 6. Update holding via PUT
    put "/holdings/#{holding.id}", { shares: '60', cost_basis: '28.50', current_price: '32.00' }
    assert_equal 302, last_response.status
    follow_redirect!
    assert_includes last_response.body, 'Updated position for SCHD.'

    # 7. Safe sell confirmation
    get "/holdings/#{holding.id}/sell"
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Liquidate holding'
    assert_includes last_response.body, 'Shares to sell'
    assert_includes last_response.body, 'Liquidate position'

    # 8. Delete holding via DELETE
    delete "/holdings/#{holding.id}"
    assert_equal 302, last_response.status
    follow_redirect!
    assert_includes last_response.body, 'Liquidated 60.0 shares of SCHD'

    # Cleanup
    repo.delete_account(acc.id)
  end
end
