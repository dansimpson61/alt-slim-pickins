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

require '/home/dan/dev/dashboard/lib/workspace'
require '/home/dan/dev/dashboard/lib/scan'

repo = SlimPickins::Library.from(File.expand_path('../pages', __dir__))
portfolio = SlimPickins::Library.from(File.expand_path('../examples/portfolio/views', __dir__),
                                      words: AppWords)
roth = SlimPickins::Library.from(File.expand_path('../examples/roth/views', __dir__))
dashboard = SlimPickins::Library.from(File.expand_path('../examples/dashboard/views', __dir__))
scenario = Roth::Scenario.defaults
projection = Roth::Projection.of(scenario)

# Every page, and how its app answers it — the corpus the gate will prove at
# boot. A page is a label, the library it renders with, and the locals its
# app would give it.
dashboard_base = { notice: nil, q: '', error_entry: nil,
                   nav_state: { studio: false, library: false, reconcile: false,
                          dispatch: false, ports: false } }.freeze
PAGES = [
  *%w[portfolio portfolio_table account_detail content figures roth_form specimen].map do |name|
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
                        archive_return_to: '/triage', reason: '')]
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
