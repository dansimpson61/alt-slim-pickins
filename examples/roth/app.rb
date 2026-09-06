# frozen_string_literal: true

# Phase 7, second round — roth ported deeply.
#
# The first round replaced the markup. This one replaces the architecture, and
# moves the results to the server:
#
#   Scenario    owns the input names, their defaults, labels, formats and
#               bounds — the single source that roth's rename went round.
#   Projector   roth's engine, untouched. See ROTH_DOMAIN_BACKLOG.md.
#   Projection  a presenter: the six figures, the table, the two charts.
#   views/*.sp  the language.
#   this file   parse, project, render. Nothing else.
#
# There is no model layer in the persistence sense because roth has no
# persistent state — each request is a pure function from a scenario to a
# projection. Scenario is a validated value object and the engine is a pure
# calculation; between them they are the "M", and inventing a record to sit
# behind them would be ceremony.

require 'json'
require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative 'lib/scenario'
require_relative 'lib/projection'

module Roth
  # roth has no words of its own.
  #
  # Round one of the port needed three: `pending` for each figure the server
  # did not know, plus mounts for the chart and the raw JSON pane. Rendering on
  # the server removed all but one — `drawing`, which carried the 130 lines of
  # Ruby that drew roth's charts. Phase 8 redrafted `chart` against exactly
  # those 130 lines, and the last word went with them.
  #
  # An app that speaks only the vocabulary is the strongest form of the claim
  # this project set out to test, and it took a real app's real charts to get
  # there.
  class App < Sinatra::Base
    helpers SlimPickins::Helpers

    set :views, File.join(__dir__, 'views')
    set :public_folder, File.join(__dir__, 'public')
    set :static, true
    # A demo whose stylesheet is being edited. Heuristic caching served a
    # stale sheet once and cost a confusing half hour; nothing here is worth
    # caching.
    set :static_cache_control, [:no_store]
    # A `Sinatra::Base` subclass does not parse ARGV, so `-p` is silently
    # ignored and `run!` takes 4567 — which roth itself is usually holding.
    set :port, ENV.fetch('PORT', 4577).to_i

    SlimPickins::Template.libraries[settings.views] = SlimPickins::Library.from(settings.views)

    # Boot proves the pages: an attribute renamed or removed in the model
    # fails here, naming the line and the attribute — the eleven-month
    # silence is a boot error, by construction.
    SlimPickins.prove!(settings.views) do |_name|
      scenario = Scenario.defaults
      { scenario: scenario, projection: Projection.of(scenario) }
    end

    REPORT = File.join(settings.views, 'partials', 'report.sp')

    helpers do
      def project(params)
        scenario = Scenario.new(params)
        [scenario, Projection.of(scenario)]
      end
    end

    # The whole page: form and results together, both rendered here.
    get '/' do
      scenario, projection = project(params)
      sp :controls, locals: { scenario: scenario, projection: projection }
    end

    # The results box on its own, for the swap. It renders the *same file*
    # the full page includes as a partial, so the two cannot drift.
    post '/projection' do
      scenario, projection = project(request_params)
      SlimPickins.render(File.read(REPORT), path: REPORT,
                                            locals: { scenario: scenario, projection: projection },
                                            library: SlimPickins::Template.libraries[settings.views])
    end

    # roth's own JSON endpoint, kept so the engine stays callable on its own.
    post '/run' do
      content_type :json
      scenario = Scenario.new(request_params)
      unless scenario.sound?
        halt 422, JSON.generate(complaints: scenario.complaints.map(&:description))
      end

      JSON.pretty_generate(Projection.of(scenario).to_h)
    end

    get '/assets/slim-pickins.css' do
      cache_control :no_store
      send_file File.expand_path('../../assets/slim-pickins.css', __dir__)
    end

    private

    # A form post or a JSON body, whichever arrived. Scenario copes with
    # missing, blank and unparseable on its own, so this only has to decide
    # which envelope it is looking at.
    def request_params
      return params unless request.media_type == 'application/json'

      body = request.body.read
      body.empty? ? {} : JSON.parse(body)
    rescue JSON::ParserError
      {}
    end

    run! if app_file == $PROGRAM_NAME
  end
end
