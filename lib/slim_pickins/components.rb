# frozen_string_literal: true

module SlimPickins
  # The four gatherers — table, chart, choose, choice — as objects. The lore
  # counted one gathering mechanism four times; this file is the one it
  # becomes.
  #
  # A gatherer's children are declarations: they register while the gatherer's
  # block runs, then the gatherer builds its semantic node from what it
  # collected. Children still evaluate against the Builder — the vocabulary is
  # the Builder's — so a component's job is exactly two things: own its
  # collection, and build its node. The Builder keeps a stack of the gatherers
  # currently open, which is the save-and-restore that used to be written by
  # hand in each one (and, in choice's case, forgotten).
  #
  # Components are part of the runtime, so they reach Builder's internals
  # through this one file. The app hatch stays six methods.
  class Component
    def initialize(builder, &block)
      @builder = builder
      @block = block
      @collected = []
    end

    # What a registering word hands over, and where the gatherer keeps it.
    def collect(item) = @collected << item

    # The Builder routes the registering words through the stack of open
    # gatherers — the guard and the save-and-restore, written once. The
    # builder's whole surface is public, and the components use it directly —
    # no send, no ivars of another object: the dogfood the vocabulary eats.
    def with_open
      @builder.with_gatherer(self) { @builder.evaluate(&@block) }
    end

    private

    def subject = @builder.subject
    def chain = @builder.chain
    def label_for(...) = @builder.label_for(...)
    def label_of(...) = @builder.label_of(...)
    def format_of(...) = @builder.format_of(...)
    def alignment_of(...) = @builder.alignment_of(...)
    def capture(&block) = @builder.capture(&block)
    def emit_node(node) = @builder.emit_node(node)
  end

  # A gatherer that is a vocabulary partial — its word name is how its
  # children find it, and its collection is what the body's `children`
  # splices.
  class PartialGatherer < Component
    attr_reader :word, :collected

    def initialize(builder, word, &block)
      @word = word.to_sym
      super(builder, &block)
    end
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
                           rows: rows, foot: foot(columns, @rows, sample) }, []])
    end

    private

    def foot(columns, rows, sample)
      totals = columns.select { |c| c[:total] }
      return [] if totals.empty?

      shown = columns.reject { |c| c[:total] }
      shown.each_with_index.map do |c, i|
        t = totals.find { |x| x[:name] == c[:name] }
        if t
          sum = rows.sum { |row| Subject.new(row).fetch(c[:name]) }
          { value: sum, kind: format_of(c, rows.first), alignment: c[:alignment] }
        elsif i.zero?
          { label: totals.first[:header] || 'Total' }
        else
          {}
        end
      end
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

      emit_node([:chart, { series: drawn, levels: levels,
                           across: across(@rows, @over || Inference.singular(@name)),
                           caption: @caption }, []])
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
        shown: values.map { |v| Generator.format(kind, v) } }
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
      emit_node([:choose, {}, chosen ? capture(&chosen.last) : []])
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
      options = @collected.map do |o|
        [:option, { value: o[:value], label: o[:label], selected: @selected }, []]
      end
      emit_node([:choice, { name: @name, label: label_for(@name, @label), selected: @selected },
                 options])
    end
  end
end
