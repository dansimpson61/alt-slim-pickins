# frozen_string_literal: true

require_relative 'errors'
require_relative 'transform'

module SlimPickins
  # The checkable half of each word's seven slots, declared once and held to
  # by check_grammar.rb and by VOCABULARY.md. The prose half — `infers` and
  # `renders` — stays in the document, because documentation is prose.
  #
  # **Word Contract vs App Contract:**
  # This file defines the **Word Contract** — compile-time grammatical
  # constraints governing what a view word takes, holds, and where it may live.
  # This is distinct from the **App Contract** (CONTRACT.md), which defines how
  # domain models answer attributes and optional label/format queries.
  #
  # name      — :none | :target | :subject | :binding | :variant | :attribute |
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

  CANONICAL_INFERENCES = {
    aside: [:box_tag],
    badge: [:badge_status, :leaf_tag],
    card: [:card_id, :box_tag, :box_depth],
    disclosure: [:box_tag],
    empty: [:empty_situation],
    fact: [:box_tag, :label, :format],
    figure: [:box_tag],
    footer: [:box_tag],
    item: [:box_tag],
    list: [:box_tag],
    metric: [:label, :format],
    money: [:number_text, :leaf_tag],
    number: [:number_text, :leaf_tag],
    percent: [:number_text, :leaf_tag],
    section: [:label, :box_tag, :box_depth],
    snippet: [:box_tag],
    time: [:time_text, :leaf_tag],
    title: [:heading_level]
  }.freeze

  CANONICAL_SPEECH = {
    empty: :adjective
  }.freeze

  CANONICAL_FLAGS = {
    empty: { empty: true },
    card: { id: true },
    section: { label: true },
    fact: { label: true },
    metric: { label: true }
  }.freeze

  CANONICAL_MODIFIERS = {
    action: %i[to variant status],
    actions: [],
    card: [:variant],
    disclosure: [:open],
    fact: %i[as label],
    metric: %i[as label],
    money: [:precision],
    number: [:precision],
    percent: [:precision],
    search: %i[q placeholder to],
    section: [],
    snippet: []
  }.freeze

  CANONICAL_SHAPES = {
    action: :encloses,
    actions: :encloses,
    aside: :encloses,
    badge: :presents,
    card: :encloses,
    disclosure: :encloses,
    empty: :says,
    fact: :presents,
    figure: :encloses,
    flash: :presents,
    footer: :encloses,
    item: :registers,
    list: :encloses,
    metric: :says,
    money: :presents,
    note: :presents,
    number: :presents,
    paragraph: :presents,
    percent: :presents,
    scroll: :encloses,
    search: :encloses,
    section: :encloses,
    snippet: :presents,
    text: :presents,
    time: :presents,
    title: :presents
  }.freeze

  def load
    dir = File.expand_path('../vocabulary', __dir__)
    shapes = {}
    Dir[File.join(dir, '*.sp')].sort.each do |path|
      source = File.read(path)
      tree = SlimPickins::Transform.tree(source)
      tree.select { |n| n.word == 'def' }.each do |def_node|
        word_name = def_node.raw_args.first&.to_sym
        shapes[word_name] = infer_from_def(word_name, def_node)
      end
    end
    shapes
  end

  # A flag is a fact that is there or not; the preamble names it.
  FLAGS = %i[content gathers empty id label payload].freeze

  def infer_from_def(word_name, def_node)
    word_sym = word_name.to_sym
    params = def_node.raw_args.drop(1).map(&:to_sym)

    has_children = false
    walk = lambda do |nodes|
      nodes.each do |n|
        has_children = true if n.word == 'contents'
        walk.call(n.children)
      end
    end
    walk.call(def_node.children)

    primary = def_node.children.first
    while primary && primary.word == 'choose' && primary.children.any?
      primary = primary.children.first
    end

    shape = CANONICAL_SHAPES[word_sym]
    unless shape
      shape = if primary
                case primary.word
                when 'box', 'form' then :encloses
                when 'span', 'paragraph', 'note', 'heading' then :presents
                else :encloses
                end
              else
                :encloses
              end
    end

    name_slot = :none
    has_content = false
    modifiers = []

    params.each_with_index do |param, idx|
      if param == :subject || (param == :target && %i[card section].include?(word_sym))
        name_slot = :subject
      elsif param == :attribute || (param == :target && word_sym == :title)
        name_slot = :attribute
      elsif param == :variant || param == :status || param == :tone
        name_slot = :variant
      elsif param == :notation
        name_slot = :notation
      elsif param == :target
        name_slot = :target
      elsif %i[content text words label message amount ratio timestamp summary title heading stamp value body].include?(param)
        has_content = true
      elsif params.size == 1
        if primary
          target_contract = SlimPickins::CONTRACTS[primary.word.to_sym]
          if target_contract && target_contract.content && target_contract.name == :none
            has_content = true
          elsif target_contract && target_contract.name == :variant && !target_contract.content
            name_slot = :variant
          else
            has_content = true
          end
        else
          has_content = true
        end
      elsif idx.zero?
        name_slot = :variant
      elsif idx == 1
        has_content = true
      end
    end

    resolved_modifiers = CANONICAL_MODIFIERS[word_sym] || modifiers.sort

    subject_action = if params.include?(:subject) || (params.include?(:target) && %i[card section].include?(word_sym)) || word_sym == :card || word_sym == :section
                       :shift
                     else
                       :keep
                     end

    speech = CANONICAL_SPEECH[word_sym] || :noun
    infers = CANONICAL_INFERENCES[word_sym] || []
    parents = if (plist = SlimPickins::Word.parents_of(word_sym)).any?
                plist
              else
                :any
              end
    flags = CANONICAL_FLAGS[word_sym] || {}

    Contract.new(
      name: name_slot,
      content: has_content,
      modifiers: resolved_modifiers,
      children: has_children ? :any : :none,
      parents: parents,
      subject: subject_action,
      speech: speech,
      shape: shape,
      infers: infers,
      **flags
    )
  end

  def parse(source, word: nil)
    tree = SlimPickins::Transform.tree(source)
    target_node = if word
                    tree.find { |n| n.word == 'def' && n.raw_args.first&.to_sym == word.to_sym } || tree.first
                  else
                    tree.first
                  end
    return nil unless target_node

    if target_node.word == 'def'
      word_name = word || target_node.raw_args.first&.to_sym
      return infer_from_def(word_name, target_node)
    end

    return nil unless target_node.word == 'expects'

    expects_node = target_node
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
    if (parents = SlimPickins::Word.parents_of(k)).size > 1
      contract = contract.dup
      contract.parents = parents
    end
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
      none: 'none', target: 'the target', subject: 'the subject this word presents; it must be there',
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

    def complaints(node, ancestry, library: nil, privileged: false, named_above: true)
      if node.word == 'tag'
        return ["`tag` is a privileged primitive and may not be used in app pages"] unless privileged
        return []
      end

      word_sym = node.word.to_sym
      contract = nil
      if ancestry.any? && SlimPickins::Word.contained?(word_sym)
        ancestry.reverse.each do |parent|
          family = SlimPickins::Word.family_for(parent.to_sym)
          if family.key?(word_sym) && family[word_sym]
            contract = family[word_sym].instance_variable_get(:@contract)
            break if contract
          end
        end
      end
      contract ||= library&.compiled_partial(word_sym)&.instance_variable_get(:@contract) ||
                   CONTRACTS[word_sym]
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
      when Array then (children - contract.children.map(&:to_s)).each { |c| out << may_not_hold(node.word, c) }
      end

      if contract.parents != :any && (ancestry & contract.parents.map(&:to_s)).empty?
        allowed = contract.parents.map { |p| "`#{p}`" }.join(' or ')
        out << "`#{node.word}` belongs inside #{allowed}"
      end

      out.concat(never_shows(node, data, ancestry, named_above))
    end

    # Sentences the page alone shows can never work (dan, 2026-10-10): what
    # they say is refused, naming the fix, rather than silently dropped. What
    # only the data can show is left to the runtime's documented fallbacks.
    def never_shows(node, data, ancestry, named_above)
      out = []
      if node.word == 'empty' && (ancestry.first == :route || ancestry.first == 'page') && !ancestry.include?('def') && !named_above
        out << '`empty` has nothing above it that could be empty: no line above names a collection. ' \
               'Put it under the word that does, as in `section holdings`.'
      end
      written = data.any? { |arg| arg.start_with?('"') }
      if node.word == 'box' && written && node.children.any?
        out << '`box` shows its words or the lines under it, never both, so these lines ' \
               'would never show. Put the words in a `text` line among them.'
      end
      titled = node.word == 'section' ? node.raw_args.any? : (node.word == 'card' && data.any?)
      if titled && node.children.any? { |child| child.word == 'heading' }
        out << "`#{node.word}` already has a title, so a `heading` directly inside it would be " \
               "a second one. Say the title on the `#{node.word}` line, or use `title` or `text`."
      end
      out
    end

    # The gate's verdict, in a shape a cache can hold. The sentence that
    # broke its word's contract, where it stands, and what it may not do —
    # no path, because the same source may render under several names
    # (roth's report.sp renders as a partial and as a page), and each
    # render composes its own.
    Violation = Struct.new(:lineno, :body, :complaint, keyword_init: true)

    # Why a word may not hold a child. `empty` gets the fix as well, because
    # the fix is always the same: it belongs to the word around the collection.
    def may_not_hold(word, child)
      return "`#{word}` may not hold `#{child}`" unless child == 'empty'

      "`#{word}` may not hold `empty`. Put the `#{word}` inside a `section` and give the section the `empty`."
    end

    # Whether a sentence names something that could turn out empty: a bare
    # name (`section holdings`) or data (`section .items`). Words and quoted
    # text cannot. The walkers carry it down, so `empty` knows what is above.
    def names_something?(node)
      node.raw_args.zip(node.ranks).any? { |arg, rank| rank.zero? || (rank == 1 && arg.start_with?('.')) }
    end

    # The gate, walked: the first sentence that violates its word's
    # contract, or nil. The report half of this truth is check_grammar's
    # walk, which reports every complaint; the refusal half — the raise,
    # with the render's own path — lives in Compilation, which caches this
    # verdict so the walk runs once per source, not once per render.
    def first_violation(tree, library: nil, privileged: false)
      catch(:violation) do
        walk = lambda do |nodes, ancestry, named|
          nodes.each do |node|
            complaint = complaints(node, ancestry, library: library, privileged: privileged, named_above: named).first
            throw :violation, Violation.new(lineno: node.lineno, body: node.body, complaint: complaint) if complaint

            walk.call(node.children, ancestry + [node.word], named || names_something?(node))
          end
        end
        walk.call(tree, [], false)
        nil
      end
    end
  end
end
