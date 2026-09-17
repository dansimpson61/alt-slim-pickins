require 'sinatra'
require 'sinatra/cookies'
require 'cgi'
require 'json'
require_relative '../lib/slim_pickins'
require_relative 'uis'
require_relative 'docs_helper'
require_relative 'pages'
require_relative 'status'
require_relative 'vitals'

set :port, ENV.fetch('STUDIO_PORT', '4580').to_i

# Every UI boots at load, so a broken UI fails here — naming the file — rather
# than serving half a studio. This is the app's own boot gate, the same shape
# the example apps use: a view the app cannot answer is a load error.
Uis.all

# What the sidebar iterates. Every page that draws it needs both, so they are
# named once here rather than repeated at each render.
SIDEBAR = { words: StudioDocs.words, guides: StudioDocs.guides }.freeze

# The picker remembers a choice in a cookie; Sinatra's cookie helpers are the
# one dependency that costs — a query parameter alone would have to ride every
# link, and `links` exists so a view holds no route at all.
helpers Sinatra::Cookies

helpers do
  # The picker's choice: `?ui=` wins, a cookie remembers, the default is the
  # registry's. A cookie naming a UI that no longer exists falls back rather
  # than 404s — the studio is a workbench, and a deleted UI is not an error.
  def ui
    @ui ||= Uis.current(cookies, params)
  end

  # The UI's own library, built once per UI per process: it carries the UI's
  # layout (so `page` wraps itself in the frame), its partials, the example
  # apps' partials, and every UI's words.
  def library
    @libraries ||= {}
    @libraries[ui.name] ||= StudioPages.ui_library(ui)
  end

  # A page of the UI that is speaking. Never `page` — that is the language's
  # own word, and a helper wearing its name is the alias problem in the app.
  def page_source(name)
    File.read(File.join(ui.views, name))
  end

  # The shelf's entries — the repo's pages with their census verdict, minted
  # by the UI that is serving. Memoised per request: the census renders every
  # page once, and a page that draws the shelf should pay for that once.
  #
  # Every page of every UI gets it, because a UI's shelf is part of its frame
  # rather than a detail of one route. A shelf that appears only on `/` is a
  # shelf you cannot browse from where you are.
  def shelf
    @shelf ||= StudioPages.entries(library: library, loaded: params[:load], paths: ui, ui: ui,
                                   pages_library: StudioPages.library)
  end

  # The locals every page of every UI gets: the shelf's entries, the picker,
  # the language's vitals, and the dated measurement they carry. Named once,
  # so a new UI cannot forget one — and a UI that wants a different shelf
  # overrides a name here rather than building its own payload.
  def commons
    { docs: StudioDocs.build,
      palette: shelf,
      words: StudioDocs.words(ui),
      guides: StudioDocs.guides(ui),
      ui_names: Uis.all.map { |u| { name: u.name, title: u.title, current: u.name == ui.name } },
      ui: ui.name,
      word_count: StudioVitals::WORDS,
      convention_count: StudioVitals::CONVENTIONS,
      promise_count: StudioVitals::PROMISES,
      measured: StudioVitals::MEASURED,
      data_note: StudioDocs::DATA_NOTE,
      words_count: StudioVitals::WORDS,
      pages_count: StudioPages::PAGES.size }
  end
end

# A UI's own selection is sticky for the session; switching is one explicit
# visit. The parameter is honoured on every other route too, so a UI can be
# driven by URL alone when that is what an agent wants.
get '/ui/:name' do
  chosen = Uis[params[:name]] or halt 404, "There is no UI called #{params[:name]}."
  response.set_cookie(Uis::COOKIE, value: chosen.name, path: '/')
  redirect to(chosen.path(chosen.paths[:home]))
end

