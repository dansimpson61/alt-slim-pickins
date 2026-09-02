# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The compile-once cache — the memory behind the gate. A source compiles
# once: the parse, the contract walk and the emit happen on the first
# render and never again, so a partial inside `each` pays once, not once
# per row. The cached verdict carries no path, so every render composes its
# own — the same source may be a partial and a page.
class CompilationTest < Minitest::Test
  def teardown
    SlimPickins::Compilation.clear!
  end

  def test_a_source_compiles_once_whatever_path_asks
    source = "page p\n  text \"x\"\n"
    first = SlimPickins::Compilation.of(source, 'a.sp')
    second = SlimPickins::Compilation.of(source, 'b.sp')
    assert_same first, second
  end

  def test_a_violation_is_cached_and_refused_under_each_renders_own_path
    source = "page p\n  money name\n"
    first = assert_raises(SlimPickins::SyntaxError) do
      SlimPickins.render(source, path: 'a.sp', locals: { p: { name: 40 } })
    end
    assert_match(/a\.sp, line 2/, first.message)

    second = assert_raises(SlimPickins::SyntaxError) do
      SlimPickins.render(source, path: 'b.sp', locals: { p: { name: 40 } })
    end
    assert_match(/\A`money` takes no name — name\n  b\.sp, line 2\n    money name\z/, second.message)
  end

  def test_a_sentence_that_will_not_parse_is_not_cached_and_names_each_path
    source = "page p\n  field name, %bogus%\n"
    first = assert_raises(SlimPickins::SyntaxError) do
      SlimPickins.render(source, path: 'a.sp', locals: { p: {} })
    end
    assert_match(/a\.sp, line 2/, first.message)

    second = assert_raises(SlimPickins::SyntaxError) do
      SlimPickins.render(source, path: 'b.sp', locals: { p: {} })
    end
    assert_match(/b\.sp, line 2/, second.message)
  end

  def test_clear_empties_the_cache
    source = "page p\n  text \"x\"\n"
    first = SlimPickins::Compilation.of(source, 'a.sp')
    SlimPickins::Compilation.clear!
    refute_same first, SlimPickins::Compilation.of(source, 'a.sp')
  end

  # The payoff, observed: a page that renders the same partial many times
  # compiles that partial once for the whole run — clearing between renders
  # would compile it per row, so two clears apart, the same render stays
  # byte-identical either way.
  def test_a_partial_renders_identically_whether_cached_or_recompiled
    partial = SlimPickins::Library.new(layout: nil, partials: { account_card: "title .name\nmoney .balance\n" })
    source = "page p\n  each account\n    account_card\n"
    locals = { p: { accounts: [{ name: 'A', balance: 10 }, { name: 'B', balance: 20 }] } }

    warm = SlimPickins.render(source, path: 'x.sp', locals: locals, library: partial)
    SlimPickins::Compilation.clear!
    cold = SlimPickins.render(source, path: 'x.sp', locals: locals, library: partial)
    assert_equal warm, cold
  end
end
