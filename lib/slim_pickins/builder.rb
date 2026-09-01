# frozen_string_literal: true

require 'cgi'
require_relative 'subject'
require_relative 'inference'
require_relative 'markdown'
require_relative 'charting'
require_relative 'icons'

module SlimPickins
  # The runtime. Every word is a real defined method — never method_missing —
  # so an unknown word fails with a name, and the vocabulary is greppable.
  #
  # Phase 0 scope: page, form, group, field, check, select, option, button,
  # actions, disclosure.
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
               form group field check select option button
               ].freeze

    def initialize(page, library = nil)
      @library = library
      @out = +''
      @chain = Chain.new(page)
      @in_form = false
      @selected = nil
      @level = 2          # `title` infers its heading level from depth
      @suppressed = false  # set when a subject is an empty collection
      @bindings = {}       # `each holding` binds `holding` for reaching out
      @columns = nil       # non-nil only while a table is collecting columns
      @series = nil        # non-nil only while a chart is collecting series
      @levels = nil
      @branches = nil      # non-nil only while a `choose` is collecting branches
      @contents = nil      # the page's own children, while a layout renders
      @head = +''          # words that belong in <head>, wherever they are said
      @icons_used = []     # so the sprite carries only the symbols a page uses
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
      instance_eval(ruby, path, 1)
      @out
    end

    # `.foo` compiles to this.
    def subject = @chain.current


    # --- Document -------------------------------------------------------

    def page(*args, &block)
      name, title = name_and_content(args)
      heading = title || Inference.label(name)

      body = capture { about(name) { wrapped_in_layout(&block) } }

      @out << '<!DOCTYPE html>'
      open(:html, lang: 'en')
      open(:head)
      void(:meta, charset: 'utf-8')
      void(:meta, name: 'viewport', content: 'width=device-width, initial-scale=1')
      text_tag(:title, heading)
      @out << @head
      close(:head)
      open(:body)
      @out << Icons.sprite(@icons_used)
      text_tag(:h1, heading)
      @out << body
      close(:body)
      close(:html)
    end

    # These three say where they belong, not where they are written, which is
    # what lets a layout mention a stylesheet from inside the body.
    def stylesheet(*args)
      _, path = name_and_content(args)
      @head << %(<link rel="stylesheet" href="#{CGI.escapeHTML(path)}">)
    end

    def meta(*args)
      name, value = name_and_content(args)
      @head << %(<meta name="#{name}" content="#{CGI.escapeHTML(value.to_s)}">)
    end

    def script(*args, defer: false)
      _, path = name_and_content(args)
      @deferred = +'' unless defined?(@deferred)
      emit(%(<script src="#{CGI.escapeHTML(path)}"#{defer ? ' defer' : ''}></script>))
    end

    def nav(*args, &block)
      variant, = name_and_content(args)
      open(:nav, class: token(:nav, variant),
                 'aria-label': variant ? variant.to_s.capitalize : 'Main')
      nest(&block)
      close(:nav)
    end

    def link(*args, to: nil)
      name, label = name_and_content(args)
      text_tag(:a, label_for(name, label), href: to&.to_s || "/#{name}")
    end

    def footer(*args, &block)
      _, body = name_and_content(args)
      open(:footer, class: token(:footer))
      body ? (@out << CGI.escapeHTML(body.to_s)) : nest(&block)
      close(:footer)
    end

    # Marks where the page's own sentences go. Only a layout has one.
    def contents
      raise Error, '`contents` belongs in a layout' unless @contents

      block = @contents
      @contents = nil
      nest(&block)
    end

    # --- Structure ------------------------------------------------------

    def section(*args, &block)
      name, heading = name_and_content(args)
      open(:section, class: token(:section, name))
      text_tag(:"h#{@level}", label_for(name, heading), class: 'section-title')
      deeper { about(name) { nest(&block) } }
      close(:section)
    end

    def title(*args)
      _, text = name_and_content(args)
      text_tag(:"h#{@level}", text, class: token(:title))
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
      items.each do |item|
        @bindings[name] = item
        @chain.with(item, described_as: "this #{name}") { nest(&block) }
      end
      @bindings.delete(name)
    end

    # Not a conditional. It names the situation, and the enclosing word
    # already knows what "empty" refers to.
    def empty(*args)
      _, message = name_and_content(args)
      return unless @suppressed

      unsuppressed { text_tag(:p, message, class: token(:empty)) }
    end

    # A table declares its columns; the rows come from the subject. `column`
    # does not render when it is read — it registers, so the header can be
    # written before the first row exists.
    def table(*args, &block)
      name, caption = name_and_content(args)
      rows = name ? subject.fetch(name) : subject.object
      # Saved, not just cleared. A `when` may hold another table, and `choose`
      # runs the chosen branch while this one is still collecting — so nulling
      # the collection on the way out took the outer table's columns with it,
      # and it crashed in Ruby rather than in the language.
      was = @columns
      @columns = []
      nest(&block)
      columns = @columns
      @columns = was

      open(:table, class: token(:table, name))
      text_tag(:caption, caption) if caption
      sample = rows.first
      columns.each do |c|
        c[:sample] = sample && Subject.new(sample).fetch(c[:name])
        c[:header] = label_of(c, sample)
      end

      open(:thead)
      open(:tr)
      columns.each do |c|
        next if c[:total]

        text_tag(:th, c[:header], class: alignment_of(c, sample))
      end
      close(:tr)
      close(:thead)
      open(:tbody)
      rows.each do |row|
        @chain.with(row) do
          open(:tr)
          columns.each do |c|
            next if c[:total]

            text_tag(:td, present(subject.fetch(c[:name]), format_of(c)), class: alignment_of(c, sample))
          end
          close(:tr)
        end
      end
      close(:tbody)
      footer_row(columns, rows, sample)
      close(:table)
    end

    # The header is not resolved here. A column registers before any row
    # exists, so the only subject in scope is the one holding the collection —
    # and it is the *row* that knows what its own columns are called. `table`
    # resolves it once the first row is in hand.
    def column(*args, as: nil)
      name, header = name_and_content(args)
      registering!(:column)
      @columns << { name: name, header: header, as: as }
    end

    def total(*args)
      name, label = name_and_content(args)
      registering!(:total)
      @columns << { name: name, header: label, as: nil, total: true }
    end

    def aside(&block)
      open(:aside, class: token(:aside))
      nest(&block)
      close(:aside)
    end

    # `columns:` is a wish, not a decree. An exact fractional track — a plain
    # `calc(100% / n)` — scales with its container and so can never reflow,
    # which quietly made every `columns:` grid non-responsive. Flooring it at
    # `--track-min` gives n columns where they fit and fewer where they do not.
    def grid(*args, columns: nil, &block)
      variant, = name_and_content(args)
      track = columns && "max(var(--track-min), calc((100% - #{columns - 1} * var(--gap)) / #{columns}))"
      open(:div, class: token(:grid, variant), style: track && "--track: #{track}")
      nest(&block)
      close(:div)
    end

    def list(*args, &block)
      variant, = name_and_content(args)
      open(:ul, class: token(:list, variant))
      nest(&block)
      close(:ul)
    end

    def item(*args, &block)
      variant, body = name_and_content(args)
      open(:li, class: token(:item, variant))
      body ? emit(CGI.escapeHTML(body.to_s)) : nest(&block)
      close(:li)
    end

    def card(*args, &block)
      variant, = name_and_content(args)
      open(:article, class: token(:card, variant),
                     id: card_id)
      deeper { nest(&block) }
      close(:article)
    end

    def figure(*args, &block)
      _, caption = name_and_content(args)
      open(:figure, class: token(:figure))
      nest(&block)
      text_tag(:figcaption, caption) if caption
      close(:figure)
    end

    # --- Content --------------------------------------------------------

    def note(*args)
      variant, body = name_and_content(args)
      text_tag(:p, body, class: token(:note, variant))
    end

    def prose(*args)
      notation, body = name_and_content(args)
      html = notation == :plain ? Markdown.plain(body) : Markdown.render(body)
      emit(%(<div class="#{token(:prose)}">#{html}</div>))
    end

    def badge(*args)
      variant, body = name_and_content(args)
      label = body || variant
      kind = variant || (KNOWN_STATUSES.include?(body.to_s.to_sym) ? body.to_s.to_sym : nil)
      text_tag(:span, label, class: token(:badge, kind))
    end

    KNOWN_STATUSES = %i[ok pending neutral warning error blocker polish].freeze

    def fact(*args)
      name, value = name_and_content(args)
      shown = value.nil? ? subject.fetch(name) : value
      open(:dl, class: token(:fact))
      text_tag(:dt, label_for(name, nil))
      text_tag(:dd, present(shown, format_of({ name: name, as: nil })))
      close(:dl)
    end

    def snippet(*args)
      language, body = name_and_content(args)
      open(:pre, class: token(:snippet, language))
      text_tag(:code, body)
      close(:pre)
      text_tag(:button, 'Copy', type: 'button', class: 'snippet-copy')
    end

    def time(*args)
      variant, moment = name_and_content(args)
      machine = moment.respond_to?(:iso8601) ? moment.iso8601 : moment.to_s
      text_tag(:time, Inference.moment(moment, variant), datetime: machine)
    end

    def image(*args, alt: nil)
      _, src = name_and_content(args)
      void(:img, src: src.to_s, alt: alt.to_s, loading: 'lazy')
    end

    # Which icon may be said as a name (`icon warning`) or arrive as data
    # (`icon .severity`). Both name the same thing.
    def icon(*args)
      name, data = name_and_content(args)
      name ||= data
      @icons_used << name.to_s.to_sym
      emit(%(<svg class="icon icon--#{name}" aria-hidden="true">) +
           %(<use href="#icon-#{name}"></use></svg>))
    end

    def metric(*args, as: nil)
      name, label = name_and_content(args)
      value = subject.fetch(name)
      open(:div, class: token(:metric))
      text_tag(:h3, label_for(name, label), class: 'metric-label')
      text_tag(:div, present(value, as || subject.format_for(name)), class: 'metric-value')
      close(:div)
    end

    # The same shape as `table`, and for the same reason. A table declares its
    # columns and the rows come from the subject; a chart declares its series
    # and the points come from the subject. `band`, `line` and `level` register
    # rather than render, so the scale can be worked out before anything is
    # drawn — exactly how `column` waits for the first row.
    #
    # The x axis is the collection's name in the singular: `chart years` reads
    # each row's `year`. `over:` says it when that is not so.
    def chart(*args, over: nil, &block)
      name, caption = name_and_content(args)
      rows = name ? subject.fetch(name) : subject.object
      rows = rows.to_a

      # Saved, not just cleared — see `table` for why.
      was_series = @series
      was_levels = @levels
      @series = []
      @levels = []
      nest(&block)
      series = @series
      levels = @levels
      @series = was_series
      @levels = was_levels

      # A series with nothing in it is not a series. roth's do-nothing line
      # takes `from:` a baseline that does not exist until something is
      # converted, and an empty one still drew an empty path and claimed a
      # place in the key.
      drawn = series.map { |s| resolve(s, rows) }.reject { |s| s[:points].empty? }

      emit(Charting.render(series: drawn,
                           levels: levels,
                           across: across(rows, over || Inference.singular(name)),
                           caption: caption))
    end

    # A filled series, stacked on the ones before it.
    def band(*args) = register_series(:band, args)

    # A series drawn over the bands rather than added to them. `from:` takes
    # its points from a different collection — the same modifier `each` uses,
    # for the same reason: this line is about something else.
    def line(*args, from: nil) = register_series(:line, args, from)

    # A horizontal reference — a threshold, a target, a deduction. It carries
    # a value rather than an attribute, and it is labelled where it sits
    # instead of in the key, because a threshold is read against the data.
    def level(*args)
      charting!(:level)
      @levels << { value: args.find { |a| a.is_a?(Numeric)}.to_f,
                   label: args.find { |a| a.is_a?(String) } }
    end

    # --- Situation --------------------------------------------------------

    # The branches register, then the first true one renders. `otherwise` is
    # an ordinary word valid inside `choose`, so `else` is never a keyword and
    # nothing needs special parsing.
    def choose(&block)
      was = @branches
      @branches = []
      nest(&block)
      chosen = @branches.find { |c, _| c } || @branches.find { |c, _| c.nil? }
      @branches = was
      nest(&chosen.last) if chosen
    end

    def when(*args, &block)
      branching!(:when)
      _, condition = name_and_content(args)
      @branches << [!!condition, block]
    end

    def otherwise(&block)
      branching!(:otherwise)
      @branches << [nil, block]
    end


    def money(*args, precision: 0)
      _, value = name_and_content(args)
      amount(value, :money, precision)
    end

    def percent(*args, precision: 1)
      _, value = name_and_content(args)
      amount(value, :percent, precision)
    end

    def number(*args, precision: 0)
      _, value = name_and_content(args)
      amount(value, :number, precision)
    end

    def text(*args)
      _, body = name_and_content(args)
      text_tag(:p, body)
    end

    # --- Interaction ----------------------------------------------------

    def form(*args, to: nil, method: nil, &block)
      name, = name_and_content(args)
      open(:form, id: name&.to_s, action: to&.to_s, method: (method || :post).to_s)
      @in_form = true
      about(name) { nest(&block) }
      @in_form = false
      close(:form)
    end

    def group(*args, &block)
      name, legend = name_and_content(args)
      label = label_for(name, legend)
      if @in_form
        open(:fieldset, class: token(:group, name))
        text_tag(:legend, label)
        nest(&block)
        close(:fieldset)
      else
        open(:div, class: token(:group))
        text_tag(:h2, label)
        nest(&block)
        close(:div)
      end
    end

    # The heaviest inference in the vocabulary: four derivations from one word.
    def field(*args, type: nil, step: nil, required: nil)
      name, label = name_and_content(args)
      value = subject.fetch(name)
      kind = type || Inference.input_type(value)

      open(:div, class: token(:field))
      text_tag(:label, label_for(name, label), for: name.to_s)
      void(:input,
            id: name.to_s,
            name: name.to_s,
            type: kind.to_s,
            value: value&.to_s,
            step: (step || Inference.step_for(value))&.to_s,
            required: required ? 'required' : nil)
      close(:div)
    end

    def check(*args)
      name, label = name_and_content(args)
      value = subject.fetch(name)
      open(:div, class: token(:field, :check))
      open(:label, for: name.to_s)
      void(:input, id: name.to_s, name: name.to_s, type: 'checkbox',
                    checked: value ? 'checked' : nil)
      @out << CGI.escapeHTML(label_for(name, label))
      close(:label)
      close(:div)
    end

    def select(*args, &block)
      name, label = name_and_content(args)
      @selected = subject.fetch(name)
      open(:div, class: token(:field, :select))
      text_tag(:label, label_for(name, label), for: name.to_s)
      open(:select, id: name.to_s, name: name.to_s)
      nest(&block)
      close(:select)
      close(:div)
      @selected = nil
    end

    def option(*args)
      value, label = name_and_content(args)
      text_tag(:option, label || Inference.label(value),
               value: value.to_s,
               selected: (@selected.to_s == value.to_s ? 'selected' : nil))
    end

    def button(*args, to: nil, type: nil)
      variant, label = name_and_content(args)
      text_tag(:button,
               label || (variant && Inference.label(variant)),
               type: (type || (@in_form ? :submit : :button)).to_s,
               formaction: to&.to_s,
               class: token(:button, variant))
    end

    def actions(&block)
      open(:div, class: token(:actions))
      nest(&block)
      close(:div)
    end

    def disclosure(*args, open: false, &block)
      _, summary = name_and_content(args)
      open_tag(:details, open ? { open: 'open' } : {})
      text_tag(:summary, summary)
      nest(&block)
      close(:details)
    end

    private

    # --- Presentation helpers -------------------------------------------

    # `as:` said in the page, else what the value's shape can tell us. A
    # number is right-aligned for free; that it is *money* is a domain fact,
    # so it has to be said.
    def present(value, as)
      kind = as || Inference.presentation(value)
      case kind
      when :money   then Inference.money(value)
      when :percent then Inference.percent(value)
      when :number  then Inference.number(value)
      else
        value.respond_to?(:strftime) ? Inference.moment(value, nil) : value.to_s
      end
    end

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

    def amount(value, kind, precision)
      body = case kind
             when :money   then Inference.money(value, precision: precision)
             when :percent then Inference.percent(value, precision: precision)
             else               Inference.number(value, precision: precision)
             end
      classes = token(kind, ('negative' if value.negative?))
      text_tag(:span, body, class: classes)
    end

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

    # `each holding` looks for `holdings` on the subject. When the subject is
    # itself the collection — as it is under `section accounts`, which is what
    # lets `empty` know what is empty — it iterates that instead.
    def collection_for(name)
      plural = Inference.plural(name).to_sym
      return subject.fetch(plural) if subject.respond_to?(plural)
      return subject.object if Inference.collection?(subject.object)

      raise Error, "#{subject.describe} has no #{plural} to go through"
    end

    def branching!(word)
      return if @branches

      raise Error, "#{word} belongs inside a choose"
    end

    # `card` infers its DOM id from the subject, so no page writes `id .id`.
    def card_id
      return nil unless subject.has?(:id)

      "#{subject.noun}-#{subject.fetch(:id)}"
    end

    def registering!(word)
      return if @columns

      raise Error, "#{word} belongs inside a table"
    end

    def charting!(word)
      return if @series

      raise Error, "#{word} belongs inside a chart"
    end

    def register_series(kind, args, from = nil)
      charting!(kind)
      name, label = name_and_content(args)
      @series << { kind: kind, name: name, label: label, from: from }
    end

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

    def deeper
      @level += 1
      yield
    ensure
      @level -= 1
    end

    def unsuppressed
      was = @suppressed
      @suppressed = false
      yield
    ensure
      @suppressed = was
    end

    # The three shapes of a class name, and the only place they are built.
    # `.word`, `.word--variant`, `.word-part` — derived from the grammar, so a
    # reader who knows the language already knows the stylesheet.
    def token(word, variant = nil)
      [word.to_s, variant && "#{word}--#{variant}"].compact.join(' ')
    end

    # Names are Symbols, content is anything else. This is why argument order
    # never has to be counted.
    def name_and_content(args)
      [args.find { |a| a.is_a?(Symbol) }, args.find { |a| !a.is_a?(Symbol) }]
    end

    # A word that names a subject shifts the chain for its children. A word
    # that names nothing leaves the chain alone, which is what makes
    # `page scenario` followed by a bare `form` mean the obvious thing.
    def about(name, &block)
      return yield if name.nil?

      # A word that names no subject leaves the chain alone. A word that names
      # one that is not there is an error — skipping quietly would report the
      # missing attribute later, on a line that is not the cause.
      value = subject.fetch(name)
      was = @suppressed
      # An empty collection suppresses everything except `empty`, which is how
      # `empty` names a situation instead of writing a branch.
      @suppressed = Inference.collection?(value) && Inference.nothing_in?(value)
      @chain.with(value, described_as: "this #{name}", &block)
    ensure
      @suppressed = was unless was.nil?
    end

    # Precedence, each level owned by whoever knows most: the page knows this
    # instance, the app knows its domain, the language knows only English.
    def label_for(name, given)
      given || subject.label_for(name) || Inference.label(name)
    end

    def nest(&block)
      instance_eval(&block) if block
    end

    def capture
      was = @out
      @out = +''
      yield
      @out
    ensure
      @out = was
    end

    # The layout is chrome inside the page, so `page` still owns the document
    # and the layout never repeats it.
    def wrapped_in_layout(&block)
      return nest(&block) unless @library&.layout

      @contents = block
      instance_eval(Transform.call(@library.layout, path: 'layout.sp'), 'layout.sp', 1)
      raise Error, 'this layout never says `contents`' if @contents
    end

    # A partial takes the current subject, like any word that names none, and
    # shifts it when it names one — the same rule as `section`.
    def render_partial(word, args, &block)
      name, = name_and_content(args)
      source = @library.source_for(word)
      ruby = Transform.call(source, path: "partials/#{word}.sp")
      about(name) do
        was = @contents
        @contents = block
        instance_eval(ruby, "partials/#{word}.sp", 1)
        @contents = was
      end
    end

    # --- HTML -----------------------------------------------------------

    def attrs(pairs)
      pairs.reject { |_, v| v.nil? || v == '' }
           .map { |k, v| %( #{k}="#{CGI.escapeHTML(v.to_s)}") }.join
    end

    def open(tag, **pairs) = emit("<#{tag}#{attrs(pairs)}>")
    def open_tag(tag, pairs) = emit("<#{tag}#{attrs(pairs)}>")
    def close(tag) = emit("</#{tag}>")
    def void(tag, **pairs) = emit("<#{tag}#{attrs(pairs)}>")

    def text_tag(tag, text, **pairs)
      emit("<#{tag}#{attrs(pairs)}>#{CGI.escapeHTML(text.to_s)}</#{tag}>")
    end

    def emit(html)
      @out << html unless @suppressed
      @out
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

    public :token                            # class names, in the four shapes
    def html(string) = emit(string)          # trusted markup — you escape it
    def children(&block) = nest(&block)      # render this word's children
    def escape(text) = CGI.escapeHTML(text.to_s)
    def arguments(args) = name_and_content(args)
  end
end
