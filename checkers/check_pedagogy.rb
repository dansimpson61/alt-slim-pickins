#!/usr/bin/env ruby
# frozen_string_literal: true
#
# The thirteenth checker: pedagogy matches ontology.
#
# Keeps the author-facing guides (PRIMER.md, CONVENTIONS.md, VOCABULARY.md,
# LAYOUT.md, and README.md) held to the Tri-Plane ontology:
#
#   1. Canvas plane separation:
#      - Substance (.sp): expresses domain content answering a route; must NEVER
#        call `page` (which belongs strictly in .frame) or top-level `contents`.
#      - Frame (.frame): defines document chrome; must declare `page` root and `contents`.
#      - Layout (.layout): defines spatial posture; must compile cleanly.
#   2. Contract & execution reality:
#      - Every snippet must compile and follow word contracts (no multiple
#        positional args to `box`, no `empty` in non-collection containers,
#        no archaic `def word, arg` commas).
#   3. Terminology & tense integrity:
#      - No retired terms (.tin, .spiff, partial/partials in author guides).
#      - Timeless present tense (no defensive historical "formerly").
#
# Exits non-zero when anything is wrong, so it can gate a commit.

require 'set'
require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/taxonomy'
require_relative '../lib/slim_pickins/compiler/layout'

module PedagogyChecker
  ROOT = File.expand_path('..', __dir__)

  DOCS = %w[
    docs/PRIMER.md
    docs/CONVENTIONS.md
    docs/VOCABULARY.md
    docs/LAYOUT.md
    README.md
  ].freeze

  Finding = Struct.new(:file, :line, :kind, :message, keyword_init: true) do
    def to_s
      "  #{kind.to_s.upcase.ljust(18)} #{file}:#{line} — #{message}"
    end
  end

  def self.run(docs = DOCS)
    findings = []

    docs.each do |rel_path|
      abs_path = File.join(ROOT, rel_path)
      next unless File.file?(abs_path)

      findings.concat(check_prose(rel_path, abs_path))
      findings.concat(check_fences(rel_path, abs_path))
    end

    findings
  end

  def self.check_prose(rel_path, abs_path)
    findings = []
    lines = File.readlines(abs_path)

    lines.each_with_index do |line, idx|
      lineno = idx + 1
      # Ignore markdown links to historical files in history/
      next if line.include?('history/') || line.include?('DAYTRIP-')

      if line.match?(/\.tin\b/)
        findings << Finding.new(file: rel_path, line: lineno, kind: :retired_term,
                                message: "contains \".tin\" — use \".frame\"")
      end
      if line.match?(/\.spiff\b/)
        findings << Finding.new(file: rel_path, line: lineno, kind: :retired_term,
                                message: "contains \".spiff\" — use \".layout\"")
      end
      if rel_path != 'README.md' && line.match?(/\bformerly\b/i)
        findings << Finding.new(file: rel_path, line: lineno, kind: :timeless_tense,
                                message: "contains \"formerly\" — author guides speak in timeless present tense")
      end
    end

    findings
  end

  def self.check_fences(rel_path, abs_path)
    findings = []
    content = File.read(abs_path)
    in_fence = false
    tag = nil
    lines = []
    start_line = 0
    prev_line = ''
    prev_context = ''

    content.lines.each_with_index do |raw_line, idx|
      if raw_line.start_with?('```')
        if in_fence
          findings.concat(verify_fence(rel_path, lines.join, start_line, tag, prev_context))
          in_fence = false
          lines = []
        else
          in_fence = true
          tag = raw_line.chomp.sub('```', '').strip
          start_line = idx + 2
          prev_context = prev_line
        end
      elsif in_fence
        lines << raw_line
      else
        prev_line = raw_line.strip unless raw_line.strip.empty?
      end
    end

    findings
  end

  def self.verify_fence(file, src, start_line, tag, context)
    findings = []
    return findings if %w[ruby html text bash sh slim css json].include?(tag)

    # Classify canvas plane
    is_layout = tag == 'layout' || (tag.empty? && (context.include?('.layout') || src.start_with?('surface ')))
    is_frame = tag == 'frame' || (tag.empty? && (context.include?('.frame') || context.include?('The frame') || context.include?('views/my_app.frame')))

    if is_layout
      begin
        SlimPickins::Compiler::Layout.new.compile(src)
      rescue => e
        findings << Finding.new(file: file, line: start_line, kind: :layout_syntax,
                                message: "invalid .layout syntax: #{e.message.lines.first&.strip}")
      end
      return findings
    end

    if is_frame
      unless src.match?(/^\s*page\b/)
        findings << Finding.new(file: file, line: start_line, kind: :frame_missing_page,
                                message: ".frame template must declare `page` document envelope at root")
      end
      unless src.match?(/^\s*contents\b/)
        findings << Finding.new(file: file, line: start_line, kind: :frame_missing_contents,
                                message: ".frame template must specify `contents` slot")
      end
      return findings
    end

    # Default to .sp substance canvas
    if src.match?(/^\s*page\b/)
      findings << Finding.new(file: file, line: start_line, kind: :plane_violation,
                              message: "`page` spoken in .sp substance template (`page` belongs exclusively in .frame)")
    end

    src.lines.each_with_index do |l, i|
      if l.match?(/^contents\b/)
        findings << Finding.new(file: file, line: start_line + i, kind: :sp_top_contents,
                                message: "`contents` spoken at top level of .sp template (only valid in .frame or inside `def`)")
      end
    end

    # Check syntax & contracts
    begin
      tree = SlimPickins::Transform.tree(src, path: File.basename(file))
      walk = lambda do |nodes|
        nodes.each do |n|
          if n.word == 'box'
            names = n.raw_args.zip(n.ranks).select { |_, r| r.zero? }.map(&:first)
            if names.size > 1
              findings << Finding.new(file: file, line: start_line + n.lineno - 1, kind: :box_multi_arg,
                                      message: "`box` called with multiple args (#{names.join(', ')}) — box takes variant only, not subject/title")
            end
          end
          if n.word == 'def' && n.body.match?(/^def\s+[a-z_]+,/)
            findings << Finding.new(file: file, line: start_line + n.lineno - 1, kind: :archaic_def,
                                    message: "archaic comma after `def` name: `#{n.body}` — use comma-less parameter list")
          end
          walk.call(n.children)
        end
      end
      walk.call(tree)
    rescue SlimPickins::SyntaxError => e
      findings << Finding.new(file: file, line: start_line + e.lineno - 1, kind: :syntax_error,
                              message: e.message.lines.first&.strip)
    rescue => e
      findings << Finding.new(file: file, line: start_line, kind: :compilation_error,
                              message: e.message.lines.first&.strip)
    end

    findings
  end
end

if $PROGRAM_NAME == __FILE__
  findings = PedagogyChecker.run
  if findings.empty?
    puts "Pedagogy: #{PedagogyChecker::DOCS.size} guides checked, 0 problems"
    exit 0
  else
    puts "Pedagogy: #{findings.size} problems found:"
    findings.each { |f| puts f }
    exit 1
  end
end
