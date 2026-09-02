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
    attr_reader :layout, :partials, :words

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
      @partials = partials.transform_keys(&:to_sym)
      @words = words.nil? ? [] : Array(words)
      refuse_shadowing!
    end

    def word?(name) = @partials.key?(name)

    def source_for(name) = @partials.fetch(name)

    private

    # Two meanings for one word is the alias problem wearing a new hat, so a
    # collision is an error rather than an override.
    def refuse_shadowing!
      require_relative 'builder'
      app_words = @partials.keys + @words.flat_map(&:instance_methods)
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
