# frozen_string_literal: true

require 'tmpdir'
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
  # The classic UI's library, because these tests render the classic UI's
  # pages: a UI's pages need that UI's own partials, and `StudioPages.library`
  # is deliberately the sandbox without any UI's. The layout rides along, so a
  # UI page that says `contents` is wrapped exactly as the studio wraps it.
  CLASSIC = Uis['classic']
  LIBRARY = StudioPages.ui_library(CLASSIC)

  def test_every_palette_page_exists
    StudioPages::PAGES.each do |id, rel|
      assert File.file?(File.join(ROOT, rel)), "#{id} points at #{rel}, which is missing"
    end
  end

  def test_the_census_is_complete
    expected = Dir[File.join(ROOT, 'pages', '**', '*.sp')]
               .reject { |f| File.basename(f) == 'layout.sp' } # chrome, not a page
               .map { |f| f.sub("#{ROOT}/", '') }
    expected += Dir[File.join(ROOT, 'examples', '**', 'views', '**', '*.sp')]
                .reject { |f| File.basename(f) == 'layout.sp' } # chrome, not a page
                .map { |f| f.sub("#{ROOT}/", '') }
    # Every UI's pages are in the census, discovered the way the registry
    # discovers them: a UI's page that is missing from the palette is a page
    # the gate never proves. The refusal template is shared chrome, not a page.
    expected += Dir[File.join(ROOT, 'studio', 'uis', '*', 'views', '*.sp')]
                .reject { |f| File.basename(f) == 'refusal.sp' }
                .map { |f| f.sub("#{ROOT}/", '') }
    assert_equal expected.sort, StudioPages::PAGES.values.sort
  end

  # The name is the promise, and until 2026-09-17 the test only checked that the
  # verdict agreed with itself: the census measured the *empty-data* render
  # while loading a page pre-fills its payload, so every entry wore `error` and
  # every entry rendered. (DAYTRIP-0.3.0b, W1.) It now asserts the promise in
  # both directions — an `ok` verdict is a render that succeeds with the page's
  # own payload, and an `error` verdict is the complaint that render raises.
  def test_every_verdict_is_a_render_the_playground_would_give
    entries = StudioPages.entries(library: LIBRARY)
    assert_equal StudioPages::PAGES.size, entries.size

    entries.each do |entry|
      assert_includes %w[ok error], entry.status, "#{entry.id} has no verdict"
      assert_equal entry.status == 'error', !entry.refusal.nil?,
                   "#{entry.id}: verdict and refusal disagree"
      # The load path is a template the serving UI mints, not a URL: the
      # `:ui` and `:id` are filled by `link_to`, so the census cannot bake in
      # one UI's name — and `:ui` in the palette must never be substituted by
      # the census itself, or a second UI's palette would link into this one.
      assert_equal '/?load=:id&ui=:ui', entry.load_path

      # The render the load gives — the same locals the route builds.
      complaint =
        begin
          SlimPickins.render(File.read(File.join(ROOT, entry.path)), path: entry.path,
                             locals: StudioPages.load_locals(entry.path),
                             library: LIBRARY)
          nil
        rescue SlimPickins::Error => e
          e.message
        end

      if entry.status == 'ok'
        assert_nil complaint, "#{entry.id} wears `ok` and the load refuses it — #{complaint}"
      else
        assert_equal entry.refusal, complaint,
                     "#{entry.id} wears `error` and does not record what the load raises"
      end
    end
  end

  # The palette's ids, never a raw path: a load parameter cannot read what
  # PAGES did not name. With several UIs a page also belongs to the UI that
  # serves it, so the refusal is held in both directions — the page's own UI
  # reads it, another UI's is refused rather than rendered against the wrong
  # partials.
  def test_source_for_reads_only_palette_pages
    StudioPages::PAGES.each do |id, rel|
      ui = Uis[id.start_with?('studio/') ? id.split('/')[1] : nil] || Uis.default_ui
      assert_equal File.read(File.join(ROOT, rel)), StudioPages.source_for(id, ui: ui)
    end
    assert_nil StudioPages.source_for('../../etc/passwd')
    assert_nil StudioPages.source_for(nil)

    classic = Uis['classic']
    other = Uis.all.find { |u| u.name != classic.name }
    if other
      assert_nil StudioPages.source_for("studio/#{other.name}/index", ui: classic),
                 "another UI's page must not load into this one"
    end
  end

  def test_the_playground_page_renders_with_a_canned_palette
    entries = StudioPages.entries(library: LIBRARY).first(2)
    html = SlimPickins.render(File.read(File.join(ROOT, 'studio', 'uis', 'classic', 'views', 'index.sp')),
                              path: 'index.sp',
                              locals: { source: "page \"x\"\n", palette: entries,
                                        editor_title: 'Write .sp Code', data: '',
                                        docs: StudioDocs.build, words: [], guides: [],
                                        ui_names: [], words_count: 64, pages_count: 22 },
                              library: LIBRARY)
    assert_includes html, 'Start from a real page'
    assert_includes html, entries.first.name
    assert_includes html, 'class="link', 'the palette loads through links, not a form'
  end

  def test_the_playground_library_renders_an_app_page_with_its_partials
    # triage is the dashboard's page: its partials (queue, unreviewed_card)
    # were the wall the census masked. The playground's library now knows
    # them, so with the page's own data it renders end-to-end.
    locals = { notice: nil, q: '', error_entry: nil,
               nav_state: { studio: false, library: false, reconcile: false,
                            dispatch: false, ports: false },
               first_item: nil, queue_intro: '', unreviewed: nil }
    html = SlimPickins.render(File.read(File.join(ROOT, 'examples', 'dashboard', 'views', 'triage.sp')),
                              path: 'examples/dashboard/views/triage.sp',
                              locals: locals, library: LIBRARY)
    assert_includes html, 'Triage'
    assert_includes html, 'All caught up', 'the queue partial rendered through the wall'
    refute_includes html, 'no word', 'the partial wall is down'
  end

  def test_the_merge_refuses_a_partial_name_shared_by_two_apps
    Dir.mktmpdir do |a|
      Dir.mktmpdir do |b|
        Dir.mkdir(File.join(a, 'partials'))
        Dir.mkdir(File.join(b, 'partials'))
        File.write(File.join(a, 'partials', 'clash.sp'), "title \"a\"\n")
        File.write(File.join(b, 'partials', 'clash.sp'), "title \"b\"\n")
        error = assert_raises(SlimPickins::Error) { StudioPages.merge_libraries([a, b]) }
        assert_includes error.message, 'clash'
      end
    end
  end

  # --- the data ledger: every provider's promise ----------------------------

  # One needle per provider page: the pre-filled JSON, round-tripped through
  # the data slot, must render the page with the playground's library — the
  # ledger's promise, held so a rotted payload is a red test, not a quietly
  # empty slot.
  LEDGER_PAGES = {
    'pages/portfolio_table.sp' => 'Where you stand',
    'pages/specimen.sp' => 'Facts, badges, moments',
    'pages/account_detail.sp' => 'Account detail',
    'pages/roth_form.sp' => 'Directional Roth Conversion Sketch',
    'pages/partials/test_account_card.sp' => 'Roth IRA',
    'examples/portfolio/views/index.sp' => 'Your retirement',
    'examples/portfolio/views/account.sp' => 'Account detail',
    'examples/portfolio/views/partials/account_card.sp' => 'Roth IRA',
    'examples/roth/views/controls.sp' => 'Directional Roth Conversion Sketch',
    'examples/roth/views/partials/report.sp' => 'Your projection',
    'examples/dashboard/views/triage.sp' => 'needs attention',
    'examples/dashboard/views/confirm_archive.sp' => 'Moves the project into archive',
    'examples/dashboard/views/partials/queue.sp' => 'needs attention',
    'examples/dashboard/views/partials/unreviewed_card.sp' => 'awaiting judgment'
  }.freeze

  def test_every_ledger_page_renders_with_its_prefilled_data
    # The one-process suite shares one Word.registry, and a partial's class
    # there is whichever library compiled it last — gate_test inline-registers
    # a deliberately invalid `test_account_card`, and the memoised constant
    # above was compiled before it. The studio's own boot is a clean process
    # that owns its registry; this test rebuilds the merged library at use
    # time so it owns its words the same way — last compile wins, and this
    # compile is the studio's.
    library = StudioPages.merge_libraries(StudioPages.library_dirs,
                                          words: [AppWords, ClassicWords])
    LEDGER_PAGES.each do |rel, needle|
      json = StudioPages.data_json_for(rel)
      refute_empty json, "#{rel} has no payload"
      html = SlimPickins.render(File.read(File.join(ROOT, rel)), path: rel,
                                locals: StudioPages.playground_locals(json),
                                library: library)
      refute_includes html, 'note--error', "#{rel} refuses its own payload"
      assert_includes html, needle, "#{rel} rendered without its needle"
    end
  end

  def test_the_prefilled_json_parses_back_into_locals
    json = StudioPages.data_json_for('pages/portfolio_table.sp')
    locals = StudioPages.data_locals(json)
    assert_equal 1_284_506, locals['portfolio']['total_value']
  end

  # --- the render contract: one response, both panes ------------------------

  def test_render_json_carries_both_panes
    payload = StudioPages.render_json("page \"t\"\n  money .total_value\n",
                                      '{"total_value": 120}')
    assert_includes payload[:visual], '<span class="money">$120</span>'
    assert_includes payload[:source], '&lt;span class=&quot;money&quot;&gt;', 'the raw pane is escaped'
    assert_includes payload[:source], 'white-space: pre-wrap',
                    'the raw pane keeps its tidy monospace wrapper'
  end

  def test_render_json_refuses_in_the_languages_voice
    payload = StudioPages.render_json("page \"t\"\n  money .total_value\n", '')
    assert_includes payload[:visual], 'note--error'
    assert_includes payload[:visual], 'this page has no total_value'
    assert_includes payload[:source], 'note--error', 'the raw pane shows the same refusal'
  end

  # --- the data wall: the writer's JSON, bound as locals --------------------

  def test_data_locals_parse_json_for_the_playground
    assert_equal({}, StudioPages.data_locals(''))
    assert_equal({}, StudioPages.data_locals(nil))
    assert_equal({ 'total_value' => 12 }, StudioPages.data_locals('{"total_value": 12}'))
    assert_equal({ 'holdings' => [{ 'market_value' => 3 }] },
                 StudioPages.data_locals('{"holdings": [{"market_value": 3}]}'))
    error = assert_raises(SlimPickins::Error) { StudioPages.data_locals('{nope') }
    assert_includes error.message, 'does not parse as JSON'
  end

  def test_the_writers_data_binds_as_locals
    html = SlimPickins.render("page \"t\"\n  money .total_value\n", path: 'p.sp',
                              locals: StudioPages.playground_locals('{"total_value": 12}'),
                              library: LIBRARY)
    assert_includes html, '$12'
  end

  def test_the_writers_data_binds_through_each
    html = SlimPickins.render("page \"t\"\n  each holding\n    money .market_value\n",
                              path: 'p.sp',
                              locals: StudioPages.playground_locals('{"holdings": [{"market_value": 3}]}'),
                              library: LIBRARY)
    assert_includes html, '$3'
  end

  # --- the refusal page: errors in the language's own voice ------------------

  def test_the_refusal_page_speaks_the_language
    html = SlimPickins.render(File.read(File.join(ROOT, 'studio', 'shared', 'refusal.sp')),
                              path: 'refusal.sp',
                              locals: { title: 'Refusal', complaint: 'this page has no total_value',
                                        where: 'playground.sp, line 2',
                                        line: 'money .total_value' },
                              library: LIBRARY)
    assert_includes html, 'this page has no total_value'
    assert_includes html, 'note--error'
    assert_includes html, 'playground.sp, line 2'
    assert_includes html, 'money .total_value'
  end

  def test_the_refusal_page_renders_without_a_sentence
    html = SlimPickins.render(File.read(File.join(ROOT, 'studio', 'shared', 'refusal.sp')),
                              path: 'refusal.sp',
                              locals: { title: 'Refusal',
                                        complaint: 'the data does not parse as JSON — x',
                                        where: nil, line: nil },
                              library: LIBRARY)
    assert_includes html, 'does not parse'
    refute_includes html, 'snippet', 'no sentence means no fence'
  end
end
