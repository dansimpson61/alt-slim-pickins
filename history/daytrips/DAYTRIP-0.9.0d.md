# Daytrip 0.9.0d — Field Validation Diagnostics & Dirty Form Re-rendering

**Date:** 2026-10-21  
**Roadmap:** [ROADMAP-0.9.md](../../ROADMAP-0.9.md) (Phase 4 of 6, Healing Wall 2)

## Premise & Measurement

1. **Wall 2 (Field Validation Diagnostics on 422 Unprocessable Entity):** In a dense analytical and transactional workbench, form submission failures must present immediate, granular, accessible feedback beside the offending controls without requiring custom JavaScript or bespoke CSS.
2. Previously, `Field` and `Input` had no mechanism to convey validation errors. Models with validation failures could not mark fields as invalid, announce errors via assistive technology, or render error messages without manual presentation boilerplate.
3. The language requires an honest, convention-based inference: `KeyValue` queries `error:`, then falls back to `subject.error_for(key)` or `subject.errors[key]`, emitting `.field--invalid`, `aria-invalid="true"`, `aria-describedby="#{name}-error"`, and `<span class="field-error">`.

## What Changed

1. **`KeyValue#error` & Inferred Diagnostics:**
   - In `lib/slim_pickins/key_value.rb`:
     - Added `attr_reader :given_error` and `error` parameter to `initialize`.
     - Implemented `KeyValue#error`: checks explicit `@given_error`, then queries `@subject.error_for(@key)` or `@subject.errors[@key]` (handling arrays and string error messages cleanly).
     - Updated `KeyValue.for_control` to pass `error: kwargs[:error]` to `new(...)`.
     - Updated `KeyValue#to_h` to include `:error`.

2. **Word Contracts & Generator:**
   - In `lib/slim_pickins/words.rb`:
     - Added `:error` to declared modifiers for `Field` and `Input`.
     - Added `:field_error` to declared inferences (`infers:`) on `Field` and `Input`.
     - Evaluated `error: kv.error` into AST node attributes for `:field` and `:input`.
   - In `lib/slim_pickins/generator.rb`:
     - In `Generator#field`: when `error` is present, renders `class="field field--invalid"`, adds `aria-invalid="true"`, `aria-describedby="#{name}-error"`, and emits `<span class="field-error" id="#{name}-error">#{error}</span>`.
     - In `Generator#input`: renders `aria-invalid="true"` and `aria-describedby="#{name}-error"` when `error` is present.

3. **Stylesheet Tokenization:**
   - In `lib/slim_pickins/assets/slim-pickins.css`:
     - Added `.field--invalid input, .field--invalid select, .field--invalid textarea { border-color: var(--negative); }`.
     - Added `.field-error { display: block; color: var(--negative); font-size: var(--size-small); margin-top: var(--step); }`.
     - Preserved theme purity: zero bespoke CSS or unthemed pixel literals. Rules defined increased from 113 to 115.

4. **Registers & Living Vitals:**
   - In `lib/slim_pickins/promises.rb`: added `Promise.new(name: :error, kind: :modifier, declared_by: %i[field input], ...)` (promises incremented from 33 to 34).
   - In `lib/slim_pickins/conventions.rb`: added `Convention.new(name: :field_error, ...)` under domain conventions (conventions incremented from 38 to 39).
   - Regenerated vocabulary documentation using `bin/generate_vocabulary.rb`.
   - Updated living vitals across `HANDOFF.md`, `PROJECT.md`, `README.md`, `docs/CONVENTIONS.md`, `docs/ONTOLOGY.md`, `docs/PRIMER.md`, `lib/slim_pickins/taxonomy.rb`, and `test/census_test.rb`.

5. **Portfolio Workbench Forms & Routes:**
   - Added `examples/portfolio/views/new_account.sp`: clean form with validation note, required attributes, placeholders, and choice selector.
   - Added `examples/portfolio/views/edit_account.sp`: patch form bound to existing account with method override and validation.
   - Wired `GET /accounts/new`, `POST /accounts`, `GET /accounts/:id/edit`, and `PATCH /accounts/:id` in `examples/portfolio/app.rb` with 422 status and dirty form re-rendering on invalid input.
   - Added `new_account.sp` and `edit_account.sp` to `bin/verify_pages.rb` and `studio/pages.rb` (verified pages incremented from 31 to 33).
   - Added integration and unit tests across `test/phase4_test.rb` and `test/phase6_test.rb`.

## Verification

- All 12 gate legs: **0 problems** (12/12 PASS).
- 33 verified pages: **0 problems** (`bin/verify_pages.rb`).
- Full test suite: **660 runs, 7,059 assertions, 0 failures, 0 errors, 0 skips**.
