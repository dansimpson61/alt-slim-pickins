# frozen_string_literal: true

require_relative 'word'

module SlimPickins
  class PartialWord < Word
    class << self
      attr_accessor :compilation, :source_lines, :is_builtin, :partial_name, :source_path
    end

    def evaluate
      p_name = self.class.partial_name
      self.class.compilation.refuse!("partials/#{p_name}.sp")
      contract = self.class.instance_variable_get(:@contract)
      ruby_ast = self.class.compilation.ruby
      p_lines = self.class.source_lines
      @builder.send(:evaluate_word_definition, p_name, [], @args, @kwargs, @block,
                    contract: contract, gatherer: self) do
        @builder.send(:eval_with, ruby_ast, "partials/#{p_name}.sp", p_lines)
      end
    end
  end
end
