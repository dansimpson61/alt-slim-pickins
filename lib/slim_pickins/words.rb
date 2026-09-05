# frozen_string_literal: true

require_relative 'word'

module SlimPickins
  module Words
    class Page < Word
      contract name: :subject, content: true, modifiers: [:favicon], children: :any, subject: :shift, shape: :document, lazy: []

      def evaluate
        favicon = @kwargs.key?(:favicon) ? @kwargs[:favicon] : nil
      name, title = arguments(@args)
      heading = title || Inference.label(name)

      value, empty, body = about(name) { wrapped_in_layout(&@block) }
      emit_node([:page, { heading: heading, head: head_nodes, icons: sprite_symbols,
                          favicon: favicon },
                 prune(body, empty)])
      value

      end
    end

    class Stylesheet < Head
      contract content: true, shape: :document, lazy: []
      maps content: :path
    end

    class Meta < Head
      contract name: :name, content: true, shape: :document, lazy: []
      maps content: :content
    end

    class Script < Head
      contract content: true, modifiers: [:defer], shape: :document, lazy: []
      maps content: :path
    end

    class Nav < Encloses
      contract name: :variant, children: [:link, :input, :search], shape: :encloses, lazy: []
    end

    class Link < Word
      contract name: :destination, content: true, modifiers: [:to, :active], shape: :says, lazy: []

      def evaluate
        to = @kwargs.key?(:to) ? @kwargs[:to] : nil
        active = @kwargs.key?(:active) ? @kwargs[:active] : nil
      name, label = arguments(@args)
      emit_node([:link, { name: name, label: label_for(name, label), to: to, active: active }, []])

      end
    end

    class Paragraph < Encloses
      contract name: :variant, content: true, children: :any, shape: :presents, lazy: []
    end

    class Region < Word
      contract name: :variant, content: true, modifiers: [:open, :id], children: :any, shape: :encloses, lazy: []

      def evaluate
        open = @kwargs.key?(:open) ? @kwargs[:open] : nil
        id = @kwargs.key?(:id) ? @kwargs[:id] : nil
      variant, body = arguments(@args)
      emit_node([:region, { variant: variant, body: body, open: open, id: id }, capture(&@block)])

      end
    end

    class Heading < Encloses
      contract content: true, shape: :presents, lazy: []
      maps content: :body
    end

class Span < Encloses
  contract name: :variant, content: true, modifiers: [:precision], shape: :presents, lazy: []
  maps content: :body
end

    class Figcaption < Encloses
      contract content: true, shape: :presents, lazy: []
      maps content: :body
    end

    class Summary < Encloses
      contract content: true, shape: :presents, lazy: []
      maps content: :body
    end

    class Each < Word
      contract name: :binding, modifiers: [:from], children: :any, subject: :each, speech: :determiner, shape: :iterates, lazy: []

      def evaluate
from = @kwargs.key?(:from) ? @kwargs[:from] : nil
name, = arguments(@args)
if Word.registry.key?(name)
  raise Error, "`each #{name}` cannot bind `#{name}` — it is a word of " \
               "the language. Name the binding something else and say " \
               "`from:` — `each row, from: .#{Inference.plural(name)}`."
end

items = from || collection_for(name)
collected = items.to_a.map do |item|
  bind(name, item)
  chain.with(item, described_as: "this #{name}") { capture(&@block) }
end
unbind(name)
emit_node([:each, { name: name }, collected])

      end
    end

    class Table < Word
      contract name: :subject, content: true, children: [:column, :total, :choose, :each], subject: :shift, shape: :gathers, lazy: []

      def evaluate
  name, caption = arguments(@args)
  @name = name
  @caption = caption
  @rows = name ? subject.fetch(name) : subject.object

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

