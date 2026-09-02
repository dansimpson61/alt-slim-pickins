#!/usr/bin/env ruby
# frozen_string_literal: true

# The exam's instrument: render the ported /triage against the same live
# data the dashboard at :4000 serves, and compare affordances — forms and
# their hidden inputs, links, badges, buttons — between the two. Byte
# equality is not the bar (a different renderer, and the named gaps); the
# bar is: nothing the original can do is missing here.

require 'net/http'
require 'rack/test'
require_relative '../lib/slim_pickins'
require_relative '../examples/dashboard/app'

DashboardPort::App.set :host_authorization, { permitted_hosts: [] }

class ParityCheck
  include Rack::Test::Methods
  def app = DashboardPort::App
end

def affordances(html)
  {
    forms: html.scan(%r{<form[^>]*action="([^"]*)"[^>]*>}).flatten.sort,
    hiddens: html.scan(%r{<input type="hidden" name="([^"]*)" value="([^"]*)"})
                  .map { |n, v| "#{n}=#{v}" }.sort,
    badges: html.scan(/class="([^"]*sp-badge[^"]*)"/).flatten.sort,
    buttons: html.scan(%r{<button[^>]*>([^<]*)</button>}).flatten.sort,
    links: html.scan(%r{<a[^>]*href="([^"]*)"[^>]*>([^<]*)</a>})
               .map { |h, t| "#{t.strip} → #{h}" }.sort
  }
end

original_html = Net::HTTP.get(URI('http://127.0.0.1:4000/triage'))
check = ParityCheck.new
check.get('/triage')
port_html = check.last_response.body

original = affordances(original_html)
port = affordances(port_html)

problems = 0
original.each_key do |kind|
  missing = original[kind] - port[kind]
  extra = port[kind] - original[kind]
  next if missing.empty? && extra.empty?

  problems += missing.size
  puts "#{kind.upcase}"
  missing.each { |x| puts "  MISSING IN PORT  #{x}" }
  extra.each { |x| puts "  extra in port    #{x}" }
end

puts "\n#{original.values.sum(&:size)} affordances compared, #{problems} missing"
exit(problems.zero? ? 0 : 1)
