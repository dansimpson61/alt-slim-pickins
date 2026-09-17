# frozen_string_literal: true

require 'json'
require 'cgi'
require_relative '../lib/slim_pickins'
require_relative 'docs_helper'
require_relative 'words'
# The sandbox: the example apps' own files, required rather than copied —
# their boot gates prove the pages with the same locals the ledger serves.
require_relative '../test/fixtures'
require_relative '../examples/portfolio/app'
require_relative '../examples/roth/app'

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
    'studio/index' => 'studio/views/index.sp',
    'studio/docs' => 'studio/views/docs.sp',
    'studio/guide' => 'studio/views/guide.sp',
    'studio/status' => 'studio/views/status.sp'
  }.freeze

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
  # playground's merged library, the playground's locals. A refusal is the
  # page naming a wall in the language's own voice; an error outside the
  # language says so.
  def self.entries(library:, loaded: nil)
    PAGES.map do |id, rel|
      status, refusal =
        begin
          SlimPickins.render(File.read(File.join(ROOT, rel)), path: rel,
                             locals: playground_locals, library: library)
          ['ok', nil]
        rescue SlimPickins::Error => e
          ['error', e.message]
        rescue StandardError => e
          ['error', "#{e.class}: #{e.message}"]
        end
      Entry.new(id: id, name: "#{id}.sp", path: rel, load_path: "/?load=#{id}",
                status: status, refusal: refusal, here: id == loaded)
    end
  end

  # The source behind a palette id — the palette's ids, never a raw path, so
  # a load parameter cannot read anything PAGES did not already name.
  def self.source_for(id)
    rel = PAGES[id]
    rel && File.read(File.join(ROOT, rel))
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
  PLAYGROUND_LIBRARY_DIRS = [
    File.join(ROOT, 'pages'),
    File.join(ROOT, 'studio', 'views'),
    File.join(ROOT, 'examples', 'portfolio', 'views'),
    File.join(ROOT, 'examples', 'dashboard', 'views'),
    File.join(ROOT, 'examples', 'roth', 'views')
  ].freeze

  def self.library
    # AppWords is portfolio's own vocabulary — `video` — StudioWords the
    # studio's own — `wired_form` — and the merged library carries both the
    # same way the apps' own libraries do.
    @library ||= merge_libraries(PLAYGROUND_LIBRARY_DIRS, words: [AppWords, StudioWords])
  end

  # The merge, its own seam so the collision refusal is testable: two apps
  # naming the same partial would otherwise render one app's word in
  # another's place, silently.
  def self.merge_libraries(dirs, words: nil)
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
    SlimPickins::Library.new(partials: partials, partial_paths: partial_paths, words: words)
  end

  # --- the data ledger: what the playground pre-fills ------------------------

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
    when 'studio/views/index.sp'
      { source: "page \"Studio\"\n  heading \"Hello\"\n", palette: [],
        editor_title: 'Write .sp Code', data: '', words: [], guides: [] }
    when 'studio/views/docs.sp'
      { title: 'A word', contract: 'No contract.', implementation: 'No implementation.',
        examples: [], source: "page \"A word\"\n", editor_title: 'Try it: word',
        data: '', data_note: StudioDocs::DATA_NOTE, words: [], guides: [] }
    when 'studio/views/guide.sp'
      { title: 'A guide', content: 'A **guide** page.', words: [], guides: [] }
    when 'studio/views/status.sp'
      { title: 'Status', overview: 'All legs green.', results: [], words: [], guides: [] }
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
  def self.plainify(value)
    case value
    when Hash then value.to_h { |k, v| [k.to_s, plainify(v)] }
    when Array then value.map { |v| plainify(v) }
    when Struct then plainify(value.to_h)
    when Date, Time then value.iso8601
    when String, Numeric, TrueClass, FalseClass, NilClass then value
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
  def self.refusal(error)
    complaint, where, line =
      if error.is_a?(SlimPickins::Error)
        [error.message.lines.first.strip,
         error.located? ? "#{error.path}, line #{error.lineno}" : nil,
         error.line]
      else
        ["#{error.class}: #{error.message.lines.first.strip}", nil, nil]
      end
    SlimPickins.render(File.read(File.join(ROOT, 'studio', 'views', 'refusal.sp')),
                       path: 'refusal.sp',
                       locals: { title: 'Refusal', complaint: complaint, where: where, line: line },
                       library: library)
  rescue StandardError
    "<div style='color: red; padding: 1rem;'><strong>Error:</strong> #{CGI.escapeHTML(error.message)}</div>"
  end

  # The studio's render contract — one response, both panes. The visual is
  # the rendered page (a refusal is still a page); the source is the raw-
  # HTML pane's own page: the same output escaped, kept tidy by the
  # pre-wrap monospace the pane has always worn. This is the client API
  # the controller grows against: a future pane joins as a key, not a
  # change.
  def self.render_json(source, data = nil)
    visual = begin
      SlimPickins.render(source, path: 'playground.sp',
                         locals: playground_locals(data), library: library)
    rescue StandardError => e
      refusal(e)
    end
    { visual: visual, source: raw_page(visual) }
  end

  def self.raw_page(html)
    "<!DOCTYPE html><html><head><style>body { font-family: monospace; white-space: pre-wrap; padding: 1rem; }</style></head><body>#{CGI.escapeHTML(html)}</body></html>"
  end
end
