# frozen_string_literal: true

require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative 'lib/exam'

module WayExam
  class App < Sinatra::Base
    helpers SlimPickins::Helpers

    set :views, File.join(__dir__, 'views')
    set :public_folder, File.expand_path('../..', __dir__)
    set :static, true
    set :port, ENV.fetch('PORT', 4586).to_i

    SlimPickins::Template.libraries[settings.views] =
      SlimPickins::Library.from(settings.views)

    SlimPickins.prove!(settings.views) do |name|
      case name
      when 'index'
        {
          overview: { questions_count: 5, passing_score: '80%' },
          q1: nil, q2: nil, q3: nil, q4: nil, q5: nil
        }
      when 'results'
        result = Exam.grade(Exam.sample_answers)
        { result: result, reviews: result.reviews }
      end
    end

    get '/' do
      sp :index, locals: {
        overview: { questions_count: Exam.questions.size, passing_score: '80%' },
        q1: nil, q2: nil, q3: nil, q4: nil, q5: nil
      }
    end

    post '/grade' do
      answers = {
        'q1' => params[:q1],
        'q2' => params[:q2],
        'q3' => params[:q3],
        'q4' => params[:q4],
        'q5' => params[:q5]
      }
      result = Exam.grade(answers)
      sp :results, locals: { result: result, reviews: result.reviews }
    end

    get '/results' do
      redirect '/'
    end
  end
end

if $PROGRAM_NAME == __FILE__
  WayExam::App.run!
end
