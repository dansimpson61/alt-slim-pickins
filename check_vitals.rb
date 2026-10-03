#!/usr/bin/env ruby
# frozen_string_literal: true
#
# The eleventh checker: a number this project states about itself is the
# census's number.
#
# `SlimPickins::Census` has been the living SSOT since DAYTRIP-0.4.0a, and
# until this script `bin/census.rb` was its only reader. That is why the counts
# it exists to settle were wrong in six places at once (DAYTRIP-0.4.0h, Part
# 2): a document that states a number is not a document that measures one, and
# nothing was asking it to be.
#
# Two rules, because the defect wears two costumes.
#
#   - PROSE — in a living document or a `.rb` comment, a number standing next
#     to a vital's name must be the census's value. Numbers the prose spells
#     out count too: `README` says "sixty-two words" twice, and a gate blind to
#     that would teach the project to spell its numbers out. In a `.rb` file
#     prose lives in two places and the gate reads both — comments, and the
#     strings an app shows a reader. `milestone_planner` describes a milestone
#     as exercising "the frozen 64 words" in a string, which is as false on the
#     page as it would be in a comment.
#   - RUBY — outside the census itself, a vital's own key name may not be
#     assigned a literal. `word_count: 64` is the same claim as "64 words" at a
#     different altitude, and it was found inside a gate (`verify_pages.rb`),
#     a third copy of literals the studio had already removed from two homes.
#     The answer to a vital is never a literal; it is `Census.snapshot`.
#
# Scope is the design question this gate had to answer, so it is written down
# rather than implied:
#
#   - Everything in the repository root and `docs/` is prose in scope the day
#     it arrives, minus `EXEMPT` below. A list of covered documents maintained
#     by hand is the same drift this gate exists to catch, and writing the scan
#     this way immediately found three documents such a list had never named.
#   - The dated record is exempt, with a reason per entry. An entry that quoted
#     the number true when it was written is not lying, and a gate that cannot
#     tell a record from a claim will be bargained with inside a week. The
#     reason is the point: a future reader can disagree with a reason, which is
#     not true of a bare skip list.
#   - `history/` and `roth/` are consulted rather than maintained, and are not
#     reached at all.
#
# What is *not* a claim. Four kinds of text hold a number without stating one,
# and the gate masks each before it reads — masking rather than skipping, so
# the line numbers it reports stay the line numbers on disk:
#
#   1. A number inside a quoted span — `` `WORDS = 64` ``, or a gate's vitals
#      row quoted as an example — is exhibited, not asserted. `studio/vitals.rb`'s
#      comment narrates the literals it was built to delete, and quoting them
#      is what makes that honest rather than stale.
#   2. A number inside a date. `until 2026-09-17 no Word answered` is not a
#      claim about seventeen words.
#   3. A list marker. `4. **No word may…**` numbers a rule; it does not count
#      words.
#   4. A number too far from the noun to be its count. At most one word may
#      stand between them, and no sentence punctuation may — otherwise `Phase
#      0 built this word` reads as a claim that the vocabulary is empty.
#
# One further narrowing, decided before the first run rather than after seeing
# what it caught: a spelled number below twenty is not read as a vital. In
# English those are determiners — "one resolution rule", "fixed it with two
# words" — while every quantity the census measures is at least twenty. Digits
# are always read, so "7 apps" is still held.
#
# Where that leaves a sentence that means "as of volet 4, there were 64": say
# so by quoting the number, the way rule 1 describes. The gate holds live prose
# to the live measurement, and prose about the past is asked to look like it.
#
# Exits non-zero on any problem, so it can gate a commit.

require 'set'
require_relative 'lib/slim_pickins/census'

