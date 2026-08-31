# frozen_string_literal: true

require 'delegate'
require_relative 'engine'
require_relative 'chart'

module Roth
  # A presenter over the engine's result.
  #
  # The engine returns OpenStructs of raw floats. Everything a page wants to
  # show — the six headline figures, a year-by-year table, the two chart series
  # — is derived here, once, so that no page computes and no page formats.
  #
  # It answers `label_for` and `format_for`, so `metric tax_delta` in a page is
  # the whole of what a page has to say. That is the same contract `Scenario`
  # satisfies for the form; a subject is a subject.
  #
  # Nothing here reaches back into the engine's arithmetic. Where the engine is
  # wrong — Social Security taxed in full, RMDs stopping at 91 — this reports
  # the wrong number faithfully, and `defects` says so on the page.
  class Projection
    ABSENT = '—'

    LABELS = {
      lifetime_taxes_primary: 'Lifetime taxes (strategy)',
      lifetime_taxes_baseline: 'Lifetime taxes (do nothing)',
      tax_delta: 'Tax difference',
      final_roth_primary: 'Final Roth share (strategy)',
      final_roth_baseline: 'Final Roth share (do nothing)',
      roth_delta: 'Roth share difference',
      years: 'Year by year'
    }.freeze

    FORMATS = {
      lifetime_taxes_primary: :money, lifetime_taxes_baseline: :money,
      tax_delta: :money, final_roth_primary: :percent,
      final_roth_baseline: :percent, roth_delta: :percent
    }.freeze

    def self.of(scenario)
      result = Engine::Projector.new(inputs: scenario.to_engine_inputs,
                                     strategy: scenario.strategy).run
      new(result, scenario)
    end

    def initialize(result, scenario)
      @result = result
      @scenario = scenario
    end

    attr_reader :scenario

    def primary = @result.primary
    def baseline = @result.baseline
    def compared? = !baseline.nil?

    # --- the six headline figures ---------------------------------------

    def lifetime_taxes_primary = primary.totals[:taxes_paid]
    def lifetime_taxes_baseline = compared? ? baseline.totals[:taxes_paid] : ABSENT

    def tax_delta
      return ABSENT unless compared?

      primary.totals[:taxes_paid] - baseline.totals[:taxes_paid]
    end

    def final_roth_primary = roth_share(primary)
    def final_roth_baseline = compared? ? roth_share(baseline) : ABSENT

    def roth_delta
      return ABSENT unless compared?

      roth_share(primary) - roth_share(baseline)
    end

    # --- the table -------------------------------------------------------

    def years = @years ||= primary.years.map { |y| Year.new(y) }

    # --- the two drawings -------------------------------------------------

    def income = chart.income
    def balances = chart.balances

    def chart
      @chart ||= Chart.new(years,
                           standard_deduction: primary.standard_deduction,
                           brackets: primary.brackets)
    end

    # --- what the engine gets wrong --------------------------------------
    #
    # Named on the page rather than only in a backlog, because a tool that
    # reports a tax figure to the dollar should say which dollars it is sure
    # of. Each of these is measured in ROTH_DOMAIN_BACKLOG.md.
    Defect = Struct.new(:description)

    DEFECTS = [
      'Social Security is taxed in full, not by the provisional-income rules',
      'nothing funds the conversion tax, so converting looks free',
      'required distributions stop after age 90',
      'distributions divide the post-growth balance, about 5% high',
      'filling a bracket stops one standard deduction short',
      'Medicare surcharges apply below 65 and are counted in no total'
    ].map { |d| Defect.new(d) }.freeze

    def defects = DEFECTS

    # For the JSON endpoint, so the engine stays callable without a browser.
    def to_h
      { scenario: primary.scenario,
        compared: compared?,
        totals: FORMATS.keys.to_h { |k| [k, public_send(k)] },
        years: primary.years.map(&:to_h) }
    end

    # --- the app contract -------------------------------------------------

    def label_for(attribute) = LABELS[attribute]

    # A format only applies to a figure that exists. When there is no baseline
    # the value is an em dash, and an em dash is not money.
    def format_for(attribute)
      return nil unless FORMATS.key?(attribute)
      return nil unless public_send(attribute).is_a?(Numeric)

      FORMATS[attribute]
    end

    private

    def roth_share(run)
      roth = run.totals[:ending_roth].to_f
      trad = run.totals[:ending_trad].to_f
      total = roth + trad
      total.positive? ? roth / total : 0.0
    end
  end

  # One row of the table. The engine's YearResult is a plain Struct of floats;
  # this is the same values with an opinion about what they mean.
  class Year < SimpleDelegator
    LABELS = {
      year: 'Year', age_primary: 'Age', base_income: 'Base income',
      social_security: 'Social Security', rmd: 'Distribution',
      conversion: 'Converted', federal_tax: 'Federal tax',
      irmaa_applied_cost: 'Medicare surcharge',
      trad_end: 'Traditional', roth_end: 'Roth'
    }.freeze

    FORMATS = {
      base_income: :money, social_security: :money, rmd: :money,
      conversion: :money, taxable_income: :money, federal_tax: :money,
      irmaa_applied_cost: :money, trad_end: :money, roth_end: :money
    }.freeze

    # A year is a label, not a quantity — 2025, never 2,025. Returning it as
    # text is what stops the language treating it as a number.
    def year = __getobj__.year.to_s

    def label_for(attribute) = LABELS[attribute]
    def format_for(attribute) = FORMATS[attribute]
  end
end
