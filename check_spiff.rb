#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Holds the design idiom's lexicon to the compiler.
#
#   - the lexicon documents every word the compiler implements
#   - every word's example source compiles
#   - every declaration in an example's compiled-CSS block is one the
#     compiler really emits for that example
#
# This is the fifth checker and the last instrument the 2026-09-26 truth
# round asked for. The round found four of the lexicon's compiled-CSS blocks
# had drifted from `Spiff` — `container-type` on `body` rather than
# `html`, `align-items: start`, and two emitted properties nothing documented
# — and that nothing in the repo could have noticed: `check_grammar` reads
# the root documents (never `docs/`), and `docs/SPIFF.md` is prose
# about CSS, so none of the other checkers look at it either. A `<details>`
# block claiming to show "the exact modern CSS emitted under the hood" is a
# measurement with no instrument behind it. This is the instrument.
#
# Both directions, like the other checkers: the lexicon must document every
# word the compiler implements (an undocumented word is a gap a reader cannot
# see), and every documented word must still compile (a documented word the
# compiler dropped is a lie).
#
# Exits non-zero when anything is wrong.

require_relative 'lib/slim_pickins'

LEXICON = File.join(__dir__, 'docs', 'SPIFF.md')
compiler = SlimPickins::Compiler::Spiff

# Words that honestly emit no CSS of their own, so their entries carry no
# compiled block and `surface`'s example compiles to an empty string on
# purpose. `surface` is scope, not style: it names the manifesto and which
# container convention its `stage` targets, and the `stage` does the work.
NO_CSS = %w[surface].freeze

