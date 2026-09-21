# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class WayExamAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    WayExam::App
  end

  def default_env
    { 'HTTP_HOST' => 'localhost' }
  end

  def test_index_renders_exam_form_and_questions
    get '/', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'The Way Exam'
    assert_includes last_response.body, 'Examination of the Way'
    assert_includes last_response.body, 'Total Questions'
    assert_includes last_response.body, 'Passing Score'
    assert_includes last_response.body, 'Morphology'
    assert_includes last_response.body, 'Conditionals'
    assert_includes last_response.body, 'Subject Shifting'
    assert_includes last_response.body, 'Design Discipline'
    assert_includes last_response.body, 'The Vocabulary'
    assert_includes last_response.body, 'Submit Exam for Grading'
  end

  def test_grade_perfect_score
    post '/grade', {
      q1: 'a',
      q2: 'b',
      q3: 'c',
      q4: 'b',
      q5: 'c'
    }, default_env

    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Exam Results'
    assert_includes last_response.body, 'Master of the Way'
    assert_includes last_response.body, 'Correct Answers'
    assert_includes last_response.body, '100'
    assert_includes last_response.body, 'Question Review'
    assert_includes last_response.body, 'Correct'
    assert_includes last_response.body, 'Retake Exam'
  end

  def test_grade_failing_score
    post '/grade', {
      q1: 'c',
      q2: 'a'
    }, default_env

    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Exam Results'
    assert_includes last_response.body, 'Needs Re-reading'
    assert_includes last_response.body, 'Incorrect'
  end

  def test_grade_blank_submission
    post '/grade', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, '(No answer)'
    assert_includes last_response.body, 'Needs Re-reading'
  end

  def test_results_redirects_to_index
    get '/results', {}, default_env
    assert_equal 302, last_response.status
    assert_equal 'http://localhost/', last_response.location
  end
end
