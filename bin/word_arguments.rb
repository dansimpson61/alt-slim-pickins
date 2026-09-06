#!/usr/bin/env ruby
# frozen_string_literal: true

# The vocabulary sorted by what each word takes and what it passes on —
# read out of the contracts, which is where those facts already live, so
# this cannot drift from the gate that enforces them.
#
#   ruby bin/word_arguments.rb            # the whole census
#   ruby bin/word_arguments.rb takes      # only what a word takes
#   ruby bin/word_arguments.rb passes     # only what a word passes on
#   ruby bin/word_arguments.rb --markdown # tables, for pasting into a document
#
# Either half of the vocabulary alone — which is the split the kernel work
# cares about, so it is a first-class question here:
#
#   ruby bin/word_arguments.rb --primitives   # the Ruby words (--ruby)
#   ruby bin/word_arguments.rb --partials     # the words written in .sp (--sp)
#
# It is a reader, never a writer. bin/generate_vocabulary.rb is the one
# script that edits from the contracts; this one only looks.

require_relative '../lib/slim_pickins'

module WordArguments
  module_function

  TEXT = SlimPickins::Contracts

  def partial?(word)
    @partials ||= SlimPickins::Library.builtin_partials.keys
    @partials.include?(word)
  end

  def origin(word) = partial?(word) ? '.sp' : 'rb'

  # The census reads one set of words, and every section reads it through
  # here — so a filter is applied once rather than remembered in nine
  # places. `only` is :ruby, :partials, or nil for the whole vocabulary.
  def all_words
    @all_words ||= begin
      # Ensure builtin partials are registered
      SlimPickins::Library.builtin
      SlimPickins::Word.registry.keys.map(&:to_sym)
    end
  end

  def words
    hash = all_words.to_h { |w| [w, SlimPickins::CONTRACTS[w]] }.compact
    case @only
    when :ruby     then hash.reject { |word, _| partial?(word) }
    when :partials then hash.select { |word, _| partial?(word) }
    else hash
    end
  end

  # `-` reads better than an empty column in a terminal.
  def or_dash(list) = list.empty? ? '-' : list.join(' ')

  # The heading always says what is being counted — a filtered census that
  # reported the whole vocabulary's totals would be a lie by omission.
  def counts
    shown = words.size
    whole = SlimPickins::CONTRACTS.size
    case @only
    when :ruby     then "#{shown} Ruby primitives, of #{whole} words"
    when :partials then "#{shown} words written in the language (.sp), of #{whole}"
    else
      sp = words.each_key.count { |w| partial?(w) }
      "#{shown} words — #{shown - sp} in Ruby, #{sp} written in the language (.sp)"
    end
  end

  # Grouped by a contract slot, largest group first, so the shape of the
  # vocabulary is visible before any single word is.
  def by(slot)
    words.group_by { |_, contract| contract.send(slot) }
         .sort_by { |value, group| [-group.size, value.to_s] }
  end

  # --- what a word takes -------------------------------------------------

  def takes(out)
    out.section('A. What a word takes — the name slot',
                'A bare name is never evaluated. What it *means* is the word\'s business.')
    by(:name).each do |slot, group|
      # `none`'s gloss is the word "none"; saying it twice helps nobody.
      gloss = TEXT::NAME_TEXT.fetch(slot)
      out.group("#{slot} (#{group.size})", gloss == slot.to_s ? nil : gloss)
      group.each do |word, contract|
        out.row(word, origin(word),
                content: contract.content ? 'yes' : '-',
                modifiers: or_dash(contract.modifiers))
      end
    end

    out.section('Modifiers', '`if:` is universal; these are the rest.')
    words.reject { |_, c| c.modifiers.empty? }
         .each { |word, c| out.row(word, origin(word), takes: c.modifiers.map { |m| "#{m}:" }.join(' ')) }

    with, without = words.partition { |_, c| c.content }
    out.section('Content', "#{with.size} words take text or data; #{without.size} take none.")
    out.list('takes content', with.map(&:first))
    out.list('takes none', without.map(&:first))
  end

  # --- what a word passes on ---------------------------------------------

  def passes(out)
    out.section('B. What a word passes on — the subject',
                'The one resolution rule: `.foo` is the innermost subject.')
    by(:subject).each do |flow, group|
      out.group("#{flow} (#{group.size})", TEXT::SUBJECT_TEXT.fetch(flow))
      out.list(nil, group.map(&:first))
    end

    out.section('Children', 'What may nest beneath, which is what the gate walks.')
    none = words.select { |_, c| c.children == :none }.keys
    any  = words.select { |_, c| c.children == :any }.keys
    named = words.select { |_, c| c.children.is_a?(Array) }
    out.list("holds nothing (#{none.size})", none)
    out.list("holds anything (#{any.size})", any)
    out.group("holds a named set (#{named.size})", nil)
    named.each { |word, c| out.row(word, origin(word), holds: c.children.join(' ')) }

    out.section('The passing mechanisms',
                'How a word hands something to another word rather than to the page.')
    out.list('gathers — its children are declarations',
             words.select { |_, c| c.gathers }.keys)
    out.list('inside: — routes its nodes up to a gatherer',
             words.select { |_, c| c.inside != :any }.map { |w, c| "#{w}->#{c.inside}" })
    out.list('parents: — ancestry checked by the gate',
             words.select { |_, c| c.parents != :any }
                  .map { |w, c| "#{w}<-#{Array(c.parents).join('/')}" })
    out.list('lazy — content arrives unevaluated',
             words.select { |_, c| !c.lazy.empty? }.keys)
    %i[id label empty].each do |derived|
      out.list("#{derived}: — derived at runtime, never said in a page",
               words.select { |_, c| c.send(derived) }.keys)
    end

    out.section('Part of speech', 'This is a noun language; the exceptions are the control flow.')
    by(:speech).each { |kind, group| out.list("#{kind} (#{group.size})", group.map(&:first)) }
  end

  # --- two voices for the same census ------------------------------------

  # The terminal. Plain columns, because a census is read down a column.
  class Plain
    def initialize = (@out = +'')
    def to_s = @out

    def title(text) = @out << "#{text}\n#{'=' * text.size}\n"
    def section(head, note = nil)
      @out << "\n\n#{head}\n#{'-' * head.size}\n"
      @out << "#{note}\n" if note
    end

    def group(head, note)
      @out << "\n  #{head}#{note ? " — #{note}" : ''}\n"
    end

    # Values are padded, not just labels: a column of `content=yes` above
    # `content=-` that does not line up is a column you have to read twice.
    WIDTH = { content: 3, modifiers: 24, takes: 24, holds: 0 }.freeze

    def row(word, origin, **fields)
      cells = fields.map { |key, value| "#{key}=#{value.to_s.ljust(WIDTH.fetch(key, 0))}" }
      @out << format("    %-12s %-4s %s\n", word, origin, cells.join('  ').rstrip)
    end

    def list(label, words)
      return if words.empty?

      @out << (label ? "\n  #{label}:\n" : "\n")
      @out << "    #{words.join(' ')}\n"
    end
  end

  # A document. The same facts, as tables to paste.
  class Markdown
    def initialize = (@out = +'')
    def to_s = @out

    def title(text) = @out << "# #{text}\n"
    def section(head, note = nil)
      @out << "\n## #{head}\n\n"
      @out << "#{note}\n\n" if note
      @head = nil
    end

    def group(head, note)
      @out << "\n**#{head}**#{note ? " — #{note}" : ''}\n\n"
      @head = nil
    end

    def row(word, origin, **fields)
      unless @head
        @out << "| word | | #{fields.keys.join(' | ')} |\n"
        @out << "|---|---|#{'---|' * fields.size}\n"
        @head = true
      end
      @out << "| `#{word}` | #{origin} | #{fields.values.map { |v| v == '-' ? '—' : v }.join(' | ')} |\n"
    end

    def list(label, words)
      return if words.empty?

      @out << (label ? "- **#{label}** — " : '- ')
      @out << "#{words.map { |w| "`#{w}`" }.join(' ')}\n"
      @head = nil
    end
  end

  def call(argv)
    @only =
      if    argv.grep(/\A--(ruby|primitives)\z/).any? then :ruby
      elsif argv.grep(/\A--(sp|partials)\z/).any?     then :partials
      end
    out = argv.include?('--markdown') ? Markdown.new : Plain.new
    wanted = argv.reject { |a| a.start_with?('--') }
    out.title("The vocabulary by argument — #{counts}")
    takes(out)  if wanted.empty? || wanted.include?('takes')
    passes(out) if wanted.empty? || wanted.include?('passes')
    out.to_s
  end
end

puts WordArguments.call(ARGV) if __FILE__ == $PROGRAM_NAME
