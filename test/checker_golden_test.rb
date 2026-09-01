# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The sentences the old checker refused, pinned before the checker was
# rewritten to consume the grammar. The refusals moved into Transform — the
# grammar's one home — so this file is what keeps the rewrite honest: every
# one of these must still fail, with a message that names the problem, and
# every golden sentence must still compile.
class CheckerGoldenTest < Minitest::Test
  GOLDEN_REFUSALS = [
    ['a bare number is not an argument', 'level 1000000.0, "A million"', /bare number/],
    ['a name may not follow content', 'note "Saved.", warning', /name may not/],
    ['a name may not follow data', 'note .body, warning', /name may not/],
    ['the leading word must be a word', '2fast "x"', /is not a word/],
    ['a modifier value must be an argument', 'image .url, alt: %bogus%', /is not an argument/],
    ['an unknown punctuation is not an argument', 'field name, %bogus%', /is not an argument/]
  ].freeze

  GOLDEN_SENTENCES = [
    'field name, "Label", type: text',
    'image .url, alt: .name',
    'line gross_income, "Do nothing", from: .baseline_years',
    # A bare number has one legal home: a modifier's value, where it is
    # configuration rather than content.
    'grid metrics, columns: 3',
    'money .tax_delta, precision: 2',
    'field growth_rate, step: 0.01'
  ].freeze

  def test_every_golden_refusal_still_fails
    GOLDEN_REFUSALS.each do |label, source, message|
      error = assert_raises(SlimPickins::SyntaxError, label) do
        SlimPickins.compile(source, path: 'golden.sp')
      end
      assert_match message, error.message
      assert_includes error.message, 'golden.sp, line 1'
    end
  end

  def test_every_golden_sentence_still_compiles
    GOLDEN_SENTENCES.each do |source|
      SlimPickins.compile(source, path: 'golden.sp')
    end
  end
end
