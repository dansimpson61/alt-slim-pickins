# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'tempfile'
require_relative '../check_spiff'

# The design-docs checker is an instrument, and `check_styles`, `check_promises`
# and `bin/check_conventions` are all held by tests for the same reason: an
# instrument that nothing runs is not an instrument, and an instrument that
# cannot fail is a rubber stamp. The 2026-09-26 truth round found four of the
# lexicon's compiled-CSS blocks had drifted from the compiler with every gate
# green; these tests are what make the new checker worth believing.
class CheckDesignDocsTest < Minitest::Test
  LEXICON = File.join(__dir__, '..', 'docs', 'SPIFF.md')

  def run_check(files)
    out = StringIO.new
    problems = SpiffCheck.run(files: files, out: out)
    [problems, out.string]
  end

  def with_mutated_lexicon(from:, to:)
    source = File.read(LEXICON)
    assert_includes source, from, "the lexicon no longer contains #{from.inspect} — this test needs a new anchor"

    Tempfile.create(['mutated-lexicon', '.md']) do |file|
      file.write(source.sub(from, to))
      file.flush
      yield file.path
    end
  end

  def test_the_real_lexicon_is_held_with_no_problems
    problems, output = run_check([LEXICON])

    assert_equal 0, problems, output
    assert_match(/\d+ lexicon entries/, output)
    refute_match(/0 lexicon entries/, output, 'the checker parsed nothing and called it green')
  end

  def test_a_value_the_compiler_no_longer_emits_is_refused
    # The exact defect the truth round found: `align-items: start` survived in
    # two entries after the compiler moved to `stretch`.
    with_mutated_lexicon(from: '  align-items: stretch;', to: '  align-items: start;') do |path|
      problems, output = run_check([path])

      refute_equal 0, problems, 'the checker passed a declaration the compiler does not emit'
      assert_includes output, 'align-items: start'
      assert_includes output, 'the compiler emits `align-items: stretch`'
    end
  end

  def test_a_property_the_compiler_never_emits_is_refused
    with_mutated_lexicon(from: '  box-sizing: border-box;',
                         to: "  box-sizing: border-box;\n  will-change: transform;") do |path|
      problems, output = run_check([path])

      refute_equal 0, problems
      assert_includes output, 'will-change: transform'
      assert_includes output, 'the compiler emits no such property'
    end
  end

  def test_a_word_implemented_but_not_documented_is_refused
    # Direction two of the checker. `collapse` was exactly this: implemented,
    # used by workbench.spiff, and absent from the lexicon until the checker
    # said so.
    with_mutated_lexicon(from: "### `collapse`\n", to: "### `collapse_hidden`\n") do |path|
      problems, output = run_check([path])

      refute_equal 0, problems
      assert_includes output, 'UNDOCUMENTED'
      assert_includes output, '`collapse`'
    end
  end

  def test_a_document_with_no_lexicon_at_all_is_refused_rather_than_passed
    Tempfile.create(['empty', '.md']) do |file|
      file.write("# Not a lexicon\n\nNothing here.\n")
      file.flush

      problems, output = run_check([file.path])

      refute_equal 0, problems, 'an empty parse must not read as green'
      assert_includes output, 'no entries parsed'
    end
  end
end
