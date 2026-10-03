# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins/census'

class CensusTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_words_census_matches_canonical_source_of_truth
    words = SlimPickins::Census.words

    assert_equal 39, words[:primitives].size
    assert_equal 23, words[:partials].size
    assert_equal 62, words[:total].size
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

  # The census counts pages by reading the gate's source, because requiring the
  # gate would close a circle through the studio's vitals. A scrape can disagree
  # with the thing it imitates, and it did: it knew `pages/` and `examples/` and
  # undercounted by two the day the Inspect surface arrived under `studio/`. So
  # the count is held to what the gate itself reports, in the gate's own process.
  def test_verified_pages_count_matches_what_the_gate_reports
    reported = IO.popen(['ruby', File.join(ROOT, 'bin', 'verify_pages.rb')],
                        err: %i[child out], &:read)[/(\d+) pages verified/, 1]

    assert_equal reported.to_i, SlimPickins::Census.verified_pages_count,
                 'the census and the gate must agree on how many pages are proved'
  end

  def test_conventions_and_promises_match_registers
    assert_equal 38, SlimPickins::Census.conventions_count
    assert_equal 35, SlimPickins::Census.promises_count
  end

  def test_styles_census_matches_stylesheet_rules
    # A pinned number is a canary: it fails when the stylesheet gains or
    # loses a class, which is how `.split_pane` folding into `.panes` was
    # noticed rather than absorbed silently.
    assert_equal 113, SlimPickins::Census.styles[:rules_defined]
  end

  def test_report_formats_all_metrics
    report = SlimPickins::Census.report

    assert_match(/62 canonical/, report)
    # The report test is about the formatting, not the count — the count has its
    # own test, and pinning it twice is how one copy goes stale.
    assert_match(/#{SlimPickins::Census.verified_pages_count} checked by verify_pages/, report)
    assert_match(/38 registered in SlimPickins::Conventions::ALL/, report)
  end
end
