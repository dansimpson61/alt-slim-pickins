#!/usr/bin/env ruby
# frozen_string_literal: true

# A self-contained page you can open. The stylesheet is inlined so the file
# stands alone — everything else is exactly what the renderer produces.

require_relative '../lib/slim_pickins'
require_relative '../test/fixtures'

name = ARGV.fetch(0, 'specimen')
root = File.expand_path('..', __dir__)
css = File.read(File.join(root, 'assets', 'slim-pickins.css'))
library = SlimPickins::Library.from(File.join(root, 'pages'))

html = SlimPickins.render(File.read(File.join(root, 'pages', "#{name}.sp")),
                          path: "pages/#{name}.sp",
                          locals: Fixtures.for(name), library: library)

# The layout's <link> cannot resolve from a file:// URL, so inline it instead.
html = html.sub(%r{<link rel="stylesheet"[^>]*>}, "<style>#{css}</style>")
out = "/tmp/#{name}.html"
File.write(out, html)
puts out
