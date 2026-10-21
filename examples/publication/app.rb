# frozen_string_literal: true

require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative 'lib/shelf'
require_relative 'lib/lore'

module Publication
  class App < Sinatra::Base
    helpers SlimPickins::Helpers

    set :views, File.join(__dir__, 'views')
    set :public_folder, File.expand_path('../..', __dir__)
    set :static, true
    set :port, ENV.fetch('PORT', 4590).to_i

    SlimPickins::Template.libraries[settings.views] = SlimPickins::Library.from(settings.views)

    # Each page's locals, in one place: the routes and the boot proof both
    # ask here, so what is proved is what is served. A document and an entry
    # are both "readings"; the reader is one surface.
    def self.locals_for(page, shelf: Shelf.of, lore: Lore.load, id: 'primer',
                        q: '', include_history: false, author: '', entry: nil)
      case page
      when 'index' then { docs: shelf.without_history, selected_doc: shelf.find(id) }
      when 'shelf' then { shelf: shelf }
      when 'document' then { document: shelf.find(id) }
      when 'search' then { query: Query.new(shelf, q: q, include_history: include_history) }
      when 'timeline' then { entries: entries_for(lore, q, author), q: q }
      when 'entry' then { entry: entry || lore.all.find { |e| e.words.any? } || lore.all.first }
      end
    end

    def self.entries_for(lore, q, author)
      if !q.to_s.empty? then lore.search(q)
      elsif !author.to_s.empty? then lore.by_author(author)
      else lore.all
      end
    end

    SlimPickins.prove!(settings.views) { |page| locals_for(page) }

    get('/') { sp :index, locals: App.locals_for('index', id: params.fetch('doc', 'primer')) }
    get('/shelf') { sp :shelf, locals: App.locals_for('shelf') }

    get '/docs/:id' do
      shelf = Shelf.of
      halt 404 unless shelf.find(params[:id])
      sp :document, locals: App.locals_for('document', shelf: shelf, id: params[:id])
    end

    get('/timeline') do
      sp :timeline, locals: App.locals_for('timeline', q: params['q'].to_s,
                                                        author: params['author'].to_s)
    end

    get '/entries/:id' do
      entry = Lore.load.find(params[:id]) or halt 404
      sp :entry, locals: App.locals_for('entry', entry: entry)
    end

    get '/search' do
      sp :search, locals: App.locals_for('search', q: params['q'].to_s,
                                                   include_history: params.key?('include_history'))
    end

    # The base theme, the compiled `.layout`, and the compiled `.style` the
    # frame's `<head>` links. Both companions are compiled per request, the
    # same way the studio serves its `workbench.css` — they are not files on
    # disk.
    get '/assets/:file' do
      content_type 'text/css'
      if params[:file] == 'slim-pickins.css'
        File.read(File.expand_path('../../lib/slim_pickins/assets/slim-pickins.css', __dir__))
      elsif params[:file] == 'publication.css'
        SlimPickins::Layout.compiled_stylesheet(
          File.read(File.expand_path('publication.layout', __dir__)),
          provenance: 'automatically from examples/publication/publication.layout')
      elsif params[:file] == 'index.css'
        SlimPickins::Layout.compiled_stylesheet(
          File.read(File.expand_path('views/index.layout', __dir__)),
          provenance: 'automatically from examples/publication/views/index.layout')
      elsif params[:file] == 'publication.style.css'
        SlimPickins::Style.compiled_stylesheet(
          File.read(File.expand_path('publication.style', __dir__)),
          provenance: 'automatically from examples/publication/publication.style')
      else
        halt 404, "There is no asset called #{params[:file]}."
      end
    end
  end
end

Publication::App.run! if $PROGRAM_NAME == __FILE__
