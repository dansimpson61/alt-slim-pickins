#!/usr/bin/env ruby
# frozen_string_literal: true
#
# The third checker: a word is reviewable.
#
#   - every word declares a part of speech and a structural shape, in its
#     contract — the language is a noun language (45 of 50), and the five
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

SlimPickins::Builder::WORDS.each do |word|
  contract = contracts[word]
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
nouns = contracts.values.count { |c| c.speech == :noun }
non_nouns = contracts.values.reject { |c| c.speech == :noun }
             .map { |c| "#{c.speech}" }.uniq.sort

# --- the vitals, measured over the .sp corpus --------------------------------
files = Dir[File.join(__dir__, '{pages,examples}', '**', '*.sp')]
sentences = 0
args = 0
max_args = 0
max_depth = 0
modifiers = Hash.new(0)
used = Set.new

files.each do |f|
  tree = SlimPickins::Transform.tree(File.read(f), path: File.basename(f))
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

shapes = contracts.values.group_by(&:shape).transform_values(&:size).sort_by { |k, _| k.to_s }

puts
puts 'vitals'
puts "  words: #{contracts.size} — #{nouns} nouns, #{contracts.size - nouns} non-nouns (#{non_nouns.join(', ')})"
puts "  shapes: #{shapes.map { |s, n| "#{s} #{n}" }.join(' · ')}"
puts "  sentences: #{sentences} · mean #{format('%.2f', args.to_f / sentences)} args · " \
     "longest #{max_args} · deepest nesting #{max_depth}"
puts "  distinct modifiers: #{modifiers.size} — #{modifiers.keys.sort.join(' ')}"
app_used = used.reject { |w| contracts.key?(w.to_sym) }
puts "  words used in real pages: #{used.size - app_used.size} of #{contracts.size} " \
     "(plus #{app_used.size} app words: #{app_used.sort.join(', ')})"
puts "  #{problems} problems"
exit(problems.zero? ? 0 : 1)
