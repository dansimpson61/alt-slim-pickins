# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/census'
require_relative '../lib/slim_pickins/taxonomy'

class TaxonomyTest < Minitest::Test
  def setup
    @census_words = SlimPickins::Census.words[:total]
    @entries = SlimPickins::Taxonomy.entries
  end

  def test_exact_parity_with_canonical_census
    assert_equal 64, @census_words.size
    assert_equal 64, @entries.size
    assert_equal @census_words.sort, @entries.keys.sort
  end

  def test_all_tiers_valid_and_non_empty
    expected_tiers = %i[structural semantic interactive behavioral visual]
    assert_equal expected_tiers.sort, SlimPickins::Taxonomy.tiers.keys.sort

    SlimPickins::Taxonomy.tiers.each do |key, meta|
      assert meta[:name], "Tier #{key} has name"
      assert meta[:title], "Tier #{key} has title"
      assert meta[:question], "Tier #{key} has authoring question"
      assert meta[:summary], "Tier #{key} has summary"
    end
  end

  def test_each_word_has_complete_entry_metadata
    @entries.each do |word, entry|
      refute_empty entry.tiers, "Word #{word} must belong to at least one tier"
      assert entry.primary_tier, "Word #{word} must declare a primary tier"
      assert_includes entry.tiers, entry.primary_tier, "Primary tier must be among declared tiers"
      refute_empty entry.role, "Word #{word} must declare an authoring role"
      refute_empty entry.note, "Word #{word} must declare a diagnostic note"
      assert_includes %i[sits_well ad_hoc candidate_for_split], entry.diagnostic,
                      "Word #{word} must have a valid diagnostic status"
      assert_includes %i[cohesive overloaded single_consumer styling_leak], entry.cohesion,
                      "Word #{word} must have a cohesion assessment"
    end
  end

  def test_words_for_tier_includes_all_applicable_words
    by_tier = SlimPickins::Taxonomy.by_tier

    by_tier.each do |tier, words|
      refute_empty words, "Tier #{tier} must have words"
      words.each do |word|
        entry = SlimPickins::Taxonomy.entry(word)
        assert_includes entry.tiers, tier, "Word #{word} must declare tier #{tier}"
      end
    end

    # Specific multi-category members
    assert_includes SlimPickins::Taxonomy.words_for_tier(:structural), :card
    assert_includes SlimPickins::Taxonomy.words_for_tier(:visual), :card
    assert_includes SlimPickins::Taxonomy.words_for_tier(:semantic), :card

    assert_includes SlimPickins::Taxonomy.words_for_tier(:semantic), :table
    assert_includes SlimPickins::Taxonomy.words_for_tier(:structural), :table
    assert_includes SlimPickins::Taxonomy.words_for_tier(:behavioral), :table

    assert_includes SlimPickins::Taxonomy.words_for_tier(:interactive), :disclosure
    assert_includes SlimPickins::Taxonomy.words_for_tier(:behavioral), :disclosure
    assert_includes SlimPickins::Taxonomy.words_for_tier(:structural), :disclosure
  end

  def test_multi_category_porosity
    multi = SlimPickins::Taxonomy.multi_category_words
    refute_empty multi
    assert_includes multi, :card
    assert_includes multi, :table
    assert_includes multi, :disclosure
    assert_includes multi, :actions
    assert_includes multi, :form
    assert_includes multi, :field
    assert_includes multi, :empty
  end

  def test_cohesion_and_split_assessments
    ledger = SlimPickins::Taxonomy.cohesion_ledger
    assert_equal 64, ledger[:cohesive].size, "All 64 words are cohesive concepts"

    # Split / overload candidates
    split_words = SlimPickins::Taxonomy.split_candidates
    assert_empty split_words, "box and span are recognized as essential primitives; no candidates for split"

    # Single-consumer ad-hoc words (absorbed into figure and disclosure in Volet 5)
    ad_hoc = SlimPickins::Taxonomy.ad_hoc_words
    assert_empty ad_hoc, "figcaption and summary absorbed into figure and disclosure via privileged tag"
  end

  def test_missing_primitives_identified
    missing = SlimPickins::Taxonomy.missing_primitives
    names = missing.map { |m| m[:name] }
    assert_includes names, :stack, "stack is diagnosed as a missing vertical rhythm primitive"
    assert_includes names, :cluster, "cluster is diagnosed as a missing horizontal flow primitive"
    assert_includes names, :sidebar, "sidebar is diagnosed as a missing two-column layout primitive"
  end

  def test_visual_tier_idiom_diagnosis
    # Primary visual words must only be chrome/assets/status, not arbitrary paint
    primary_visual = SlimPickins::Taxonomy.by_primary_tier[:visual]
    assert_equal %i[badge iframe script stylesheet], primary_visual.sort

    # Badge is semantic status dressed as a pill
    assert_includes SlimPickins::Taxonomy.entry(:badge).tiers, :semantic

    # No word in the language exists solely for visual decoration
    pure_decorative = @entries.values.select do |e|
      e.tiers == %i[visual] && !%i[stylesheet script iframe].include?(e.word)
    end
    assert_empty pure_decorative, "No vocabulary word exists solely as decorative paint"
  end

  def test_system_taxonomy_terms
    expected = %i[word primitive partial def contract tin spiff].sort
    system_terms = SlimPickins::Taxonomy.system_terms

    assert_equal expected, system_terms.keys.sort
    assert_equal 7, system_terms.size

    system_terms.each do |key, term|
      assert_equal key, term.name
      refute_empty term.summary
      refute_empty term.definition
      assert_equal term, SlimPickins::Taxonomy.system_term(key)
    end
  end
end
