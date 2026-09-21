# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/exam'

class ExamTest < Minitest::Test
  def test_questions_are_populated
    questions = WayExam::Exam.questions
    assert_equal 5, questions.size
    assert questions.all? { |q| q.options.size >= 3 }
  end

  def test_grading_perfect_score_with_keys
    result = WayExam::Exam.grade(WayExam::Exam.sample_answers)
    assert_equal 5, result.score
    assert_equal 5, result.total
    assert_equal 100, result.percentage
    assert result.passed
    assert_equal 'Master of the Way', result.verdict
    assert result.reviews.all?(&:correct)
  end

  def test_grading_perfect_score_with_full_text
    answers = {
      'q1' => 'A dot means data, a bare word is language.',
      'q2' => 'Conditionals dissolve into vocabulary (like empty) describing the situation.',
      'q3' => 'Child sentences resolve dotted attributes (e.g. .balance) directly on that account.',
      'q4' => 'In theme roles and word variants, refusing raw inline styles.',
      'q5' => '64 words'
    }
    result = WayExam::Exam.grade(answers)
    assert_equal 5, result.score
    assert_equal 100, result.percentage
    assert result.passed
  end

  def test_grading_failing_score
    result = WayExam::Exam.grade({ 'q1' => 'Wrong' })
    assert_equal 0, result.score
    assert_equal 0, result.percentage
    refute result.passed
    assert_equal 'Needs Re-reading', result.verdict
  end
end