def ___dummy

      end
    end

    class Column < Word
      contract name: :attribute, content: true, modifiers: [:as], parents: [:table], subject: :row, shape: :registers, lazy: []

      def evaluate
        as = @kwargs.key?(:as) ? @kwargs[:as] : nil
      name, header = arguments(@args)
      register!(SlimPickins::Words::Table, { name: name, header: header, as: as }, 'column')

      end
    end

    class Total < Word
      contract name: :attribute, content: true, parents: [:table], shape: :registers, lazy: []

      def evaluate
      name, label = arguments(@args)
      register!(SlimPickins::Words::Table, { name: name, header: label, as: nil, total: true }, 'total')

      end
    end

    class Grid < Word
      contract name: :variant, content: true, modifiers: [:columns], children: :any, shape: :encloses, lazy: []

      def evaluate
        columns = @kwargs.key?(:columns) ? @kwargs[:columns] : nil
      variant, = arguments(@args)
      emit_node([:grid, { variant: variant, columns: columns }, capture(&@block)])

      end
    end

    class Prose < Encloses
      contract name: :notation, content: true, shape: :presents, lazy: []
      maps content: :body
    end

    class Fact < Word
      contract name: :attribute, content: true, shape: :presents, lazy: []

      def evaluate
      name, value = arguments(@args)
      shown = value.nil? ? subject.fetch(name) : value
      emit_node([:fact, { name: name, label: label_for(name, nil),
                          value: shown, kind: format_of({ name: name, as: nil }) }, []])

      end
    end

    class Snippet < Encloses
      contract name: :notation, content: true, shape: :presents, lazy: []
      maps name: :language, content: :body
    end

    class Iframe < Word
      contract name: :name, modifiers: [:src, :srcdoc, :width, :height], shape: :presents, lazy: []

      def evaluate
        src = @kwargs.key?(:src) ? @kwargs[:src] : nil
        srcdoc = @kwargs.key?(:srcdoc) ? @kwargs[:srcdoc] : nil
        width = @kwargs.key?(:width) ? @kwargs[:width] : nil
        height = @kwargs.key?(:height) ? @kwargs[:height] : nil
      name, = arguments(@args)
      emit_node([:iframe, { name: name, src: src, srcdoc: srcdoc, width: width, height: height }, []])

      end
    end

    class Image < Word
      contract content: true, modifiers: [:alt], shape: :presents

      def evaluate
        alt = @kwargs.key?(:alt) ? @kwargs[:alt] : nil
      _, src = arguments(@args)
      emit_node([:image, { src: src, alt: alt }, []])

      end
    end

    class Icon < Word
      contract name: :name, content: true, shape: :says, lazy: []

      def evaluate
      name, data = arguments(@args)
      name ||= data
      use_icon(name.to_s.to_sym)
      emit_node([:icon, { name: name }, []])

      end
    end

    class Metric < Word
      contract name: :attribute, content: true, modifiers: [:as], shape: :says, lazy: []

      def evaluate
        as = @kwargs.key?(:as) ? @kwargs[:as] : nil
      name, label = arguments(@args)
      value = subject.fetch(name)
      emit_node([:metric, { name: name, label: label_for(name, label),
                            value: value, kind: as || subject.format_for(name) }, []])

      end
    end

    class Chart < Word
      contract name: :subject, content: true, modifiers: [:over], children: [:band, :line, :level, :each, :choose], subject: :shift, shape: :gathers, lazy: []

      def evaluate
  over = @kwargs.key?(:over) ? @kwargs[:over] : nil
  name, caption = arguments(@args)
  @name = name
  @caption = caption
  @over = over
  rows = name ? subject.fetch(name) : subject.object
  @rows = rows.to_a

  with_open
  series = @collected.select { |i| i[:kind] }
  levels = @collected.select { |i| i[:value] }

  drawn = series.map { |s| resolve(s, @rows) }.reject { |s| s[:points].empty? }

  emit_node([:chart, { series: drawn, levels: levels,
                       across: across(@rows, @over || Inference.singular(@name)),
                       caption: @caption }, []])
