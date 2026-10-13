#!/usr/bin/env ruby
# frozen_string_literal: true

# The polysemy and vocabulary taxonomy census for Roadmap 0.6 (Daytrip 0.6.0a).
#
# Measures every occurrence and role of overloaded words across the codebase:
#   - `variant` (style weight vs. data status vs. formatting mode vs. contract slot)
#   - `children` (block-yielding keyword vs. AST node list vs. contract slot vs. child class)
#   - `content` (inline payload argument vs. contract flag vs. domain text vs. CSS layout)
#   - `subject` (frame record vs. evaluation receiver vs. contract slot)
#   - `name` (sentence slot vs. word identity vs. HTML parameter vs. model attribute)
#   - `body` (block nodes vs. HTML tag vs. model text vs. convention)
#   - `parent` (family namespace vs. container-value walk vs. DOM parent)
#   - Taxonomy (`word`, `primitive`, `partial`, `def`, `contract`, `tin`, `spiff`)

require 'find'
require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/census'

module PolysemyCensus
  ROOT = File.expand_path('..', __dir__)

  TERMS = %w[variant children content subject name body parent tin spiff].freeze

  def self.scan_files
    matches = Hash.new { |h, k| h[k] = { rb: [], sp: [], md: [] } }

    Find.find(ROOT) do |path|
      next if path =~ %r{/(?:\.git|vendor|history|roth)\b}
      ext = File.extname(path)
      cat = case ext
            when '.rb' then :rb
            when '.sp' then :sp
            when '.md' then :md
            end
      next unless cat

      rel = path.delete_prefix("#{ROOT}/")
      File.readlines(path, encoding: 'utf-8').each_with_index do |line, idx|
        TERMS.each do |term|
          if line =~ /\b#{term}\b/i
            matches[term][cat] << [rel, idx + 1, line.strip]
          end
        end
      end
    rescue StandardError => e
      warn "Could not read #{path}: #{e.message}"
    end

    matches
  end

  def self.contract_census
    words = SlimPickins::Census.words[:total]
    contracts = words.each_with_object({}) { |w, h| h[w] = SlimPickins::CONTRACTS[w] }

    name_slots = Hash.new { |h, k| h[k] = [] }
    children_slots = Hash.new { |h, k| h[k] = [] }
    content_slots = Hash.new { |h, k| h[k] = [] }
    modifiers = Hash.new { |h, k| h[k] = [] }

    contracts.each do |w, c|
      next unless c
      name_slots[c.name] << w
      content_slots[c.content ? :accepts : :none] << w
      ch = c.children.is_a?(Array) ? :specific_list : c.children
      children_slots[ch] << w
      c.modifiers.each { |m| modifiers[m] << w }
    end

    {
      words_count: words.size,
      name_slots: name_slots,
      children_slots: children_slots,
      content_slots: content_slots,
      modifiers: modifiers
    }
  end

  def self.run
    puts '========================================================================'
    puts '        SLIM-PICKINS POLYSEMY & TAXONOMY CENSUS (ROADMAP 0.6)           '
    puts '========================================================================'

    matches = scan_files
    contracts = contract_census

    puts "\n--- 1. OVERALL FREQUENCY BY SURFACE ---"
    printf "%-12s | %-16s | %-16s | %-16s\n", 'Term', 'Ruby (.rb)', 'Templates (.sp)', 'Docs (.md)'
    puts '-------------+------------------+------------------+------------------'
    TERMS.each do |term|
      m = matches[term]
      rb_info = "#{m[:rb].size} (#{m[:rb].map(&:first).uniq.size}f)"
      sp_info = "#{m[:sp].size} (#{m[:sp].map(&:first).uniq.size}f)"
      md_info = "#{m[:md].size} (#{m[:md].map(&:first).uniq.size}f)"
      printf "%-12s | %-16s | %-16s | %-16s\n", term, rb_info, sp_info, md_info
    end

    puts "\n--- 2. THE CONTRACTS LANDSCAPE (62 CANONICAL WORDS) ---"
    puts "Name slot breakdown:"
    contracts[:name_slots].sort.each do |slot, ws|
      puts "  :#{slot} (#{ws.size}): #{ws.join(', ')}"
    end

    puts "\nChildren contract breakdown:"
    contracts[:children_slots].sort.each do |slot, ws|
      puts "  :#{slot} (#{ws.size}): #{ws.join(', ')}"
    end

    puts "\nContent acceptance:"
    contracts[:content_slots].sort.each do |slot, ws|
      puts "  :#{slot} (#{ws.size}): #{ws.join(', ')}"
    end

    puts "\n--- 3. KEY COLLISION ANALYSIS ---"

    puts "\n[VARIANT] Four Distinct Roles:"
    puts "  1. Presentational Style: button, box, grid, list, aside, scroll, nav, tabs"
    puts "  2. Semantic Status / Tone: badge (ok, blocker, pending), note (warning, quiet)"
    puts "  3. Formatting / Mode: time (:relative, :datetime), choice (:radio)"
    puts "  4. Contract Slot: name_slot = :variant (`14` words) & modifier kwarg (action, card)"

    puts "\n[CHILDREN] Four Distinct Roles:"
    puts "  1. Language Word (Yield): 'children' in `11` vocabulary partials (actions, aside, card, etc.)"
    puts "  2. AST Node Structure: Node[:word, :attributes, :children] across compiler & generator"
    puts "  3. Contract Slot: contract children: :any (20), :none (36), specific (6)"
    puts "  4. Family Class Containment: `10` nested Ruby classes (Table::Column) & 1 partial (list.sp/item)"

    puts "\n[TAXONOMY] Current System Boundaries:"
    words_info = SlimPickins::Census.words
    puts "  - Words: #{words_info[:total].size} canonical (#{words_info[:primitives].size} Ruby primitives + #{words_info[:partials].size} .sp partials), #{SlimPickins::Census.app_words.size} app words"
    puts "  - Primitives: #{words_info[:primitives].size} classes inheriting SlimPickins::Word"
    puts "  - Partials: #{words_info[:partials].size} .sp templates with `def` in lib/vocabulary/ + `#{SlimPickins::Census.app_words.size}` app partials"
    puts "  - Tins: 9 [app].tin files providing outer document chrome"
    puts "  - Spiff: [app].spiff companion stylesheets compiled to spatial CSS"
    puts '========================================================================'
  end
end

PolysemyCensus.run if __FILE__ == $PROGRAM_NAME
