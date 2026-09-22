# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins/census'

class CensusTest < Minitest::Test
  def test_words_census_matches_canonical_source_of_truth
    words = SlimPickins::Census.words

    assert_equal 42, words[:primitives].size
    assert_equal 22, words[:partials].size
    assert_equal 64, words[:total].size
  end

  def test_apps_census_identifies_all_demonstration_apps
    apps = SlimPickins::Census.apps

    assert_includes apps, :portfolio
    assert_includes apps, :roth
    assert_includes apps, :lore_reader
    assert_includes apps, :way_exam
    assert_includes apps, :milestone_planner
    assert_includes apps, :word_graph
    assert_includes apps, :dashboard
  end

  def test_verified_pages_count_matches_corpus
    assert_equal 31, SlimPickins::Census.verified_pages_count
  end

  def test_conventions_and_promises_match_registers
    assert_equal 38, SlimPickins::Census.conventions_count
    assert_equal 33, SlimPickins::Census.promises_count
  end

  def test_styles_census_matches_stylesheet_rules
    assert_equal 105, SlimPickins::Census.styles[:rules_defined]
  end

  def test_report_formats_all_metrics
    report = SlimPickins::Census.report

    assert_match(/64 canonical/, report)
    assert_match(/31 checked by verify_pages/, report)
    assert_match(/38 registered in SlimPickins::Conventions::ALL/, report)
  end
end
