# frozen_string_literal: true

require_relative 'engine'

module Roth
  # The one place that knows what roth's inputs are called.
  #
  # This exists because of a real incident. roth's field names lived in three
  # places — the `Engine::Inputs` struct, the `name=` attributes in the Slim
  # form, and the specs — with nothing binding them. A rename in September 2025
  # reached the first and stopped, and the running app has silently dropped
  # Social Security ever since, reporting a confident number $138,700 out.
  #
  # So: `FIELDS` declares each input once. The form derives from it, the
  # parameters derive from it, and `to_engine_inputs` is the *only* line that
  # knows the engine's spelling. If the engine renames again, one method
  # changes and nothing else can half-follow.
  #
  # It also satisfies the language's app contract: it answers its own
  # attributes, and it answers `label_for` and `format_for`, so no page ever
  # states a label or a format.
  class Scenario
    Field = Struct.new(:name, :default, :label, :format, :coerce, :within,
                       keyword_init: true) do
      def cast(raw)
        return default if raw.nil? || raw.to_s.strip.empty?

        coerce.call(raw)
      rescue ArgumentError, TypeError
        default
      end

      def complaint(value)
        return nil if within.nil? || within.cover?(value)

        "#{label} must be between #{within.first} and #{within.last}"
      end
    end

    def self.number(raw) = Float(raw)
    def self.whole(raw) = Integer(Float(raw))
    def self.word(raw) = raw.to_s

    FIELDS = [
      Field.new(name: :age_primary, default: 60, label: 'Age (primary)',
                coerce: method(:whole), within: 0..120),
      Field.new(name: :age_spouse, default: 58, label: 'Age (spouse)',
                coerce: method(:whole), within: 0..120),
      Field.new(name: :trad_balance, default: 750_000, label: 'Traditional balance',
                format: :money, coerce: method(:number), within: 0..100_000_000),
      Field.new(name: :roth_balance, default: 150_000, label: 'Roth balance',
                format: :money, coerce: method(:number), within: 0..100_000_000),
      Field.new(name: :base_income, default: 80_000, label: 'Base income',
                format: :money, coerce: method(:number), within: 0..100_000_000),
      Field.new(name: :ss_primary_start_year, default: 7, label: 'SS start (years from now)',
                coerce: method(:whole), within: 0..60),
      Field.new(name: :ss_primary_amount, default: 45_000, label: 'SS annual amount',
                format: :money, coerce: method(:number), within: 0..1_000_000),
      Field.new(name: :growth_rate, default: 0.05, label: 'Growth rate',
                format: :percent, coerce: method(:number), within: -0.5..0.5),
      Field.new(name: :inflation_rate, default: 0.02, label: 'Inflation',
                format: :percent, coerce: method(:number), within: -0.5..0.5),
      Field.new(name: :horizon_years, default: 30, label: 'Horizon (years)',
                coerce: method(:whole), within: 1..60),
      Field.new(name: :conversion_strategy, default: 'fixed', label: 'Strategy',
                coerce: method(:word)),
      Field.new(name: :conversion_value, default: 0.0, label: 'Strategy value',
                format: :money, coerce: method(:number), within: 0..10_000_000)
    ].freeze

    BY_NAME = FIELDS.to_h { |f| [f.name, f] }.freeze
    STRATEGIES = { 'fixed' => 'Fixed amount', 'fill_bracket' => 'Fill bracket' }.freeze

    # Every field becomes a reader, so `field age_primary` in a page resolves
    # by the same rule as anything else. A page naming a field that does not
    # exist raises on the line that named it — which is the drift the incident
    # above went unnoticed for eleven months.
    FIELDS.each { |f| define_method(f.name) { @values[f.name] } }

    attr_reader :values, :complaints

    def self.defaults = new({})

    # Accepts string or symbol keys, from a form post or a JSON body. Anything
    # missing, blank or unparseable falls back to the field's default rather
    # than reaching the engine as nil.
    def initialize(params)
      params = params.transform_keys(&:to_sym)
      @values = BY_NAME.transform_values { |f| f.cast(params[f.name]) }
      @values[:conversion_strategy] = 'fixed' unless STRATEGIES.key?(@values[:conversion_strategy])
      @complaints = FIELDS.filter_map { |f| f.complaint(@values[f.name]) }
    end

    def sound? = @complaints.empty?

    # The app contract's optional half.
    def label_for(attribute) = BY_NAME[attribute]&.label
    def format_for(attribute) = BY_NAME[attribute]&.format

    # The only place that knows the engine's spelling of anything.
    def to_engine_inputs
      Engine::Inputs.from_hash(
        'age_primary' => age_primary,
        'age_spouse' => age_spouse,
        'trad_balance' => trad_balance,
        'roth_balance' => roth_balance,
        'base_income' => base_income,
        'ss_primary_start_year' => ss_primary_start_year,
        'ss_primary_amount' => ss_primary_amount,
        'growth_rate' => growth_rate,
        'inflation_rate' => inflation_rate,
        'horizon_years' => horizon_years,
        'conversion_strategy' => conversion_strategy,
        'conversion_value' => conversion_value
      )
    end

    def strategy
      case conversion_strategy
      when 'fill_bracket' then Engine::Strategy::FillBracket.new(target_bracket: conversion_value)
      else Engine::Strategy::FixedAmount.new(amount: conversion_value)
      end
    end

    def converting? = conversion_value.positive?
  end
end
