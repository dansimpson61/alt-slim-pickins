#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Holds a Spiff's compiled selectors to the HTML its pages really render.
#
#   - every class the compiled stylesheet targets must appear in the rendered
#     HTML of at least one page the Spiff governs
#
# This leg was built on 2026-09-26 to compare a Spiff's *zone names* against the
# `.sp` sources in its directory — "without data and without rendering", as its
# own header said at the time. DAYTRIP-0.4.0h then measured two things about it:
# it is the one leg with no recorded catch, and it shares the shape of eight of
# the ten, comparing a declaration to a declaration while both defect classes
# that have actually cost this project sessions live where none of them can look.
#
# Retargeted rather than deleted, because the measurement said where to aim.
#
#   - **It checked a third of what the compiler emits.** For `workbench.spiff`
#     the old check read 3 zone names. The compiled CSS targets 11 classes — the
#     surface, the stage, the `panes` it dissolves, the controls it reaches into
#     — so 8 were never checked at all. `panes` and `shell` are among those 8,
#     and they are the two classes 0.4.0g's hardest defects were about.
#   - **Its right-hand side was source text, so a word defined but never reached
#     passed.** The `.footer` rule that styled nothing because the element was a
#     `.foot` is exactly that defect. A rendered page cannot lie about it.
#
# So the question moved from "does a file somewhere define this name?" to "does
# this selector match anything the browser will be given?" — which is the
# question a compiled stylesheet actually raises, and the reason the zone-name
# walk, its ceiling and its `app_root` are gone: scope is now the pages rendered
# at or below the Spiff's own directory, and a `.spiff` either sits at its app's
# root or beside the views it governs.
#
# The corpus is `bin/verify_pages.rb`'s `PAGES` — one home for "every page this
# project can render, and the locals it needs". It has three consumers now
# (that gate, `bin/byte_diff.rb`, this one) rather than three copies, and a Spiff
# whose pages are not in it is refused rather than passed: that is how
# `examples/doc_reader` was found, an app directory with a Spiff, a page and a
# data file that nothing had ever rendered.
#
# Exits non-zero when anything is wrong.

require 'set'
require 'stringio'
require_relative 'lib/slim_pickins'
require_relative 'lib/slim_pickins/compiler/spiff'

# Reaching `PAGES` boots the example apps, and an app proves its own pages aloud
# on boot (`SlimPickins.prove!`). That output belongs to the app and not to this
# gate's report, so it is kept out of it.
begin
  spoken = $stdout
  $stdout = StringIO.new
  require_relative 'bin/verify_pages'
ensure
  $stdout = spoken
end

module SpiffScope
  ROOT = __dir__

  # A rule's selector, up to its brace. `@media`/`@container` lines open a block
  # without selecting anything, so they are not selectors.
  SELECTOR = /^\s*([^{@\n][^{\n]*)\{/
  CLASS = /\.([A-Za-z][\w-]*)/

  module_function

  # The classes the compiled stylesheet targets. Read from the CSS the compiler
  # emits rather than from the Spiff's parse tree: the parse tree names zones,
  # but the stylesheet is what the browser applies and therefore the only thing
  # that can match nothing.
  def targeted_classes(spiff_path)
    css = SlimPickins::Compiler::Spiff.compile(File.read(spiff_path), path: spiff_path)
    css.scan(SELECTOR).flatten.join(' ').scan(CLASS).flatten.uniq.sort
  end

  # The pages a Spiff governs: those rendered from at or below its own directory.
  #
  # `root` is the tree the run is about — this repository by default, a fixture's
  # temp directory under test. It is a parameter and not a constant because the
  # suite has to be able to pose a corpus this one cannot: a Spiff nothing
  # renders, a zone defined but unreached. The gate the retarget replaced learned
  # that the hard way, with every fixture test passing the repository root for a
  # tree built under `/tmp`.
  def scope_of(spiff, pages:, root: ROOT)
    prefix = "#{File.dirname(relative(spiff, root: root))}/"
    pages.select { |label, _library, _locals| label.start_with?(prefix) }
  end

  def relative(path, root: ROOT) = File.expand_path(path).delete_prefix("#{root}/")

  # Every class the pages in scope actually put into the HTML — the half of this
  # question the gate never used to ask.
  def rendered_classes(pages, root: ROOT)
    pages.each_with_object(Set.new) do |(label, library, locals), classes|
      html = SlimPickins.render(File.read(File.join(root, label)), path: label,
                                locals: locals, library: library)
      html.scan(/class="([^"]*)"/).flatten.each { |value| classes.merge(value.split) }
    end
  end

  # Returns the problem count and prints the report to `out`.
  def run(spiffs: nil, pages: PAGES, root: ROOT, out: $stdout)
    problems = 0
    checked = 0
    report = ->(line) { out.puts "  #{line}" }

    spiffs = (spiffs || Dir[File.join(root, '{pages,examples,studio}', '**', '*.spiff')]).sort
    if spiffs.empty?
      report.call('NO SPIFFS        no `.spiff` files found — the corpus or its shape changed')
      problems += 1
    end

    spiffs.each do |spiff|
      scope = scope_of(spiff, pages: pages, root: root)
      if scope.empty?
        report.call("UNRENDERED       `#{relative(spiff, root: root)}` governs no page the corpus renders, so its " \
                    'selectors have nothing to answer to — give its pages to `bin/verify_pages.rb`')
        problems += 1
        next
      end

      rendered = rendered_classes(scope, root: root)
      targeted = targeted_classes(spiff)
      checked += targeted.size

      (targeted - rendered.to_a).each do |name|
        report.call("MATCHES NOTHING  `#{relative(spiff, root: root)}` compiles a selector for `.#{name}`, " \
                    "and none " \
                    "of the #{scope.size} page(s) it governs renders that class")
        problems += 1
      end
    end

    out.puts
    out.puts "#{spiffs.size} spiff(s), #{checked} compiled classes held to the HTML their pages render, " \
             "#{problems} problems"
    problems
  end
end

exit(SpiffScope.run.zero? ? 0 : 1) if $PROGRAM_NAME == __FILE__
