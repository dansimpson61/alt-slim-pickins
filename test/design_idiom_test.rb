# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

class DesignIdiomTest < Minitest::Test
  def test_surface_and_stage_with_flank_and_air
    source = <<~DESIGN
      surface doc_reader
        stage
          air generous
          flank catalog, beside: reading_pane, balance: subordinate, collapse: cozy
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

  def test_unknown_collapse_token_raises_honest_argument_error
    source = <<~DESIGN
      surface error_page
        stage
          flank left_col, beside: right_col, collapse: non_existent_token
    DESIGN

    error = assert_raises(ArgumentError) do
      SlimPickins::DesignIdiom.compile(source)
    end
    assert_includes error.message, 'Unknown collapse token: `non_existent_token`'
  end

  def test_collapse_token_resolves_for_flank_and_horizon
    flank_source = <<~DESIGN
      surface flank_page
        stage
          flank left_col, beside: right_col, collapse: wide
    DESIGN
    flank_css = SlimPickins::DesignIdiom.compile(flank_source)
    assert_includes flank_css, '(inline-size < 64rem)'

    horizon_source = <<~DESIGN
      surface horizon_page
        horizon col1, col2
          collapse wide
    DESIGN
    horizon_css = SlimPickins::DesignIdiom.compile(horizon_source)
    assert_includes horizon_css, '(inline-size < 64rem)'
  end

  def test_surface_with_direct_air_and_horizon_manifesto
    source = <<~DESIGN
      surface workbench
        air tight

        horizon library, editor, output
          posture shelf, workspace, mirror
          collapse roomy

        zone library
          frame quiet
          cadence compact
          scroll internal

        zone editor
          frame quiet
          air balanced
          focus primary

        zone output
          frame lifted
          presence steady
    DESIGN

    css = SlimPickins::DesignIdiom.compile(source)

    # Surface & Stage grid container
    assert_includes css, '.surface-workbench { display: block; width: 100%; }'
    assert_includes css, 'container-name: workbench;'
    assert_includes css, 'grid-template-columns: minmax(14rem, 19rem) minmax(0, 3fr) minmax(0, 2fr);'
    assert_includes css, 'padding: clamp(0.5rem, 1.5cqi, 0.875rem);'
    assert_includes css, 'gap: clamp(0.5rem, 1.5cqi, 0.875rem);'

    # Dissolve intermediate panes wrapper
    assert_includes css, 'display: contents;'

    # Sandi Metz hygiene baseline
    assert_includes css, 'min-height: 0;'
    assert_includes css, 'min-width: 0;'

    # Explicit column placement
    assert_includes css, 'grid-column: 1;'
    assert_includes css, 'grid-column: 2;'
    assert_includes css, 'grid-column: 3;'

    # Container query collapse
    assert_includes css, '@container workbench (inline-size < 56rem) {'
    assert_includes css, 'grid-template-columns: 100%;'

    # Zone library: internal scroll & panel containment
    assert_includes css, 'overflow-y: auto;'
    assert_includes css, 'overscroll-behavior: contain;'
    assert_includes css, 'max-height: var(--panel-height, 28rem);'

    # Zone editor: primary focus
    assert_includes css, 'resize: vertical;'
    assert_includes css, 'min-height: var(--editor-source-height, 12rem);'
    assert_includes css, 'min-height: var(--editor-design-height, 9rem);'
    assert_includes css, 'min-height: var(--editor-data-height, 6rem);'

    # Zone output: steady presence
    assert_includes css, 'position: sticky;'
    assert_includes css, 'top: var(--gap, 0.75rem);'
    assert_includes css, 'height: calc(100dvh - var(--menu-height, 2.75rem) - var(--footer-height, 2rem) - var(--gap-loose, 1.5rem));'
  end

  def test_horizon_mismatched_postures_raises_error
    source = <<~DESIGN
      surface test_page
        horizon col1, col2, col3
          posture shelf, workspace
    DESIGN

    error = assert_raises(ArgumentError) do
      SlimPickins::DesignIdiom.compile(source)
    end
    assert_includes error.message, 'horizon with 3 zones (col1, col2, col3) expected 3 postures, got 2 (shelf, workspace)'
  end

  def test_horizon_unknown_posture_token_raises_error
    source = <<~DESIGN
      surface test_page
        horizon col1, col2
          posture shelf, imaginary_token
    DESIGN

    error = assert_raises(ArgumentError) do
      SlimPickins::DesignIdiom.compile(source)
    end
    assert_includes error.message, 'Unknown posture token: `imaginary_token`'
  end
end
