# Daytrip 0.5.0d — Retiring `expects` Across the Vocabulary

**Status: closed.** Migrated all remaining 19 canonical vocabulary partials from `expects` to `def <word>, *params`, retiring `expects` entirely from the 28 partial files across the repository (5 in `studio/`, 23 in `lib/vocabulary/`). All twelve gate legs green, 35 verified pages byte-identical, 0 drift in `VOCABULARY.md`, full test suite at 630 runs, 6,810 assertions, 0 failures (+88 assertions from expanded contract inference proof).

**Baseline:** all twelve gate legs green, 35 verified pages byte-identical, and the test suite at 630 runs, 6,722 assertions, 0 failures, at commit `1896958`.

---

## Census: The 19 Remaining Vocabulary Partials

Following Daytrip 0.5.0c (which migrated the 5 studio furniture partials and the first 4 vocabulary leaf presenters: `flash`, `text`, `note`, `badge`), exactly 19 partials remained carrying `expects`:

1. `aside.sp`: `def aside, variant \n box .variant \n children`
2. `figure.sp`: `def figure, caption \n box \n children \n tag figcaption, .caption`
3. `footer.sp`: `def footer, content \n box .content \n children`
4. `list.sp`: `def list, variant \n box .variant \n children`
5. `scroll.sp`: `def scroll, variant \n box .variant \n children`
6. `empty.sp`: `def empty, message \n paragraph .message`
7. `disclosure.sp`: `def disclosure, summary \n box open: .open \n tag summary, .summary \n children`
8. `money.sp`: `def money, amount \n span .amount, precision: .precision`
9. `number.sp`: `def number, amount \n span .amount, precision: .precision`
10. `percent.sp`: `def percent, ratio \n span .ratio, precision: .precision`
11. `time.sp`: `def time, variant, content \n span .variant, .content`
12. `title.sp`: `def title, attribute, content \n heading .content`
13. `paragraph.sp`: `def paragraph, variant, content \n tag p, .content, variant: .variant \n children`
14. `item.sp`: `def item, variant, content \n box .variant, .content \n children`
15. `action.sp`: `def action, label \n choose \n when .status ...`
16. `actions.sp`: `def actions \n box \n form method: post ... children`
17. `search.sp`: `def search \n choose \n when .to ...`
18. `card.sp`: `def card, subject, content \n box .variant, id: .id ... children`
19. `section.sp`: `def section, subject, content \n box .name \n choose \n when .label ... children`

---

## The Four Stages

### Stage 1: Runtime Support in `Builder#define_local_word` and `bind_parameters`
1. Re-aligned `Builder.bind_parameters` with slim-pickins' foundational law: "Names are Symbols, content is anything else. This is why argument order never has to be counted."
   - When a word has a contract taking name and content, Symbol arguments map to the name parameter and non-Symbol arguments map to the content parameter.
   - Positional mapping remains the fallback for untyped app words.
2. Preserved subject shift targets and name symbols as raw symbols instead of prematurely evaluating them against the parent subject.
3. Supported automatic runtime inference for:
   - `id` (`contract&.id`): derives DOM `id` via `card_id` or `noun-id`.
   - `label` (`contract&.label`): derives human label via `label_for`.
   - `variant` (`contract&.modifiers&.include?(:variant)`): derives variant when symbol is not an attribute of subject.
   - `modifiers` (`contract&.modifiers`): defaults undeclared modifiers to `chain.container_value(modifier)` or `nil`.
   - `empty` (`contract&.empty`): skips evaluation and returns `[]` when `!empty_active?`.
   - `landing` of procs: evaluates procs passed to content (e.g. `section account, .name`) inside `about(shift_target)` so expressions resolve against the shifted subject.
   - `attribute` resolution: fetches attribute value for bare symbols on subject when `contract.name == :attribute` (`title word_name`).
   - `children` splicing: defaults captured blocks to `[]` so partials like `footer` can be called without children blocks.

### Stage 2: Migrate Batch 2 (14 Containers & Leaf Words)
1. Migrated `aside.sp`, `figure.sp`, `footer.sp`, `list.sp`, `scroll.sp`, `empty.sp`, `disclosure.sp`, `money.sp`, `number.sp`, `percent.sp`, `time.sp`, `title.sp`, `paragraph.sp`, and `item.sp`.
2. Added `CANONICAL_MODIFIERS` table to `VocabularyShapes` in `lib/slim_pickins/contracts.rb` to ensure exact modifier ordering for canonical words.

### Stage 3: Migrate Batch 3 (5 Complex Presenters & Shifts)
1. Migrated `action.sp`, `actions.sp`, `search.sp`, `card.sp`, and `section.sp`.
2. Updated `StudioDocs.examples` indexer in `studio/docs_helper.rb` to traverse the body of vocabulary `def` blocks, ensuring vocabulary words defined in terms of other vocabulary words (e.g. `title.sp` using `heading`) retain verified wild usage citations and try seeds.

### Stage 4: Retiring `expects` and Final Gate Verification
1. Confirmed 0 partial files in `lib/vocabulary/` and `studio/` contain `expects`.
2. Expanded `test_def_data_flow_inference_produces_identical_contracts` in `test/contracts_test.rb` to assert that every single file in `lib/vocabulary/*.sp` declares with `def` and infers a contract identical to its canonical contract.
3. Verified full test suite: 630 runs, 6,810 assertions, 0 failures.
4. Verified all twelve gate legs live: all green.
5. Verified byte-identity: 35 pages verified, 0 problems.
6. Verified vocabulary documentation: 0 drift under `bin/generate_vocabulary.rb`.

---

## Verification

- Full test suite: 630 runs, 6,810 assertions, 0 failures (+88 assertions from comprehensive 23-partial contract inference proof).
- All 12 gate legs green (`check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, `check_spiff.rb`, `check_spiff_scope.rb`, `bin/check_promises.rb`, `bin/check_conventions.rb`, `bin/check_card.rb`, `bin/verify_pages.rb`, `check_vitals.rb`, `check_ruby.rb`, `Suite`).
- 35 verified pages byte-identical under `bin/verify_pages.rb` (0 problems).
- 0 drift in `VOCABULARY.md` bullets under `bin/generate_vocabulary.rb`.
- `check_ruby.rb` clean across 128 files (0 problems).
- `check_vitals.rb` clean across 40 prose claims (0 problems).
