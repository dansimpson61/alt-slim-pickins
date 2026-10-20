# Daytrip 0.8.0c — Blockless `box` Default Splice & `.style` / `.layout` Token Handoff

**Date:** 2026-10-20  
**Roadmap:** [ROADMAP-0.8.md](../../ROADMAP-0.8.md) (Phase 3 of 6)

## Premise & Measurement

1. **`box` in container words (`def`):** In `.sp`, authors define container words (`def meta / box`, `def actions / box`) that wrap caller blocks and provide a semantic root element. Previously, `Words::Box#evaluate` when called without a block rendered an empty `Node[:box, ...]` unless an explicit `contents` was nested underneath it (`box \n contents`). This led to repeated boilerplate across the corpus (`def meta / box / contents`, `def chips / box / contents`, `def actions / box / contents`).
2. **`.style` and `.layout` token handoff:** `Compiler::Layout::TREATMENT_TOKENS` hardcoded fixed literals (`'max-width' => '65ch'`, `'line-height' => '1.7'` on `:editorial` and `'70ch'` / `'1.6'` on `:prose`), which silently clobbered the sayable theme roles (`measure wide`, `density airy`) compiled to `:root { --measure: 72ch; --lead: 1.7; }` by a surface's `.style` companion.
3. **Convention register and axiomatic grade:** The axiomatic grade in `lib/slim_pickins/conventions.rb` and `bin/check_conventions.rb` historically phrased its single entry as "recording an absence". With the `.style` companion resolving sayable theme roles and handing off to `.layout`, the axiomatic grade records an active theme-role convention.

## What Changed

1. **Blockless `box` splices `contents` by default in `Words::Box`:**
   - Updated `SlimPickins::Words::Box#evaluate` so that when called without a block (`unless @block`), if caller children have been spliced (`if spliced && first.nil?`), it yields `Node[:box, { variant: nil, body: nil, open: open, id: id }, spliced]`.
   - Updated `VocabularyShapes#infer_from_def` so a composed word whose primary body is a blockless `box` (`n.word == 'box' && n.children.empty? && n.raw_args.empty?`) is recognized as having `:any` children.
   - Dropped redundant `contents` lines under `box` in `def`s across the corpus (`lib/vocabulary/actions.sp`, `examples/publication/views/document.sp`, `examples/publication/views/entry.sp`, `studio/shared/partials/shell.sp`).
   - Added unit test `test_blockless_box_inside_def_splices_contents_by_default` in `test/def_test.rb`.

2. **Connected `.style` and `.layout` tokens in `Compiler::Layout::TREATMENT_TOKENS`:**
   - Updated `TREATMENT_TOKENS[:editorial]` to `'max-width' => 'var(--measure, 65ch)'` and `'line-height' => 'var(--lead, 1.7)'`.
   - Updated `TREATMENT_TOKENS[:prose]` to `'max-width' => 'var(--measure, 70ch)'` and `'line-height' => 'var(--lead, 1.6)'`.
   - Updated `docs/LAYOUT.md` and `test/layout_test.rb` to reflect the fallback-preserving CSS custom properties.

3. **Updated Convention Register and Axiomatic Check:**
   - Updated `Convention.new(name: :theme_roles, ...)` in `lib/slim_pickins/conventions.rb` to record that `:theme_roles` compiles to a `:root` custom property that governs `.layout` zones and base styles.
   - Updated `bin/check_conventions.rb` to record the theme-role decision.

## Verification

- All 12 gate legs + pedagogy: **0 problems**.
- Full test suite: **662 runs, 7,105 assertions, 0 failures, 0 errors, 0 skips**.
