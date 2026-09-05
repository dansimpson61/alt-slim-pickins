require 'sinatra'
require 'cgi'
require_relative '../lib/slim_pickins'

set :port, 4580
set :views, File.join(__dir__, 'views')

STUDIO_LIBRARY = SlimPickins::Library.from(File.expand_path('views', __dir__))

get '/' do
  default_source = "page \"Slim-Pickins Studio\"\n  heading \"Hello World\"\n"
  SlimPickins.render(File.read(File.join(settings.views, 'index.sp')), path: 'index.sp', locals: { source: default_source }, library: STUDIO_LIBRARY)
end

get '/docs/:word' do
  word = params[:word]
  default_source = "page \"Docs: #{word}\"\n  heading \"Docs for #{word} will go here\"\n"
  SlimPickins.render(File.read(File.join(settings.views, 'index.sp')), path: 'index.sp', locals: { source: default_source }, library: STUDIO_LIBRARY)
end

post '/render' do
  source = params[:source].to_s
  begin
    SlimPickins.render(source, path: "playground.sp", library: STUDIO_LIBRARY)
  rescue => e
    "<div style='color: red; padding: 1rem;'><strong>Error:</strong> #{e.message}</div>"
  end
end

post '/render_html' do
  source = params[:source].to_s
  begin
    html = SlimPickins.render(source, path: "playground.sp", library: STUDIO_LIBRARY)
    "<!DOCTYPE html><html><head><style>body { font-family: monospace; white-space: pre-wrap; padding: 1rem; }</style></head><body>#{CGI.escapeHTML(html)}</body></html>"
  rescue => e
    "<!DOCTYPE html><html><head><style>body { font-family: sans-serif; padding: 1rem; color: red; }</style></head><body><strong>Error:</strong> #{CGI.escapeHTML(e.message)}</body></html>"
  end
end

get '/assets/slim-pickins.css' do
  content_type 'text/css'
  File.read(File.expand_path('../assets/slim-pickins.css', __dir__))
end
