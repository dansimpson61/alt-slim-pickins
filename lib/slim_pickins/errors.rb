# frozen_string_literal: true

module SlimPickins
  Error = Class.new(StandardError)

  # Errors speak the language, not the implementation: they name the word, the
  # line, and what was expected — never a Ruby method or an internal class.
  class SyntaxError < Error
    attr_reader :path, :lineno, :line

    def initialize(message, path, lineno, line)
      @path = path
      @lineno = lineno
      @line = line
      super("#{message}\n  #{path}, line #{lineno}\n    #{line}")
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
