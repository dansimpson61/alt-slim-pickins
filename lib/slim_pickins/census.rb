# frozen_string_literal: true

require 'set'
require_relative '../slim_pickins'
require_relative 'promises'
require_relative 'conventions'

module SlimPickins
  # The Single Source of Truth for repository facts and vitals.
  #
  # Built in DAYTRIP-0.4.0a to stop the perpetual manual editing and drift of
  # perishable numbers across documentation surfaces. This module dynamically
  # computes the living census directly from the tree.
  module Census
    ROOT = File.expand_path('../..', __dir__)
    CSS_PATH = File.join(ROOT, 'assets', 'slim-pickins.css')

    module_function

    def words
      SlimPickins::Library.builtin
      primitives = SlimPickins::Word.registry.select do |_word, klass|
        klass.name.to_s.start_with?('SlimPickins::Words::')
      end.keys
      partials = Dir[File.join(ROOT, 'lib', 'vocabulary', '*.sp')].map do |f|
        File.basename(f, '.sp').to_sym
      end
      {
        primitives: primitives.sort,
        partials: partials.sort,
        total: (primitives + partials).uniq.sort
      }
    end

    def app_words
      Dir[File.join(ROOT, '**', 'partials', '*.sp')]
        .reject { |f| f.include?('/lib/vocabulary/') }
        .map { |f| File.basename(f, '.sp').to_sym }
        .uniq
        .sort
    end

    def apps
      Dir[File.join(ROOT, 'examples', '*', 'app.rb')].map do |f|
        File.basename(File.dirname(f)).to_sym
      end.sort
    end

    def verified_pages_count
      verify_script = File.read(File.join(ROOT, 'bin', 'verify_pages.rb'))
      explicit_pages = verify_script.scan(/^\s*\['(pages|examples)\//).size
      mapped_pages = verify_script.scan(/%w\[portfolio_table account_detail roth_form specimen\]/).any? ? 4 : 0
      studio_count = verify_script.include?('*STUDIO_PAGES') ? 8 : 0
      explicit_pages + mapped_pages + studio_count
    end

    def styles
      css = File.read(CSS_PATH)
      selectors = css.gsub(%r{/\*.*?\*/}m, '').split('}').map { |rule| rule.split('{').first.to_s }
      defined_classes = selectors.join(' ').scan(/\.([a-z][a-z0-9_-]*)/).flatten.to_set

      {
        rules_defined: defined_classes.size
      }
    end

    def conventions_count
      SlimPickins::Conventions::ALL.size
    end

    def promises_count
      SlimPickins::Promises::ALL.size
    end

    def test_files
      Dir[File.join(ROOT, 'test', '**', '*_test.rb')] +
        Dir[File.join(ROOT, 'examples', '**', 'test', '**', '*_test.rb')]
    end

    def snapshot
      w = words
      s = styles
      {
        canonical_words: w[:total].size,
        ruby_primitives: w[:primitives].size,
        sp_partials: w[:partials].size,
        apps: apps,
        app_words: app_words.size,
        verified_pages: verified_pages_count,
        css_rules: s[:rules_defined],
        conventions: conventions_count,
        promises: promises_count,
        test_files: test_files.size
      }
    end

    def report
      s = snapshot
      [
        "Slim-Pickins Census (living SSOT):",
        "  words: #{s[:canonical_words]} canonical (#{s[:ruby_primitives]} Ruby primitives + #{s[:sp_partials]} .sp partials)",
        "  apps: #{s[:apps].size} (#{s[:apps].join(', ')})",
        "  app words: #{s[:app_words]} defined across apps and studio",
        "  verified pages: #{s[:verified_pages]} checked by verify_pages.rb",
        "  conventions: #{s[:conventions]} registered in SlimPickins::Conventions::ALL",
        "  promises: #{s[:promises]} tracked in SlimPickins::Promises::ALL",
        "  styles: #{s[:css_rules]} rules/classes defined in assets/slim-pickins.css",
        "  test suite: #{s[:test_files]} test files"
      ].join("\n")
    end
  end
end
