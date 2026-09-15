require 'sinatra'
require 'cgi'
require_relative '../lib/slim_pickins'
require_relative 'docs_helper'
require_relative 'pages'
require_relative 'status'

set :port, ENV.fetch('STUDIO_PORT', '4580').to_i
set :views, File.join(__dir__, 'views')

STUDIO_LIBRARY = SlimPickins::Library.from(File.expand_path('views', __dir__))

# What the sidebar iterates. Every page that draws it needs both, so they are
# named once here rather than repeated at each render.
SIDEBAR = { words: StudioDocs.words, guides: StudioDocs.guides }.freeze

get '/' do
  loaded_id = params[:load]
  source = StudioPages.source_for(loaded_id) ||
           "page \"Slim-Pickins Studio\"\n  heading \"Hello World\"\n"
  SlimPickins.render(File.read(File.join(settings.views, 'index.sp')), path: 'index.sp',
                     locals: { source: source,
                               palette: StudioPages.entries(library: StudioPages.library, loaded: loaded_id),
                               editor_title: StudioPages.title_for(loaded_id),
                               data: loaded_id ? StudioPages.data_json_for(StudioPages::PAGES[loaded_id]) : '',
                               docs: StudioDocs.build, **SIDEBAR },
                     library: STUDIO_LIBRARY)
end

# A word's documentation, served through the language rather than
# round-tripped through the playground — the same reason the guides are.
# The payload comes from `StudioDocs.entries` as a plain hash lookup: a
# word's name is a string key here, never a method name, so no word name
# ever has to survive dispatch on the playground's OpenStruct.
#
# The page also carries the word's try-it pane: the repo's real sentences
# using the word, each with a seed link, and the editor itself — the same
# form and iframes the playground uses. `?try=N` picks the example to seed;
# without it the first example is seeded, so the pane is never empty.
get '/docs/:word' do
  entry = StudioDocs.entries[params[:word]]
  halt 404, "There is no word called #{params[:word]}." unless entry

  try_index = params[:try] && params[:try].to_i
  examples = StudioDocs.examples_of(params[:word]) { |path| StudioPages.data_json_for(path) }
  example = examples[try_index || 0]
  SlimPickins.render(File.read(File.join(settings.views, 'docs.sp')), path: 'docs.sp',
                     locals: { title: "Docs: #{params[:word]}", contract: entry[:contract],
                               implementation: entry[:implementation],
                               examples: examples,
                               source: StudioDocs.seed_for(params[:word], try_index || 0) || '',
                               editor_title: "Try it: #{params[:word]}",
                               data: example ? example.data.to_s : '',
                               data_note: StudioDocs::DATA_NOTE, **SIDEBAR },
                     library: STUDIO_LIBRARY)
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

  SlimPickins.render(File.read(File.join(settings.views, 'guide.sp')),
                     path: 'guide.sp',
                     locals: { title: "Guide: #{name}", content: File.read(document), **SIDEBAR },
                     library: STUDIO_LIBRARY)
end

# The checkers' output, served through the language rather than pasted into
# a shell. Each leg runs live — `StudioStatus.run` shells the four gate
# scripts and captures their stdout — so the page can never claim a green
# that the repo no longer has. The page itself is held by check_grammar
# like every other page: the studio joined the corpus when this page did.
get '/status' do
  results = StudioStatus.run
  SlimPickins.render(File.read(File.join(settings.views, 'status.sp')), path: 'status.sp',
                     locals: { title: 'Status', overview: StudioStatus.overview(results),
                               results: results, **SIDEBAR },
                     library: STUDIO_LIBRARY)
end

post '/render' do
  source = params[:source].to_s
  begin
    SlimPickins.render(source, path: "playground.sp",
                       locals: StudioPages.playground_locals(params[:data]),
                       library: StudioPages.library)
  rescue StandardError => e
    render_refusal(e)
  end
end

post '/render_html' do
  source = params[:source].to_s
  begin
    html = SlimPickins.render(source, path: "playground.sp",
                              locals: StudioPages.playground_locals(params[:data]),
                              library: StudioPages.library)
    "<!DOCTYPE html><html><head><style>body { font-family: monospace; white-space: pre-wrap; padding: 1rem; }</style></head><body>#{CGI.escapeHTML(html)}</body></html>"
  rescue StandardError => e
    "<!DOCTYPE html><html><head><style>body { font-family: monospace; white-space: pre-wrap; padding: 1rem; }</style></head><body>#{CGI.escapeHTML(render_refusal(e))}</body></html>"
  end
end

# A playground error, rendered through the language — the same voice
# everywhere else in the language speaks. The complaint is the error's own
# first line; the location and the sentence join it when the error knows
# them (a JSON parse error names no sentence). The final string below is
# the last hand-built error in the studio: it exists only for the refusal
# page failing, which must not be able to break the studio.
def render_refusal(error)
  complaint, where, line =
    if error.is_a?(SlimPickins::Error)
      [error.message.lines.first.strip,
       error.located? ? "#{error.path}, line #{error.lineno}" : nil,
       error.line]
    else
      ["#{error.class}: #{error.message.lines.first.strip}", nil, nil]
    end
  SlimPickins.render(File.read(File.join(settings.views, 'refusal.sp')), path: 'refusal.sp',
                     locals: { title: 'Refusal', complaint: complaint, where: where, line: line },
                     library: STUDIO_LIBRARY)
rescue StandardError
  "<div style='color: red; padding: 1rem;'><strong>Error:</strong> #{CGI.escapeHTML(error.message)}</div>"
end

get '/assets/slim-pickins.css' do
  content_type 'text/css'
  File.read(File.expand_path('../assets/slim-pickins.css', __dir__))
end
