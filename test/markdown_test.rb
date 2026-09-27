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

  # --- demand ledger additions (G20-G23) ----------------------------------

  def test_indented_code_fence_is_recognized_and_deindented
    source = "   ```ruby\n   puts 1\n     x = 2\n   ```"
    assert_equal "<pre><code>puts 1\n  x = 2</code></pre>", render(source)
  end

  def test_yaml_frontmatter_is_stripped_from_render
    source = "---\nschema: 1\nstatus: active\n---\n# Title\n\nBody text"
    assert_equal '<h2>Title</h2><p>Body text</p>', render(source)
  end

  def test_yaml_frontmatter_is_stripped_from_plain
    source = "---\nschema: 1\n---\nFirst paragraph\n\nSecond paragraph"
    assert_equal '<p>First paragraph</p><p>Second paragraph</p>', SlimPickins::Markdown.plain(source)
  end

  def test_images_render_as_img_tags
    assert_equal '<p><img src="pic.png" alt="A photo"></p>', render('![A photo](pic.png)')
  end

  def test_linked_images_render_cleanly
    assert_equal '<p><a href="dest.html"><img src="pic.png" alt="A photo"></a></p>',
                 render('[![A photo](pic.png)](dest.html)')
  end

  def test_blockquote_with_empty_quote_line_splits_into_paragraphs
    source = "> First paragraph\n>\n> Second paragraph"
    assert_equal '<blockquote><p>First paragraph</p><p>Second paragraph</p></blockquote>', render(source)
  end

  def test_blockquote_with_adjacent_labeled_lines_preserves_linebreaks
    source = "> **Purpose:** View DSL\n> **Next Horizon:** Phase 2"
    assert_equal '<blockquote><strong>Purpose:</strong> View DSL<br><strong>Next Horizon:</strong> Phase 2</blockquote>',
                 render(source)
  end

  def test_blockquote_wrapped_prose_collapses_to_single_line
    source = "> This is wrapped prose that\n> continues across lines."
    assert_equal '<blockquote>This is wrapped prose that continues across lines.</blockquote>', render(source)
  end
end

# The guides the studio serves, held to the rule that their prose renders.
#
# The 2026-09-26 round found four classes of defect here, none of them
# visible to any checker because nothing rendered the documents and read the
# result: a code span that wrapped inside a list item (the item renderer ran
# `spans` twice, splitting the pair), a four-backtick delimiter, a span whose
# content held three backticks, and three element names that had simply lost
# their backticks. Every one of them showed the reader raw punctuation.
#
# Reading the source cannot catch these, because the source is ambiguous by
# construction — what is broken is the pairing. So this tests the *output*:
# no backtick may survive rendering, and no HTML element name may render as
# literal text.
class GuideRenderingTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  # Every document the studio serves as a guide, plus the design idiom's
  # companion, since all of them are read through `prose`.
  GUIDES = %w[README PRIMER VOCABULARY CONTRACT DESIGN KERNEL LORE
              ROADMAP-0.2 ROADMAP-0.3 HANDOFF DAYTRIP BLUESKY].freeze

  def documents
    (GUIDES.map { |n| File.join(ROOT, "#{n}.md") } +
      [File.join(ROOT, 'docs', 'SPIFF.md'),
       File.join(ROOT, 'spiff_discussion.md')])
      .select { |path| File.file?(path) }
  end

  def rendered(path)
    SlimPickins::Markdown.render(File.read(path))
  end

  # The invariant, stated exactly: a backtick may appear *inside* a code
  # element — that is what a span containing backticks looks like when it
  # renders correctly — but a backtick in the prose around the code means a
  # span never closed, and the reader is looking at punctuation instead of
  # content. The first version of this test counted every backtick and so read
  # a correct document as broken once the engine could quote backticks.
  def test_no_guide_leaves_a_backtick_in_its_prose
    offenders = documents.filter_map do |path|
      prose = rendered(path).gsub(%r{<pre>.*?</pre>|<code>.*?</code>}m, '')
      count = prose.scan('`').size
      "#{File.basename(path)}: #{count}" if count.positive?
    end
    assert_empty offenders, 'a backtick reached the reader as prose, so a code span never closed'
  end

  def test_no_guide_renders_an_html_element_as_literal_text
    offenders = documents.filter_map do |path|
      # Remove what the engine really emitted as code, then look for a tag
      # that is still escaped in the prose around it.
      prose = rendered(path).gsub(%r{<pre>.*?</pre>|<code>.*?</code>}m, '')
      found = prose.scan(/&lt;\/?(?:details|summary|div|p|ul|ol|li|section|article|aside|nav|footer|head|table|form|figure|fieldset)\b/i)
      "#{File.basename(path)}: #{found.uniq.join(', ')}" if found.any?
    end
    assert_empty offenders, 'an HTML element name rendered as literal text instead of code'
  end

  # The engine bug behind six of the defects above, pinned directly.
  def test_a_code_span_may_wrap_a_line_inside_a_list_item
    assert_equal "<ul><li>a <code>one two</code> b</li></ul>",
                 SlimPickins::Markdown.render("- a `one\ntwo` b")
  end

  def test_a_code_span_may_wrap_a_line_inside_a_paragraph
    assert_equal '<p>a <code>one two</code> b</p>',
                 SlimPickins::Markdown.render("a `one\ntwo` b")
  end

  # --- code spans that contain backticks ---------------------------------
  #
  # CommonMark's rule: a span opens on a run of backticks and closes on the
  # next run of *the same length*, so a shorter run inside it is content.
  # The pattern this replaced could only ever delimit with one backtick,
  # which made a whole class of sentence unwritable — anything that had to
  # quote a fence, starting with this repository's own fence pattern.

  def test_a_code_span_may_contain_a_run_of_backticks
    # The spaces are content: CommonMark strips one leading and trailing space
    # only when both are present, and nothing here does that yet.
    assert_equal '<p>the fence <code> ```ruby </code> opens</p>',
                 SlimPickins::Markdown.render('the fence ```` ```ruby ```` opens')
  end

  def test_a_span_delimited_by_four_backticks_may_quote_the_fence_pattern
    source = 'pattern: ````FENCE = %r{\A```[^\n`]*\z}```` here'
    assert_equal '<p>pattern: <code>FENCE = %r{\A```[^\n`]*\z}</code> here</p>',
                 SlimPickins::Markdown.render(source)
  end

  def test_a_lone_run_with_no_partner_is_left_as_written
    assert_equal '<p>a `lonely backtick</p>', SlimPickins::Markdown.render('a `lonely backtick')
  end

  def test_separate_spans_do_not_merge_across_a_line
    # The old pattern paired the first backtick with the last, so `.` / `#`
    # became one span whose content was `./`.
    assert_equal '<p><code>.</code>/<code>#</code></p>',
                 SlimPickins::Markdown.render('`.`/`#`')
  end

  # --- code is not markup -------------------------------------------------

  def test_emphasis_inside_a_code_span_is_left_alone
    assert_equal '<p><code>**not bold**</code> and <strong>bold</strong></p>',
                 SlimPickins::Markdown.render('`**not bold**` and **bold**')
  end

  def test_a_link_may_use_a_code_span_as_its_text
    assert_equal '<p><a href="word.md"><code>word.md</code></a></p>',
                 SlimPickins::Markdown.render('[`word.md`](word.md)')
  end

  def test_emphasis_may_wrap_a_code_span
    assert_equal '<p><strong>card (<code>card</code>)</strong> is bold</p>',
                 SlimPickins::Markdown.render('**card (`card`)** is bold')
  end
end
