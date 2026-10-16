# Daytrip 0.6.0k — First-Principles Pedagogy, Ontology Sweep & Roadmap 0.6 Close

**Status: in progress (Pre-Movement & Movement 1 landed).** The closing movement of Roadmap 0.6.

## Objective
Bring every author-facing guide (`PRIMER.md`, `CONVENTIONS.md`, `VOCABULARY.md`) and repository entrypoint (`README.md`, `HANDOFF.md`, `WISHLIST.md`, `slim_pickins.gemspec`) into 100% alignment with the Daytrip 0.6.0j Tri-Plane Ontology, register `docs/STRETCH_PROTOCOL.md`, prune historical session bloat from `HANDOFF.md`, and close Roadmap 0.6 cleanly with Roadmap 0.7's Stretch Exam target named.

---

## Movements

### Pre-Movement: Characterizing the Audience & Specifying the Pedagogy (Completed)
Before editing `PRIMER.md`, `CONVENTIONS.md`, or `VOCABULARY.md`, establish and confirm the pedagogical specification:
1. **Strict Audience Partition:**
   - **Authors (`PRIMER.md`, `CONVENTIONS.md`, `VOCABULARY.md`, `docs/LAYOUT.md`):** Learn how to think and write in `.frame`, `.sp`, and `.layout`. Zero compiler internals (`Builder`, `Transform`), zero gate mechanics (`Promises::ALL`), and zero development biography. Reflected in `DocReader::Document::FOR_USERS`.
   - **Stewards (`docs/ONTOLOGY.md`, `docs/STRETCH_PROTOCOL.md`, `KERNEL.md`, `LORE.md`):** Hold the Tri-Plane Meta-Architecture, the Mechanical Invariant Triad (`contract`, `convention`, `promise`), the bandpass filter diagnostics, and the roadmap evolution protocol.
2. **The Five Pedagogical Laws for Author Guides:**
   - **Deductive Top-Down Order:** Canvas plane (`.frame`, `.sp`, `.layout`) -> One-sentence grammar -> Universal slot & inference model (`word [target], [override], [kwargs]`) -> Composed word authoring (`def` & `contents` & `dictionary`/`on`/`map`) -> The 5 Vocabulary Categories (`Substance`, `Skeleton`, `Affordances`, `Flow & Logic`, `Environment`).
   - **Idiomatic Shape:** Show significantly more written `.sp`, structured as short, outline-like route templates calling short, focused `def` words.
   - **Visible Inference:** Pair `.sp` sentences with what they infer (`.label`, `.id`, `.noun`, `.target`, input types, formatting) so conventions are predictable, never superstition.
   - **Timeless Present Tense:** Purge all "formerly", phase numbers, and defensive justifications (unique historical notes preserved verbatim in `history/CHRONICLE.md`).
   - **Dogfood Readability in `doc_reader`:** Verified that all rewritten guides render cleanly in `examples/doc_reader`, setting the baseline for Roadmap 0.7's Editorial Stretch Exam.
   
### Movement 1: Primary Guides Rewritten to the 0.6.0j Tri-Plane Ontology (Completed)
1. **`PRIMER.md` (The Way):**
   - Teaches the Three Canvases up front: `.frame` (document chrome & `page`), `.sp` (route substance & `composed words`), and `.layout` (spatial posture).
   - Removed `page` from all `.sp` route substance snippets; `.frame` declares `page` enclosing `contents`.
   - Replaced flawed `box documents, title` examples with `section documents, title` and `card document, .name`.
   - Updated all `def` examples to modern comma-less syntax (`def card target, title`, `def catalog documents, title`).
   - Replaced all lingering references to `partial`/`partials`, `.tin`, and `.spiff` with `composed word`, `.frame`, and `.layout`.
   - Teaches `dictionary` / `on` / `map` as the first-class association primitives replacing ad-hoc variants, and `contents` as the universal splice pronoun.
   - Presents the 5 refined bandpass vocabulary categories (`Substance`, `Skeleton`, `Affordances`, `Flow & Logic`, `Environment`).
2. **`VOCABULARY.md` (The 64 Canonical Words):**
   - Updated header and category organization to reflect **38 Ruby primitives and 26 `.sp` composed words** across the 5 categories (`Substance`, `Skeleton`, `Affordances`, `Flow & Logic`, `Environment`), completing all 7 slots on all 64 words (`metric`, `fact`, and `snippet` as composed words; `dictionary`, `on`, and `map` documented in full).
   - Clarified `page` as exclusive to `.frame` envelopes and `contents` as spoken in `.frame` or `def`.
   - Verified `bin/generate_vocabulary.rb` and `check_grammar.rb` run with 0 drift.
