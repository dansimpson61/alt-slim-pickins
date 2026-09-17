#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Instrument two of DAYTRIP-0.3.0b: the convention register, held.
#
#   - every entry's home still exists: the file is there and the marker is in it
#   - every public function of `Inference` is claimed by an entry, or named in
#     `Conventions::INTERNAL` with a reason — an exact partition, so a new
#     inference cannot arrive unregistered
#   - every word whose contract declares an inference (`id:`, `label:`) has an
#     entry — an exact set, so a new declared inference cannot arrive unregistered
#   - all four grades are represented, because a grade that vanishes from the
#     register is a grade the language can no longer see it has
#   - the count is printed, and the axiomatic grade's single entry is named
#
# A register that only agreed with itself would be another unmanaged source of
# truth. Every entry points at code, and the code is asked.

require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/conventions'

here = File.expand_path('..', __dir__)
problems = 0

SlimPickins::Library.builtin
entries = SlimPickins::Conventions::ALL

# --- 1. every home still exists ---------------------------------------------
entries.each do |convention|
  path = File.join(here, convention.file)
  unless File.file?(path)
    puts "  NO HOME      `#{convention.name}` names #{convention.file}, which is not there"
    problems += 1
    next
  end
  next if File.read(path).include?(convention.marker)

  puts "  MOVED        `#{convention.name}` says #{convention.file} holds " \
       "#{convention.marker.inspect}, and it does not"
  problems += 1
end

# --- 2. Inference is exactly partitioned ------------------------------------
live = SlimPickins::Inference.singleton_methods(false).map(&:to_sym).sort
claimed = entries.flat_map { |c| Array(c.inference) }.map(&:to_sym)
internal = SlimPickins::Conventions::INTERNAL.keys.map(&:to_sym)
accounted = (claimed + internal).sort

(live - accounted).each do |fn|
  puts "  UNREGISTERED `Inference.#{fn}` decides something and is in neither the register nor INTERNAL"
  problems += 1
end
(accounted - live).each do |fn|
  puts "  PHANTOM      the register accounts for `Inference.#{fn}`, which does not exist"
  problems += 1
end
duplicated = claimed.tally.select { |_, n| n > 1 }.keys
duplicated.each do |fn|
  puts "  TWICE        `Inference.#{fn}` is claimed by more than one entry"
  problems += 1
end

# --- 3. declared inferences are all registered ------------------------------
# A word's contract can declare an inference: `id:` (the subject's id) or
# `label:` (the app contract's label). Both are registered by name here.
declared_inferences = SlimPickins::Word.registry.filter_map do |word, _klass|
  contract = SlimPickins::CONTRACTS[word]
  next unless contract

  word if contract.id || contract.label
end.sort
missing = declared_inferences - %i[card section]
unless missing.empty?
  puts "  UNREGISTERED #{missing.join(', ')} declare an inference and have no entry"
  problems += 1
end
unless declared_inferences == %i[card section]
  puts "  CHANGED      the words declaring an inference are #{declared_inferences.join(', ')}; " \
       'the register was written for card and section'
  problems += 1
end

# --- 4. all four grades are visible -----------------------------------------
%i[structural shape domain axiomatic].each do |grade|
  next if SlimPickins::Conventions.by_grade(grade).any?

  puts "  NO GRADE     nothing registers the `#{grade}` grade — a grade the language cannot see"
  problems += 1
end

# --- the report --------------------------------------------------------------
puts
puts "convention register — #{entries.size} conventions, every one with its home and its override"
%i[structural shape domain axiomatic].each do |grade|
  names = SlimPickins::Conventions.by_grade(grade).map(&:name)
  puts "  #{grade.to_s.ljust(10)} #{names.size.to_s.rjust(2)}  #{names.join(' ')}"
end
axiomatic = SlimPickins::Conventions.by_grade(:axiomatic)
puts "  the axiomatic grade holds #{axiomatic.size} entry, and it records an absence: " \
     "#{axiomatic.first.decides}"

puts
puts "#{problems} problems"
exit(problems.zero? ? 0 : 1)
