require 'ostruct'
require 'set'
require_relative 'uis'
module StudioDocs
  # One link in the sidebar. A plain Struct is the app contract satisfied with
  # no ceremony, which is the point — `each word` binds one of these and the
  # view reads `.name` and `.path` off it.
  Entry = Struct.new(:name, :path, :role, :facets, :badge, :active, keyword_init: true)

  # A tier group of words on the library shelf, representing one of the five
  # deductive authoring tiers (Structural, Semantic, Interactive, Behavioral, Visual).
  TierGroup = Struct.new(:name, :title, :question, :summary, :count, :words, keyword_init: true)

  ROOT = File.expand_path('..', __dir__)

  # The documents worth reading end to end, in the order a newcomer should
  # meet them. Curated rather than globbed: not every `.md` at the root is a
  # guide, and the order is part of the argument. The working documents —
  # the roadmap, the handoff, the daytrip — join the guides because dan's
  # Phase 5 answer names the studio's own md docs a dogfood target: a studio
  # that cannot show its own resume prompt and its own plan is a studio that
  # eats someone else's food.
  GUIDES = %w[README PRIMER VOCABULARY CONTRACT DESIGN KERNEL LORE
              ROADMAP-0.2 ROADMAP-0.3 HANDOFF DAYTRIP BLUESKY].freeze

  def self.guides(ui = Uis.default_ui)
    GUIDES.map { |name| Entry.new(name: name, path: ui.path(ui.paths[:guide], name: name)) }
  end

  # The language's words, as the document lists them — the same scan
  # check_grammar uses. The registry is global and any library may register
  # an app's own words into it (the playground's merged library does), so
  # "registry minus the studio's furniture" is no longer enough: the docs
  # document the language, and the language's one home is VOCABULARY.md.
  def self.vocabulary
    @vocabulary ||= File.read(File.join(ROOT, 'VOCABULARY.md'))
                        .scan(/^### `([a-z_]+)`/).flatten.to_set
  end

  # Every word the language actually knows, from the document — so an app's
  # words, however many libraries register them, never leak into the
  # sidebar. Each word's path is minted by the UI that will serve it.
  def self.words(ui = Uis.default_ui)
    require_relative '../lib/slim_pickins'
    SlimPickins::Library.builtin
    vocabulary.select { |word| SlimPickins::Word.registry.key?(word.to_sym) }.sort
      .map { |word| Entry.new(name: word, path: ui.path(ui.paths[:word], word: word)) }
  end

  # The five-tier deductive authoring hierarchy for the Studio shelf (Volet 4).
  # Each word appears in its primary tier and cross-references any secondary
  # facets (e.g., `card` appears in Structural with badge "visual, semantic",
  # and in Semantic with badge "structural, visual").
  def self.words_by_tier(ui = Uis.default_ui, current: nil)
    require_relative '../lib/slim_pickins/taxonomy'
    SlimPickins::Library.builtin

    SlimPickins::Taxonomy.tiers.map do |tier_key, meta|
      words_in_tier = SlimPickins::Taxonomy.words_for_tier(tier_key)
      valid_words = words_in_tier.select do |word|
        vocabulary.include?(word.to_s) && SlimPickins::Word.registry.key?(word.to_sym)
      end

      entries = valid_words.map do |word|
        entry_meta = SlimPickins::Taxonomy.entry(word)
        other_facets = (entry_meta&.tiers || []) - [tier_key]
        badge_text = other_facets.empty? ? nil : other_facets.join(', ')

        Entry.new(
          name: word.to_s,
          path: ui.path(ui.paths[:word], word: word.to_s),
          role: entry_meta&.role,
          facets: other_facets,
          badge: badge_text,
          active: current.to_s == word.to_s
        )
      end

      TierGroup.new(
        name: tier_key,
        title: "#{meta[:title]} (#{entries.size})",
        question: meta[:question],
        summary: meta[:summary],
        count: entries.size,
        words: entries
      )
    end
  end

  # The payloads, with one home: a plain hash of word name to its contract
  # and implementation. A word's name is a string key here — never a method
  # name — so a docs page is served by lookup, and no word name ever has to
  # survive being dispatched on an OpenStruct whose real methods (`each`,
  # `map`, `send`, `class`...) it might collide with. `build` is the same
  # payloads as an OpenStruct, kept for the playground, where the reader
  # writes `docs.word.contract` by hand and owns the dispatch. The payloads
  # cover the language as the document lists it, so app words registered by
  # other libraries never earn a docs page.
  def self.entries
    @entries ||= begin
      require_relative '../lib/slim_pickins'
      SlimPickins::Library.builtin
      vocabulary.filter_map do |word|
        klass = SlimPickins::Word.registry[word.to_sym]
        next unless klass

        [word, { contract: contract_of(word),
                 implementation: implementation_of(word, klass) }]
      end.to_h
    end
  end

  def self.build = OpenStruct.new(entries)

  def self.contract_of(word)
    contract = SlimPickins::CONTRACTS[word.to_sym]
    contract ? SlimPickins::Contracts.bullets(word, contract).join("\n") : 'No explicit contract defined.'
  end

  # A partial's home is its .sp file, wherever it lives — the class carries
  # its own path (the Library read it), so the docs name it rather than
  # guess it. A Ruby class's home is its declaration, found by scanning the
  # library for `class <Name>` — never by trusting a method's
  # source_location: a class that inherits its `evaluate` (Prose inherits
  # Encloses') would otherwise send the reader to the base class's line, in
  # the wrong file. The declaration scan is the one mechanism for all of
  # them.
  def self.implementation_of(word, klass)
    if klass.respond_to?(:partial_name)
      if (path = klass.source_path)
        "**Type:** App Partial\n(`#{word}.sp`)\n\n**Defined in**\n" \
          "`#{path.sub("#{ROOT}/", '')}`\n\n```sp\n#{File.read(path) rescue 'Source not found'}\n```"
      else
        "**Type:** App Partial\n(declared inline)\n\n**Defined in**\nnowhere on disk"
      end
    else
      file, line = class_declaration(klass)
      if file
        "**Type:** Ruby Class\n(`#{klass.name}`)\n\n**Defined in**\n`#{file}:#{line}`\n\n```ruby\n#{class_body(file, line).strip}\n```"
      else
        "**Type:** Ruby Class\n(`#{klass.name}`)\n\n**Defined in**\nUnknown location"
      end
    end
  end

  # The declaration, not the method: the word's simple name inside its own
  # module. Two files can declare `class Page` (the runtime's Page lives in
  # subject.rb, the word's in words.rb), so a bare name match is not enough
  # — the file must also hold the class's module.
  def self.class_declaration(klass)
    simple = klass.name.split('::').last
    parent = klass.name.split('::')[-2]
    pattern = /^\s*class #{Regexp.escape(simple)}\b/
    library_files.each do |file|
      next unless File.read(file).include?("module #{parent}")

      line = File.readlines(file).index { |l| l =~ pattern }
      return [file.sub("#{ROOT}/", ''), line + 1] if line
    end
    nil
  end

  # The class's own body: from its declaration to the first `end` at the
  # declaration's own indent — inner blocks close first, so the first `end`
  # at the class's indent is the class's.
  def self.class_body(file, line)
    lines = File.readlines(File.join(ROOT, file))
    indent = lines[line - 1][/^\s*/].length
    body = []
    lines[line..].each do |l|
      body << l
      break if l =~ /^#{' ' * indent}end\s*$/
    end
    body.join
  end

  def self.library_files = Dir[File.join(ROOT, 'lib', '**', '*.rb')].sort

  # --- the examples: real sentences, cited ---------------------------------

  # One real sentence from the repo that uses a word — the docs' "In the
  # wild" section. The body is the node's own sentence; the context is the
  # sentence nested in its ancestors, indented as sourced; the citation is
  # the file and line it stands on; the try path seeds the try-it pane with
  # the context; the data is the page's own payload, when the ledger has
  # one.
  Example = Struct.new(:body, :where, :path, :context, :try_path, :data, :note,
                       keyword_init: true)

  EXAMPLES_PER_WORD = 3

  # The try-it's honest limit, said beside the editor: the payload is the
  # page's own, and editing it is steering.
  DATA_NOTE = 'The data slot carries the page\'s payload — synthesized ' \
              'where the example has no page of its own — edit it to steer ' \
              'the page; a refusal names what is missing.'

  # The corpus every example comes from — the same .sp files check_shape
  # measures, so an example exists exactly where the language is really used.
  def self.corpus_files
    Dir[File.join(ROOT, '{pages,examples,lib/vocabulary,studio}', '**', '*.sp')]
  end

  # Built once per boot: walking the whole corpus per docs page would be a
  # cost the studio's restart model does not need. The studio serves booted
  # code, so a new corpus sentence arrives exactly when the process restarts.
  def self.examples
    @examples ||= begin
      index = Hash.new { |h, k| h[k] = [] }
      corpus_files.each do |file|
        tree = SlimPickins::Transform.tree(File.read(file), path: File.basename(file))
        visit = lambda do |nodes, ancestors|
          nodes.each do |node|
            list = index[node.word.to_sym]
            if list.size < EXAMPLES_PER_WORD
              list << [file.sub("#{ROOT}/", ''), node.lineno, node.body,
                       ancestors + [node],
                       ancestors.last ? ancestors.last.children : []]
            end
            visit.call(node.children, ancestors + [node]) unless node.word.to_sym == :def
          end
        end
        visit.call(tree, [])
      end
      index
    end
  end

  # The example's context: the real page's own opening — its page line (the
  # subject's home, load-bearing, never decorative) and the path down to
  # the word, indented as sourced — and the word's own body, two levels
  # deep, because an enclosing word's demonstration *is* its body; deeper
  # still is elided with a comment, so the block stays one honest seed. A
  # partial file has no page line, so its context is the partial's
  # internals, and the try-it wraps those in a page of its own.
  MAX_CONTEXT_DEPTH = 2
  MAX_CONTEXT_SIBLINGS = 3

  def self.context_of(chain, siblings = nil)
    page = chain.find { |node| node.word.to_sym == :page }
    below = chain.reject { |node| node.word.to_sym == :page }
    lines = []
    lines << page.body if page
    below.each_with_index { |node, i| lines << "#{'  ' * (i + 1)}#{node.body}" }
    word = below.last
    if word
      word_level = below.size
      subtree_lines(lines, word.children, word_level + 1, word_level + MAX_CONTEXT_DEPTH)
      add_siblings(lines, siblings, word, word_level)
    end
    lines.join("\n")
  end

  # A registering word's demonstration needs its co-registrations — a
  # `total` is nothing without its columns — so up to three siblings join
  # the context at the word's level, the rest elided.
  def self.add_siblings(lines, siblings, word, level)
    parents = SlimPickins::CONTRACTS.dig(word.word.to_sym, :parents)
    return unless siblings && parents && parents != :any

    others = siblings.reject { |s| s.equal?(word) }
    others.first(MAX_CONTEXT_SIBLINGS).each { |s| lines << "#{'  ' * level}#{s.body}" }
    lines << "#{'  ' * level}# ..." if others.size > MAX_CONTEXT_SIBLINGS
  end

  def self.subtree_lines(lines, nodes, level, max_level)
    nodes.each do |node|
      # Machinery words cannot render in a page — they are not context.
      next if %i[children contents].include?(node.word.to_sym)

      if level > max_level
        marker = "#{'  ' * level}# ..."
        lines << marker unless lines.last == marker
        return
      end

      lines << "#{'  ' * level}#{node.body}"
      subtree_lines(lines, node.children, level + 1, max_level)
    end
  end

  # Words whose seed can never work: their whole meaning is machinery the
  # page context cannot hold. Their examples show context and a note, and
  # carry no Try-it link.
  STRUCTURAL_NOTES = {
    contents: 'lives in a layout — `contents` marks where the page goes, so it has no standalone try.',
    children: 'lives in a partial — `children` splices the caller\'s body, so it has no standalone try.'
  }.freeze

  # Words whose seed works but shows itself only under data the pre-fill
  # does not carry. They keep their Try-it link, beside the note.
  DEMONSTRATION_NOTES = {
    empty: 'shows itself only when its collection is empty — set the collection to [] to see it.',
    otherwise: 'shows itself only when the conditions are false — make the data\'s condition false to see it.'
  }.freeze

  # The examples for one word, shaped for the view: the sentence in its
  # context, its citation, the seed path, and — when the caller supplies a
  # data lookup — the page's own payload for the data slot. Page-rooted
  # examples with a payload rank first, so the first Try-it a reader meets
  # is the one most likely to demonstrate the word; structural words get
  # their note and no link at all.
  def self.examples_of(word, ui: Uis.default_ui)
    data_for = block_given? ? proc { |path, chain| yield(path, chain) } : ->(_p, _c) { '' }
    structural = STRUCTURAL_NOTES.key?(word.to_sym)
    note = STRUCTURAL_NOTES[word.to_sym] || DEMONSTRATION_NOTES[word.to_sym]
    ranked_rows(word, data_for).first(EXAMPLES_PER_WORD).each_with_index.map do |row, i|
      file, line, body, chain, siblings, payload, = row
      Example.new(body: body, where: "#{file}:#{line}", path: file,
                  context: context_of(chain, siblings),
                  try_path: structural ? nil : ui.path(ui.paths[:try], word: word, n: i),
                  data: structural ? '' : payload, note: note)
    end
  end

  # The one ranking the seed and the docs share, so a seed and its data can
  # never come from different examples: page-rooted first, then payloads,
  # then file order.
  def self.ranked_rows(word, data_for)
    examples[word.to_sym].each_with_index.map do |(file, line, body, chain, siblings), index|
      payload = data_for.call(file, chain)
      [file, line, body, chain, siblings, payload,
       chain.first.word.to_sym == :page ? 0 : 1, payload.empty? ? 1 : 0, index]
    end.sort_by { |row| [row[6], row[7], row[8]] }
  end

  # The try-it's seed: the example's context. A page-rooted example is the
  # real page's own opening — a complete document, subject shift included —
  # so it seeds verbatim; a partial file's internals get a page of their
  # own. `index` 0 is the default when no `try` is asked for; an index past
  # the list means nothing to seed. The same ranking as `examples_of`, so a
  # seed and its data never come from different examples.
  def self.seed_for(word, index)
    return nil if STRUCTURAL_NOTES.key?(word.to_sym)

    row = index && ranked_rows(word, ->(_p, _c) { '' })[index]
    return nil unless row

    chain = row[3]
    context = context_of(chain, row[4])
    return context if chain.first.word.to_sym == :page

    "page \"Try: #{word}\"\n#{context}\n"
  end
end
