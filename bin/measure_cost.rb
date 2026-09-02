#!/usr/bin/env ruby
# frozen_string_literal: true

# The payload's last step: what the proof costs, measured. Renders the
# heaviest repo page (specimen.sp — every word) with and without the gate,
# and a partial inside a 50-row `each`, and prints the millisecond costs.
# The numbers are recorded in ROADMAP-0.2.md; this is the instrument — run
# it again when ruby or the grammar changes.

require 'benchmark'
require_relative '../lib/slim_pickins'
require_relative '../test/fixtures'

RUNS = 200
ROWS = 50

pages = SlimPickins::Library.from(File.expand_path('../pages', __dir__))
source = File.read(File.expand_path('../pages/specimen.sp', __dir__))
locals = Fixtures.for('specimen')

def ms(&block) = Benchmark.realtime(&block) * 1000

full = ms do
  RUNS.times { SlimPickins.render(source, path: 'pages/specimen.sp', locals: locals, library: pages) }
end
bare = ms do
  RUNS.times do
    transform = SlimPickins::Transform.new(source, 'x')
    SlimPickins::Builder.new(SlimPickins::Page.new(locals: locals), pages)
               .render(transform.call, 'x', source: source)
  end
end

rows = (1..ROWS).map { |i| Fixtures.account("A#{i}", i, 100, 7_000, 'Pre-tax', []) }
loop_page = "page p\n  each account\n    account_card\n"
partials = SlimPickins::Library.new(layout: nil, partials: pages.partials)
per_row = ms { 20.times { SlimPickins.render(loop_page, path: 'x',
                                             locals: { p: { accounts: rows } }, library: partials) } } / 20 / ROWS

puts "The cost, measured — #{RUBY_DESCRIPTION[/ruby \S+/]}, pages/specimen.sp, #{RUNS} runs"
puts format('  full render   %5.2f ms', full / RUNS)
puts format('  without gate  %5.2f ms', bare / RUNS)
puts format('  the gate      %5.2f ms  (the walk alone — the parse is shared)', (full - bare) / RUNS)
puts format('  per row       %5.2f ms  (account_card inside a %d-row each)', per_row, ROWS)
