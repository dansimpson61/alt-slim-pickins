# frozen_string_literal: true

require_relative 'contracts'
require_relative 'icons'

module SlimPickins
  # The vocabulary, in its own home. The Builder is the runtime — the chain,
  # the bindings, the gatherer stack — and extends this module, so a word is
  # still a real method and an unknown word still fails with its own name.
  #
  # The words build semantic nodes, and they build them with the same surface
  # an app's own words get — `tag`, `html`, `token`, `arguments`, `children` —
  # which is the dogfood: the built-ins are produced by the same mechanism as
  # the escape hatch, so a definition cannot tell itself apart from an app's.
  # Where a word needs the runtime (subject resolution, inference, gathering),
  # it reaches the Builder's internals, which the extended module may.
  module Words
    # The vocabulary is the contracts: one list, in contracts.rb.
    WORDS = CONTRACTS.keys.freeze

    # --- Document -------------------------------------------------------

    def page(*args, favicon: nil, &block)
      name, title = arguments(args)
      heading = title || Inference.label(name)

      value, empty, body = about(name) { wrapped_in_layout(&block) }
      emit_node([:page, { heading: heading, head: head_nodes, icons: sprite_symbols,
                          favicon: favicon },
                 prune(body, empty)])
      value
    end

    # These three say where they belong, not where they are written, which is
    # what lets a layout mention a stylesheet from inside the body.
    def stylesheet(*args)
      _, path = arguments(args)
      in_head([:stylesheet, { path: path }, []])
    end

    def meta(*args)
      name, value = arguments(args)
      in_head([:meta, { name: name, value: value }, []])
    end

    def script(*args, defer: false)
      _, path = arguments(args)
      emit_node([:script, { path: path, defer: defer }, []])
    end

    def nav(*args, &block)
      variant, = arguments(args)
      emit_node([:nav, { variant: variant }, capture(&block)])
    end

    def link(*args, to: nil, active: nil)
      name, label = arguments(args)
      emit_node([:link, { name: name, label: label_for(name, label), to: to, active: active }, []])
    end

    # The element primitives. `paragraph` is the atom under note and text;
    # `region` is the atom under the wrappers — and under the named boxes it
    # derives its tag from the word, so a promoted `footer` stays a footer.
    # Classes still derive from the word, so a partial composing over them
    # keeps the language's shape.
    # The classed leaf — the atom under badge, money, percent, number and
    # time. Tag, class and formatting all derive from the word; the
    # Generator owns the inference, which is where formatting has always
    # lived.
    # Marks where the caller's children go — the partial's `contents`.
    def children
      raise Error, '`children` has nothing to splice — this word took no children' if spliced.nil?

      spliced.each { |n| emit_node(n) }
    end

    # Marks where the page's own nodes go. Only a layout has one.
    def contents
      raise Error, '`contents` belongs in a layout' unless contents_stowed?

      take_contents&.each { |n| emit_node(n) }
    end

    # --- Structure ------------------------------------------------------

    # The loop is written once, here, and never in a page.
    #
    # A binding may not be named after a word. `each` binds its name so an
    # inner loop can reach back out — but that reaching is served by
    # `method_missing`, and a word is a real method, so the word would answer
    # instead and hand back its own output. `each item` then made `item.name`
    # fail with a Ruby error about a String.
    #
    # It is refused rather than allowed-until-it-bites, for the same reason
    # `section` refuses to shift its subject opportunistically: a cost that
    # only appears in some pages is a cost nobody can see.
    def each(*args, from: nil, &block)
      name, = arguments(args)
      if WORDS.include?(name)
        raise Error, "`each #{name}` cannot bind `#{name}` — it is a word of " \
                     "the language. Name the binding something else and say " \
                     "`from:` — `each row, from: .#{Inference.plural(name)}`."
      end

      items = from || collection_for(name)
      collected = items.map do |item|
        bind(name, item)
        chain.with(item, described_as: "this #{name}") { capture(&block) }
      end
      unbind(name)
      emit_node([:each, { name: name }, collected])
    end

    # A table declares its columns; the rows come from the subject. The
    # gatherer is Table — see components.rb — this is the router's part.
    def table(*args, &block)
      name, caption = arguments(args)
      Table.new(self, name, caption, block).render
    end

    # The header is not resolved here. A column registers before any row
    # exists, so the only subject in scope is the one holding the collection —
    # and it is the *row* that knows what its own columns are called. The
    # table resolves it once the first row is in hand.
    def column(*args, as: nil)
      name, header = arguments(args)
      register!(Table, { name: name, header: header, as: as }, 'column')
    end

    def total(*args)
      name, label = arguments(args)
      register!(Table, { name: name, header: label, as: nil, total: true }, 'total')
    end

    # `columns:` is a wish, not a decree. An exact fractional track — a plain
    # `calc(100% / n)` — scales with its container and so can never reflow,
    # which quietly made every `columns:` grid non-responsive. Flooring it at
    # `--track-min` gives n columns where they fit and fewer where they do not.
    def grid(*args, columns: nil, &block)
      variant, = arguments(args)
      emit_node([:grid, { variant: variant, columns: columns }, capture(&block)])
    end

    # --- Content --------------------------------------------------------

    def prose(*args)
      notation, body = arguments(args)
      emit_node([:prose, { notation: notation, body: body }, []])
    end

    def fact(*args)
      name, value = arguments(args)
      shown = value.nil? ? subject.fetch(name) : value
      emit_node([:fact, { name: name, label: label_for(name, nil),
                          value: shown, kind: format_of({ name: name, as: nil }) }, []])
    end

    def snippet(*args)
      language, body = arguments(args)
      emit_node([:snippet, { language: language, body: body }, []])
    end

    def image(*args, alt: nil)
      _, src = arguments(args)
      emit_node([:image, { src: src, alt: alt }, []])
    end

    # Which icon may be said as a name (`icon warning`) or arrive as data
    # (`icon .severity`). Both name the same thing.
    def icon(*args)
      name, data = arguments(args)
      name ||= data
      use_icon(name.to_s.to_sym)
      emit_node([:icon, { name: name }, []])
    end

    def metric(*args, as: nil)
      name, label = arguments(args)
      value = subject.fetch(name)
      emit_node([:metric, { name: name, label: label_for(name, label),
                            value: value, kind: as || subject.format_for(name) }, []])
    end

    # The same shape as `table`, and for the same reason. A table declares its
    # columns and the rows come from the subject; a chart declares its series
    # and the points come from the subject. The gatherer is Chart.
    def chart(*args, over: nil, &block)
      name, caption = arguments(args)
      Chart.new(self, name, caption, over, block).render
    end

    # A filled series, stacked on the ones before it.
    def band(*args)
      name, label = arguments(args)
      register!(Chart, { kind: :band, name: name, label: label }, 'band')
    end

    # A series drawn over the bands rather than added to them. `from:` takes
    # its points from a different collection — the same modifier `each` uses,
    # for the same reason: this line is about something else.
    def line(*args, from: nil)
      name, label = arguments(args)
      register!(Chart, { kind: :line, name: name, label: label, from: from }, 'line')
    end

    # A horizontal reference — a threshold, a target, a deduction. It carries
    # a value rather than an attribute, and it is labelled where it sits
    # instead of in the key, because a threshold is read against the data.
    def level(*args)
      register!(Chart,
                { value: args.find { |a| a.is_a?(Numeric) }.to_f,
                  label: args.find { |a| a.is_a?(String) } },
                'level')
    end

    # --- Situation --------------------------------------------------------

    # The branches register, then the first true one renders. `otherwise` is
    # an ordinary word valid inside `choose`, so `else` is never a keyword and
    # nothing needs special parsing. The gatherer is Choose.
    def choose(&block)
      Choose.new(self, &block).render
    end

    def when(*args, &block)
      target = open_gatherer(Choose)
      raise Error, 'when belongs inside a choose' unless target

      # The transform sends the condition as a lambda, unevaluated — so this
      # guard can refuse a `when` outside a `choose` before the argument
      # runs, instead of reporting the argument's problem.
      condition = args.first
      target.add_branch(!!(condition&.call), block)
    end

    def otherwise(&block)
      target = open_gatherer(Choose)
      raise Error, 'otherwise belongs inside a choose' unless target

      target.add_branch(nil, block)
    end

    # --- Interaction ----------------------------------------------------

    def form(*args, to: nil, method: nil, target: nil, &block)
      name, = arguments(args)
      value, empty, children = about(name) { capture(&block) }
      emit_node([:form, { name: name, to: to, method: method, target: target }, prune(children, empty)])
      value
    end

    def group(*args, &block)
      name, legend = arguments(args)
      emit_node([:group, { name: name, legend: label_for(name, legend) }, capture(&block)])
    end

    # The heaviest inference in the vocabulary: four derivations from one word.
    def field(*args, type: nil, step: nil, required: nil)
      name, label = arguments(args)
      value = subject.fetch(name)
      emit_node([:field, { name: name, label: label_for(name, label),
                           value: value,
                           kind: type || Inference.input_type(value),
                           step: (step || Inference.step_for(value))&.to_s,
                           required: required }, []])
    end

    # `field` insists on a label, because data entry explains what it asks.
    # A search box does not; it names nothing and just sits there, so the
    # bare input is its own word rather than a field with its label omitted.
    def input(*args, type: nil, placeholder: nil)
      name, value = arguments(args)
      shown = value.nil? ? subject.fetch(name) : value
      emit_node([:input, { name: name, value: shown,
                           kind: type || Inference.input_type(shown),
                           placeholder: placeholder }, []])
    end

    # The multi-line sibling of `field` — the same label/value inference, a
    # different widget.
    def textarea(*args, rows: nil, required: nil)
      name, label = arguments(args)
      value = subject.fetch(name)
      emit_node([:textarea, { name: name, label: label_for(name, label),
                              value: value, rows: (rows || 4).to_s,
                              required: required }, []])
    end

    # What a form carries that is not said: the name and the value travel
    # with the submit without ever being seen. `hidden path, .value` names
    # both; `hidden path` reads the subject, like `field` reads it.
    def hidden(*args)
      name, value = arguments(args)
      shown = value.nil? ? subject.fetch(name) : value
      emit_node([:hidden, { name: name, value: shown }, []])
    end

    def checkbox(*args)
      name, label = arguments(args)
      value = subject.fetch(name)
      emit_node([:checkbox, { name: name, label: label_for(name, label), value: value }, []])
    end

    def choice(*args, &block)
      name, label = arguments(args)
      Choice.new(self, name, label, block).render
    end

    def option(*args)
      value, label = arguments(args)
      register!(Choice, { value: value, label: label }, 'option')
    end

    def button(*args, to: nil, type: nil, size: nil)
      variant, label = arguments(args)
      emit_node([:button, { variant: variant,
                            label: label || (variant && Inference.label(variant)),
                            to: to, type: type, size: size }, []])
    end
  end
end
