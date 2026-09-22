# frozen_string_literal: true

require_relative 'errors'

module SlimPickins
  # An app's own vocabulary. A partial is not a new construct — it is a word
  # the app defines, written in the language, invoked exactly like a built-in.
  # slim-pickins owns the vocabulary of presentation; an app owns the
  # vocabulary of its own components.
  #
  # A layout is the same idea one level up: the chrome every page shares,
  # written once, with `contents` marking where the page goes.
  class Library
    attr_reader :layout, :partials, :words, :app_partials, :dir

    # The language's own vocabulary, written as partials — the dogfood made
    # visible: new words are drafted in the language itself, in
    # lib/vocabulary, and every app gets them. Promotion to a Ruby built-in
    # is a round-end decision, not an assumption.
    VOCABULARY_DIR = File.expand_path('../vocabulary', __dir__)

    def self.from(dir, words: nil)
      dir = File.expand_path(dir)
      layout_path = File.join(dir, 'layout.sp')
      partials = {}
      partial_paths = {}
      Dir[File.join(dir, 'partials', '*.sp')].each do |path|
        name = File.basename(path, '.sp').to_sym
        partials[name] = File.read(path)
        partial_paths[name] = path
      end
      new(layout: (File.read(layout_path) if File.exist?(layout_path)),
          partials: partials, partial_paths: partial_paths, words: words,
          dir: dir)
    end

    # `words:` is the escape hatch: one module whose methods become words —
    # or several, in an array, so an app's words may be written in parts and
    # delegate to each other — written in Ruby because the thing they render
    # has no word yet. See Builder's "escape hatch" section for the surface
    # they may use.
    def initialize(layout: nil, partials: {}, partial_paths: {}, words: nil, dir: nil)
      @layout = layout
      @dir = dir
      app_partials = partials.transform_keys(&:to_sym)
      vocabulary = self.class.builtin_partials
      dupes = app_partials.keys & vocabulary.keys
      unless dupes.empty?
        raise Error, "`#{dupes.first}` is already a slim-pickins word — an app cannot redefine it"
      end

      @app_partials = app_partials
      @partials = vocabulary.merge(app_partials)
      # A partial's file is part of what it is — the docs name it, and a
      # word without its home cannot be documented truthfully. Read in the
      # same glob that read the source, so path and source can never drift.
      @partial_paths = self.class.builtin_partial_paths.merge(partial_paths.transform_keys(&:to_sym))
      @words = words.nil? ? [] : Array(words)
      refuse_shadowing!
      
      @partials.each do |word, source|
        # `fetch(word, nil)`: a partial declared inline (Library.new with
        # bare sources) has no file, and that is a real state — its docs
        # say so — not a reason to refuse the library.
        Compilation.compile_partial(word, source, vocabulary.key?(word), @partial_paths[word])
      end
    end

    # The vocabulary is built in — a promoted word is a word everywhere, not
    # something an app opts into by loading a library.
    def self.builtin_partial_paths
      @builtin_partial_paths ||= Dir[File.join(VOCABULARY_DIR, '*.sp')].to_h do |path|
        [File.basename(path, '.sp').to_sym, path]
      end
    end

    def self.builtin_partials
      @builtin_partials ||= builtin_partial_paths.transform_values { |path| File.read(path) }
    end

    # The library every render gets when the app passes none.
    def self.builtin
      @builtin ||= new
    end

    def word?(name) = @partials.key?(name)

    def source_for(name) = @partials.fetch(name)

    # Render a named page or partial directly from this library.
    def render(name, locals: {}, helpers: nil, filter: nil)
      path = if @dir
               File.join(@dir, "#{name}.sp")
             elsif @partial_paths.key?(name.to_sym)
               @partial_paths[name.to_sym]
             end

      source = if path && File.exist?(path)
                 File.read(path)
               elsif @partials.key?(name.to_sym)
                 @partials[name.to_sym]
               else
                 raise Error, "template `#{name}` not found in library"
               end

      SlimPickins.render(source, path: path || "(#{name})", locals: locals, helpers: helpers, library: self, filter: filter)
    end

    private

    # Two meanings for one word is the alias problem wearing a new hat, so a
    # collision is an error rather than an override. The vocabulary's own
    # partials are words, not app words — they pass the check by right.
    def refuse_shadowing!
      vocabulary = self.class.builtin_partial_paths.keys
      app_words = (@partials.keys - vocabulary) + word_names
      
      app_words.each do |name|
        primitive_keys = SlimPickins::Words.constants.map do |c|
          c.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
                 gsub(/([a-z\d])([A-Z])/,'\1_\2').
                 tr("-", "_").
                 downcase.to_sym
        end
        if primitive_keys.include?(name)
          raise Error, "`#{name}` is already a slim-pickins word — an app cannot redefine it"
        end
      end

      duplicated = app_words.tally.select { |_, n| n > 1 }.keys
      return if duplicated.empty?

      raise Error, "`#{duplicated.first}` is defined twice — as a partial and in Ruby"
    end

    # The names the app's own word modules declare.
    #
    # Each module in the ancestry is read for *its own* instance methods,
    # never `instance_methods`, which answers with everything the module
    # inherited as well. That difference is not academic: a module which
    # includes a shared one would otherwise offer `Kernel#format` and
    # `Object#hash` as words, and this check would refuse the language's own
    # `format` as a duplicate.
    #
    # The same word declared once through two modules that share an ancestor
    # is *one* word, not two: an interface kata is exactly that shape. Two
    # different implementations of one name are the alias problem, and are
    # still refused — the name's home must be one module, or the app cannot
    # say which of them a page means.
    def word_names
      declared = @words.each_with_object({}) do |mod, out|
        next unless mod.is_a?(Module)

        mod.ancestors.each do |ancestor|
          next unless ancestor.is_a?(Module)

          ancestor.public_instance_methods(false).each { |name| (out[name] ||= []) << ancestor }
        end
      end

      declared.each_with_object([]) do |(name, homes), names|
        implementations = homes.uniq
        if implementations.size > 1
          raise Error, "`#{name}` is declared by two apps' words in one library — " \
                       "one name must have one home"
        end

        names << name
      end
    end
  end
end
