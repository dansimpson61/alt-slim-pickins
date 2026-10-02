#!/usr/bin/env ruby
# frozen_string_literal: true
#
# The byte-diff instrument: render every page the gate proves and reduce the
# whole corpus to one digest, so a refactor can be *shown* to change no output
# rather than asserted to.
#
# This is the project's acceptance test for shape work — the thing that made the
# 2026-10-02 indentation round safe to do at all, and the thing `tabs` broke
# once by numbering ids from `object_id` (rendered HTML was not a pure function
# of its source, so nothing could be byte-compared; see the note in
# `Generator#tabs`). It borrows `PAGES` from `bin/verify_pages.rb` rather than
# keeping a second copy of the corpus and its locals.
#
#   ruby bin/byte_diff.rb                  # print the corpus digest
#   ruby bin/byte_diff.rb /tmp/before      # also write each page, for diffing
#
# Refactor, re-run, compare the digests. They differ => output changed.
# To see *where*, snapshot into two directories and `diff -r` them.
#
# The status page prints the clock, so the clock is scrubbed before hashing —
# otherwise the corpus would never be identical to itself.
#
# The digest is a *relative* instrument, not a constant to pin. Some pages render
# live repository content: `examples/lore_reader` shows a count of `LORE.md`'s
# entries, so leaving lore moves the digest legitimately. Snapshot before your
# change and after it, in the same session, and compare those. A digest that
# differs from one written down in a document last week proves nothing — and
# chasing that ghost is exactly the half hour this paragraph exists to save.

require 'digest'
require 'fileutils'
require_relative 'verify_pages'

ROOT = File.expand_path('..', __dir__)
CLOCK = /\d{4}-\d\d-\d\d \d\d:\d\d(:\d\d)?/

out_dir = ARGV.first
FileUtils.mkdir_p(out_dir) if out_dir

manifest = PAGES.map do |label, library, locals|
  html = SlimPickins.render(File.read(File.join(ROOT, label)),
                            path: label, locals: locals, library: library)
             .gsub(CLOCK, '<TIME>')
  File.write(File.join(out_dir, label.tr('/', '_')), html) if out_dir
  format('%-72s %7d  %s', label, html.bytesize, Digest::SHA256.hexdigest(html)[0, 16])
end

report = "#{manifest.join("\n")}\n"
File.write(File.join(out_dir, '_MANIFEST'), report) if out_dir

puts report
puts "#{PAGES.size} pages"
puts "corpus digest: #{Digest::SHA256.hexdigest(report)[0, 24]}"
puts "written to #{out_dir}" if out_dir
