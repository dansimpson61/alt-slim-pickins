require 'ostruct'
require 'set'
module StudioDocs
  # One link in the sidebar. A plain Struct is the app contract satisfied with
  # no ceremony, which is the point — `each word` binds one of these and the
  # view reads `.name` and `.path` off it.
  Entry = Struct.new(:name, :path, keyword_init: true)

  ROOT = File.expand_path('..', __dir__)

  # The documents worth reading end to end, in the order a newcomer should
  # meet them. Curated rather than globbed: not every `.md` at the root is a
  # guide, and the order is part of the argument. The working documents —
  # the roadmap, the handoff, the daytrip — join the guides because dan's
  # Phase 5 answer names the studio's own md docs a dogfood target: a studio
  # that cannot show its own resume prompt and its own plan is a studio that
  # eats someone else's food.
  GUIDES = %w[README PRIMER VOCABULARY CONTRACT DESIGN KERNEL LORE
              ROADMAP-0.2 ROADMAP-0.3 HANDOFF DAYTRIP].freeze

  def self.guides = GUIDES.map { |name| Entry.new(name: name, path: "/guides/#{name}") }

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
  # sidebar.
  def self.words
    require_relative '../lib/slim_pickins'
    SlimPickins::Library.builtin
    vocabulary.select { |word| SlimPickins::Word.registry.key?(word.to_sym) }.sort
      .map { |word| Entry.new(name: word, path: "/docs/#{word}") }
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
  Example = Struct.new(:body, :where, :path, :context, :try_path, :data,
                       keyword_init: true)

  EXAMPLES_PER_WORD = 3

  # The try-it's honest limit, said beside the editor: the payload is the
  # page's own, and editing it is steering.
  DATA_NOTE = 'The data slot carries the page\'s own payload — edit it to ' \
              'steer the page; a refusal names what is missing.'

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
                       ancestors + [node]]
            end
            visit.call(node.children, ancestors + [node])
          end
        end
        visit.call(tree, [])
      end
      index
    end
  end

  # The example's context: the real page's own opening — its page line (the
  # subject's home, load-bearing, never decorative) and the path down to
  # the word, indented as sourced. A partial file has no page line, so its
  # context is the partial's internals, and the try-it wraps those in a
  # page of its own.
  def self.context_of(chain)
    page = chain.find { |node| node.word.to_sym == :page }
    below = chain.reject { |node| node.word.to_sym == :page }
    lines = []
    lines << page.body if page
    lines.concat(below.each_with_index.map { |node, i| "#{'  ' * (i + 1)}#{node.body}" })
    lines.join("\n")
  end

  # The examples for one word, shaped for the view: the sentence in its
  # context, its citation, the seed path, and — when the caller supplies a
  # data lookup — the page's own payload for the data slot.
  def self.examples_of(word)
    data_for = block_given? ? proc { |path| yield(path) } : ->(_path) { '' }
    examples[word.to_sym].each_with_index.map do |(file, line, body, chain), i|
      Example.new(body: body, where: "#{file}:#{line}", path: file,
                  context: context_of(chain), try_path: "/docs/#{word}?try=#{i}",
                  data: data_for.call(file))
    end
  end

  # The try-it's seed: the example's context. A page-rooted example is the
  # real page's own opening — a complete document, subject shift included —
  # so it seeds verbatim; a partial file's internals get a page of their
  # own. `index` 0 is the default when no `try` is asked for; an index past
  # the list means nothing to seed.
  def self.seed_for(word, index)
    list = examples[word.to_sym]
    return nil unless index && list[index]

    chain = list[index][3]
    context = context_of(chain)
    return context if chain.first.word.to_sym == :page

    "page \"Try: #{word}\"\n#{context}\n"
  end
end
