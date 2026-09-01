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
      nodes.each { |node| emit(node) }
      @out
    end

    private

    def emit(node)
      # A bare string in the tree is escaped text — the one general rule.
      return @out << esc(node) if node.is_a?(String)

      kind, attrs, children = node
      case kind
      when :raw then @out << children.join
      when :tag
        @out << "<#{attrs[:name]}#{attrs_html(attrs[:attrs])}>"
        children.each { |c| emit(c) }
        @out << "</#{attrs[:name]}>"
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
      full_tag('a', attrs[:label], href: attrs[:to]&.to_s || "/#{attrs[:name]}")
    end

    def footer(attrs, children)
      open_tag('footer', class: token(:footer))
      attrs[:body] ? @out << esc(attrs[:body]) : children.each { |c| emit(c) }
      @out << '</footer>'
    end

    # --- Structure --------------------------------------------------------

    def section(attrs, children)
      open_tag('section', class: token(:section, attrs[:name]))
      full_tag(:"h#{attrs[:level]}", attrs[:heading], class: 'section-title')
      children.each { |c| emit(c) }
      @out << '</section>'
    end

    def title(attrs, _children)
      full_tag(:"h#{attrs[:level]}", attrs[:text], class: token(:title))
    end

    def empty(attrs, _children)
      full_tag('p', attrs[:message], class: token(:empty))
    end

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

    def aside(_attrs, children)
      open_tag('aside', class: token(:aside))
      children.each { |c| emit(c) }
      @out << '</aside>'
    end

    def grid(attrs, children)
      track = attrs[:columns] &&
              "max(var(--track-min), calc((100% - #{attrs[:columns] - 1} * var(--gap)) / #{attrs[:columns]}))"
      open_tag('div', class: token(:grid, attrs[:variant]), style: track && "--track: #{track}")
      children.each { |c| emit(c) }
      @out << '</div>'
    end

    def list(attrs, children)
      open_tag('ul', class: token(:list, attrs[:variant]))
      children.each { |c| emit(c) }
      @out << '</ul>'
    end

    def item(attrs, children)
      open_tag('li', class: token(:item, attrs[:variant]))
      attrs[:body] ? @out << esc(attrs[:body]) : children.each { |c| emit(c) }
      @out << '</li>'
    end

    def card(attrs, children)
      open_tag('article', class: token(:card, attrs[:variant]), id: attrs[:id])
      children.each { |c| emit(c) }
      @out << '</article>'
    end

    def figure(attrs, children)
      open_tag('figure', class: token(:figure))
      children.each { |c| emit(c) }
      full_tag('figcaption', attrs[:caption]) if attrs[:caption]
      @out << '</figure>'
    end

    def disclosure(attrs, children)
      @out << (attrs[:open] ? '<details open="open">' : '<details>')
      full_tag('summary', attrs[:summary])
      children.each { |c| emit(c) }
      @out << '</details>'
    end

    # --- Content ----------------------------------------------------------

    def note(attrs, _children)
      full_tag('p', attrs[:body], class: token(:note, attrs[:variant]))
    end

    def prose(attrs, _children)
      html = attrs[:notation] == :plain ? Markdown.plain(attrs[:body]) : Markdown.render(attrs[:body])
      @out << %(<div class="#{token(:prose)}">#{html}</div>)
    end

    def badge(attrs, _children)
      full_tag('span', attrs[:label], class: token(:badge, attrs[:kind]))
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

    def time(attrs, _children)
      full_tag('time', Inference.moment(attrs[:moment], attrs[:variant]), datetime: attrs[:machine])
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

    def money(attrs, _children)
      amount(attrs[:value], :money, attrs[:precision])
    end

    def percent(attrs, _children)
      amount(attrs[:value], :percent, attrs[:precision])
    end

    def number(attrs, _children)
      amount(attrs[:value], :number, attrs[:precision])
    end

    def amount(value, kind, precision)
      body = case kind
             when :money   then Inference.money(value, precision: precision)
             when :percent then Inference.percent(value, precision: precision)
             else               Inference.number(value, precision: precision)
             end
      classes = token(kind, ('negative' if value.negative?))
      full_tag('span', body, class: classes)
    end

    def text(attrs, _children)
      full_tag('p', attrs[:body])
    end

    # --- Interaction ------------------------------------------------------

    def form(attrs, children)
      open_tag('form', id: attrs[:name]&.to_s, action: attrs[:to]&.to_s,
                      method: (attrs[:method] || :post).to_s)
      children.each { |c| emit(c) }
      @out << '</form>'
    end

    def group(attrs, children)
      if attrs[:in_form]
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
      full_tag('button', attrs[:label],
               type: (attrs[:type] || (attrs[:in_form] ? :submit : :button)).to_s,
               formaction: attrs[:to]&.to_s,
               class: token(:button, attrs[:variant]))
    end

    def actions(_attrs, children)
      open_tag('div', class: token(:actions))
      children.each { |c| emit(c) }
      @out << '</div>'
    end

    # --- bits -------------------------------------------------------------

    def open_tag(tag, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>"
    def void_tag(tag, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>"
    def full_tag(tag, text, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>#{esc(text)}</#{tag}>"
  end
end
