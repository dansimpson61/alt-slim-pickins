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
  # infers    — the conventions this word triggers, by name, into
  #             `Conventions::ALL`. A convention's prose has one home — the
  #             register — and a word names the ones it uses; the document's
  #             `conventions` bullet is generated from the join, so a word entry
  #             can no longer restate a rule the register already states.
  Contract = Struct.new(:name, :content, :modifiers, :children, :parents, :subject,
                        :speech, :shape, :gathers, :inside, :lazy, :empty, :id, :label,
                        :infers, :open,
                        keyword_init: true) do
    def initialize(**kw)
      super(**{ name: :none, content: false, modifiers: [], children: :none,
                parents: :any, subject: :keep, speech: :noun, shape: nil,
                gathers: false, inside: :any, lazy: [], empty: false, id: false,
                label: false, infers: [], open: false }.merge(kw))
    end
  end

  # The Ruby primitives' loader lived here until 2026-09-17. It read `# key:
  # value` comment preambles above each `def` in words.rb; when words.rb moved
  # to the `contract` macro, the loader kept reading the old spelling and
  # returned an empty hash — silently, for as long as nobody looked. The promise
  # ledger found it (`PRIMITIVES` had no reader, and could not have had one),
  # and dan ruled the deletion rather than the revival. What replaces it is the
  # registry: a word's contract is set by its own `contract` call or by its
  # partial's `expects` preamble, and `CONTRACTS` reads whichever is there.

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

  # A flag is a fact that is there or not; the preamble names it.
  FLAGS = %i[content gathers empty id label payload].freeze

  def parse(source)
    tree = SlimPickins::Transform.tree(source)
    expects_node = tree.first
    return nil unless expects_node && expects_node.word == 'expects'

    kwargs = {}
    
    names = expects_node.raw_args.zip(expects_node.ranks).select { |_, r| r.zero? }.map(&:first)
    kwargs[:name] = names.first.to_sym if names.any?

    expects_node.raw_args.zip(expects_node.ranks).each do |arg, rank|
      if rank == 2
        key = arg[/\A([a-z_]+):/, 1].to_sym
        value_str = arg.split(':', 2).last.strip
        value = if value_str == 'true'
                  true
                elsif value_str == 'false'
                  false
                elsif value_str == 'any'
                  :any
                elsif value_str.start_with?('[')
                  # rough array parsing if needed, but the grammar naturally uses multiple lines or space?
                  # Wait, our `expects` uses nested children!
                  value_str
                else
                  value_str.to_sym
                end

if key == :takes
  # `takes: content` — what the word takes, said once (2026-09-17). It replaces
  # `content: true`, where `true` was a placeholder carrying no information, and
  # it covers both kinds the preamble can name: a flag (content, empty, id,
  # label, gathers, payload) and a modifier. FLAGS decides which — and note that `id` is
  # both, so a modifier called `id` is declared in Ruby, as `box` does.
  taken = value_str.to_sym
  if taken == :payload
    kwargs[:open] = true
  elsif FLAGS.include?(taken)
    kwargs[taken] = true
  else
    kwargs[:modifiers] ||= []
    kwargs[:modifiers] << taken
  end
elsif key == :infers
  # `infers: label` — the convention this word triggers, by name. Repeatable,
  # and only a name: the prose lives once, in the register.
  (kwargs[:infers] ||= []) << value_str.to_sym
elsif key == :payload || key == :open
  kwargs[:open] = value == true || value == 'true'
elsif FLAGS.include?(key)
  kwargs[key] = value == true || value == 'true'
elsif %i[name inside speech subject shape].include?(key)
  kwargs[key] = value.to_sym
elsif %i[children parents].include?(key)
  str_val = value_str.gsub(/^"|"$/, '')
  kwargs[key] = str_val == 'any' ? :any : str_val.split.map(&:to_sym)
else
  # Any other key is a modifier declared the long way (`open: true`), kept so a
  # stale file is read correctly rather than silently misread.
  kwargs[:modifiers] ||= []
  kwargs[:modifiers] << key
end

      end
    end
    
    expects_node.children.each do |child|
      if child.word == 'modifier'
        kwargs[:modifiers] ||= []
        kwargs[:modifiers] << child.raw_args.first.to_sym
      elsif child.word == 'takes' || child.word == 'children'
        kwargs[:children] ||= []
        kwargs[:children] << child.raw_args.first.to_sym
      end
    end

    kwargs[:parents] = [kwargs[:inside]] if kwargs[:inside] && !kwargs[:parents]
    Contract.new(**kwargs)
  end
end

# CONTRACTS just pulls from Word.registry + VocabularyShapes for now
# But actually, VocabularyShapes is only needed if we don't compile them to Word subclasses instantly.
# Let's define CONTRACTS as a dynamic lookup
@loading_vocab = false
@vocab_shapes_cache = nil
CONTRACTS = Hash.new do |h, k|
  contract = SlimPickins::Word.registry[k]&.instance_variable_get(:@contract)
  if contract
    # Don't cache Word.registry contracts in the Hash so tests can redefine them
    next contract
  end
  
  unless @loading_vocab
    @loading_vocab = true
    @vocab_shapes_cache ||= VocabularyShapes.load
    @loading_vocab = false
  end

  # Cache the vocabulary shapes, since they never change — but never cache a
  # miss. A lookup that arrives *while* the vocabulary is loading finds the
  # cache still empty, and writing that nil down made the answer permanent:
  # `note` lost its contract in every process that called `Library.builtin`,
  # which is every app, so the transform stopped governing it and nothing
  # said so. A miss is only ever "not yet".
  shape = @vocab_shapes_cache&.[](k)
  h[k] = shape if shape
  shape
end







  # The same checks check_grammar.rb runs, as a module so tests can hold them.
  # A node is Transform's; ancestry is the stack of words above it. Errors
  # speak the language, naming the word and what it may or may not do.
  module Contracts
    # The modifiers every word accepts, whether or not it declares them. Named
    # once, because a permit list living inside a method body is a source of
    # truth no checker can read — and this one has three entries of which one
    # is read by nothing (`DAYTRIP-0.3.0b`, the promise ledger).
    UNIVERSAL_MODIFIERS = %i[if class id].freeze

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
      mod_text = if contract.open
                   contract.modifiers.empty? ? 'any' : (contract.modifiers.map { |m| "`#{m}:`" } + ['any']).join(', ')
                 elsif contract.modifiers.empty?
                   'none'
                 else
                   contract.modifiers.map { |m| "`#{m}:`" }.join(', ')
                 end
      [
        "- **name** — #{NAME_TEXT.fetch(contract.name)}",
        "- **content** — #{contract.content ? 'text or data, when there is any' : 'none'}",
        "- **modifiers** — #{mod_text}",
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
    # The gate calls it walking the tree; `PartialWord#evaluate` calls it for a
    # partial's own preamble, so an app partial's declaration is consumed by
    # the runtime too — one complaint machine, two consumers.
    def call_complaint(contract, word, names, data, modifiers)
      return nil if word.to_sym == :tag
      return "`#{word}` takes no name — #{names.join(', ')}" if contract.name == :none && names.any?
      return "`#{word}` takes no content or data — #{data.join(', ')}" if !contract.content && data.any?
      return nil if contract.open

      unknown = modifiers - (contract.modifiers + UNIVERSAL_MODIFIERS)
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
