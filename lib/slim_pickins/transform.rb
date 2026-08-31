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

    def self.call(source, path: '(page)')
      new(source, path).call
    end

    def initialize(source, path)
      @source = source
      @path = path
    end

    def call
      out = []
      open = []

      sentences.each_with_index do |s, i|
        while open.any? && s.indent <= open.last
          open.pop
          out << "#{'  ' * open.size}end"
        end

        nxt = sentences[i + 1]
        pad = '  ' * open.size
        ruby = to_ruby(s)

        if nxt && nxt.indent > s.indent
          out << "#{pad}#{ruby} do"
          open << s.indent
        else
          out << "#{pad}#{ruby}"
        end
      end

      while open.any?
        open.pop
        out << "#{'  ' * open.size}end"
      end

      "#{out.join("\n")}\n"
    end

    private

    def sentences
      @sentences ||= @source.lines.each_with_index.filter_map do |raw, i|
        line = raw.chomp.sub(/\s+#.*\z/, '').sub(/\A(\s*)#.*\z/, '\1').rstrip
        next if line.strip.empty?

        Sentence.new(line[/\A */].size, line.strip, i + 1)
      end
    end

    def to_ruby(sentence)
      word, _, rest = sentence.body.partition(' ')
      unless word =~ WORD
        raise SyntaxError.new("#{word.inspect} is not a word", @path, sentence.lineno, sentence.body)
      end

      args = split_args(rest).map { |a| argument(a, sentence) }
      if RESERVED.include?(word)
        parts = [":#{word}", *args]
        "send(#{parts.join(', ')})"
      else
        args.empty? ? word : "#{word}(#{args.join(', ')})"
      end
    end

    # An argument is one of five things, and each has exactly one spelling.
    def argument(arg, sentence)
      case arg
      when MODIFIER then "#{Regexp.last_match(1)}: #{argument(Regexp.last_match(2), sentence)}"
      when /\A".*"\z/ then arg
      when DOTTED then "subject.#{Regexp.last_match(1)}"
      when BINDING then arg
      when NAME then ":#{arg}"
      when /\A-?\d+(\.\d+)?\z/ then arg
      else
        raise SyntaxError.new(
          "#{arg.inspect} is not an argument — a name, \"text\", .data, or a modifier:",
          @path, sentence.lineno, sentence.body
        )
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
