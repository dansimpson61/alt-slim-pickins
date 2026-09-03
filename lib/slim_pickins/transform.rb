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
    WORD    = /\A[a-z][a-z0-9_]*\z/
    NAME    = /\A[a-z][a-z0-9_]*\z/
    DOTTED  = /\A\.([a-z0-9_-]+\??)\z/
    BINDING = /\A[a-z0-9_-]+(\.[a-z0-9_-]+\??)+\z/
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
        ruby = if RESERVED.include?(n.word)
                 "send(#{([":#{n.word}", *n.compiled]).join(', ')})"
               elsif n.compiled.empty?
                 n.word
               else
                 "#{n.word}(#{n.compiled.join(', ')})"
               end
        pad = '  ' * depth
        # Children nest two levels deeper than their sentence — one for
        # with_line's block, one for the word's own.
        if n.children.any?
          ["#{pad}with_line(#{n.lineno}) do", "#{pad}  #{ruby} do",
           *emit(n.children, depth + 2), "#{pad}  end", "#{pad}end"]
        else
          ["#{pad}with_line(#{n.lineno}) do", "#{pad}  #{ruby}", "#{pad}end"]
        end
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
      if contract_for(word)&.lazy&.include?(:content)
        # A word whose shape declares lazy content receives it unevaluated,
        # so its guard can fire before the argument runs. `when` was the one
        # hardcoded case; now laziness is a declared capability any word —
        # built-in, vocabulary partial, or an app's own — may claim.
        raw.each_with_index do |arg, i|
          compiled[i] = "-> { #{compiled[i]} }" if ranks[i] == 1
        end
      end
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
      when MODIFIER then "'#{Regexp.last_match(1)}': #{argument(Regexp.last_match(2), sentence, as_modifier: true)}"
      when /\A".*"\z/ then arg
      when DOTTED then "subject.send(:'#{Regexp.last_match(1)}')"
      when BINDING then arg.split('.').map { |p| "send(:'#{p}')" }.join('.')
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
