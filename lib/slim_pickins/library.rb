# frozen_string_literal: true

require_relative 'errors'
require_relative 'word'

module SlimPickins
  # An app's own vocabulary. A partial is not a new construct — it is a word
  # the app defines, written in the language, invoked exactly like a built-in.
  # slim-pickins owns the vocabulary of presentation; an app owns the
  # vocabulary of its own components.
  #
  # A tin is the same idea one level up: the chrome every page shares, written
  # once as `[name].tin`, with `contents` marking where the page goes. The
  # word for it used to be "layout", which named the presentation the design
  # idiom now owns; a tin is the modest metal over the building, and
  # `[name].tin` sits beside `[name].spiff` as one concern per file.
  class Library
    attr_reader :frame, :frames, :tin, :tins, :partials, :words, :app_partials, :compiled_partials, :dir, :public_url

    # The language's own vocabulary, written as partials — the dogfood made
    # visible: new words are drafted in the language itself, in
    # lib/vocabulary, and every app gets them. Promotion to a Ruby built-in
    # is a round-end decision, not an assumption.
    VOCABULARY_DIR = File.expand_path('../vocabulary', __dir__)

    # The frame's home on disk: `[app].frame` (formerly `[app].tin`), named for
    # the app it frames, so it sits beside that app's views.
    def self.frame_path(dir)
      dir = File.expand_path(dir)
      app = File.basename(dir)
      outer = File.basename(File.dirname(dir))
      [File.join(dir, "#{app}.frame"),
       File.join(dir, 'views', "#{app}.frame"),
       File.join(dir, "#{outer}.frame"),
       File.join(File.dirname(dir), "#{outer}.frame"),
       File.join(dir, "#{app}.tin"),
       File.join(dir, 'views', "#{app}.tin"),
       File.join(dir, "#{outer}.tin"),
       File.join(File.dirname(dir), "#{outer}.tin")].find { |path| File.file?(path) }
    end
    singleton_class.alias_method :tin_path, :frame_path

    # Where a directory's views are: the directory itself when it holds `.sp`
    # files (a studio UI keeps its pages in `views/`, and is handed the root),
    # else a `views/` beneath it (an example app). One reading, used by both
    # `from` and the per-view lookups so a page and its frame are never found by
    # two different rules.
    def self.views_dir(dir)
      dir = File.expand_path(dir)
      return dir unless Dir[File.join(dir, '*.sp')].empty?

      nested = File.join(dir, 'views')
      Dir.exist?(nested) ? nested : dir
    end

    # Every view that carries its own frame, by view name. A view's frame is
    # `<view>.frame` beside the app's, and it beats the app's.
    def self.view_frames(dir)
      frames = Dir[File.join(views_dir(dir), '*.frame')].to_h do |path|
        [File.basename(path, '.frame'), File.read(path)]
      end
      tins = Dir[File.join(views_dir(dir), '*.tin')].to_h do |path|
        [File.basename(path, '.tin'), File.read(path)]
      end
      tins.merge(frames)
    end
    singleton_class.alias_method :view_tins, :view_frames

    def self.from(dir, words: nil, public_url: nil)
      dir = File.expand_path(dir)
      file = frame_path(dir)
      partials = {}
      partial_paths = {}
      Dir[File.join(dir, 'partials', '*.sp')].each do |path|
        name = File.basename(path, '.sp').to_sym
        partials[name] = File.read(path)
        partial_paths[name] = path
      end
      new(frame: (File.read(file) if file),
          frames: view_frames(dir),
          partials: partials, partial_paths: partial_paths, words: words,
          dir: dir, public_url: public_url)
    end

    def initialize(frame: nil, frames: {}, tin: nil, tins: {}, partials: {}, partial_paths: {}, words: nil, dir: nil,
                   public_url: nil)
      @frame = frame || tin
      @frames = (tins || {}).merge(frames || {})
      @tin = @frame
      @tins = @frames
      @public_url = public_url
      @dir = dir
      app_partials = partials.transform_keys(&:to_sym)
      vocabulary = self.class.builtin_partials

      @app_partials = app_partials
      @partials = vocabulary.merge(app_partials)
      # A partial's file is part of what it is — the docs name it, and a
      # word without its home cannot be documented truthfully. Read in the
      # same glob that read the source, so path and source can never drift.
      @partial_paths = self.class.builtin_partial_paths.merge(partial_paths.transform_keys(&:to_sym))
      @words = words.nil? ? [] : Array(words)
      refuse_shadowing!
      
      @compiled_partials = self.class.builtin_compiled_partials.dup
      @app_partials.each do |word, source|
        # `fetch(word, nil)`: a partial declared inline (Library.new with
        # bare sources) has no file, and that is a real state — its docs
        # say so — not a reason to refuse the library.
        @compiled_partials[word] = Compilation.compile_partial(word, source, false, @partial_paths[word])
      end
    end

    def self.builtin_compiled_partials
      @builtin_compiled_partials ||= begin
        paths = builtin_partial_paths
        builtin_partials.to_h do |word, source|
          [word, Compilation.compile_partial(word, source, true, paths[word])]
        end
      end
    end

    # The vocabulary is built in — a promoted word is a word everywhere, not
    # something an app opts into by loading a library.
    def self.builtin_partial_paths
      @builtin_partial_paths ||= begin
        paths = {}
        Dir[File.join(VOCABULARY_DIR, '*.sp')].sort.each do |path|
          base = File.basename(path, '.sp').to_sym
          paths[base] = path
          File.read(path).scan(/^\s*def\s+([a-zA-Z0-9_]+)/).flatten.each do |child|
            child_sym = child.to_sym
            paths[child_sym] = path
            if child_sym != base
              Word.register_family(base, child_sym)
            end
          end
        end
        paths
      end
    end

    def self.builtin_partials
      @builtin_partials ||= builtin_partial_paths.transform_values { |path| File.read(path) }
    end

    # The library every render gets when the app passes none.
    def self.builtin
      @builtin ||= new
    end

    def compiled_partial(word) = @compiled_partials[word.to_sym]

    def word?(name) = @partials.key?(name)

    def source_for(name) = @partials.fetch(name)

    # The tin a page wears: its own if it has one, else the app's.
    #
    # This is the only place the rule lives. It used to live in the studio, so
    # the language did not know a page could have its own chrome and only the
    # studio could find the document that said so.
    def frame_for(view = nil)
      return @frame unless view

      @frames.fetch(view.to_s) { @frame }
    end
    alias_method :tin_for, :frame_for

    # The Layout a page is presented by: `[view].layout` beside it, else the
    # app's companion.
    def self.layout_for(view = nil, path: nil, app: nil)
      found = view_layout(view, path) || app || app_layout(path)
      found && File.read(found)
    end
    singleton_class.alias_method :spiff_for, :layout_for

    def self.view_layout(view, path)
      dir = path ? File.dirname(path.to_s) : nil
      return nil unless dir

      names = [view, File.basename(dir)].compact.uniq.reject(&:empty?)
      candidates = names.map { |name| File.join(dir, "#{name}.layout") } +
                   names.map { |name| File.join(dir, "#{name}.spiff") }
      candidates.find { |file| File.file?(file) }
    end
    singleton_class.alias_method :view_spiff, :view_layout

    def self.app_layout(path)
      return nil unless path

      dir = File.dirname(path.to_s)
      inner = File.basename(dir)
      outer = File.basename(File.dirname(dir))
      [File.join(dir, "#{inner}.layout"),
       File.join(File.dirname(dir), "#{outer}.layout"),
       File.join(dir, "#{inner}.spiff"),
       File.join(File.dirname(dir), "#{outer}.spiff")].find { |file| File.file?(file) }
    end
    singleton_class.alias_method :app_spiff, :app_layout

    # An app's stylesheets live in its own public directory, named for what
    # they style: `public/css/[app].css`, or `public/css/[view].css` for one
    # view. The view's word wins, as it does for tins and Spiffs.
    #
    # This is roth's layout, which is the only app that has ever had styles of
    # its own — `public/css/roth.css` — so the convention was read off a
    # working example rather than invented and then found unservable.
    #
    # A page gets the app's or its own *only when the app says where its public
    # directory is served*. The on-disk convention is one rule; the URL is not
    # derivable from it, because each app hands Sinatra a different public
    # folder (an example hands it the repo root, so its files are served under
    # `examples/…`; roth hands it its own `public/`). Emitting a guessed URL
    # would be a stylesheet the app cannot serve, which is worse than no line
    # at all.
    def self.public_dir(path)
      return nil unless path

      dir = File.dirname(path.to_s)
      base = File.basename(dir) == 'views' ? File.dirname(dir) : dir
      candidate = File.join(base, 'public')
      Dir.exist?(candidate) ? candidate : nil
    end

    # The style a page wears of its own or its app's: `[view].css` first, then
    # `[app].css`, in the app's public directory.
    def self.own_stylesheet(view, path, public_dir: nil)
      public_dir ||= self.public_dir(path)
      return nil unless public_dir && view

      app = File.basename(File.dirname(public_dir))
      [view, app].uniq.map { |name| File.join(public_dir, 'css', "#{name}.css") }
                    .find { |file| File.file?(file) }
    end

    # The stylesheets a page gets without saying so, in precedence order:
    # slim-pickins' own, then the page's or its app's.
    #
    # The base is the language's and every page has it, so it is never looked
    # for. The other is found only if it exists — and only announced when
    # `public_url` says where the app serves its public directory, so silence
    # stays the normal case and never costs a 404.
    BASE_STYLESHEET = '/assets/slim-pickins.css'

    def stylesheets_for(view, path: nil, public_dir: nil, url: nil)
      return [BASE_STYLESHEET] unless url

      own = self.class.own_stylesheet(view, path, public_dir: public_dir)
      # `File.join` answers `"/css/roth.css"` for both an empty prefix (roth,
      # which serves its `public/` at its root) and `"/public"`, where a naive
      # join leaves a doubled slash.
      [BASE_STYLESHEET, own && File.join(url.to_s, 'css', File.basename(own))].compact
    end

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

    # The language words this library shadows.
    # An app may define a partial or Ruby word that shares a name with a
    # vocabulary partial or Ruby primitive (ruled 2026-10-05) — the app's
    # word wins inside this library (nearest wins), and the gate reports it.
    def shadowed_words
      builtins = self.class.builtin_partials.keys | self.class.primitive_keys
      (@app_partials.keys | word_names) & builtins
    end

    def self.primitive_keys
      @primitive_keys ||= SlimPickins::Word.registry.select do |_, klass|
        klass.name.to_s.start_with?('SlimPickins::Words::')
      end.keys
    end

    private

    # An app may shadow a language word (ruled 2026-10-05: allowed, nearest
    # wins, and the gate reports it). But within the app itself, one word may
    # not have two definitions — defining it both as a partial and in Ruby
    # is refused because one name must have one home.
    def refuse_shadowing!
      app_words = @app_partials.keys + word_names
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

    builtin_partial_paths
  end
end
