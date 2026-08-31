#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase 4's done-condition: the three pages drafted on paper, rendered.
# They were written before any code existed, against no implementation.

require 'date'
require_relative '../lib/slim_pickins'

def struct(name, **attrs)
  Struct.new(*attrs.keys, keyword_init: true).new(**attrs).tap do |s|
    s.singleton_class.define_method(:inspect) { "#<#{name}>" }
  end
end

Money = lambda do |*fields|
  Module.new do
    define_method(:format_for) { |a| fields.include?(a) ? :money : nil }
  end
end

holding = lambda do |symbol, shares, value, gain, weight|
  h = Struct.new(:symbol, :shares, :market_value, :gain, :weight, keyword_init: true)
           .new(symbol: symbol, shares: shares, market_value: value, gain: gain, weight: weight)
  h.singleton_class.define_method(:format_for) do |a|
    { shares: :number, market_value: :money, gain: :money, weight: :percent }[a]
  end
  h
end

account = lambda do |name, id, balance, room, treatment, holdings|
  a = Struct.new(:name, :id, :balance, :contribution_room, :tax_treatment, :holdings, keyword_init: true)
           .new(name: name, id: id, balance: balance, contribution_room: room,
                tax_treatment: treatment, holdings: holdings)
  a.singleton_class.define_method(:format_for) { |x| %i[balance contribution_room].include?(x) ? :money : nil }
  a
end

target = Struct.new(:asset_class, :target, :actual, :drift, keyword_init: true)
targets = [
  target.new(asset_class: 'US equity', target: 0.60, actual: 0.63, drift: 0.03),
  target.new(asset_class: 'International', target: 0.25, actual: 0.21, drift: -0.04),
  target.new(asset_class: 'Bonds', target: 0.15, actual: 0.16, drift: 0.01)
]
targets.each do |t|
  t.singleton_class.define_method(:format_for) { |a| a == :asset_class ? nil : :percent }
end

contribution = Struct.new(:amount, :account_id, :frequency, :auto_invest, keyword_init: true)
                     .new(amount: 500, account_id: 'roth', frequency: 'monthly', auto_invest: true)

portfolio = struct('Portfolio',
                   as_of: Date.new(2026, 8, 30),
                   total_value: 1_284_506, ytd_return: 0.0742,
                   annual_income: 48_200, years_to_rmd: 13,
                   allocation: [0.63, 0.21, 0.16], balances: [900_000, 1_020_000, 1_284_506],
                   years: [2024, 2025, 2026], drifted?: true, targets: targets,
                   growth_rate: 0.05, inflation_rate: 0.02, horizon_years: 30,
                   contribution: contribution,
                   accounts: [
                     account.call('Traditional IRA', 1, 417_530, 7_000, 'Pre-tax', [
                                    holding.call('VTI', 1240, 356_120, 48_900, 0.42),
                                    holding.call('VXUS', 890, 61_410, -3_180, 0.07)
                                  ]),
                     account.call('Roth IRA', 2, 117_760, 7_000, 'Tax-free', [
                                    holding.call('VTI', 410, 117_760, 21_050, 0.14)
                                  ])
                   ])
portfolio.singleton_class.define_method(:format_for) do |a|
  { total_value: :money, ytd_return: :percent, annual_income: :money, years_to_rmd: :number }[a]
end

project = Struct.new(:path, :purpose, keyword_init: true)
pattern = struct('Pattern',
                 title: 'Rapid Iterative Feedback', category: 'ux', status: 'canonical',
                 origin_project: 'dashboard', origin_file: 'docs/pattern_rif.md',
                 content: "A **four-step** loop.\n\n- Observe\n- Implement\n- Verify\n- Commit\n\nSee [the Ode](/ode).",
                 lore: 'Feed this to any agent before development.',
                 projects: [project.new(path: 'abide', purpose: 'Habit tracker'),
                            project.new(path: 'dashboard', purpose: 'Workspace memory')])

finding = Struct.new(:severity, :summary, keyword_init: true)
surface = Struct.new(:name, :caption, :screenshot, :findings, keyword_init: true)
review = struct('Review',
                reviewed_on: Date.new(2026, 8, 27), reviewer: 'dan',
                introduction: "Every surface, *as reviewed*.\n\nScreenshots are regenerable.",
                surfaces_reviewed: 12, findings_open: 4, worst_severity: 'blocker',
                surfaces: [
                  surface.new(name: 'Triage', caption: 'The triage view, before the fix',
                              screenshot: '/.ocr/triage_big.png',
                              findings: [finding.new(severity: 'blocker', summary: 'Links are not clickable.'),
                                         finding.new(severity: 'polish', summary: 'Badge spacing is tight.')]),
                  surface.new(name: 'Ports', caption: 'The ports table', screenshot: '/.ocr/ports_big.png',
                              findings: [finding.new(severity: 'warning', summary: 'Sort order is not obvious.')])
                ])

PAGES = {
  'pages/portfolio.sp' => { portfolio: portfolio },
  'pages/content.sp' => { pattern: pattern },
  'pages/figures.sp' => { review: review }
}.freeze

library = SlimPickins::Library.from('pages')

PAGES.each do |path, locals|
  html = SlimPickins.render(File.read(path), path: path, locals: locals, library: library)
  sentences = File.read(path).lines.count { |l| !l.strip.empty? }
  puts format('%-22s %3d sentences -> %5d bytes of HTML', path, sentences, html.bytesize)
  File.write("/tmp/#{File.basename(path, '.sp')}.html", html)
end

puts
puts 'rendered to /tmp/{portfolio,content,figures}.html'
