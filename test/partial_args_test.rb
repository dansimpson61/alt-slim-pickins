# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# A partial's arguments are its scope (Round A): the content and modifiers
# it was said with become its own subject, so vocabulary written as
# partials can take parameters — `.content`, `.to`, and friends — without a
# line of Ruby. A bare partial still reads the subject it was invoked
# against, which is what keeps `account_card` untouched.
class PartialArgsTest < Minitest::Test
  Account = Struct.new(:name, :balance, keyword_init: true)

  def render(source, partials:, **locals)
    SlimPickins.render(source, path: '(test)', locals: locals,
                       library: SlimPickins::Library.new(layout: nil, partials: partials))
  end

  def test_a_partial_reads_its_content
    html = render("page account\n  shout \"hello\"\n",
                  partials: { shout: "title .content\n" },
                  account: Account.new(name: 'x', balance: 1))
    assert_includes html, '<h2 class="title shout">hello</h2>'
  end

  def test_a_partial_reads_its_modifiers
    action = "form method: post, to: .to\n  hidden path, .path\n  button .content\n"
    html = render(%(page account\n  go_form "Commit", to: "/actions/commit", path: .name\n),
                  partials: { go_form: action },
                  account: Account.new(name: 'ode-to-joy', balance: 1))
    assert_includes html, '<form class="form go_form" action="/actions/commit" method="post">'
    assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
    assert_includes html, '<button type="submit" class="button">Commit</button>'
  end

  def test_a_bare_partial_still_reads_the_subject_it_was_invoked_against
    card = "title .name\nmoney .balance\n"
    html = render("page account\n  account_card\n",
                  partials: { account_card: card },
                  account: Account.new(name: 'Roth', balance: 1500))
    assert_includes html, '<h2 class="title">Roth</h2>'
    assert_includes html, '$1,500'
  end

  def test_missing_parameters_name_the_partial
    action = "form method: post, to: .to\n  button .content\n"
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render(%(page account\n  go_form "Go"\n), partials: { go_form: action }, account: {})
    end
    assert_match(/\Athis go_form has no to\n/, error.message)
  end

  # The optionality spelling (dan, 2026-09-02): slots a preamble declares
  # materialise as keys of the parameters subject, nil when the call did not
  # say them — `when .open` is "was the modifier said", in the language's
  # own conditional.
  def test_a_declared_modifier_reads_nil_when_unsaid
    badge = <<~PART
      # content: true
      # modifiers: tone

      paragraph .tone, .content
    PART
    html = render("page account\n  chip \"hello\"\n", partials: { chip: badge },
                   account: Account.new(name: 'x', balance: 1))
    assert_includes html, '<p class="paragraph chip">hello</p>'
  end

  def test_when_a_modifier_is_said_is_the_languages_own_conditional
    toggle = <<~PART
      # content: true
      # modifiers: open

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
    chip = <<~PART
      # name: variant
      # content: true

      choose
        when .name
          paragraph .name, .content
        otherwise
          paragraph "plain", .content
    PART
    named = render(%(page account\n  chip warning, "x"\n), partials: { chip: chip },
                   account: Account.new(name: 'x', balance: 1))
    bare = render(%(page account\n  chip "x"\n), partials: { chip: chip },
                  account: Account.new(name: 'x', balance: 1))
    assert_includes named, '<p class="paragraph paragraph--warning chip">x</p>'
    assert_includes bare, '<p class="paragraph chip">plain</p>'
  end

  # Declared slots are scope; everything else falls through to the subject
  # the partial was invoked against.
  def test_a_declared_partial_still_reads_the_subject_it_was_invoked_against
    card = <<~PART
      # content: true

      title .name
      money .balance
      paragraph .content
    PART
    html = render(%(page account\n  account_card "note"\n), partials: { account_card: card },
                  account: Account.new(name: 'Roth', balance: 1500))
    assert_includes html, '<h2 class="title">Roth</h2>'
    assert_includes html, '$1,500'
    assert_includes html, '<p class="paragraph">note</p>'
  end

  # The runtime consumes the declaration: a preambled partial refuses what
  # its own file says it does not take.
  def test_a_declared_partial_refuses_an_undeclared_modifier
    badge = <<~PART
      # content: true
      # modifiers: tone

      paragraph .content
    PART
    error = assert_raises(SlimPickins::Error) do
      render(%(page account\n  chip "x", wat: true\n), partials: { chip: badge },
             account: Account.new(name: 'x', balance: 1))
    end
    assert_match(/`chip` has no `wat:` modifier/, error.message)
    assert_match(/chip "x", wat: true/, error.message)
  end
end
