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

    # A decimal field must take a decimal: with no step the browser counts in
    # whole numbers and refuses 2.5 on submit. A rate wants hundredths, so its
    # arrows move it sensibly; any larger decimal is allowed as it stands. A
    # decimal is any number but an Integer: a Float, or a BigDecimal.
    def step_for(value)
      return nil if value.is_a?(Integer) || !value.is_a?(Numeric)

      value.abs < 1 ? 0.01 : 'any'
    end

    def boolean?(value) = value == true || value == false

    def truthy?(val)
      return false if val.nil? || val == false
      return false if val.respond_to?(:empty?) && val.empty?

      true
    end

    # --- Collections ----------------------------------------------------

    # The common ones a collection is named with. English has too many
    # exceptions for rules, so this is a list, and `from:` covers the rest.
    IRREGULAR_PLURALS = {
      'child' => 'children',
      'person' => 'people',
      'datum' => 'data',
      'leaf' => 'leaves',
      'man' => 'men',
      'woman' => 'women',
      'analysis' => 'analyses',
      'criterion' => 'criteria'
    }.freeze

    IRREGULAR_SINGULARS = IRREGULAR_PLURALS.invert.freeze

    # A word that ends in a hiss takes `es`: address, tax, match, wish.
    HISSING = /(s|x|ch|sh)\z/

    # `each holding` looks for `holdings`; `each address`, for `addresses`.
    def plural(name)
      s = name.to_s
      return IRREGULAR_PLURALS[s] if IRREGULAR_PLURALS.key?(s)
      return "#{s[0..-2]}ies" if s.end_with?('y') && !%w[a e i o u].include?(s[-2])
      return "#{s}es" if s.match?(HISSING)

      "#{s}s"
    end

    # The inverse, for `chart years` finding each row's `year`. Deliberately
    # the same rules `plural` runs backwards, and nil when the name is not
    # a plural at all — a chart that cannot name its axis counts instead.
    def singular(name)
      return nil if name.nil?

      s = name.to_s
      return IRREGULAR_SINGULARS[s].to_sym if IRREGULAR_SINGULARS.key?(s)
      return :"#{s[0..-4]}y" if s.end_with?('ies')
      return s.delete_suffix('es').to_sym if s.match?(/(ss|x|ch|sh)es\z/)

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

    # Digits grouped in thousands, rounded — never cut — to the places shown.
    def separated(number, precision)
      whole, fraction = format("%.#{precision}f", number.abs.round(precision)).split('.')
      grouped = whole.reverse.scan(/\d{1,3}/).join(',').reverse
      [grouped, fraction].compact.join('.')
    end

    def sign(value)
      value.negative? ? '−' : ''
    end

    # Money shows cents when the value has them: 12.99 is $12.99, and a whole
    # amount stays whole.
    def cents(value)
      (value % 1).zero? ? 0 : 2
    end

    def money(value, precision: cents(value))
      "#{sign(value)}$#{separated(value, precision)}"
    end

    def percent(value, precision: 1)
      format("%.#{precision}f%%", value * 100)
    end

    # A number shows the fraction it has, up to two places: 0.083 is 0.08 and
    # 2.7 is 2.7, where a whole-number default once made both of them less.
    # `precision:` says exactly how many places, zeros included.
    def number(value, precision: nil)
      return "#{sign(value)}#{separated(value, precision)}" if precision

      "#{sign(value)}#{separated(value, 2).sub(/(\.\d*?)0+\z/, '\1').chomp('.')}"
    end
  end
end
