# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The vocabulary has one definition, in three homes that must agree: the
# contracts declare what a word is, the Words module implements it, and the
# Generator renders it. This is the dogfood test — the language's own
# machinery holds the language's own vocabulary, so a word added to one home
# and forgotten in another fails here before it can drift.
class WordsTest < Minitest::Test
  # The vocabulary is two kinds of word now: Ruby primitives and partials in
  # lib/vocabulary. Each kind has one home that must agree with the contracts
  # — the primitives their Words methods and generator handlers, the composed
  # words their .sp file, whose preamble is the declaration.
  def test_contracts_words_and_generator_agree_on_the_vocabulary
    contracts = SlimPickins::CONTRACTS.keys
    primitives = SlimPickins::Words.instance_methods(false)
    composed = contracts - primitives
    vocab_dir = File.expand_path('../lib/vocabulary', __dir__)
    composed.each do |w|
      assert File.exist?(File.join(vocab_dir, "#{w}.sp")),
             "`#{w}` is in the contracts but has no partial in lib/vocabulary"
    end

    flattened = %i[each choose contents] # spliced by the interpreter, not rendered
    registering = primitives.select { |w| SlimPickins::CONTRACTS[w].parents != :any }
    missing = (primitives - flattened - registering).reject do |w|
      SlimPickins::Generator.private_instance_methods.include?(w)
    end
    assert_empty missing, 'every primitive needs a generator handler'
  end

  # The dogfood, enforced: the vocabulary and the components are written with
  # the public surface only — no send, no reaching into the Builder's ivars.
  # An app word is exactly as powerful as a built-in because both eat the
  # same food.
  def test_the_vocabulary_uses_the_public_surface_only
    %w[words.rb components.rb].each do |f|
      source = File.read(File.join(__dir__, '..', 'lib', 'slim_pickins', f))
      refute_match(/\.send\(/, source, "#{f} must not reach private methods with send")
      refute_match(/@(nodes|chain|bindings|lines|path|source_lines|level|in_form|empty_active|gatherers|contents|head_nodes|icons_used|library|out)\b/,
                   source, "#{f} must not reach into the Builder's ivars")
    end
  end
end
