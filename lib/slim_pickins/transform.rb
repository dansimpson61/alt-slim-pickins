# frozen_string_literal: true

require_relative 'contracts'

module SlimPickins
  # Turns a page into Ruby source: indentation becomes blocks, and every
  # sentence becomes a method call on the builder, wrapped in `with_line` so
  # the builder always knows which sentence it is evaluating — the seam that
  # lets a runtime error name the line.
  #
  #   section holdings          with_line(3) do
  #     title .name        =>     section(:holdings) do
  #                                 with_line(4) do
  #                                   title(subject.name)
  #                                 end
  #                               end
  #                             end
  #
  # The transform is deliberately thin. It does not know what any word means —
  # that is the vocabulary's business — and it does not parse Ruby, because
  # every argument is already valid Ruby once a bare name becomes a symbol and
  # a leading dot becomes the subject.
  class Transform
    def contract_for(word) = CONTRACTS[word.to_sym]

    # A sentence lands when its word moves "it" and the sentence names where
    # to. Gatherers are left out: `table` and `chart` declare a shift, but
    # their children run against each row and nothing beneath them sees the
    # collection as "it", so there is nowhere for their content to land.
    def lands?(contract, ranks)
      contract && contract.subject == :shift && contract.shape != :gathers && ranks.include?(0)
    end
    WORD    = /\A[a-z][a-z0-9_]*\z/
    NAME    = /\A[a-z][a-z0-9_]*\z/
    DOTTED  = /\A\.([a-z_][a-z0-9_-]*\??)\z/
    BINDING = /\A[a-z_][a-z0-9_-]*(\.[a-z0-9_-]+\??)+\z/
    MODIFIER = /\A([a-z0-9_-]+):\s*(.+)\z/m

    # Words the host language reserves. A page may still use them — `when` is
    # part of the vocabulary — so the transform routes them past Ruby's parser
    # rather than the language giving up its own word.
    RESERVED = %w[when in if unless else end do then case while until for next
                  break return class module def begin rescue ensure yield self
                  nil true false and or not redo retry super alias undef].freeze

    Sentence = Struct.new(:indent, :body, :lineno)

    # One parsed sentence with its children — the tree the checker walks to
    # enforce government, built by the same indentation rule that builds the
    # Ruby. `word` is the leading word, `raw_args` the arguments as written,
    # `ranks` each argument's kind (0 name, 1 content or data, 2 modifier) and
    # `compiled` the Ruby each argument becomes.
    #
    # `guard` is the Ruby an `if:` modifier carried, hoisted out of the
    # arguments. `if:` is universal, and it is the transform that honours it
    # rather than the words, because a word does not always get a say: an app
    # word added through the hatch is `extend`ed onto the builder and never
    # passes through the dispatch a registry word does. Hoisting it also means
    # the guard runs *before* the sentence's other arguments, and before a
    # word's children — so a guarded sentence costs nothing and evaluates
    # nothing, which is the same choice `when` makes for its condition.
    Node = Struct.new(:indent, :body, :lineno, :word, :raw_args, :ranks, :compiled, :guard, :children,
                      keyword_init: true)

    # A `.sp` file that is not a partial is a route: its first sentence is the
    # route's signature (subject, title, modifiers), and its filename is the
    # word. The transform must know which files are routes to read that first
    # sentence as arguments rather than as `word arguments`.
    def self.route?(path)
      p = path.to_s
      p.end_with?('.sp') && !p.include?('partials/') && !p.include?('vocabulary/')
    end

    def self.call(source, path: 'page.sp', route: nil)
      new(source, path, route: route).call
    end

    def self.tree(source, path: 'page.sp', route: nil)
      new(source, path, route: route).tree
    end

    def initialize(source, path, route: nil)
      @source = source
      @path = path
      @route = route.nil? ? self.class.route?(path) : route
    end

    def call
      defs, rest = tree.partition { |n| n.word == 'def' }
      "#{emit(defs + rest).join("\n")}\n"
    end

    def tree
      @tree ||= begin
        stack = []
        nodes = []
        first = true
        sentences.each do |s|
          node = build(s, first: first)
          # A route's signature is its first top-level sentence that is not a
          # `def` — a `def` word (and its indented body) may precede it, so
          # "first" survives until the first indentation-zero non-def sentence.
          first = false if s.indent.zero? && !s.body.start_with?('def ')
          stack.pop while stack.any? && s.indent <= stack.last.indent
          (stack.any? ? stack.last.children : nodes) << node
          stack << node
        end
        nodes
      end
    end

    private

    def emit(nodes, depth = 0)
      nodes.flat_map do |n|
        next [] if n.word == 'expects'

        pad = '  ' * depth

        if n.word == 'def'
          word_name = n.compiled.first
          params = "[#{n.compiled.drop(1).join(', ')}]"
          [
            "#{pad}define_local_word(#{word_name}, #{params}) do",
            *emit(n.children, depth + 1),
            "#{pad}end"
          ]
        elsif n.word == :route
          ruby = "route(#{n.compiled.join(', ')})"
          if n.children.any?
            ["#{pad}with_line(#{n.lineno}) do", "#{pad}  #{ruby} do",
             *emit(n.children, depth + 2), "#{pad}  end", "#{pad}end"]
          else
            ["#{pad}with_line(#{n.lineno}) do", "#{pad}  #{ruby}", "#{pad}end"]
          end
        else
          ruby = if RESERVED.include?(n.word)
                   "send(#{([":#{n.word}", *n.compiled]).join(', ')})"
                 elsif n.compiled.empty?
                   n.word
                 else
                   "#{n.word}(#{n.compiled.join(', ')})"
                 end
          # The guard sits inside `with_line`, before the word and its children:
          # `next` leaves the block, so the word never runs and neither does
          # anything nested under it.
          guard = n.guard ? ["#{pad}  next unless SlimPickins::Inference.truthy?(#{n.guard})"] : []
          # Children nest two levels deeper than their sentence — one for
          # with_line's block, one for the word's own.
          if n.children.any?
            ["#{pad}with_line(#{n.lineno}) do", *guard, "#{pad}  #{ruby} do",
             *emit(n.children, depth + 2), "#{pad}  end", "#{pad}end"]
          else
            ["#{pad}with_line(#{n.lineno}) do", *guard, "#{pad}  #{ruby}", "#{pad}end"]
          end
        end
      end
    end

    def build(sentence, first: false)
      word, _, rest = sentence.body.partition(' ')

      # A route's leading sentence is its signature — no word, only arguments.
      # Three shapes can only be a signature: a title alone (`"The Publication"`),
      # which opens with a quote; a subject whose comma is part of the first
      # token (`document, .title`); and a bare subject with no title and no
      # comma (`portfolio`), which names nothing the vocabulary knows. A word
      # invocation never takes any of the three, so a fragment that opens with a
      # real word (`grid .name`, `section accounts`) reads as a word.
      if first && @route && route_signature?(word, rest)
        return route_signature(sentence)
      end

      unless word =~ WORD
        raise SyntaxError.new("#{word.inspect} is not a word", @path, sentence.lineno, sentence.body)
      end

      if word == 'def'
        def_target, params_str = if rest =~ /\A([a-z][a-z0-9_]*)(?:,\s*|\s+)(.*)\z/
                                   [$1, $2]
                                 elsif rest =~ /\A([a-z][a-z0-9_]*)\z/
                                   [$1, '']
                                 else
                                   raise SyntaxError.new("invalid def signature #{rest.inspect}", @path, sentence.lineno, sentence.body)
                                 end
        params = split_args(params_str)
        raw = [def_target, *params]
        compiled = raw.map { |a| ":#{a}" }
        ranks = [0] * raw.size
        return Node.new(indent: sentence.indent, body: sentence.body, lineno: sentence.lineno,
                        word: word, raw_args: raw, ranks: ranks, compiled: compiled, guard: nil,
                        children: [])
      end

      raw = split_args(rest)
      compiled = raw.map { |a| argument(a, sentence) }
      ranks = raw.map { |a| rank(a) }
      contract = contract_for(word)
      if contract&.lazy&.include?(:content) || lands?(contract, ranks)
        # A word whose shape declares lazy content receives it unevaluated,
        # so its guard can fire before the argument runs. `when` was the one
        # hardcoded case; now laziness is a declared capability any word —
        # built-in, vocabulary partial, or an app's own — may claim.
        #
        # And a sentence that names where it lands reads its content there:
        # `page document, .title` is the document's title, because a dot
        # means "it" and this sentence is about the document (2026-10-04).
        raw.each_with_index do |arg, i|
          compiled[i] = "-> { #{compiled[i]} }" if ranks[i] == 1
        end
      end
      if ranks != ranks.sort
        late = ranks.each_cons(2).find_index { |earlier, later| earlier > later }
        raise SyntaxError.new(
          "#{KINDS[ranks[late + 1]]} may not come after #{KINDS[ranks[late]]} — " \
          'a name, then content or data, then modifiers',
          @path, sentence.lineno, sentence.body
        )
      end

      # `if:` is hoisted out of the arguments and into a guard. It is universal,
      # so no word declares it and no word needs to read it; and a word cannot
      # be the place it is honoured, because a hatch word never passes through
      # the dispatch. Removing it from the arguments also means the predicate is
      # evaluated once, by the guard, rather than twice.
      guard = nil
      raw.each_with_index do |arg, i|
        next unless ranks[i] == 2 && arg.match?(/\Aif:\s*.+\z/m)

        guard = compiled[i].sub(/\Aif:\s*/, '')
        raw = raw.reject.with_index { |_, j| j == i }
        ranks = ranks.reject.with_index { |_, j| j == i }
        compiled = compiled.reject.with_index { |_, j| j == i }
        break
      end

      Node.new(indent: sentence.indent, body: sentence.body, lineno: sentence.lineno,
               word: word, raw_args: raw, ranks: ranks, compiled: compiled, guard: guard,
               children: [])
    end

    # Whether a route's first sentence is its signature rather than a word
    # invocation. A signature is a quoted title, a comma-led subject, a lone
    # dotted value (a title read from the subject), or a bare name the
    # vocabulary does not know — never a word.
    def route_signature?(word, rest)
      return true if word.start_with?('"') || word.end_with?(',') || word.match?(DOTTED)

      rest.empty? && word =~ WORD && contract_for(word).nil? && !SlimPickins::Word.registry.key?(word.to_sym)
    end

    # A route's leading sentence is its signature — subject, title, modifiers —
    # with no word, because the filename is the word. It compiles to a `route`
    # call the Builder reads, with content landed lazily under the subject the
    # way `page`'s arguments did.
    def route_signature(sentence)
      raw = split_args(sentence.body)
      compiled = raw.map { |a| argument(a, sentence) }
      ranks = raw.map { |a| rank(a) }
      if ranks != ranks.sort
        late = ranks.each_cons(2).find_index { |earlier, later| earlier > later }
        raise SyntaxError.new(
          "#{KINDS[ranks[late + 1]]} may not come after #{KINDS[ranks[late]]} — " \
          'a name, then content or data, then modifiers',
          @path, sentence.lineno, sentence.body
        )
      end
      compiled = compiled.each_with_index.map { |c, i| ranks[i] == 1 ? "-> { #{c} }" : c }
      Node.new(indent: sentence.indent, body: sentence.body, lineno: sentence.lineno,
               word: :route, raw_args: raw, ranks: ranks, compiled: compiled, guard: nil,
               children: [])
    end

    def sentences
      @sentences ||= @source.lines.each_with_index.filter_map do |raw, i|
        line = raw.chomp.sub(/\s+#.*\z/, '').sub(/\A(\s*)#.*\z/, '\1').rstrip
        next if line.strip.empty?

        Sentence.new(line[/\A */].size, line.strip, i + 1)
      end
    end

    # An argument is one of five things, and each has exactly one spelling.
    # A bare number has one legal home: a modifier's value, where it is
    # configuration (`columns: 3`, `step: 0.01`) rather than content. As a
    # positional argument it has nowhere to stand — a figure belongs to the
    # app. `true`, `false` and `nil` join the numbers there (2026-09-17): the
    # same division decides it — a modifier's value is configuration and a
    # positional argument is content — and it closes a silent wrongness, since
    # `required: false` used to arrive as the truthy *name* `:false` and saying
    # false meant saying true.
    def argument(arg, sentence, as_modifier: false)
      case arg
      when MODIFIER
        key = Regexp.last_match(1)
        key = "'#{key}'" if key.include?('-')
        "#{key}: #{argument(Regexp.last_match(2), sentence, as_modifier: true)}"
      when /\A".*"\z/ then arg
      when DOTTED
        method = Regexp.last_match(1)
        method.include?('-') ? "subject.public_send(:'#{method}')" : "subject.#{method}"
      when BINDING
        arg.split('.').map { |p| p.include?('-') ? "public_send(:'#{p}')" : p }.join('.')
      when /\A(true|false|nil)\z/ then as_modifier ? arg : ":#{arg}"
      when NAME then ":#{arg}"
      when /\A-?\d+(\.\d+)?\z/
        return arg if as_modifier

        raise SyntaxError.new(
          "#{arg.inspect} is not an argument — a bare number has nowhere to " \
          'stand; a figure belongs to the app',
          @path, sentence.lineno, sentence.body
        )
      else
        raise SyntaxError.new(
          "#{arg.inspect} is not an argument — a name, \"text\", .data, or a modifier:",
          @path, sentence.lineno, sentence.body
        )
      end
    end

    # The three kinds of argument, in the order the sentence takes them. They
    # are named because an error that says which kind arrived late tells the
    # writer what to move; one that can only name the first case has to guess,
    # and guessed wrong at every sentence whose content followed a modifier.
    KINDS = { 0 => 'a name', 1 => 'content or data', 2 => 'a modifier' }.freeze

    # A name, then content or data, then modifiers — the same order the
    # grammar checker held the documents to, now enforced by the grammar
    # itself, in the grammar's one home.
    def rank(arg)
      case arg
      when MODIFIER then 2
      when /\A".*"\z/, DOTTED, BINDING then 1
      else 0
      end
    end

    # Commas inside quotes or parentheses do not separate arguments.
    def split_args(str)
      parts = []
      buf = +''
      depth = 0
      quoted = false
      str.each_char do |c|
        if c == '"'                   then quoted = !quoted
                                           buf << c
        elsif quoted                  then buf << c
        elsif c == ',' && depth.zero? then parts << buf.strip
                                           buf = +''
        else
          depth += 1 if c == '('
          depth -= 1 if c == ')'
          buf << c
        end
      end
      parts << buf.strip unless buf.strip.empty?
      parts
    end
  end
end
