# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

class DesignIdiomTest < Minitest::Test
  def test_surface_and_stage_with_flank_and_air
    source = <<~DESIGN
      surface doc_reader
        stage
          air generous
          flank catalog, beside: reading_pane, balance: subordinate, collapse_at: "48rem"
    DESIGN

    css = SlimPickins::DesignIdiom.compile(source)

    assert_includes css, '.surface-doc_reader { display: block; width: 100%; }'
    assert_includes css, 'container-type: inline-size;'
    assert_includes css, 'container-name: doc_reader;'
    assert_includes css, 'padding: clamp(1.5rem, 4cqi, 3rem);'
    assert_includes css, 'gap: clamp(1.5rem, 4cqi, 3rem);'
    assert_includes css, 'grid-template-columns: minmax(14rem, 1fr) minmax(0, 3fr);'
    assert_includes css, '.stage-doc_reader > .catalog,'
    assert_includes css, 'grid-column: 1;'
    assert_includes css, '.stage-doc_reader > .reading_pane,'
    assert_includes css, 'grid-column: 2;'
    assert_includes css, '@container doc_reader (inline-size < 48rem) {'
    assert_includes css, 'grid-template-columns: 100%;'
  end

  def test_flank_balance_variants
    equal_source = <<~DESIGN
      surface test_surface
        stage
          flank left_col, beside: right_col, balance: equal
    DESIGN
    equal_css = SlimPickins::DesignIdiom.compile(equal_source)
    assert_includes equal_css, 'grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);'

    dominant_source = <<~DESIGN
      surface test_surface
        stage
          flank hero, beside: aside_col, balance: dominant
    DESIGN
    dominant_css = SlimPickins::DesignIdiom.compile(dominant_source)
    assert_includes dominant_css, 'grid-template-columns: minmax(0, 3fr) minmax(14rem, 1fr);'
  end

  def test_stage_with_stack
    source = <<~DESIGN
      surface dashboard
        stage
          air balanced
          stack header, metrics, chart
    DESIGN

    css = SlimPickins::DesignIdiom.compile(source)
    assert_includes css, 'display: flex;'
    assert_includes css, 'flex-direction: column;'
    assert_includes css, 'padding: clamp(1rem, 2.5cqi, 1.75rem);'
    assert_includes css, 'gap: clamp(1rem, 2.5cqi, 1.75rem);'
  end

  def test_zones_with_frame_cadence_and_treatment
    source = <<~DESIGN
      surface doc_reader
        zone catalog
          frame quiet
          cadence compact

        zone reading_pane
          frame quiet
          treatment editorial
    DESIGN

    css = SlimPickins::DesignIdiom.compile(source)

    # Catalog zone assertions
    assert_includes css, '.stage-doc_reader > .catalog,'
    assert_includes css, 'background: var(--surface-soft, #f9f8f5);'
    assert_includes css, 'border: 1px solid var(--rule, #e5e1d8);'
    assert_includes css, 'gap: 0.35rem;'

    # Reading pane zone assertions
    assert_includes css, '.stage-doc_reader > .reading_pane,'
    assert_includes css, 'max-width: 65ch;'
    assert_includes css, 'line-height: 1.7;'
    assert_includes css, 'font-size: 1.05rem;'
  end

  def test_empty_or_blank_design_returns_empty_string
    assert_equal '', SlimPickins::DesignIdiom.compile('')
    assert_equal '', SlimPickins::DesignIdiom.compile(nil)
    assert_equal '', SlimPickins::DesignIdiom.compile("   \n\n  ")
  end

  def test_theme_custom_token_injection
    custom_air = { custom_wide: '5rem' }
    source = <<~DESIGN
      surface custom_page
        stage
          air custom_wide
    DESIGN

    css = SlimPickins::DesignIdiom.compile(source, air_tokens: custom_air)
    assert_includes css, 'padding: 5rem;'
    assert_includes css, 'gap: 5rem;'
  end

  def test_unknown_air_token_raises_honest_argument_error
    source = <<~DESIGN
      surface error_page
        stage
          air non_existent_token
    DESIGN

    error = assert_raises(ArgumentError) do
      SlimPickins::DesignIdiom.compile(source)
    end
    assert_includes error.message, 'Unknown air token: `non_existent_token`'
  end
end
