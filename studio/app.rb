require 'sinatra'
require 'cgi'
require_relative '../lib/slim_pickins'
require_relative 'docs_helper'

set :port, 4580
set :views, File.join(__dir__, 'views')

STUDIO_LIBRARY = SlimPickins::Library.from(File.expand_path('views', __dir__))

get '/' do
  default_source = "page \"Slim-Pickins Studio\"\n  heading \"Hello World\"\n"
  SlimPickins.render(File.read(File.join(settings.views, 'index.sp')), path: 'index.sp', locals: { source: default_source, docs: StudioDocs.build }, library: STUDIO_LIBRARY)
end

get '/docs/:word' do
  word = params[:word]
  default_source = "page \"Docs: #{word}\"\n  scroll\n    section \"Contract\"\n      prose markdown, docs.#{word}.contract\n    section \"Implementation\"\n      prose markdown, docs.#{word}.implementation\n"
  SlimPickins.render(File.read(File.join(settings.views, 'index.sp')), path: 'index.sp', locals: { source: default_source, docs: StudioDocs.build }, library: STUDIO_LIBRARY)
end

get '/guides/:name' do
  name = params[:name]
  content = File.read(File.expand_path("../#{name}.md", __dir__)) rescue "Guide not found."
  default_source = "page \"Guide: #{name}\"\n  scroll\n    prose markdown, docs.#{name}.implementation\n"
  # Actually, we can just pass the markdown directly!
  default_source = "page \"Guide: #{name}\"\n  scroll\n    prose markdown, .content\n"
  SlimPickins.render(File.read(File.join(settings.views, 'index.sp')), path: 'index.sp', locals: { source: default_source, content: content, docs: StudioDocs.build }, library: STUDIO_LIBRARY)
end

post '/render' do
  source = params[:source].to_s
  begin
    SlimPickins.render(source, path: "playground.sp", locals: { docs: StudioDocs.build }, library: STUDIO_LIBRARY)
  rescue => e
    "<div style='color: red; padding: 1rem;'><strong>Error:</strong> #{e.message}</div>"
  end
end

post '/render_html' do
  source = params[:source].to_s
  begin
    html = SlimPickins.render(source, path: "playground.sp", locals: { docs: StudioDocs.build }, library: STUDIO_LIBRARY)
    "<!DOCTYPE html><html><head><style>body { font-family: monospace; white-space: pre-wrap; padding: 1rem; }</style></head><body>#{CGI.escapeHTML(html)}</body></html>"
  rescue => e
    "<!DOCTYPE html><html><head><style>body { font-family: sans-serif; padding: 1rem; color: red; }</style></head><body><strong>Error:</strong> #{CGI.escapeHTML(e.message)}</body></html>"
  end
end

get '/assets/slim-pickins.css' do
  content_type 'text/css'
  File.read(File.expand_path('../assets/slim-pickins.css', __dir__))
end
