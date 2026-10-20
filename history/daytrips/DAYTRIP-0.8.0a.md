# Daytrip 0.8.0a — Heal `metric` and `fact`, and retire the runtime duplicates

**Status: built and verified (2026-10-20).** The first movement of Roadmap 0.8
([ROADMAP-0.8.md](../../ROADMAP-0.8.md)), curing the composed-word dispatch in
`Builder` and `PartialWord` and repairing the label-corruption bugs in `metric`
and `fact`.

## The findings

1. **`metric` and `fact` disagreed on their second parameter and corrupted labels:**
   - `lib/vocabulary/metric.sp` was `def metric attribute, label` with a hardcoded
     `tag h3, .label, class: "metric-label"` that ignored `@box_level` depth.
   - `lib/vocabulary/fact.sp` was `def fact attribute, value`.
   - In `Builder#define_single_local_word`, bare `metric <attr>` hit `builder.rb:209`
     (`if contract&.name == :attribute && content_val.nil?`), which assigned
     `bound[:label] = subject.fetch(name_val)` and overwrote the label with the
     metric's numeric value (`<h3 class="metric-label">6</h3><div class="metric-value">6</div>`
     in `document_card.sp`).
   - Conversely, two-argument `fact <name>, <value>` (`fact words, .word_count`,
     `fact precedence, "four tiers"`, `fact silent, .when_silent`) hit
     `builder.rb:198` (`bound[:label] ||= label_for(name_val, raw_content)`),
     which treated the second positional argument (`value`) as the label override
     and overwrote `<dt>` with `<dd>` across seven files.
   - Single-argument dotted calls (`metric .reading_minutes`, `fact .speech_name`,
     `fact .origin`) evaluated `subject.<attr>` before entering the word and lost
     the attribute symbol, falling back to `"Metric"` or repeating the value as
     the `<dt>` term.
2. **Three runtime copies existed for `.sp` words:**
   - `Builder#define_single_local_word` carried hardcoded `if word_name == :fact`,
     `elsif word_name == :metric`, and `elsif word_name == :snippet` blocks plus
     `!%i[fact metric].include?(word_name)` special cases.
   - `PartialWord` duplicated 180 lines of parameter and contract resolution (including
     unreachable copies of the `:fact`, `:metric`, and `:snippet` branches).
   - `Generator#fact`, `Generator#metric`, and `Generator#snippet` were dead methods
     left behind after those words promoted to `lib/vocabulary/*.sp`.

## What landed

- **Unified `metric` and `fact` signature and depth-aware heading:**
  - `lib/vocabulary/metric.sp` is now `def metric attribute, value / box / heading .label / tag div, .value, class: "metric-value"`.
  - `heading .label` inside `box` uses `Generator#heading`'s `@box_base` convention
    (`metric-title` at `@box_level + 1`: `<h2>` at root, `<h3>` inside `section` or
    `card`, `<h4>` inside both).
  - `lib/slim_pickins/assets/slim-pickins.css` styles `.metric-title` in place of
    `.metric-label`.
  - Both `fact` and `metric` declare `modifiers: %i[as label]` in
    `VocabularyShapes::CANONICAL_MODIFIERS` (`lib/slim_pickins/contracts.rb`),
    with `Promises::ALL` (`lib/slim_pickins/promises.rb`) recording `label:` and
    updating `as:` (promises 32 → 33).
- **Contract-driven attribute/value/label resolution and dotted-fetch provenance:**
  - `Subject#fetch` (`lib/slim_pickins/subject.rb`) notifies `@builder&.note_fetch(attribute, self, result)`,
    reset per sentence in `Builder#with_line`, so dotted single-argument calls
    (`metric .reading_minutes`, `fact .speech_name`, `fact .origin`) recover both
    the attribute name and the originating subject's `label_for` / `format_for`.
  - `Builder#evaluate_word_definition` resolves any word with `contract.name == :attribute`
    and `content_param == :value` (`fact` and `metric`) purely from its contract,
    with zero `word_name ==` branches.
- **Single compilation/execution path and dead-code retirement:**
  - Removed `Generator#fact`, `Generator#metric`, and `Generator#snippet` from
    `lib/slim_pickins/generator.rb`.
  - Collapsed `PartialWord` (`lib/slim_pickins/partial_word.rb`, 239 → 23 lines)
    to delegate directly to `Builder#evaluate_word_definition`.
- **Callers and corpus repaired:**
  - `Publication::Entry` (`examples/publication/lib/lore.rb`) now includes
    `Described` (`labels reading_minutes: 'Minutes'`), and `document.sp`,
    `entry.sp`, `portfolio/views/index.sp`, `specimen.sp`, `task_card.sp`, and
    `question_card.sp` drop redundant label/value arguments.
  - Regenerated `docs/VOCABULARY.md` (`ruby bin/generate_vocabulary.rb`), updated
    `docs/PRIMER.md`, `docs/ONTOLOGY.md`, `lib/slim_pickins/taxonomy.rb`,
    `README.md`, `HANDOFF.md`, and added regression tests in `test/phase4_test.rb`
    and `test/demand_round2_test.rb`.

## Verification

- All 12 gate legs + `checkers/check_pedagogy.rb` green (0 problems).
- Full test suite green: 658 runs, 7,087 assertions, 0 failures, 0 errors, 0 skips.
