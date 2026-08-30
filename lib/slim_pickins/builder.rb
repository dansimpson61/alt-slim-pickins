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
    WORDS = %i[page form group field check select option button actions
               disclosure].freeze

    def initialize(page)
      @out = +''
      @chain = Chain.new(page)
      @in_form = false
      @selected = nil
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

      @out << '<!DOCTYPE html>'
      open(:html, lang: 'en')
      open(:head)
      empty(:meta, charset: 'utf-8')
      empty(:meta, name: 'viewport', content: 'width=device-width, initial-scale=1')
      text_tag(:title, heading)
      close(:head)
      open(:body)
      text_tag(:h1, heading)
      about(name) { nest(&block) }
      close(:body)
      close(:html)
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
      label = legend || Inference.label(name)
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
      text_tag(:label, label || Inference.label(name), for: name.to_s)
      empty(:input,
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
      empty(:input, id: name.to_s, name: name.to_s, type: 'checkbox',
                    checked: value ? 'checked' : nil)
      @out << CGI.escapeHTML(label || Inference.label(name))
      close(:label)
      close(:div)
    end

    def select(*args, &block)
      name, label = name_and_content(args)
      @selected = subject.fetch(name)
      open(:div, class: 'field field--select')
      text_tag(:label, label || Inference.label(name), for: name.to_s)
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
               label || Inference.label(variant),
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

    # Names are Symbols, content is anything else. This is why argument order
    # never has to be counted.
    def name_and_content(args)
      [args.find { |a| a.is_a?(Symbol) }, args.find { |a| !a.is_a?(Symbol) }]
    end

    # A word that names a subject shifts the chain for its children. A word
    # that names nothing leaves the chain alone, which is what makes
    # `page scenario` followed by a bare `form` mean the obvious thing.
    def about(name, &block)
      return yield if name.nil? || !subject.respond_to?(name)

      @chain.with(subject.fetch(name), described_as: "this #{name}", &block)
    end

    def nest(&block)
      instance_eval(&block) if block
    end

    # --- HTML -----------------------------------------------------------

    def attrs(pairs)
      pairs.reject { |_, v| v.nil? || v == '' }
           .map { |k, v| %( #{k}="#{CGI.escapeHTML(v.to_s)}") }.join
    end

    def open(tag, **pairs) = @out << "<#{tag}#{attrs(pairs)}>"
    def open_tag(tag, pairs) = @out << "<#{tag}#{attrs(pairs)}>"
    def close(tag) = @out << "</#{tag}>"
    def empty(tag, **pairs) = @out << "<#{tag}#{attrs(pairs)}>"

    def text_tag(tag, text, **pairs)
      @out << "<#{tag}#{attrs(pairs)}>#{CGI.escapeHTML(text.to_s)}</#{tag}>"
    end
  end
end
