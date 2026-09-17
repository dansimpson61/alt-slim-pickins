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
#
# A variant comes from an attribute name, so it may be snake_case — and so may
# a word, for exactly the same reason: both are Ruby identifiers, and a word
# that is two words long has no other spelling available to it. The rule used
# to forbid it, and the reason it could was that every word in the vocabulary
# happened to be one English word. That stopped being true when app partials
# arrived: `account_card` and `unreviewed_card` have been in `pages/partials/`
# all along and escaped only because no rule ever named them. Examined and
# widened (2026-09-06, dan's constraint 3) rather than obeyed — the shapes are
# still four, and a hyphen still means "part of".
SHAPE = /\A[a-z][a-z0-9_]*(-[a-z][a-z0-9_]*)?(--[a-z0-9_]+)?\z/

def base_of(klass) = klass.split('--').first.split('-').first

problems = 0
def fail!(line) = (puts "  #{line}")

# The registry is the vocabulary's one home, and it is not complete until the
# built-in library has loaded the words that are written as `.sp` partials.
SlimPickins::Library.builtin
words = SlimPickins::Word.registry.keys.map(&:to_s).to_set
# Words an app defines for itself. Every app in this repo renders through the
# one stylesheet, so a rule may belong to any of their partials — the studio's
# as much as the pages'. Reading every `partials/` there is stops this list
# needing an edit each time an app arrives, which is how the studio's own
# words came to look like orphans.
app_words = Dir[File.join(__dir__, '**', 'partials', '*.sp')]
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
# A promoted partial carries its own name as the class base, so every
# composed word's name is emittable — and must have a rule.
can_emit |= (SlimPickins::CONTRACTS.keys - SlimPickins::Words.instance_methods(false)).map(&:to_s)
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

# --- 0. every presentational value lives in the theme ----------------------
# The claim is that a theme is one :root and can miss nothing. That is only
# true if no rule below :root carries a value a theme might want to change.
# Structural constants — zero, a full width, a grid fraction — stay literal.
STRUCTURAL = %w[0 1 2 3 100%].freeze
body = css.split('document --').last.to_s
literals = body.scan(/:\s*([^;{}]*)/).flatten.join(' ')
              .scan(/(?<![\w-])(\d*\.?\d+(?:rem|em|px|ch|%)?)(?![\w-])/).flatten
              .reject { |v| STRUCTURAL.include?(v) }
literals.tally.sort.each do |value, count|
  fail!("UNTHEMED    #{value} appears #{count}x outside :root — a theme cannot reach it")
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

# --- 2b. every variant a page says must be stylable -------------------------
# A variant is open to apps — but open is not the same as silent. `badge
# banana` emits `badge--banana`, a class no rule defines, so the element
# renders unstyled and nothing says so, where an unknown *word* fails loudly on
# its line. dan's ruling (2026-09-17, DAYTRIP-0.3.0b's E1): a variant the
# stylesheet cannot style is refused.
#
# The refusal lives here rather than in the runtime, and that is not a
# compromise: the rule that decides it is in the stylesheet, and the runtime
# never reads the stylesheet. A page's variant can therefore be refused at the
# gate and not at render — named as a limit in the daytrip.
#
# Two variants the corpus says are recorded rather than fixed: styling them is
# a design decision and dropping them is a page change, so they wait on a
# ruling and are printed on every run until they get one.
UNSTYLED_BY_RULING = {
  'grid--cards' => 'said at pages/specimen.sp:57',
  'grid--metrics' => 'said at pages/specimen.sp:20, examples/portfolio/views/index.sp:3, ' \
                     'examples/roth/views/partials/report.sp:5'
}.freeze

said_variants = Hash.new { |h, k| h[k] = [] }
Dir[File.join(__dir__, '{pages,examples,lib/vocabulary,studio}', '**', '*.sp')].each do |path|
  walk = lambda do |nodes|
    nodes.each do |node|
      contract = SlimPickins::CONTRACTS[node.word.to_sym]
      if contract&.name == :variant
        variant = node.raw_args.zip(node.ranks).find { |_, rank| rank.zero? }&.first
        said_variants["#{node.word}--#{variant}"] << "#{path.sub("#{__dir__}/", '')}:#{node.lineno}" if variant
      end
      walk.call(node.children)
    end
  end
  walk.call(SlimPickins::Transform.tree(File.read(path), path: path))
end

(said_variants.keys - defined.to_a - UNSTYLED_BY_RULING.keys).sort.each do |klass|
  fail!("UNSTYLED VARIANT  `#{klass}` is said at #{said_variants[klass].uniq.join(', ')} " \
        'and no rule defines it — a variant nothing can style is refused')
  problems += 1
end
UNSTYLED_BY_RULING.each_key do |klass|
  next unless said_variants.key?(klass)

  puts "  RECORDED    `#{klass}` is said and unstyled — #{UNSTYLED_BY_RULING[klass]}"
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
