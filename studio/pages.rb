# frozen_string_literal: true

require 'json'
require_relative '../lib/slim_pickins'
require_relative 'docs_helper'

# The palette: the repo's own real pages, offered to the playground as
# starting points, each carrying its census verdict — the same render the
# playground will give it, run when the palette is built. `ok` means the page
# renders with the playground's locals and the studio's library; `error`
# means it named a wall, and the refusal is recorded verbatim, the way the
# language said it. The palette is curated for order and complete by test:
# every `.sp` under examples/ (a layout is chrome, not a page) and the
# studio's own top-level views is in it, because a census that skips pages
# understates the demand.
module StudioPages
  ROOT = File.expand_path('..', __dir__)

  Entry = Struct.new(:id, :name, :path, :load_path, :status, :refusal, :here,
                     keyword_init: true)

  # Ordered by app — an app's pages before its partials, the studio last —
  # because the order is part of the argument, exactly as it is for the
  # guides. A layout and the refusal template are chrome, not pages, so they
  # are not here.
  PAGES = {
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
  # another's place. `pages/partials` is excluded: its one file is the cost
  # instrument's fixture, not a page's partial.
  PLAYGROUND_LIBRARY_DIRS = [
    File.join(ROOT, 'studio', 'views'),
    File.join(ROOT, 'examples', 'portfolio', 'views'),
    File.join(ROOT, 'examples', 'dashboard', 'views'),
    File.join(ROOT, 'examples', 'roth', 'views')
  ].freeze

  def self.library
    @library ||= merge_libraries(PLAYGROUND_LIBRARY_DIRS)
  end

  # The merge, its own seam so the collision refusal is testable: two apps
  # naming the same partial would otherwise render one app's word in
  # another's place, silently.
  def self.merge_libraries(dirs)
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
    SlimPickins::Library.new(partials: partials, partial_paths: partial_paths)
  end
end
