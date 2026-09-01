# frozen_string_literal: true

module SlimPickins
  # Turns a page into Ruby source: indentation becomes blocks, and every
  # sentence becomes a method call on the builder.
  #
  #   section holdings          section(:holdings) do
  #     title .name        =>     title(subject.name)
  #                             end
  #
  # The transform is deliberately thin. It does not know what any word means —
  # that is the vocabulary's business — and it does not parse Ruby, because
  # every argument is already valid Ruby once a bare name becomes a symbol and
  # a leading dot becomes the subject.
  class Transform
    WORD    = /\A[a-z][a-z_]*\z/
    NAME    = /\A[a-z][a-z_]*\z/
    DOTTED  = /\A\.([a-z_]+\??)\z/
    BINDING = /\A[a-z_]+(\.[a-z_]+\??)+\z/
    MODIFIER = /\A([a-z_]+):\s*(.+)\z/m

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
    Node = Struct.new(:indent, :body, :lineno, :word, :raw_args, :ranks, :compiled, :children,
                      keyword_init: true)

    def self.call(source, path: '(page)')
      new(source, path).call
    end

    def self.tree(source, path: '(page)')
      new(source, path).tree
    end

    def initialize(source, path)
      @source = source
      @path = path
    end

    def call
      "#{emit(tree).join("\n")}\n"
    end

    def tree
      @tree ||= begin
        stack = []
        nodes = []
        sentences.each do |s|
          node = build(s)
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
        ruby = if n.word == 'when'
                 # `when`'s condition arrives as a lambda, unevaluated, so
                 # the guard can refuse a `when` outside a `choose` *before*
                 # the argument runs. Without this, `when .x` outside a
                 # choose reports "this page has no x" — the wrong problem,
                 # on the one construct with no real page behind it. The
                 # branch body keeps the ordinary `do` block.
                 n.compiled.empty? ? 'send(:when)' : "send(:when, -> { #{n.compiled.join(', ')} })"
               elsif RESERVED.include?(n.word)
                 "send(#{([":#{n.word}", *n.compiled]).join(', ')})"
               elsif n.compiled.empty?
                 n.word
               else
                 "#{n.word}(#{n.compiled.join(', ')})"
               end
        pad = '  ' * depth
        n.children.any? ? ["#{pad}#{ruby} do", *emit(n.children, depth + 1), "#{pad}end"] : ["#{pad}#{ruby}"]
      end
    end

    def build(sentence)
      word, _, rest = sentence.body.partition(' ')
      unless word =~ WORD
        raise SyntaxError.new("#{word.inspect} is not a word", @path, sentence.lineno, sentence.body)
      end

      raw = split_args(rest)
      compiled = raw.map { |a| argument(a, sentence) }
      ranks = raw.map { |a| rank(a) }
      if ranks != ranks.sort
        raise SyntaxError.new(
          'a name may not come after content or data — names come first',
          @path, sentence.lineno, sentence.body
        )
      end

      Node.new(indent: sentence.indent, body: sentence.body, lineno: sentence.lineno,
               word: word, raw_args: raw, ranks: ranks, compiled: compiled, children: [])
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
    # app.
    def argument(arg, sentence, as_modifier: false)
      case arg
      when MODIFIER then "#{Regexp.last_match(1)}: #{argument(Regexp.last_match(2), sentence, as_modifier: true)}"
      when /\A".*"\z/ then arg
      when DOTTED then "subject.#{Regexp.last_match(1)}"
      when BINDING then arg
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
