#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Holds a Spiff to the pages it accompanies.
#
#   - every zone a `.spiff` names must be something the pages in its scope can
#     render, with that name as its class
#
# This is the tenth gate and the last one the round asked for. It exists for a
# defect the other nine cannot see: the design-idiom compiler emits a selector
# for every zone a Spiff names, and a compiled selector that matches nothing in
# the real DOM is a correctness defect however short it is — the round that
# removed the defensive selector explosion said exactly that. Until now nothing
# compared a Spiff's zone names to the pages those zones are supposed to style,
# so a typo (`reading_pane` for `reading_panel`) or a renamed zone would compile
# to a rule that silently styles nothing.
#
# What this checks, stated plainly: the *names*. A zone's class comes from the
# word or partial of the same name — a page's `def catalog` promotes `catalog`,
# and `library.sp` promotes `library` — so "can this scope render that name?"
# is a question about the sources on disk, and it is answered without data and
# without rendering. It cannot see a word that is defined but never reached, so
# it proves the Spiff is not naming a stranger; it does not prove the element
# appears in every render. `bin/verify_pages.rb` is the gate that renders.
#
# Exits non-zero when anything is wrong.

require 'set'
require_relative 'lib/slim_pickins'

module SpiffScope
  module_function

  # From the Spiff's own parse tree, not a second pattern. `zone` names one;
  # `flank` names two — its lead, and its companion in `beside:`, which is a
  # zone in its own right and is styled like one; `horizon` names all of its
  # zones in order. Missing the companion would leave the one name a Spiff is
  # most likely to get wrong unchecked.
  #
  # Only bare names and `beside:` are zones. `balance: equal`, `collapse:
  # tight` and the rest name roles and tokens — `subordinate` and `tight` are
  # not classes any page carries, and treating them as zones would refuse every
  # real Spiff.
  def zone_names(spiff_path)
    tree = SlimPickins::Transform.tree(File.read(spiff_path), path: spiff_path)
    names = []
    walk = lambda do |nodes|
      nodes.each do |node|
        case node.word
        when 'zone'
          names << node.raw_args.first
        when 'flank'
          names << node.raw_args.first
          names << node.raw_args.find { |arg| arg.to_s.start_with?('beside:') }&.split(':', 2)&.last
        when 'horizon'
          names.concat(node.raw_args)
        end
        walk.call(node.children)
      end
    end
    walk.call(tree)
    names.compact.map(&:to_s).map(&:strip).reject(&:empty?).uniq
  end

  # The app a Spiff belongs to: the nearest directory at or above it that holds
  # the views it governs. A `.spiff` either sits at the app's root
  # (`doc_reader/`, with a `views/` beneath it; `workbench/`, with its views
  # beside it) or beside the views themselves.
  # `nil` is a real answer, and the only honest one when the walk finds no app:
  # returning the last directory seen meant returning `/` for a Spiff that
  # belongs to none, and `renderable_names` then globbed the entire filesystem.
  # That is the defect behind this gate's own false first run (LORE.md,
  # 2026-09-27) — the false pass was fixed then, the walk was not.
  #
  # `within` is required because a walk needs a floor. It is the tree the run was
  # told to examine, so a Spiff outside the corpus is refused deterministically
  # rather than resolving to whatever unrelated ancestor happens to hold a `.sp`.
  # It, and not the filesystem root, is the boundary that does the work.
  def app_root(spiff_path, within:)
    ceiling = File.expand_path(within)
    dir = File.dirname(File.expand_path(spiff_path))

    while inside?(dir, ceiling)
      return dir if app?(dir)

      parent = File.dirname(dir)
      break if parent == dir # only `within: '/'` gets here; the loop stays total

      dir = parent
    end
    nil
  end

  # A directory is an app when it holds the views a Spiff governs.
  def app?(dir)
    Dir.exist?(File.join(dir, 'views')) ||
      File.exist?(File.join(dir, "#{File.basename(dir)}.tin")) ||
      Dir[File.join(dir, '*.sp')].any?
  end

  def inside?(dir, ceiling)
    dir == ceiling || dir.start_with?("#{ceiling}/")
  end

  # What a scope can render, from the two ways this project makes a word: a page
  # may define one inline (`def catalog`), and an app may put one on disk
  # (`partials/library.sp`). Both promote their name as the class on a
  # single-root element, which is what makes the name match a Spiff's zone.
  def renderable_names(app)
    names = Set.new

    Dir[File.join(app, '**', '*.sp')].sort.each do |path|
      tree = SlimPickins::Transform.tree(File.read(path), path: path)
      walk = lambda do |nodes|
        nodes.each do |node|
          names << node.raw_args.first.to_s if node.word == 'def'
          walk.call(node.children)
        end
      end
      walk.call(tree)
    end

    names.merge(Dir[File.join(app, '**', 'partials', '*.sp')].map { |f| File.basename(f, '.sp') })
  end

  # Returns the problem count and prints the report to `out`.
  def run(files: nil, root: __dir__, out: $stdout)
    problems = 0
    report = ->(line) { out.puts "  #{line}" }

    spiffs = (files || Dir[File.join(root, '{pages,examples,studio}', '**', '*.spiff')]).sort
    if spiffs.empty?
      report.call('SPIFFS      no .spiff files found — the corpus or its shape changed')
      problems += 1
    end

    spiffs.each do |spiff|
      app = app_root(spiff, within: root)
      unless app
        report.call("NO APP      `#{File.basename(spiff)}` belongs to no app — nothing at or above it " \
                    'holds views, a tin, or a `.sp`, so its zones have nothing to answer to')
        problems += 1
        next
      end

      renderable = renderable_names(app)

      zone_names(spiff).each do |zone|
        next if renderable.include?(zone)

        report.call("UNRENDERABLE  `#{File.basename(spiff)}` styles zone `#{zone}`, and nothing in " \
                    "#{app.sub("#{root}/", '')} renders a `#{zone}` — the selector matches nothing")
        problems += 1
      end
    end

    out.puts
    out.puts "#{spiffs.size} spiff(s) held to their pages, #{problems} problems"
    problems
  end
end

exit(SpiffScope.run.zero? ? 0 : 1) if $PROGRAM_NAME == __FILE__
