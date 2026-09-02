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
    attr_reader :layout, :partials, :words, :app_partials

    # The language's own vocabulary, written as partials — the dogfood made
    # visible: new words are drafted in the language itself, in
    # lib/vocabulary, and every app gets them. Promotion to a Ruby built-in
    # is a round-end decision, not an assumption.
    VOCABULARY_DIR = File.expand_path('../vocabulary', __dir__)

    def self.from(dir, words: nil)
      dir = File.expand_path(dir)
      layout_path = File.join(dir, 'layout.sp')
      partials = Dir[File.join(dir, 'partials', '*.sp')].to_h do |path|
        [File.basename(path, '.sp').to_sym, File.read(path)]
      end
      new(layout: (File.read(layout_path) if File.exist?(layout_path)), partials: partials, words: words)
    end

    # `words:` is the escape hatch: one module whose methods become words —
    # or several, in an array, so an app's words may be written in parts and
    # delegate to each other — written in Ruby because the thing they render
    # has no word yet. See Builder's "escape hatch" section for the surface
    # they may use.
    def initialize(layout: nil, partials: {}, words: nil)
      @layout = layout
      app_partials = partials.transform_keys(&:to_sym)
      vocabulary = self.class.builtin_partials
      dupes = app_partials.keys & vocabulary.keys
      unless dupes.empty?
        raise Error, "`#{dupes.first}` is already a slim-pickins word — an app cannot redefine it"
      end

      @app_partials = app_partials
      @partials = vocabulary.merge(app_partials)
      @words = words.nil? ? [] : Array(words)
      refuse_shadowing!
    end

    # The vocabulary is built in — a promoted word is a word everywhere, not
    # something an app opts into by loading a library.
    def self.builtin_partials
      @builtin_partials ||= Dir[File.join(VOCABULARY_DIR, '*.sp')].to_h do |path|
        [File.basename(path, '.sp').to_sym, File.read(path)]
      end
    end

    # The library every render gets when the app passes none.
    def self.builtin
      @builtin ||= new
    end

    def word?(name) = @partials.key?(name)

    def source_for(name) = @partials.fetch(name)

    private

    # Two meanings for one word is the alias problem wearing a new hat, so a
    # collision is an error rather than an override. The vocabulary's own
    # partials are words, not app words — they pass the check by right.
    def refuse_shadowing!
      require_relative 'builder'
      vocabulary = Dir[File.join(VOCABULARY_DIR, '*.sp')].map { |p| File.basename(p, '.sp').to_sym }
      app_words = (@partials.keys - vocabulary) + @words.flat_map(&:instance_methods)
      app_words.each do |name|
        next unless Builder::WORDS.include?(name)

        raise Error, "`#{name}` is already a slim-pickins word — an app cannot redefine it"
      end
      duplicated = app_words.tally.select { |_, n| n > 1 }.keys
      return if duplicated.empty?

      raise Error, "`#{duplicated.first}` is defined twice — as a partial and in Ruby"
    end
  end
end
