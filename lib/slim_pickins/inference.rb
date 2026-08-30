# frozen_string_literal: true

require 'date'

module SlimPickins
  # The whole bet of this language: that a word plus an attribute name is
  # enough, and the label, the input name, the value and the input type can
  # all be worked out.
  #
  # The type is inferred from the *value*, not from a schema. That matters for
  # the app contract: a plain Struct, a Hash or an ordinary PORO can satisfy
  # it without declaring anything.
  module Inference
    module_function

    # base_income -> "Base income". Trailing ? is a predicate, not part of the
    # label; a trailing _at or _on is noise once the label reads as English.
    def label(name)
      return nil if name.nil?

      words = name.to_s.sub(/\?\z/, '').sub(/_(at|on)\z/, '').split('_')
      words[0] = words[0].capitalize
      words.join(' ')
    end

    def input_type(value)
      case value
      when true, false, nil then :text
      when Numeric          then :number
      when Date, Time       then :date
      else                       :text
      end
    end

    # A float that is clearly a rate wants finer steps than a count does.
    def step_for(value)
      return nil unless value.is_a?(Float)

      value.abs < 1 ? 0.01 : nil
    end

    def boolean?(value) = value == true || value == false
  end
end