get '/' do
  loaded_id = params[:load]
  source = StudioPages.source_for(loaded_id, ui: ui) ||
           "page \"Slim-Pickins Studio\"\n  heading \"Hello World\"\n"
  # `palette` is in `commons`, already measured against this UI's own pages
  # and with `loaded` marked, so the route does not build a second census.
  locals = { title: 'Workbench', source: source,
             editor_title: StudioPages.title_for(loaded_id),
             data: loaded_id ? StudioPages.data_json_for(StudioPages::PAGES[loaded_id]) : '',
             loaded: loaded_id, **commons }
  SlimPickins.render(page_source('index.sp'), path: 'index.sp', locals: locals, library: library)
end

# A word's documentation, served through the language rather than
# round-tripped through the playground — the same reason the guides are.
# The payload comes from `StudioDocs.entries` as a plain hash lookup: a
# word's name is a string key here, never a method name, so no word name
# ever has to survive dispatch on the playground's OpenStruct.
get '/docs/:word' do
  entry = StudioDocs.entries[params[:word]]
  halt 404, "There is no word called #{params[:word]}." unless entry

  try_index = params[:try] && params[:try].to_i
  examples = StudioDocs.examples_of(params[:word], ui: ui) do |path, chain|
    StudioPages.data_json_for(path, chain)
  end
  example = examples[try_index || 0]
  seedable = example&.try_path
  locals = { title: "Docs: #{params[:word]}", contract: entry[:contract],
             implementation: entry[:implementation],
             examples: examples,
             source: seedable ? (StudioDocs.seed_for(params[:word], try_index || 0) || '') : '',
             editor_title: "Try it: #{params[:word]}",
             data: seedable ? example.data.to_s : '',
             data_note: StudioDocs::DATA_NOTE, **commons }
  SlimPickins.render(page_source('docs.sp'), path: 'docs.sp', locals: locals, library: library)
end

# A guide is one of this repo's own documents, served through the language
# rather than round-tripped through the playground. The playground could not
# serve it: `/render` receives only the editor's `source`, so a page saying
# `prose markdown, .content` arrives with no content to read.
#
# `File.basename` is what keeps `../` out of the path; the guide must be a
# markdown document sitting at the repo root, or it does not exist.
get '/guides/:name' do
  name = File.basename(params[:name], '.md')
  document = File.expand_path("../#{name}.md", __dir__)
  halt 404, "There is no guide called #{name}." unless File.file?(document)

  locals = { title: "Guide: #{name}", content: File.read(document), **commons }
  SlimPickins.render(page_source('guide.sp'), path: 'guide.sp', locals: locals, library: library)
end

# The checkers' output, served through the language rather than pasted into
# a shell. Each leg runs live — `StudioStatus.run` shells the gate scripts
# and captures their stdout — so the page can never claim a green that the
# repo no longer has. The page itself is held by check_grammar like every
# other page: the studio joined the corpus when this page did.
get '/status' do
  results = StudioStatus.run
  locals = { title: 'Status', overview: StudioStatus.overview(results), results: results, **commons }
  SlimPickins.render(page_source('status.sp'), path: 'status.sp', locals: locals, library: library)
end

post '/render' do
  StudioPages.render_json(params[:source].to_s, params[:data], library: library)[:visual]
end

# The render contract, as JSON — one request, both panes. The controller on
# the wired form fetches this. There is no no-JavaScript path: the form's
# action names the route a submit would take, and nothing fills the panes
# without the controller. dan's ruling (2026-09-17): the fallback claim was
# dropped rather than built, and the studio says rendering requires
# JavaScript rather than hiding it.
post '/render.json' do
  content_type :json
  JSON.generate(StudioPages.render_json(params[:source].to_s, params[:data], library: library))
end

# The studio's static assets — the stylesheet, the vendored Stimulus, the
# controller. A whitelist rather than a glob: an asset route must never
# become a file reader.
ASSETS = %w[slim-pickins.css stimulus.umd.js studio.js].freeze

get '/assets/:file' do
  name = File.basename(params[:file])
  halt 404, "There is no asset called #{name}." unless ASSETS.include?(name)

  content_type name.end_with?('.css') ? 'text/css' : 'text/javascript'
  File.read(File.expand_path("../assets/#{name}", __dir__))
end
