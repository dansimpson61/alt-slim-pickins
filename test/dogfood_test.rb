# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative 'fixtures'
require_relative '../examples/roth/lib/scenario'
require_relative '../examples/roth/lib/projection'

# The dogfood, eaten. Every hard-wired gatherer — table, chart, choose,
# choice — is re-implemented here as an app word module, using ONLY the
# public surface: Component, register!, with_gatherer, subject, chain,
# label_for, label_of, format_of, alignment_of, children, evaluate,
# emit_node, element, tag, token, arguments, and the Generator's format.
#
# The repo's real pages render through this module and must come out
# byte-identical to the built-ins. If they ever differ, the surface is
# incomplete and the vocabulary has food it would not serve.
#
# One honest limit, named: the built-in `when` gets its condition deferred by
# the transform (a lambda), so its guard fires before the argument runs. That
# deferral is grammar-level — Ruby evaluates arguments before any method —
# and no surface can give it to an app word. `when_app` therefore evaluates its
# condition eagerly; valid usage renders identically, and only the error for
# an invalid `when_app` differs. Everything else here is byte-complete.
module Dogfood
  class TableApp < SlimPickins::Component
    INSIDE = 'a table'

    def initialize(builder, name, caption, block)
      super(builder, &block)
      @name = name
      @caption = caption
      @rows = name ? subject.fetch(name) : subject.object
    end

    def render
      with_open
      columns = @collected
      sample = @rows.first
      columns.each do |c|
        c[:sample] = sample && SlimPickins::Subject.new(sample).fetch(c[:name])
        c[:header] = label_of(c, sample)
        c[:alignment] = alignment_of(c, sample)
      end

      rows = @rows.map do |row|
        chain.with(row) do
          cells = columns.reject { |c| c[:total] }.map do |c|
            { name: c[:name], value: subject.fetch(c[:name]), kind: format_of(c),
              alignment: c[:alignment] }
          end
          [:row, {}, cells]
        end
      end

      emit_node([:table, { name: @name, caption: @caption, columns: columns,
                           rows: rows, foot: foot(columns, @rows) }, []])
    end

    private

    def foot(columns, rows)
      totals = columns.select { |c| c[:total] }
      return [] if totals.empty?

      shown = columns.reject { |c| c[:total] }
      shown.each_with_index.map do |c, i|
        t = totals.find { |x| x[:name] == c[:name] }
        if t
          sum = rows.sum { |row| SlimPickins::Subject.new(row).fetch(c[:name]) }
          { value: sum, kind: format_of(c, rows.first), alignment: c[:alignment] }
        elsif i.zero?
          { label: totals.first[:header] || 'Total' }
        else
          {}
        end
      end
    end
  end

  class ChartApp < SlimPickins::Component
    INSIDE = 'a chart'

    def initialize(builder, name, caption, over, block)
      super(builder, &block)
      @name = name
      @caption = caption
      @over = over
      @rows = (name ? subject.fetch(name) : subject.object).to_a
    end

    def render
      with_open
      series = @collected.select { |i| i[:kind] }
      levels = @collected.select { |i| i[:value] }
      drawn = series.map { |s| resolve(s, @rows) }.reject { |s| s[:points].empty? }

      emit_node([:chart, { series: drawn, levels: levels,
                           across: across(@rows, @over || SlimPickins::Inference.singular(@name)),
                           caption: @caption }, []])
    end

    private

    def resolve(series, rows)
      source = series[:from] ? series[:from].to_a : rows
      sample = source.first
      kind = SlimPickins::Subject.new(sample).format_for(series[:name])
      values = source.map { |row| SlimPickins::Subject.new(row).fetch(series[:name]) }

      { kind: series[:kind],
        label: label_of({ name: series[:name], header: series[:label] }, sample),
        points: values.map(&:to_f),
        shown: values.map { |v| SlimPickins::Generator.format(kind, v) } }
    end

    def across(rows, attribute)
      return (1..rows.size).map(&:to_s) unless attribute && rows.first
      return (1..rows.size).map(&:to_s) unless SlimPickins::Subject.new(rows.first).has?(attribute)

      rows.map { |row| SlimPickins::Subject.new(row).fetch(attribute).to_s }
    end
  end

  class ChooseApp < SlimPickins::Component
    INSIDE = 'a choose'

    def render
      with_open
      chosen = @collected.find { |c, _| c } || @collected.find { |c, _| c.nil? }
      emit_node([:choose, {}, chosen ? children(&chosen.last) : []])
    end

    def add_branch(condition, block) = @collected << [condition, block]
  end

  class ChoiceApp < SlimPickins::Component
    INSIDE = 'a choice'

    def initialize(builder, name, label, block)
      super(builder, &block)
      @name = name
      @label = label
      @selected = subject.fetch(name)
    end

    def render
      with_open
      options = @collected.map do |o|
        [:option, { value: o[:value], label: o[:label], selected: @selected }, []]
      end
      emit_node([:choice, { name: @name, label: label_for(@name, @label),
                            selected: @selected }, options])
    end
  end

  def table_app(*args, &block)
    name, caption = arguments(args)
    TableApp.new(self, name, caption, block).render
  end

  def column_app(*args, as: nil)
    name, header = arguments(args)
    register!(TableApp, { name: name, header: header, as: as }, 'column')
  end

  def total_app(*args)
    name, label = arguments(args)
    register!(TableApp, { name: name, header: label, as: nil, total: true }, 'total')
  end

  def chart_app(*args, over: nil, &block)
    name, caption = arguments(args)
    ChartApp.new(self, name, caption, over, block).render
  end

  def band_app(*args)
    name, label = arguments(args)
    register!(ChartApp, { kind: :band, name: name, label: label }, 'band')
  end

  def line_app(*args, from: nil)
    name, label = arguments(args)
    register!(ChartApp, { kind: :line, name: name, label: label, from: from }, 'line')
  end

  def level_app(*args)
    register!(ChartApp,
              { value: args.find { |a| a.is_a?(Numeric) }.to_f,
                label: args.find { |a| a.is_a?(String) } },
              'level_app')
  end

  def choose_app(&block) = ChooseApp.new(self, &block).render

  def when_app(*args, &block)
    target = open_gatherer(ChooseApp)
    raise SlimPickins::Error, 'when belongs inside a choose' unless target

    # The built-in `when` receives a lambda from the transform; an app word
    # receives the already-evaluated value. Valid usage renders identically.
    target.add_branch(!!args.first, block)
  end

  def otherwise_app(&block)
    target = open_gatherer(ChooseApp)
    raise SlimPickins::Error, 'otherwise belongs inside a choose' unless target

    target.add_branch(nil, block)
  end

  def choice_app(*args, &block)
    name, label = arguments(args)
    ChoiceApp.new(self, name, label, block).render
  end

  def option_app(*args)
    value, label = arguments(args)
    register!(ChoiceApp, { value: value, label: label }, 'option')
  end
