# frozen_string_literal: true

require 'cgi'
require_relative 'inference'
require_relative 'markdown'
require_relative 'charting'
require_relative 'icons'

module SlimPickins
  # The HTML interpreter. It walks the tree of semantic nodes the Builder
  # evaluates — `[:word, attributes, children]` — and emits the document. The
  # words built the description; this is where presentation lives: escaping,
  # formatting, and the shape of every tag. A second interpreter over the
  # same tree is what an API would be; none is built, because none has asked.
  class Generator
    # The four class-name shapes, and the only place they are built. The
    # Builder's hatch exposes this through its own `token`, so the truth has
    # one home.
    def self.token(word, variant = nil)
      [word.to_s, variant && "#{word}--#{variant}"].compact.join(' ')
    end

    # The same three levels the words used at build time — `as:` said in the
    # page, else the app's own answer, else the value's shape. The one home
    # for formatting: the words that need it at build time (a chart's
    # tooltips) and this interpreter call the same function.
    def self.format(kind, value)
      kind ||= Inference.presentation(value)
      case kind
      when :money   then Inference.money(value)
      when :percent then Inference.percent(value)
      when :number  then Inference.number(value)
      else value.respond_to?(:strftime) ? Inference.moment(value, nil) : value.to_s
      end
    end

    def initialize
      @out = +''
    end

    def call(nodes)
      @depth = 1
      @in_form = false
      @box_base = nil
      @box_level = nil
      nodes.each { |node| emit(node) }
      @out
    end

    # The walk's context — heading depth and form-ness are tree facts, so the
    # interpreter derives them as it goes. The words stopped carrying them.
    def with_depth(depth)
      was = @depth
      @depth = depth
      yield
    ensure
      @depth = was
    end

    def with_form(in_form)
      was = @in_form
      @in_form = in_form
      yield
    ensure
      @in_form = was
    end

    private

    # Elements that may not carry a closing tag — an app word building
    # `tag(:img, ...)` must get what the built-in `image` word gets.
    VOID = %w[area base br col embed hr img input link meta param source track wbr].freeze

    def emit(node)
      # A bare string in the tree is escaped text; nil is nothing at all —
      # the old runtime escaped it to an empty string.
      return @out << esc(node) if node.is_a?(String)
      return if node.nil?

      kind, attrs, children = node
      case kind
      when :raw then @out << children.join
      when :tag
        @out << "<#{attrs[:name]}#{attrs_html(attrs[:attrs])}>"
        children.each { |c| emit(c) } unless VOID.include?(attrs[:name].to_s)
        @out << "</#{attrs[:name]}>" unless VOID.include?(attrs[:name].to_s)
      when :each then children.flatten(1).each { |c| emit(c) } # one list per iteration
      when :choose, :contents then children.each { |c| emit(c) } # already flat
      else
        raise Error, "no generator for node `#{kind}`" unless respond_to?(kind, true)

        send(kind, attrs, children)
      end
    end

    def token(word, variant = nil) = self.class.token(word, variant)
    def esc(text) = CGI.escapeHTML(text.to_s)
    def attrs_html(pairs)
      pairs.reject { |_, v| v.nil? || v == '' || v == false }
           .map { |k, v| v == true ? %( #{k}) : %( #{k}="#{CGI.escapeHTML(v.to_s)}") }.join
    end

    # --- Document ---------------------------------------------------------

    def page(attrs, children)
      @out << '<!DOCTYPE html>'
      open_tag('html', lang: 'en')
      open_tag('head')
      void_tag('meta', charset: 'utf-8')
      void_tag('meta', name: 'viewport', content: 'width=device-width, initial-scale=1')
      void_tag('link', rel: 'icon', href: attrs[:favicon]) if attrs[:favicon]
      full_tag('title', attrs[:heading])
      attrs[:head].each { |node| emit(node) }
      @out << '</head>'
      open_tag('body')
      @out << Icons.sprite(attrs[:icons])
      full_tag('h1', attrs[:heading])
      children.each { |node| emit(node) }
      @out << '</body>'
      @out << '</html>'
    end

    def stylesheet(attrs, _children)
      @out << %(<link rel="stylesheet" href="#{CGI.escapeHTML(attrs[:path])}">)
    end

    def meta(attrs, _children)
      @out << %(<meta name="#{attrs[:name]}" content="#{CGI.escapeHTML(attrs[:value].to_s)}">)
    end

    def script(attrs, _children)
      @out << %(<script src="#{CGI.escapeHTML(attrs[:path])}"#{attrs[:defer] ? ' defer' : ''}></script>)
    end

    def nav(attrs, children)
      open_tag('nav', class: token(:nav, attrs[:variant]),
                     'aria-label': attrs[:variant] ? attrs[:variant].to_s.capitalize : 'Main')
      children.each { |c| emit(c) }
      @out << '</nav>'
    end

    def link(attrs, _children)
      classes = [token(:link), attrs[:active] ? 'link--active' : nil].compact.join(' ')
      full_tag('a', attrs[:label], href: attrs[:to]&.to_s || "/#{attrs[:name]}",
               class: classes, 'aria-current': attrs[:active] ? 'page' : nil)
    end

    # --- Structure --------------------------------------------------------

    def table(attrs, _children)
      name, caption, columns, rows, foot =
        attrs.values_at(:name, :caption, :columns, :rows, :foot)
      open_tag('table', class: token(:table, name))
      full_tag('caption', caption) if caption
      @out << '<thead>'
      @out << '<tr>'
      columns.each do |c|
        next if c[:total]

        full_tag('th', c[:header], class: c[:alignment])
      end
      @out << '</tr>'
      @out << '</thead>'
      @out << '<tbody>'
      rows.each do |row|
        @out << '<tr>'
        row[2].each do |cell|
          full_tag('td', Generator.format(cell[:kind], cell[:value]), class: cell[:alignment])
        end
        @out << '</tr>'
      end
      @out << '</tbody>'
      unless foot.empty?
        @out << '<tfoot>'
        @out << '<tr>'
        foot.each do |cell|
          body = cell.key?(:label) ? cell[:label] : (cell.key?(:value) ? Generator.format(cell[:kind], cell[:value]) : '')
          full_tag('td', body, class: cell[:alignment])
        end
        @out << '</tr>'
        @out << '</tfoot>'
      end
      @out << '</table>'
    end

    def grid(attrs, children)
      track = attrs[:columns] &&
              "max(var(--track-min), calc((100% - #{attrs[:columns] - 1} * var(--gap)) / #{attrs[:columns]}))"
      open_tag('div', class: token(:grid, attrs[:variant]), style: track && "--track: #{track}")
      children.each { |c| emit(c) }
      @out << '</div>'
    end

    # --- Content ----------------------------------------------------------

    def prose(attrs, _children)
      html = attrs[:notation] == :plain ? Markdown.plain(attrs[:body]) : Markdown.render(attrs[:body])
      @out << %(<div class="#{token(:prose)}">#{html}</div>)
    end

    def fact(attrs, _children)
      open_tag('dl', class: token(:fact))
      full_tag('dt', attrs[:label])
      full_tag('dd', Generator.format(attrs[:kind], attrs[:value]))
      @out << '</dl>'
    end

    def snippet(attrs, _children)
      open_tag('pre', class: token(:snippet, attrs[:language]))
      full_tag('code', attrs[:body])
      @out << '</pre>'
      full_tag('button', 'Copy', type: 'button', class: 'snippet-copy')
    end

    def iframe(attrs, _children)
      open_tag('iframe',
               class: token(:iframe, attrs[:name]),
               name: attrs[:name],
               src: attrs[:src],
               srcdoc: attrs[:srcdoc],
               width: attrs[:width],
               height: attrs[:height])
      @out << "</iframe>"
    end

    def image(attrs, _children)
      void_tag('img', src: attrs[:src].to_s, alt: attrs[:alt].to_s, loading: 'lazy')
    end

    def icon(attrs, _children)
      @out << %(<svg class="icon icon--#{attrs[:name]}" aria-hidden="true">) +
              %(<use href="#icon-#{attrs[:name]}"></use></svg>)
    end

    def metric(attrs, _children)
      open_tag('div', class: token(:metric))
      full_tag('h3', attrs[:label], class: 'metric-label')
      full_tag('div', Generator.format(attrs[:kind], attrs[:value]), class: 'metric-value')
      @out << '</div>'
    end

    def chart(attrs, _children)
      @out << Charting.render(series: attrs[:series], levels: attrs[:levels],
                              across: attrs[:across], caption: attrs[:caption])
    end

    # The classed leaf — the atom under badge, money, percent, number and
    # time. Tag, class and formatting all derive from the word; this is the
    # presentation the promoted words no longer carry in Ruby.
    SPAN_TAGS = { badge: 'span', money: 'span', percent: 'span', number: 'span', time: 'time' }.freeze
    KNOWN_STATUSES = Icons::SYMBOLS.keys.freeze

    def span(attrs, _children)
      base = attrs[:class_base] || :span
      body = attrs[:body]
      case base
      when :money, :percent, :number
        precision = attrs[:precision] || (base == :percent ? 1 : 0)
        text = Inference.send(base, body, precision: precision)
        negative = body.respond_to?(:negative?) && body.negative?
        full_tag('span', text, class: token(base, negative ? 'negative' : nil))
      when :badge
        kind = attrs[:variant] ||
               (KNOWN_STATUSES.include?(body.to_s.to_sym) ? body.to_s.to_sym : nil)
        full_tag('span', body || kind, class: token(:badge, kind))
      when :time
        machine = body.respond_to?(:iso8601) ? body.iso8601 : body.to_s
        full_tag('time', Inference.moment(body, attrs[:variant]), class: token(:time, attrs[:variant]),
                                                               datetime: machine)
      else
        full_tag(SPAN_TAGS.fetch(base, 'span'), body, class: token(base, attrs[:variant]))
      end
    end

    def figcaption(attrs, _children)
      full_tag('figcaption', attrs[:body]) if attrs[:body]
    end

    def summary(attrs, _children)
      full_tag('summary', attrs[:body])
    end

    def heading(attrs, _children)
      # A heading inside a box is the box's title — the class follows the
      # part convention, `#{box}-title`, at the box's own level; the depth
      # rule still governs a heading of its own.
      if attrs[:class_base]
        full_tag(:"h#{@depth + 1}", attrs[:body], class: token(attrs[:class_base]))
      elsif @box_base
        full_tag(:"h#{@box_level + 1}", attrs[:body], class: "#{@box_base}-title")
      else
        full_tag(:"h#{@depth + 1}", attrs[:body], class: token(:heading))
      end
    end

    def paragraph(attrs, children)
      open_tag('p', class: token(attrs[:class_base] || :paragraph, attrs[:variant]))
      attrs[:body] ? @out << esc(attrs[:body]) : children.each { |c| emit(c) }
      @out << '</p>'
    end

    # The named boxes: a promoted word's box is its tag too. `region` under
    # a `footer` partial emits a <footer>, so promotion changes nothing a
    # page sees, tags included. Words not named here keep the div they are.
    # Some boxes also deepen their children's headings, like the words they
    # replaced did.
    BOX_TAGS  = { footer: 'footer', aside: 'aside', item: 'li', list: 'ul',
                  card: 'article', section: 'section', figure: 'figure',
                  disclosure: 'details' }.freeze
    BOX_DEPTH = { card: 1, section: 1 }.freeze

    def region(attrs, children)
      tag_name = BOX_TAGS.fetch(attrs[:class_base], 'div')
      open_tag(tag_name, class: token(attrs[:class_base] || :region, attrs[:variant]),
                          id: attrs[:id]&.to_s, open: attrs[:open] && 'open')
      if attrs[:body]
        @out << esc(attrs[:body])
      else
        was_box, was_level = @box_base, @box_level
        begin
          @box_base, @box_level = attrs[:class_base], @depth if attrs[:class_base]
          with_depth(@depth + BOX_DEPTH.fetch(attrs[:class_base], 0)) { children.each { |c| emit(c) } }
        ensure
          @box_base, @box_level = was_box, was_level
        end
      end
      @out << "</#{tag_name}>"
    end

    # --- Interaction ------------------------------------------------------

    def form(attrs, children)
      open_tag('form', id: attrs[:name]&.to_s, action: attrs[:to]&.to_s,
                      method: (attrs[:method] || :post).to_s, target: attrs[:target]&.to_s)
      with_form(true) { children.each { |c| emit(c) } }
      @out << '</form>'
    end

    def group(attrs, children)
      if @in_form
        open_tag('fieldset', class: token(:group, attrs[:name]))
        full_tag('legend', attrs[:legend])
        children.each { |c| emit(c) }
        @out << '</fieldset>'
      else
        open_tag('div', class: token(:group))
        full_tag('h2', attrs[:legend])
        children.each { |c| emit(c) }
        @out << '</div>'
      end
    end

    def field(attrs, _children)
      open_tag('div', class: token(:field))
      full_tag('label', attrs[:label], for: attrs[:name].to_s)
      void_tag('input',
               id: attrs[:name].to_s,
               name: attrs[:name].to_s,
               type: attrs[:kind].to_s,
               value: attrs[:value]&.to_s,
               step: attrs[:step],
               required: attrs[:required] ? 'required' : nil)
      @out << '</div>'
    end

    def input(attrs, _children)
      void_tag('input',
               id: attrs[:name].to_s,
               name: attrs[:name].to_s,
               type: attrs[:kind].to_s,
               value: attrs[:value]&.to_s,
               placeholder: attrs[:placeholder]&.to_s)
    end

    def textarea(attrs, _children)
      open_tag('div', class: token(:field))
      full_tag('label', attrs[:label], for: attrs[:name].to_s)
      open_tag('textarea', id: attrs[:name].to_s, name: attrs[:name].to_s,
                           rows: attrs[:rows], required: attrs[:required] ? 'required' : nil)
      @out << esc(attrs[:value])
      @out << '</textarea></div>'
    end

    def hidden(attrs, _children)
      void_tag('input', type: 'hidden', name: attrs[:name].to_s, value: attrs[:value]&.to_s)
    end

    def checkbox(attrs, _children)
      open_tag('div', class: token(:field, :checkbox))
      open_tag('label', for: attrs[:name].to_s)
      void_tag('input', id: attrs[:name].to_s, name: attrs[:name].to_s, type: 'checkbox',
                        checked: attrs[:value] ? 'checked' : nil)
      @out << esc(attrs[:label])
      @out << '</label>'
      @out << '</div>'
    end

    def choice(attrs, children)
      open_tag('div', class: token(:field, :choice))
      full_tag('label', attrs[:label], for: attrs[:name].to_s)
      open_tag('select', id: attrs[:name].to_s, name: attrs[:name].to_s)
      children.each { |c| emit(c) }
      @out << '</select>'
      @out << '</div>'
    end

    def option(attrs, _children)
      full_tag('option', attrs[:label] || Inference.label(attrs[:value]),
               value: attrs[:value].to_s,
               selected: (attrs[:selected].to_s == attrs[:value].to_s ? 'selected' : nil))
    end

    def button(attrs, _children)
      classes = token(:button, attrs[:variant])
      classes += " button--#{attrs[:size]}" if attrs[:size]
      full_tag('button', attrs[:label],
               type: (attrs[:type] || (@in_form ? :submit : :button)).to_s,
               formaction: attrs[:to]&.to_s,
               class: classes)
    end

    # --- bits -------------------------------------------------------------

    def open_tag(tag, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>"
    def void_tag(tag, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>"
    def full_tag(tag, text, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>#{esc(text)}</#{tag}>"
  end
end
