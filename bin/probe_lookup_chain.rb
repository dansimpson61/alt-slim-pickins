#!/usr/bin/env ruby
# frozen_string_literal: true

# Probe the nearest-first lookup chain across the repository in reporting-only
# mode (Daytrip 0.5.0a, Part 2).
#
# Walking nearest first:
#   1. The file it is written in (file-local `def`s)
#   2. The families of the words it is nested inside (nearest enclosing word first)
#   3. The app (the library's own partials and Ruby words)
#   4. The language (top-level canonical words)
#
# This instrument changes no behaviour. It reports:
#   - Words that resolve differently than today's global registry (expected: `editor`)
#   - Words that resolve only through an enclosing word's family (expected: eleven contained words)
#   - Words that do not resolve at all (expected: empty)

require_relative '../lib/slim_pickins'
require_relative 'verify_pages'

CONTAINED = {
  'table'  => %w[column total],
  'chart'  => %w[band line level],
  'choose' => %w[when otherwise],
  'choice' => %w[option],
  'form'   => %w[hidden],
  'tabs'   => %w[tab],
  'list'   => %w[item]
}.freeze

ALL_CONTAINED = CONTAINED.values.flatten.freeze

CANONICAL_PRIMITIVES = SlimPickins::Word.registry.select do |_, k|
  k.name.to_s.start_with?('SlimPickins::Words::')
end.keys.map(&:to_s)

CANONICAL_PARTIALS = SlimPickins::Library.builtin_partials.keys.map(&:to_s)
CANONICAL_ALL = (CANONICAL_PRIMITIVES + CANONICAL_PARTIALS).uniq
TOP_LEVEL_LANGUAGE = (CANONICAL_ALL - ALL_CONTAINED).freeze

def resolve_word(word, ancestors, file_defs, library, in_privileged_builtin)
  return nil if %w[def expects].include?(word)

  # Privileged primitive (Builder#tag within lib/vocabulary/*.sp)
  if in_privileged_builtin && word == 'tag'
    return { tier: :language_privileged, target: word }
  end

  # 1. File defs
  if file_defs.include?(word)
    return { tier: :file, target: word }
  end

  # 2. Nearest enclosing family
  ancestors.reverse_each do |anc|
    family = CONTAINED[anc.word]
    if family&.include?(word)
      return { tier: :family, parent: anc.word, target: word, parent_line: anc.lineno }
    end
  end

  # 3. App library
  if library
    app_partials = library.instance_variable_get(:@app_partials) || {}
    if app_partials.key?(word.to_sym)
      path = library.instance_variable_get(:@partial_paths)&.[](word.to_sym)
      return { tier: :app_partial, target: word, path: path }
    end

    app_words = library.instance_variable_get(:@words) || []
    app_word_methods = app_words.flat_map { |w| w.respond_to?(:instance_methods) ? w.instance_methods.map(&:to_s) : [] }
    if app_word_methods.include?(word)
      return { tier: :app_ruby, target: word }
    end
  end

  # 4. Language top-level
  if TOP_LEVEL_LANGUAGE.include?(word)
    return { tier: :language, target: word }
  end

  # Contained word called outside parent?
  if ALL_CONTAINED.include?(word)
    return { tier: :unresolved_contained, target: word }
  end

  { tier: :unresolved, target: word }
end

def walk(node, ancestors, file_defs, library, file_path, in_privileged, &block)
  res = resolve_word(node.word, ancestors, file_defs, library, in_privileged)
  block.call(node, ancestors, res, file_path) if res

  new_ancestors = ancestors + [node]
  node.children&.each do |child|
    walk(child, new_ancestors, file_defs, library, file_path, in_privileged, &block)
  end
end

builtin_lib = SlimPickins::Library.builtin
classic_ui = Uis['classic']
workbench_ui = Uis['workbench']
classic_lib = StudioPages.ui_library(classic_ui)
workbench_lib = StudioPages.ui_library(workbench_ui)
inspector_lib = StudioInspector.library

portfolio_lib = SlimPickins::Library.from(File.expand_path('../examples/portfolio/views', __dir__), words: AppWords)
roth_lib = SlimPickins::Library.from(File.expand_path('../examples/roth/views', __dir__))
dash_lib = SlimPickins::Library.from(File.expand_path('../examples/dashboard/views', __dir__))
lore_lib = SlimPickins::Library.from(File.expand_path('../examples/lore_reader/views', __dir__))
exam_lib = SlimPickins::Library.from(File.expand_path('../examples/way_exam/views', __dir__))
mstone_lib = SlimPickins::Library.from(File.expand_path('../examples/milestone_planner/views', __dir__))
graph_lib = SlimPickins::Library.from(File.expand_path('../examples/word_graph/views', __dir__))
doc_lib = SlimPickins::Library.from(File.expand_path('../examples/doc_reader/views', __dir__))

