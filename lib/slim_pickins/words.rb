# frozen_string_literal: true

require_relative 'word'

module SlimPickins
  module Words
    class Page < Word
      contract name: :subject, content: true, modifiers: [:favicon], children: :any, subject: :shift, shape: :document, lazy: [], infers: [:document, :title, :layout]

      def evaluate
        favicon = @kwargs.key?(:favicon) ? @kwargs[:favicon] : nil
        name, title = arguments(@args)
        heading = title || Inference.label(name)

        # The layout runs first, because it may contribute to the head — its
        # stylesheet and its scripts. Reading `head_nodes` before it ran meant
        # a layout's assets never reached the document, which is the one thing
        # a layout exists to hold.
        value, empty, body = about(name) { wrapped_in_layout(&@block) }
        emit_node([:page, { heading: heading, head: head_nodes,
                            favicon: favicon },
                   prune(body, empty)])
        value
      end
    end

    class Stylesheet < Head
      contract content: true, shape: :document, lazy: []
      maps content: :path
    end


    class Script < Head
      contract content: true, modifiers: [:defer], shape: :document, lazy: []
      maps content: :path
    end

    # `link_to` is an app word — the studio's, and any app's — standing in for
    # `link` where the destination is not a literal the page can spell:
    # `link`'s `to:` takes a string, and a URL only the app can mint is not
    # one. It renders an anchor exactly as `link` does, so `nav` accepts it as
    # a child; allowing it here is the language admitting a named sibling
    # rather than pretending a nav cannot hold a link.
    class Nav < Encloses
      contract name: :variant, children: [:link, :link_to, :input, :search], shape: :encloses, lazy: []
    end

    class Link < Says
      contract name: :destination, content: true, modifiers: [:to, :active], shape: :says, lazy: [], infers: [:link_href, :label]
      maps name: :name, content: :label
    end

    class Paragraph < Encloses
      contract name: :variant, content: true, children: :any, shape: :presents, lazy: []
      maps content: :body
    end

    class Box < Word
      contract name: :variant, content: true, modifiers: [:open, :id], children: :any, shape: :encloses, lazy: [], infers: [:box_body_over_children]

      def evaluate
        open = @kwargs.key?(:open) ? @kwargs[:open] : nil
        id = @kwargs.key?(:id) ? @kwargs[:id] : nil
      variant, body = arguments(@args)
      emit_node([:box, { variant: variant, body: body, open: open, id: id }, capture(&@block)])

      end
    end

    class Heading < Encloses
      contract content: true, shape: :presents, lazy: [], infers: [:heading_level, :box_title]
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
      contract name: :binding, modifiers: [:from], children: :any, subject: :each, speech: :determiner, shape: :iterates, lazy: [], infers: [:plural_collection, :singular_binding, :subject_or_collection]

      def evaluate
from = @kwargs.key?(:from) ? @kwargs[:from] : nil
name, = arguments(@args)
if Word.registry.key?(name)
  raise Error, "`each #{name}` cannot bind `#{name}` — it is a word of " \
               "the language. Name the binding something else and say " \
               "`from:` — `each row, from: .#{Inference.plural(name)}`."
end

items = if from.is_a?(Symbol)
          subject.fetch(from)
        elsif from
          from
        else
          collection_for(name)
        end
collected = items.to_a.map do |item|
  bind(name, item)
  chain.with(item, described_as: "this #{name}") { capture(&@block) }
