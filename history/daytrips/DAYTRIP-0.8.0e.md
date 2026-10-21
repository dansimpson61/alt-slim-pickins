# Daytrip 0.8.0e — Garden Triage, Directory Modernization (`views/words/`) & SOTA App Modernization

**Date:** 2026-10-20  
**Roadmap:** [ROADMAP-0.8.md](../../ROADMAP-0.8.md) (Phase 5 of 6)

## Premise & Measurement

1. **Garden Triage:** Prototype apps `examples/milestone_planner` and `examples/way_exam` had fulfilled their historical roles during early milestone and exam development. With `portfolio` chosen to carry Roadmap 0.9's authentic SQLite CRUD exam, maintaining these redundant apps added maintenance drag. A stray root `word_graph.html` dump and stale root `roth/` links in `README.md` and `HANDOFF.md` also remained.
2. **Historical Artifact Stowing:** Dated planning and study documents (`KERNEL.md`, `examples/publication/ON_PAPER.md`, `examples/publication/WHAT_IF.md`, `examples/dashboard/INVENTORY.md`, `examples/roth/ROTH_DOMAIN_BACKLOG.md`, and `examples/roth/ROTH_STUDY.md`) were scattered in working trees rather than organized in `history/`.
3. **Legacy Directory Nomenclature (`views/partials/` → `views/words/`):** The repository had standardized terminology from "partial" to "composed word" in Roadmap 0.6, yet filesystem directories across `examples/` and `studio/` remained named `partials/`.
4. **SOTA App Modernization Powered by `KeyValue`:** Daytrip 0.8.0b introduced `SlimPickins::KeyValue` as the universal spine for `(key, label, value, format)`. Kept apps still relied on ad-hoc singleton monkeypatching (`Fixtures.labelled`), class-macro metadata mixins (`Publication::Described`), or long `choose/when` ladders in `.sp` views that should use `dictionary`/`on`/`map`. Dan explicitly ruled that `KeyValue` supersedes `Described`.

## What Changed

1. **Garden Triage & Stowing:**
   - Retired `examples/milestone_planner/` and `examples/way_exam/`, along with their test suites (`test/examples/milestone_planner_test.rb` and `test/examples/way_exam_test.rb`) and root `word_graph.html`.
   - Stowed historical planning and study documents into `history/`:
     - `KERNEL.md` → `history/studies/KERNEL.md` (and updated `studio/docs_helper.rb`).
     - `examples/publication/ON_PAPER.md` → `history/planning/ON_PAPER_PUBLICATION.md`.
     - `examples/publication/WHAT_IF.md` → `history/planning/WHAT_IF_PUBLICATION.md`.
     - `examples/dashboard/INVENTORY.md` → `history/planning/INVENTORY_DASHBOARD.md`.
     - `examples/roth/ROTH_DOMAIN_BACKLOG.md` → `history/planning/ROTH_DOMAIN_BACKLOG.md`.
     - `examples/roth/ROTH_STUDY.md` → `history/studies/ROTH_STUDY.md`.
   - Updated `bin/verify_pages.rb`, `studio/pages.rb`, `test/studio_pages_test.rb`, `bin/probe_lookup_chain.rb`, and `test/isolation_test.rb` to remove references to retired apps.

2. **Nomenclature & Directory Modernization (`views/words/`):**
   - Extended `Library.from` (`lib/slim_pickins/library.rb`) to discover composed words from both `words/*.sp` and legacy `partials/*.sp` across `[dir, dir/views]`.
   - Updated `Census.app_words` (`lib/slim_pickins/census.rb`) to count words in both `words/*.sp` and `partials/*.sp`.
   - Updated `Transform.route?` (`lib/slim_pickins/transform.rb`) and `Builder#render` (`lib/slim_pickins/builder.rb`) to treat `words/` identically to `partials/` as non-route composed words.
   - Migrated all `partials/` directories across the repository to `words/`:
     - `examples/publication/views/words/`
     - `examples/portfolio/views/words/`
     - `examples/roth/views/words/`
     - `examples/dashboard/views/words/`
     - `examples/word_graph/views/words/`
     - `studio/shared/words/`
     - `studio/uis/classic/views/words/`
     - `studio/uis/workbench/views/words/`
     - `studio/views/words/`
   - Updated checkers `check_styles.rb` and `check_shape.rb` to scan `words/*.sp`.

3. **SOTA App Modernization Powered by `KeyValue`:**
   - Replaced singleton monkeypatching in `test/fixtures.rb`: completely removed `Fixtures.labelled` and dynamic `format_for` overrides on Struct instances. `Holding`, `Account`, `Portfolio`, `Balance`, `Target`, and `Specimen` are now pure Ruby Structs.
   - Stated presentation directly in templates via `KeyValue`:
     - In `examples/portfolio/views/index.sp` and `examples/portfolio/views/words/card.sp`: used `metric total_value, as: money`, `column market_value, "Value", as: money`, etc. (using bare words, not Ruby symbol literals).
     - Removed `Publication::Described` and `include Described` from `examples/publication/lib/shelf.rb` and `lore.rb`.
     - In `examples/publication/views/search.sp`: updated `field q, "Words to find"`, `field include_history, "Include the history"`.
     - In `examples/publication/views/entry.sp`, `document.sp`, and `words/document_card.sp`: updated `metric reading_minutes, label: "Minutes"`.
     - In `examples/word_graph/views/words/word_card.sp` and `views/word.sp`: replaced multi-branch `choose/when` ladders with declarative nested `dictionary .speech` and `dictionary .shape`.

4. **Census & Vitals Alignment:**
   - Synchronized prose census claims across `HANDOFF.md`, `README.md`, and `docs/PRIMER.md`:
     - 5 apps (down from 7)
     - 26 app words (down from 30)
     - 30 verified pages (down from 34)
     - 55 test files (down from 57)
     - 63 canonical words, 38 conventions, 33 promises, 113 CSS rules.

## Verification

- All 12 gate legs + pedagogy: **0 problems**.
- Verified pages (`bin/verify_pages.rb`): **30 pages verified, 0 problems**.
- Full test suite: **640 runs, 6,896 assertions, 0 failures, 0 errors, 0 skips**.
