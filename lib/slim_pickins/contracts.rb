# frozen_string_literal: true

module SlimPickins
  # The checkable half of each word's seven slots, declared once and held to
  # by check_grammar.rb and by VOCABULARY.md. The prose half — `infers` and
  # `renders` — stays in the document, because documentation is prose.
  #
  # name      — :none | :subject | :binding | :variant | :attribute |
  #             :destination | :topic | :notation | :value | :name
  #             whether a bare name is legal, and what kind of name it is —
  #             which is what the word makes of it.
  # content   — whether content and data arguments are legal.
  # modifiers — the modifier keys the word takes; `if:` is universal.
  # children  — :any | :none | the words that may nest beneath it.
  # parents   — :any | the words this one may nest beneath, checked by
  #             ancestry, because `each` and `choose` may stand between a
  #             registering word and its gatherer (Phase 8: `each` composes
  #             with registration).
  # subject   — what the word does to the subject: :keep | :shift | :each |
  #             :row.
  Contract = Struct.new(:name, :content, :modifiers, :children, :parents, :subject,
                        keyword_init: true) do
    def initialize(**kw)
      super(**{ name: :none, content: false, modifiers: [], children: :none,
                parents: :any, subject: :keep }.merge(kw))
    end
  end

  CONTRACTS = {
    page:       Contract.new(name: :subject, content: true, children: :any, subject: :shift),
    contents:   Contract.new,
    stylesheet: Contract.new(content: true),
    meta:       Contract.new(name: :name, content: true),
    script:     Contract.new(content: true, modifiers: [:defer]),
    nav:        Contract.new(name: :variant, children: [:link]),
    link:       Contract.new(name: :destination, content: true, modifiers: [:to]),
    footer:     Contract.new(content: true, children: :any),
    aside:      Contract.new(children: :any),
    section:    Contract.new(name: :subject, content: true, children: :any, subject: :shift),
    title:      Contract.new(content: true),
    each:       Contract.new(name: :binding, modifiers: [:from], children: :any, subject: :each),
    empty:      Contract.new(content: true, children: :any),
    table:      Contract.new(name: :subject, content: true,
                             children: %i[column total choose each], subject: :shift),
    column:     Contract.new(name: :attribute, content: true, modifiers: [:as],
                             parents: [:table], subject: :row),
    total:      Contract.new(name: :attribute, content: true, parents: [:table]),
    grid:       Contract.new(name: :variant, modifiers: [:columns], children: :any),
    list:       Contract.new(name: :variant, children: %i[item each]),
    item:       Contract.new(name: :variant, content: true, children: :any, parents: [:list]),
    card:       Contract.new(name: :variant, children: :any),
    actions:    Contract.new(children: %i[link button]),
    figure:     Contract.new(content: true, children: :any),
    disclosure: Contract.new(content: true, modifiers: [:open], children: :any),
    money:      Contract.new(content: true, modifiers: [:precision]),
    percent:    Contract.new(content: true, modifiers: [:precision]),
    number:     Contract.new(content: true, modifiers: [:precision]),
    text:       Contract.new(content: true),
    note:       Contract.new(name: :variant, content: true),
    prose:      Contract.new(name: :notation, content: true),
    badge:      Contract.new(name: :variant, content: true),
    fact:       Contract.new(name: :attribute, content: true),
    snippet:    Contract.new(name: :notation, content: true),
    time:       Contract.new(name: :variant, content: true),
    image:      Contract.new(content: true, modifiers: [:alt]),
    icon:       Contract.new(name: :name, content: true),
    metric:     Contract.new(name: :attribute, content: true, modifiers: [:as]),
    chart:      Contract.new(name: :subject, content: true, modifiers: [:over],
                             children: %i[band line level each choose], subject: :shift),
    band:       Contract.new(name: :attribute, content: true, parents: [:chart]),
    line:       Contract.new(name: :attribute, content: true, modifiers: [:from], parents: [:chart]),
    level:      Contract.new(content: true, parents: [:chart]),
    choose:     Contract.new(children: %i[when otherwise]),
    when:       Contract.new(content: true, children: :any, parents: [:choose]),
    otherwise:  Contract.new(children: :any, parents: [:choose]),
    form:       Contract.new(name: :subject, modifiers: %i[to method],
                             children: %i[group field checkbox choice actions disclosure],
                             subject: :shift),
    group:      Contract.new(name: :topic, content: true, children: :any),
    field:      Contract.new(name: :attribute, content: true, modifiers: %i[type step required]),
    checkbox:   Contract.new(name: :attribute, content: true),
    choice:     Contract.new(name: :attribute, content: true, children: [:option]),
    option:     Contract.new(name: :value, content: true, parents: [:choice]),
    button:     Contract.new(name: :variant, content: true, modifiers: %i[to type])
  }.freeze

  # The same checks check_grammar.rb runs, as a module so tests can hold them.
  # A node is Transform's; ancestry is the stack of words above it. Errors
  # speak the language, naming the word and what it may or may not do.
  module Contracts
    module_function

    def complaints(node, ancestry)
      contract = CONTRACTS[node.word.to_sym]
      return [] unless contract

      out = []
      names = node.raw_args.zip(node.ranks).select { |_, r| r.zero? }.map(&:first)
      data = node.raw_args.zip(node.ranks).select { |_, r| r == 1 }.map(&:first)
      modifiers = node.raw_args.zip(node.ranks).select { |_, r| r == 2 }
                  .map { |a, _| a[/\A([a-z_]+):/, 1].to_sym }

      out << "`#{node.word}` takes no name — #{names.join(', ')}" if contract.name == :none && names.any?
      out << "`#{node.word}` takes no content or data — #{data.join(', ')}" if !contract.content && data.any?

      unknown = modifiers - (contract.modifiers + [:if])
      out << "`#{node.word}` has no `#{unknown.first}:` modifier" if unknown.any?

      children = node.children.map(&:word).uniq
      case contract.children
      when :none then out << "`#{node.word}` holds nothing — a `#{children.first}` has nowhere to go" if children.any?
      when Array then (children - contract.children.map(&:to_s)).each { |c| out << "`#{node.word}` may not hold `#{c}`" }
      end

      if contract.parents != :any && (ancestry & contract.parents.map(&:to_s)).empty?
        allowed = contract.parents.map { |p| "`#{p}`" }.join(' or ')
        out << "`#{node.word}` belongs inside #{allowed}"
      end

      out
    end
  end
end
