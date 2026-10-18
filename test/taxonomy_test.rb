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
    assert_equal 63, @census_words.size
    assert_equal 63, @entries.size
    assert_equal @census_words.sort, @entries.keys.sort
  end

  def test_the_three_ontological_planes
    planes = SlimPickins::Taxonomy.planes
    assert_equal %i[invariant linguistic spatial], planes.keys.sort

    assert_equal %i[word primitive composed_word def], planes[:linguistic][:terms]
    assert_equal %i[frame layout style substance], planes[:spatial][:terms]
    assert_equal %i[contract convention promise], planes[:invariant][:terms]

    planes.each do |key, meta|
      assert meta[:name], "Plane #{key} has name"
      assert meta[:title], "Plane #{key} has title"
      assert meta[:summary], "Plane #{key} has summary"
      refute_empty meta[:terms], "Plane #{key} has terms"
    end
  end

  def test_all_refined_categories_valid_and_non_empty
    expected = %i[affordances environment flow skeleton substance].sort
    assert_equal expected, SlimPickins::Taxonomy.categories.keys.sort

    SlimPickins::Taxonomy.categories.each do |key, meta|
      assert meta[:name], "Category #{key} has name"
      assert meta[:title], "Category #{key} has title"
      assert meta[:question], "Category #{key} has authoring question"
      assert meta[:summary], "Category #{key} has summary"
      refute_empty meta[:sub_categories], "Category #{key} has sub-categories"
    end
  end

  def test_each_word_has_complete_entry_metadata
    @entries.each do |word, entry|
      refute_empty entry.categories, "Word #{word} must belong to at least one category"
      assert entry.primary_category, "Word #{word} must declare a primary category"
      assert_includes entry.categories, entry.primary_category, "Primary category must be among declared categories"
      assert entry.sub_category, "Word #{word} must declare a sub-category"
      refute_empty entry.role, "Word #{word} must declare an authoring role"
      refute_empty entry.note, "Word #{word} must declare a diagnostic note"
      assert_includes %i[sits_well ad_hoc candidate_for_split], entry.diagnostic,
                      "Word #{word} must have a valid diagnostic status"
      assert_includes %i[cohesive overloaded single_consumer styling_leak], entry.cohesion,
                      "Word #{word} must have a cohesion assessment"
    end
  end

  def test_words_for_category_includes_all_applicable_words
    by_cat = SlimPickins::Taxonomy.by_category

    by_cat.each do |cat, words|
      refute_empty words, "Category #{cat} must have words"
      words.each do |word|
        entry = SlimPickins::Taxonomy.entry(word)
        assert_includes entry.categories, cat, "Word #{word} must declare category #{cat}"
      end
    end

    # Specific multi-category members
    assert_includes SlimPickins::Taxonomy.words_for_category(:skeleton), :card
    assert_includes SlimPickins::Taxonomy.words_for_category(:substance), :card

    assert_includes SlimPickins::Taxonomy.words_for_category(:skeleton), :table
    assert_includes SlimPickins::Taxonomy.words_for_category(:substance), :table

    assert_includes SlimPickins::Taxonomy.words_for_category(:affordances), :actions
    assert_includes SlimPickins::Taxonomy.words_for_category(:skeleton), :actions

    assert_includes SlimPickins::Taxonomy.words_for_category(:flow), :disclosure
    assert_includes SlimPickins::Taxonomy.words_for_category(:skeleton), :disclosure
  end

  def test_filter_analysis_diagnostics
    analysis = SlimPickins::Taxonomy.filter_analysis

    # 1. Passband widths
    widths = analysis.passband_widths
    assert_equal 5, widths.size
    assert_equal 22, widths[:substance][:count]
    assert_equal 25, widths[:skeleton][:count]
    assert_equal 19, widths[:affordances][:count]
    assert_equal 6, widths[:flow][:count]
    assert_equal 5, widths[:environment][:count]

    # 2. Boundary selectivity
    selectivity = analysis.boundary_selectivity
    assert_equal 5, selectivity.size
    assert selectivity[:environment][:selectivity] > 0.8, "Environment exhibits high selectivity"
    assert selectivity[:skeleton][:selectivity] >= 0.5, "Skeleton has moderate selectivity due to container housing"

    # 3. Polyhierarchical resonance
    resonance = analysis.polyhierarchical_resonance
    assert_equal 14, resonance.size, "14 words exhibit constructive multi-category resonance"
    resonance_words = resonance.map { |r| r[:word] }
    assert_includes resonance_words, :card
    assert_includes resonance_words, :table
    assert_includes resonance_words, :form
    assert_includes resonance_words, :disclosure
    assert_includes resonance_words, :empty
    assert_includes resonance_words, :actions

    # 4. Crossover matrix
    matrix = analysis.crossover_matrix
    refute_empty matrix
    assert_equal %i[card chart dictionary fact table].sort, matrix[%i[substance skeleton]].sort
    assert_equal %i[actions field form group nav tabs].sort, matrix[%i[skeleton affordances]].sort
  end

  def test_system_taxonomy_terms_across_the_three_planes
    expected = %i[word primitive composed_word def frame layout style substance contract convention promise].sort
    system_terms = SlimPickins::Taxonomy.system_terms

    assert_equal expected, system_terms.keys.sort
    assert_equal 11, system_terms.size

    system_terms.each do |key, term|
      assert_equal key, term.name
      assert_includes %i[linguistic spatial invariant], term.plane
      refute_empty term.summary
      refute_empty term.definition
      assert_equal term, SlimPickins::Taxonomy.system_term(key)
    end
  end
end
