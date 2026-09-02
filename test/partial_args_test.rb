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
    assert_includes html, '<h2 class="title">hello</h2>'
  end

  def test_a_partial_reads_its_modifiers
    action = "form method: post, to: .to\n  hidden path, .path\n  button .content\n"
    html = render(%(page account\n  go_form "Commit", to: "/actions/commit", path: .name\n),
                  partials: { go_form: action },
                  account: Account.new(name: 'ode-to-joy', balance: 1))
    assert_includes html, '<form action="/actions/commit" method="post">'
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
end
