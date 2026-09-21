# frozen_string_literal: true

require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative 'lib/graph'

module WordGraph
  class App < Sinatra::Base
    helpers SlimPickins::Helpers

    set :views, File.join(__dir__, 'views')
    set :public_folder, File.expand_path('../..', __dir__)
    set :static, true
    set :port, ENV.fetch('PORT', 4588).to_i

    SlimPickins::Template.libraries[settings.views] =
      SlimPickins::Library.from(settings.views)

    SlimPickins.prove!(settings.views) do |name|
      graph = Graph.instance
      case name
      when 'index'
        { words: graph.all, q: '' }.merge(graph.stats)
      when 'word'
        w = graph.find('table')
        peers = graph.by_shape(w.shape).reject { |item| item.name == w.name }
        parents = w.explicit_parents.map { |p| graph.find(p) }.compact
        children = w.explicit_children.map { |c| graph.find(c) }.compact
        { word: w, parents: parents, children: children, peers: peers }.merge(w.to_h)
      when 'shapes'
        { shapes: graph.shapes }
      when 'matrix'
        { words: graph.all }
      end
    end

    class << self
      attr_writer :graph

      def graph
        @graph ||= Graph.instance
      end
    end

    helpers do
      def graph
        self.class.graph
      end
    end

    get '/' do
      words = if params[:shape] && !params[:shape].empty?
                graph.by_shape(params[:shape])
              elsif params[:speech] && !params[:speech].empty?
                graph.by_speech(params[:speech])
              elsif params[:q] && !params[:q].empty?
                graph.search(params[:q])
              else
                graph.all
              end

      sp :index, locals: {
        words: words,
        q: params[:q] || ''
      }.merge(graph.stats)
    end

    get '/words/:name' do
      word = graph.find(params[:name]) or halt 404
      peers = graph.by_shape(word.shape).reject { |w| w.name == word.name }
      parents = word.explicit_parents.map { |p| graph.find(p) }.compact
      children = word.explicit_children.map { |c| graph.find(c) }.compact

      sp :word, locals: {
        word: word,
        parents: parents,
        children: children,
        peers: peers
      }.merge(word.to_h)
    end

    get '/shapes' do
      sp :shapes, locals: {
        shapes: graph.shapes
      }
    end

    get '/matrix' do
      sp :matrix, locals: {
        words: graph.all
      }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  WordGraph::App.run!
end
