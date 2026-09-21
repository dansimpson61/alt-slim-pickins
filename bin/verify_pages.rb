#!/usr/bin/env ruby
# frozen_string_literal: true

# The payload's report: evaluate every page the repo and both apps can
# answer, and say which ones the app has proved able to answer. The static
# half — the word contracts — is check_grammar's; this is the evaluation
# half, the one the grammar cannot see: every subject resolvable, every
# attribute answered, against the data the app would actually serve.
#
# A page that fails is reported, not skipped, and the report names the
# failure the way the language does — path, line, sentence. Exits non-zero
# on any problem, so it can gate a commit.

require_relative '../lib/slim_pickins'
require_relative '../test/fixtures'
require_relative '../examples/portfolio/app'
require_relative '../examples/roth/app'
require_relative '../studio/docs_helper'
require_relative '../studio/pages'
require_relative '../studio/status'
require_relative '../studio/uis'

require '/home/dan/dev/dashboard/lib/workspace'
require '/home/dan/dev/dashboard/lib/scan'

repo = SlimPickins::Library.from(File.expand_path('../pages', __dir__))
portfolio = SlimPickins::Library.from(File.expand_path('../examples/portfolio/views', __dir__),
                                      words: AppWords)
roth = SlimPickins::Library.from(File.expand_path('../examples/roth/views', __dir__))
dashboard = SlimPickins::Library.from(File.expand_path('../examples/dashboard/views', __dir__))
lore_reader = SlimPickins::Library.from(File.expand_path('../examples/lore_reader/views', __dir__))
lore = LoreReader::Lore.load
lore_sample = lore.all.first
way_exam = SlimPickins::Library.from(File.expand_path('../examples/way_exam/views', __dir__))
way_result = WayExam::Exam.grade(WayExam::Exam.sample_answers)
milestone_planner = SlimPickins::Library.from(File.expand_path('../examples/milestone_planner/views', __dir__))
planner = MilestonePlanner::Planner.new
m1_sample = planner.find('m1')
word_graph = SlimPickins::Library.from(File.expand_path('../examples/word_graph/views', __dir__))
graph = WordGraph::Graph.instance
w_sample = graph.find('table')
w_peers = graph.by_shape(w_sample.shape).reject { |w| w.name == w_sample.name }
w_parents = w_sample.explicit_parents.map { |p| graph.find(p) }.compact
w_children = w_sample.explicit_children.map { |c| graph.find(c) }.compact
studio = StudioPages.ui_library(Uis['classic'])



scenario = Roth::Scenario.defaults
projection = Roth::Projection.of(scenario)

# Every page, and how its app answers it — the corpus the gate will prove at
# boot. A page is a label, the library it renders with, and the locals its
# app would give it.
dashboard_base = { notice: nil, q: '', error_entry: nil,
                   nav_state: { studio: false, library: false, reconcile: false,
                          dispatch: false, ports: false } }.freeze

# The studio's own pages — the found gap, closed: they were the only corpus
# pages this gate never rendered. `/status` is the one exception in shape:
# its route shells this very gate, so proving it with live results would
# recurse — it renders against the canned shape `StudioStatus.canned_locals`
# holds (one home, shared with `studio_docs_test`), and the recursion hazard is
# named here.
#
# Each UI's pages are verified against *that UI's* library, because a UI's
# page needs its own partials: the census in `pages.rb` holds the same fact
# from the other side. A UI added tomorrow is verified the day it arrives —
# the list comes from the registry, not from here.
def ui_locals(ui)
  base = { docs: StudioDocs.build,
           palette: StudioPages.entries(library: StudioPages.ui_library(ui), paths: ui, ui: ui),
           words: StudioDocs.words(ui), guides: StudioDocs.guides(ui),
           ui_names: Uis.all.map { |u| { name: u.name, title: u.title, current: u.name == ui.name } },
           ui: ui.name, word_count: 64, convention_count: 38, promise_count: 32,
           measured: '2026-09-17', data_note: StudioDocs::DATA_NOTE,
           words_count: 64, pages_count: StudioPages::PAGES.size }
  {
    'index.sp' => base.merge(title: 'Workbench',
                             source: "page \"Slim-Pickins Studio\"\n  heading \"Hello World\"\n",
                             editor_title: 'Write .sp Code', data: '', loaded: nil),
    'docs.sp' => base.merge(title: 'Docs: badge', contract: 'No contract.',
                            implementation: 'No implementation.', examples: [],
                            source: "page \"Try: badge\"\n", editor_title: 'Try it: badge',
                            data: ''),
    'guide.sp' => base.merge(title: 'Guide: PRIMER', content: 'A **guide** page.'),
    'status.sp' => base.merge(title: 'Status', **StudioStatus.canned_locals)
  }
