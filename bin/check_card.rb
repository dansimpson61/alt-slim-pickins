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
#   - the prose fields are inside their budgets
#
# Exits non-zero when anything is wrong, so it can gate a commit.

# The budgets, and why a resume card has them.
#
# The card is read at the start of every session so that a session can resume
# *instead of* reading the repository. A card that costs more to read than the part
# of the repo it describes has stopped doing that — and by 2026-10-03 this one had:
# `status` was 20,000 characters and `notes` 9,060, together longer than
# `transform.rb`, `builder.rb` and `generator.rb` combined, in a single folded YAML
# scalar with no paragraph breaks. DAYTRIP-0.4.0h named it "the same disease in the
# instrument built to stop it", and this script printed `status 11145 chars` on
# every green run and had no opinion about it.
#
# It has one now. The numbers are a judgement, not a measurement: roughly a
# minute's reading each, which is proportionate to a field read before every
# session. `next_step` gets the most because it is the operative field — the one
# thing a session must act on. They are dan's to change, and changing them is one
# line.
#
# What overflows does not get deleted. The round-by-round account went to
# `history/CHRONICLE.md` verbatim, because sampling found none of it anywhere else
# in the repository — the assumption that it duplicated the `DAYTRIP-*.md` files
# was false, and a budget that invites deletion of the only copy of something is a
# worse instrument than no budget at all.
BUDGETS = { 'status' => 1_500, 'next_step' => 2_000, 'notes' => 1_500 }.freeze

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

  BUDGETS.each do |field, budget|
    length = card[field].to_s.length
    next if length <= budget

    puts "  OVER BUDGET    `#{field}` is #{length} chars against a budget of #{budget} — a card that " \
         'costs more to read than the repo it stands in for has stopped working'
    puts '                 (move the overflow somewhere it can be read; do not delete it)'
    problems += 1
  end
end

puts
if problems.zero?
  room = BUDGETS.map { |field, budget| "#{field} #{card[field].to_s.length}/#{budget}" }.join(', ')
  puts "resume card — #{REQUIRED.size} fields present, last_touched #{card['last_touched']}, #{room}"
end
puts "#{problems} problems"
exit(problems.zero? ? 0 : 1)
