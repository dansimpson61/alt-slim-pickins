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
  # empty     — the word renders only while the enclosing subject is an
  #             empty collection (the gatherers' `empty`).
  # id        — the word's id derives from the subject (`card`).
  # label     — the word's content is labelled by the app contract
  #             (`section`'s heading).
  Contract = Struct.new(:name, :content, :modifiers, :children, :parents, :subject,
                        :speech, :shape, :gathers, :inside, :lazy, :empty, :id, :label,
                        keyword_init: true) do
    def initialize(**kw)
      super(**{ name: :none, content: false, modifiers: [], children: :none,
                parents: :any, subject: :keep, speech: :noun, shape: nil,
                gathers: false, inside: :any, lazy: [], empty: false, id: false,
                label: false }.merge(kw))
    end
  end

  # The Ruby primitives. The full vocabulary merges these with the shapes
  # declared in lib/vocabulary's partials — each word's definition and its
  # declaration live in one file, and this hash is the primitives' home.
    module PrimitiveShapes
    module_function

    def load
      source = File.read(File.expand_path('words.rb', __dir__))
      blocks = source.scan(/((?:^[ 	]*#[^
]*
)+)[ 	]*def ([a-z_]+)/)
      
      blocks.to_h do |comment_block, word|
        kwargs = {}
        comment_block.lines.each do |line|
          if line =~ /^[ 	]*#\s*([a-z_]+):\s*(.+?)\s*$/
            key = $1.to_sym
            value = $2
            kwargs[key] = case key
                          when :name, :inside, :speech, :subject then value.to_sym
                          when :content, :gathers, :empty, :id, :label then value == 'true'
                          when :shape then value.to_sym
                          when :children, :parents then value == 'any' ? :any : value.split.map(&:to_sym)
                          else value.split.map(&:to_sym)
                          end
          end
        end
        next nil if kwargs.empty?
        kwargs[:parents] = [kwargs[:inside]] if kwargs[:inside] && !kwargs[:parents]
        [word.to_sym, Contract.new(**kwargs)]
      end.compact
    end
  end

  PRIMITIVES = PrimitiveShapes.load.freeze


  # The shapes a vocabulary partial declares, as comment preambles at the top
  # of its file — the word's own file is the single source of what it is, and
  # the checkers hold it. Keys: name, content, modifiers, children, parents,
  # gathers, inside, lazy, shape, speech, subject, empty, id, label.
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
                      when :name, :inside, :speech, :subject then value.to_sym
                      when :content, :gathers, :empty, :id, :label then value == 'true'
                      when :shape then value.to_sym
                      when :children, :parents then value == 'any' ? :any : value.split.map(&:to_sym)
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

    # The name/content/modifier half of a violation, in the language's voice.
    # The gate calls it walking the tree; render_partial calls it for a
    # partial's own preamble, so an app partial's declaration is consumed by
    # the runtime too — one complaint machine, two consumers.
    def call_complaint(contract, word, names, data, modifiers)
      return nil if word.to_sym == :tag
      return "`#{word}` takes no name — #{names.join(', ')}" if contract.name == :none && names.any?
      return "`#{word}` takes no content or data — #{data.join(', ')}" if !contract.content && data.any?

      unknown = modifiers - (contract.modifiers + %i[if class id])
      "`#{word}` has no `#{unknown.first}:` modifier" if unknown.any?
    end

    def complaints(node, ancestry)
      contract = CONTRACTS[node.word.to_sym]
      return [] unless contract

      out = []
      names = node.raw_args.zip(node.ranks).select { |_, r| r.zero? }.map(&:first)
      data = node.raw_args.zip(node.ranks).select { |_, r| r == 1 }.map(&:first)
      modifiers = node.raw_args.zip(node.ranks).select { |_, r| r == 2 }
                  .map { |a, _| a[/\A([a-z_]+):/, 1].to_sym }

      complaint = call_complaint(contract, node.word, names, data, modifiers)
      out << complaint if complaint

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
