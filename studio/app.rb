require 'sinatra'
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
  # Render the raw .sp source without layout
  begin
    # Create a temporary file path string to pass to render
    SlimPickins.render(source, path: "playground.sp", library: STUDIO_LIBRARY)
  rescue => e
    "<div style='color: red; padding: 1rem;'><strong>Error:</strong> #{e.message}</div>"
  end
end

get '/assets/slim-pickins.css' do
  content_type 'text/css'
  File.read(File.expand_path('../assets/slim-pickins.css', __dir__))
end

