# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../test/fixtures'
require_relative '../examples/portfolio/app'

# Daytrip 0.5.0e — Shadowing language words.
# Ruled 2026-10-05: an app partial or Ruby word may shadow a built-in language word,
# resolved nearest-first, isolated to that library, and reported by the gate.
class ShadowingTest < Minitest::Test
  def test_app_partial_shadows_built_in_vocabulary_partial
    lib = SlimPickins::Library.new(partials: {
      card: "paragraph .name\n"
    })

    assert_includes lib.shadowed_words, :card
    html = SlimPickins.render("page p\n  card\n", library: lib, locals: { p: { name: 'Dan' } })
    assert_includes html, 'Dan'
    refute_includes html, '<article class="card"'
  end

  def test_app_partial_shadows_built_in_primitive
    lib = SlimPickins::Library.new(partials: {
      heading: "paragraph .title\n"
    })

    assert_includes lib.shadowed_words, :heading
    html = SlimPickins.render("page p\n  heading\n", library: lib, locals: { p: { title: 'Hello' } })
    assert_includes html, 'Hello'
    refute_includes html, '<h2'
  end

  def test_app_ruby_word_shadows_built_in_word
    custom_words = Module.new do
      def heading(*args)
        text "ruby heading"
      end
    end

    lib = SlimPickins::Library.new(words: custom_words)
    assert_includes lib.shadowed_words, :heading
    html = SlimPickins.render("page p\n  heading\n", library: lib, locals: { p: {} })
    assert_includes html, 'ruby heading'
  end

  def test_shadowing_is_isolated_to_the_owning_library_instance
    app_lib = SlimPickins::Library.new(partials: {
      card: "paragraph \"app card\"\n"
    })

    builtin_lib = SlimPickins::Library.builtin

    app_html = SlimPickins.render("page p\n  card\n", library: app_lib, locals: { p: {} })
    assert_includes app_html, 'app card'

    builtin_html = SlimPickins.render("page p\n  card\n", library: builtin_lib, locals: { p: {} })
    assert_includes builtin_html, '<article class="card"'
  end

  def test_internal_app_collision_between_partial_and_ruby_is_refused
    ruby_word = Module.new { def custom_card; end }
    error = assert_raises(SlimPickins::Error) do
      SlimPickins::Library.new(partials: { custom_card: "paragraph \"hi\"\n" }, words: ruby_word)
    end
    assert_equal '`custom_card` is defined twice — as a partial and in Ruby', error.message
  end

  def test_portfolio_app_library_shadows_card_cleanly
    views_dir = File.expand_path('../examples/portfolio/views', __dir__)
    lib = SlimPickins::Library.from(views_dir, words: AppWords)

    assert_includes lib.shadowed_words, :card
    assert lib.word?(:card)

    account = Fixtures.portfolio.accounts.last
    html = lib.render('account', locals: { account: account })
    assert_includes html, '<title>Account detail</title>'
    assert_includes html, 'Roth IRA'
    assert_includes html, '<video class="video"'
  end
end
