#!/usr/bin/env ruby
# frozen_string_literal: true

# Renders every page in pages/ against the shared fixtures. This is Phase 4's
# done-condition and Phase 5's demonstration: the three pages were drafted on
# paper before any code existed.

require_relative '../lib/slim_pickins'
require_relative '../test/fixtures'

library = SlimPickins::Library.from(File.expand_path('../pages', __dir__))

Dir[File.expand_path('../pages/*.sp', __dir__)].sort.each do |path|
  name = File.basename(path, '.sp')
  locals = Fixtures.for(name)
  next unless locals

  source = File.read(path)
  html = SlimPickins.render(source, path: path, locals: locals, library: library)
  File.write("/tmp/#{name}.html", html)
  puts format('%-22s %3d sentences -> %5d bytes of HTML',
              "pages/#{name}.sp", source.lines.count { |l| !l.strip.empty? }, html.bytesize)
end

puts
puts 'rendered to /tmp/*.html'
