#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase 0's verification: render the roth form in this language and compare it
# with the hand-written Slim page it replaces. Not a byte diff — a diff of the
# facts a form is made of, which is what a reader would actually check.

require 'slim'
require 'delegate'
require_relative '../lib/slim_pickins'
require '/home/dan/dev/roth/lib/engine/inputs'

ROTH = '/home/dan/dev/roth/views/controls.slim'

def facts(html)
  inputs = html.scan(/<input[^>]*>/).map do |tag|
    {
      name: tag[/name="([^"]*)"/, 1],
      type: tag[/type="([^"]*)"/, 1],
      value: tag[/value="([^"]*)"/, 1]
    }
  end.reject { |f| f[:name].nil? }
  labels = html.scan(%r{<label[^>]*>([^<]*)</label>}).flatten.map(&:strip).reject(&:empty?)
  options = html.scan(%r{<option[^>]*value="([^"]*)"}).flatten
  { inputs: inputs, labels: labels, options: options }
end

# The optional half of the contract, exercised. roth is the only thing that
# knows `ss_primary_amount` means "SS annual amount", so roth is where it is
# said — once, rather than on every page that shows the field.
class Scenario < SimpleDelegator
  LABELS = {
    age_primary: 'Age (primary)', age_spouse: 'Age (spouse)',
    trad_balance: 'Traditional balance', roth_balance: 'Roth balance',
    ss_primary_start_year: 'SS start (years from now)',
    ss_primary_amount: 'SS annual amount',
    ss_spouse_start_year: 'Spouse SS start (years from now)',
    ss_spouse_amount: 'Spouse SS annual amount',
    inflation_rate: 'Inflation', horizon_years: 'Horizon (years)',
    conversion_value: 'Strategy value', conversion_strategy: 'Strategy'
  }.freeze

  def label_for(attribute) = LABELS[attribute]
end

scenario = Engine::Inputs.from_hash(
  'age_primary' => 60, 'age_spouse' => 58,
  'trad_balance' => 750_000, 'roth_balance' => 150_000, 'base_income' => 80_000,
  'ss_primary_start_year' => 7, 'ss_primary_amount' => 45_000,
  'ss_spouse_start_year' => 9, 'ss_spouse_amount' => 22_000
)

ours = facts(SlimPickins.render(File.read('pages/roth_form.sp'),
                                path: 'pages/roth_form.sp',
                                locals: { scenario: Scenario.new(scenario) }))
theirs = facts(Slim::Template.new(ROTH).render(Object.new))

puts "hand-written Slim : #{theirs[:inputs].size} inputs, #{theirs[:labels].size} labels, #{theirs[:options].size} options"
puts "this language     : #{ours[:inputs].size} inputs, #{ours[:labels].size} labels, #{ours[:options].size} options"
puts

only_theirs = theirs[:inputs].map { |f| f[:name] } - ours[:inputs].map { |f| f[:name] }
only_ours   = ours[:inputs].map { |f| f[:name] } - theirs[:inputs].map { |f| f[:name] }

puts "fields only in the hand-written page: #{only_theirs.inspect}"
puts "fields only in ours                 : #{only_ours.inspect}"
puts

puts 'shared fields — type and value agreement:'
shared = ours[:inputs].select { |f| theirs[:inputs].any? { |t| t[:name] == f[:name] } }
shared.each do |f|
  t = theirs[:inputs].find { |x| x[:name] == f[:name] }
  mark = (f[:type] == t[:type] && f[:value] == t[:value]) ? '  ok  ' : ' DIFF '
  puts format('%s %-28s ours=%-8s %-9s theirs=%-8s %-9s',
              mark, f[:name], f[:type], f[:value], t[:type], t[:value])
end

puts
puts 'labels, side by side:'
[ours[:labels].size, theirs[:labels].size].max.times do |i|
  o = ours[:labels][i] || '—'
  t = theirs[:labels][i] || '—'
  puts format('  %-30s | %s', o, t)
end
