# frozen_string_literal: true

require_relative 'contracts'

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

    def page(*args, &block)
      name, title = arguments(args)
      heading = title || Inference.label(name)

      value, empty, body = about(name) { wrapped_in_layout(&block) }
      emit_node([:page, { heading: heading, head: @head_nodes, icons: @icons_used.dup },
                 prune(body, empty)])
      value
    end

    # These three say where they belong, not where they are written, which is
    # what lets a layout mention a stylesheet from inside the body.
    def stylesheet(*args)
      _, path = arguments(args)
      @head_nodes << [:stylesheet, { path: path }, []]
    end

    def meta(*args)
      name, value = arguments(args)
      @head_nodes << [:meta, { name: name, value: value }, []]
    end

    def script(*args, defer: false)
      _, path = arguments(args)
      emit_node([:script, { path: path, defer: defer }, []])
    end

    def nav(*args, &block)
      variant, = arguments(args)
      emit_node([:nav, { variant: variant }, capture(&block)])
    end

    def link(*args, to: nil)
      name, label = arguments(args)
      emit_node([:link, { name: name, label: label_for(name, label), to: to }, []])
    end

    def footer(*args, &block)
      _, body = arguments(args)
      emit_node([:footer, { body: body }, capture(&block)])
    end

    # Marks where the page's own nodes go. Only a layout has one.
    def contents
      raise Error, '`contents` belongs in a layout' unless @contents

      nodes = @contents
      @contents = nil
      @nodes.concat(nodes)
    end

    # --- Structure ------------------------------------------------------

    def section(*args, &block)
      name, heading = arguments(args)
      value, empty, children = about(name) { deeper { capture(&block) } }
      emit_node([:section, { name: name, heading: label_for(name, heading), level: @level },
                 prune(children, empty)])
      value
    end

    def title(*args)
      _, text = arguments(args)
      emit_node([:title, { text: text, level: @level }, []])
    end

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
        @bindings[name] = item
        @chain.with(item, described_as: "this #{name}") { capture(&block) }
      end
      @bindings.delete(name)
      emit_node([:each, { name: name }, collected])
    end

    # Not a conditional. It names the situation, and the enclosing word
    # already knows what "empty" refers to — the enclosing word keeps the node
    # when the collection is empty and prunes its siblings.
    def empty(*args)
      return unless @empty_active

      _, message = arguments(args)
      emit_node([:empty, { message: message }, []])
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

    def aside(&block)
      emit_node([:aside, {}, capture(&block)])
    end

    # `columns:` is a wish, not a decree. An exact fractional track — a plain
    # `calc(100% / n)` — scales with its container and so can never reflow,
    # which quietly made every `columns:` grid non-responsive. Flooring it at
    # `--track-min` gives n columns where they fit and fewer where they do not.
    def grid(*args, columns: nil, &block)
      variant, = arguments(args)
      emit_node([:grid, { variant: variant, columns: columns }, capture(&block)])
    end

    def list(*args, &block)
      variant, = arguments(args)
      emit_node([:list, { variant: variant }, capture(&block)])
    end

    def item(*args, &block)
      variant, body = arguments(args)
      emit_node([:item, { variant: variant, body: body }, capture(&block)])
    end

    def card(*args, &block)
      variant, = arguments(args)
      emit_node([:card, { variant: variant, id: card_id }, deeper { capture(&block) }])
    end

    def figure(*args, &block)
      _, caption = arguments(args)
      emit_node([:figure, { caption: caption }, capture(&block)])
    end

    def disclosure(*args, open: false, &block)
      _, summary = arguments(args)
      emit_node([:disclosure, { summary: summary, open: open }, capture(&block)])
    end

    # --- Content --------------------------------------------------------

    def note(*args)
      variant, body = arguments(args)
      tag(:p, { class: token(:note, variant) }, [body])
    end

    def prose(*args)
      notation, body = arguments(args)
      emit_node([:prose, { notation: notation, body: body }, []])
    end

    KNOWN_STATUSES = %i[ok pending neutral warning error blocker polish].freeze

    def badge(*args)
      variant, body = arguments(args)
      label = body || variant
      kind = variant || (KNOWN_STATUSES.include?(body.to_s.to_sym) ? body.to_s.to_sym : nil)
      tag(:span, { class: token(:badge, kind) }, [label])
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

    def time(*args)
      variant, moment = arguments(args)
      machine = moment.respond_to?(:iso8601) ? moment.iso8601 : moment.to_s
      emit_node([:time, { variant: variant, moment: moment, machine: machine }, []])
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
      @icons_used << name.to_s.to_sym
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

    def money(*args, precision: 0)
      _, value = arguments(args)
      emit_node([:money, { value: value, precision: precision }, []])
    end

    def percent(*args, precision: 1)
      _, value = arguments(args)
      emit_node([:percent, { value: value, precision: precision }, []])
    end

    def number(*args, precision: 0)
      _, value = arguments(args)
      emit_node([:number, { value: value, precision: precision }, []])
    end

    def text(*args)
      _, body = arguments(args)
      tag(:p, {}, [body])
    end

    # --- Interaction ----------------------------------------------------

    def form(*args, to: nil, method: nil, &block)
      name, = arguments(args)
      was_in_form = @in_form
      @in_form = true
      value, empty, children = about(name) { capture(&block) }
      @in_form = was_in_form
      emit_node([:form, { name: name, to: to, method: method }, prune(children, empty)])
      value
    end

    def group(*args, &block)
      name, legend = arguments(args)
      emit_node([:group, { name: name, legend: label_for(name, legend), in_form: @in_form },
                 capture(&block)])
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

    def button(*args, to: nil, type: nil)
      variant, label = arguments(args)
      emit_node([:button, { variant: variant,
                            label: label || (variant && Inference.label(variant)),
                            to: to, type: type, in_form: @in_form }, []])
    end

    def actions(&block)
      emit_node([:actions, {}, capture(&block)])
    end
  end
end
