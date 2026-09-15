# frozen_string_literal: true

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
  # guides.
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

  # The playground's own locals — one home, used by the route and by the
  # census, so a verdict and the real render can never drift apart.
  def self.playground_locals = { docs: StudioDocs.build }

  # The census, run the way the playground will run the page: the studio's
  # library, the playground's locals. A refusal is the page naming a wall in
  # the language's own voice; an error outside the language says so.
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
end
