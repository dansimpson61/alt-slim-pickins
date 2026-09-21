# frozen_string_literal: true

require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative 'lib/planner'

module MilestonePlanner
  class App < Sinatra::Base
    helpers SlimPickins::Helpers

    set :views, File.join(__dir__, 'views')
    set :public_folder, File.expand_path('../..', __dir__)
    set :static, true
    set :port, ENV.fetch('PORT', 4587).to_i

    SlimPickins::Template.libraries[settings.views] =
      SlimPickins::Library.from(settings.views)

    SlimPickins.prove!(settings.views) do |name|
      planner = Planner.new
      case name
      when 'index'
        { stats: planner.stats, milestones: planner.all }
      when 'milestone'
        m = planner.find('m1')
        { milestone: m, tasks: m.tasks, title: nil, owner: :dan }.merge(m.to_h)
      end
    end

    class << self
      attr_writer :planner

      def planner
        @planner ||= Planner.new
      end
    end

    helpers do
      def planner
        self.class.planner
      end
    end



    get '/' do
      sp :index, locals: {
        stats: planner.stats,
        milestones: planner.all
      }
    end

    get '/milestones/:id' do
      milestone = planner.find(params[:id]) or halt 404
      sp :milestone, locals: {
        milestone: milestone,
        tasks: milestone.tasks,
        title: nil,
        owner: :dan
      }.merge(milestone.to_h)
    end

    post '/milestones/:id/tasks' do
      title = params[:title].to_s.strip
      owner = params[:owner].to_s.strip
      unless title.empty?
        planner.add_task(params[:id], title: title, owner: owner.empty? ? 'dan' : owner)
      end
      redirect "/milestones/#{params[:id]}"
    end

    post '/tasks/:id/toggle' do
      planner.toggle_task(params[:id])
      redirect request.referer || '/'
    end
  end
end

if $PROGRAM_NAME == __FILE__
  MilestonePlanner::App.run!
end
