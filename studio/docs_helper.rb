require 'ostruct'
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
              ROADMAP-0.2 HANDOFF DAYTRIP design_conventions].freeze

  def self.guides = GUIDES.map { |name| Entry.new(name: name, path: "/guides/#{name}") }

  # The studio's own partials register as words too — `editor`, `preview`,
  # `split_pane`. They are this app's furniture, not the language, so the
  # sidebar leaves them out. Named explicitly rather than relying on being
  # read before the studio's library loads, which would be true today and
  # silently false the first time a line moved.
  FURNITURE = Dir[File.join(__dir__, 'views', 'partials', '*.sp')]
              .map { |f| File.basename(f, '.sp') }.freeze

  # Every word the language actually knows. The sidebar used to be 77
  # hand-written `link` sentences, which could disagree with the vocabulary
  # and had no way to say so. Read from the registry, it cannot.
  def self.words
    require_relative '../lib/slim_pickins'
    SlimPickins::Library.builtin
    (SlimPickins::Word.registry.keys.map(&:to_s) - FURNITURE).sort
      .map { |word| Entry.new(name: word, path: "/docs/#{word}") }
  end

  # The payloads, with one home: a plain hash of word name to its contract
  # and implementation. A word's name is a string key here — never a method
  # name — so a docs page is served by lookup, and no word name ever has to
  # survive being dispatched on an OpenStruct whose real methods (`each`,
  # `map`, `send`, `class`...) it might collide with. `build` is the same
  # payloads as an OpenStruct, kept for the playground, where the reader
  # writes `docs.word.contract` by hand and owns the dispatch.
  def self.entries
    @entries ||= begin
      require_relative '../lib/slim_pickins'
      SlimPickins::Library.builtin
      SlimPickins::Word.registry.keys.sort.to_h do |name|
        word = name.to_s
        [word, { contract: contract_of(word),
                 implementation: implementation_of(word, SlimPickins::Word.registry[name]) }]
      end
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
end
