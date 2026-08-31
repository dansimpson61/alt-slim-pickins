# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../lib/slim_pickins/template'
require_relative '../examples/roth/app'

# Phase 7: roth, ported. The first pages written in this language whose subject
# matter was chosen by someone else, and the first honest test of the claim
# that the escape hatch is rarely needed.
class Phase7Test < Minitest::Test
  include Rack::Test::Methods

  Roth.set :host_authorization, { permitted_hosts: [] }

  PAGE = File.expand_path('../examples/roth/views/controls.sp', __dir__)
  SLIM = File.expand_path('~/dev/roth/views/controls.slim')

  def app = Roth

  BASE = { age_primary: 60, age_spouse: 58, trad_balance: 750_000,
           roth_balance: 150_000, base_income: 80_000,
           ss_primary_start_year: 7, ss_primary_amount: 45_000,
           growth_rate: 0.05, inflation_rate: 0.02, horizon_years: 30,
           conversion_strategy: 'fixed', conversion_value: 0.0 }.freeze

  def json_run(except: [], **overrides)
    payload = BASE.reject { |k, _| except.include?(k) }.merge(overrides)
    post '/run', JSON.generate(payload), { 'CONTENT_TYPE' => 'application/json' }
    JSON.parse(last_response.body)
  end

  SS_KEYS = %i[ss_primary_start_year ss_primary_amount].freeze

  # --- the page renders --------------------------------------------------

  def test_the_ported_page_serves
    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<!DOCTYPE html>'
    assert_includes last_response.body, 'Directional Roth Conversion Sketch'
  end

  # roth is a single-page app, so there is no layout. The chrome is said in the
  # page, and `stylesheet` still puts itself in <head> from the last line of it.
  def test_a_stylesheet_said_last_still_lands_in_the_head
    get '/'
    head = last_response.body[/<head>.*?<\/head>/m]
    assert_includes head, '/assets/slim-pickins.css'
    assert_includes head, '/css/roth.css'
  end

  # --- the form ----------------------------------------------------------

  # Every value in the hand-written page was an attribute; here it is data, so
  # the page states none of them.
  def test_the_defaults_come_from_the_subject_not_the_page
    get '/'
    assert_includes last_response.body, 'name="trad_balance" type="number" value="750000"'
    refute_includes File.read(PAGE), '750'
  end

  # The whole of CONTRACT.md's optional half, exercised: fourteen labelled
  # controls and not one label written in the page.
  def test_no_field_label_is_written_in_the_page
    page = File.read(PAGE)
    Scenario::LABELS.each_value do |label|
      refute_includes page, label, "#{label.inspect} should come from label_for, not the page"
    end
    get '/'
    assert_includes last_response.body, '<label for="ss_primary_amount">SS annual amount</label>'
  end

  # A float under 1 is a rate and wants a finer step. Nothing says so.
  def test_the_step_is_inferred_from_the_value
    get '/'
    assert_includes last_response.body, 'name="growth_rate" type="number" value="0.05" step="0.01"'
    refute_includes File.read(PAGE), 'step'
  end

  # --- what the language took away from the script -----------------------

  # `disclosure` is a <details>. The hand-written page had two JS toggles and
  # a `.hidden` class; both are gone, and the browser does it.
  def test_the_two_disclosures_need_no_script
    get '/'
    assert_equal 2, last_response.body.scan('<details>').size
    js = File.read(File.expand_path('../examples/roth/public/js/app.js', __dir__))
    refute_includes js, 'toggle-adv'
    refute_includes js, 'toggle-json'
    refute_includes js, "classList.toggle('hidden')"
  end

  # --- the escape hatch, used by an app it did not design ----------------

  def test_the_app_words_render
    get '/'
    body = last_response.body
    assert_equal 6, body.scan('class="metric-value"').size
    assert_includes body, '<div class="metric-value" data-metric="tax_delta">--</div>'
    assert_includes body, '<svg id="balance-chart" class="chart-canvas">'
    assert_includes body, '<pre id="output" class="snippet">'
  end

  # The point of the hatch: a reader cannot tell `pending` from `metric`.
  def test_an_app_word_reads_like_a_built_in
    page = File.read(PAGE)
    assert_includes page, 'pending tax_delta, "Tax delta"'
    refute_includes page, '<'
    refute_includes page, 'div'
  end

  # `.chart` carries `max-width: var(--measure-chart)`, which is right for a
  # figure the language draws and wrong for roth's full-bleed chart. An app
  # word that borrows a vocabulary class inherits styling meant for something
  # else, so this one does not borrow it.
  def test_the_chart_mount_does_not_borrow_the_vocabulary_class
    get '/'
    refute_includes last_response.body, 'id="balance-chart" class="chart"'
  end

  # --- the engine, untouched ---------------------------------------------

  def test_the_projection_still_runs
    totals = json_run['primary']['totals']
    assert_equal 200, last_response.status
    assert_operator totals['taxes_paid'], :>, 0
  end

  # The projector only produces a baseline when a conversion is actually made,
  # so the `--` a served page shows for four of six metrics is correct.
  def test_a_baseline_appears_only_when_something_is_converted
    assert_equal %w[primary], json_run(conversion_value: 0.0).keys
    assert_equal %w[primary baseline], json_run(conversion_value: 50_000.0).keys
  end

  # The port fixes a live bug it did not set out to fix. roth's view posts
  # `social_security_*`; `Engine::Inputs` was renamed to `ss_primary_*` and
  # reads nothing else, so Social Security is silently dropped in the running
  # app. The ported page uses the engine's own names.
  def test_the_ported_field_names_reach_the_engine
    slim = File.read(SLIM)
    assert_includes slim, 'name="social_security_amount"', 'roth still posts the old name'

    taxes = lambda { |result| result['primary']['totals']['taxes_paid'] }

    ported     = taxes[json_run]
    old_names  = taxes[json_run(except: SS_KEYS, social_security_amount: 45_000,
                                social_security_start_year: 7)]
    without_ss = taxes[json_run(except: SS_KEYS)]

    refute_equal ported, old_names,
                 'the engine should read the ported names and not the old ones'
    assert_equal without_ss, old_names,
                 'posting the old names is indistinguishable from no Social Security'
  end

  # --- the measurement Phase 7 exists to take ----------------------------

  def test_the_port_is_smaller_than_the_page_it_replaces
    ours   = File.readlines(PAGE).count { |l| !l.strip.empty? }
    theirs = File.readlines(SLIM).count { |l| !l.strip.empty? }
    assert_operator ours, :<, theirs, "ported #{ours} lines vs #{theirs} hand-written"
  end
end
