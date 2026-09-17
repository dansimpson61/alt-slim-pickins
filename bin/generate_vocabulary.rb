#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Rewrites the five checkable bullets of every VOCABULARY.md entry from the
# contracts in lib/slim_pickins/contracts.rb — the single home of what each
# word takes, holds, and may live inside. The prose half of an entry
# (`infers`, `renders`, and the paragraphs) is left alone.
#
# check_grammar.rb fails if an entry's bullets drift from the contracts, so
# this script is the only way to edit them: change the contract, run this.

require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/conventions'

path = File.join(__dir__, '..', 'VOCABULARY.md')
source = File.read(path)
changed = 0

parts = source.split(/^(### `[a-z_]+`)/)
out = [parts.shift] # the preamble
parts.each_slice(2) do |header, body|
  out << header
  next unless header && body && header =~ /\A### `([a-z_]+)`/

  word = Regexp.last_match(1)
  contract = SlimPickins::CONTRACTS[word.to_sym]
  unless contract
    puts "no contract for #{word} — skipped"
    out << body
    next
  end

  SlimPickins::Contracts.bullets(word, contract).each do |bullet|
    slot = bullet[/^- \*\*(\w+)\*\*/, 1]
    old = body[/^- \*\*#{slot}\*\* —.*$/, 0]
    unless old
      puts "#{word} has no #{slot} bullet — skipped"
      next
    end
    next if old == bullet

    body = body.sub(old, bullet)
    changed += 1
  end

  # The reference shape (2026-09-17): the conventions a word triggers are
  # generated from its own `infers:` declaration, so the register's prose is
  # shown here rather than restated. Placed after the five checkable bullets,
  # before the prose half.
  conventions = SlimPickins::Conventions.bullet(contract)
  existing = body[/^- \*\*conventions\*\* —.*$/, 0]
  if conventions
    if existing
      unless existing == conventions
        body = body.sub(existing, conventions)
        changed += 1
      end
    else
      subject_line = body[/^- \*\*subject\*\* —.*$/, 0]
      if subject_line
        body = body.sub(subject_line, "#{subject_line}\n#{conventions}")
        changed += 1
      else
        puts "#{word} has no subject bullet to put its conventions after — skipped"
      end
    end
  elsif existing
    body = body.sub("#{existing}\n", '')
    changed += 1
  end
  out << body
end

# A word in the contracts without an entry gets one — heading and the five
# generated bullets, nothing more. The prose and the example sentence are the
# author's; check_grammar holds the bullets and demands the sentence.
added = []
SlimPickins::Library.builtin
all_words = SlimPickins::Word.registry.keys.map(&:to_s)
all_words.each do |word|
  next if source =~ /^### `#{word}`/

  added << word
  out << "\n### `#{word}`\n\n"
  out << SlimPickins::Contracts.bullets(word, SlimPickins::CONTRACTS[word.to_sym]).join("\n")
  out << "\n\n"
end

File.write(path, out.join)
puts "#{changed} bullets regenerated, #{added.size} entries created#{" (#{added.join(", ")})" if added.any?}"
