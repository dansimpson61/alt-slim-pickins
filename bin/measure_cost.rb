#!/usr/bin/env ruby
# frozen_string_literal: true

# What the proof costs, measured — before the cache and after. Renders the
# heaviest repo page (specimen.sp — every word) cold (compile-once cache
# empty) and warm (cache hit, what a request pays), and a partial inside a
# 50-row `each`, warm. The numbers are recorded in ROADMAP-0.2.md; this is
# the instrument — run it again when ruby or the grammar changes.

require 'benchmark'
require_relative '../lib/slim_pickins'
require_relative '../test/fixtures'

RUNS = 200
ROWS = 50

pages = SlimPickins::Library.from(File.expand_path('../pages', __dir__))
source = File.read(File.expand_path('../pages/specimen.sp', __dir__))
locals = Fixtures.for('specimen')

def ms(&block) = Benchmark.realtime(&block) * 1000

cold = ms do
  SlimPickins::Compilation.clear!
  RUNS.times do
    SlimPickins.render(source, path: 'pages/specimen.sp', locals: locals, library: pages)
    SlimPickins::Compilation.clear!
  end
end

warm = ms do
  SlimPickins.render(source, path: 'pages/specimen.sp', locals: locals, library: pages) # warm it
  RUNS.times { SlimPickins.render(source, path: 'pages/specimen.sp', locals: locals, library: pages) }
end

rows = (1..ROWS).map { |i| Fixtures.account("A#{i}", i, 100, 7_000, 'Pre-tax', []) }
loop_page = "page p\n  each account\n    test_account_card\n"
partials = SlimPickins::Library.new(layout: nil, partials: pages.app_partials)
SlimPickins.render(loop_page, path: 'x', locals: { p: { accounts: rows } }, library: partials) # warm it
per_row = ms { 20.times { SlimPickins.render(loop_page, path: 'x',
                                             locals: { p: { accounts: rows } }, library: partials) } } / 20 / ROWS

puts "The cost, measured — #{RUBY_DESCRIPTION[/ruby \S+/]}, pages/specimen.sp, #{RUNS} runs"
puts format('  cold render   %5.2f ms  (parse, walk, emit, evaluate, generate)', cold / RUNS)
puts format('  warm render   %5.2f ms  (the cache hit — what a request pays)', warm / RUNS)
puts format('  per row       %5.2f ms  (test_account_card inside a %d-row each, warm)', per_row, ROWS)
