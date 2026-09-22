# DAYTRIP-0.4.0a — The Truthful Floor

**Opened 2026-09-22, on dan's word.** A jaunt off the path, giving orthogonal volume
to the roadmap's linear vector.

> *"The itinerary is just a vector; the daytrips give it volume."*

This daytrip opens Volet 1 of the Roadmap 0.4 planning progression. Having closed
Roadmap 0.3 with 0 missing affordances across four garden applications, we step
sideways into the soil before taking the next step forward.

---

## The brief

**His observations and direction (2026-09-22):**

1. **Ataovy dian-tana is wisdom, not dogma**: We carry our past, experience,
   hard knocks, and the debris of demonstration apps built by caprice and chance.
   We do not lock ourselves into rigid path dependency on these things. We move
   with an animated spirit.
2. **The volume and the vector**: The roadmap's itinerary is a 1D vector; daytrips
   provide orthogonal depth. We explore, measure, and plan one volet at a time.
3. **Audit against current and future purpose**: Strip away unused baggage from
   the past; keep only what is essential and necessary.
4. **DRY, SSOT, and dynamic self-documentation**: Replace manual bookkeeping of
   mutable integers in prose with executable single sources of truth.
5. **Tacit in the view, declared in the contract**: Conventions are silent in
   templates for human kindness, but explicit in contracts to prevent magic from
   decaying into superstition.

---

## The question

> **How do we establish complete, dynamic self-documenting integrity across the
> language's census, conventions, and contracts — discarding phantom baggage,
> settling convention provenance (F9) to unblock the Why Pane, and establishing
> an executable Single Source of Truth?**

---

## Baggage discarded vs. What earned its place

Auditing the handoff's proposed chores against live code immediately separated
inherited debris from living purpose:

| Proposed in Handoff | Ground Truth | Verdict |
|---|---|---|
| "Fill 14 blank slots in `VOCABULARY.md`" | `check_conventions.rb` is 100% green with 0 problems. Words with no inferences do not declare conventions. | **Discarded as phantom baggage.** Fabricating conventions for words that do no inference is anti-design. |
| "Purge dead stubs in `builder.rb` / `words.rb`" | Grep for deprecated or dead stubs across `lib/` yields 0 results. The runtime is clean. | **Discarded as phantom baggage.** |
| "Harmonize prose census in timeless specs" | `DESIGN.md` and `CONTRACT.md` define immutable grammar and contracts. Hardcoding perishable test counts in them rots on the next commit. | **Replaced with SSOT.** Timeless specs describe invariants; vitals live in an executable census. |
| "Settle F9 (`column` vs `chart` label convention)" | `chart` declares `label` while walking `table_header`'s path (`Builder#label_of`). Inconsistent convention naming confuses the Why Pane. | **Essential.** Unifying convention provenance directly unblocks transparent Why Pane inspection. |

---

## The Stops

### Stop 1 — The Census SSOT (`SlimPickins::Census` / `bin/census.rb`)
Create an executable Single Source of Truth for repository vitals:
- Canonical vocabulary words (42 Ruby primitives + 22 `.sp` partials = 64 total).
- Active garden applications (verified by presence of `app.rb` in `examples/`).
- Verified pages corpus (matching `verify_pages.rb`).
- Emitted and defined CSS classes and rules.
- Convention and promise register counts.
- Test suite runs and assertion totals.

### Stop 2 — Settle Convention Provenance (F9)
In `lib/slim_pickins/words.rb`, update `Chart`'s contract to declare `infers: [:chart_axis, :format_family, :table_header]`.
In `lib/slim_pickins/conventions.rb`, refine `table_header` to document that it covers both table column headers and chart series labels via `Builder#label_of`.
Ensure `check_conventions.rb` and `test/instruments_test.rb` verify the link.

### Stop 3 — Enriched Dynamic Self-Documentation
Upgrade `bin/generate_vocabulary.rb` and `SlimPickins::Conventions.bullet`:
- When a word declares a convention with a concrete mapping in code (e.g. `box_tag` mapping to `BOX_TAGS`, or `leaf_tag` mapping to `SPAN_TAGS`), the generated bullet explicitly reveals the concrete tag yielded (e.g. `disclosure` yields `<details>`, `card` yields `<article>`).
- Regenerate `VOCABULARY.md` using the updated generator.

### Stop 4 — Decouple Timeless Specs from Perishable Counts
Update `README.md`, `DESIGN.md`, and `CONTRACT.md` to remove perishable test counts, directing readers to the dynamic census instrument.

---

## Verification & Done Looks Like

- `ruby bin/census.rb` runs and reports live vitals.
- `ruby bin/generate_vocabulary.rb` regenerates `VOCABULARY.md` with concrete tag yields.
- `ruby bin/check_conventions.rb` and `ruby bin/check_promises.rb` report 0 problems.
- All 7 gate scripts pass (`check_grammar`, `check_shape`, `check_styles`, `check_promises`, `check_conventions`, `check_card`, `verify_pages`).
- Full test suite passes with 0 failures.

---

## Outcome (Volet 1 Complete)

1. **Stop 1 (Census SSOT)**: `SlimPickins::Census` (`lib/slim_pickins/census.rb` and `bin/census.rb`) is live and verified by `test/census_test.rb`. Computes exact counts: 64 canonical words (42 primitives + 22 partials), 7 apps, 31 verified pages, 38 conventions, 33 promises, 105 style rules.
2. **Stop 2 (F9 Settled)**: `Chart` contract updated to declare `table_header` instead of `label`, aligning with `Builder#label_of`. `SlimPickins::Conventions::ALL` updated. Verified by `test/instruments_test.rb` and `check_conventions.rb`.
3. **Stop 3 (Dynamic Self-Documentation)**: `SlimPickins::Conventions.bullet` upgraded with concrete element mapping for `box_tag` and `leaf_tag`. `bin/generate_vocabulary.rb` and `check_grammar.rb` pass `word: word`. 13 bullets regenerated in `VOCABULARY.md` revealing exact tag yields (`disclosure -> <details>`, `card -> <article>`, etc.).
4. **Stop 4 (Decoupled Specs)**: `README.md` updated to cite `bin/census.rb` as the living source of truth for vitals, retiring stale 0.2-era text.
5. **Gate Status**: All 7 gates green, 370 unit/integration runs pass in-process (plus all app suites), 0 errors, 0 failures.

