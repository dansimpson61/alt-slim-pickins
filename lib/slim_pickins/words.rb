# frozen_string_literal: true

require_relative 'word'

module SlimPickins
  module Words
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

      def evaluate
        attrs = unpack_arguments
        if @args.size >= 2 && !@args[0].is_a?(Symbol)
          attrs[:label] ||= @args[0]
          attrs[:to] ||= @args[1]
        end
        emit_node(Node[:link, attrs, []])
      end
    end


    class Box < Word
      contract name: :variant, content: true, modifiers: [:open, :id], children: :any, shape: :encloses, lazy: [:content], infers: [:box_body_over_children]

      def evaluate
        open = @kwargs[:open]
        id = @kwargs[:id]

        first = @args[0]
        second = @args[1]

        first = first.call if first.is_a?(Proc)

        unless @block
          if spliced && first.nil?
            return emit_node(Node[:box, { variant: nil, body: nil, open: open, id: id }, spliced])
          end

          body_text = first.is_a?(Proc) ? first.call : first
          return emit_node(Node[:box, { variant: nil, body: body_text, open: open, id: id }, []])
        end

        shifts_subject = false
        subject_target = nil
        title_arg = nil

        if first.is_a?(Symbol)
          if subject.has?(first)
            val = subject.fetch(first)
            if !val.is_a?(String)
              shifts_subject = true
              subject_target = first
              title_arg = second
            end
          end
        elsif !first.nil? && !first.is_a?(String)
          shifts_subject = true
          subject_target = first
          title_arg = second
        end

        if shifts_subject
          title_text = nil
          target_val = subject_target.is_a?(Symbol) ? subject.fetch(subject_target) : subject_target
          empty = Inference.nothing_in?(target_val)

          was_empty = @builder.empty_active?
          @builder.instance_variable_set(:@empty_active, empty)

          raw_children = chain.with(target_val, described_as: "this #{subject_target || 'box'}", overlay: true) do
            if title_arg
              if !empty
                title_text = if title_arg.is_a?(Proc)
                               title_arg.call
                             elsif title_arg.is_a?(Symbol)
                               subject.has?(title_arg) ? subject.fetch(title_arg) : title_arg.to_s
                             else
                               title_arg
                             end
              else
                if title_arg.is_a?(String)
                  title_text = title_arg
                elsif title_arg.is_a?(Symbol) && !title_arg.to_s.start_with?('.')
                  title_text = subject.has?(title_arg) ? subject.fetch(title_arg) : title_arg.to_s
                end
              end
            end
            capture(&@block)
          end
          @builder.instance_variable_set(:@empty_active, was_empty)

          children = prune(raw_children, empty)
          if title_text && !title_text.to_s.empty?
            children.unshift(Node[:heading, { body: title_text.to_s }, []])
          end

          emit_node(Node[:box, { variant: nil, body: nil, open: open, id: id }, children])
          target_val
        else
          resolved_args = @args.map { |a| a.is_a?(Proc) ? a.call : a }
          variant, body = arguments(resolved_args)
          emit_node(Node[:box, { variant: variant, body: body, open: open, id: id }, capture(&@block)])
        end
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

    class Each < Word
      contract name: :binding, modifiers: [:from], children: :any, subject: :each, speech: :determiner, shape: :iterates, lazy: [], infers: [:plural_collection, :singular_binding, :subject_or_collection]

      def evaluate
        from = @kwargs[:from]
        name, = arguments(@args)
        if Word.registry.key?(name) || Library.builtin.word?(name)
          raise Error, "`each #{name}` cannot bind `#{name}` — it is a word of " \
                       "the language. Name the binding something else and say " \
                       "`from:` — `each row, from: .#{Inference.plural(name)}`."
        end

        # `from:` said is `from:` meant, even when what it reads is nil.
        items = if !@kwargs.key?(:from)
                  collection_for(name)
                elsif from.is_a?(Symbol)
                  subject.fetch(from)
                else
                  from
                end

        unless items.nil? || Inference.collection?(items) || items.is_a?(Hash)
          raise Error, "`each #{name}` expects a collection to go through, got #{items.class.name.split('::').last.downcase}"
        end

        iterable = if items.is_a?(Hash)
                     items.map { |k, v| KeyValue.new(k, v, subject: subject, formatted: true) }
                   else
                     (items || []).to_a
                   end

        collected = iterable.map do |item|
          naming(name, item) { chain.with(item, described_as: "this #{name}") { capture(&@block) } }
        end
        emit_node(Node[:each, { name: name }, collected])
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
          sample_val = sample && Subject.new(sample).fetch(c[:name])
          kv = key_value(c[:name], sample_val, row: sample, label: c[:header], format: c[:as])
          c[:sample] = sample_val
          c[:header] = kv.label
          c[:alignment] = kv.alignment
        end

        outer_subject = subject
        rows = @rows.map do |row|
          chain.with(row) do
            cells = columns.reject { |c| c[:total] }.map do |c|
              val = subject.fetch(c[:name])
              kv = KeyValue.new(c[:name], val, subject: outer_subject, row: subject,
                                label: c[:header], format: c[:as])
              { name: c[:name], value: val, kind: kv.explicit_or_domain_format,
                alignment: c[:alignment] }
            end
            # A row is a node too, though it is carried in the table's attributes
            # rather than emitted — which is why the sweep over `emit_node` did
            # not find it and a render did.
            Node[:row, {}, cells]
          end
        end

        emit_node(Node[:table, { name: @name, caption: @caption, columns: columns,
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
            kv = key_value(c[:name], sum, row: sample, label: c[:header], format: c[:as])
            { value: sum, kind: kv.explicit_or_domain_format, alignment: c[:alignment] }
          elsif i.zero?
            { label: totals.first[:header] || 'Total' }
          else
            {}
          end
        end
      end

      class Column < Word
        contract name: :attribute, content: true, modifiers: [:as], subject: :row, shape: :registers, lazy: [], infers: [:column_registration, :table_header, :numeric_alignment, :format]

        def evaluate
          name, header = arguments(@args)
          register!(SlimPickins::Words::Table, { name: name, header: header, as: @kwargs[:as] }, 'column')
        end
      end

      class Total < Word
        contract name: :attribute, content: true, shape: :registers, lazy: [], infers: [:column_registration, :format]

        def evaluate
          name, label = arguments(@args)
          register!(SlimPickins::Words::Table, { name: name, header: label, as: nil, total: true }, 'total')
        end
      end
    end

    class Grid < Word
      contract name: :variant, content: true, modifiers: [:columns], children: :any, shape: :encloses, lazy: []

      def evaluate
        variant, = arguments(@args)
        emit_node(Node[:grid, { variant: variant, columns: @kwargs[:columns] }, capture(&@block)])
      end
    end

    class Prose < Encloses
      contract name: :notation, content: true, shape: :presents, lazy: []
      maps content: :body

      # A self-titled page (its title taken from the subject's first heading)
      # renders the subject's content without repeating that heading, so
      # `prose markdown, .content` begins where the title ended.
      def evaluate
        attrs = unpack_arguments
        attrs[:drop_leading_heading] = true if attrs[:notation] == :markdown && @builder.self_titled?
        emit_node(Node[:prose, attrs, []])
      end
    end

    class Iframe < Says
      contract name: :name, modifiers: [:src, :srcdoc, :width, :height], shape: :presents, lazy: []
    end

    class Chart < Word
      contract name: :subject, content: true, modifiers: [:over], children: [:band, :line, :level, :each, :choose], subject: :shift, shape: :gathers, lazy: [], infers: [:chart_axis, :format_family, :table_header]

      def evaluate
        over = @kwargs[:over]
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

        emit_node(Node[:chart, { series: drawn, levels: levels,
                             across: across(@rows, @over || Inference.singular(@name)),
                             caption: @caption }, []])
      end

      private

      def resolve(series, rows)
        source = series[:from] ? series[:from].to_a : rows
        sample = source.first
        kv = key_value(series[:name], nil, row: sample, label: series[:label])
        kind = kv.explicit_or_domain_format
        values = source.map { |row| Subject.new(row).fetch(series[:name]) }

        { kind: series[:kind],
          label: kv.label,
          points: values.map(&:to_f),
          shown: values.map { |v| Generator.format(kind, v) } }
      end

      def across(rows, attribute)
        return (1..rows.size).map(&:to_s) unless attribute && rows.first
        return (1..rows.size).map(&:to_s) unless Subject.new(rows.first).has?(attribute)

        rows.map { |row| Subject.new(row).fetch(attribute).to_s }
      end

      class Band < Word
        contract name: :attribute, content: true, shape: :registers, lazy: [], infers: [:column_registration]

        def evaluate
          name, label = arguments(@args)
          register!(SlimPickins::Words::Chart, { kind: :band, name: name, label: label }, 'band')
        end
      end

      class Line < Word
        contract name: :attribute, content: true, modifiers: [:from], shape: :registers, lazy: [], infers: [:column_registration]

        def evaluate
          name, label = arguments(@args)
          register!(SlimPickins::Words::Chart, { kind: :line, name: name, label: label, from: @kwargs[:from] }, 'line')
        end
      end

      class Level < Word
        contract content: true, shape: :registers, lazy: [], infers: [:column_registration]

        def evaluate
          register!(SlimPickins::Words::Chart,
                    { value: @args.find { |a| a.is_a?(Numeric) }.to_f,
                      label: @args.find { |a| a.is_a?(String) } },
                    'level')
        end
      end
    end

    class Tabs < Encloses
      contract children: :any, shape: :encloses

      # `parents:` since 2026-10-03, which makes `tab` the tenth structural child
      # held to its gatherer rather than the one exception. A stray `tab` used to
      # render an empty `<div class="tab-panel">` and throw its content away: the
      # content maps to `:label`, and the label is rendered by the enclosing
      # `tabs`, which was not there to render it. Silent loss, where a stray
      # `item` has always been refused by name.
      class Tab < Encloses
        contract content: true, children: :any, modifiers: [:active],
                 shape: :encloses, lazy: [], infers: [:label]
        maps content: :label
      end
    end

    class Form < Word
      contract name: :subject, modifiers: [:to, :method, :target], children: [:group, :field, :checkbox, :choice, :actions, :disclosure, :button, :hidden, :input, :textarea, :choose, :contents, :box, :each], subject: :shift, shape: :encloses, lazy: []

      class Hidden < Word
        contract name: :name, content: true, shape: :says, lazy: []

        def evaluate
          kv = KeyValue.for_control(subject, @args, @kwargs, second_is: :value)
          emit_node(Node[:hidden, { name: kv.key, value: kv.raw_value }, []])
        end
      end

      def evaluate
        name, = arguments(@args)
        value, empty, children = about(name) { @builder.with_family(:form) { capture(&@block) } }
        emit_node(Node[:form, { name: name, to: @kwargs[:to], method: @kwargs[:method], target: @kwargs[:target] },
                       prune(children, empty)])
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
        kv = KeyValue.for_control(subject, @args, @kwargs)
        emit_node(Node[:field, { name: kv.key, label: kv.label,
                                 value: kv.raw_value,
                                 kind: kv.input_type(@kwargs[:type]),
                                 step: kv.step(@kwargs[:step]),
                                 required: @kwargs[:required] }, []])
      end
    end

    class Input < Word
      contract name: :attribute, content: true, modifiers: [:type, :placeholder], shape: :says, lazy: [], infers: [:input_type]

      def evaluate
        kv = KeyValue.for_control(subject, @args, @kwargs, second_is: :value)
        emit_node(Node[:input, { name: kv.key, value: kv.raw_value,
                                 kind: @kwargs[:type] || Inference.input_type(kv.raw_value),
                                 placeholder: @kwargs[:placeholder] }, []])
      end
    end

    class Textarea < Word
      contract name: :attribute, content: true, modifiers: [:rows, :required, :readonly], shape: :says, lazy: [], infers: [:label]

      def evaluate
        kv = KeyValue.for_control(subject, @args, @kwargs, require_attribute: false)
        emit_node(Node[:textarea, { name: kv.key, label: kv.label,
                                    value: kv.raw_value, rows: (@kwargs[:rows] || 4).to_s,
                                    required: @kwargs[:required], readonly: @kwargs[:readonly] }, []])
      end
    end

    class Checkbox < Word
      contract name: :attribute, content: true, shape: :says, lazy: [], infers: [:label]

      def evaluate
        kv = KeyValue.for_control(subject, @args, @kwargs)
        emit_node(Node[:checkbox, { name: kv.key, label: kv.label, value: kv.raw_value }, []])
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

        kv = KeyValue.for_control(subject, remaining, @kwargs, require_attribute: false)
        @name = kv.key
        @label = kv.label
        selected = kv.raw_value

        with_open
        options = @collected.map do |o|
          Node[:option, { value: o[:value], label: o[:label], selected: selected }, []]
        end
        emit_node(Node[:choice, { name: kv.key, label: kv.label, selected: selected, variant: variant },
                   options])
      end

      class Option < Word
        contract name: :value, content: true, shape: :registers, lazy: []

        def evaluate
          value = @args[0]
          label = @args[1] || (value.is_a?(Symbol) ? label_for(value, nil) : value.to_s)
          register!(SlimPickins::Words::Choice, { value: value, label: label }, 'option')
        end
      end
    end

    class Button < Word
      contract name: :variant, content: true, modifiers: [:to, :target, :type, :size, :name, :value], shape: :says, lazy: [], infers: [:button_type]

      def evaluate
        variant, label = arguments(@args)
        emit_node(Node[:button, { variant: variant,
                                  label: label || (variant && Inference.label(variant)),
                                  to: @kwargs[:to], target: @kwargs[:target],
                                  type: @kwargs[:type], size: @kwargs[:size],
                                  name: @kwargs[:name], value: @kwargs[:value] }, []])
      end
    end

    class Choose < Word
      contract children: [:when, :otherwise], speech: :verb, shape: :gathers, lazy: [], infers: [:first_truthy_branch]

      class When < Word
        contract content: true, children: :any, speech: :conjunction, shape: :encloses, lazy: [:content]

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

      class Otherwise < Word
        contract children: :any, speech: :adverb, shape: :encloses, lazy: []

        def evaluate
          target = open_gatherer(SlimPickins::Words::Choose)
          raise Error, 'otherwise belongs inside a choose' unless target

          target.add_branch(nil, @block)
        end
      end

      def evaluate
        with_open
        chosen = @collected.find { |c, _| c } || @collected.find { |c, _| c.nil? }
        emit_node(Node[:choose, {}, chosen ? capture(&chosen.last) : []])
      end

      def add_branch(condition, block)
        @collected << [condition, block]
      end
    end

    class Contents < Word
      contract shape: :document, lazy: []

      def evaluate
        if !spliced.nil?
          spliced.each { |n| emit_node(n) }
        elsif contents_stowed?
          take_contents&.each { |n| emit_node(n) }
        else
          raise Error, '`contents` belongs in a frame'
        end
      end
    end

    class Dictionary < Word
      contract name: :topic, content: true, children: [:on, :otherwise], speech: :noun, shape: :gathers, lazy: []

      def initialize(builder, args, kwargs, block)
        super
        @table = {}
        @fallback = nil
      end

      def add_entry(key, target = nil, block = nil)
        @table[key] = block || target
      end

      def set_fallback(target = nil, block = nil)
        @fallback = block || target
      end

      def table = @table
      def fallback = @fallback

      def evaluate
        with_open if @block

        return self if @args.empty?

        key = @args.first
        Dictionary.resolve(@builder, key, @table, fallback: @fallback, forward_args: @args.drop(1))
      end

      def resolve_key(key)
        target = self.class.find_entry(@table, key)
        target.nil? ? @fallback : target
      end

      def self.find_entry(table, key)
        return nil unless table.is_a?(Hash)

        key = key.raw_value if key.is_a?(KeyValue)
        KeyValue.hash_fetch(table, key)
      end

      def self.resolve(builder, key, table, fallback: nil, forward_args: [], &block)
        raw_table = if table.is_a?(Dictionary)
                      table.table
                    elsif table.is_a?(Hash)
                      table
                    end
        effective_fallback = table.is_a?(Dictionary) ? (table.fallback || fallback) : fallback

        target = find_entry(raw_table, key)
        target = effective_fallback if target.nil?

        return nil if target.nil?

        if target.is_a?(Proc)
          nodes = builder.capture { target.call(*forward_args, &block) }
          nodes.each { |n| builder.emit_node(n) }
          nodes
        elsif target.is_a?(Symbol) && (builder.respond_to?(target) || Library.builtin.word?(target) || Word.registry.key?(target))
          builder.public_send(target, *forward_args, &block)
        else
          target
        end
      end

      class On < Word
        contract name: :name, content: true, children: :any, speech: :preposition, shape: :registers, lazy: []

        def evaluate
          target = open_gatherer(SlimPickins::Words::Dictionary)
          raise Error, 'on belongs inside a dictionary' unless target

          key = @args[0]
          target_action = @args[1]
          if key == :default || key == :otherwise
            target.set_fallback(target_action, @block)
          else
            target.add_entry(key, target_action, @block)
          end
        end
      end

      class Otherwise < Word
        contract children: :any, speech: :adverb, shape: :encloses, lazy: []

        def evaluate
          target = open_gatherer(SlimPickins::Words::Dictionary)
          raise Error, 'otherwise belongs inside a dictionary' unless target

          target.set_fallback(@args.first, @block)
        end
      end
    end

    class Map < Word
      contract name: :topic, content: true, open: true, speech: :verb, shape: :presents, lazy: []

      def evaluate
        first = @args.first
        if @kwargs.any?
          if @kwargs.key?(:in)
            dict = @kwargs[:in]
            Dictionary.resolve(@builder, first, dict, forward_args: @args.drop(1), &@block)
          else
            fallback = @kwargs[:default] || @kwargs[:otherwise]
            mapping = @kwargs.reject { |k, _| k == :default || k == :otherwise }
            Dictionary.resolve(@builder, first, mapping, fallback: fallback, forward_args: @args.drop(1), &@block)
          end
        elsif @args.size >= 2
          dict = first
          key = @args[1]
          resolved_dict = if dict.is_a?(Symbol) && @builder.respond_to?(dict)
                            @builder.public_send(dict)
                          else
                            dict
                          end
          Dictionary.resolve(@builder, key, resolved_dict, forward_args: @args.drop(2), &@block)
        end
      end
    end

  end
end