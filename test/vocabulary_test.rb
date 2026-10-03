# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/vocabulary'
require_relative '../lib/slim_pickins/census'

# VOCABULARY.md's generated half, as one question with two askers.
#
# `bin/generate_vocabulary.rb` repairs what `check_grammar.rb` refuses, and
# before this module each carried its own copy of the splitting regex, the bullet
# lookup and the conventions comparison. Two copies of a question answer it
# differently eventually, so the question is held here.
class VocabularyTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  DOCUMENT = File.read(File.join(ROOT, 'VOCABULARY.md'))

  def setup
    SlimPickins::Library.builtin
  end

  def contract_for(word) = SlimPickins::CONTRACTS[word.to_sym]

  def entry_for(word)
    _, body = SlimPickins::Vocabulary.entries(DOCUMENT).find { |name, _| name == word }
    body
  end

  def test_every_entry_in_the_document_is_found
    words = SlimPickins::Vocabulary.entries(DOCUMENT).map(&:first)
    assert_equal words, words.uniq, 'an entry appears twice'
    assert_includes words, 'page'
    assert_equal SlimPickins::Census.words[:total].size, words.size,
                 'every word in the vocabulary has an entry, and nothing else does'
  end

  def test_the_real_document_has_no_drift
    SlimPickins::Vocabulary.entries(DOCUMENT).each do |word, body|
      contract = contract_for(word)
      next unless contract

      assert_empty SlimPickins::Vocabulary.drift(word, contract, body).map(&:slot),
                   "`#{word}` has hand-edited bullets — run bin/generate_vocabulary.rb"
    end
  end

  # The three shapes drift takes, because the generator does something different
  # with each and the gate words each differently.
  def test_a_hand_edited_bullet_is_drift_that_names_both_sides
    body = entry_for('page').sub(/^- \*\*children\*\* —.*$/, '- **children** — a hand-edited lie')
    drift = SlimPickins::Vocabulary.drift('page', contract_for('page'), body)

    assert_equal ['children'], drift.map(&:slot)
    refute drift.first.missing?
    refute drift.first.unwanted?
    assert_equal '- **children** — a hand-edited lie', drift.first.actual
    assert_equal '- **children** — anything', drift.first.expected
  end

  def test_a_bullet_that_is_gone_is_drift_the_generator_can_insert
    body = entry_for('page').sub(/^- \*\*conventions\*\* —.*$\n/, '')
    drift = SlimPickins::Vocabulary.drift('page', contract_for('page'), body).first

    assert_equal 'conventions', drift.slot
    assert drift.missing?, 'the generator inserts this one after the subject bullet'
    refute_nil drift.expected
  end

  def test_a_conventions_bullet_a_word_does_not_declare_is_unwanted
    word = SlimPickins::Vocabulary.entries(DOCUMENT).map(&:first).find do |name|
      contract = contract_for(name)
      contract && SlimPickins::Conventions.bullet(contract, word: name).nil?
    end
    refute_nil word, 'no word in the vocabulary declares nothing — this test has nothing to ask'

    body = "#{entry_for(word)}\n- **conventions** — an invented claim"
    drift = SlimPickins::Vocabulary.drift(word, contract_for(word), body).first

    assert_equal 'conventions', drift.slot
    assert drift.unwanted?, 'the generator deletes this one'
    assert_nil drift.expected
  end

  # The bug this regex was fixed for once already: with `/m`, `.*$` swallows the
  # rest of the entry and the comparison is against half the document.
  def test_a_bullet_is_one_line
    bullet = SlimPickins::Vocabulary.bullet_in(entry_for('page'), 'name')

    refute_nil bullet
    refute_includes bullet, "\n"
  end

  def test_the_document_survives_a_walk_that_changes_nothing
    assert_equal DOCUMENT, SlimPickins::Vocabulary.with_entries(DOCUMENT) { |_word, body| body },
                 'the preamble and the headings come back untouched'
  end

  def test_a_walk_replaces_only_the_body_it_was_given
    rebuilt = SlimPickins::Vocabulary.with_entries(DOCUMENT) do |word, body|
      word == 'page' ? body.sub(/^- \*\*children\*\* —.*$/, '- **children** — changed') : body
    end

    assert_includes rebuilt, '- **children** — changed'
    assert_includes rebuilt, '### `page`'
    assert_equal DOCUMENT.lines.size, rebuilt.lines.size
  end
end
