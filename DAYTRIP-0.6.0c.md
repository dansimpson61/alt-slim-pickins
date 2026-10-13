# Daytrip 0.6.0c — Unifying the Splice Pronoun: Retiring `children` for `contents`

**Status: ready to close 2026-10-13, on dan's word.**

Fulfilling the third movement of Roadmap 0.6:
1. Unified template splicing under `contents`:
   - Retired `children` as a template keyword across all templates, partials, and tins.
   - Preserved clear conceptual boundaries: family containment speaks of *members*, collections speak of *items*, and template splicing universally speaks of *contents*.
   - Updated `Contents < Word` in `lib/slim_pickins/words.rb` to handle both caller block splicing in partials (`!spliced.nil?`) and stowed page node splicing in tins (`contents_stowed?`), raising `` `contents` belongs in a tin `` if neither applies.
   - Deleted the `Children < Word` class.
2. Migrated all template partials from `children` to `contents`:
   - All 11 vocabulary partials in `lib/vocabulary/`: `actions.sp`, `aside.sp`, `card.sp`, `disclosure.sp`, `figure.sp`, `footer.sp`, `list.sp`, `paragraph.sp`, `scroll.sp`, `section.sp`.
   - All 3 studio partials: `studio/shared/partials/panes.sp`, `studio/shared/partials/shell.sp`, `studio/uis/workbench/views/partials/word_docs.sp`.
   - Portfolio demo partial: `examples/portfolio/views/partials/card.sp`.
3. Updated Contracts, Taxonomy, and Census:
   - `lib/slim_pickins/contracts.rb`: Updated `VocabularyShapes.infer_from_def` to detect child-accepting partials when the AST contains `n.word == 'contents'`.
   - `lib/slim_pickins/words.rb`: Updated `Form` contract allowed children to replace `:children` with `:contents`.
   - `lib/slim_pickins/taxonomy.rb`: Removed `:children`, updated `:contents` role and notes.
   - `VOCABULARY.md`: Removed `### `children`` entry, updated `### `contents`` description, and aligned `form` children bullet.
   - `test/studio_try_test.rb`: Updated `STRUCTURAL` from `%w[contents children]` to `%w[contents]`, with try-it yield at 63 useful words (64 - 1).
4. Vitals & Prose Synchronized:
   - Canonical words settled at 64 (41 Ruby primitives + 23 `.sp` partials).
   - Noun words settled at 57 of 64.
   - Updated living prose across `README.md`, `PRIMER.md`, `PROJECT.md`, `DESIGN.md`, `HANDOFF.md`, and `VOCABULARY.md`.
   - Updated `test/check_vitals_test.rb` fixtures to test stale claims against 64.
5. All 12 gate legs green, 35 verified pages byte-identical, `check_ruby.rb` clean repo-wide, and full test suite passing with 0 failures (649 runs, 6,997 assertions, 0 failures).

**Baseline:** All twelve gate legs green, 35 verified pages byte-identical, test suite at 649 runs, 7,045 assertions, 0 failures, at commit `c21de1d`.
**Outcome:** All twelve gate legs green, 35 verified pages byte-identical, test suite at 649 runs, 6,997 assertions, 0 failures.

---

## Part 1 — Why Unify on `contents`

Prior to Daytrip 0.6.0c, template splicing had two words doing one job:
- Chrome files (`.tin`) spliced the stowed page nodes via `contents`.
- Partial definitions (`.sp`) spliced the caller's block via `children`.

This dual naming created confusion with three distinct meanings of "children":
1. AST children (nodes indented under a node in the parse tree).
2. Family containment (words permitted inside a parent's lexical scope, e.g. `when` inside `choose`).
3. Template splicing (inserting the caller's nodes into a component or layout).

By retiring `children` as a keyword:
- Family containment speaks of **members**.
- Collections speak of **items**.
- Template splicing universally speaks of **contents**.

Inside both partials and tins, an author says `contents` to splice what was passed into the template.

---

## Part 2 — Verification Matrix

| Instrument | Measurement | Verdict |
| :--- | :--- | :--- |
| `check_grammar.rb` | 1,351 sentences checked, 98 words defined | 0 problems (PASS) |
| `check_shape.rb` | 64 canonical words (57 nouns, 7 non-nouns) | 0 problems (PASS) |
| `check_styles.rb` | 28 classes emitted, 59 rendering, 113 rules | 0 problems (PASS) |
| `check_spiff.rb` | 16 lexicon entries, 84 documented declarations | 0 problems (PASS) |
| `check_spiff_scope.rb` | 3 spiffs, 15 compiled classes | 0 problems (PASS) |
| `bin/check_promises.rb` | 35 promises tracked | 0 problems (PASS) |
| `bin/check_conventions.rb` | 38 conventions registered | 0 problems (PASS) |
| `bin/check_card.rb` | 7 fields present, last_touched 2026-10-13 | 0 problems (PASS) |
| `bin/verify_pages.rb` | 35 pages across 8 apps and studio | 35 verified, 0 problems (PASS) |
| `check_vitals.rb` | 37 prose claims read across 10 docs & 131 Ruby files | 0 problems (PASS) |
| `check_ruby.rb` | `ruby -w -c` across 131 Ruby files | 0 problems (PASS) |
| `bin/census.rb` | 64 canonical words (41 Ruby primitives + 23 `.sp` partials) | 0 problems (PASS) |
| Test Suite (`Census.test_files`) | 649 runs, 6,997 assertions, 0 failures, 0 skips | 0 failures (PASS) |
| `StudioStatus.run` | 12 gate legs live | 12/12 PASS |