end

private

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

def across(rows, attribute)
  return (1..rows.size).map(&:to_s) unless attribute && rows.first
  return (1..rows.size).map(&:to_s) unless Subject.new(rows.first).has?(attribute)

  rows.map { |row| Subject.new(row).fetch(attribute).to_s }
end

def ___dummy

      end
    end

    class Band < Word
      contract name: :attribute, content: true, parents: [:chart], shape: :registers, lazy: []

      def evaluate
      name, label = arguments(@args)
      register!(SlimPickins::Words::Chart, { kind: :band, name: name, label: label }, 'band')

      end
    end

    class Line < Word
      contract name: :attribute, content: true, modifiers: [:from], parents: [:chart], shape: :registers, lazy: []

      def evaluate
        from = @kwargs.key?(:from) ? @kwargs[:from] : nil
      name, label = arguments(@args)
      register!(SlimPickins::Words::Chart, { kind: :line, name: name, label: label, from: from }, 'line')

      end
    end

    class Level < Word
      contract content: true, parents: [:chart], shape: :registers, lazy: []

      def evaluate
      register!(SlimPickins::Words::Chart,
                { value: @args.find { |a| a.is_a?(Numeric) }.to_f,
                  label: @args.find { |a| a.is_a?(String) } },
                'level')

      end
    end

    class When < Word
      contract content: true, children: :any, parents: [:choose], speech: :conjunction, shape: :encloses, lazy: [:content]

      def evaluate
      target = open_gatherer(SlimPickins::Words::Choose)
      raise Error, 'when belongs inside a choose' unless target

      # The transform sends the condition as a lambda, unevaluated — so this
      # guard can refuse a `when` outside a `choose` before the argument
      # runs, instead of reporting the argument's problem.
      condition = @args.first
      target.add_branch(!!(condition&.call), @block)

      end
    end

    class Tabs < Encloses
      contract name: :variant, children: :any, shape: :encloses
    end

    class Tab < Encloses
      contract content: true, children: :any, modifiers: [:active], shape: :encloses
      maps content: :label
    end

    class Form < Word
      contract name: :subject, modifiers: [:to, :method, :target], children: [:group, :field, :checkbox, :choice, :actions, :disclosure, :button, :hidden, :input, :textarea], subject: :shift, shape: :encloses, lazy: []

      def evaluate
        to = @kwargs.key?(:to) ? @kwargs[:to] : nil
        method = @kwargs.key?(:method) ? @kwargs[:method] : nil
        target = @kwargs.key?(:target) ? @kwargs[:target] : nil
      name, = arguments(@args)
      value, empty, children = about(name) { capture(&@block) }
      emit_node([:form, { name: name, to: to, method: method, target: target }, prune(children, empty)])
      value

      end
    end

    class Group < Encloses
      contract name: :topic, content: true, children: :any, shape: :encloses, lazy: []
      maps content: :legend
    end

    class Field < Word
      contract name: :attribute, content: true, modifiers: [:type, :step, :required], shape: :says, lazy: []

      def evaluate
        type = @kwargs.key?(:type) ? @kwargs[:type] : nil
        step = @kwargs.key?(:step) ? @kwargs[:step] : nil
        required = @kwargs.key?(:required) ? @kwargs[:required] : nil
      name, label = arguments(@args)
      value = subject.fetch(name)
      emit_node([:field, { name: name, label: label_for(name, label),
                           value: value,
                           kind: type || Inference.input_type(value),
                           step: (step || Inference.step_for(value))&.to_s,
                           required: required }, []])

      end
    end

    class Input < Word
      contract name: :attribute, content: true, modifiers: [:type, :placeholder], shape: :says, lazy: []

      def evaluate
        type = @kwargs.key?(:type) ? @kwargs[:type] : nil
        placeholder = @kwargs.key?(:placeholder) ? @kwargs[:placeholder] : nil
      name, value = arguments(@args)
      shown = value.nil? ? subject.fetch(name) : value
      emit_node([:input, { name: name, value: shown,
                           kind: type || Inference.input_type(shown),
                           placeholder: placeholder }, []])

      end
    end

    class Textarea < Word
      contract name: :attribute, content: true, modifiers: [:rows, :required], shape: :says, lazy: []

      def evaluate
        rows = @kwargs.key?(:rows) ? @kwargs[:rows] : nil
        required = @kwargs.key?(:required) ? @kwargs[:required] : nil
      name, label = arguments(@args)
      value = subject.fetch(name)
      emit_node([:textarea, { name: name, label: label_for(name, label),
                              value: value, rows: (rows || 4).to_s,
                              required: required }, []])

      end
    end

    class Hidden < Word
      contract name: :name, content: true, parents: [:form], shape: :says, lazy: []

      def evaluate
      name, value = arguments(@args)
      shown = value.nil? ? subject.fetch(name) : value
      emit_node([:hidden, { name: name, value: shown }, []])

      end
    end

    class Checkbox < Word
      contract name: :attribute, content: true, shape: :says, lazy: []

      def evaluate
      name, label = arguments(@args)
      value = subject.fetch(name)
      emit_node([:checkbox, { name: name, label: label_for(name, label), value: value }, []])

      end
    end

    class Choice < Word
      contract name: :attribute, content: true, children: [:option, :choice], shape: :gathers, lazy: []

      def evaluate
