# frozen_string_literal: true

# Phase 7 — roth, ported to this language.
#
# The engine is roth's, untouched. Only the view changes: 91 lines of
# hand-written Slim become 46 sentences plus the five words below.
#
# roth is a single-page app, so the honest comparison is one file to one file
# and there is no layout here. The chrome a layout would hold — the stylesheet,
# the script, the footer — is said in the page, because `stylesheet` and
# `script` say where they belong rather than where they are written.

require 'json'
require 'delegate'
require 'ostruct' # roth's projector builds OpenStructs and never requires it
require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'

ROTH = File.expand_path('~/dev/roth')
require File.join(ROTH, 'lib/engine/inputs')
require File.join(ROTH, 'lib/engine/projector')
require File.join(ROTH, 'lib/engine/strategy/fixed_amount')
require File.join(ROTH, 'lib/engine/strategy/fill_bracket')
require File.join(ROTH, 'lib/engine/tax_tables')

# The escape hatch, used as designed: these are words roth needs and the
# vocabulary of web presentation should not have.
#
# Every one of them exists because roth draws its results in the browser. The
# language renders on the server, so where a result belongs there is a hole,
# and a hole that a script fills is exactly the kind of app peculiarity that
# must not leak into a shared vocabulary. Each is named for the thing it holds,
# so the page still says what is there rather than emitting an anonymous div.
module RothWords
  # `metric` presents a value. This presents the absence of one — a number
  # that arrives from /run after the page has been served. The distinction is
  # worth a word: a reader can see which figures the server knows and which it
  # does not, which the hand-written page left implicit in a `--`.
  def pending(*args)
    name, label = arguments(args)
    html(%(<div class="#{token(:metric)}">) +
         %(<h3 class="metric-label">#{escape(label)}</h3>) +
         %(<div class="metric-value" data-metric="#{escape(name)}">--</div></div>))
  end

  # roth's SVG chart, drawn in the browser from the projection. `chart` exists
  # in the vocabulary and draws a series the server already holds, so this is a
  # mount rather than a chart; Phase 8 is where `chart` gets redrafted against
  # it.
  #
  # The legend and the tooltip are parts of the chart, not things a page should
  # have to name, so they live inside the word — the same way `metric` emits
  # its own label and value. The frame is what the tooltip positions against.
  # The parts take the `.word-part` shape the stylesheet already uses for
  # `.metric-label` and `.chart-slice`.
  #
  # Deliberately not `token(:chart)`. Borrowing the vocabulary's class looked
  # tidy and was wrong: `.chart` carries `max-width: var(--measure-chart)`,
  # which is right for a figure the language draws and capped roth's
  # full-bleed chart at 512px. An app word that reuses a vocabulary class
  # inherits styling written for a different thing.
  def balance_chart(*_args)
    html('<div class="chart-frame">' \
         '<svg id="balance-chart" class="chart-canvas"></svg>' \
         '<div id="chart-legend" class="chart-legend"></div>' \
         '<div id="chart-tooltip" class="chart-tooltip"></div>' \
         '</div>')
  end

  # The raw projection JSON, for looking under the bonnet.
  def raw_output(*_args) = html(%(<pre id="output" class="#{token(:snippet)}"></pre>))
end

# The optional half of the contract. roth is the only thing that knows
# `ss_primary_amount` means "SS annual amount", so roth is where it is said —
# once, rather than on every page that shows the field.
class Scenario < SimpleDelegator
  LABELS = {
    age_primary: 'Age (primary)', age_spouse: 'Age (spouse)',
    trad_balance: 'Traditional balance', roth_balance: 'Roth balance',
    ss_primary_start_year: 'SS start (years from now)',
    ss_primary_amount: 'SS annual amount',
    ss_spouse_start_year: 'Spouse SS start (years from now)',
    ss_spouse_amount: 'Spouse SS annual amount',
    inflation_rate: 'Inflation', horizon_years: 'Horizon (years)',
    conversion_value: 'Strategy value', conversion_strategy: 'Strategy'
  }.freeze

  def label_for(attribute) = LABELS[attribute]
end

class Roth < Sinatra::Base
  helpers SlimPickins::Helpers

  set :views, File.join(__dir__, 'views')
  set :public_folder, File.join(__dir__, 'public')
  set :static, true

  # One place says what this app's vocabulary is.
  SlimPickins::Template.libraries[settings.views] =
    SlimPickins::Library.from(settings.views).tap do |lib|
      lib.instance_variable_set(:@words, RothWords)
    end

  # The values the hand-written page carried as `value="…"` attributes. Here
  # they are the subject's own data, which is why the page never states one.
  DEFAULTS = {
    'age_primary' => 60, 'age_spouse' => 58,
    'trad_balance' => 750_000, 'roth_balance' => 150_000, 'base_income' => 80_000,
    'ss_primary_start_year' => 7, 'ss_primary_amount' => 45_000,
    'conversion_value' => 0.0
  }.freeze

  helpers do
    # `form controls` is about these, and every `field` beneath it reads one.
    def controls = Scenario.new(Engine::Inputs.from_hash(DEFAULTS))

    # The chart's baseline toggle. Unchecked when the page is served; the
    # script owns it from there.
    def show_baseline = false

    def strategy_from(inputs)
      case inputs.conversion_strategy
      when 'fill_bracket' then Engine::Strategy::FillBracket.new(target_bracket: inputs.conversion_value)
      else Engine::Strategy::FixedAmount.new(amount: inputs.conversion_value || 0)
      end
    end
  end

  get('/') { sp :controls }

  # The language's own stylesheet lives in the repo, not in this app's public
  # folder. Named exactly, rather than mounted as a directory.
  get('/assets/slim-pickins.css') do
    send_file File.expand_path('../../assets/slim-pickins.css', __dir__)
  end

  # roth's own endpoint, unchanged in substance — the port is of the view.
  post '/run' do
    content_type :json
    inputs = Engine::Inputs.from_hash(JSON.parse(request.body.read))
    result = Engine::Projector.new(inputs: inputs, strategy: strategy_from(inputs)).run
    seniors = [inputs.age_primary.to_i >= 65 ? 1 : 0,
               inputs.age_spouse.to_i >= 65 ? 1 : 0].sum
    std_ded = Engine::TaxTables.standard_deduction(inputs.current_year, inputs.inflation_rate, seniors)

    output = { primary: scenario_hash(result.primary, std_ded) }
    output[:baseline] = scenario_hash(result.baseline, std_ded) if result.baseline
    JSON.pretty_generate(output)
  end

  helpers do
    def scenario_hash(run, std_ded)
      { scenario: run.scenario, totals: run.totals, years: run.years.map(&:to_h),
        brackets: run.brackets, standard_deduction: std_ded }
    end
  end

  run! if app_file == $PROGRAM_NAME
end
