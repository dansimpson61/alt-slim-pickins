# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../lib/slim_pickins/template'
require_relative '../examples/roth/app'

# Phase 7: roth, ported. The first pages in this language whose subject matter
# was chosen by someone else, and — after the second round — the first results
# this language renders on the server.
class Phase7Test < Minitest::Test
  include Rack::Test::Methods

  Roth::App.set :host_authorization, { permitted_hosts: [] }

  VIEWS = File.expand_path('../examples/roth/views', __dir__)
  PAGE = File.join(VIEWS, 'controls.sp')
  REPORT = File.join(VIEWS, 'partials', 'report.sp')
  SCRIPT = File.expand_path('../examples/roth/public/js/app.js', __dir__)
  SLIM = File.expand_path('~/dev/roth/views/controls.slim')

  def app = Roth::App

  def sentences(path) = File.readlines(path).count { |l| !l.strip.empty? }

  def json_run(**over)
    post '/run', JSON.generate(over), { 'CONTENT_TYPE' => 'application/json' }
    JSON.parse(last_response.body)
  end

  # --- the page ----------------------------------------------------------

  def test_the_ported_page_serves
    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<!DOCTYPE html>'
    assert_includes last_response.body, 'Directional Roth Conversion Sketch'
  end

  # roth is a single-page app, so there is no layout. `stylesheet` still puts
  # itself in <head> from the last lines of the page.
  def test_a_stylesheet_said_last_still_lands_in_the_head
    get '/'
    head = last_response.body[/<head>.*?<\/head>/m]
    assert_includes head, '/assets/slim-pickins.css'
    assert_includes head, '/css/roth.css'
  end

  # --- Scenario owns the names ------------------------------------------

  # The fault this whole round exists to fix. roth's field names lived in the
  # struct, the form and the specs with nothing binding them; a rename reached
  # one and the app silently dropped an income source for eleven months.
  def test_one_object_owns_every_input_name
    scenario = Roth::Scenario.defaults
    Roth::Scenario::FIELDS.each do |field|
      assert_respond_to scenario, field.name
      refute_nil scenario.label_for(field.name), "#{field.name} has no label"
    end
  end

  # And the language makes drift loud: a page naming an attribute the subject
  # does not have raises on the line that named it.
  def test_a_page_cannot_quietly_name_a_field_that_is_gone
    error = assert_raises(SlimPickins::Error) do
      SlimPickins.render('field no_such_input', locals: { scenario: Roth::Scenario.defaults })
    end
    assert_match(/no_such_input/, error.message)
  end

  def test_every_field_the_page_names_exists_on_the_scenario
    named = File.readlines(PAGE).filter_map { |l| l.strip[/\Afield ([a-z_]+)/, 1] }
    assert_equal 11, named.size
    scenario = Roth::Scenario.defaults
    named.each { |n| assert_respond_to scenario, n.to_sym }
  end

  # --- the form ----------------------------------------------------------

  def test_the_defaults_come_from_the_subject_not_the_page
    get '/'
    assert_includes last_response.body, 'name="trad_balance" type="number" value="750000"'
    refute_includes File.read(PAGE), '750'
  end

  def test_no_field_label_is_written_in_the_page
    page = File.read(PAGE)
    Roth::Scenario::FIELDS.each do |field|
      refute_includes page, field.label, "#{field.label.inspect} should come from label_for"
    end
    get '/'
    assert_includes last_response.body, '<label for="ss_primary_amount">SS annual amount</label>'
  end

  def test_the_step_is_inferred_from_the_value
    get '/'
    assert_includes last_response.body, 'name="growth_rate" type="number" value="0.05" step="0.01"'
    refute_includes File.read(PAGE), 'step'
  end

  # --- validation, which roth had none of --------------------------------

  # The API refuses; the form does not. One object, two policies, chosen by
  # the caller.
  def test_the_json_endpoint_refuses_with_a_reason
    body = json_run(horizon_years: 0, age_primary: 500)
    assert_equal 422, last_response.status
    assert_includes body['complaints'], 'Horizon (years) must be between 1 and 60 — using 1'
    assert_includes body['complaints'], 'Age (primary) must be between 0 and 120 — using 120'
  end

  # The seam an outside review found: `/run` validated and `/projection` did
  # not, so the form rendered a 500 for input the API would have refused —
  # the same unenforced-seam disease this round was built to cure.
  def test_the_form_renders_and_says_what_it_did
    post '/projection', { 'age_primary' => '200', 'horizon_years' => '0' }
    assert_equal 200, last_response.status
    shown = last_response.body.scan(/class="note note--warning">([^<]*)/).flatten
    assert_includes shown, 'Age (primary) must be between 0 and 120 — using 120'
    assert_includes shown, 'Horizon (years) must be between 1 and 60 — using 1'
  end

  def test_a_sound_scenario_says_nothing
    get '/'
    refute_includes last_response.body, 'note--warning'
  end

  # roth raised NoMethodError from inside `aggregate` on this input.
  def test_a_zero_horizon_no_longer_crashes
    post '/projection', { 'horizon_years' => '0' }
    assert_equal 200, last_response.status
    assert_equal 1, Roth::Scenario.new('horizon_years' => '0').horizon_years
  end

  def test_blank_and_unparseable_fall_back_to_defaults
    scenario = Roth::Scenario.new('trad_balance' => '', 'age_primary' => 'banana')
    assert_equal 750_000, scenario.trad_balance
    assert_equal 60, scenario.age_primary
    assert scenario.sound?
  end

  # --- the results, now rendered on the server ---------------------------

  def test_the_figures_are_real_and_formatted_by_the_language
    get '/'
    assert_includes last_response.body, '<div class="metric-value">$412,800</div>'
    assert_includes last_response.body, '<div class="metric-value">33.9%</div>'
  end

  # No baseline exists until something is converted, so four of six figures
  # are honestly absent rather than zero.
  def test_an_absent_figure_is_an_em_dash_not_a_number
    get '/'
    assert_equal 4, last_response.body.scan('<div class="metric-value">—</div>').size

    post '/projection', { 'conversion_value' => '50000' }
    assert_equal 0, last_response.body.scan('<div class="metric-value">—</div>').size
  end

  def test_the_year_table_replaces_the_raw_json_dump
    get '/'
    body = last_response.body
    assert_equal 30, body.scan('<tr>').size - 1          # 30 rows plus the header
    assert_includes body, '<caption>Year by year</caption>'
    assert_includes body, '<th class="column--numeric">Medicare surcharge</th>'
    refute_includes body, 'Show Raw JSON'
  end

  # The IRMAA subsystem — table, thresholds, inflation, two-year lag — ran on
  # every request in roth and reached no screen. It has a column now.
  def test_the_irmaa_figures_finally_reach_a_reader
    get '/'
    assert_includes last_response.body, 'Medicare surcharge'
  end

  # Both charts were drawn by an app word until Phase 8 redrafted `chart`
  # against them. They are vocabulary now — see test/phase8_test.rb for what
  # the word does; this only asserts roth still has two of them.
  def test_both_charts_are_server_rendered_svg
    get '/'
    assert_equal 2, last_response.body.scan('<svg class="chart"').size
    assert_includes last_response.body, 'viewBox="0 0 800 320"'
  end

  # The chart the specification asked for and nobody built. Its data was on
  # the wire the whole time; `extractSeries` threw both series away.
  def test_the_balance_chart_the_spec_asked_for_exists
    get '/'
    balances = last_response.body.scan(/<svg class="chart".*?<\/svg>/m).last
    assert_includes balances, 'Traditional'
    assert_includes balances, 'Roth'
  end

  # A viewBox is responsive with no script at all. roth's chart measured
  # clientWidth once at load and never redrew.
  def test_the_charts_carry_no_pixel_width
    get '/'
    svg = last_response.body[/<svg class="chart"[^>]*>/]
    refute_includes svg, 'width='
    assert_includes svg, 'viewBox='
  end

  # --- the full page and the fragment cannot drift -----------------------

  def test_the_swap_renders_the_same_file_the_page_includes
    get '/'
    whole = last_response.body
    post '/projection', {}
    fragment = last_response.body

    assert_equal 200, last_response.status
    refute_includes fragment, '<!DOCTYPE'
    assert fragment.start_with?('<section class="section section--projection">')
    assert_includes whole, fragment
  end

  # --- what the language took away from the script -----------------------

  # roth hand-rolled two show/hide toggles. One became `disclosure`, which is a
  # `<details>` the browser drives; the other — the raw JSON pane — has no
  # reason to exist now the table does its job.
  def test_the_hand_rolled_toggles_are_gone
    get '/'
    assert_equal 1, last_response.body.scan('<details').size
    assert_includes last_response.body, '<summary>Show advanced assumptions</summary>'

    js = File.read(SCRIPT)
    refute_includes js, 'toggle-adv'
    refute_includes js, 'toggle-json'
    refute_includes js, "classList.toggle('hidden')"
  end

  def test_the_script_no_longer_draws_or_formats_anything
    js = File.read(SCRIPT)
    %w[createElementNS niceDomain formatMoney stackPath toLocaleString].each do |gone|
      refute_includes js, gone, "#{gone} should have moved to the server"
    end
  end

  def test_the_script_is_a_fraction_of_what_it_replaced
    code = ->(f) { File.readlines(f).count { |l| s = l.strip; !s.empty? && !s.start_with?('//') } }
    ours = code[SCRIPT]
    theirs = code[File.expand_path('~/dev/roth/public/js/app.js')]
    assert_operator ours, :<, theirs / 4, "ported #{ours} lines against #{theirs}"
  end

  # --- the escape hatch --------------------------------------------------

  # Round one of the port needed three app words, server-rendering removed two,
  # and Phase 8 removed the last — `drawing`, which carried roth's charts.
  # roth now speaks nothing but the vocabulary.
  def test_roth_has_no_words_of_its_own
    refute Roth.const_defined?(:Words), 'roth should need no Ruby-defined words'
    assert_empty SlimPickins::Template.libraries[VIEWS].words
  end

  # Nothing in either page reaches for markup.
  def test_no_page_contains_a_tag
    [PAGE, REPORT].each do |path|
      source = File.read(path)
      refute_includes source, '<', "#{File.basename(path)} should hold no markup"
      refute_includes source, 'div'
    end
  end

  # --- the engine, untouched ---------------------------------------------

  def test_the_projection_still_runs
    assert_operator json_run['totals']['lifetime_taxes_primary'], :>, 0
    assert_equal 200, last_response.status
  end

  def test_a_baseline_appears_only_when_something_is_converted
    refute json_run(conversion_value: 0.0)['compared']
    assert json_run(conversion_value: 50_000.0)['compared']
  end

  # The port fixes a live bug it did not set out to fix: roth's view posts
  # `social_security_*` and `Engine::Inputs` reads `ss_primary_*`. `Scenario`
  # is now the only thing that knows the engine's spelling.
  def test_the_ported_field_names_reach_the_engine
    assert_includes File.read(SLIM), 'name="social_security_amount"',
                    'roth still posts the old name'

    with_ss = json_run['totals']['lifetime_taxes_primary']
    without = json_run(ss_primary_amount: 0)['totals']['lifetime_taxes_primary']
    refute_equal with_ss, without, 'Social Security should change the answer'
  end

  # --- the measurement Phase 7 exists to take ----------------------------

  def test_the_pages_are_smaller_than_the_page_they_replace
    ours = sentences(PAGE) + sentences(REPORT)
    theirs = File.readlines(SLIM).count { |l| !l.strip.empty? }
    assert_operator ours, :<, theirs, "ported #{ours} sentences against #{theirs} lines"
  end
end
