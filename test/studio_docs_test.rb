# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../studio/docs_helper'
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

  # --- the status page -----------------------------------------------------

  # The page's seam is its locals: results arrive as Structs with name and
  # fenced, the overview as a line of prose. Canned results pin that the
  # page renders for the shape the route gives it, without running the
  # checkers inside the suite.
  def test_status_page_renders_canned_results
    results = [
      StudioStatus::Result.new(name: 'Grammar', output: "0 problems\n", ok: true),
      StudioStatus::Result.new(name: 'Shape', output: "1 problem\n", ok: false)
    ]
    library = SlimPickins::Library.from(File.expand_path('../studio/views', __dir__))
    html = SlimPickins.render(File.read(File.join(ROOT, 'studio', 'views', 'status.sp')),
                              path: 'status.sp',
                              locals: { title: 'Status', overview: '1 of 2 legs red.',
                                        results: results, words: [], guides: [] },
                              library: library)
    assert_includes html, '1 of 2 legs red.'
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
        assert_match(/\.sp:\d+\z/, ex.where, "#{word}'s example is uncited")
        assert_equal "/docs/#{word}?try=#{examples.index(ex)}", ex.try_path
      end
    end
  end

  def test_examples_are_capped_at_three
    assert_operator StudioDocs.examples_of('badge').size, :<=, StudioDocs::EXAMPLES_PER_WORD
  end

  def test_seed_for_wraps_the_example_in_a_page
    seed = StudioDocs.seed_for('money', 0)
    assert_match(/\Apage "Try: money"\n  /, seed)
    assert_includes seed, 'money'
    assert_nil StudioDocs.seed_for('money', 99), 'an index past the list seeds nothing'
  end

  def test_the_docs_page_renders_with_canned_examples
    examples = [StudioDocs::Example.new(body: "badge ok, \"x\"",
                                        where: 'pages/specimen.sp:13',
                                        try_path: '/docs/badge?try=0')]
    library = SlimPickins::Library.from(File.expand_path('../studio/views', __dir__))
    html = SlimPickins.render(File.read(File.join(ROOT, 'studio', 'views', 'docs.sp')),
                              path: 'docs.sp',
                              locals: { title: 'Docs: badge', contract: 'c', implementation: 'i',
                                        examples: examples, source: "page \"Try: badge\"\n",
                                        editor_title: 'Try it: badge',
                                        data_note: StudioDocs::DATA_NOTE, words: [], guides: [] },
                              library: library)
    assert_includes html, 'In the wild'
    assert_includes html, 'Try it: badge'
    assert_includes html, 'snippet--sp', 'the example renders in the language’s own fence'
    assert_includes html, 'Try it</a>', 'each example carries its seed link'
    assert_includes html, 'grid', 'the two outputs share a row'
  end
end
