#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase 2's demonstration: nested collections, a table that writes no loop,
# and formatting chosen from the value.

require_relative '../lib/slim_pickins'

# The optional half of the contract again: a number's shape cannot say whether
# it is money. The app knows, and says it once.
Holding = Struct.new(:symbol, :shares, :market_value, :gain, :weight, keyword_init: true) do
  FORMATS = { shares: :number, market_value: :money, gain: :money, weight: :percent }.freeze
  def format_for(attribute) = FORMATS[attribute]
end
Account = Struct.new(:name, :holdings, keyword_init: true)
Portfolio = Struct.new(:accounts, :total_value, :ytd_return, keyword_init: true)

portfolio = Portfolio.new(
  total_value: 1_284_506,
  ytd_return: 0.0742,
  accounts: [
    Account.new(name: 'Traditional IRA', holdings: [
                  Holding.new(symbol: 'VTI', shares: 1240, market_value: 356_120, gain: 48_900, weight: 0.42),
                  Holding.new(symbol: 'VXUS', shares: 890, market_value: 61_410, gain: -3_180, weight: 0.07)
                ]),
    Account.new(name: 'Roth IRA', holdings: [
                  Holding.new(symbol: 'VTI', shares: 410, market_value: 117_760, gain: 21_050, weight: 0.14)
                ])
  ]
)

library = SlimPickins::Library.from('pages')

html = SlimPickins.render(File.read('pages/portfolio_table.sp'),
                          path: 'pages/portfolio_table.sp',
                          locals: { portfolio: portfolio }, library: library)
puts html.gsub('><', ">\n<")

puts
puts '--- the same partial, a different page ---'
detail = SlimPickins.render(File.read('pages/account_detail.sp'),
                            path: 'pages/account_detail.sp',
                            locals: { account: portfolio.accounts.last }, library: library)
puts detail[%r{<h2>.*?</table>}m].gsub('><', ">\n<")

puts
puts '--- the same page with no accounts ---'
bare = SlimPickins.render(File.read('pages/portfolio_table.sp'),
                          path: 'pages/portfolio_table.sp', library: library,
                          locals: { portfolio: Portfolio.new(accounts: [], total_value: 0, ytd_return: 0.0) })
puts bare[%r{<section class="section section--accounts">.*?</section>}m].gsub('><', ">\n<")
