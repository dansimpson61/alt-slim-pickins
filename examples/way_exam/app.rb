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
          overview: { questions_count: Exam.questions.size, passing_score: '80%' },
          questions: Exam.questions
        }
      when 'results'
        result = Exam.grade(Exam.sample_answers)
        { result: result, reviews: result.reviews }
      end
    end

    get '/' do
      sp :index, locals: {
        overview: { questions_count: Exam.questions.size, passing_score: '80%' },
        questions: Exam.questions
      }
    end

    post '/grade' do
      answers = {}
      Exam.questions.each do |q|
        answers[q.id] = params[q.id] || params[q.id.to_sym]
      end
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