# --- parsing the lexicon ------------------------------------------------------
#
# An entry is `### `word`` and runs to the next `### `. Within it, every
# fenced `` ```css `` block is a claim about what this word emits, and the
# entry's closing example — the last fenced `text` block before the first CSS
# block — is the source that claim is made about.
module Lexicon
  Entry = Struct.new(:word, :example, :css_blocks, keyword_init: true)
  Decl = Struct.new(:selector, :property, :value, keyword_init: true)

  module_function

  def entries(source)
    source.split(/^### /).drop(1).filter_map do |section|
      word = section[/^`([a-z_]+)`/, 1]
      next unless word

      # Fences may be indented — the lexicon writes its examples inside list
      # items, two spaces in — so the anchor allows leading space. Reading
      # only column 0 is the error `LORE.md` records under "indented code
      # fences break column-0 regexes"; this checker made it once already.
      blocks = section.scan(/^[ \t]*```(\w*)\n(.*?)^[ \t]*```/m)
      first_css = blocks.index { |lang, _| lang == 'css' }
      next unless first_css || NO_CSS.include?(word)

      Entry.new(
        word: word,
        example: blocks[0...(first_css || blocks.size)].last&.last.to_s,
        css_blocks: blocks.select { |lang, _| lang == 'css' }.map { |_, body| body }
      )
    end
  end

  # A documented declaration, read the way a reader reads it. Comments are
  # stripped first, so the `balance` entry's `/* equal */` labels do not
  # become a property called `/* equal */`.
  def declarations(css_block)
    body = css_block.gsub(%r{/\*.*?\*/}m, '')
    rules = body.split('}').map { |rule| [rule.split('{').first.to_s.strip, rule.split('{', 2)[1]] }
    rules.flat_map do |selector, declarations|
      declarations.to_s.scan(/^\s*([a-z-]+)\s*:\s*(.+?);\s*$/).map do |property, value|
        Decl.new(selector: selector, property: property, value: value.strip)
      end
    end
  end

  # The properties the compiler really emits, with their selectors, so a
  # matching declaration can also be checked against a documented selector
  # that means to name one.
  def emitted(css)
    css.gsub(%r{/\*.*?\*/}m, '').split('}').flat_map do |rule|
      selector = rule.split('{').first.to_s.strip
      rule.split('{', 2)[1].to_s.scan(/^\s*([a-z-]+)\s*:\s*(.+?);\s*$/).map do |property, value|
        Decl.new(selector: selector, property: property, value: value.strip)
      end
    end
  end

  # Whether the compiler really says this. The selector is honoured when the
  # documentation names one, and tolerated when it does not — most entries
  # document a word's declarations without repeating a selector the reader
  # already knows. The *value* must match exactly: `grid-column: 1` is not
  # satisfied by a compiler that emits `grid-column: 1 / -1` elsewhere, which
  # is exactly the class of defect this checker exists to catch.
  def emitted?(emitted, decl)
    by_value = emitted.select { |e| e.property == decl.property && e.value == decl.value }
    return by_value.any? if decl.selector.empty?

    by_value.any? { |e| selectors(e.selector).include?(selectors(decl.selector).first) }
  end

  # A selector is a list, and the two sides write the same list with different
  # line breaks — the documentation indents a wrapped selector inside
  # `@container`, the compiler does not. Comparing the raw strings fails on
  # formatting rather than on meaning, so selectors are compared as the set of
  # things they select.
  def selectors(text)
    text.to_s.split(',').map(&:strip).reject(&:empty?)
  end

  # What to tell the reader when it does not: the values the compiler uses
  # instead are the `align-items: start` case, and the most useful thing to
  # say is both.
  def refusal(emitted, decl)
    others = emitted.select { |e| e.property == decl.property }.map(&:value).uniq
    return 'the compiler emits no such property' if others.empty?

    "the compiler emits `#{decl.property}: #{others.join('`, `')}`"
  end
end

# --- the check ----------------------------------------------------------------
# The lexicon's own instrument, callable as a script and requirable by the
# suite. `docs/SPIFF.md` is not in `check_grammar`'s corpus — it is
# prose about CSS, not `.sp` sentences — so nothing else in the repo looks at
# it, and a checker nothing tests is the same shape of liability this file
# exists to remove. `test/check_spiff_test.rb` holds the runner.
module SpiffCheck
  module_function

  # The lexicon's examples are teaching fragments — `air tight`, a bare `zone
  # cadence compact` — deliberately smaller than a program, because the entry
  # is about one word and the page around it would be noise. So each entry is
  # paired here with the complete, compilable source that shows the word doing
  # its job, and `Source#shows?` holds the pairing: the fragment must actually
  # be part of the source it is said to document, or the pairing is a fiction
  # and the declarations below are checked against the wrong program.
  Source = Struct.new(:design, :fragment, keyword_init: true) do
    def shows?
      said = fragment.to_s.split("\n").map(&:strip).reject(&:empty?)
      return false if said.empty?

      said.all? { |line| design.to_s.include?(line) }
    end
  end

  EXAMPLES = {
    'surface' => Source.new(design: "surface doc_reader\n  stage\n    flank catalog, beside: reading_pane\n",
                            fragment: "surface doc_reader\n  stage\n    flank catalog, beside: reading_pane"),
    'stage' => Source.new(design: "surface doc_reader\n  stage\n    air generous\n" \
                                  "    flank catalog, beside: reading_pane, balance: subordinate\n",
                          fragment: "stage\n    air generous\n    flank catalog, beside: reading_pane, balance: subordinate"),
    'horizon' => Source.new(design: "surface workbench, kind: shell\n  horizon library, editor, output\n" \
                                    "    posture shelf, workspace, mirror\n    collapse roomy\n",
                            fragment: "horizon library, editor, output\n    posture shelf, workspace, mirror\n    collapse roomy"),
    'posture' => Source.new(design: "surface workbench, kind: shell\n  horizon library, editor, output\n" \
                                    "    posture shelf, workspace, mirror\n",
                            fragment: "horizon library, editor, output\n    posture shelf, workspace, mirror"),
    'collapse' => Source.new(design: "surface workbench, kind: shell\n  horizon library, editor, output\n" \
                                     "    posture shelf, workspace, mirror\n    collapse roomy\n",
                             fragment: "collapse roomy"),
    'flank' => Source.new(design: "surface doc_reader\n  stage\n" \
                                  "    flank catalog, beside: reading_pane, balance: subordinate, collapse: cozy\n",
                          fragment: "flank catalog, beside: reading_pane, balance: subordinate, collapse: cozy"),
    'stack' => Source.new(design: "surface doc_reader\n  stage\n    stack overview, details, air: generous\n",
                          fragment: "stack overview, details, air: generous"),
    'zone' => Source.new(design: "surface doc_reader\n  stage\n  zone catalog\n    frame quiet\n    cadence compact\n",
                         fragment: "zone catalog\n    frame quiet\n    cadence compact"),
    'air' => Source.new(design: "surface doc_reader\n  stage\n    air generous\n", fragment: 'air generous'),
    'balance' => Source.new(design: "surface doc_reader\n  stage\n" \
                                    "    flank catalog, beside: reading_pane, balance: subordinate\n",
                            fragment: "flank catalog, beside: reading_pane, balance: subordinate"),
    'frame' => Source.new(design: "surface doc_reader\n  stage\n  zone catalog\n    frame quiet\n", fragment: 'frame quiet'),
    'cadence' => Source.new(design: "surface doc_reader\n  stage\n  zone catalog\n    cadence compact\n",
                            fragment: 'cadence compact'),
    'treatment' => Source.new(design: "surface doc_reader\n  stage\n  zone reading_pane\n    treatment editorial\n",
                              fragment: 'treatment editorial'),
    'scroll' => Source.new(design: "surface workbench, kind: shell\n  zone library\n    scroll internal\n",
                           fragment: 'scroll internal'),
    'presence' => Source.new(design: "surface workbench, kind: shell\n  zone output\n    presence steady\n",
                             fragment: 'presence steady'),
    'focus' => Source.new(design: "surface workbench, kind: shell\n  zone editor\n    focus primary\n",
                          fragment: 'focus primary')
  }.freeze

  # Machinery, not vocabulary: the builders' own constructors and the
  # line-tracking helper are called by the compiler, never written by an
  # author.
  MACHINERY = %w[initialize with_line].freeze

  # Returns the problem count and prints the report to `out`. Both directions,
  # like the other checkers: the lexicon must document every word the compiler
  # implements — a word it does not is a gap a reader cannot see — and every
  # documented word's example must compile, with every declaration in its
  # compiled-CSS block one the compiler really emits for that example.
  def run(files: [LEXICON], compiler: SlimPickins::Compiler::Spiff, out: $stdout)
    problems = 0
    report = ->(line) { out.puts "  #{line}" }

    entries = files.flat_map { |file| Lexicon.entries(File.read(file)) }
    if entries.empty?
      report.call('LEXICON     no entries parsed — the document or its shape changed')
      problems += 1
    end

    # --- direction 1: the lexicon must document every word the compiler makes
    #
    # Read from the compiler's source, because a word with a token table but
    # no reader is not a word anyone can say. `air`, `flank`, `stack` and
    # `horizon` are readable at surface scope as well as stage scope; that is
    # one word with two doors, not eight words.
    source = File.read(File.join(__dir__, 'lib', 'slim_pickins', 'compiler', 'spiff.rb'))
    documented = entries.map(&:word).to_set
    implemented = source.scan(/^        def ([a-z_]+)\(/).flatten.to_set - MACHINERY
    (implemented - documented).sort.each do |word|
      report.call("UNDOCUMENTED  `#{word}` is implemented and has no lexicon entry")
      problems += 1
    end

    # --- direction 2: every example compiles, and its documented CSS is real
    declarations = 0
    entries.each do |entry|
      pairing = EXAMPLES[entry.word]
      if pairing.nil?
        report.call("UNPAIRED    `#{entry.word}` has a lexicon entry and no source to check it against")
        problems += 1
        next
      end

      unless pairing.shows?
        report.call("NOT PAIRED  `#{entry.word}`'s source does not contain its own example fragment — " \
                    'the declarations would be checked against the wrong program')
        problems += 1
        next
      end

      begin
        css = compiler.compile(pairing.design, path: "docs/SPIFF.md (#{entry.word})")
      rescue StandardError => e
        report.call("WILL NOT COMPILE  `#{entry.word}`'s example: #{e.message}")
        problems += 1
        next
      end

      if css.strip.empty?
        report.call("EMPTY       `#{entry.word}`'s example compiles to nothing")
        problems += 1
        next
      end

      emitted = Lexicon.emitted(css)
      entry.css_blocks.each do |block|
        Lexicon.declarations(block).each do |decl|
          declarations += 1
          next if Lexicon.emitted?(emitted, decl)

          report.call("NOT EMITTED  `#{entry.word}` documents `#{decl.property}: #{decl.value}`; " \
                      "#{Lexicon.refusal(emitted, decl)}")
          problems += 1
        end
      end
    end

    out.puts
    out.puts "#{entries.size} lexicon entries, #{declarations} documented declarations, #{problems} problems"
    problems
  end
end

exit(SpiffCheck.run(files: ARGV.empty? ? [LEXICON] : ARGV).zero? ? 0 : 1) if $PROGRAM_NAME == __FILE__
