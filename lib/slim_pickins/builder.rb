# frozen_string_literal: true

require 'cgi'
require_relative 'subject'
require_relative 'inference'

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
    WORDS = %i[page contents stylesheet meta script nav link footer
               section title each empty table column total
               money percent number text
               form group field check select option button actions
               disclosure].freeze

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
      @contents = nil      # the page's own children, while a layout renders
      @head = +''          # words that belong in <head>, wherever they are said
      define_app_words
    end

    # An app's words become real singleton methods, for the same reason the
    # built-ins are real methods: a call site should not be able to tell them
    # apart, and an unknown word should still fail with its own name.
    def define_app_words
      return unless @library

      @library.partials.each_key do |word|
        define_singleton_method(word) do |*args, &block|
          render_partial(word, args, &block)
        end
      end
    end

    # Words are real methods, so an unknown word fails with its own name.
    # The only thing method_missing serves is a binding introduced by `each`,
    # which is dynamic by nature and cannot be a defined method.
    def method_missing(name, *args)
      return @bindings[name] if args.empty? && @bindings.key?(name)

      raise Error, "there is no word `#{name}`"
    end

    def respond_to_missing?(name, include_private = false)
      @bindings.key?(name) || super
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
      open(:nav, class: ['nav', variant && "nav--#{variant}"].compact.join(' '),
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
      open(:footer)
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
      open(:section, class: name && "section section--#{name}")
      text_tag(:"h#{@level}", label_for(name, heading))
      deeper { about(name) { nest(&block) } }
      close(:section)
    end

    def title(*args)
      _, text = name_and_content(args)
      text_tag(:"h#{@level}", text)
    end

    # The loop is written once, here, and never in a page.
    def each(*args, from: nil, &block)
      name, = name_and_content(args)
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

      unsuppressed { text_tag(:p, message, class: 'empty') }
    end

    # A table declares its columns; the rows come from the subject. `column`
    # does not render when it is read — it registers, so the header can be
    # written before the first row exists.
    def table(*args, &block)
      name, caption = name_and_content(args)
      rows = name ? subject.fetch(name) : subject.object
      @columns = []
      nest(&block)
      columns = @columns
      @columns = nil

      open(:table, class: name && "table table--#{name}")
      text_tag(:caption, caption) if caption
      sample = rows.first
      columns.each { |c| c[:sample] = sample && Subject.new(sample).fetch(c[:name]) }

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

    def column(*args, as: nil)
      name, header = name_and_content(args)
      registering!(:column)
      @columns << { name: name, header: label_for(name, header), as: as }
    end

    def total(*args)
      name, label = name_and_content(args)
      registering!(:total)
      @columns << { name: name, header: label, as: nil, total: true }
    end

    # --- Content --------------------------------------------------------

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
        open(:fieldset, class: name && "group group--#{name}")
        text_tag(:legend, label)
        nest(&block)
        close(:fieldset)
      else
        open(:div, class: 'group')
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

      open(:div, class: 'field')
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
      open(:div, class: 'field field--check')
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
      open(:div, class: 'field field--select')
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
               class: ['button', variant && "button--#{variant}"].compact.join(' '))
    end

    def actions(&block)
      open(:div, class: 'actions')
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
      else value.to_s
      end
    end

    # `as:` said in the page, else the app's own answer, else what the value's
    # shape can tell us — the same three levels as labels, owned by the same
    # three people.
    def format_of(column, row = nil)
      column[:as] || Subject.new(row || subject.object).format_for(column[:name])
    end

    def alignment_of(column, sample)
      kind = format_of(column, sample) || Inference.presentation(column[:sample])
      %i[money percent number].include?(kind) ? 'numeric' : nil
    end

    def amount(value, kind, precision)
      body = case kind
             when :money   then Inference.money(value, precision: precision)
             when :percent then Inference.percent(value, precision: precision)
             else               Inference.number(value, precision: precision)
             end
      classes = [kind.to_s, ('negative' if value.negative?)].compact.join(' ')
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

    def registering!(word)
      return if @columns

      raise Error, "#{word} belongs inside a table"
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
  end
end
