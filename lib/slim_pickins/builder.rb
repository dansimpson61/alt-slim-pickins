# frozen_string_literal: true

require 'cgi'
require_relative 'subject'
require_relative 'inference'
require_relative 'markdown'
require_relative 'charting'
require_relative 'icons'
require_relative 'generator'
require_relative 'components'

module SlimPickins
  # The runtime. A page evaluates into a tree of semantic nodes —
  # `[:word, attributes, children]` — and the Generator walks that tree to
  # produce HTML. The Builder's job is the evaluation: the subject chain, the
  # bindings, the gatherer stack, and the words themselves, each of which now
  # describes its node instead of emitting strings.
  #
  # Every word is a real defined method — never method_missing — so an
  # unknown word fails with a name, and the vocabulary is greppable.
  #
  # A useful property falls out of the transform: names compile to Symbols and
  # content compiles to Strings. So a word can tell a name from content by
  # type rather than by counting positions, and `button primary, "Run"`,
  # `button primary` and `button "Run"` all mean the obvious thing.
  class Builder
    WORDS = %i[page contents stylesheet meta script nav link footer aside
               section title each empty table column total
               grid list item card actions figure disclosure
               money percent number text note prose badge fact snippet
               time image icon metric chart band line level
               choose when otherwise
               form group field checkbox choice option button
               ].freeze

    def initialize(page, library = nil)
      @library = library
      @chain = Chain.new(page)
      @in_form = false
      @level = 2            # `title` infers its heading level from depth
      @empty_active = false # set while the named subject is an empty collection
      @bindings = {}        # `each holding` binds `holding` for reaching out
      @gatherers = []       # the components whose children are declarations
      @contents = nil       # the page's own nodes, while a layout renders
      @head_nodes = []      # words that belong in <head>, wherever they are said
      @icons_used = []      # so the sprite carries only the symbols a page uses
      define_app_words
    end

    # An app's words become real singleton methods, for the same reason the
    # built-ins are real methods: a call site should not be able to tell them
    # apart, and an unknown word should still fail with its own name.
    def define_app_words
      return unless @library

      extend @library.words if @library.words
      @library.partials.each_key do |word|
        define_singleton_method(word) do |*args, &block|
          render_partial(word, args, &block)
        end
      end
    end

    # Words are real methods, so an unknown word fails with its own name.
    # The only thing method_missing serves is a binding introduced by `each`,
    # which is dynamic by nature and cannot be a defined method.
    # Reaching out by name: `order.number` inside a nested loop, or
    # `pattern.title` at the top of a page. A binding from `each` wins, then
    # the subject chain — whose floor is the page, so locals and helpers are
    # reachable here for the same reason `.foo` reaches them.
    def method_missing(name, *args)
      if args.empty?
        # Wrapped, so `order.number` and `pattern.title` read the same whether
        # the thing behind them is a struct, a hash or a plain object.
        return Subject.new(@bindings[name], described_as: "this #{name}") if @bindings.key?(name)
        return Subject.new(subject.fetch(name), described_as: "this #{name}") if subject.has?(name)
      end

      raise Error, "there is no word `#{name}`"
    end

    def respond_to_missing?(name, include_private = false)
      @bindings.key?(name) || subject.has?(name) || super
    end

    def render(ruby, path)
      @nodes = []
      instance_eval(ruby, path, 1)
      @nodes
    end

    # `.foo` compiles to this.
    def subject = @chain.current

    # --- Document -------------------------------------------------------

    def page(*args, &block)
      name, title = name_and_content(args)
      heading = title || Inference.label(name)

      value, empty, body = about(name) { wrapped_in_layout(&block) }
      emit_node([:page, { heading: heading, head: @head_nodes, icons: @icons_used.dup },
                 prune(body, empty)])
      value
    end

    # These three say where they belong, not where they are written, which is
    # what lets a layout mention a stylesheet from inside the body.
    def stylesheet(*args)
      _, path = name_and_content(args)
      @head_nodes << [:stylesheet, { path: path }, []]
    end

    def meta(*args)
      name, value = name_and_content(args)
      @head_nodes << [:meta, { name: name, value: value }, []]
    end

    def script(*args, defer: false)
      _, path = name_and_content(args)
      emit_node([:script, { path: path, defer: defer }, []])
    end

    def nav(*args, &block)
      variant, = name_and_content(args)
      emit_node([:nav, { variant: variant }, capture(&block)])
    end

    def link(*args, to: nil)
      name, label = name_and_content(args)
      emit_node([:link, { name: name, label: label_for(name, label), to: to }, []])
    end

    def footer(*args, &block)
      _, body = name_and_content(args)
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
      name, heading = name_and_content(args)
      value, empty, children = about(name) { deeper { capture(&block) } }
      emit_node([:section, { name: name, heading: label_for(name, heading), level: @level },
                 prune(children, empty)])
      value
    end

    def title(*args)
      _, text = name_and_content(args)
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
      name, = name_and_content(args)
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

      _, message = name_and_content(args)
      emit_node([:empty, { message: message }, []])
    end

    # A table declares its columns; the rows come from the subject. The
    # gatherer is Table — see components.rb — this is the router's part.
    def table(*args, &block)
      name, caption = name_and_content(args)
      Table.new(self, name, caption, block).render
    end

    # The header is not resolved here. A column registers before any row
    # exists, so the only subject in scope is the one holding the collection —
    # and it is the *row* that knows what its own columns are called. The
    # table resolves it once the first row is in hand.
    def column(*args, as: nil)
      name, header = name_and_content(args)
      register!(Table, { name: name, header: header, as: as }, 'column')
    end

    def total(*args)
      name, label = name_and_content(args)
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
      variant, = name_and_content(args)
      emit_node([:grid, { variant: variant, columns: columns }, capture(&block)])
    end

    def list(*args, &block)
      variant, = name_and_content(args)
      emit_node([:list, { variant: variant }, capture(&block)])
    end

    def item(*args, &block)
      variant, body = name_and_content(args)
      emit_node([:item, { variant: variant, body: body }, capture(&block)])
    end

    def card(*args, &block)
      variant, = name_and_content(args)
      emit_node([:card, { variant: variant, id: card_id }, deeper { capture(&block) }])
    end

    def figure(*args, &block)
      _, caption = name_and_content(args)
      emit_node([:figure, { caption: caption }, capture(&block)])
    end

    def disclosure(*args, open: false, &block)
      _, summary = name_and_content(args)
      emit_node([:disclosure, { summary: summary, open: open }, capture(&block)])
    end

    # --- Content --------------------------------------------------------

    def note(*args)
      variant, body = name_and_content(args)
      emit_node([:note, { variant: variant, body: body }, []])
    end

    def prose(*args)
      notation, body = name_and_content(args)
      emit_node([:prose, { notation: notation, body: body }, []])
    end

    KNOWN_STATUSES = %i[ok pending neutral warning error blocker polish].freeze

    def badge(*args)
      variant, body = name_and_content(args)
      label = body || variant
      kind = variant || (KNOWN_STATUSES.include?(body.to_s.to_sym) ? body.to_s.to_sym : nil)
      emit_node([:badge, { variant: variant, kind: kind, label: label }, []])
    end

    def fact(*args)
      name, value = name_and_content(args)
      shown = value.nil? ? subject.fetch(name) : value
      emit_node([:fact, { name: name, label: label_for(name, nil),
                          value: shown, kind: format_of({ name: name, as: nil }) }, []])
    end

    def snippet(*args)
      language, body = name_and_content(args)
      emit_node([:snippet, { language: language, body: body }, []])
    end

    def time(*args)
      variant, moment = name_and_content(args)
      machine = moment.respond_to?(:iso8601) ? moment.iso8601 : moment.to_s
      emit_node([:time, { variant: variant, moment: moment, machine: machine }, []])
    end

    def image(*args, alt: nil)
      _, src = name_and_content(args)
      emit_node([:image, { src: src, alt: alt }, []])
    end

    # Which icon may be said as a name (`icon warning`) or arrive as data
    # (`icon .severity`). Both name the same thing.
    def icon(*args)
      name, data = name_and_content(args)
      name ||= data
      @icons_used << name.to_s.to_sym
      emit_node([:icon, { name: name }, []])
    end

    def metric(*args, as: nil)
      name, label = name_and_content(args)
      value = subject.fetch(name)
      emit_node([:metric, { name: name, label: label_for(name, label),
                            value: value, kind: as || subject.format_for(name) }, []])
    end

    # The same shape as `table`, and for the same reason. A table declares its
    # columns and the rows come from the subject; a chart declares its series
    # and the points come from the subject. The gatherer is Chart.
    def chart(*args, over: nil, &block)
      name, caption = name_and_content(args)
      Chart.new(self, name, caption, over, block).render
    end

    # A filled series, stacked on the ones before it.
    def band(*args)
      name, label = name_and_content(args)
      register!(Chart, { kind: :band, name: name, label: label }, 'band')
    end

    # A series drawn over the bands rather than added to them. `from:` takes
    # its points from a different collection — the same modifier `each` uses,
    # for the same reason: this line is about something else.
    def line(*args, from: nil)
      name, label = name_and_content(args)
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
      _, value = name_and_content(args)
      emit_node([:money, { value: value, precision: precision }, []])
    end

    def percent(*args, precision: 1)
      _, value = name_and_content(args)
      emit_node([:percent, { value: value, precision: precision }, []])
    end

    def number(*args, precision: 0)
      _, value = name_and_content(args)
      emit_node([:number, { value: value, precision: precision }, []])
    end

    def text(*args)
      _, body = name_and_content(args)
      emit_node([:text, { body: body }, []])
    end

    # --- Interaction ----------------------------------------------------

    def form(*args, to: nil, method: nil, &block)
      name, = name_and_content(args)
      was_in_form = @in_form
      @in_form = true
      value, empty, children = about(name) { capture(&block) }
      @in_form = was_in_form
      emit_node([:form, { name: name, to: to, method: method }, prune(children, empty)])
      value
    end

    def group(*args, &block)
      name, legend = name_and_content(args)
      emit_node([:group, { name: name, legend: label_for(name, legend), in_form: @in_form },
                 capture(&block)])
    end

    # The heaviest inference in the vocabulary: four derivations from one word.
    def field(*args, type: nil, step: nil, required: nil)
      name, label = name_and_content(args)
      value = subject.fetch(name)
      emit_node([:field, { name: name, label: label_for(name, label),
                           value: value,
                           kind: type || Inference.input_type(value),
                           step: (step || Inference.step_for(value))&.to_s,
                           required: required }, []])
    end

    def checkbox(*args)
      name, label = name_and_content(args)
      value = subject.fetch(name)
      emit_node([:checkbox, { name: name, label: label_for(name, label), value: value }, []])
    end

    def choice(*args, &block)
      name, label = name_and_content(args)
      Choice.new(self, name, label, block).render
    end

    def option(*args)
      value, label = name_and_content(args)
      register!(Choice, { value: value, label: label }, 'option')
    end

    def button(*args, to: nil, type: nil)
      variant, label = name_and_content(args)
      emit_node([:button, { variant: variant,
                            label: label || (variant && Inference.label(variant)),
                            to: to, type: type, in_form: @in_form }, []])
    end

    def actions(&block)
      emit_node([:actions, {}, capture(&block)])
    end

    private

    # --- the node assembly ------------------------------------------------

    # Every word hands its node to the current collection — the body's, or the
    # head's for the words that belong there.
    def emit_node(node) = @nodes << node

    def capture(&block)
      was = @nodes
      @nodes = []
      nest(&block)
      @nodes
    ensure
      @nodes = was
    end

    # The paper's "conditionally pruning an AST": an empty collection keeps
    # only the `empty` node that names it; anything else keeps everything but.
    def prune(children, empty)
      empty ? children.select { |n| n.first == :empty } : children.reject { |n| n.first == :empty }
    end

    # --- presentation helpers ---------------------------------------------

    # `as:` said in the page, else the app's own answer, else what the value's
    # shape can tell us — the same three levels as labels, owned by the same
    # three people.
    def format_of(column, row = nil)
      column[:as] || Subject.new(row || subject.object).format_for(column[:name])
    end

    # The same three levels as everywhere else — the page said it, or the app
    # said it, or English — except that here "the app" is the row rather than
    # whatever holds the collection. `format_of` had always asked the row;
    # labels asked the enclosing subject, and a table of Years read its headers
    # off the Projection that merely held them: "Irmaa applied cost".
    def label_of(column, row = nil)
      column[:header] ||
        (row && Subject.new(row).label_for(column[:name])) ||
        subject.label_for(column[:name]) ||
        Inference.label(column[:name])
    end

    def alignment_of(column, sample)
      kind = format_of(column, sample) || Inference.presentation(column[:sample])
      %i[money percent number].include?(kind) ? 'column--numeric' : nil
    end

    # `each holding` looks for `holdings` on the subject. When the subject is
    # itself the collection — as it is under `section accounts`, which is what
    # lets `empty` know what is empty — it iterates that instead.
    def collection_for(name)
      plural = Inference.plural(name).to_sym
      return subject.fetch(plural) if subject.respond_to?(plural)
      return subject.object if Inference.collection?(subject.object)

      raise Error, "#{subject.describe} has no #{plural} to go through"
    end

    # `card` infers its DOM id from the subject, so no page writes `id .id`.
    def card_id
      return nil unless subject.has?(:id)

      "#{subject.noun}-#{subject.fetch(:id)}"
    end

    # --- the gathering mechanism, written once -----------------------------
    #
    # The registering words route through the stack of open gatherers — the
    # one collect-and-restore the lore counted four times. A nested gatherer
    # pushes and pops; the outer one's collection is untouched, which is the
    # save-and-restore each word used to do by hand (and `choice` never did).
    def register!(kind, item, what)
      target = open_gatherer(kind)
      raise Error, "#{what} belongs inside #{kind::INSIDE}" unless target

      target.collect(item)
    end

    def open_gatherer(kind)
      @gatherers.reverse.find { |g| g.is_a?(kind) }
    end

    def with_gatherer(gatherer)
      @gatherers.push(gatherer)
      yield
    ensure
      @gatherers.pop
    end

    def chain = @chain

    def deeper
      @level += 1
      yield
    ensure
      @level -= 1
    end

    # The three shapes of a class name, built in exactly one place — the
    # Generator's — so the runtime and the hatch share the truth.
    def token(word, variant = nil)
      Generator.token(word, variant)
    end

    # Names are Symbols, content is anything else. This is why argument order
    # never has to be counted.
    def name_and_content(args)
      [args.find { |a| a.is_a?(Symbol) }, args.find { |a| !a.is_a?(Symbol) }]
    end

    # A word that names a subject shifts the chain for its children. A word
    # that names nothing leaves the chain alone, which is what makes
    # `page scenario` followed by a bare `form` mean the obvious thing.
    # Returns [value, empty?, children] so the caller can prune by the
    # situation.
    def about(name, &block)
      return [nil, false, yield] if name.nil?

      # A word that names no subject leaves the chain alone. A word that names
      # one that is not there is an error — skipping quietly would report the
      # missing attribute later, on a line that is not the cause.
      value = subject.fetch(name)
      empty = Inference.collection?(value) && Inference.nothing_in?(value)
      was = @empty_active
      @empty_active = empty
      [value, empty, @chain.with(value, described_as: "this #{name}", &block)]
    ensure
      @empty_active = was unless was.nil?
    end

    # Precedence, each level owned by whoever knows most: the page knows this
    # instance, the app knows its domain, the language knows only English.
    def label_for(name, given)
      given || subject.label_for(name) || Inference.label(name)
    end

    def nest(&block)
      instance_eval(&block) if block
    end

    # The layout is chrome inside the page, so `page` still owns the document
    # and the layout never repeats it.
    def wrapped_in_layout(&block)
      return capture(&block) unless @library&.layout

      @contents = capture(&block)
      nodes = capture { instance_eval(Transform.call(@library.layout, path: 'layout.sp'), 'layout.sp', 1) }
      raise Error, 'this layout never says `contents`' if @contents

      nodes
    end

    # A partial takes the current subject, like any word that names none, and
    # shifts it when it names one — the same rule as `section`.
    def render_partial(word, args, &block)
      name, = name_and_content(args)
      source = @library.source_for(word)
      ruby = Transform.call(source, path: "partials/#{word}.sp")
      value, empty, children = about(name) { capture { instance_eval(ruby, "partials/#{word}.sp", 1) } }
      @nodes.concat(prune(children, empty))
      value
    end

    # --- the escape hatch -------------------------------------------------
    #
    # The language has no `div`, deliberately. When an app needs something the
    # vocabulary has no word for — a `<video>`, a third-party embed — it adds
    # a *word*, in Ruby, through `Library.new(words: SomeModule)`. That keeps
    # the founding claim intact: extending the language adds vocabulary, never
    # syntax, and a call site still cannot tell where a word came from.
    #
    # These five are the whole surface such a word may use. Everything else
    # stays private, so the hatch cannot quietly become an API.
    public

    public :token # class names, in the four shapes
    def html(string) = emit_node([:raw, {}, [string]]) # trusted markup — you escape it
    def tag(name, attributes = {}, &block) = emit_node([:tag, { name: name, attrs: attributes }, capture(&block)])
    def children(&block) = capture(&block) # this word's children, as nodes
    def arguments(args) = name_and_content(args)
  end
end
