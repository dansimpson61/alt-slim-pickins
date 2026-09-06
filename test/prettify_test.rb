# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# Layout has one home, and this is it. Every other test in the suite asserts
# what the language *says*; these assert how the document is *laid out*, so
# that no semantic test has to care — and so that the two consumers who asked
# for the layout have something that speaks for them.
#
# Both are people: the studio's HTML tab, which exists to show a human what
# the language emits, and whoever is later debugging that output. That is the
# whole argument for the one rule below, and the reason a formatter that broke
# a line inside an element's text was a defect rather than a preference.
class PrettifyTest < Minitest::Test
  def lay_out(html) = SlimPickins::Generator.prettify(html)

  # --- the rule ---------------------------------------------------------

  # The rule the two consumers bought: an element holding nothing but text
  # keeps its text and its closing tag on the line it started.
  def test_an_element_holding_only_text_is_never_broken
    assert_equal %(<li class="item">One</li>\n), lay_out('<li class="item">One</li>')
  end

  def test_an_element_earns_indentation_by_holding_elements
    assert_equal <<~HTML, lay_out('<ul><li>One</li><li>Two</li></ul>')
      <ul>
        <li>One</li>
        <li>Two</li>
      </ul>
    HTML
  end

  def test_nesting_deepens_by_one_level_each_time
    assert_equal <<~HTML, lay_out('<div><ul><li>One</li></ul></div>')
      <div>
        <ul>
          <li>One</li>
        </ul>
      </div>
    HTML
  end

  # --- what flows, and what breaks --------------------------------------

  # Inline content follows the open tag it belongs to rather than starting a
  # line, which is what keeps a heading beside its section.
  def test_inline_content_stays_with_the_tag_that_opened_it
    assert_equal %(<section class="section"><h2>Title</h2>\n  <div><p>Body</p></div>\n</section>\n),
                 lay_out('<section class="section"><h2>Title</h2><div><p>Body</p></div></section>')
  end

  def test_an_element_of_only_inline_children_stays_on_one_line
    assert_equal %(<div class="prose"><p>A <strong>bold</strong> claim.</p></div>\n),
                 lay_out('<div class="prose"><p>A <strong>bold</strong> claim.</p></div>')
  end

  # A void tag holds nothing, so it opens no level and forces no break.
  def test_a_void_tag_opens_no_level
    assert_equal %(<p>Before<br>After</p>\n), lay_out('<p>Before<br>After</p>')
  end

  # `pre` is unbroken for a reason the others are not: its whitespace is the
  # content. Reformatting inside it would change what the page says.
  def test_pre_is_left_exactly_as_it_was
    source = "<pre class=\"snippet\"><code>def a\n  b\nend</code></pre>"
    assert_equal "#{source}\n", lay_out(source)
  end

  # --- the document -----------------------------------------------------

  def test_the_doctype_takes_its_own_line
    assert_equal "<!DOCTYPE html>\n<html>\n  <body><h1>Hi</h1></body>\n</html>\n",
                 lay_out('<!DOCTYPE html><html><body><h1>Hi</h1></body></html>')
  end

  # Laying out a laid-out document changes nothing. Without this the studio's
  # HTML tab would drift every time it re-rendered.
  def test_laying_out_twice_is_laying_out_once
    html = SlimPickins.render(<<~PAGE, locals: { thing: { origin: 'dashboard' } })
      page thing
        heading "Hi"
        list
          item "One"
          item "Two"
        fact .origin
    PAGE
    assert_equal html, lay_out(html)
  end

  # --- nothing is lost --------------------------------------------------

  # Layout may move whitespace between tags; it may never lose, reorder, or
  # invent one. This is the guard that a formatter rewrite cannot quietly eat
  # a page.
  def test_every_tag_survives_in_its_original_order
    source = '<div><ul><li>One</li><li><span>Two</span></li></ul><img src="/a.png"><p>End</p></div>'
    assert_equal source.scan(/<[^>]+>/), lay_out(source).scan(/<[^>]+>/)
  end

  def test_the_text_survives_unchanged
    source = '<div><h1>Title</h1><ul><li>One</li><li>Two</li></ul></div>'
    assert_equal 'TitleOneTwo', lay_out(source).gsub(/<[^>]+>/, '').gsub(/\s+/, '')
  end
end
