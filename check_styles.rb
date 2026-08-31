#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Holds the stylesheet and the runtime to each other.
#
#   - every class the runtime emits has a rule
#   - every rule corresponds to a word
#   - every class name obeys the four shapes
#
# This is check_grammar.rb's trick pointed at CSS. The existing
# slim-pickins.css has twelve classes used in views and defined nowhere;
# nothing could have told anyone, because no list said what ought to exist.
# Here both sides derive from the same word list, so drift is checkable.
#
# Exits non-zero when anything is wrong.

require 'set'
require_relative 'lib/slim_pickins'
require_relative 'test/fixtures'

CSS = File.join(__dir__, 'assets', 'slim-pickins.css')

# .word | .word--variant | .word-part | .word-part--variant
# A variant comes from an attribute name, so it may be snake_case.
SHAPE = /\A[a-z]+(-[a-z]+)?(--[a-z0-9_]+)?\z/

def base_of(klass) = klass.split('--').first.split('-').first

problems = 0
def fail!(line) = (puts "  #{line}")

words = SlimPickins::Builder::WORDS.map(&:to_s).to_set
app_words = Dir[File.join(__dir__, 'pages', 'partials', '*.sp')]
            .map { |f| File.basename(f, '.sp') }.to_set

# --- what the stylesheet defines -------------------------------------------
# Every class in selector position, including the second one after a comma —
# reading only line starts missed `.money, .percent, .number`.
css = File.read(CSS)
selectors = css.gsub(%r{/\*.*?\*/}m, '').split('}').map { |rule| rule.split('{').first.to_s }
defined = selectors.join(' ').scan(/\.([a-z][a-z0-9_-]*)/).flatten.to_set

# --- what the runtime *can* emit, read from the source ----------------------
# Rendering alone is not enough: `empty` only appears when a collection is
# empty, and an unused variant appears never. A render-only check is blind to
# exactly the classes that go unstyled, which is how the twelve undefined ones
# survived. Every class is built by `token(:word, …)` or written as a literal,
# so both are greppable.
source = Dir[File.join(__dir__, 'lib', '**', '*.rb')].flat_map { |f| File.read(f).lines }.join
can_emit = source.scan(/token\(:([a-z_]+)/).flatten.to_set
can_emit |= source.scan(/class="([a-z][a-z0-9-]*)/).flatten.map { |c| c.split.first }.to_set

# --- what the runtime emits, by rendering every page in the repo ------------
library = SlimPickins::Library.from(File.join(__dir__, 'pages'))
emitted = Set.new
Dir[File.join(__dir__, 'pages', '*.sp')].sort.each do |path|
  locals = Fixtures.for(File.basename(path, '.sp'))
  next unless locals

  html = SlimPickins.render(File.read(path), path: path, locals: locals, library: library)
  html.scan(/class="([^"]*)"/).flatten.each { |c| emitted.merge(c.split) }
rescue StandardError => e
  fail!("COULD NOT RENDER #{File.basename(path)}: #{e.message}")
  problems += 1
end

# --- 1a. every class the code can emit has a rule --------------------------
(can_emit - defined).sort.each do |klass|
  fail!("UNSTYLED    #{klass.inspect} can be emitted but no rule defines it")
  problems += 1
end

# --- 1. every class obeys the four shapes ----------------------------------
(emitted | defined).sort.each do |klass|
  next if klass =~ SHAPE

  fail!("SHAPE       #{klass.inspect} is not .word, .word--variant, .word-part or .word-part--n")
  problems += 1
end

# --- 2. every emitted class has a rule -------------------------------------
(emitted - defined).sort.each do |klass|
  # A variant is open-ended — an app may name one we never saw — but its base
  # must be styled, or the whole element is unstyled.
  base = base_of(klass)
  next if klass.include?('--') && defined.include?(base)

  fail!("UNSTYLED    #{klass.inspect} is emitted but no rule defines it")
  problems += 1
end

# --- 3. every rule corresponds to a word -----------------------------------
(defined - emitted).sort.each do |klass|
  base = base_of(klass)
  next if words.include?(base) || app_words.include?(base)

  fail!("ORPHAN      #{klass.inspect} is defined but no word can emit it")
  problems += 1
end

puts
puts "#{can_emit.size} classes the code can emit, #{emitted.size} seen rendering, " \
     "#{defined.size} rules, #{problems} problems"
exit(problems.zero? ? 0 : 1)
