# frozen_string_literal: true

require_relative 'errors'
require_relative 'transform'

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
  # speech    — the word's part of speech; :noun unless declared otherwise.
  #             The five non-nouns are the control flow.
  # shape     — the structural shape the word falls into: :document,
  #             :encloses, :presents, :says, :registers, :gathers,
  #             :iterates. A word with no declared shape has to argue for
  #             itself in writing; check_shape.rb fails on it.
  Contract = Struct.new(:name, :content, :modifiers, :children, :parents, :subject,
                        :speech, :shape, :gathers, :inside, :lazy, keyword_init: true) do
    def initialize(**kw)
      super(**{ name: :none, content: false, modifiers: [], children: :none,
                parents: :any, subject: :keep, speech: :noun, shape: nil,
                gathers: false, inside: :any, lazy: [] }.merge(kw))
    end
  end

  # The Ruby primitives. The full vocabulary merges these with the shapes
  # declared in lib/vocabulary's partials — each word's definition and its
  # declaration live in one file, and this hash is the primitives' home.
  PRIMITIVES = {
    children:   Contract.new(shape: :document),
    page:       Contract.new(name: :subject, content: true, modifiers: [:favicon],
                             children: :any, subject: :shift, shape: :document),
    contents:   Contract.new(shape: :document),
    stylesheet: Contract.new(content: true, shape: :document),
    meta:       Contract.new(name: :name, content: true, shape: :document),
    script:     Contract.new(content: true, modifiers: [:defer], shape: :document),
    nav:        Contract.new(name: :variant, children: %i[link input search], shape: :encloses),
    link:       Contract.new(name: :destination, content: true, modifiers: %i[to active], shape: :says),
    footer:     Contract.new(content: true, children: :any, shape: :encloses),
    aside:      Contract.new(children: :any, shape: :encloses),
    section:    Contract.new(name: :subject, content: true, children: :any, subject: :shift,
                             shape: :encloses),
    title:      Contract.new(content: true, shape: :presents),
    each:       Contract.new(name: :binding, modifiers: [:from], children: :any, subject: :each,
                             speech: :determiner, shape: :iterates),
    empty:      Contract.new(content: true, children: :any, speech: :adjective, shape: :says),
    table:      Contract.new(name: :subject, content: true,
                             children: %i[column total choose each], subject: :shift,
                             shape: :gathers),
    column:     Contract.new(name: :attribute, content: true, modifiers: [:as],
                             parents: [:table], subject: :row, shape: :registers),
    total:      Contract.new(name: :attribute, content: true, parents: [:table], shape: :registers),
    grid:       Contract.new(name: :variant, modifiers: [:columns], children: :any, shape: :encloses),
    list:       Contract.new(name: :variant, children: %i[item each], shape: :encloses),
    item:       Contract.new(name: :variant, content: true, children: :any, parents: [:list],
                             shape: :registers),
    card:       Contract.new(name: :variant, content: true, children: :any, shape: :encloses),
    actions:    Contract.new(children: %i[link button], shape: :encloses),
    figure:     Contract.new(content: true, children: :any, shape: :encloses),
    disclosure: Contract.new(content: true, modifiers: [:open], children: :any, shape: :encloses),
    money:      Contract.new(content: true, modifiers: [:precision], shape: :presents),
    percent:    Contract.new(content: true, modifiers: [:precision], shape: :presents),
    number:     Contract.new(content: true, modifiers: [:precision], shape: :presents),
    text:       Contract.new(content: true, shape: :presents),
    note:       Contract.new(name: :variant, content: true, shape: :presents),
    prose:      Contract.new(name: :notation, content: true, shape: :presents),
    badge:      Contract.new(name: :variant, content: true, shape: :presents),
    fact:       Contract.new(name: :attribute, content: true, shape: :presents),
    snippet:    Contract.new(name: :notation, content: true, shape: :presents),
    time:       Contract.new(name: :variant, content: true, shape: :presents),
    image:      Contract.new(content: true, modifiers: [:alt], shape: :presents),
    icon:       Contract.new(name: :name, content: true, shape: :says),
    metric:     Contract.new(name: :attribute, content: true, modifiers: [:as], shape: :says),
    chart:      Contract.new(name: :subject, content: true, modifiers: [:over],
                             children: %i[band line level each choose], subject: :shift,
                             shape: :gathers),
    band:       Contract.new(name: :attribute, content: true, parents: [:chart], shape: :registers),
    line:       Contract.new(name: :attribute, content: true, modifiers: [:from], parents: [:chart],
                             shape: :registers),
    level:      Contract.new(content: true, parents: [:chart], shape: :registers),
    choose:     Contract.new(children: %i[when otherwise], speech: :verb, shape: :gathers),
    when:       Contract.new(content: true, children: :any, parents: [:choose],
                             speech: :conjunction, shape: :encloses,
                             lazy: [:content]),
    otherwise:  Contract.new(children: :any, parents: [:choose], speech: :adverb, shape: :encloses),
    form:       Contract.new(name: :subject, modifiers: %i[to method],
                             children: %i[group field checkbox choice actions disclosure
                                          button hidden input textarea],
                             subject: :shift, shape: :encloses),
    group:      Contract.new(name: :topic, content: true, children: :any, shape: :encloses),
    field:      Contract.new(name: :attribute, content: true, modifiers: %i[type step required],
                             shape: :says),
    textarea:   Contract.new(name: :attribute, content: true, modifiers: %i[rows required],
                             shape: :says),
    input:      Contract.new(name: :attribute, content: true, modifiers: %i[type placeholder],
                             shape: :says),
    hidden:     Contract.new(name: :name, content: true, parents: [:form], shape: :says),
    checkbox:   Contract.new(name: :attribute, content: true, shape: :says),
    choice:     Contract.new(name: :attribute, content: true, children: %i[option choice], shape: :gathers),
    option:     Contract.new(name: :value, content: true, parents: [:choice], shape: :registers),
    button:     Contract.new(name: :variant, content: true, modifiers: %i[to type size], shape: :says)
  }.freeze

  # The shapes a vocabulary partial declares, as comment preambles at the top
  # of its file — the word's own file is the single source of what it is, and
  # the checkers hold it. Keys: name, content, modifiers, children, gathers,
  # inside, lazy, shape.
  module VocabularyShapes
    module_function

    def load
      dir = File.expand_path('../vocabulary', __dir__)
      Dir[File.join(dir, '*.sp')].to_h do |path|
        word = File.basename(path, '.sp').to_sym
        [word, parse(File.read(path))]
      end.compact
    end

    def parse(source)
      kwargs = {}
      source.lines.each do |line|
        break unless line =~ /\A#\s*([a-z_]+):\s*(.+?)\s*\z/

        key = Regexp.last_match(1).to_sym
        value = Regexp.last_match(2)
        kwargs[key] = case key
                      when :name, :inside then value.to_sym
                      when :content, :gathers then value == 'true'
                      when :shape then value.to_sym
                      else value.split.map(&:to_sym)
                      end
      end
      return nil if kwargs.empty?

      kwargs[:parents] = [kwargs[:inside]] if kwargs[:inside] && !kwargs[:parents]
      Contract.new(**kwargs)
    end
  end

  # The vocabulary's one list: primitives plus the partials' declared shapes.
  CONTRACTS = PRIMITIVES.merge(VocabularyShapes.load).freeze

  # The same checks check_grammar.rb runs, as a module so tests can hold them.
  # A node is Transform's; ancestry is the stack of words above it. Errors
  # speak the language, naming the word and what it may or may not do.
  module Contracts
    NAME_TEXT = {
      none: 'none', subject: 'the subject this word presents; it must be there',
      binding: 'the singular of the collection; also binds that name',
      variant: 'the variant', attribute: 'the attribute',
      destination: 'the destination', topic: 'the topic', notation: 'the notation',
      value: 'the value', name: 'a name'
    }.freeze

    SUBJECT_TEXT = {
      keep: 'unchanged', shift: 'the named thing', each: 'each element in turn',
      row: 'unchanged; the enclosing word supplies each row in turn'
    }.freeze

    module_function

    # The five checkable bullets of a vocabulary entry, rendered from the
    # contract. bin/generate_vocabulary.rb writes them into VOCABULARY.md and
    # check_grammar.rb holds the document to them, so the only way to change
    # a bullet is to change the contract.
    def bullets(word, contract)
      [
        "- **name** — #{NAME_TEXT.fetch(contract.name)}",
        "- **content** — #{contract.content ? 'text or data, when there is any' : 'none'}",
        "- **modifiers** — #{contract.modifiers.empty? ? 'none' : contract.modifiers.map { |m| "`#{m}:`" }.join(', ')}",
        "- **children** — #{children_text(contract.children)}",
        "- **subject** — #{SUBJECT_TEXT.fetch(contract.subject)}"
      ]
    end

    def children_text(children)
      case children
      when :any then 'anything'
      when :none then 'none'
      else children.map { |c| "`#{c}`" }.join(', ')
      end
    end

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

    # The gate's verdict, in a shape a cache can hold. The sentence that
    # broke its word's contract, where it stands, and what it may not do —
    # no path, because the same source may render under several names
    # (roth's report.sp renders as a partial and as a page), and each
    # render composes its own.
    Violation = Struct.new(:lineno, :body, :complaint, keyword_init: true)

    # The gate, walked: the first sentence that violates its word's
    # contract, or nil. The report half of this truth is check_grammar's
    # walk, which reports every complaint; the refusal half — the raise,
    # with the render's own path — lives in Compilation, which caches this
    # verdict so the walk runs once per source, not once per render.
    def first_violation(tree)
      catch(:violation) do
        walk = lambda do |nodes, ancestry|
          nodes.each do |node|
            complaint = complaints(node, ancestry).first
            throw :violation, Violation.new(lineno: node.lineno, body: node.body, complaint: complaint) if complaint

            walk.call(node.children, ancestry + [node.word])
          end
        end
        walk.call(tree, [])
        nil
      end
    end
  end
end
