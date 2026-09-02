# frozen_string_literal: true

module SlimPickins
  # Errors speak the language, not the implementation: they name the word, the
  # line, and what was expected — never a Ruby method or an internal class.
  # A syntax error is located by the Transform as it compiles; a runtime error
  # is located by the Builder, which knows the sentence being evaluated. Both
  # carry the location the same way, so both speak with the same voice.
  class Error < StandardError
    attr_reader :path, :lineno, :line

    def locate(path, lineno, line)
      @path = path
      @lineno = lineno
      @line = line
      self
    end

    def located? = !@path.nil?

    def message
      return super unless located?

      where = +@path
      where << ", line #{@lineno}" if @lineno
      where << "\n    #{@line}" if @line
      "#{super}\n  #{where}"
    end
  end

  class SyntaxError < Error
    def initialize(message, path, lineno, line)
      super(message)
      locate(path, lineno, line)
    end
  end

  # The subject chain bottoms out at the page, so an attribute that is missing
  # is missing from something nameable. It raises rather than rendering blank.
  class UnknownAttribute < Error
    def initialize(attribute, subject)
      super("#{subject.describe} has no #{attribute}")
    end
  end

  # A subject that is nil is a different failure from an attribute that is
  # missing, and saying so is the difference between a useful error and a
  # misleading one.
  class Nothing < Error
    def initialize(attribute, subject)
      super("#{subject.describe} to ask for #{attribute} — the subject is empty")
    end
  end
end
