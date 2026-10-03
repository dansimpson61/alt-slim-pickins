# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../studio/inspector'
require_relative '../studio/pages'

# The Inspect surface, after DAYTRIP-0.4.0k turned it inside out.
#
# It was 436 lines of Ruby writing HTML — a 254-line method of which 200 lines
# were an inline `<style>` block, 23 class literals, five tier palettes and two
# ad-hoc click listeners. It is now a page in the language it inspects, a Spiff
# for its layout, the theme for its colour, and `:target` for its selection.
#
# So these tests ask what the surface must still *do*, plus the three things the
# rewrite is only correct if they hold: the tree's links and the cards' ids agree,
# nothing is styled inline, and there is no JavaScript.
class StudioInspectorTest < Minitest::Test
  SOURCE = <<~SP
    page portfolio
      section holdings
        card
          title .name
          money .market_value
  SP
  LOCALS = { portfolio: { holdings: { name: 'Retirement', market_value: 125_000 } } }.freeze

  def tree = SlimPickins.evaluate(SOURCE, locals: LOCALS)
  def page = StudioInspector.page_for(tree, source: SOURCE)

  # --- what the surface says -------------------------------------------------
  def test_both_panes_render_with_their_zone_names
    html = page

    assert_includes html, 'Semantic Tree'
    assert_includes html, 'Provenance and the Why Pane'
    assert_match(/class="box tree"/, html, '`zone tree` in the Spiff needs this class to be real')
    assert_match(/class="box detail"/, html, '`zone detail` likewise')
  end

  def test_every_node_is_named_and_its_conventions_are_shown
    html = page

    assert_includes html, ':page'
    assert_includes html, ':card_id', 'the card convention is registered in the Why pane'
    assert_includes html, ':document', 'the page convention is registered in the Why pane'
    assert_includes html, ':number_text', 'the money convention is registered in the Why pane'
  end

  def test_the_four_tiers_are_named_and_badged_by_the_theme
    html = page

    assert_includes html, 'Language (Structure)'
    assert_includes html, 'Language (Shape)'
    assert_match(/class="badge badge--structural"/, html, 'the tier is a variant the theme colours')
    assert_match(/class="badge badge--shape"/, html)
  end

  def test_the_override_idiom_is_still_offered
    assert_match(/class="snippet snippet--override"/, page,
                 'a convention a reader cannot override is a trap')
  end

  # --- the three things the rewrite is only correct if they hold -------------

  # The tree's links and the cards' ids are produced by two different mechanisms —
  # `Node#anchor` here, and the `card_id` convention in the page — so they are the
  # one coupling this surface can break silently.
  def test_every_node_links_to_a_card_that_exists
    html = page
    links = html.scan(/href="#([^"]+)"/).flatten
    ids = html.scan(/<article[^>]*id="([^"]+)"/).flatten

    refute_empty links
    assert_equal links.sort, ids.sort,
                 'a tree link with no card, or a card nothing points at, is a dead selection'
  end

  def test_the_surface_carries_no_javascript
    html = page

    refute_includes html, '<script'
    refute_includes html, 'onclick'
    refute_match(/addEventListener/, html)
  end

  def test_the_surface_styles_nothing_inline
    html = page

    refute_includes html, '<style', 'the 200-line heredoc is the thing this rewrite removed'
    assert_includes html, '/assets/slim-pickins.css', 'colour comes from the theme'
    assert_includes html, '/assets/inspect.css', 'layout comes from the Spiff'
  end

  # --- the data layer, which is all the Ruby that was actually needed --------
  def test_the_tree_becomes_nested_nodes_with_stable_ids
    roots = StudioInspector.nodes_of(tree)
    flat = StudioInspector.flatten(roots)

    assert_equal 1, roots.size, 'a page is one root'
    assert_operator flat.size, :>, 1
    assert_equal flat.map(&:id), flat.map(&:id).uniq, 'an id names one node'
    assert_equal ':page', roots.first.named
    assert_equal '#node-n_0', roots.first.anchor
  end

  def test_a_nodes_complex_payloads_are_shown_as_children_not_as_values
    roots = StudioInspector.nodes_of(tree)
    StudioInspector.flatten(roots).each do |node|
      assert_empty node.facts.map(&:attribute) & %w[rows columns foot],
                   'rows and columns are children in every sense the reader cares about'
    end
  end

  # --- the refusal, and the studio that asks for all of it -------------------
  def test_a_refusal_shows_its_message
    html = StudioInspector.error_page_for(SlimPickins::Error.new('this portfolio has no holdings'))

    assert_includes html, 'this portfolio has no holdings'
    refute_includes html, '<style'
  end

  def test_render_json_still_carries_the_inspect_surface
    res = StudioPages.render_json("page \"Overview\"\n  heading \"Hello\"\n")

    assert res.key?(:visual)
    assert res.key?(:source)
    assert res.key?(:inspect)
    assert_includes res[:inspect], 'Semantic Tree'
    assert_includes res[:inspect], 'Provenance and the Why Pane'
  end
end
