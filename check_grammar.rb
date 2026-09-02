#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Keeps the design documents accountable to the code, and to the grammar —
# which has exactly one home, Transform. This checker holds no grammar of its
# own: it compiles, and Transform raises.
#
#   - every sentence compiles — Transform names the line and what was expected
#   - every word used in a sentence is defined in VOCABULARY.md, or is an app
#     word (a partial found through Library, or a method of a *Words module)
#   - every word defined in VOCABULARY.md has at least one sentence
#
# An untagged fence holds sentences and is checked. Tag a fence (```slim,
# ```html) to exclude it — that is how a document shows something that is not
# this language. There is no third category, which is what stops examples
# from rotting.
#
# Exits non-zero when anything is wrong, so it can gate a commit.

require 'set'
require_relative 'lib/slim_pickins'

DOCS = (%w[DESIGN.md VOCABULARY.md README.md PRIMER.md ROADMAP-0.2.md
            history/ROADMAP-0.1.md history/PORTFOLIO.md history/CONTENT.md
            history/FIGURES.md history/PHASE0.md history/PHASE2.md
            history/PHASE7.md] +
         Dir[File.join(__dir__, '{pages,examples,lib/vocabulary}', '**', '*.sp')]
           .map { |f| f.sub("#{__dir__}/", '') }).freeze

here = File.expand_path(__dir__)
docs = ARGV.empty? ? DOCS.map { |f| File.join(here, f) } : ARGV

# The vocabulary, plus the app's own. A partial file defines a word, and it
# is found the way the runtime finds it — through Library, not a glob of this
# checker's own. Words defined in Ruby through the escape hatch live in a
# module named *Words; the scan below is *discovery only*, and the runtime's
# registry (Builder extends the module's methods) is what makes them words.
vocab = File.read(File.join(here, 'VOCABULARY.md'))
            .scan(/^### `([a-z_]+)`/).flatten.to_set

# Words the language has renamed. The records in history/ speak the language
# as it was when each phase closed, and a record that updates itself is not a
# record — so a renamed word stays legal there, and only there.
renamed = File.read(File.join(here, 'VOCABULARY.md'))
              .scan(/^Formerly `([a-z_]+)`/).flatten.to_set

app_words = Set.new
app_words |= SlimPickins::Library.from(File.join(here, 'pages')).partials.keys.map(&:to_s)
app_words |= Dir[File.join(here, 'lib', 'vocabulary', '*.sp')].map { |f| File.basename(f, '.sp') }
Dir[File.join(here, 'examples', '**', 'views')].select { |d| File.directory?(d) }.each do |dir|
  app_words |= SlimPickins::Library.from(dir).partials.keys.map(&:to_s)
end

# The `end` that closes the module is the one at the module's own indentation.
# Anchoring on `^end` instead read straight past a nested module and counted
# every later method as a word — which would quietly hide a genuinely
# undefined one.
Dir[File.join(here, 'examples', '**', '*.rb')].each do |f|
  File.read(f).scan(/^([ \t]*)module \w*Words\b(.*?)^\1end/m).each do |_indent, body|
    app_words |= body.scan(/^\s*def ([a-z_]+)/).flatten.to_set
  end
end
vocab |= app_words

# Walk a document and yield each untagged fenced block, with the line its
# first sentence stands on. A regex cannot pair fences: a closing ``` is
# indistinguishable from an opening one, so the pairing is tracked.
def each_block(path)
  unless path.end_with?('.md')
    yield File.read(path), 1
    return
  end

  open = false
  checking = false
  buf = []
  start = 1
  File.readlines(path).each_with_index do |raw, i|
    if raw.start_with?('```')
      if open
        yield buf.join, start if checking && buf.any?
        open = false
        checking = false
        buf = []
      else
        open = true
        checking = raw.chomp == '```'
        start = i + 2
      end
      next
    end
    buf << raw if open && checking
  end
  yield buf.join, start if open && checking && buf.any?
end

used = Hash.new { |h, k| h[k] = [] }
used_full = Hash.new { |h, k| h[k] = [] }
problems = 0
checked = 0

docs.each do |doc|
  where = File.basename(doc)
  each_block(doc) do |source, first_line|
    begin
      tree = SlimPickins::Transform.tree(source, path: where)
    rescue SlimPickins::SyntaxError => e
      puts "  BAD SENTENCE  #{where}:#{first_line + e.lineno - 1}: #{e.line.inspect} — #{e.message.lines.first.strip}"
      problems += 1
      next
    end

    # Walk the tree with the grammar itself, enforcing each word's declared
    # contract: what it takes, what it holds, and where it may live.
    walk = lambda do |nodes, ancestry|
      nodes.each do |node|
        checked += 1
        used[node.word] << where
        used_full[node.word] << doc

        SlimPickins::Contracts.complaints(node, ancestry).each do |complaint|
          puts "  BAD CONTRACT  #{where}:#{first_line + node.lineno - 1}: `#{node.word}` — #{complaint}"
          problems += 1
        end

        walk.call(node.children, ancestry + [node.word])
      end
    end
    walk.call(tree, [])
  end
end

(used.keys.to_set - vocab).sort.each do |w|
  history_only = used_full[w].all? { |f| f.start_with?(File.join(here, 'history')) }
  next if renamed.include?(w) && history_only

  puts "  UNDEFINED     #{w.inspect} used in #{used[w].uniq.join(', ')} but not in VOCABULARY.md"
  problems += 1
end

# A single file is not a fair corpus, so the unexemplified check only runs
# over the documents as a whole.
if ARGV.empty?
  ((vocab - app_words) - used.keys.to_set).sort.each do |w|
    puts "  UNEXEMPLIFIED #{w.inspect} defined but has no sentence"
    problems += 1
  end
end

# VOCABULARY.md's five checkable bullets are generated from the contracts —
# the declarations are the single home, and bin/generate_vocabulary.rb is the
# only way to edit them. A hand-edited bullet fails here.
File.read(File.join(here, 'VOCABULARY.md'))
    .split(/^(### `[a-z_]+`)/).drop(1).each_slice(2) do |header, body|
  next unless header =~ /\A### `([a-z_]+)`/

  word = Regexp.last_match(1)
  contract = SlimPickins::CONTRACTS[word.to_sym]
  next unless contract

  SlimPickins::Contracts.bullets(word, contract).each do |bullet|
    slot = bullet[/^- \*\*(\w+)\*\*/, 1]
    actual = body[/^- \*\*#{slot}\*\* —.*$/, 0]
    next if actual == bullet

    puts "  UNGENERATED   VOCABULARY.md `#{word}`: expected #{bullet.inspect}, got #{actual.inspect}"
    problems += 1
  end
end

puts "\n#{checked} sentences checked, #{vocab.size} words defined, #{problems} problems"
exit(problems.zero? ? 0 : 1)
