# Daytrip 0.6.0j — Meta-Architecture Renaming, Conceptual Ontology & Vocabulary Purification

**Status: Complete (2026-10-14).**

## Context & Motivation

In Daytrip 0.4.0d, seven "system taxonomy terms" (`word`, `primitive`, `partial`, `def`, `contract`, `tin`, `spiff`) were codified in `lib/slim_pickins/taxonomy.rb` under `Taxonomy::SYSTEM`. While helpful at the time, an audit conducted with dan surfaces deeper architectural truths and opportunities for clarity:

1. **Renamings for Clarity (A Gesture of Kindness for the Author):**
   - **`.tin` -> `.frame`**: The outer document chrome is not a tin can; it is the document's *frame* (the `<head>`, outer shell, navigation, footer, and asset envelope).
   - **`.spiff` -> `.layout`**: Spiff is the spatial layout language (`horizon`, `flank`, `stack`, `grid`). Renaming it to `.layout` makes its purpose unmistakable.
   - **`.style` (Reserved Future Layer)**: Acknowledges the distinction between macro-layout (`.layout`) and micro-layout / component-level styling (`.style`), which remains to be designed.

2. **Truths Not Previously Recognized:**
   - **`page` belongs exclusively in `.frame`**: Today, `.sp` templates redundantly wrap their content in `page portfolio, "Your retirement"`. But the template *is* the substance answering a route. `page` is the document chrome concept and belongs in the `.frame`.
   - **"Partial" is an anachronism borrowed from Slim**: In Rails/Slim, a partial is a template fragment (`render :partial`). In `alt-slim-pickins`, words defined via `def` are first-class **composed words** (or **defined words**). They are invoked identically to primitive words (`card`, `actions`, `badge`).
   - **Invariant Triad Audit (`contract`, `convention`, `promise`)**: The descriptions of promises and conventions blurred together. A rigorous audit is needed to clarify their roles:
     - `contract`: The **Grammar** (compile-time syntactic bounds enforced by the Gate).
     - `convention`: The **Inference Engine** (what the runtime decides when an author stays silent).
     - `promise`: The **Feature Ledger** (proof that declared modifiers actually have active readers in code).
   - **Substance Migration**: presentation atoms like `metric`, `badge`, `snippet`, and `fact` should be implemented as `.sp` composed words rather than Ruby classes, shrinking the runtime primitive core.
   - **Syntax Alignment**: All `.sp` definitions must align with modern `word subject, kwargs` syntax, banishing the archaic comma after `def word_name`.
   - **No Backward Compatibility Needed**: Per the Ode to Joy, this is craft work for an audience of one. Redesign freely without legacy deprecation shims or dual-mode aliases.

---

## The Tri-Plane Meta-Architecture (Post-Renaming)

```
+-----------------------------------------------------------------------------------+
|                           THE THREE ONTOLOGICAL PLANES                            |
+-----------------------------------------------------------------------------------+
| 1. LINGUISTIC & EXECUTION PLANE (The Lexicon & Grammar)                           |
|    - word          : Atomic syntactic token and invocation unit (word arguments)  |
|    - primitive     : Atomic leaf word implemented directly in Ruby (Words::*)     |
|    - composed word : First-class word defined in .sp syntax (formerly "partial")  |
|    - def           : Definition keyword: `def word_name subject, kwargs`          |
+-----------------------------------------------------------------------------------+
| 2. COMPOSITION & SPATIAL PLANE (The Canvases)                                     |
|    - frame         : Document envelope chrome (.frame, formerly .tin)             |
|    - layout        : Spatial companion stylesheet (.layout, formerly .spiff)      |
|    - style         : [Future Layer] Micro-layout, component styling, & theme roles|
|    - substance     : The route-level body template (.sp) filling `contents`       |
+-----------------------------------------------------------------------------------+
| 3. MECHANICAL INVARIANT PLANE (The Instruments of Truth)                          |
|    - contract      : Compile-time syntactic grammar (takes, holds, modifiers)     |
|    - convention    : Inferences and defaults when syntax remains silent (38 rules)|
|    - promise       : Ledger proving declared modifiers have active readers (33)   |
+-----------------------------------------------------------------------------------+
```

---

## Refined Vocabulary Taxonomy: Categories & Sub-Categories

Rather than a single broad `semantic` bucket and an apologetic `visual` bucket, the vocabulary organizes into intuitive categories and sub-categories with clean bandpass filter characteristics:

1. **Substance (Domain Content & Phrasing)**
   - *Typography / Phrasing*: `heading`, `paragraph`, `text`, `note`, `flash`, `quote`, `snippet`, `code`
   - *Data & Metrics*: `metric`, `fact`, `number`, `money`, `percent`, `time`, `badge`
2. **Skeleton (Structure & Framing)**
   - *Regions / Landmarks*: `section`, `aside`, `nav`, `footer`, `header`
   - *Containers / Surfaces*: `box`, `card`, `figure`, `group`, `cluster`
   - *Collections & Tabular*: `list`, `item`, `table`, `column`, `row`, `grid`
