# frozen_string_literal: true

module SlimPickins
  # The four gatherers — table, chart, choose, choice — as objects. The lore
  # counted one gathering mechanism four times; this file is the one it
  # becomes.
  #
  # A gatherer's children are declarations: they register while the gatherer's
  # block runs, then the gatherer renders from what it collected. Children
  # still evaluate against the Builder — the vocabulary is the Builder's — so
  # a component's job is exactly two things: own its collection, and render
  # it. The Builder keeps a stack of the gatherers currently open, which is
  # the save-and-restore that used to be written by hand in each one (and, in
  # choice's case, forgotten).
  #
  # Components are part of the runtime, so they reach Builder's internals
  # through this one file. The app hatch stays five methods.
  class Component
    def initialize(builder, &block)
      @builder = builder
      @block = block
      @collected = []
    end

    # What a registering word hands over, and where the gatherer keeps it.
    def collect(item) = @collected << item

    # The Builder routes the registering words through the stack of open
    # gatherers — the guard and the save-and-restore, written once.
    def with_open
      @builder.send(:with_gatherer, self) { @builder.send(:nest, &@block) }
    end

    private

    def subject = @builder.send(:subject)
    def chain = @builder.send(:chain)
    def open(...) = @builder.send(:open, ...)
    def close(...) = @builder.send(:close, ...)
    def void(...) = @builder.send(:void, ...)
    def text_tag(...) = @builder.send(:text_tag, ...)
    def emit(...) = @builder.send(:emit, ...)
    def token(...) = @builder.send(:token, ...)
    def label_for(...) = @builder.send(:label_for, ...)
    def label_of(...) = @builder.send(:label_of, ...)
    def format_of(...) = @builder.send(:format_of, ...)
    def present(...) = @builder.send(:present, ...)
    def alignment_of(...) = @builder.send(:alignment_of, ...)
  end

  # A table declares its columns; the rows come from the subject. `column`
  # registers rather than renders, so the header can be written before the
  # first row exists.
  class Table < Component
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
        c[:sample] = sample && Subject.new(sample).fetch(c[:name])
        c[:header] = label_of(c, sample)
      end

      open(:table, class: token(:table, @name))
      text_tag(:caption, @caption) if @caption
      open(:thead)
      open(:tr)
      columns.each do |c|
        next if c[:total]

        text_tag(:th, c[:header], class: alignment_of(c, sample))
      end
      close(:tr)
      close(:thead)
      open(:tbody)
      @rows.each do |row|
        chain.with(row) do
          open(:tr)
          columns.each do |c|
            next if c[:total]

            text_tag(:td, present(subject.fetch(c[:name]), format_of(c)), class: alignment_of(c, sample))
          end
          close(:tr)
        end
      end
      close(:tbody)
      footer_row(columns, @rows, sample)
      close(:table)
    end

    private

    def footer_row(columns, rows, sample)
      totals = columns.select { |c| c[:total] }
      return if totals.empty?

      open(:tfoot)
      open(:tr)
      shown = columns.reject { |c| c[:total] }
      shown.each_with_index do |c, i|
        t = totals.find { |x| x[:name] == c[:name] }
        if t
          sum = rows.sum { |row| Subject.new(row).fetch(c[:name]) }
          text_tag(:td, present(sum, format_of(c, rows.first)), class: alignment_of(c, sample))
        elsif i.zero?
          text_tag(:td, totals.first[:header] || 'Total')
        else
          text_tag(:td, '')
        end
      end
      close(:tr)
      close(:tfoot)
    end
  end

  # The same shape as `table`. A chart declares its series and the points come
  # from the subject; `band`, `line` and `level` register rather than render,
  # so the scale can be settled before anything is drawn.
  class Chart < Component
    INSIDE = 'a chart'

    def initialize(builder, name, caption, over, block)
      super(builder, &block)
      @name = name
      @caption = caption
      @over = over
      rows = name ? subject.fetch(name) : subject.object
      @rows = rows.to_a
    end

    def render
      with_open
      series = @collected.select { |i| i[:kind] }
      levels = @collected.select { |i| i[:value] }

      # A series with nothing in it is not a series. roth's do-nothing line
      # takes `from:` a baseline that does not exist until something is
      # converted, and an empty one still drew an empty path and claimed a
      # place in the key.
      drawn = series.map { |s| resolve(s, @rows) }.reject { |s| s[:points].empty? }

      emit(Charting.render(series: drawn,
                           levels: levels,
                           across: across(@rows, @over || Inference.singular(@name)),
                           caption: @caption))
    end

    private

    # A series becomes points to draw, a name to call it, and the same values
    # written the way the rest of the page would write them — so a tooltip says
    # `$412,800` because `format_for` said money, not because a chart guessed.
    def resolve(series, rows)
      source = series[:from] ? series[:from].to_a : rows
      sample = source.first
      kind = Subject.new(sample).format_for(series[:name])
      values = source.map { |row| Subject.new(row).fetch(series[:name]) }

      { kind: series[:kind],
        label: label_of({ name: series[:name], header: series[:label] }, sample),
        points: values.map(&:to_f),
        shown: values.map { |v| present(v, kind) } }
    end

    # `chart years` reads each row's `year`. Where the rows cannot answer that,
    # the axis counts instead of inventing.
    def across(rows, attribute)
      return (1..rows.size).map(&:to_s) unless attribute && rows.first
      return (1..rows.size).map(&:to_s) unless Subject.new(rows.first).has?(attribute)

      rows.map { |row| Subject.new(row).fetch(attribute).to_s }
    end
  end

  # The branches register, then the first true one renders. `otherwise` is an
  # ordinary word valid inside `choose`, so `else` is never a keyword and
  # nothing needs special parsing.
  class Choose < Component
    INSIDE = 'a choose'

    def render
      with_open
      chosen = @collected.find { |c, _| c } || @collected.find { |c, _| c.nil? }
      @builder.send(:nest, &chosen.last) if chosen
    end

    def add_branch(condition, block) = @collected << [condition, block]
  end

  # The dropdown: a label, a select, and the options its children declared.
  # `option` has no guard of its own — the Builder's routing refuses it
  # outside a choice, the guard the other three gatherers always had.
  class Choice < Component
    INSIDE = 'a choice'

    def initialize(builder, name, label, block)
      super(builder, &block)
      @name = name
      @label = label
      @selected = subject.fetch(name)
    end

    def render
      with_open
      open(:div, class: token(:field, :choice))
      text_tag(:label, label_for(@name, @label), for: @name.to_s)
      open(:select, id: @name.to_s, name: @name.to_s)
      @collected.each do |o|
        text_tag(:option, o[:label] || Inference.label(o[:value]),
                 value: o[:value].to_s,
                 selected: (@selected.to_s == o[:value].to_s ? 'selected' : nil))
      end
      close(:select)
      close(:div)
    end
  end
end
