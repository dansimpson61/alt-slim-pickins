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
                               palette: StudioPages.entries(library: STUDIO_LIBRARY, loaded: loaded_id),
                               editor_title: StudioPages.title_for(loaded_id),
                               docs: StudioDocs.build, **SIDEBAR },
                     library: STUDIO_LIBRARY)
end

# A word's documentation, served through the language rather than
# round-tripped through the playground — the same reason the guides are.
# The payload comes from `StudioDocs.entries` as a plain hash lookup: a
# word's name is a string key here, never a method name, so no word name
# ever has to survive dispatch on the playground's OpenStruct.
get '/docs/:word' do
  entry = StudioDocs.entries[params[:word]]
  halt 404, "There is no word called #{params[:word]}." unless entry

  SlimPickins.render(File.read(File.join(settings.views, 'docs.sp')), path: 'docs.sp',
                     locals: { title: "Docs: #{params[:word]}", contract: entry[:contract],
                               implementation: entry[:implementation], **SIDEBAR },
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
    SlimPickins.render(source, path: "playground.sp", locals: StudioPages.playground_locals, library: STUDIO_LIBRARY)
  rescue => e
    "<div style='color: red; padding: 1rem;'><strong>Error:</strong> #{e.message}</div>"
  end
end

post '/render_html' do
  source = params[:source].to_s
  begin
    html = SlimPickins.render(source, path: "playground.sp", locals: StudioPages.playground_locals, library: STUDIO_LIBRARY)
    "<!DOCTYPE html><html><head><style>body { font-family: monospace; white-space: pre-wrap; padding: 1rem; }</style></head><body>#{CGI.escapeHTML(html)}</body></html>"
  rescue => e
    "<!DOCTYPE html><html><head><style>body { font-family: sans-serif; padding: 1rem; color: red; }</style></head><body><strong>Error:</strong> #{CGI.escapeHTML(e.message)}</body></html>"
  end
end

get '/assets/slim-pickins.css' do
  content_type 'text/css'
  File.read(File.expand_path('../assets/slim-pickins.css', __dir__))
end
