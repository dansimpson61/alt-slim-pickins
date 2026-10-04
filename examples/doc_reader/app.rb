# frozen_string_literal: true

require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative 'lib/shelf'

module DocReader
  class App < Sinatra::Base
    helpers SlimPickins::Helpers

    set :views, File.join(__dir__, 'views')
    set :public_folder, File.expand_path('../..', __dir__)
    set :static, true
    set :port, ENV.fetch('PORT', 4590).to_i

    SlimPickins::Template.libraries[settings.views] = SlimPickins::Library.from(settings.views)

    # Each page's locals, in one place: the routes and the boot proof both
    # ask here, so what is proved is what is served.
    def self.locals_for(page, shelf: Shelf.of, id: 'primer', q: '', include_history: false)
      case page
      when 'index' then { docs: shelf.without_history, selected_doc: shelf.find(id) }
      when 'shelf', 'audiences' then { shelf: shelf }
      when 'document' then { document: shelf.find(id) }
      when 'search' then { query: Query.new(shelf, q: q, include_history: include_history) }
      end
    end

    SlimPickins.prove!(settings.views) { |page| locals_for(page) }

    get('/') { sp :index, locals: App.locals_for('index', id: params.fetch('doc', 'primer')) }
    get('/shelf') { sp :shelf, locals: App.locals_for('shelf') }
    get('/audiences') { sp :audiences, locals: App.locals_for('audiences') }

    get '/docs/:id' do
      shelf = Shelf.of
      halt 404 unless shelf.find(params[:id])
      sp :document, locals: App.locals_for('document', shelf: shelf, id: params[:id])
    end

    get '/search' do
      sp :search, locals: App.locals_for('search', q: params['q'].to_s,
                                                   include_history: params.key?('include_history'))
    end
  end
end

DocReader::App.run! if $PROGRAM_NAME == __FILE__
