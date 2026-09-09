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
    SlimPickins::Word.registry.keys.each do |name|
      entry = entries[name.to_s]
      refute_nil entry, "#{name} has no payload"
      refute_empty entry[:contract], "#{name} has no contract"
      assert_includes entry[:implementation], '**Defined in**', "#{name} names no home"
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
  end
end
