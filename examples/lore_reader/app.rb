# frozen_string_literal: true

require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative 'lib/lore'

module LoreReader
  class App < Sinatra::Base
    helpers SlimPickins::Helpers

    set :views, File.join(__dir__, 'views')
    set :public_folder, File.expand_path('../..', __dir__)
    set :static, true
    set :port, ENV.fetch('PORT', 4585).to_i

    SlimPickins::Template.libraries[settings.views] =
      SlimPickins::Library.from(settings.views)

    SlimPickins.prove!(settings.views) do |name|
      lore = Lore.load
      case name
      when 'index'
        { lore: lore, entries: lore.all.first(5), stats: lore.stats, q: '', current_author: '' }
      when 'entry'
        { entry: lore.all.first }
      end
    end

    helpers do
      def lore
        @lore ||= Lore.load
      end
    end

    get '/' do
      q = params[:q].to_s.strip
      author = params[:author].to_s.strip
      entries = if !q.empty?
                  lore.search(q)
                elsif !author.empty?
                  lore.by_author(author)
                else
                  lore.all
                end
      sp :index, locals: {
        lore: lore,
        entries: entries,
        stats: lore.stats,
        q: q,
        current_author: author
      }
    end

    get '/entries/:id' do
      entry = lore.find(params[:id]) or halt 404
      sp :entry, locals: { entry: entry }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  LoreReader::App.run!
end
