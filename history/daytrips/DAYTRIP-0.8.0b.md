# Daytrip 0.8.0b — The `KeyValue` Spine & Native `kwargs`

**Date:** 2026-10-20
**Roadmap:** [ROADMAP-0.8.md](../../ROADMAP-0.8.md) (Phase 2 of 6)

## Premise & Measurement

Every attribute-bearing word in Slim-Pickins asks the same four questions of a
datum: **`key`**, **`label`**, **`value`**, and **`format`**. Before this
daytrip, those four questions were re-derived across seven open-coded paths:

1. `Builder#evaluate_word_definition` had a 42-line special block for
   attribute-and-value words (`fact`, `metric`).
2. `Words::Table` and `Builder#label_of`, `Builder#format_of`, and
   `Builder#alignment_of` maintained a separate copy of the three-tier
   label/format precedence rules over raw column Hashes.
3. `Words::Chart#resolve` fabricated a fake table-column Hash (`{ name:,
   header: }`) to call `Builder#label_of` and open-coded `format_for`.
4. `Words::Field`, `Input`, `Textarea`, `Checkbox`, `Choice`, and `Hidden` each
   open-coded their own `(name, value, label, kind, step)` resolution.
5. `Subject#has?` / `Subject#fetch` and `Words::Dictionary.find_entry` carried
   separate multi-branch loops to normalize `Symbol`/`String`/`boolean`/`nil`
   keys.
6. `Words::Each` and `Builder#collection_for` refused to iterate a native Ruby
   `Hash`.
7. `VocabularyShapes#infer_from_def` in `lib/slim_pickins/contracts.rb` declared
   an unused `modifiers = []` local and hardcoded `CANONICAL_MODIFIERS` for 12
   `.sp` words because `Transform` did not parse keyword modifier declarations
   on `def` lines, while `lib/slim_pickins/words.rb` repeated
   `@kwargs.key?(:x) ? @kwargs[:x] : nil` 24 times.

## What Changed

1. **`SlimPickins::KeyValue` (`lib/slim_pickins/key_value.rb`):**
   - Introduced `SlimPickins::KeyValue` as the single home for **`key`**,
     **`label`**, **`value`**, and **`format`**, plus `raw_value`,
     `formatted_value`, `alignment`, `input_type`, and `step`.
   - Updated the three `:domain` entries in `lib/slim_pickins/conventions.rb`
     (`:label`, `:format`, `:table_header`) to point to their unified home in
     `lib/slim_pickins/key_value.rb`.
   - Routed `Builder#evaluate_word_definition` (`metric`, `fact`), `Words::Table`
     (`Column`, `Total`), `Words::Chart` (`Band`, `Line`), and the form words
     (`Field`, `Input`, `Textarea`, `Checkbox`, `Choice`, `Hidden`) through
     `KeyValue`.
   - Retired `Builder#label_of` and `Builder#alignment_of` (and their delegators
     in `Word`), and reduced `Builder#label_for` and `Builder#format_of` to
     one-line delegates to `KeyValue`.

2. **Native `Hash` iteration in `Each` & shared indifferent key lookup:**
   - Updated `Builder#collection_for` and `Words::Each#evaluate` so a native Ruby
     `Hash` can be iterated with `each`, yielding each `[k, v]` entry as a
     `KeyValue` (while a `Hash` shifted into by `section` or `box` remains a
     keyed subject).
   - Allowed zero-argument `metric` / `fact` calls when the current subject on
     `@chain` is already a `KeyValue` (`each top_word / metric`).
   - Extracted `KeyValue.hash_has?` and `KeyValue.hash_fetch` to unify
     `Symbol`/`String`/`boolean`/`nil` key lookup across `Subject` and
     `Words::Dictionary.find_entry`.

3. **Native `kwargs` in `.sp` `def` headers & `Words`:**
   - Updated `Transform#build` and `Transform#emit` so `def` lines in `.sp` can
     declare keyword modifiers (`key:` or `key: default`), passing any defaults
     to `Builder#define_local_word`.
   - Updated `action.sp`, `card.sp`, `disclosure.sp`, `fact.sp`, `metric.sp`,
     `money.sp`, `number.sp`, `percent.sp`, and `search.sp` in `lib/vocabulary/`
     to declare their modifiers in their `def` headers.
   - Updated `VocabularyShapes#infer_from_def` to read declared modifiers
     directly from the `def` header and deleted `CANONICAL_MODIFIERS` from
     `lib/slim_pickins/contracts.rb`.
   - Replaced the `@kwargs.key?(:x) ? @kwargs[:x] : nil` ternary lines across
     `lib/slim_pickins/words.rb` with direct `@kwargs[:x]` lookups.

## Verification

- All 12 gate legs + `checkers/check_pedagogy.rb`: **0 problems**.
- Full test suite: **661 runs, 7,102 assertions, 0 failures, 0 errors, 0 skips**.
