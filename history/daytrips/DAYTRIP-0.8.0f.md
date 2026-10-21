# Daytrip 0.8.0f — Leveling the Path for 0.9 CRUD & Roadmap 0.8 Close

**Date:** 2026-10-21  
**Roadmap:** [ROADMAP-0.8.md](../../ROADMAP-0.8.md) (Phase 6 of 6, Roadmap 0.8 Close)

## Premise & Measurement

1. **Form Containment & Validation Feedback:** Roadmap 0.9 targets `examples/portfolio` as the authentic SQLite-backed CRUD & state-mutation stretch exam. However, `Form`'s restrictive child contract (`children: [:group, :field, ...]`) rejected feedback affordances (`note`, `flash`), grouping structure (`section`, `box`), and app composed words needed for validation errors and multi-part flows. Furthermore, `Form#evaluate` called `prune(children, empty)`, which wiped out input fields when a form was instantiated for a new, unpersisted record.
2. **Modifier Harmonization on `Field` and `Input`:** `Field` and `Input` exhibited modifier asymmetry: `Field` took `required:` and `step:` but lacked `placeholder:`, while `Input` took `placeholder:` but lacked `required:` and `step:`.
3. **Empty Collection Pruning Scope:** `empty` pruning was previously invoked at the top-level route/page (`Builder#render`), where an empty collection at the page level caused `prune(body, empty)` to delete sibling toolbars (`actions`) and sibling creation forms (`form`) on the same page. In `.sp`, a collection's empty state belongs to the collection's enclosing container (`section` or `box`), and must not leak to prune page-level siblings.

## What Changed

1. **Widened `Form` Child Contract & Retired Form Pruning:**
   - In `lib/slim_pickins/words.rb`: updated `Form`'s contract to `children: :any` (matching `Group`, `Box`, `Tab`, and `Grid`), permitting `<form>` to enclose `note`, `flash`, `section`, `box`, and app composed words while structural constraints on child-only words (`column`, `band`, `option`) remain enforced by their own `parents` contracts.
   - In `Form#evaluate`: removed `prune(children, empty)`. Form input fields and controls are never pruned when a form's record is new or empty.
   - Regenerated `docs/VOCABULARY.md` bullets via `bin/generate_vocabulary.rb`.

2. **Harmonized `Field` and `Input` Modifiers:**
   - In `lib/slim_pickins/words.rb`:
     - Added `placeholder:` to `Field`'s contract and forwarded `placeholder: @kwargs[:placeholder]` to `Node[:field, ...]`.
     - Added `required:` and `step:` to `Input`'s contract and forwarded `step: kv.step(@kwargs[:step])` and `required: @kwargs[:required]` to `Node[:input, ...]`.
   - In `lib/slim_pickins/generator.rb`:
     - `Generator#field`: renders `placeholder: attrs[:placeholder]&.to_s`.
     - `Generator#input`: renders `placeholder: attrs[:placeholder]&.to_s`, `step: attrs[:step]`, and `required: attrs[:required] ? 'required' : nil`.
   - In `lib/slim_pickins/promises.rb`:
     - Updated `declared_by:` for `placeholder:` to `%i[field input search]`.
     - Updated `declared_by:` for `required:` to `%i[field input textarea]`.
     - Updated `declared_by:` for `step:` to `%i[field input]`.

3. **Scoped `empty` Pruning to Collection Containers:**
   - In `lib/slim_pickins/builder.rb`:
     - In `define_single_local_word`: ensured composed words (such as `section`) prune their captured block (`prune(capture(&caller_block), empty_active?)`) when evaluated under an empty collection, so empty collections cleanly prune their tables and grids while preserving the empty message.
     - In `Builder#render`: prevented `@empty_active = false if Inference.collection?(value)` from globally marking the route as empty, and restricted top-level body pruning so that a page containing an empty collection does not prune sibling creation forms or toolbars.
   - In `examples/publication/app.rb`: updated `locals_for('entry')` to select the first entry that mentions vocabulary words, ensuring `chips` renders for layout scope verification now that `section words` properly prunes when words are absent.

4. **Dedicated Verification & Tests:**
   - Added `test_form_encloses_feedback_structure_and_composed_words` in `test/contract_test.rb`.
   - Added `test_field_and_input_modifier_harmonization` in `test/contract_test.rb`.
   - Added `test_empty_pruning_scoped_to_collection_container_leaves_siblings_intact` in `test/contract_test.rb`.
   - Added `test_form_may_hold_feedback_and_structure_words` in `test/contracts_test.rb`.

## Verification

- All 12 gate legs + pedagogy: **0 problems** (12/12 PASS on `StudioStatus.run`).
- Verified pages (`bin/verify_pages.rb`): **30 pages verified, 0 problems**.
- Full test suite: **644 runs, 6,922 assertions, 0 failures, 0 errors, 0 skips**.
