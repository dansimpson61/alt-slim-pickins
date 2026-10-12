# Daytrip 0.5.0e — Shadowing Language Words & Portfolio Card

**Status: closed.** Fulfilling Criterion 4 of `ROADMAP-0.5.md` and shipping Dan's 2026-10-05 ruling:
1. Lifted the shadowing refusals in `Library#initialize` and `Library#refuse_shadowing!`, allowing an app partial or Ruby word to shadow a built-in language word within that app's own scope.
2. Updated the gate (`check_shape.rb`) to report shadowed language words cleanly (`shadowed language words: card (portfolio)`).
3. Migrated the portfolio app's `account_card` partial to plain `card` (`examples/portfolio/views/partials/card.sp`).
4. Updated `examples/portfolio/views/index.sp` and `examples/portfolio/views/account.sp` to invoke `card`.
5. Rendered all touched portfolio pages before and after, presenting the diffs directly to Dan.
6. Maintained library containment in `studio/pages.rb` (`StudioPages.library_for` and `merge_libraries` skipping language words) so app shadowing does not contaminate the playground or other apps.
7. Verified all 12 gate legs and the full test suite remain green (636 runs, 6,840 assertions, 0 failures; 35 pages verified).

**Baseline:** All twelve gate legs green, 35 verified pages byte-identical, and the test suite at 630 runs, 6,810 assertions, 0 failures, at commit `a190d7b`.

---

## Roadmap Context: Criterion 4 of ROADMAP-0.5.md

> "The portfolio app's `account_card` becomes plain `card`, contained to that app's own family. Today, nine different partials across six apps and the studio — `account_card`, `document_card`, `lore_card`, `milestone_card`, `task_card`, `question_card`, `unreviewed_card`, `why_card`, `word_card` — are all some variation of "a card for this one record," and none of them can simply be called `card`, because the code still raises an error if an app tries to use a name the language already uses. dan already ruled on 2026-10-05 that this should be allowed — an app may use a language word's name, and the gate merely reports it — but that ruling never shipped as code. Renaming `account_card` to `card`, safely contained to the portfolio app's own family, is the concrete proof that this roadmap lets an author write the name they actually mean, not a demonstration invented after the fact to justify the work."

---

## Dan's 2026-10-05 Ruling

> "Ruled 2026-10-05 — allow it, and have the gate report it. The refusals in Library#initialize and refuse_shadowing! go; the gate gains a line that names every shadowed language word."

---

## Scope of Work & Outcome

1. **`lib/slim_pickins/library.rb`**:
   - Removed refusal in `Library#initialize` on vocabulary dupes.
   - Removed refusal in `Library#refuse_shadowing!` on primitive keys.
   - Retained internal app collision refusal: `` `#{duplicated.first}` is defined twice — as a partial and in Ruby ``.
   - Exposed `shadowed_words` on `Library` instances and `primitive_keys` on `Library`.
2. **`lib/slim_pickins/builder.rb`**:
   - Updated `Builder#define_app_words` so module methods from `words:` are explicitly bound via `define_singleton_method` to shadow built-ins cleanly.
   - Initialized `@spliced = []` in `Builder#render` when rendering partial templates directly.
3. **The Gate (`check_shape.rb`)**:
   - Added reporting for shadowed language words in the vitals section (`shadowed language words: card (portfolio)`).
4. **The Portfolio App**:
   - Renamed `examples/portfolio/views/partials/account_card.sp` to `examples/portfolio/views/partials/card.sp`.
   - Updated `examples/portfolio/views/index.sp` and `account.sp`.
   - Added `children` splice to `card.sp` so `index.sp` can cleanly provide `actions`.
5. **Studio & Sandbox Containment (`studio/pages.rb`)**:
   - Added `StudioPages.library_for(rel, default: library)` so portfolio pages evaluate against portfolio's own library.
   - Added filtering in `StudioPages.merge_libraries` to prevent app-level shadowed words from leaking into the shared playground/specimen library.
6. **Documentation & Tests**:
   - Updated `PRIMER.md` documenting Dan's 2026-10-05 ruling.
   - Updated `test/phase3_test.rb`, `test/phase6_test.rb`, and `test/vocabulary_partials_test.rb`.
   - Updated `test/studio_pages_test.rb`, `studio/pages.rb`, `bin/measure_cost.rb`.
   - Added unit tests in `test/shadowing_test.rb`.
   - Updated `HANDOFF.md` test files vitals count to 58.
7. **Verification**:
   - All 12 gate legs green on `/status` (live via `StudioStatus.run`).
   - 35 pages verified via `bin/verify_pages.rb`.
   - Full suite passes: 636 runs, 6,840 assertions, 0 failures.