3. **Affordances (Controls & Interactions)**
   - *Actions & Navigation*: `link`, `button`, `actions`, `action`, `tabs`, `tab`
   - *Inputs & Transport*: `form`, `field`, `input`, `choice`, `option`, `search`
4. **Flow & Logic (State & Behavior)**
   - *Iteration*: `each`, `empty`
   - *Branching & Conditions*: `choose`, `when`, `otherwise`
   - *Disclosure & State*: `disclosure`
5. **Environment (Document & Splicing)**
   - *Document Resources*: `stylesheet`, `script`, `iframe`, `tag`
   - *Splicing & Slots*: `contents`

---

## Planned Movements

### Movement 1: The Great Renaming (`.tin` -> `.frame`, `.spiff` -> `.layout`, `page` in `.frame`)
- Rename all `*.tin` files across `examples/` and `studio/` to `*.frame` (e.g., `portfolio.frame`, `dashboard.frame`, `workbench.frame`).
- Rename all `*.spiff` files to `*.layout`. Update layout compilers, checkers (`checkers/check_layout.rb`), and tests.
- Re-architect `page`: `page` is spoken exclusively in `.frame`. Remove redundant outer `page` wrappers from `.sp` substance templates where appropriate, splicing substance directly into `contents`.
- Update `Library`, `Builder`, `Generator`, and `Conventions` to recognize `.frame` and `.layout`.

### Movement 2: Syntax Modernization of `def` & Composed Word Audit
- Modernize `def` syntax handling in `Transform` and `Builder` to accept `def word_name subject, kwargs` without an archaic comma separating the word name from its parameters.
- Audit all 23 canonical `.sp` files in `lib/vocabulary/` and update them to the modern syntax:
  - `def action label`
  - `def card target, title`
  - `def note tone, text`
  - etc.
- Retire the term "partial" across code and documentation in favor of **composed word** (or **defined word**).

### Movement 3: Expressing `metric`, `badge`, `snippet`, and `fact` in `.sp`
- Implement `metric.sp`, `fact.sp`, and `snippet.sp` in `lib/vocabulary/` as composed words.
- Modernize `badge.sp` to the new syntax.
- Retire Ruby primitive classes (`Words::Metric`, `Words::Fact`, `Words::Snippet`) from `lib/slim_pickins/words.rb`.
- Update `Census`, `Contracts`, and `Vitals` to reflect the updated balance (38 primitives, 27 composed words).

### Movement 4: The Invariant Audit (`contract`, `convention`, `promise`)
- Perform an exhaustive audit of:
  - `Contracts`: verify all 64 words have accurate contracts reflecting modern slot containment (`contents`, `group`).
  - `Conventions`: audit all 38 entries, removing stale references and clarifying what the engine infers when authors stay silent.
  - `Promises`: audit all 33 entries, verifying every declared modifier has a real, active reader in the codebase.
- Formulate the precise architectural boundary between the three instruments.

### Movement 5: Multi-Axial Taxonomy & Bandpass Filter Diagnostics
- Codify the refined Categories & Sub-Categories in `lib/slim_pickins/taxonomy.rb`.
- Implement `Taxonomy.filter_analysis` measuring passband width, boundary selectivity, and polyhierarchical resonance across the 64 words.
- Provide clean, forward-looking query APIs (`Taxonomy.planes`, `Taxonomy.categories`, `Taxonomy.by_category`) without legacy compatibility shims.

### Movement 6: Living Architectural Treatise (`docs/ONTOLOGY.md`)
- Author `docs/ONTOLOGY.md` detailing:
  - The Tri-Plane Meta-Architecture.
  - The new file extensions (`.frame`, `.layout`, and future `.style`).
  - Primitive words vs. Composed words.
  - The Invariant Triad (`contract`, `convention`, `promise`).
  - The Refined Taxonomy & Bandpass Filter Model.

### Movement 7: Verification & Gate Integrity
- Update all 12 gate legs in `studio/status.rb` and root checkers.
- Update `bin/census_polysemy.rb`, `test/taxonomy_test.rb`, and `examples/way_exam/lib/exam.rb`.
- Verify all 12 Studio gate legs green, 35 pages verified OK, 0 failures.

---

## Baseline Verification State
- **Gate Status:** All 12 legs green.
- **Suite:** 652 runs, 7,048 assertions, 0 failures.
- **Vitals:** 64 canonical words (41 primitives, 23 partials), 33 promises, 38 conventions, 35 verified pages.

---

## Completed Verification State (2026-10-14)
- **Gate Status:** All 12 legs green (`Grammar`, `Shape`, `Styles`, `Layout`, `Scope`, `Promises`, `Conventions`, `Card`, `Pages`, `Vitals`, `Ruby`, `Suite`).
- **Suite:** 650 runs, 7,098 assertions, 0 failures, 0 errors, 0 skips.
- **Pages:** 35 pages verified OK via `bin/verify_pages.rb`.
- **Census / Vitals:** 64 canonical words (38 primitives, 26 composed words), 33 promises, 38 conventions, 35 verified pages, 8 apps, 113 CSS rules, 60 test files. 0 vitals problems.
- **Treatise:** `docs/ONTOLOGY.md` authored and registered in `studio/docs_helper.rb`.
