# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The vocabulary has one definition, in three homes that must agree: the
# contracts declare what a word is, the Words module implements it, and the
# Generator renders it. This is the dogfood test — the language's own
# machinery holds the language's own vocabulary, so a word added to one home
# and forgotten in another fails here before it can drift.
class WordsTest < Minitest::Test
  def test_contracts_words_and_generator_agree_on_the_vocabulary
    contracts = SlimPickins::CONTRACTS.keys
    words = SlimPickins::Words.instance_methods(false)

    assert_equal contracts.sort, words.sort,
                 'every contract needs a word, and every word a contract'

    flattened = %i[each choose contents] # spliced by the interpreter, not rendered
    registering = contracts.select { |w| SlimPickins::CONTRACTS[w].parents != :any }
    # A registering word renders through its gatherer — Table, Chart, Choose
    # or Choice — so its home is the component, not the Generator.
    missing = (contracts - flattened - registering).reject do |w|
      SlimPickins::Generator.private_instance_methods.include?(w)
    end
    assert_empty missing, 'every word needs a generator handler'
  end
end
