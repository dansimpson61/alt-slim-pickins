#!/usr/bin/env ruby
# frozen_string_literal: true
#
# The resume card's frontmatter, held by the gate.
#
# `PROJECT.md` is the most-read file in the project — every session starts by
# reading it, or by reading the dashboard's rendering of it — and until now its
# validity was held by a human remembering RIF step 4. A colon-space in the
# status scalar broke it four times (2026-09-16 twice, 2026-09-17 twice); each
# time the checker was memory. Four bites is enough evidence that a truth held
# by remembering is not held (DAYTRIP-0.3.0b).
#
#   - the frontmatter parses as YAML, and the field that failed is named
#   - every field the dashboard needs is present and not empty
#   - `last_touched` is a date, because the dashboard reads it as one
#   - `docs`, when it names a file, names one that exists
#
# Exits non-zero when anything is wrong, so it can gate a commit.

require 'date'
require 'yaml'

root = File.expand_path('..', __dir__)
path = File.join(root, 'PROJECT.md')
problems = 0

unless File.file?(path)
  puts '  NO CARD      PROJECT.md is not there — every session starts by reading it'
  puts "\n1 problems"
  exit 1
end

# The dashboard needs everything below; a card missing one fails silently in the
# GUI, which is worse than failing here.
REQUIRED = %w[schema_version id purpose status kind last_touched next_step].freeze

source = File.read(path)
frontmatter = source[/\A---\n(.*?)\n---/m, 1]
unless frontmatter
  puts '  NO FRONTMATTER  PROJECT.md does not open with a `---` block'
  puts "\n1 problems"
  exit 1
end

card =
  begin
    YAML.safe_load(frontmatter, permitted_classes: [Date])
  rescue Psych::SyntaxError => e
    # The colon-space lives here. Naming the line and the column, in the card's
    # own terms, is the whole reason this script exists.
    puts "  UNPARSEABLE  the frontmatter is not valid YAML — #{e.message.lines.first.strip}"
    puts "               (a colon followed by a space inside an unquoted value is the usual cause;"
    puts '                quote the value, or use a dash)'
    problems += 1
    nil
  end

if card
  unless card.is_a?(Hash)
    puts '  NOT A MAPPING  the frontmatter parsed, but not into fields'
    problems += 1
    card = nil
  end
end

if card
  REQUIRED.each do |field|
    value = card[field]
    next unless value.nil? || value.to_s.strip.empty?

    puts "  MISSING FIELD  `#{field}` is required by the dashboard and is absent or empty"
    problems += 1
  end

  last = card['last_touched']
  unless last.is_a?(Date) || last.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
    puts "  NOT A DATE     `last_touched` is #{last.inspect} — the dashboard reads it as a date"
    problems += 1
  end

  docs = card['docs']
  if docs && !File.file?(File.join(root, docs.to_s))
    puts "  NO DOCS FILE   `docs` names #{docs.inspect}, which is not there"
    problems += 1
  end
end

puts
if problems.zero?
  puts "resume card — #{REQUIRED.size} fields present, last_touched #{card['last_touched']}, status #{card['status'].to_s.length} chars"
end
puts "#{problems} problems"
exit(problems.zero? ? 0 : 1)