libs = {
  portfolio: portfolio_lib, roth: roth_lib, dash: dash_lib, lore: lore_lib,
  exam: exam_lib, mstone: mstone_lib, graph: graph_lib, doc: doc_lib,
  classic: classic_lib, workbench: workbench_lib, inspector: inspector_lib,
  builtin: builtin_lib
}

def library_for(file, libs)
  case file
  when %r{^examples/portfolio/} then libs[:portfolio]
  when %r{^examples/roth/} then libs[:roth]
  when %r{^examples/dashboard/} then libs[:dash]
  when %r{^examples/lore_reader/} then libs[:lore]
  when %r{^examples/way_exam/} then libs[:exam]
  when %r{^examples/milestone_planner/} then libs[:mstone]
  when %r{^examples/word_graph/} then libs[:graph]
  when %r{^examples/doc_reader/} then libs[:doc]
  when %r{^studio/uis/classic/} then libs[:classic]
  when %r{^studio/uis/workbench/} then libs[:workbench]
  when %r{^studio/views/} then libs[:inspector]
  when %r{^studio/shared/} then libs[:classic]
  when %r{^lib/vocabulary/} then libs[:builtin]
  when %r{^pages/} then libs[:builtin]
  else libs[:builtin]
  end
end

all_files = Dir.glob('{examples,studio,lib/vocabulary,pages}/**/*.{sp,tin}').sort

results = []
all_files.each do |file|
  lib = library_for(file, libs)
  source = File.read(file)
  tree = SlimPickins::Transform.tree(source, path: file)
  file_defs = tree.select { |n| n.word == 'def' }.map { |n| n.raw_args.first.to_s }
  in_privileged = file.start_with?('lib/vocabulary/')

  tree.each do |root|
    walk(root, [], file_defs, lib, file, in_privileged) do |node, ancestors, res, fpath|
      results << { path: fpath, line: node.lineno, word: node.word, res: res }
    end
  end
end

puts "=== PROBE LOOKUP CHAIN (0.5.0a Part 2) ==="
puts "Files inspected: #{all_files.size}"
puts "Total sentences resolved: #{results.size}"

by_tier = results.group_by { |r| r[:res][:tier] }
puts "\nResolution counts by tier:"
by_tier.each do |tier, items|
  puts "  #{tier.to_s.ljust(22)}: #{items.size.to_s.rjust(4)} calls across #{items.map { |i| i[:word] }.uniq.size} words"
end

# List 1: Resolves differently than today (colliding names across scopes)
# Under today's global registry, any colliding partial name is overwritten by the last write.
partial_files = Dir.glob('{examples,studio}/**/partials/*.sp')
colliding_names = partial_files.group_by { |p| File.basename(p, '.sp') }.select { |_, paths| paths.size > 1 }

puts "\n1. Resolves differently than today's global registry:"
if colliding_names.empty?
  puts "  (none)"
else
  colliding_names.each do |name, paths|
    occurrences = results.select { |r| r[:word] == name }
    puts "  `#{name}` (#{occurrences.size} calls across #{occurrences.map { |o| o[:path] }.uniq.size} files):"
    occurrences.each do |occ|
      puts "    #{occ[:path]}:#{occ[:line]} -> resolves nearest to #{occ[:res][:path]}"
    end
    puts "    Definitions that collided globally under old registry:"
    paths.each { |p| puts "      - #{p}" }
  end
end

# List 2: Resolves only through enclosing word's family
family_calls = results.select { |r| r[:res][:tier] == :family }
puts "\n2. Resolves only through enclosing word's family (#{family_calls.size} calls across #{family_calls.map { |c| c[:word] }.uniq.size} words):"
family_by_parent = family_calls.group_by { |c| c[:res][:parent] }
family_by_parent.each do |parent, calls|
  words = calls.map { |c| c[:word] }.uniq.sort.join(', ')
  puts "  Inside `#{parent}`: #{calls.size} calls (#{words})"
end

# List 3: Does not resolve at all
unresolved = results.select { |r| r[:res][:tier].to_s.start_with?('unresolved') }
puts "\n3. Does not resolve at all:"
if unresolved.empty?
  puts "  (none — 0 problems)"
else
  unresolved.each do |u|
    puts "  #{u[:path]}:#{u[:line]} - #{u[:word]} (#{u[:res][:tier]})"
  end
end