end

STUDIO_PAGES = Uis.all.flat_map do |ui|
  locals = ui_locals(ui)
  locals.map do |view, canned|
    ["#{ui.views.sub("#{File.expand_path('..', __dir__)}/", '')}/#{view}",
     StudioPages.ui_library(ui), canned]
  end
end.freeze

PAGES = [
  *%w[portfolio_table account_detail roth_form specimen].map do |name|
    ["pages/#{name}.sp", repo, Fixtures.for(name)]
  end,
  ['examples/portfolio/views/index.sp', portfolio, { portfolio: Fixtures.portfolio }],
  ['examples/portfolio/views/account.sp', portfolio, { account: Fixtures.portfolio.accounts.last }],
  ['examples/roth/views/controls.sp', roth, { scenario: scenario, projection: projection }],
  ['examples/roth/views/partials/report.sp', roth, { scenario: scenario, projection: projection }],
  ['examples/dashboard/views/triage.sp', dashboard,
   dashboard_base.merge(first_item: nil, queue_intro: '', unreviewed: nil)],
  ['examples/dashboard/views/confirm_archive.sp', dashboard,
   dashboard_base.merge(archive_heading: 'Archive "example"?', archive_path: 'example',
                        archive_return_to: '/triage', reason: '')],
  ['examples/lore_reader/views/index.sp', lore_reader,
   { lore: lore, entries: lore.all.first(5), stats: lore.stats, q: '', current_author: '' }],
  ['examples/lore_reader/views/entry.sp', lore_reader,
   { entry: lore_sample }],
  ['examples/way_exam/views/index.sp', way_exam,
   { overview: { questions_count: 5, passing_score: '80%' },
     q1: nil, q2: nil, q3: nil, q4: nil, q5: nil }],
  ['examples/way_exam/views/results.sp', way_exam,
   { result: way_result, reviews: way_result.reviews }],
  ['examples/milestone_planner/views/index.sp', milestone_planner,
   { stats: planner.stats, milestones: planner.all }],
  ['examples/milestone_planner/views/milestone.sp', milestone_planner,
   { milestone: m1_sample, tasks: m1_sample.tasks, title: nil, owner: :dan }.merge(m1_sample.to_h)],
  ['examples/word_graph/views/index.sp', word_graph,
   { words: graph.all, q: '' }.merge(graph.stats)],
  ['examples/word_graph/views/word.sp', word_graph,
   { word: w_sample, parents: w_parents, children: w_children, peers: w_peers }.merge(w_sample.to_h)],
  ['examples/word_graph/views/shapes.sp', word_graph,
   { shapes: graph.shapes }],
  ['examples/word_graph/views/matrix.sp', word_graph,
   { words: graph.all }],
  *STUDIO_PAGES
].freeze



problems = 0

PAGES.each do |label, library, locals|
  begin
    SlimPickins.render(File.read(File.expand_path("../#{label}", __dir__)),
                       path: label, locals: locals, library: library)
    puts "  OK            #{label}"
  rescue SlimPickins::Error => e
    # The error speaks the language — path, line, sentence — so it is printed
    # verbatim under the page it belongs to.
    problems += 1
    puts "  BAD ANSWER    #{label}"
    puts e.message
  rescue StandardError => e
    # Not a language error: the app's own Ruby broke. That is itself the
    # finding, and saying so keeps the language's strongest claim intact.
    problems += 1
    puts "  RUBY ERROR    #{label}"
    puts "  #{e.class}: #{e.message}"
  end
end

puts "\n#{PAGES.size} pages verified, #{problems} problems"
exit(problems.zero? ? 0 : 1)
