# Daytrip 0.8.0d — Word-by-Word Audit, Composed-Word Harmonization & Dead Variant Retirement

**Date:** 2026-10-20  
**Roadmap:** [ROADMAP-0.8.md](../../ROADMAP-0.8.md) (Phase 4 of 6)

## Premise & Measurement

1. **Word-name compiler crutches in `contracts.rb`:** `VocabularyShapes#infer_from_def` in `lib/slim_pickins/contracts.rb` carried hardcoded word-name branches (`(param == :target && %i[card section].include?(word_sym))` and `(param == :target && word_sym == :title)` and line 225's `|| word_sym == :card || word_sym == :section`) because `card.sp`, `section.sp`, and `title.sp` declared `target` in their parameter lists rather than self-describing slot names (`subject` and `attribute`).
2. **Dead `variant` declarations:** An audit of all 14 words declaring `variant` in their contracts or `def` headers showed that `aside`, `scroll`, `item`, and `tabs` had zero CSS rules and zero callers passing variants. Their `variant` slots were dead declarations.
3. **Explicit `def` headers on studio partials:** Partials in `studio/shared/partials/` and `studio/uis/` (classic and workbench) lacked explicit `def` headers (`panes.sp`, `editor.sp`, `library.sp`, etc.), relying on anonymous `PartialWord` wrapper classes instead of compiling directly into `Builder` local word definitions.

## What Changed

1. **Harmonized `card.sp`, `section.sp`, and `title.sp` parameter signatures:**
   - Updated `lib/vocabulary/card.sp` to `def card subject, title, variant:`.
   - Updated `lib/vocabulary/section.sp` to `def section subject, heading`.
   - Updated `lib/vocabulary/title.sp` to `def title attribute, text`.
   - Removed all hardcoded word-name branches from `VocabularyShapes#infer_from_def` in `lib/slim_pickins/contracts.rb`:
     - `param == :subject` directly maps `name_slot = :subject` and `subject_action = :shift`.
     - `param == :attribute` directly maps `name_slot = :attribute`.
   - Regenerated `docs/VOCABULARY.md` bullets via `bin/generate_vocabulary.rb` and updated prose references in `docs/VOCABULARY.md` and `docs/PRIMER.md`.

2. **Retired dead `variant` declarations:**
   - `lib/vocabulary/aside.sp`: simplified to `def aside \n box`.
   - `lib/vocabulary/scroll.sp`: simplified to `def scroll \n box`.
   - `lib/vocabulary/list.sp`: simplified `item` to `def item content \n box .content \n contents`.
   - `lib/slim_pickins/words.rb`: updated `Tabs` contract to `contract children: :any, shape: :encloses`, dropping dead `name: :variant`.
   - In `docs/VOCABULARY.md`: `aside`, `scroll`, `item`, and `tabs` now declare `- **name** — none` (verified by `bin/generate_vocabulary.rb`).

3. **Explicit `def` headers on all studio UI partials:**
   - `studio/shared/partials/panes.sp`: `def panes \n box`.
   - `studio/uis/classic/views/partials/`: added `def` headers to `editor.sp`, `editor_form.sp`, `html_preview.sp`, `palette.sp`, `preview.sp`, `try_it.sp`, and `vocabulary.sp`.
   - `studio/uis/workbench/views/partials/`: added `def` headers to `editor.sp`, `library.sp`, `main_menu.sp`, `output.sp`, `ui_picker.sp`, and `word_docs.sp`.
   - Updated `studio/docs_helper.rb` so `StudioDocs.examples` visits inside `def` blocks anywhere in the corpus, indexing examples that live inside composed words.

4. **Robustness in `Subject` and `Builder`:**
   - In `SlimPickins::Subject#has?`: added a guard ensuring `attribute` is a `Symbol` or `String`, preventing `TypeError` on Structs or non-primitive objects.
   - In `SlimPickins::Builder#evaluate_word_definition`: ensured `bound[:variant]` only inspects `name_val` when it is a `Symbol`.

## Verification

- All 12 gate legs + pedagogy: **0 problems**.
- Verified pages (`bin/verify_pages.rb`): **34 pages verified, 0 problems**.
- Full test suite: **662 runs, 7,108 assertions, 0 failures, 0 errors, 0 skips**.
