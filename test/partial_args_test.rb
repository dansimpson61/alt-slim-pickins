# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# A partial's arguments are its scope (Round A): the content and modifiers
# it was said with become its own subject, so vocabulary written as
# partials can take parameters — `.content`, `.to`, and friends — without a
# line of Ruby. A bare partial still reads the subject it was invoked
# against, which is what keeps `test_test_account_card` untouched.
class PartialArgsTest < Minitest::Test
  Account = Struct.new(:name, :balance, keyword_init: true)

  def render(source, partials:, **locals)
    SlimPickins.render(source, path: '(test)', locals: locals,
                       library: SlimPickins::Library.new(layout: nil, partials: partials))
  end

  # Compiling a partial registers its word globally (`Compilation.compile_partial`),
  # and every word here is a throwaway. Nothing removed them, so the registry
  # carried `tone:` — a modifier no vocabulary word declares — for the rest of
  # the process, and the promise ledger found it a whole suite later
  # (DAYTRIP-0.3.0b). Snapshot and restore, so the process this suite runs in
  # holds no word that exists in no page.
  def setup
    @registry_before = SlimPickins::Word.registry.keys
  end

  def teardown
    (SlimPickins::Word.registry.keys - @registry_before).each do |word|
      SlimPickins::Word.registry.delete(word)
    end
  end

  def test_a_partial_reads_its_content
    html = render("page account\n  test_test_shout \"hello\"\n",
                  partials: { test_test_shout: "title .content\n" },
                  account: Account.new(name: 'x', balance: 1))
    assert_includes html, '<h2 class="title test_test_shout">hello</h2>'
  end

  def test_a_partial_reads_its_modifiers
    action = "form method: post, to: .to\n  hidden path, .path\n  button .content\n"
    html = render(%(page account\n  test_test_go_form "Commit", to: "/actions/commit", path: .name\n),
                  partials: { test_test_go_form: action },
                  account: Account.new(name: 'ode-to-joy', balance: 1))
    assert_includes html, '<form class="form test_test_go_form" action="/actions/commit" method="post">'
    assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
    assert_includes html, '<button type="submit" class="button">Commit</button>'
  end

  def test_a_bare_partial_still_reads_the_subject_it_was_invoked_against
    card = "title .name\nmoney .balance\n"
    html = render("page account\n  test_test_account_card\n",
                  partials: { test_test_account_card: card },
                  account: Account.new(name: 'Roth', balance: 1500))
    assert_includes html, '<h2 class="title">Roth</h2>'
    assert_includes html, '$1,500'
  end

  def test_missing_parameters_name_the_partial
    action = "form method: post, to: .to\n  button .content\n"
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render(%(page account\n  test_test_go_form "Go"\n), partials: { test_test_go_form: action }, account: {})
    end
    assert_match(/\Athis test_test_go_form has no to\n/, error.message)
  end

  # The optionality spelling (dan, 2026-09-02): slots a preamble declares
  # materialise as keys of the parameters subject, nil when the call did not
  # say them — `when .open` is "was the modifier said", in the language's
  # own conditional.
  def test_a_declared_modifier_reads_nil_when_unsaid
    badge = <<~PART
      expects content: true, tone: true

      paragraph .tone, .content
    PART
    html = render("page account\n  test_chip \"hello\"\n", partials: { test_chip: badge },
                   account: Account.new(name: 'x', balance: 1))
    assert_includes html, '<p class="paragraph test_chip">hello</p>'
  end

  def test_when_a_modifier_is_said_is_the_languages_own_conditional
    toggle = <<~PART
      expects content: true, open: true

      choose
        when .open
          paragraph "open", .content
        otherwise
          paragraph "closed", .content
    PART
    open = render(%(page account\n  toggle "x", open: true\n), partials: { toggle: toggle },
                  account: Account.new(name: 'x', balance: 1))
    closed = render(%(page account\n  toggle "x"\n), partials: { toggle: toggle },
                    account: Account.new(name: 'x', balance: 1))
    assert_includes open, '>open</p>'
    assert_includes closed, '>closed</p>'
  end

  def test_when_a_variant_is_named_is_the_languages_own_conditional
    test_chip = <<~PART
      expects variant, content: true

      choose
        when .name
          paragraph .name, .content
        otherwise
          paragraph "plain", .content
    PART
    named = render(%(page account\n  test_chip warning, "x"\n), partials: { test_chip: test_chip },
                   account: Account.new(name: 'x', balance: 1))
    bare = render(%(page account\n  test_chip "x"\n), partials: { test_chip: test_chip },
                  account: Account.new(name: 'x', balance: 1))
    assert_includes named, '<p class="paragraph paragraph--warning test_chip">x</p>'
    assert_includes bare, '<p class="paragraph test_chip">plain</p>'
  end

  # Declared slots are scope; everything else falls through to the subject
  # the partial was invoked against.
  def test_a_declared_partial_still_reads_the_subject_it_was_invoked_against
    card = <<~PART
      expects content: true

      title .name
      money .balance
      paragraph .content
    PART
    html = render(%(page account\n  test_test_account_card "note"\n), partials: { test_test_account_card: card },
                  account: Account.new(name: 'Roth', balance: 1500))
    assert_includes html, '<h2 class="title">Roth</h2>'
    assert_includes html, '$1,500'
    assert_includes html, '<p class="paragraph">note</p>'
  end

  # The runtime consumes the declaration: a preambled partial refuses what
  # its own file says it does not take.
  def test_a_declared_partial_refuses_an_undeclared_modifier
    badge = <<~PART
      expects content: true, tone: true

      paragraph .content
    PART
    error = assert_raises(SlimPickins::Error) do
      render(%(page account\n  test_chip "x", wat: true\n), partials: { test_chip: badge },
             account: Account.new(name: 'x', balance: 1))
    end
    assert_match(/`test_chip` has no `wat:` modifier/, error.message)
    assert_match(/test_chip "x", wat: true/, error.message)
  end
end
