# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# `tabs` — the word the studio's own playground is built on, and the one word
# with no test at all until 2026-09-17.
#
# Its radio group's name and each tab's id were derived from `object_id`, so the
# same page rendered different HTML on every render in a process. Rendered output
# was therefore not a pure function of its source, and the byte-diff harness —
# which the project names as *the acceptance test for refactors* — could not be
# used on any page holding tabs. It could not be used on this project's own
# studio index, and it silently contaminated a measurement made the same day.
#
# These tests hold the two properties that matter: the same page renders the same
# HTML, and each group in a page is its own.
class TabsTest < Minitest::Test
  PAGE = <<~SP
    page "P"
      tabs
        tab "A", active: true
          text "a"
        tab "B"
          text "b"
  SP

  def render(source, **locals)
    SlimPickins.render(source, path: 'tabs.sp', locals: locals)
  end

  def test_the_same_page_renders_the_same_html
    assert_equal render(PAGE), render(PAGE),
                 'a page must be a pure function of its source, or nothing can be diffed'
  end

  def test_a_group_names_and_ids_its_tabs
    html = render(PAGE)

    assert_includes html, 'name="tabs-1"'
    assert_includes html, 'id="tab-1-0"'
    assert_includes html, 'for="tab-1-0"'
    assert_includes html, 'id="tab-1-1"'
    assert_includes html, 'for="tab-1-1"'
  end

  def test_the_tab_that_says_it_is_active_is_the_one_checked
    html = render(PAGE)
    inputs = html.scan(/<input[^>]*>/)

    assert_equal 2, inputs.size
    assert_match(/id="tab-1-0"[^>]*checked/, inputs[0])
    refute_match(/checked/, inputs[1])
  end

  def test_the_first_tab_is_checked_when_none_says_it_is
    html = render("page \"P\"\n  tabs\n    tab \"A\"\n      text \"a\"\n    tab \"B\"\n      text \"b\"\n")

    assert_match(/id="tab-1-0"[^>]*checked/, html)
  end

  def test_each_group_in_a_page_is_its_own
    html = render("page \"P\"\n  tabs\n    tab \"A\"\n      text \"a\"\n  tabs\n    tab \"B\"\n      text \"b\"\n")

    assert_includes html, 'name="tabs-1"'
    assert_includes html, 'name="tabs-2"'
    assert_includes html, 'id="tab-2-0"'
  end
end