# A module rather than a straight script, so the suite can ask it questions the
# real corpus cannot pose — the idiom `check_spiff_scope.rb` already uses.
module Vitals
  ROOT = __dir__

  # --- the dated record, and why each entry is not a claim about now ---------
  EXEMPT = {
    'LORE.md' => 'dated entries — what a session learned, on the day it learned it',
    'KERNEL.md' => 'a draft spec that pins its measurements to tree 5d43fe9 in its own first paragraph',
    'COMMUNITY_BULLETIN_BOARD.md' => 'a council transcript, argued on a date',
    'BLUESKY.md' => 'speculation, deliberately unmeasured',
    'spiff_discussion.md' => 'a conversation, kept as it was had',
    'DEMAND.md' => "roadmap 0.3's phase ledger, written against a vocabulary it froze on purpose",
    'DAYTRIP.md' => 'the first daytrip, and a record of the vitals as they stood that day',
    'Tight Coupling in Ruby DSLs.md' => "a transcript of someone else's critique, not this project's prose",
    'ROADMAP-*.md' => 'each phase records what was true at that phase, which is the value',
    'DAYTRIP-*.md' => "a round's record — that it is never updated is the whole point"
  }.freeze

  # `apps` is the one vital the snapshot answers with a list rather than a count.
  VALUES = SlimPickins::Census.snapshot.then { |s| s.merge(apps: s[:apps].size) }.freeze

  # A quantity the census measures: how prose names it, and the Ruby keys that
  # carry it. Order matters — `app words` has to claim the text before `words`
  # can see it — so the list runs most specific first.
  Vital = Struct.new(:key, :nouns, :ruby_keys, keyword_init: true) do
    def value = VALUES.fetch(key)
    def name = key.to_s.tr('_', ' ')

    # The two shapes a claim takes, compiled once per noun. Built inline instead,
    # they were rebuilt for every block of every file — a hundred and thirty
    # files' worth, times ten vitals, times two — and the leg cost five seconds
    # against the two the other ten legs take together.
    def patterns
      @patterns ||= nouns.flat_map do |noun|
        [/(#{NUMBER})#{GAP}(?:#{noun})/, /(?:#{noun})\s*[:=]\s*(#{NUMBER})/]
      end
    end
  end

  VITALS = [
    Vital.new(key: :app_words, nouns: [/app words?/i], ruby_keys: %w[app_words_count]),
    Vital.new(key: :test_files, nouns: [/test files?/i], ruby_keys: %w[test_files_count]),
    Vital.new(key: :ruby_primitives, nouns: [/ruby (?:primitives|classes)/i, /primitives/i], ruby_keys: []),
    Vital.new(key: :sp_partials, nouns: [/\.sp\W{0,2}(?:partials|templates)/i, /partials/i], ruby_keys: []),
    Vital.new(key: :css_rules, nouns: [/(?:style|stylesheet|css) rules?/i, /rules?/i],
              ruby_keys: %w[rules_count styles_count style_count]),
    Vital.new(key: :verified_pages, nouns: [/(?:verified |rendered )?pages?/i],
              ruby_keys: %w[pages_count page_count]),
    Vital.new(key: :conventions, nouns: [/conventions?/i], ruby_keys: %w[convention_count conventions_count]),
    Vital.new(key: :promises, nouns: [/promises?/i], ruby_keys: %w[promise_count promises_count]),
    Vital.new(key: :apps, nouns: [/apps?\b/i, /applications?/i], ruby_keys: %w[apps_count app_count]),
    Vital.new(key: :canonical_words, nouns: [/(?:canonical |vocabulary |known |total )?words?/i],
              ruby_keys: %w[word_count])
  ].freeze

  # A key whose answer is never a literal, whatever the literal says: `measured`
  # asks when these numbers were taken, and the only honest answer is now.
  STAMP_KEYS = %w[measured measured_at].freeze

  # --- numbers, including the ones the prose spells out ----------------------
  TENS = %w[twenty thirty forty fifty sixty seventy eighty ninety].freeze
  UNITS = %w[one two three four five six seven eight nine].freeze

  SPELLED = /(?:#{TENS.join('|')})(?:[- ](?:#{UNITS.join('|')}))?/i
  NUMBER = /\b(?:\d{1,4}|#{SPELLED})\b/
  # Between the number and the noun: one word at most, and no punctuation that
  # would let the claim reach into the next clause.
  GAP = /[\s`*_-]{0,3}(?:[A-Za-z][A-Za-z-]{0,14}[\s`*_]{1,3})?/
  # A quoted span wraps at column 80 whichever delimiter it uses, and Ruby has
  # more delimiters than two: `%(...)` and its siblings are string literals as
  # much as `"..."` is, and leaving them out let a fixture written that way read
  # as code. Single quotes are deliberately absent — prose uses an apostrophe
  # far more often than a quotation, and a mask that swallowed every one would
  # hide real claims.
  QUOTED = /
    `[^`\n]*(?:\n[^`\n]*)?`
    | "[^"\n]*(?:\n[^"\n]*)?"
    | %[qQwWi]?\([^)\n]*\)
    | %[qQwWi]?\{[^}\n]*\}
    | %[qQwWi]?\[[^\]\n]*\]
  /x

  Claim = Struct.new(:file, :line, :vital, :stated, :excerpt, keyword_init: true) do
    def true? = stated == vital.value
    def where = "#{file}:#{line}"
  end

  Problem = Struct.new(:kind, :message, :excerpt, keyword_init: true)

  module_function

  # Matched on the basename: every document in scope sits at the root or in
  # `docs/`, so the patterns need no path, and a rule written without one can be
  # asked about a fixture as easily as about the repository.
  def exempt?(path) = EXEMPT.keys.any? { |pattern| File.fnmatch?(pattern, File.basename(path)) }

  # `sixty-two` is 62. Anything the matcher found is one of the two forms the
  # NUMBER pattern admits.
  def number_of(text)
    return Integer(text, 10) if /\A\d+\z/.match?(text)

    tens, unit = text.downcase.tr('-', ' ').split
    (TENS.index(tens) + 2) * 10 + (unit ? UNITS.index(unit) + 1 : 0)
  end

  # The four kinds of text that hold a number without stating one, struck out
  # character for character so every offset still points where it did.
  def mask(body)
    body.gsub(QUOTED) { |span| span.gsub(/[^\n]/, '~') }
        .gsub(/\d{4}-\d\d-\d\d/) { |date| '~' * date.length }
        .gsub(/(?<=\A|\n)([ \t]*\#?[ \t]*)(\d+\.)(?=\s)/) do
          "#{::Regexp.last_match(1)}#{'~' * ::Regexp.last_match(2).length}"
        end
  end

  # Prose is read a block at a time, not a line at a time: the elision that hid
  # `check_shape.rb`'s own "(59 of 64)" for a month puts the noun in one
  # sentence and the number in the next.
  def blocks_of(text, comment: false)
    lines = text.lines.each_with_index.map { |line, index| [index + 1, line] }
    lines = lines.select { |_, line| line.lstrip.start_with?('#') } if comment
    lines.chunk_while { |(a, _), (b, _)| b == a + 1 }
         .reject { |chunk| chunk.all? { |_, line| line.strip.empty? } }
         .map { |chunk| [chunk.first.first, chunk.map(&:last).join] }
  end

  # The prose in a `.rb` file that is not a comment: the strings an app puts in
  # front of a reader. Interpolated and escaped strings are left alone — a
  # string that computes part of itself is not a hand-kept literal.
  #
  # Only the apps' and runtime's strings, never a suite's. The justification for
  # reading strings at all is that a reader sees them, and nobody reads a
  # fixture — which is also why this gate can be given a test that is nothing
  # but wrong numbers without the gate reporting its own suite.
  def strings_of(text)
    text.lines.each_with_index.flat_map do |line, index|
      next [] if line.lstrip.start_with?('#')

      line.scan(/'([^'\\\n\#]*)'|"([^"\\\n\#]*)"/).map { |single, double| [index + 1, single || double] }
    end
  end

  # One passage being read. It exists to hold the two things the three
  # productions below must agree about: where a match sits in the original text,
  # and which spans have already been claimed. `app words` has to win over
  # `words`, which it can only do if the broader noun is told the text is taken.
  class Reading
    def initialize(body, file:, start:)
      @body = body
      @file = file
      @start = start
      @taken = []
      @claims = []
    end

    attr_reader :claims

    # Every production offers its match here, and a span inside one already
    # claimed is declined rather than double-counted.
    def claim(vital, stated, match)
      span = match.begin(0)...match.end(0)
      return if @taken.any? { |taken| taken.cover?(span.begin) || span.cover?(taken.begin) }

      @taken << span
      @claims << Claim.new(file: @file, line: line_at(span.begin), vital: vital, stated: stated,
                           excerpt: match[0].gsub(/\s+/, ' '))
    end

    # The block was joined from real lines, so the offset still names one.
    def line_at(offset) = @start + @body[0, offset].count("\n")
  end

  def claims_in(raw, file:, start:)
    body = mask(raw)
    reading = Reading.new(body, file: file, start: start)

    # `62 canonical words`, and the reverse form a gate's own vitals row uses,
    # `words: 62`. Most specific vital first, so `app words` claims the span
    # before `words` is offered it.
    VITALS.each do |vital|
      vital.patterns.each do |pattern|
        body.scan(pattern) { reading.claim(vital, number_of(Regexp.last_match(1)), Regexp.last_match) }
      end
    end

    elided(body).each { |vital, stated, match| reading.claim(vital, stated, match) }
    reading.claims
  end

  # `N of M` elides the noun — "a noun language (59 of 64)". The total is the
  # claim, and it belongs to whichever vital the surrounding block names. The
  # twenty-floor applies here too: a coverage fraction over a vital is a fraction
  # over a vital-sized set, so `11 of 14` labels on a form is not one.
  def elided(body)
    body.to_enum(:scan, /\b\d\d+ of (\d\d+)\b/).filter_map do
      match = Regexp.last_match
      total = Integer(match[1], 10)
      next if total < 20

      vital = VITALS.reverse.find { |candidate| candidate.nouns.any? { |noun| body.match?(noun) } }
      [vital, total, match] if vital
    end
  end

  # --- the corpus -----------------------------------------------------------
  def all_documents = (Dir[File.join(ROOT, '*.md')] + Dir[File.join(ROOT, 'docs', '*.md')]).sort

  def all_ruby_files
    (Dir[File.join(ROOT, '{lib,bin,studio,test,examples}', '**', '*.rb')] +
      Dir[File.join(ROOT, 'check_*.rb')]).sort
  end

  def census_home = File.join(ROOT, 'lib', 'slim_pickins', 'census.rb')

  def suite?(path) = path.end_with?('_test.rb') || path.include?('/test/')

  def claims_from(documents, ruby_files)
    claims = []
    (documents + ruby_files).each do |path|
      relative = path.delete_prefix("#{ROOT}/")
      source = File.read(path)
      ruby = path.end_with?('.rb')

      blocks_of(source, comment: ruby).each do |start, block|
        claims.concat(claims_in(block, file: relative, start: start))
      end
      next unless ruby && !suite?(path)

      strings_of(source).each do |line, string|
        claims.concat(claims_in(string, file: relative, start: line))
      end
    end
    claims
  end

  # Rule two: a vital's own key name, assigned a literal, anywhere but the
  # census that measures it. Quoted spans are struck out first, by the same rule
  # the prose side uses — an assignment inside a string is being exhibited, not
  # made, which is how a comment may narrate the literal it deleted and how this
  # gate's own test may hold the defect it proves.
  #
  # Compiled once, and asked only of the lines that could possibly answer. The
  # naive form built a regex per key per line, which over twenty thousand lines
  # is a quarter of a million throwaway regexes.
  # Each rule is two questions. The *key* is asked of the masked line, because
  # surviving the mask is what proves it is an assignment and not a fixture
  # inside a string. The *value* is then read from the line as written — mask
  # first and `measured: "2026-09-17"` disappears along with its quotes, which
  # is the one thing this rule exists to refuse. Found by mutation: the
  # single-quoted form was caught and the double-quoted form was not.
  LITERALS = VITALS.flat_map do |vital|
    vital.ruby_keys.map { |key| [vital, key, /\b#{key}:/, /\b#{key}:\s*["']?\d/] }
  end.freeze
  STAMPS = STAMP_KEYS.map { |key| [key, /\b#{key}:/, /\b#{key}:\s*['"]/] }.freeze
  WORTH_READING = Regexp.union(*(LITERALS.map { |_, key, _| key } + STAMP_KEYS)).freeze

  def literals_in(ruby_files)
    found = []
    ruby_files.reject { |path| path == census_home }.each do |path|
      relative = path.delete_prefix("#{ROOT}/")

      File.readlines(path).each_with_index do |raw, index|
        next if raw.lstrip.start_with?('#')
        next unless raw.match?(WORTH_READING)

        line = mask(raw)

        LITERALS.each do |vital, key, in_code, assigns_a_literal|
          next unless line.match?(in_code) && raw.match?(assigns_a_literal)

          found << Problem.new(kind: 'HARDCODED', excerpt: raw,
                               message: "#{relative}:#{index + 1} assigns `#{key}` a literal — ask " \
                                        "`Census.snapshot[:#{vital.key}]`, which measures #{vital.value}")
        end

        STAMPS.each do |key, in_code, quotes_a_value|
          next unless line.match?(in_code) && raw.match?(quotes_a_value)

          found << Problem.new(kind: 'STAMPED', excerpt: raw,
                               message: "#{relative}:#{index + 1} hardcodes `#{key}` — when the numbers " \
                                        'were taken is never a literal; it is now')
        end
      end
    end
    found
  end

  def run(documents: nil, ruby_files: nil, out: $stdout)
    ruby_files ||= all_ruby_files
    exempt, documents = (documents || all_documents).partition { |path| exempt?(path) }

    claims = claims_from(documents, ruby_files)
    problems = claims.reject(&:true?).map do |claim|
      Problem.new(kind: 'STALE', excerpt: claim.excerpt,
                  message: "#{claim.where} states #{claim.stated} #{claim.vital.name} — the census " \
                           "measures #{claim.vital.value}")
    end + literals_in(ruby_files)

    problems.each do |problem|
      out.puts "  #{problem.kind.ljust(11)} #{problem.message}"
      out.puts "              #{problem.excerpt.strip.inspect}"
    end

    out.puts
    out.puts 'vitals, as the census measures them'
    VITALS.sort_by(&:key).each do |vital|
      stated = claims.count { |claim| claim.vital == vital }
      out.puts "  #{vital.name.ljust(16)} #{vital.value.to_s.rjust(4)}   #{stated} stated in prose"
    end
    out.puts "  #{claims.size} prose claims read across #{documents.size} documents and " \
             "#{ruby_files.size} Ruby files"
    out.puts "  #{exempt.size} documents exempt as dated record: " \
             "#{exempt.map { |p| File.basename(p) }.sort.join(', ')}"
    out.puts
    out.puts "#{problems.size} problems"
    problems.size
  end
end

exit(Vitals.run.zero? ? 0 : 1) if $PROGRAM_NAME == __FILE__
