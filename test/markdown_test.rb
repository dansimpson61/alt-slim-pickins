# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins/markdown'

# Prose is the one word that renders markup, so its renderer is the
# language's trust boundary: everything is escaped first, and only a fixed
# set of patterns becomes tags. These tests pin the three forms Phase 5
# grew — fences, tables, ordered lists — and the rule that everything else
# is still text.
class MarkdownTest < Minitest::Test
  def render(source) = SlimPickins::Markdown.render(source)

  # --- fences ------------------------------------------------------------

  def test_a_fence_renders_as_pre_code
    assert_equal '<pre><code>puts 1</code></pre>', render("```\nputs 1\n```")
  end

  def test_a_fence_keeps_blank_lines_and_escapes_content
    assert_equal "<pre><code>puts 1 &lt; 2\n\nx = 5</code></pre>",
                 render("```\nputs 1 < 2\n\nx = 5\n```")
  end

  def test_a_fence_tag_is_read_and_dropped
    assert_equal '<pre><code>puts 1</code></pre>', render("```ruby\nputs 1\n```")
  end

  def test_an_unterminated_fence_runs_to_the_end
    assert_equal '<pre><code>open</code></pre>', render("```\nopen")
  end

  def test_a_fence_does_not_wait_for_a_blank_line
    assert_equal '<p>text</p><pre><code>x</code></pre><p>after</p>',
                 render("text\n```\nx\n```\nafter")
  end

  # --- tables ------------------------------------------------------------

  def test_a_pipe_table_renders_head_and_body
    source = "| a | b |\n|---|---|\n| 1 | 2 |\n| 3 | 4 |"
    assert_equal '<table><thead><tr><th>a</th><th>b</th></tr></thead>' \
                 '<tbody><tr><td>1</td><td>2</td></tr><tr><td>3</td><td>4</td></tr></tbody></table>',
                 render(source)
  end

  def test_an_empty_corner_cell_survives
    assert_includes render("| | labels |\n|---|---|\n| x | y |"),
                    '<th></th><th>labels</th>'
  end

  def test_a_pipe_inside_a_code_span_does_not_split_the_cell
    assert_includes render("| a |\n|---|\n| `x|y` |"), '<td><code>x|y</code></td>'
  end

  def test_inline_markup_and_escaping_hold_inside_cells
    assert_includes render("| a |\n|---|\n| <b>**bold** |"),
                    '<td>&lt;b&gt;<strong>bold</strong></td>'
  end

  def test_a_short_row_is_padded_to_the_headers_width
    assert_includes render("| a | b |\n|---|---|\n| one |"),
                    '<tr><td>one</td><td></td></tr>'
  end

  def test_a_dash_line_alone_is_an_hr
    assert_equal '<hr>', render('---')
  end

  # --- ordered lists -----------------------------------------------------

  def test_an_ordered_list_renders_items
    assert_equal '<ol><li>one</li><li>two</li></ol>', render("1. one\n2. two")
  end

  def test_a_list_that_does_not_start_at_one_says_so
    assert_equal '<ol start="4"><li>four</li><li>five</li></ol>', render("4. four\n5. five")
  end

  # --- list items that wrap ----------------------------------------------

  def test_an_indented_line_continues_the_item
    assert_equal '<ul><li>a b</li></ul>', render("- a\n  b")
  end

  def test_ordered_items_fold_their_continuations
    assert_equal '<ol><li>one continued</li><li>two</li></ol>', render("1. one\n   continued\n2. two")
  end

  def test_an_indented_dash_opens_one_level_of_nesting
    assert_equal '<ul><li>a<ul><li>b</li></ul></li></ul>', render("- a\n  - b")
  end

  def test_a_nested_item_folds_its_own_continuations
    assert_equal '<ul><li>a<ul><li>b c</li></ul></li></ul>', render("- a\n  - b\n    c")
  end

  def test_inline_markup_survives_folding
    assert_equal '<ul><li>a <strong>bold</strong></li></ul>', render("- a\n  **bold**")
  end

  # --- what was there still is -------------------------------------------

  def test_headings_lists_quotes_and_paragraphs_are_unchanged
    assert_equal '<h3>Head</h3>', render('## Head')
    assert_equal '<ul><li>a</li></ul>', render('- a')
    assert_equal '<blockquote>quoted</blockquote>', render('> quoted')
    assert_equal '<p>plain</p>', render('plain')
  end

  def test_blank_lines_between_blocks_emit_nothing
    assert_equal '<p>a</p><p>b</p>', render("a\n\n\nb")
  end

  def test_everything_is_escaped_first
    refute_includes render('<script>alert(1)</script>'), '<script>'
  end

  def test_plain_stays_paragraphs_only
    assert_equal '<p>a</p><p>b</p>', SlimPickins::Markdown.plain("a\n\nb")
  end
end
