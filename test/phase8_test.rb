# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/template'
require_relative '../examples/roth/app'

# Phase 8: `chart` redrafted against roth's two real charts.
#
# The first draft was the one entry written without evidence. It took parallel
# flat arrays, drew one polyline, and its VOCABULARY entry claimed to infer
# "axes, scale and legend" while emitting none of the three.
class Phase8Test < Minitest::Test
  include Rack::Test::Methods

  Roth::App.set :host_authorization, { permitted_hosts: [] }

  Point = Struct.new(:year, :rent, :food, :spend, keyword_init: true) do
    LABELS = { rent: 'Rent', food: 'Food', spend: 'Total spend' }.freeze
    FORMATS = { rent: :money, food: :money, spend: :money }.freeze
    def label_for(attribute) = LABELS[attribute]
    def format_for(attribute) = FORMATS[attribute]
  end

  def app = Roth::App

  def points
    [[2024, 1200, 400], [2025, 1300, 450], [2026, 1400, 500]].map do |year, rent, food|
      Point.new(year: year, rent: rent, food: food, spend: rent + food)
    end
  end

  def draw(source, **locals)
    SlimPickins.render(source, locals: { points: points, ceiling: 2000 }.merge(locals))
  end

  # --- the shape of the word ---------------------------------------------

  # A table declares its columns and the rows come from the subject; a chart
  # declares its series and the points come from the subject. Same rule.
  def test_a_chart_declares_its_series_like_a_table_declares_its_columns
    svg = draw("chart points\n  band rent\n  band food\n")
    assert_equal 1, svg.scan('<svg class="chart"').size
    assert_equal 2, svg.scan('class="chart-band').size / 2   # one path, one key swatch
  end

  def test_bands_stack_and_lines_lie_over_them
    svg = draw("chart points\n  band rent\n  band food\n  line spend\n")
    assert_includes svg, 'chart-band--0'
    assert_includes svg, 'chart-band--1'
    assert_includes svg, 'chart-line--0'
  end

  def test_a_band_outside_a_chart_says_so
    error = assert_raises(SlimPickins::Error) { draw('band rent') }
    assert_equal 'band belongs inside a chart', error.message
  end

  def test_a_level_outside_a_chart_says_so
    error = assert_raises(SlimPickins::Error) { draw('level .ceiling, "Cap"') }
    assert_equal 'level belongs inside a chart', error.message
  end

  # --- what it infers ------------------------------------------------------

  # `chart points` reads each row's `point`… which does not exist here, so it
  # counts. `chart years` reads `year`, which is the case that matters.
  def test_the_x_axis_comes_from_the_singular_of_the_collection
    assert_equal :year, SlimPickins::Inference.singular(:years)
    assert_equal :balance, SlimPickins::Inference.singular(:balances)
    assert_equal :entry, SlimPickins::Inference.singular(:entries)
    assert_nil SlimPickins::Inference.singular(:history)
  end

  def test_over_names_the_axis_when_the_name_does_not
    svg = draw("chart points, over: year\n  band rent\n")
    %w[2024 2025 2026].each { |year| assert_includes svg, ">#{year}</text>" }
  end

  def test_an_axis_it_cannot_name_counts_rather_than_inventing
    svg = draw("chart points\n  band rent\n")
    assert_includes svg, '>1</text>'
    assert_includes svg, '>3</text>'
  end

  # The three levels of the contract, on a chart: the page said it, or the row
  # said it, or English.
  def test_series_labels_come_from_the_row
    svg = draw("chart points\n  band rent\n  band food\n")
    assert_includes svg, '>Rent</text>'
    assert_includes svg, '>Food</text>'
  end

  def test_the_page_may_override_a_series_label
    svg = draw(%(chart points\n  band rent, "Housing"\n))
    assert_includes svg, '>Housing</text>'
    refute_includes svg, '>Rent</text>'
  end

  # A tooltip says $1,200 because `format_for` said money, not because a chart
  # guessed at it.
  def test_values_are_written_the_way_the_rest_of_the_page_writes_them
    svg = draw("chart points, over: year\n  band rent\n")
    assert_includes svg, 'Rent: $1,200'
  end

  def test_the_axis_reads_in_thousands
    assert_equal '0', SlimPickins::Charting.short(0)
    assert_equal '500', SlimPickins::Charting.short(500)
    assert_equal '2k', SlimPickins::Charting.short(2000)
    assert_equal '1.5m', SlimPickins::Charting.short(1_500_000)
  end

  # --- what it draws unasked ----------------------------------------------

  def test_axes_ticks_and_a_key_arrive_without_being_asked_for
    svg = draw("chart points, over: year\n  band rent\n")
    assert_includes svg, 'class="chart-axis"'
    assert_includes svg, 'class="chart-tick"'
    assert_includes svg, 'class="chart-hit"'
  end

  # The whole tooltip, and no script anywhere. roth spent forty lines of
  # JavaScript and a mount point on this.
  def test_the_hover_detail_is_a_native_title
    svg = draw("chart points, over: year\n  band rent\n  band food\n")
    assert_includes svg, '<title>2025 — Rent: $1,300 | Food: $450</title>'
  end

  def test_hover_columns_stay_inside_the_plot
    svg = draw("chart points, over: year\n  band rent\n")
    lefts = svg.scan(/class="chart-hit" x="([-\d.]+)"/).flatten.map(&:to_f)
    assert lefts.all? { |x| x >= 64 }, "a hover column started at #{lefts.min}"
  end

  # --- the scale ------------------------------------------------------------

  # roth's top tax bracket sits at $760k against $200k of income. Letting a
  # reference into the scale stretched the axis fourfold and pressed every
  # band flat along the bottom.
  def test_a_level_does_not_stretch_the_scale
    without = draw("chart points, over: year\n  band rent\n")
    with = draw(%(chart points, over: year\n  band rent\n  level .ceiling, "Cap"\n),
                ceiling: 900_000)
    ticks = ->(svg) { svg.scan(/class="chart-tick" x="8.0"[^>]*>([^<]+)/).flatten }
    assert_equal ticks[without], ticks[with]
  end

  def test_a_level_outside_the_scale_is_not_drawn
    svg = draw(%(chart points, over: year\n  band rent\n  level .ceiling, "Cap"\n),
               ceiling: 900_000)
    refute_includes svg, 'chart-level'
  end

  def test_a_level_inside_the_scale_is_drawn_and_labelled_in_place
    svg = draw(%(chart points, over: year\n  band rent\n  level .ceiling, "Cap"\n),
               ceiling: 1000)
    assert_includes svg, 'class="chart-level"'
    assert_includes svg, '>Cap</text>'
  end

  def test_a_chart_of_nothing_renders_nothing
    assert_equal '', SlimPickins::Charting.render(series: [], across: [])
  end

  # Only visible under stress: a high income brings seven brackets into view
  # and "12%" landed four pixels from "Standard deduction". The rule still
  # draws; two labels on top of each other say less than one.
  def test_crowded_level_labels_thin_out_but_keep_their_rules
    post '/projection', { 'base_income' => '450000', 'trad_balance' => '4000000' }
    svg = last_response.body[/<svg class="chart".*?<\/svg>/m]

    assert_equal 7, svg.scan('class="chart-level"').size
    labels = svg.scan(/class="chart-note"[^>]*>([^<]+)/).flatten
    assert_equal 6, labels.size

    # Declaration order decides who survives, so the page keeps the say —
    # roth writes its deduction before its brackets.
    assert_includes labels, 'Standard deduction'
    refute_includes labels, '12%'
  end

  # --- roth, which is the evidence -----------------------------------------

  # 130 lines of Ruby became eleven sentences, and roth's last app word went
  # with them.
  def test_roths_two_charts_are_now_sentences
    report = File.read(File.expand_path('../examples/roth/views/partials/report.sp', __dir__))
    assert_includes report, 'chart years'
    assert_includes report, 'band base_income'
    assert_includes report, 'line federal_tax'
    assert_includes report, 'level .standard_deduction, "Standard deduction"'
    refute_includes report, 'drawing'
    refute File.exist?(File.expand_path('../examples/roth/lib/chart.rb', __dir__))
  end

  # `each` composes with registration: the brackets are a collection, and each
  # one registers a level, without `chart` knowing anything about loops.
  def test_each_composes_with_the_words_that_register
    get '/'
    drawn = last_response.body.scan(/class="chart-note"[^>]*>([^<]+)/).flatten
    assert_includes drawn, 'Standard deduction'
    assert_includes drawn, '12%'
    assert_includes drawn, '22%'
  end

  # `from:` is the same modifier `each` takes, and means the same thing.
  def test_from_lays_a_second_collection_over_the_first
    get '/'
    refute_includes last_response.body, 'chart-line--1', 'nothing to compare against yet'

    post '/projection', { 'conversion_value' => '50000' }
    assert_includes last_response.body, 'chart-line--1'
    assert_includes last_response.body, 'Do nothing'
  end

  def test_the_key_names_every_series_roth_draws
    post '/projection', { 'conversion_value' => '50000' }
    income = last_response.body.scan(/<svg class="chart".*?<\/svg>/m).first
    key = income.scan(/class="chart-tick" x="[\d.]+" y="17.0">([^<]+)/).flatten
    assert_equal ['Base income', 'Social Security', 'Distribution', 'Converted',
                  'Federal tax', 'Do nothing'], key
  end
end
