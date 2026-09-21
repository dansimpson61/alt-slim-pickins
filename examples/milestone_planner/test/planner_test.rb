# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/planner'

class PlannerTest < Minitest::Test
  def setup
    @planner = MilestonePlanner::Planner.new
  end

  def test_seed_data_is_populated
    assert_equal 5, @planner.total_milestones
    assert_equal 11, @planner.total_tasks
    assert @planner.completed_milestones >= 1
    assert @planner.overall_progress > 0
  end

  def test_milestone_status_calculation
    m1 = @planner.find('m1')
    assert m1.completed?
    assert_equal 'ok', m1.status
    assert_equal 'Complete', m1.status_label
    assert_equal 100, m1.progress

    m3 = @planner.find('m3')
    refute m3.completed?
    assert m3.blocked?
    assert_equal 'blocker', m3.status
    assert_equal 'Blocked', m3.status_label
  end

  def test_empty_milestone
    m5 = @planner.find('m5')
    assert m5.empty?
    assert_equal 0, m5.total_tasks
    assert_equal 0, m5.progress
  end

  def test_add_task
    task = @planner.add_task('m5', title: 'Write bluesky doc', owner: 'dan')
    refute_nil task
    assert_equal 't12', task.id
    refute @planner.find('m5').empty?
    assert_equal 1, @planner.find('m5').total_tasks
  end

  def test_toggle_task
    m2 = @planner.find('m2')
    task = m2.tasks.find { |t| t.id == 't7' }
    refute task.done?

    @planner.toggle_task('t7')
    assert task.done?
    assert_equal 'ok', task.status

    @planner.toggle_task('t7')
    refute task.done?
    assert_equal 'pending', task.status
  end

  def test_stats_hash
    stats = @planner.stats
    assert_equal 5, stats[:total_milestones]
    assert_equal 11, stats[:total_tasks]
    assert stats[:overall_progress] >= 50
  end
end