end
unbind(name)
emit_node([:each, { name: name }, collected])

      end
    end

    class Table < Word
      contract name: :subject, content: true, children: [:column, :total, :choose, :each], subject: :shift, shape: :gathers, lazy: [], infers: [:table_rows]

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

    end

    class Column < Word
      contract name: :attribute, content: true, modifiers: [:as], parents: [:table], subject: :row, shape: :registers, lazy: [], infers: [:column_registration, :table_header, :numeric_alignment, :format]

      def evaluate
        as = @kwargs.key?(:as) ? @kwargs[:as] : nil
      name, header = arguments(@args)
      register!(SlimPickins::Words::Table, { name: name, header: header, as: as }, 'column')

      end
    end

    class Total < Word
      contract name: :attribute, content: true, parents: [:table], shape: :registers, lazy: [], infers: [:column_registration, :format]

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
      contract name: :attribute, content: true, shape: :presents, lazy: [], infers: [:label, :format]

      def evaluate
        name, value = arguments(@args)
        if name
          shown = value.nil? ? subject.fetch(name) : value
          resolved_label = label_for(name, nil)
          kind = format_of({ name: name, as: nil })
        else
          shown = @args[0]
          resolved_label = @args[1]
          kind = nil
        end
        emit_node([:fact, { name: name, label: resolved_label,
                            value: shown, kind: kind }, []])
      end
    end

    class Snippet < Encloses
      contract name: :notation, content: true, shape: :presents, lazy: []
      maps name: :language, content: :body
    end

    class Iframe < Says
      contract name: :name, modifiers: [:src, :srcdoc, :width, :height], shape: :presents, lazy: []
    end



    class Metric < Word
      contract name: :attribute, content: true, modifiers: [:as], shape: :says, lazy: [], infers: [:label, :format]

      def evaluate
        as = @kwargs.key?(:as) ? @kwargs[:as] : nil
        name, label = arguments(@args)
        if name
          value = subject.fetch(name)
          resolved_label = label_for(name, label)
          kind = as || subject.format_for(name)
        else
          value = @args[0]
          resolved_label = @args[1] || 'Metric'
          kind = as
        end
        emit_node([:metric, { name: name, label: resolved_label,
                              value: value, kind: kind }, []])
      end
    end

    class Chart < Word
      contract name: :subject, content: true, modifiers: [:over], children: [:band, :line, :level, :each, :choose], subject: :shift, shape: :gathers, lazy: [], infers: [:chart_axis, :format_family, :table_header]

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

    end

    class Band < Word
      contract name: :attribute, content: true, parents: [:chart], shape: :registers, lazy: [], infers: [:column_registration]

      def evaluate
      name, label = arguments(@args)
      register!(SlimPickins::Words::Chart, { kind: :band, name: name, label: label }, 'band')

      end
    end

    class Line < Word
      contract name: :attribute, content: true, modifiers: [:from], parents: [:chart], shape: :registers, lazy: [], infers: [:column_registration]

      def evaluate
        from = @kwargs.key?(:from) ? @kwargs[:from] : nil
      name, label = arguments(@args)
      register!(SlimPickins::Words::Chart, { kind: :line, name: name, label: label, from: from }, 'line')

      end
    end

    class Level < Word
      contract content: true, parents: [:chart], shape: :registers, lazy: [], infers: [:column_registration]

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
        target.add_branch(Inference.truthy?(condition&.call), @block)

      end
    end

    class Tabs < Encloses
      contract name: :variant, children: :any, shape: :encloses
    end

    class Tab < Encloses
      contract content: true, children: :any, modifiers: [:active], shape: :encloses, lazy: [], infers: [:label]
      maps content: :label
    end

    class Form < Word
      contract name: :subject, modifiers: [:to, :method, :target], children: [:group, :field, :checkbox, :choice, :actions, :disclosure, :button, :hidden, :input, :textarea, :choose, :children, :box], subject: :shift, shape: :encloses, lazy: []

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
      contract name: :topic, content: true, children: :any, shape: :encloses, lazy: [], infers: [:group_shape, :label]
      maps content: :legend
    end

    class Field < Word
      contract name: :attribute, content: true, modifiers: [:type, :step, :required], shape: :says, lazy: [], infers: [:label, :input_type, :input_step, :boolean_field]

      def evaluate
        type = @kwargs.key?(:type) ? @kwargs[:type] : nil
        step = @kwargs.key?(:step) ? @kwargs[:step] : nil
        required = @kwargs.key?(:required) ? @kwargs[:required] : nil
      name, label = arguments(@args)
      value = subject.fetch(name)
      # A value that is already true or false knows what shape it wants; the
      # page says `field done` and gets a checkbox (dan's ruling, 2026-09-17).
      # `type:` overrides, as every inference is overridable by saying the thing.
      kind = type || (Inference.boolean?(value) ? :checkbox : Inference.input_type(value))
      emit_node([:field, { name: name, label: label_for(name, label),
                           value: value,
                           kind: kind,
                           step: (step || Inference.step_for(value))&.to_s,
                           required: required }, []])

      end
    end

    class Input < Word
      contract name: :attribute, content: true, modifiers: [:type, :placeholder], shape: :says, lazy: [], infers: [:input_type]

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
      contract name: :attribute, content: true, modifiers: [:rows, :required, :readonly], shape: :says, lazy: [], infers: [:label]

      def evaluate
        rows = @kwargs.key?(:rows) ? @kwargs[:rows] : nil
        required = @kwargs.key?(:required) ? @kwargs[:required] : nil
        readonly = @kwargs.key?(:readonly) ? @kwargs[:readonly] : nil
        name, label = arguments(@args)
        if name
          value = subject.has?(name) ? subject.fetch(name) : nil
        else
          value = @args[0]
          label = @args[1]
        end
        emit_node([:textarea, { name: name, label: label_for(name, label),
                                value: value, rows: (rows || 4).to_s,
                                required: required, readonly: readonly }, []])

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
      contract name: :attribute, content: true, shape: :says, lazy: [], infers: [:label]

      def evaluate
      name, label = arguments(@args)
      value = subject.fetch(name)
      emit_node([:checkbox, { name: name, label: label_for(name, label), value: value }, []])

      end
    end

    class Choice < Word
      contract name: :attribute, content: true, children: [:option, :choice, :each], shape: :gathers, lazy: [], infers: [:label, :option_selected]

      def evaluate
        variant = nil
        remaining = @args.dup
        if remaining.first == :radio
          variant = :radio
          remaining.shift
        end

        name, label = arguments(remaining)
        if name.nil? && remaining.first
          val = remaining.first
          name = val.is_a?(Symbol) ? val : nil
          label = remaining[1] || (name ? label_for(name, nil) : nil)
          selected = val.is_a?(Symbol) ? (subject.has?(val) ? subject.fetch(val) : nil) : val
        else
          @name = name
          @label = label
          selected = name && subject.has?(name) ? subject.fetch(name) : nil
        end

        with_open
        options = @collected.map do |o|
          [:option, { value: o[:value], label: o[:label], selected: selected }, []]
        end
        emit_node([:choice, { name: name, label: label_for(name, label), selected: selected, variant: variant },
                   options])

      end
    end

    class Option < Word
      contract name: :value, content: true, parents: [:choice], shape: :registers, lazy: []

      def evaluate
        value = @args[0]
        label = @args[1] || (value.is_a?(Symbol) ? label_for(value, nil) : value.to_s)
        register!(SlimPickins::Words::Choice, { value: value, label: label }, 'option')

      end
    end

    class Button < Word
      contract name: :variant, content: true, modifiers: [:to, :target, :type, :size, :name, :value], shape: :says, lazy: [], infers: [:button_type]

      def evaluate
        to = @kwargs.key?(:to) ? @kwargs[:to] : nil
        target = @kwargs.key?(:target) ? @kwargs[:target] : nil
        type = @kwargs.key?(:type) ? @kwargs[:type] : nil
        size = @kwargs.key?(:size) ? @kwargs[:size] : nil
        name = @kwargs.key?(:name) ? @kwargs[:name] : nil
        value = @kwargs.key?(:value) ? @kwargs[:value] : nil
        variant, label = arguments(@args)
        emit_node([:button, { variant: variant,
                              label: label || (variant && Inference.label(variant)),
                              to: to, target: target, type: type, size: size,
                              name: name, value: value }, []])

      end
    end

    class Choose < Word
      contract children: [:when, :otherwise], speech: :verb, shape: :gathers, lazy: [], infers: [:first_truthy_branch]

      def evaluate
  with_open
  chosen = @collected.find { |c, _| c } || @collected.find { |c, _| c.nil? }
  emit_node([:choose, {}, chosen ? capture(&chosen.last) : []])
end

def add_branch(condition, block)
  @collected << [condition, block]
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