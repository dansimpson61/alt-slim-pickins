# frozen_string_literal: true

require_relative 'errors'
require_relative 'transform'
require_relative 'contracts'

module SlimPickins
  # The compile-once cache — the escape for apps that cannot pay the gate's
  # per-render cost, and the memory behind the gate. A page compiles to two
  # things: the Ruby the Builder evaluates, and the gate's verdict on its
  # sentences. Both come from one parse, and both are cached together,
  # keyed by the source — so the parse, the contract walk and the emit run
  # once per source rather than once per render, and a partial inside
  # `each` pays once, not once per row.
  #
  # The cached verdict carries no path: the same source may render under
  # several names — roth's report.sp renders as a partial and as a page —
  # so each render composes the refusal with its own path. A source that
  # will not parse raises during the first build, is not cached, and so
  # names the path of every render that tries it.
  class Compilation
    def self.of(source, path)
      # The cache is read without the lock first: under MRI a Hash read is
      # atomic, and the common path is a hit — every partial invocation pays
      # this call, so the lock only belongs to the miss that builds.
      cached = (@cache ||= {})[source]
      return cached if cached

      (@mutex ||= Mutex.new).synchronize { @cache[source] ||= new(source, path) }
    end

    # The instrument's reach: bin/measure_cost.rb empties it to measure the
    # cold path.
    def self.clear! = @cache&.clear

    def initialize(source, path)
      transform = Transform.new(source, path)
      @violation = Contracts.first_violation(transform.tree)
      @ruby = transform.call
    end

    # The gate, for the render that asked: a violating page is refused with
    # this render's path, in the syntax error's voice — the word, the line,
    # and the sentence.
    def refuse!(path)
      return unless @violation

      raise SyntaxError.new(@violation.complaint, path, @violation.lineno, @violation.body)
    end

    attr_reader :ruby
  end
end
