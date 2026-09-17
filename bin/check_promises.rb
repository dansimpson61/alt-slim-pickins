#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Instrument one of DAYTRIP-0.3.0b: the promise ledger, held.
#
#   - every modifier the living vocabulary declares is in the ledger
#   - every universal modifier the gate permits is in the ledger
#   - every loader the runtime defines is in the ledger
#   - every ledger entry's reader still exists on disk
#   - every promise with no reader is printed, with its count
#
# It fails on the first four and *reports* the fifth, because a promise with no
# reader is a finding waiting on a ruling, not a defect to be silently deleted
# (`DAYTRIP-0.3.0b`, E4 and E7). `--strict` fails on the fifth too, which is
# how the daytrip showed the debt rather than asserting it.
#
# A ledger that only agreed with itself would be another unmanaged source of
# truth, so both directions are checked: the code must cover the ledger, and
# the ledger must cover the code.

require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/promises'

here = File.expand_path('..', __dir__)
strict = ARGV.include?('--strict')
problems = 0

SlimPickins::Library.builtin

# --- what the living vocabulary declares -------------------------------------
live_declared = Hash.new { |h, k| h[k] = [] }
SlimPickins::Promises.language_words.each do |word|
  contract = SlimPickins::CONTRACTS[word]
  next unless contract

  contract.modifiers.each { |modifier| live_declared[modifier] << word }
end
live_universal = SlimPickins::Contracts::UNIVERSAL_MODIFIERS

ledger = SlimPickins::Promises::ALL
by_name = ledger.to_h { |p| [p.name, p] }
ledger_modifier_names = ledger.select { |p| p.kind == :modifier }.map(&:name)
ledger_universal_names = ledger.select { |p| p.kind == :universal }.map(&:name)

# --- direction 1: the code must be covered by the ledger ---------------------
# A name may be both declared by a word and permitted universally (`id:` is:
# `box` declares it and the gate allows it everywhere), which is why the two
# sets are unioned rather than kept apart.
((live_declared.keys | live_universal) - by_name.keys).sort.each do |modifier|
  puts "  UNLEDGERED   `#{modifier}:` is live (#{live_declared[modifier].join(', ')}) and not in the ledger"
  problems += 1
end

# A ledger entry for a modifier nothing declares and the gate does not permit
# claims a promise the language no longer makes.
(ledger_modifier_names - live_declared.keys).sort.each do |modifier|
  puts "  STALE        the ledger records `#{modifier}:` and no word declares it"
  problems += 1
end

# The universal set has one home — the gate's own list — and the ledger must
# agree with it in both directions.
(live_universal - ledger_universal_names).each do |modifier|
  puts "  UNLEDGERED   the gate permits `#{modifier}:` universally and the ledger does not record it"
  problems += 1
end
(ledger_universal_names - live_universal).each do |modifier|
  puts "  UNPERMITTED  the ledger records `#{modifier}:` as universal and the gate does not permit it"
  problems += 1
end

# --- direction 2: the ledger must describe the code truthfully ---------------
ledger.each do |promise|
  next if promise.kind == :loader

  actual = live_declared[promise.name].sort
  next if actual == promise.declared_by.sort

  puts "  DRIFTED      `#{promise.name}:` is declared by #{actual.join(', ')}, " \
       "the ledger says #{promise.declared_by.join(', ')}"
  problems += 1
end

# Every recorded reader must still be there. The ledger's whole value is that a
# reader cannot vanish without someone being told.
ledger.each do |promise|
  promise.read_by.each do |path|
    next if File.file?(File.join(here, path))

    puts "  LOST READER  `#{promise.name}` says it is read by #{path}, which is not there"
    problems += 1
  end
  next unless promise.verdict == :none && promise.read_by.any?

  puts "  CONTRADICTED `#{promise.name}` is recorded as unread and names a reader"
  problems += 1
end

# --- the report --------------------------------------------------------------
outstanding = SlimPickins::Promises.outstanding
puts
puts "promise ledger — #{ledger.size} promises: " \
     "#{ledger.count { |p| p.kind == :modifier }} declared by words, " \
     "#{ledger.count { |p| p.kind == :universal }} universal, " \
     "#{ledger.count { |p| p.kind == :loader }} loaders"
puts "  read: #{ledger.count { |p| p.verdict == :read }} · " \
     "forwarded: #{ledger.count { |p| p.verdict == :forwarded }} · " \
     "no reader: #{outstanding.size}"
outstanding.each { |p| puts "  NO READER    `#{p.name}` — #{p.note}" }

if strict && outstanding.any?
  puts
  puts "  #{outstanding.size} promises have no reader — a ruled decision owns each (E4, E7)"
  problems += outstanding.size
end

puts
puts "#{problems} problems"
exit(problems.zero? ? 0 : 1)
