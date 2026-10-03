# frozen_string_literal: true

require_relative 'contracts'
require_relative 'conventions'

module SlimPickins
  # VOCABULARY.md's shape: which part of an entry the contracts own, and which
  # part the author does.
  #
  # Each entry's checkable bullets — `name`, `content`, `modifiers`, `children`,
  # `subject`, and `conventions` when the word declares one — are generated from
  # `contracts.rb`, the single home of what a word takes, holds and may live
  # inside. The prose half (`infers`, `renders`, the paragraphs, the example
  # sentence) is the author's and nothing here touches it.
  #
  # That arrangement needs two readers — `bin/generate_vocabulary.rb` to write the
  # bullets, `check_grammar.rb` to refuse a hand-edited one — and they had the
  # splitting regex, the bullet lookup and the conventions comparison each in two
  # copies. DAYTRIP-0.4.0h's Part 4 named that: "a checker that exists because a
  # truth has two homes is a tax on the duplication, not a net under the code."
  #
  # Its proposed remedy was to stop committing the document, and measuring it
  # showed that to be wrong: 349 of 1,226 lines are generated and the other 72% is
  # prose no generator can produce. The duplication was never the document. It was
  # the two copies of the question, and this is where the question lives now.
  module Vocabulary
    # An entry opens with its heading, and the heading names the word.
    ENTRY = /^(### `[a-z_]+`)/
    HEADING = /\A### `([a-z_]+)`/
    SLOT = /^- \*\*(\w+)\*\*/
    CONVENTIONS = 'conventions'

    # One place an entry's generated bullets and the contracts disagree.
    Drift = Struct.new(:word, :slot, :expected, :actual, keyword_init: true) do
      # The entry has no bullet for a slot the contracts fill.
      def missing? = actual.nil?

      # The entry carries a bullet for something the word does not declare.
      def unwanted? = expected.nil?
    end

    module_function

    # Every entry, as `[word, body]`.
    def entries(source)
      source.split(ENTRY).drop(1).each_slice(2).filter_map do |heading, body|
        word = heading[HEADING, 1]
        [word, body] if word
      end
    end

    # The document rebuilt, each entry's body replaced by what the block returns
    # for it. The preamble and the headings come back untouched.
    def with_entries(source)
      parts = source.split(ENTRY)
      rebuilt = [parts.shift]
      parts.each_slice(2) do |heading, body|
        rebuilt << heading
        word = heading[HEADING, 1]
        rebuilt << (word ? yield(word, body) : body)
      end
      rebuilt.join
    end

    # Where an entry's generated bullets and the contracts disagree. The
    # generator repairs what this reports; the gate refuses it. Same question.
    def drift(word, contract, body)
      found = Contracts.bullets(word, contract).filter_map do |bullet|
        slot = bullet[SLOT, 1]
        actual = bullet_in(body, slot)
        Drift.new(word: word, slot: slot, expected: bullet, actual: actual) unless actual == bullet
      end

      expected = Conventions.bullet(contract, word: word)
      actual = bullet_in(body, CONVENTIONS)
      return found if expected == actual

      found + [Drift.new(word: word, slot: CONVENTIONS, expected: expected, actual: actual)]
    end

    # The bullet an entry carries for a slot, as one line. No `/m`: with it `.`
    # matches newlines and `.*$` swallows the rest of the entry.
    def bullet_in(body, slot) = body[/^- \*\*#{slot}\*\* —.*$/, 0]

    # A new entry: the heading and the generated bullets, nothing more. The prose
    # and the example sentence are the author's, and `check_grammar` demands the
    # sentence.
    def new_entry(word, contract)
      "\n### `#{word}`\n\n#{Contracts.bullets(word, contract).join("\n")}\n\n"
    end
  end
end
