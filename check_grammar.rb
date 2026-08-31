#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Keeps the design documents accountable to each other.
#
#   - every sentence obeys the grammar table in DESIGN.md
#   - every word used in a sentence is defined in VOCABULARY.md
#   - every word defined in VOCABULARY.md has at least one sentence
#
# An untagged fence holds sentences and is checked. Tag a fence (```slim,
# ```html) to exclude it — that is how a document shows something that is not
# this language. There is no third category, which is what stops examples
# from rotting.
#
# Exits non-zero when anything is wrong, so it can gate a commit.

require 'set'

DOCS = (%w[DESIGN.md VOCABULARY.md ROADMAP.md README.md
            PORTFOLIO.md CONTENT.md FIGURES.md PHASE0.md PHASE2.md] +
         Dir[File.join(__dir__, '{pages,examples}', '**', '*.sp')]
           .map { |f| f.sub("#{__dir__}/", '') }).freeze

WORD = /\A[a-z][a-z_]*\z/

# A name is never evaluated; all data is dotted. Ranks must never decrease
# across a sentence: names, then content, then modifiers.
KINDS = {
  0 => /\A[a-z][a-z_]*\z/,                                # a name
  1 => /\A(".*"|\.[a-z_]+\??|[a-z_]+(\.[a-z_]+)+\??)\z/,  # data — always dotted
  2 => /\A[a-z_]+:\s*.+\z/                                # a modifier
}.freeze

# Split on commas that are not inside quotes or parentheses.
def split_args(str)
  parts, buf, depth, quoted = [], +'', 0, false
  str.each_char do |c|
    if c == '"'                   then quoted = !quoted; buf << c
    elsif quoted                  then buf << c
    elsif c == ',' && depth.zero? then parts << buf.strip; buf = +''
    else
      depth += 1 if c == '('
      depth -= 1 if c == ')'
      buf << c
    end
  end
  parts << buf.strip unless buf.strip.empty?
  parts
end

def kind_of(arg)
  KINDS.each { |rank, re| return rank if arg =~ re }
  nil
end

# Walk a document and yield each line of every *untagged* fenced block.
# A regex cannot do this: a closing fence is indistinguishable from an opening
# one, so the pairing has to be tracked. Getting this wrong made the checker
# read prose as grammar.
def each_sentence_line(path)
  # A .sp file is a page: all of it is sentences, no fences involved.
  unless path.end_with?('.md')
    File.readlines(path).each_with_index { |raw, i| yield raw, i + 1 }
    return
  end

  open = false
  checking = false
  File.readlines(path).each_with_index do |raw, i|
    if raw.start_with?('```')
      if open
        open = false
      else
        open = true
        checking = raw.chomp == '```'
      end
      next
    end
    yield raw, i + 1 if open && checking
  end
end

here = File.expand_path(__dir__)
docs = ARGV.empty? ? DOCS.map { |f| File.join(here, f) } : ARGV

# slim-pickins' vocabulary, plus the app's own — a partial file defines a
# word, and a call site cannot tell the two apart, so neither can this.
vocab = File.read(File.join(here, 'VOCABULARY.md'))
            .scan(/^### `([a-z_]+)`/).flatten.to_set
# An app's vocabulary: partials anywhere in the repo, plus words defined in
# Ruby through the escape hatch, which live in a module named *Words.
app_words = Dir[File.join(here, '**', 'partials', '*.sp')]
            .map { |f| File.basename(f, '.sp') }.to_set
Dir[File.join(here, 'examples', '**', '*.rb')].each do |f|
  File.read(f).scan(/module \w*Words\b(.*?)^end/m).flatten.each do |body|
    app_words |= body.scan(/^\s*def ([a-z_]+)/).flatten.to_set
  end
end
vocab |= app_words
used = Hash.new { |h, k| h[k] = [] }
problems = 0
checked = 0

docs.each do |doc|
  where = File.basename(doc)
  each_sentence_line(doc) do |raw, lineno|
    line = raw.chomp.sub(/\s+#.*\z/, '').rstrip
    next if line.strip.empty?

    body = line.strip
    at = "#{where}:#{lineno}"
    word, _, rest = body.partition(' ')

    unless word =~ WORD
      puts "  BAD WORD      #{at}: #{body.inspect}"
      problems += 1
      next
    end

    checked += 1
    used[word] << where
    ranks = split_args(rest).map { |a| [a, kind_of(a)] }
    ranks.each do |arg, rank|
      next unless rank.nil?

      puts "  UNKNOWN ARG   #{at}: #{arg.inspect} in #{body.inspect}"
      problems += 1
    end

    seq = ranks.map(&:last).compact
    next if seq == seq.sort

    puts "  ORDER         #{at}: #{body.inspect} ranks=#{seq.inspect}"
    problems += 1
  end
end

(used.keys.to_set - vocab).sort.each do |w|
  puts "  UNDEFINED     #{w.inspect} used in #{used[w].uniq.join(', ')} but not in VOCABULARY.md"
  problems += 1
end

((vocab - app_words) - used.keys.to_set).sort.each do |w|
  puts "  UNEXEMPLIFIED #{w.inspect} defined but has no sentence"
  problems += 1
end

puts "\n#{checked} sentences checked, #{vocab.size} words defined, #{problems} problems"
exit(problems.zero? ? 0 : 1)