end

class DogfoodTest < Minitest::Test
  RENAMES = %w[table column total chart band line level choose when otherwise choice option].freeze

  # The built-in word names become the app's, everywhere they lead a line.
  def dogfood_source(source)
    source.lines.map do |line|
      line.sub(/\A(\s*)(#{RENAMES.join('|')})\b/) { "#{Regexp.last_match(1)}#{Regexp.last_match(2)}_app" }
    end.join
  end

  def assert_same_plate(source, locals: {}, library: nil)
    built_in = SlimPickins.render(source, locals: locals, library: library)
    eaten = SlimPickins.render(dogfood_source(source), locals: locals,
                               library: SlimPickins::Library.new(words: Dogfood,
                                                                 layout: library&.layout,
                                                                 partials: library ? library.partials : {}))
    assert_equal built_in, eaten, 'the app-word gatherers must render byte-identically'
  end

  def test_the_repo_pages_render_identically_through_the_app_word_gatherers
    pages = SlimPickins::Library.from(File.expand_path('../pages', __dir__))
    assert_same_plate(File.read(File.expand_path('../pages/portfolio.sp', __dir__)),
                      locals: { portfolio: Fixtures.portfolio }, library: pages)
    assert_same_plate(File.read(File.expand_path('../pages/specimen.sp', __dir__)),
                      locals: Fixtures.for('specimen'), library: pages)
  end

  def test_roths_report_and_form_render_identically_through_the_app_word_gatherers
    roth = SlimPickins::Library.from(File.expand_path('../examples/roth/views', __dir__))
    scenario = Roth::Scenario.defaults
    projection = Roth::Projection.of(scenario)
    assert_same_plate(File.read(File.expand_path('../examples/roth/views/controls.sp', __dir__)),
                      locals: { scenario: scenario, projection: projection }, library: roth)
    assert_same_plate(File.read(File.expand_path('../examples/roth/views/partials/report.sp', __dir__)),
                      locals: { scenario: scenario, projection: projection }, library: roth)
  end

  def test_the_app_word_gatherers_guard_like_the_built_ins
    error = assert_raises(SlimPickins::Error) do
      SlimPickins.render("page p\n  option_app fixed, \"Fixed\"\n", locals: { p: {} },
                         library: SlimPickins::Library.new(words: Dogfood))
    end
    assert_equal 'option belongs inside a choice', error.message
  end
end
