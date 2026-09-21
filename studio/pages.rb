# frozen_string_literal: true

require 'json'
require 'cgi'
require_relative '../lib/slim_pickins'
require_relative 'uis'
require_relative 'status'
require_relative 'docs_helper'
require_relative 'uis/words'
# The sandbox: the example apps' own files, required rather than copied —
# their boot gates prove the pages with the same locals the ledger serves.
require_relative '../test/fixtures'
require_relative '../examples/portfolio/app'
require_relative '../examples/roth/app'
require_relative '../examples/lore_reader/lib/lore'
require_relative '../examples/way_exam/lib/exam'
require_relative '../examples/milestone_planner/lib/planner'


# The palette: the repo's own real pages, offered to the playground as
# starting points, each carrying its census verdict — the same render the
# playground will give it, run when the palette is built. `ok` means the page
# renders with the playground's locals and the studio's library; `error`
# means it named a wall, and the refusal is recorded verbatim, the way the
# language said it. The palette is curated for order and complete by test:
# every `.sp` under pages/ and examples/ (a layout is chrome, not a page)
# and the studio's own top-level views is in it, because a census that
# skips pages understates the demand.
module StudioPages
  ROOT = File.expand_path('..', __dir__)

  Entry = Struct.new(:id, :name, :path, :load_path, :status, :refusal, :here,
                     keyword_init: true)

  # Ordered as an argument, exactly like the guides: the repo's own pages
  # first — specimen leads, it is the whole vocabulary on one page — then
  # the example apps, an app's pages before its partials, the studio last.
  # A layout and the refusal template are chrome, not pages, so they are
  # not here.
  # Every UI's own pages join the census, discovered rather than listed: a
  # new UI's pages must appear in the palette the moment the UI does, or the
  # census is understating the demand for exactly the surfaces most likely to
  # be broken. `refusal.sp` is a template, not a page, and stays out.
  def self.ui_pages
    Uis.all.flat_map do |ui|
      Dir[File.join(ui.views, '*.sp')]
        .reject { |path| File.basename(path) == 'refusal.sp' }
        .map { |path| ["studio/#{ui.name}/#{File.basename(path, '.sp')}", path.sub("#{ROOT}/", '')] }
    end
  end

  PAGES = {
    'pages/specimen' => 'pages/specimen.sp',
    'pages/portfolio_table' => 'pages/portfolio_table.sp',
    'pages/account_detail' => 'pages/account_detail.sp',
    'pages/roth_form' => 'pages/roth_form.sp',
    'pages/partials/test_account_card' => 'pages/partials/test_account_card.sp',
    'portfolio/index' => 'examples/portfolio/views/index.sp',
    'portfolio/account' => 'examples/portfolio/views/account.sp',
    'portfolio/partials/account_card' => 'examples/portfolio/views/partials/account_card.sp',
    'dashboard/triage' => 'examples/dashboard/views/triage.sp',
    'dashboard/confirm_archive' => 'examples/dashboard/views/confirm_archive.sp',
    'dashboard/partials/queue' => 'examples/dashboard/views/partials/queue.sp',
    'dashboard/partials/unreviewed_card' => 'examples/dashboard/views/partials/unreviewed_card.sp',
    'roth/controls' => 'examples/roth/views/controls.sp',
    'roth/partials/report' => 'examples/roth/views/partials/report.sp',
    'lore_reader/index' => 'examples/lore_reader/views/index.sp',
    'lore_reader/entry' => 'examples/lore_reader/views/entry.sp',
    'lore_reader/partials/lore_card' => 'examples/lore_reader/views/partials/lore_card.sp',
    'way_exam/index' => 'examples/way_exam/views/index.sp',
    'way_exam/results' => 'examples/way_exam/views/results.sp',
    'way_exam/partials/question_card' => 'examples/way_exam/views/partials/question_card.sp',
    'milestone_planner/index' => 'examples/milestone_planner/views/index.sp',
    'milestone_planner/milestone' => 'examples/milestone_planner/views/milestone.sp',
    'milestone_planner/partials/milestone_card' => 'examples/milestone_planner/views/partials/milestone_card.sp',
    'milestone_planner/partials/task_card' => 'examples/milestone_planner/views/partials/task_card.sp'
  }.merge(ui_pages.to_h.transform_values(&:freeze)).freeze



  # The playground's own locals — one home, used by the routes and by the
  # census, so a verdict and the real render can never drift apart. `data`
  # is the writer's JSON payload, parsed and bound as the page's locals —
  # the data wall, landed at app level: plain hashes and arrays, no kernel
  # motion.
  def self.playground_locals(data = nil)
    { docs: StudioDocs.build }.merge(data_locals(data))
  end

  # The writer's data, as locals. Empty means no data; anything else must
  # parse as JSON, and a refusal to parse speaks the language's own terms —
  # every playground refusal speaks the same voice.
  def self.data_locals(data)
    text = data.to_s.strip
    return {} if text.empty?

    JSON.parse(text)
  rescue JSON::ParserError => e
    raise SlimPickins::Error,
          "the data does not parse as JSON — #{e.message.lines.first.strip}"
  end

  # The census, run the way the playground will run the page: the
  # playground's merged library, the playground's locals — **and the page's own
  # payload**, because that is what loading it gives you (2026-09-17, W1).
  # Before this, the census measured the empty-data render while the load
  # pre-filled the ledger, so all 18 entries wore `error` and all 18 rendered:
  # the badge described a state no visitor ever saw. A refusal is the page
  # naming a wall in the language's own voice; an error outside the language
  # says so.
  # The locals the *load* gives a page — one home, used by the census, the
  # route and the gate, so a verdict can never describe a render nobody gets.
  #
  # A UI's own page is answered directly: its canned locals carry real objects
  # (a `StudioStatus::Result` answers `state` and `fenced`; a parsed hash would
  # not), and the route hands over the same objects. Every other page takes the
  # JSON slot, because that is exactly what the playground gives it.
  def self.load_locals(rel)
    return ui_locals(File.basename(rel, '.sp')) if rel.start_with?('studio/uis/')

    playground_locals(data_json_for(rel))
  end

  # `library` is what a *UI's own* page renders with — its frame, its partials.
  # `pages_library` is what a *loaded* page renders with: the sandbox, with no
  # UI's layout. The distinction is the whole reason a palette page cannot be
  # rendered inside the workbench's chrome, and it was invisible until the
  # census started measuring the load — every entry went red with "this
  # specimen has no word_count", which is a frame asking a page for its own
  # locals.
  def self.entries(library:, loaded: nil, paths: nil, ui: nil, pages_library: nil)
    paths ||= Uis.default_ui
    # A UI's shelf lists *its own* pages: another UI's page cannot render
    # against this one's partials, and offering it would be a link to a
    # refusal. The repo's pages and the examples belong to every shelf.
    pages = PAGES.reject do |id, _|
      id.start_with?('studio/') && ui && !id.start_with?("studio/#{ui.name}/")
    end
    pages.map do |id, rel|
      # A UI's own page renders with that UI's library; a *loaded* page renders
      # with the sandbox, which carries no UI's layout — because that is what
      # the load gives it. Measuring a loaded page inside the workbench's frame
      # is how every entry went red asking a specimen for `words_count`.
      engine = rel.start_with?('studio/uis/') ? library : (pages_library || library)
      status, refusal =
        begin
          SlimPickins.render(File.read(File.join(ROOT, rel)), path: rel,
                             locals: load_locals(rel), library: engine)
          ['ok', nil]
        rescue SlimPickins::Error => e
          ['error', e.message]
        rescue StandardError => e
          ['error', "#{e.class}: #{e.message}"]
        end
      Entry.new(id: id, name: "#{id}.sp", path: rel, load_path: paths.paths[:load],                status: status, refusal: refusal, here: id == loaded)
    end
  end

  # The source behind a palette id — the palette's ids, never a raw path, so
  # a load parameter cannot read anything PAGES did not already name. A UI's
  # own page is refused when the UI serving the request is not the one the id
  # names: the palette lists every UI's pages, and loading another UI's page
  # into this workbench would render it against the wrong library.
  def self.source_for(id, ui: Uis.default_ui)
    rel = PAGES[id]
    return nil unless rel
    return nil if id.to_s.start_with?('studio/') && !id.to_s.start_with?("studio/#{ui.name}/")

    File.read(File.join(ROOT, rel))
  end

  # The editor's heading: the page being edited, or the invitation.
  def self.title_for(id)
    PAGES.key?(id) ? "Editing: #{PAGES[id]}" : 'Write .sp Code'
  end

  # --- the playground's library: the partial wall, landed -------------------

  # The studio's own furniture plus every example app's partials, merged —
  # a loaded page and its data now render end-to-end. A name shared by two
  # apps refuses loudly here rather than rendering one app's word in
  # another's place. pages/partials is included: its test_account_card is a
  # real partial — account_detail renders it — whatever else uses it.
  #
  # The sandbox library: the repo's pages, the shared furniture and the
  # example apps' partials — but *no UI's* partials, because a UI's fragments
  # are its own. This is the library the playground renders a writer's source
  # against, and a UI's own library is this one plus that UI's directory.
  #
  # Several UIs means several `editor` fragments, quite legitimately: two UIs
  # are two designs, and a shared name across them is not an alias problem,
  # it is the point. What must not happen is one UI's page rendering against
  # another UI's partials, which is why the merge is per UI and the refusal
  # below still fires for the two cases that *are* ambiguity: one name from
  # two example apps, or two words in one library.
  def self.library_dirs = [
    File.join(ROOT, 'pages'),
    File.join(ROOT, 'studio', 'shared'),
    File.join(ROOT, 'examples', 'portfolio', 'views'),
    File.join(ROOT, 'examples', 'dashboard', 'views'),
    File.join(ROOT, 'examples', 'roth', 'views'),
    File.join(ROOT, 'examples', 'lore_reader', 'views'),
    File.join(ROOT, 'examples', 'way_exam', 'views'),
    File.join(ROOT, 'examples', 'milestone_planner', 'views')
  ].freeze



  def self.library
    @library ||= merge_libraries(library_dirs, words: [AppWords, *Uis.all.map(&:words)])
  end

  # The merge, its own seam so the collision refusal is testable: two apps
  # naming the same partial would otherwise render one app's word in
  # another's place, silently.
  def self.merge_libraries(dirs, words: nil, layout: nil)
    partials = {}
    partial_paths = {}
    dirs.each do |dir|
      Dir[File.join(dir, 'partials', '*.sp')].each do |path|
        name = File.basename(path, '.sp').to_sym
        if partials.key?(name)
          raise SlimPickins::Error,
                "`#{name}` is a partial in two apps — the playground refuses to guess which one a page means"
        end

        partials[name] = File.read(path)
        partial_paths[name] = path
      end
    end
    SlimPickins::Library.new(layout: layout, partials: partials, partial_paths: partial_paths, words: words)
  end

  # A UI's own library: its layout (so `page` infers the frame), its partials,
  # the shared furniture, the example apps' partials so a loaded page renders
  # end-to-end, and every UI's words. Built per UI because the layout is part
  # of the library — the page word wraps itself in it — so a UI's frame cannot
  # be borrowed from another UI by accident.
  #
  # The layout sits at the UI's *root*, not in `views/`: `Library.from` reads a
  # directory's `layout.sp` beside its `partials/`, and a UI's views are one
  # level down, so the frame is read here rather than left to be missed. A
  # missing layout is silent — the pages simply render unframed — which is how
  # this cost a round.
  def self.ui_library(ui)
    layout_path = File.join(ui.dir, 'layout.sp')
    merge_libraries([*library_dirs, ui.views],
                    words: [AppWords, *Uis.all.map(&:words)],
                    layout: (File.read(layout_path) if File.exist?(layout_path)))
  end

  # --- the data ledger: what the playground pre-fills ------------------------

  # What a UI's own page needs, canned: its frame's locals and the page's
  # answer. Used by the census and by `bin/verify_pages.rb`, so a UI page is
  # measured by the same shape in both — the drift this replaces was two
  # copies of the same canned payload, one of which had gone stale.
  #
  # The shelf is two canned entries rather than the real census: a UI page
  # rendered *by* the census cannot take the census again without recursing.
  def self.ui_locals(page)
    base = {
      docs: StudioDocs.build,
      words: StudioDocs.words,
      guides: StudioDocs.guides,
      palette: [Entry.new(id: 'pages/specimen', name: 'pages/specimen.sp', path: 'pages/specimen.sp',
                          load_path: '/?load=:id&ui=:ui', status: 'ok', refusal: nil, here: false)],
      ui_names: Uis.all.map { |u| { name: u.name, title: u.title, current: u.name == Uis.default } },
      ui: Uis.default,
      word_count: 64, convention_count: 38, promise_count: 32, measured: '2026-09-17',
      words_count: 64, pages_count: PAGES.size
    }
    case page
    when 'index'
      base.merge(title: 'Studio', source: "page \"Studio\"\n  heading \"Hello\"\n",
                 editor_title: 'Write .sp Code', data: '', loaded: nil,
                 data_note: StudioDocs::DATA_NOTE)
    when 'docs'
      base.merge(title: 'Docs: badge', contract: 'No contract.',
                 implementation: 'No implementation.', examples: [],
                 source: "page \"Try: badge\"\n", editor_title: 'Try it: badge',
                 data: '', data_note: StudioDocs::DATA_NOTE)
    when 'guide'
      base.merge(title: 'Guide: PRIMER', content: 'A **guide** page.')
    else
      # `StudioStatus.canned` builds real `Result`s: the page asks each for
      # `name`, `state` and `fenced`, so a plain hash would not answer — and
      # inventing a second shape here is the drift this method exists to stop.
      base.merge(title: 'Status', **StudioStatus.canned_locals)
    end
  end

  # The dashboard's stable first queue item — dan's ruling (2026-09-15): the
  # docs teach a stable shape, so the sandbox answers with a sample rather
  # than the live Scan.triage_queue. The card it renders is held by the
  # ledger's render test. The base is the app's own prove! scaffolding.
  SAMPLE_FIRST_ITEM = {
    'path' => '/triage/example', 'status_variant' => 'warning',
    'status' => 'needs review', 'purpose' => 'A page waiting for its ruling.',
    'next_line' => nil, 'offer_commit' => false
  }.freeze

  DASHBOARD_BASE = { q: '', error_entry: nil,
                     nav_state: { 'studio' => false, 'library' => false,
                                  'reconcile' => false, 'dispatch' => false,
                                  'ports' => false } }.freeze

  # The data ledger: what the playground pre-fills for a corpus page — the
  # same locals the page's own app proves it with. One provider per page,
  # and the ledger's render test holds every provider to its promise: the
  # pre-filled data renders the page. Pages with no entry have no payload,
  # and that is itself a true answer, not a crash.
  def self.data_for(rel)
    case rel
    when 'pages/portfolio_table.sp', 'pages/specimen.sp',
         'pages/account_detail.sp', 'pages/roth_form.sp'
      Fixtures.for(File.basename(rel, '.sp')) || {}
    when 'examples/portfolio/views/index.sp'
      { portfolio: Fixtures.portfolio }
    when 'examples/portfolio/views/account.sp'
      { account: Fixtures.portfolio.accounts.last }
    when 'examples/portfolio/views/partials/account_card.sp',
         'pages/partials/test_account_card.sp'
      # Rendered standalone, the card's subject is the page — so the
      # account's own fields are the locals, not a wrapper around them.
      Fixtures.portfolio.accounts.last.to_h
    # Every UI's own pages answer the same canned locals: a UI added tomorrow
    # joins the census without a provider of its own, which is what keeps the
    # census complete rather than merely long. The studio's pages are each
    # UI's own sandbox, so one provider answers them all.
    #
    # The payload is plain — strings, arrays, nil — because it round-trips
    # through JSON before the page sees it. `docs` is deliberately *not* here:
    # it is an OpenStruct the render path supplies, and `plainify` would turn
    # it into nil and take the whole payload down with it.
    # A UI's own pages answer the locals that UI's frame draws on: the shelf
    # (a canned pair of entries, so the census does not recurse into the census
    # it is taking), the vocabulary and the guides, and the vitals. One home
    # for these, because the census and the gate both render UI pages and a
    # second copy is where the two would drift.
    when %r{\Astudio/uis/(?<ui>[a-z]+)/views/(?<page>[a-z_]+)\.sp\z}
      ui_locals(Regexp.last_match(:page))
    when 'examples/roth/views/controls.sp', 'examples/roth/views/partials/report.sp'
      roth_locals
    when 'examples/dashboard/views/triage.sp'
      DASHBOARD_BASE.merge(notice: 'A page waiting for its ruling.', unreviewed: nil,
                           first_item: SAMPLE_FIRST_ITEM,
                           queue_intro: 'One item needs attention — this is the first:')
    when 'examples/dashboard/views/partials/queue.sp'
      DASHBOARD_BASE.merge(first_item: SAMPLE_FIRST_ITEM,
                           queue_intro: 'One item needs attention — this is the first:')
    when 'examples/dashboard/views/partials/unreviewed_card.sp'
      DASHBOARD_BASE.merge(unreviewed: '1 instruction file awaiting judgment — hand-kept rules ' \
                                       'nobody has ruled canonical or legacy.')
    when 'examples/dashboard/views/confirm_archive.sp'
      DASHBOARD_BASE.merge(archive_heading: 'Archive "example"?', archive_path: 'example',
                           archive_return_to: '/triage', reason: '')
    when 'examples/lore_reader/views/index.sp'
      lore = LoreReader::Lore.load
      { 'stats' => lore.stats, 'entries' => lore.all.first(5).map(&:to_h), 'q' => '' }
    when 'examples/lore_reader/views/entry.sp'
      lore = LoreReader::Lore.load
      { 'entry' => lore.all.first.to_h }
    when 'examples/lore_reader/views/partials/lore_card.sp'
      lore = LoreReader::Lore.load
      entry = lore.all.first.to_h
      entry.merge('entry' => entry)
    when 'examples/way_exam/views/index.sp'
      { 'overview' => { 'questions_count' => 5, 'passing_score' => '80%' },
        'q1' => nil, 'q2' => nil, 'q3' => nil, 'q4' => nil, 'q5' => nil }
    when 'examples/way_exam/views/results.sp'
      result = WayExam::Exam.grade(WayExam::Exam.sample_answers)
      { 'result' => result.to_h, 'reviews' => result.reviews.map(&:to_h) }
    when 'examples/way_exam/views/partials/question_card.sp'
      result = WayExam::Exam.grade(WayExam::Exam.sample_answers)
      result.reviews.first.to_h
    when 'examples/milestone_planner/views/index.sp'
      planner = MilestonePlanner::Planner.new
      { 'stats' => planner.stats, 'milestones' => planner.all.map(&:to_h) }
    when 'examples/milestone_planner/views/milestone.sp'
      planner = MilestonePlanner::Planner.new
      m = planner.find('m1')
      m.to_h.merge('milestone' => m.to_h, 'title' => '', 'owner' => 'dan', 'tasks' => m.tasks.map(&:to_h))
    when 'examples/milestone_planner/views/partials/milestone_card.sp'
      planner = MilestonePlanner::Planner.new
      m = planner.find('m1').to_h
      m.merge('milestone' => m)
    when 'examples/milestone_planner/views/partials/task_card.sp'
      planner = MilestonePlanner::Planner.new
      t = planner.find('m1').tasks.first.to_h
      t.merge('task' => t)
    else
      {}
    end


  end

  # roth's payload, serialized field by field: Scenario's values are the
  # form's inputs, and the projection answers the report's named figures.
  # `Projection#to_h` is roth's JSON-endpoint shape, not the page's — so
  # the fields are named here, and the ledger's render test holds them.
  def self.roth_locals
    scenario = Roth::Scenario.defaults
    projection = Roth::Projection.of(scenario)
    { scenario: scenario.instance_variable_get(:@values),
      projection: {
        'lifetime_taxes_primary' => projection.lifetime_taxes_primary,
        'lifetime_taxes_baseline' => projection.lifetime_taxes_baseline,
        'tax_delta' => projection.tax_delta,
        'final_roth_primary' => projection.final_roth_primary,
        'final_roth_baseline' => projection.final_roth_baseline,
        'roth_delta' => projection.roth_delta,
        'years' => projection.years.map(&:to_h),
        'baseline_years' => projection.baseline_years.map(&:to_h),
        'standard_deduction' => projection.standard_deduction,
        'brackets' => projection.brackets.map(&:to_h),
        'complaints' => projection.complaints.map(&:description),
        'defects' => projection.defects.map(&:to_h)
      } }
  end

  # A payload's plain shape: Structs become hashes, dates their iso8601,
  # keys their strings — the JSON the data slot parses back into the same
  # locals. Anything with no plain shape becomes nothing rather than a
  # disguise.
  # A value as plain data, for the JSON slot. Every branch that can be
  # serialized is named; an unnameable value is a defect in the ledger, not
  # something to launder into `nil` — nil used to take the *whole* payload
  # down with it, because `JSON.pretty_generate` then raised and the rescue
  # returned an empty string. A page would report "this page has no title"
  # while its provider sat right there with the title in it.
  def self.plainify(value)
    case value
    when Hash then value.to_h { |k, v| [k.to_s, plainify(v)] }
    when Array then value.map { |v| plainify(v) }
    when Struct then plainify(value.to_h)
    when Date, Time then value.iso8601
    when Symbol then value.to_s
    when String, Numeric, TrueClass, FalseClass, NilClass then value
    else
      # An OpenStruct, or anything else that answers `to_h` — the docs payload
      # is one, and it rides in the ledger's canned answers.
      if value.respond_to?(:to_h)
        plainify(value.to_h)
      else
        raise ArgumentError, "#{value.class} is not plain data — the ledger must name a shape JSON can carry"
      end
    end
  end

  # The data slot's pre-fill for a page: its ledger payload, as pretty
  # JSON — or, for a page with no ledger entry, the chain refs its context
  # reads answered with plain defaults (the example carries a note that the
  # values are synthetic) — or nothing, where both are empty. A payload
  # that cannot be serialized is a ledger defect the render test catches;
  # the route itself never crashes on it.
  def self.data_json_for(rel, chain = nil)
    data = data_for(rel)
    data = synthesized_for(chain) if data.empty? && chain
    return '' if data.empty?

    JSON.pretty_generate(plainify(data))
  rescue StandardError
    ''
  end

  # A page with no ledger entry still owes the try-it a payload: the chain
  # refs its context reads, answered with plain defaults — the word
  # demonstrates, and the example's note says the values are synthetic.
  SYNTH_DEFAULTS = {
    name: nil, content: 'Hello world', label: 'A label', open: true,
    q: '', title: 'A title', where: 'a place', body: 'A body',
    notice: nil, unreviewed: nil, first_item: nil, placeholder: 'Search',
    nav_state: { 'studio' => false, 'library' => false, 'reconcile' => false,
                 'dispatch' => false, 'ports' => false }
  }.freeze

  def self.synthesized_for(chain)
    refs = []
    chain.each { |node| refs.concat(refs_of(node)) }
    walk = lambda do |nodes|
      nodes.each do |node|
        refs.concat(refs_of(node))
        walk.call(node.children)
      end
    end
    walk.call(chain.last.children) if chain.last
    found = refs.uniq.to_h { |ref| [ref.to_sym, SYNTH_DEFAULTS.fetch(ref.to_sym, 'a value')] }
    SYNTH_DEFAULTS.merge(found).transform_keys(&:to_s)
  end

  # The chain refs a sentence reads — `.total_value`, `id: .id`, anywhere
  # in the args; the first segment is the data key. `guard` is included
  # because `if:` no longer travels in the arguments: the transform hoists it
  # into a guard, so a guarded sentence's predicate is still a local the page
  # has to be given, and the synthesized payload must carry it.
  def self.refs_of(node)
    args = node.raw_args.dup
    args << node.guard if node.respond_to?(:guard) && node.guard
    args.flat_map { |arg| arg.scan(/\.([a-z_]+)/).flatten }.uniq
  end

  # --- the render contract --------------------------------------------------

  # A playground error, rendered through the language — the same voice
  # everywhere else in the language speaks. The complaint is the error's
  # own first line; the location and the sentence join it when the error
  # knows them. The final string exists only for the refusal page failing,
  # which must not be able to break the studio.
  def self.refusal(error, library: nil)
    complaint, where, line =
      if error.is_a?(SlimPickins::Error)
        [error.message.lines.first.strip,
         error.located? ? "#{error.path}, line #{error.lineno}" : nil,
         error.line]
      else
        ["#{error.class}: #{error.message.lines.first.strip}", nil, nil]
      end
    SlimPickins.render(File.read(File.join(ROOT, 'studio', 'shared', 'refusal.sp')),
                       path: 'refusal.sp',
                       locals: { title: 'Refusal', complaint: complaint, where: where, line: line },
                       library: library || self.library)
  rescue StandardError
    "<div style='color: red; padding: 1rem;'><strong>Error:</strong> #{CGI.escapeHTML(error.message)}</div>"
  end

  # The studio's render contract — one response, both panes. The visual is
  # the rendered page (a refusal is still a page); the source is the raw-
  # HTML pane's own page: the same output escaped, kept tidy by the
  # pre-wrap monospace the pane has always worn. This is the client API
  # the controller grows against: a future pane joins as a key, not a
  # change.
  def self.render_json(source, data = nil, library: nil)
    library ||= StudioPages.library
    visual = begin
      SlimPickins.render(source, path: 'playground.sp',
                         locals: playground_locals(data), library: library)
    rescue StandardError => e
      refusal(e, library: library)
    end
    { visual: visual, source: raw_page(visual) }
  end

  def self.raw_page(html)
    "<!DOCTYPE html><html><head><style>body { font-family: monospace; white-space: pre-wrap; padding: 1rem; }</style></head><body>#{CGI.escapeHTML(html)}</body></html>"
  end
end
