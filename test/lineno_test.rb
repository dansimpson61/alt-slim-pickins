# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The lineno seam — Phase 3's payload begins here. A runtime error names the
# line the way a syntax error names it: the path, the sentence's line, and
# the sentence itself. Without this, "the roth test" — a renamed attribute
# failing at boot, naming the line and the attribute — cannot exist.
class LinenoTest < Minitest::Test
  Account = Struct.new(:name, keyword_init: true)

  def render(source, library: nil, **locals)
    SlimPickins.render(source, path: 'form.sp', locals: locals, library: library)
  end

  def test_a_missing_attribute_names_the_sentence_that_reads_it
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render("page account\n  section profile\n    title .nmae\n",
             account: { profile: Account.new(name: 'Roth') })
    end
    assert_match(/\Athis profile has no nmae\n  form\.sp, line 3\n    title \.nmae\z/, error.message)
  end

  def test_an_error_inside_a_loop_names_the_inner_sentence
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render("page accounts\n  each account\n    title .nmae\n",
             accounts: [Account.new(name: 'A'), Account.new(name: 'B')])
    end
    assert_match(/\Athis account has no nmae\n  form\.sp, line 3\n    title \.nmae\z/, error.message)
  end

  def test_a_guard_names_the_line_of_the_misplaced_word
    error = assert_raises(SlimPickins::Error) do
      render("page account\n  when .name\n    note \"x\"\n", account: Account.new(name: 'Roth'))
    end
    assert_match(/\Awhen belongs inside a choose\n  form\.sp, line 2\n    when \.name\z/, error.message)
  end

  def test_an_error_in_the_chosen_branch_names_the_branch_not_the_choose
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render("page account\n  choose\n    when .name\n      title .nmae\n    otherwise\n      text \"x\"\n",
             account: Account.new(name: 'Roth'))
    end
    assert_match(/\Athis account has no nmae\n  form\.sp, line 4\n    title \.nmae\z/, error.message)
  end

  def test_an_error_in_a_partial_names_the_partial_not_the_page
    library = SlimPickins::Library.new(layout: nil,
                                       partials: { account_card: "title .name\nmoney .nmae\n" })
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render("page account\n  account_card\n", library: library, account: Account.new(name: 'Roth'))
    end
    assert_match(/\Athis account has no nmae\n  partials\/account_card\.sp, line 2\n    money \.nmae\z/,
                 error.message)
  end

  def test_an_error_in_the_layout_names_the_layout_not_the_page
    layout = "nav\n  link home\n  title .nmae\ncontents\n"
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render("page account\n  text \"x\"\n", library: SlimPickins::Library.new(layout: layout),
             account: Account.new(name: 'Roth'))
    end
    assert_match(/\Athis account has no nmae\n  layout\.sp, line 3\n    title \.nmae\z/, error.message)
  end
end
