#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Rewrites the checkable bullets of every VOCABULARY.md entry from the contracts
# in lib/slim_pickins/contracts.rb — the single home of what each word takes,
# holds, and may live inside. The prose half of an entry (`infers`, `renders`,
# and the paragraphs) is left alone.
#
# check_grammar.rb fails if an entry's bullets drift from the contracts, so this
# script is the only way to edit them: change the contract, run this.
#
# The two of them ask `SlimPickins::Vocabulary` the same question and differ only
# in what they do with the answer — this one repairs the drift, the gate refuses
# it. They each used to carry their own copy of the splitting regex, the bullet
# lookup and the conventions comparison.

require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/vocabulary'

path = File.expand_path('../VOCABULARY.md', __dir__)
source = File.read(path)
changed = 0

document = SlimPickins::Vocabulary.with_entries(source) do |word, body|
  contract = SlimPickins::CONTRACTS[word.to_sym]
  unless contract
    puts "no contract for #{word} — skipped"
    next body
  end

  SlimPickins::Vocabulary.drift(word, contract, body).each do |drift|
    if drift.unwanted?
      # The word declares no conventions and the entry shows some.
      body = body.sub("#{drift.actual}\n", '')
    elsif !drift.missing?
      body = body.sub(drift.actual, drift.expected)
    elsif drift.slot == SlimPickins::Vocabulary::CONVENTIONS
      # The reference shape (2026-09-17): a word's conventions are generated from
      # its own `infers:` declaration, and sit after the five checkable bullets,
      # before the prose half.
      anchor = SlimPickins::Vocabulary.bullet_in(body, 'subject')
      unless anchor
        puts "#{word} has no subject bullet to put its conventions after — skipped"
        next
      end
      body = body.sub(anchor, "#{anchor}\n#{drift.expected}")
    else
      puts "#{word} has no #{drift.slot} bullet — skipped"
      next
    end
    changed += 1
  end

  body
end

# A word in the contracts without an entry gets one. The prose and the example
# sentence are the author's; check_grammar holds the bullets and demands the
# sentence.
SlimPickins::Library.builtin
added = SlimPickins::Word.registry.keys.map(&:to_s).reject { |word| source.match?(/^### `#{word}`/) }
added.each { |word| document += SlimPickins::Vocabulary.new_entry(word, SlimPickins::CONTRACTS[word.to_sym]) }

File.write(path, document)
puts "#{changed} bullets regenerated, #{added.size} entries created#{" (#{added.join(', ')})" if added.any?}"
