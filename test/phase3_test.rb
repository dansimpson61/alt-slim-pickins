# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# Phase 3: reuse. A layout is the chrome every page shares; a partial is a
# word an app defines. Neither adds syntax.
class Phase3Test < Minitest::Test
  Account = Struct.new(:name, :balance, keyword_init: true)

  LAYOUT = <<~SP
    stylesheet "/css/base.css"
    nav
      link home, "Studio"
    contents
    footer "Made here."
  SP

  def library(layout: LAYOUT, partials: {})
    SlimPickins::Library.new(layout: layout, partials: partials)
  end

  def render(source, library: nil, **locals)
    SlimPickins.render(source, path: '(test)', locals: locals, library: library)
  end

  # --- layout -----------------------------------------------------------

  def test_a_layout_wraps_the_page_and_contents_marks_the_hole
    html = render("page account\n  title .name\n",
                  library: library, account: Account.new(name: 'Roth', balance: 1))
    assert_includes html, '<nav class="nav" aria-label="Main">'
    assert_includes html, '<h2 class="title">Roth</h2>'
    assert_includes html, '<footer class="footer">Made here.</footer>'
    assert_operator html.index('<nav'), :<, html.index('>Roth<')
    assert_operator html.index('>Roth<'), :<, html.index('<footer')
  end

  # The layout renders inside the body, but a stylesheet belongs in the head.
  # Words say where they belong, not where they are written.
  def test_a_stylesheet_named_in_the_layout_still_lands_in_the_head
    html = render("page account\n  title .name\n",
                  library: library, account: Account.new(name: 'Roth', balance: 1))
    head = html[%r{<head>.*?</head>}m]
    assert_includes head, '<link rel="stylesheet" href="/css/base.css">'
  end

  def test_the_page_says_nothing_about_the_layout
    page = "page account\n  title .name\n"
    refute_includes page, 'layout'
    assert_includes render(page, library: library, account: Account.new(name: 'x', balance: 1)),
                    '<footer class="footer">Made here.</footer>'
  end

  def test_a_layout_that_never_says_contents_is_an_error
    error = assert_raises(SlimPickins::Error) do
      render("page account\n  title .name\n",
             library: library(layout: %(footer "Only chrome.")),
             account: Account.new(name: 'x', balance: 1))
    end
    assert_equal 'this layout never says `contents`', error.message
  end

  def test_contents_outside_a_layout_is_an_error
    error = assert_raises(SlimPickins::Error) { render("page account\n  contents\n", account: {}) }
    assert_equal '`contents` belongs in a layout', error.message
  end

  # --- partials as app-defined words ------------------------------------

  CARD = "title .name\nmoney .balance\n"

  def test_an_app_word_is_invoked_exactly_like_a_built_in
    html = render("page account\n  account_card\n",
                  library: library(layout: nil, partials: { account_card: CARD }),
                  account: Account.new(name: 'Roth', balance: 1500))
    assert_includes html, '<h2 class="title">Roth</h2>'
    assert_includes html, '$1,500'
  end

  def test_an_app_word_takes_the_current_subject
    accounts = [Account.new(name: 'A', balance: 1), Account.new(name: 'B', balance: 2)]
    html = render("page portfolio\n  each account\n    account_card\n",
                  library: library(layout: nil, partials: { account_card: CARD }),
                  portfolio: { accounts: accounts })
    assert_includes html, '<h2 class="title">A</h2>'
    assert_includes html, '<h2 class="title">B</h2>'
  end

  # Same rule as `section`: a name shifts the subject, and must be there.
  def test_an_app_word_may_name_a_subject
    html = render("page portfolio\n  account_card best\n",
                  library: library(layout: nil, partials: { account_card: CARD }),
                  portfolio: { best: Account.new(name: 'Roth', balance: 9) })
    assert_includes html, '<h2 class="title">Roth</h2>'
  end

  # The call site must not reveal which vocabulary a word came from.
  def test_a_reader_cannot_tell_an_app_word_from_a_built_in
    builder = SlimPickins::Builder.new(
      SlimPickins::Page.new(locals: {}),
      library(layout: nil, partials: { account_card: CARD })
    )
    assert builder.respond_to?(:account_card)
    assert builder.respond_to?(:section)
  end

  def test_an_unknown_word_still_fails_with_its_own_name
    error = assert_raises(SlimPickins::Error) do
      render(%(page account\n  sparkline "x"\n),
             library: library(layout: nil, partials: { account_card: CARD }), account: {})
    end
    assert_equal 'there is no word `sparkline`', error.message
  end

  # --- shadowing is an error, not an override ---------------------------

  def test_an_app_may_not_redefine_a_slim_pickins_word
    error = assert_raises(SlimPickins::Error) do
      SlimPickins::Library.new(partials: { table: 'title .name' })
    end
    assert_equal '`table` is already a slim-pickins word — an app cannot redefine it', error.message
  end

  # --- loading from disk ------------------------------------------------

  def test_a_library_reads_a_layout_and_partials_from_a_directory
    lib = SlimPickins::Library.from(File.expand_path('../pages', __dir__))
    assert lib.layout
    assert lib.word?(:account_card)
    refute lib.word?(:nonexistent)
  end
end
