# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../studio/docs_helper'
require_relative '../studio/pages'
require_relative '../studio/status'

SlimPickins::Library.builtin

# The docs payloads are the studio's documentation of the vocabulary, and
# their "Defined in" line used to lie: the extraction trusted a method's
# source_location, so every word whose class inherits its `evaluate` (17 of
# 69, measured 2026-09-06) pointed at the base class's line in the wrong
# file. These tests pin the truth each payload must tell: the pointer lands
# on the word's own declaration, or there is no pointer at all.
class StudioDocsTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  # The classic UI's library — the same one the studio serves those pages
  # with. Building one by hand here was how this test drifted from the app the
  # first time: the library carries the UI's partials, the layout and the
  # shared furniture, and only the app knows the whole list.
  LIBRARY = StudioPages.ui_library(Uis['classic'])

  def entries = StudioDocs.entries

  def test_every_word_has_a_payload_that_names_a_home
    # Over `entries` itself, not the live registry: in a suite sharing one
    # process, another test's library may register words after the payloads
    # memoised — a timing accident of the test world, not a defect. In the
    # studio the registry is complete before the first request.
    entries.each do |word, entry|
      refute_empty entry[:contract], "#{word} has no contract"
      assert_includes entry[:implementation], '**Defined in**', "#{word} names no home"
    end
  end

  def test_every_partial_payload_points_at_its_sp_file
    entries.each do |word, entry|
      impl = entry[:implementation]
      next unless impl.include?('App Partial')

      klass = SlimPickins::Word.registry[word.to_sym]
      next unless klass.source_path # declared inline — there is no file to point at

      assert_includes impl, "`#{klass.source_path.sub("#{ROOT}/", '')}`",
                      "#{word} names a file that is not its own"
      assert File.file?(klass.source_path), "#{word}'s partial file is missing"
    end
  end

  def test_every_class_payload_points_at_the_words_own_declaration
    entries.each do |word, entry|
      impl = entry[:implementation]
      next if impl.include?('App Partial')

      m = impl.match(/`([^`]+\.rb):(\d+)`/)
      refute_nil m, "#{word} names no location"
      file, line = m[1], m[2].to_i
      lines = File.readlines(File.join(ROOT, file))
      simple = word.split('_').map(&:capitalize).join
      assert_match(/^\s*class #{Regexp.escape(simple)}\b/, lines[line - 1],
                   "#{word} points at #{file}:#{line}, which is not its declaration")
    end
  end

  def test_no_payload_falls_back_to_an_unknown_location
    unknown = entries.values.map { |e| e[:implementation] }.select { |i| i.include?('Unknown location') }
    assert_empty unknown, "payloads without a home: #{unknown.size}"
  end

  def test_every_guide_exists_at_the_root
    StudioDocs::GUIDES.each do |name|
      assert File.file?(File.join(ROOT, "#{name}.md")), "guide #{name} has no document"
    end
  end

  # --- the docs document the language, not the apps --------------------------

  def test_the_sidebar_lists_the_language_not_the_apps
    StudioPages.library # the merged library registers app words globally
    words = StudioDocs.words.map(&:name)
    assert_includes words, 'badge'
    assert_includes words, 'page'
    refute_includes words, 'queue', 'an app partial is not a vocabulary word'
    refute_includes words, 'editor', 'studio furniture is not a vocabulary word'
  end

  def test_the_docs_payloads_cover_the_language_not_the_apps
    keys = StudioDocs.entries.keys
    assert_includes keys, 'money'
    refute_includes keys, 'queue', 'an app partial earns no docs page'
    refute_includes keys, 'editor', 'studio furniture earns no docs page'
  end

  # --- the status page -----------------------------------------------------

  # The page's seam is its locals: results arrive as Structs with name and
  # fenced, the overview as a line of prose. Canned results pin that the
  # page renders for the shape the route gives it, without running the
  # checkers inside the suite.
  def test_status_page_renders_canned_results
    html = SlimPickins.render(File.read(File.join(ROOT, 'studio', 'uis', 'classic', 'views', 'status.sp')),
                              path: 'status.sp',
                              locals: { title: 'Status', words: [], guides: [], ui_names: [],
                                        **StudioStatus.canned_locals },
                              library: LIBRARY)
    assert_includes html, '1 of 8 legs red'
    assert_includes html, 'Grammar'
    assert_includes html, '<pre><code>0 problems', 'the leg output renders as a fence'
    # The state is a badge whose class the stylesheet marks — the page
    # authors no glyph at all, which is the whole point of the CSS mark.
    assert_includes html, 'badge--ok'
    assert_includes html, 'badge--error', 'the red leg wears its state'
    refute_includes html, 'class="icon', 'the status page authors no icon'
  end

  # --- the examples: the docs' "In the wild" section -----------------------

  # The vocabulary's one home that survives the shared registry is the
  # document — VOCABULARY.md, the same source check_grammar reads — so the
  # drift guard iterates that, not the live Word.registry other tests may
  # have loaded with their own app words.
  def test_every_vocabulary_word_has_at_least_one_real_example
    vocab = File.read(File.join(ROOT, 'VOCABULARY.md')).scan(/^### `([a-z_]+)`/).flatten
    vocab.each do |word|
      examples = StudioDocs.examples_of(word)
      refute_empty examples, "#{word} has no real usage in the corpus"
      examples.each do |ex|
        refute_includes ex.body, "\n", "#{word}'s example is not one sentence"
        refute_empty ex.context, "#{word}'s example has no context"
        assert_match(/\.sp:\d+\z/, ex.where, "#{word}'s example is uncited")
        next unless ex.try_path # structural words carry a note, not a link

        assert_equal "/docs/#{word}?try=#{examples.index(ex)}&ui=classic", ex.try_path
      end
    end
  end

  def test_examples_are_capped_at_three
    assert_operator StudioDocs.examples_of('badge').size, :<=, StudioDocs::EXAMPLES_PER_WORD
  end

  def test_seed_for_wraps_the_example_in_a_page
    seed = StudioDocs.seed_for('money', 0)
    assert_match(/\Apage portfolio, "Your retirement"\n/, seed,
                 'a page-rooted example seeds the real opening, subject included')
    assert_includes seed, 'section "Where you stand"'
    assert_includes seed, 'money'
    assert_nil StudioDocs.seed_for('money', 99), 'an index past the list seeds nothing'
  end

  def test_a_partial_internal_seed_gets_a_page_of_its_own
    seed = StudioDocs.seed_for('heading', 0)
    assert_match(/\Apage "Try: heading"\n/, seed)
    assert_includes seed, 'heading .content'
  end

  def test_examples_carry_context_and_the_pages_payload
    examples = StudioDocs.examples_of('money') { |path| StudioPages.data_json_for(path) }
    first = examples.first
    assert_includes first.context, 'page portfolio, "Your retirement"'
    assert_includes first.context, 'section "Where you stand"'
    assert_includes first.context, 'money .total_value'
    assert_equal 'pages/portfolio_table.sp', first.path
    parsed = JSON.parse(first.data)
    assert_equal 1_284_506, parsed['portfolio']['total_value']
  end

  def test_a_partial_internal_example_gets_synthetic_payload
    examples = StudioDocs.examples_of('heading') { |p, c| StudioPages.data_json_for(p, c) }
    parsed = JSON.parse(examples.first.data)
    assert_equal 'Hello world', parsed['content'], 'the slot read gets a synthetic value'
    assert_nil parsed['name'], 'a nil slot keeps enclosing boxes open for their children'
    assert_nil examples.first.note, 'a synthetic payload is not a structural note'
  end

  def test_the_docs_page_renders_with_canned_examples
    examples = [StudioDocs::Example.new(body: "badge ok, \"x\"",
                                        where: 'pages/specimen.sp:13',
                                        path: 'pages/specimen.sp',
                                        context: "section \"Facts, badges, moments\"\n  badge ok, \"x\"",
                                        try_path: '/docs/badge?try=0', data: '')]
    html = SlimPickins.render(File.read(File.join(ROOT, 'studio', 'uis', 'classic', 'views', 'docs.sp')),
                              path: 'docs.sp',
                              locals: { title: 'Docs: badge', contract: 'c', implementation: 'i',
                                        examples: examples, source: "page \"Try: badge\"\n",
                                        editor_title: 'Try it: badge', data: '',
                                        data_note: StudioDocs::DATA_NOTE, words: [], guides: [],
                                        ui_names: [] },
                              library: LIBRARY)
    assert_includes html, 'In the wild'
    assert_includes html, 'Try it: badge'
    assert_includes html, 'snippet--sp', 'the example renders in the language’s own fence'
    assert_includes html, 'Try it</a>', 'each example carries its seed link'
    assert_includes html, 'grid', 'the two outputs share a row'
    # The burr's resolution, to its natural end: one wired form, no button.
    assert_includes html, 'data-controller="render"', 'the form is wired'
    assert_includes html, 'action="/render"', 'the form still names its route'
    assert_equal 0, html.scan('type="submit"').size, 'live rendering needs no button'
    assert_equal 1, html.scan('class="form editor_form"').size,
                 'the wired form carries its class exactly once'
  end
end
