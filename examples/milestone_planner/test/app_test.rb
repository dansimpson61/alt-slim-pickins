# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

class MilestonePlannerAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    MilestonePlanner::App
  end

  def setup
    MilestonePlanner::App.planner = MilestonePlanner::Planner.new
  end

  def default_env
    { 'HTTP_HOST' => 'localhost' }
  end


  def test_index_renders_overview_and_milestones
    get '/', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Milestone Planner'
    assert_includes last_response.body, 'Roadmap &amp; Project Horizon'
    assert_includes last_response.body, 'Overview Metrics'
    assert_includes last_response.body, 'Total Tasks'
    assert_includes last_response.body, 'Phase 0: Scope the Studio Workbench'
    assert_includes last_response.body, 'Phase 1: The Garden, planted'
  end


  def test_milestone_detail_renders_tasks
    get '/milestones/m1', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Milestone Detail'
    assert_includes last_response.body, 'Back to Planner'
    assert_includes last_response.body, 'Add Task'
    assert_includes last_response.body, 'Build palette census'
  end

  def test_empty_milestone_renders_empty_state
    get '/milestones/m5', {}, default_env
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'No tasks defined for this milestone yet.'
  end

  def test_add_task_posts_and_redirects
    post '/milestones/m5/tasks', { title: 'New bluesky item', owner: 'dan' }, default_env
    assert_equal 302, last_response.status
    assert_equal 'http://localhost/milestones/m5', last_response.location
    follow_redirect!
    assert_includes last_response.body, 'New bluesky item'
  end

  def test_toggle_task_posts_and_redirects
    post '/tasks/t7/toggle', {}, default_env.merge('HTTP_REFERER' => 'http://localhost/milestones/m2')
    assert_equal 302, last_response.status
    assert_equal 'http://localhost/milestones/m2', last_response.location
    follow_redirect!
    assert_includes last_response.body, 'Milestone Detail'
  end

  def test_missing_milestone_returns_404
    get '/milestones/m999', {}, default_env
    assert_equal 404, last_response.status
  end
end