3. **`CONVENTIONS.md` (The Inference Engine):**
   - Aligned all 38 convention descriptions (`frame` replacing `tin`) with the universal slot model (`word [target], [override], [kwargs]` -> automatic `.label`, `.id`, `.noun`, `.target`) and `.frame` / `.layout` resolution rules.
   - Removed `page` from route substance convention examples (`form to: "/save"`, `section account`, `each document`, portfolio template).
   - Stripped internal compiler explanations and preserved dated 2026-10-10 rulings in `history/CHRONICLE.md`.
4. **`checkers/check_pedagogy.rb` & `test/check_pedagogy_test.rb` (The Pedagogy Instrument):**
   - Built continuous automated checker verifying canvas plane separation (substance cannot speak `page`, frame must declare `page` and `contents`), contract reality (no multi-arg `box`), syntax, and terminology across all author guides. 0 problems across 5 guides, 6 tests passing in test suite.

### Movement 2: Repository Entrypoint & Gem Metadata Sweep
- **`README.md`:** Replace all `.tin` / `.spiff` / `partials` references with `.frame` / `.layout` / `composed words`; update gate command leg names (`check_layout.rb`, `check_layout_scope.rb`); link `docs/ONTOLOGY.md` and `docs/STRETCH_PROTOCOL.md`.
- **`slim_pickins.gemspec`:** Update `spec.description` from `"26 partials, Spiff stylesheets"` to `"64 canonical words, .frame envelopes, .layout spatial stylesheets, and zero runtime dependencies"`.
- **`WISHLIST.md`:** Update stale census counts (64 words, 26 composed words, 61 `:root` theme roles) and align terminology to `.frame` / `.layout` / `composed words`.
- **`StudioDocs::DOCUMENTS` (`studio/docs_helper.rb`):** Register `STRETCH_PROTOCOL` (`docs/STRETCH_PROTOCOL.md`) alongside `ONTOLOGY` so the Studio serves it and `test/markdown_test.rb` guards it.

### Movement 3: `HANDOFF.md` Pruning (Timeless Entrypoint)
- Excise the ~200 lines of obsolete 2026-10-04 to 2026-10-11 Roadmap 0.4/0.5 task queues, rejected `0.4.0p` C-questions, and closed audit lists (verifying any unique historical prose is preserved in `history/CHRONICLE.md`).
- Leave a lean, current `HANDOFF.md` (~60–80 lines) containing:
  1. Ordered reading list (including `docs/ONTOLOGY.md` and `docs/STRETCH_PROTOCOL.md`).
  2. Current Vitals held by `check_vitals.rb` (64 words: 38 primitives + 26 composed words, 8 apps, 35 pages, 38 conventions, 33 promises, 113 CSS rules).
  3. Active next step: Opening **Roadmap 0.7** with its paper Stretch Exam.
  4. Studio Process & RIF Housekeeping Protocol with current gate leg script names.
  5. Standing Principles.

### Movement 4: Closing Roadmap 0.6 & Naming the 0.7 Stretch Target
- Mark all 6 criteria in `ROADMAP-0.6.md` complete with measured evidence.
- Stow `DAYTRIP-0.6.0g.md` through `DAYTRIP-0.6.0k.md` into `history/daytrips/` and `ROADMAP-0.6.md` into `history/planning/` (updating `StudioDocs::DOCUMENTS` and `DocReader::Shelf` paths as needed).
- Record Dan's ruling for **Roadmap 0.7** in `PROJECT.md` (`next_step`) and `HANDOFF.md`:
  - **Roadmap 0.7 Stretch Exam:** *The Editorial & Micro-Layout Publication* — uniting `doc_reader` and `lore_reader` into a single publication-grade reader (and retiring standalone `lore_reader` upon completion).
  - **Daytrip 0.7.0a (Paper First):** Draft the uncompromised `.frame`, `.sp`, and `.layout`/`.style` templates for the unified reader on paper, run them against the gate to inventory the Wall Ledger (landing evaluation, self-titling documents, inline metadata cluster micro-layout, sayable editorial theme roles, and subject/class collision), and frame `ROADMAP-0.7.md`.
  
### Movement 5: Full 12-Leg Gate & Live Verification
- Run all 12 gate legs, `check_vitals.rb`, `check_ruby.rb`, `bin/verify_pages.rb` (35 pages), and the full single-process test suite.