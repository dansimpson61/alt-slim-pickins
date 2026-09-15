# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../studio/docs_helper'
require_relative '../studio/pages'

SlimPickins::Library.builtin

# The palette is the studio's census of the repo's real pages, and the
# census is only worth the trust these tests pin: it is complete (every
# `.sp` under examples/ and the studio's own top-level views is in it — a
# census that skips pages understates the demand), every named file exists,
# and every verdict comes from the same render the playground will give, so
# the census itself can never raise.
class StudioPagesTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  LIBRARY = SlimPickins::Library.from(File.join(ROOT, 'studio', 'views'))

  def test_every_palette_page_exists
    StudioPages::PAGES.each do |id, rel|
      assert File.file?(File.join(ROOT, rel)), "#{id} points at #{rel}, which is missing"
    end
  end

  def test_the_census_is_complete
    expected = Dir[File.join(ROOT, 'examples', '**', 'views', '**', '*.sp')]
               .reject { |f| File.basename(f) == 'layout.sp' } # chrome, not a page
               .map { |f| f.sub("#{ROOT}/", '') }
    expected += Dir[File.join(ROOT, 'studio', 'views', '*.sp')]
                .map { |f| f.sub("#{ROOT}/", '') }
    assert_equal expected.sort, StudioPages::PAGES.values.sort
  end

  def test_every_verdict_is_a_render_the_playground_would_give
    entries = StudioPages.entries(library: LIBRARY)
    assert_equal StudioPages::PAGES.size, entries.size
    entries.each do |entry|
      assert_includes %w[ok error], entry.status, "#{entry.id} has no verdict"
      assert_equal entry.status == 'error', !entry.refusal.nil?,
                   "#{entry.id}: verdict and refusal disagree"
      assert_equal "/?load=#{entry.id}", entry.load_path
    end
  end

  def test_source_for_reads_only_palette_pages
    StudioPages::PAGES.each_key do |id|
      assert_equal File.read(File.join(ROOT, StudioPages::PAGES[id])),
                   StudioPages.source_for(id)
    end
    assert_nil StudioPages.source_for('../../etc/passwd')
    assert_nil StudioPages.source_for(nil)
  end

  def test_the_playground_page_renders_with_a_canned_palette
    entries = StudioPages.entries(library: LIBRARY).first(2)
    html = SlimPickins.render(File.read(File.join(ROOT, 'studio', 'views', 'index.sp')),
                              path: 'index.sp',
                              locals: { source: "page \"x\"\n", palette: entries,
                                        editor_title: 'Write .sp Code',
                                        docs: StudioDocs.build, words: [], guides: [] },
                              library: LIBRARY)
    assert_includes html, 'Start from a real page'
    assert_includes html, entries.first.name
    assert_includes html, 'class="link', 'the palette loads through links, not a form'
  end
end
