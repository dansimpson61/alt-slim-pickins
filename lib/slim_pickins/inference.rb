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

    # --- Collections ----------------------------------------------------

    # `each holding` looks for `holdings`. Deliberately the two rules English
    # actually needs here; anything else is what `from:` is for.
    def plural(name)
      s = name.to_s
      return "#{s[0..-2]}ies" if s.end_with?('y') && !%w[a e i o u].include?(s[-2])

      "#{s}s"
    end

    # The inverse, for `chart years` finding each row's `year`. Deliberately
    # the same two rules `plural` runs backwards, and nil when the name is not
    # a plural at all — a chart that cannot name its axis counts instead.
    def singular(name)
      return nil if name.nil?

      s = name.to_s
      return :"#{s[0..-4]}y" if s.end_with?('ies')

      s.end_with?('s') ? s[0..-2].to_sym : nil
    end

    def collection?(value) = value.is_a?(Enumerable) && !value.is_a?(Hash)

    def nothing_in?(value)
      return true if value.nil?
      return value.none? if collection?(value)

      false
    end

    # --- Moments --------------------------------------------------------

    def moment(value, variant)
      return relative(value) if variant == :relative
      return value.strftime('%-d %B %Y, %H:%M') if variant == :datetime && value.respond_to?(:strftime)
      return value.strftime('%-d %B %Y') if value.respond_to?(:strftime)

      value.to_s
    end

    def relative(value)
      return value.to_s unless value.respond_to?(:to_time)

      days = ((Time.now - value.to_time) / 86_400).round
      case days
      when 0 then 'today'
      when 1 then 'yesterday'
      when 2..30 then "#{days} days ago"
      else moment(value, nil)
      end
    end

    # --- Presentation ---------------------------------------------------

    # What the *shape* of a value can tell us, and no more. A number is a
    # number; whether it is money is a domain fact and must be said.
    def presentation(value)
      return :number if value.is_a?(Numeric)

      :text
    end

    def separated(number)
      whole, fraction = format('%.10f', number.abs).split('.')
      grouped = whole.reverse.scan(/\d{1,3}/).join(',').reverse
      [grouped, fraction]
    end

    def money(value, precision: 0)
      grouped, fraction = separated(value)
      body = precision.zero? ? grouped : "#{grouped}.#{fraction[0, precision]}"
      "#{value.negative? ? '−' : ''}$#{body}"
    end

    def percent(value, precision: 1)
      format("%.#{precision}f%%", value * 100)
    end

    def number(value, precision: 0)
      grouped, fraction = separated(value)
      body = precision.zero? ? grouped : "#{grouped}.#{fraction[0, precision]}"
      "#{value.negative? ? '−' : ''}#{body}"
    end
  end
end