name, label = arguments(@args)
@name = name
@label = label
@selected = subject.fetch(name)

with_open
options = @collected.map do |o|
  [:option, { value: o[:value], label: o[:label], selected: @selected }, []]
end
emit_node([:choice, { name: @name, label: label_for(@name, @label), selected: @selected },
           options])

      end
    end

    class Option < Word
      contract name: :value, content: true, parents: [:choice], shape: :registers, lazy: []

      def evaluate
      value, label = arguments(@args)
      register!(SlimPickins::Words::Choice, { value: value, label: label }, 'option')

      end
    end

    class Button < Word
      contract name: :variant, content: true, modifiers: [:to, :target, :type, :size], shape: :says, lazy: []

      def evaluate
        to = @kwargs.key?(:to) ? @kwargs[:to] : nil
        target = @kwargs.key?(:target) ? @kwargs[:target] : nil
        type = @kwargs.key?(:type) ? @kwargs[:type] : nil
        size = @kwargs.key?(:size) ? @kwargs[:size] : nil
  variant, label = arguments(@args)
  emit_node([:button, { variant: variant,
                        label: label || (variant && Inference.label(variant)),
                        to: to, target: target, type: type, size: size }, []])

      end
    end

    class Choose < Word
      contract children: [:when, :otherwise], speech: :verb, shape: :gathers, lazy: []

      def evaluate
  with_open
  chosen = @collected.find { |c, _| c } || @collected.find { |c, _| c.nil? }
  emit_node([:choose, {}, chosen ? capture(&chosen.last) : []])
end

def add_branch(condition, block)
  @collected << [condition, block]
end

def ___dummy

      end
    end

    class Otherwise < Word
      contract children: :any, parents: [:choose], speech: :adverb, shape: :encloses, lazy: []

      def evaluate
      target = open_gatherer(SlimPickins::Words::Choose)
      raise Error, 'otherwise belongs inside a choose' unless target

      target.add_branch(nil, @block)

      end
    end

    class Children < Word
      contract shape: :document, lazy: []

      def evaluate
      raise Error, '`children` has nothing to splice — this word took no children' if spliced.nil?

      spliced.each { |n| emit_node(n) }

      end
    end

    class Contents < Word
      contract shape: :document, lazy: []

      def evaluate
      raise Error, '`contents` belongs in a layout' unless contents_stowed?

      take_contents&.each { |n| emit_node(n) }

      end
    end

  end
end