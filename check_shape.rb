#!/usr/bin/env ruby
# frozen_string_literal: true
#
# The third checker: a word is reviewable.
#
#   - every word declares a part of speech and a structural shape, in its
#     contract — the language is a noun language (59 of 64), and the five
#     non-nouns are the control flow
#   - the vitals are printed, measured over the real .sp corpus
#
# It fails only on the shape row: a word with no declared shape has to argue
# for itself in writing, so irregularity stops accumulating silently. A vital
# that moves is not a failure — it is a conversation.

require 'set'
require_relative 'lib/slim_pickins'

problems = 0
contracts = SlimPickins::CONTRACTS

# The registry is the vocabulary's one home, and it is not complete until the
# built-in library has loaded the words that are written as `.sp` partials.
SlimPickins::Library.builtin

# `CONTRACTS` answers a lookup but cannot be enumerated: it is a dynamic hash
# whose `values` are only whatever has been asked for so far, so counting them
# counts this script's own curiosity. The vocabulary is gathered once, from the
# registry, and every vital below is measured over that.
vocabulary = SlimPickins::Word.registry.keys.to_h { |word| [word, contracts[word]] }

vocabulary.each do |word, contract|
  unless contract
    puts "  NO CONTRACT   `#{word}` has no contract"
    problems += 1
    next
  end
  unless contract.shape
    puts "  NO SHAPE      `#{word}` declares no shape — argue for it in writing"
    problems += 1
  end
end

# --- the register ----------------------------------------------------------
declared = vocabulary.values.compact
nouns = declared.count { |c| c.speech == :noun }
non_nouns = declared.reject { |c| c.speech == :noun }.map { |c| c.speech.to_s }.uniq.sort

# --- the vitals, measured over the .sp corpus --------------------------------
files = Dir[File.join(__dir__, '{pages,examples,lib/vocabulary,studio}', '**', '*.sp')]
sentences = 0
args = 0
max_args = 0
max_depth = 0
modifiers = Hash.new(0)
used = Set.new

files.each do |f|
  # The `expects` line *declares* the word rather than saying anything with it,
  # so it is not a sentence and is not counted as one — the position
  # check_grammar already records, and which this checker had not honoured: its
  # census had been counting declaration keys (`content`, `precision`, and now
  # `takes`) as page modifiers, inflating the count with words no page writes.
  # Found 2026-09-17, in the round that changed the preamble's spelling.
  source = File.read(f).sub(/\Aexpects\b.*$/, '')
  tree = SlimPickins::Transform.tree(source, path: File.basename(f))
  visit = lambda do |nodes, depth|
    nodes.each do |node|
      sentences += 1
      args += node.raw_args.size
      max_args = [max_args, node.raw_args.size].max
      max_depth = [max_depth, depth].max
      used << node.word
      node.raw_args.zip(node.ranks).each do |arg, rank|
        modifiers[arg[/\A([a-z_]+):/, 1]] += 1 if rank == 2
      end
      visit.call(node.children, depth + 1)
    end
  end
  visit.call(tree, 1)
end

shapes = declared.group_by(&:shape).transform_values(&:size).sort_by { |k, _| k.to_s }

puts
puts 'vitals'
puts "  words: #{vocabulary.size} — #{nouns} nouns, #{vocabulary.size - nouns} non-nouns (#{non_nouns.join(', ')})"
puts "  shapes: #{shapes.map { |s, n| "#{s} #{n}" }.join(' · ')}"
puts "  sentences: #{sentences} · mean #{format('%.2f', args.to_f / sentences)} args · " \
     "longest #{max_args} · deepest nesting #{max_depth}"
puts "  distinct modifiers: #{modifiers.size} — #{modifiers.keys.sort.join(' ')}"
app_used = used.reject { |w| vocabulary.key?(w.to_sym) }
puts "  words used in real pages: #{used.size - app_used.size} of #{vocabulary.size} " \
     "(plus #{app_used.size} app words: #{app_used.sort.join(', ')})"
puts "  #{problems} problems"
exit(problems.zero? ? 0 : 1)
