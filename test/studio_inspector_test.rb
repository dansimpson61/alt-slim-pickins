# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../studio/inspector'
require_relative '../studio/pages'

class StudioInspectorTest < Minitest::Test
  def test_page_for_renders_semantic_tree_and_why_pane
    source = <<~SP
      page portfolio
        section holdings
          card
            title .name
            money .market_value
    SP
    locals = { portfolio: { holdings: { name: 'Retirement', market_value: 125_000 } } }
    tree = SlimPickins.evaluate(source, locals: locals)

    html = StudioInspector.page_for(tree, source: source)

    assert_includes html, 'Semantic Tree'
    assert_includes html, 'Provenance &amp; The Why Pane'
    assert_includes html, ':page'
    assert_includes html, ':card_id', 'card convention is registered in Why pane'
    assert_includes html, ':document', 'page convention is registered in Why pane'
    assert_includes html, ':number_text', 'money convention is registered in Why pane'
    assert_includes html, 'Language (Structure)', 'tier classification appears'
    assert_includes html, 'Language (Shape)', 'tier classification appears'
    assert_includes html, 'Override Idiom:', 'override instructions are visible'
  end

  def test_render_json_includes_inspect_key
    source = "page \"Overview\"\n  heading \"Hello\"\n"
    res = StudioPages.render_json(source)

    assert res.key?(:visual)
    assert res.key?(:source)
    assert res.key?(:inspect)
    assert_includes res[:inspect], 'Semantic Tree'
    assert_includes res[:inspect], 'Provenance &amp; The Why Pane'
  end

  def test_error_page_for_renders_refusal_cleanly
    error = SlimPickins::Error.new('this portfolio has no holdings')
    html = StudioInspector.error_page_for(error)

    assert_includes html, 'Refusal / Evaluation Error'
    assert_includes html, 'this portfolio has no holdings'
  end
end
