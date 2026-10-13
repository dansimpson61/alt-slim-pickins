# Daytrip 0.5.0f — Wishlist, Loose Ends & Flights of Imagination Ledger

**Status: closed.** Collected the repository's forward horizon into a living, structured document (`WISHLIST.md`) and codified a standing consultation protocol for future roadmaps and daytrips:
1. Established `WISHLIST.md` across six sections: The Standing Protocol, Loose Ends & Technical Pinches, Architecture/Library/Language Horizons, Pedagogy/Terminology/Repo Health, Aesthetics/Examples/Workbench, Bluesky & Flights of Imagination, and Retired or Graduated Items.
2. Codified the standing consultation and intake rules in `working-with-dan.md` (Instruction 9) and within `WISHLIST.md` itself so that every roadmap conception, daytrip planning session, and roadmap close reviews and feeds known seams and creative horizons.
3. Added `WISHLIST.md` to `check_vitals.rb` exemption list with clear rationale, keeping all vitals checks green.
4. Maintained all twelve gate legs green, 35 verified pages byte-identical, and the full test suite at 636 runs, 6,840 assertions, 0 failures.

**Baseline:** All twelve gate legs green, 35 verified pages byte-identical, and the test suite at 636 runs, 6,840 assertions, 0 failures, at commit `536684e`.

---

## Origin & Purpose

Dan requested (2026-10-12):
> "Let's make a daytrip to collect loose ends and wishlist items or even bluesky ideas/flights of imagination in a document. Then, whenever we plan a roadmap or daytrip we should consult the document to see if there is something from it that should/may be included."

Throughout roadmaps 0.1 through 0.5, valuable technical observations, edge-case frictions, and expansive design visions were generated across disparate places—`examples/doc_reader/WHAT_IF.md`, `BLUESKY.md`, `ROADMAP-0.5.md` Section 7 open questions, `history/CHRONICLE.md`, and chat transcripts. Without a central living ledger and an explicit protocol, these insights risked being lost between sessions.

---

## Deliverables

### 1. `WISHLIST.md`
A dedicated living ledger structured as follows:
- **The Standing Protocol:** Rules for consulting the document at roadmap conception and daytrip planning, continuous intake during active sessions, systematic intake at roadmap close, and marking items graduated or retired with rationale.
- **Section I — Loose Ends & Technical Pinches:**
  - Context-sensitive `actions` (in vs out of form).
  - `link` syntax duality (Roadmap 0.5 Criterion 7, Item 1).
  - Two sentence-parsing fixes (Roadmap 0.5 Criterion 7, Item 3: bare name lookup & quoted interpolation).
  - Landing evaluation for sentence arguments (`page document, .title`).
  - Class derivation decoupled from subject attribute collision (`section users`).
  - Object identity for DOM IDs.
  - Heading depth level gaps.
  - Collection-scoped emptiness.
  - Entity routing helper primitive (`link show`).
  - Date formatting register discrepancy.
- **Section II — Architecture, Library & Language Horizons:**
  - Defining the Slim-Pickins MVP (core elements, behaviors, theming facility, and features).
  - Library vs. Development Project structure (clean, lean gemification of `lib/slim_pickins`).
  - Adapter pattern for pluggable backends (library-agnostic charts, markdown, syntax highlighting).
  - Database frontend & authentic CRUD example application.
  - The "Rubinius" vision — writing `sp` in `sp` to the practical limit across studio and internals.
  - Untangling the dual nature of "variant" (Roadmap 0.5 Criterion 7, Item 2: style weight vs data-driven status).
  - Systematic audit of container value inheritance (Roadmap 0.5 Criterion 7, Item 4: lexical scoping interaction).
  - Standardizing domain contract declarations (`labels`, `formats`).
- **Section III — Pedagogy, Terminology & Repository Health:**
  - Terminology audit & systematization (built-ins, partials, `.sp`, defs, tin, spiff, doc names).
  - Project identity: dropping `alt-` in `alt-slim-pickins`; archiving/deleting older `slim-pickins` repos.
  - Repository cleanup & historical artifact stowing (stowing old artifacts/planning; organizing examples and studio).
  - Pedagogy from first principles (short outline pages calling short word defs, clearing dev history/jargon).
- **Section IV — Aesthetics, Examples & Workbench:**
  - Aesthetic diversity in showcase apps (example apps that look really good in distinctly different ways).
  - Retiring or modernizing dated example apps (`way_exam`, `word_graph`).
  - Studio editor gutter and inline failure diagnostics.
  - Content-aware workbench pane sizing.
- **Section V — Bluesky & Flights of Imagination:**
  - Making the theme sayable (Style DSL mapping to theme variables without utility bloat).
  - Seeing the state / Bret Victor inference engine visualization in Studio.
  - Intrinsic responsive layout primitives (Every Layout in the DSL: Stack, Switcher, Cluster).
  - Self-titling & content-aware documents.
  - Modular component tins (localized framing).
- **Section VI — Retired or Graduated Items:**
  - Shadowing built-in language words (Graduated in Daytrip 0.5.0e).
  - Retiring legacy `expects` declaration line (Graduated in Daytrip 0.5.0d).

### 2. Standing Protocol Integration
- Added Instruction 9 to `working-with-dan.md`:
  > *"Maintain and consult `WISHLIST.md`. Consult it whenever planning a roadmap or daytrip for relevant loose ends, wishlist items, or flights of imagination. Record ideas or design frictions there during sessions whenever they fall out of immediate scope. At the close of each roadmap, systematically ask whether there is anything to add to the wishlist before opening the next phase."*

### 3. Vitals & Gate Cleanliness
- Added `'WISHLIST.md' => 'loose ends, wishlist items, and flights of imagination'` to `EXEMPT` in `check_vitals.rb`.
- Verified `ruby check_vitals.rb` reports 0 problems.
- Verified `test/check_vitals_test.rb` passes (19 runs, 52 assertions, 0 failures).

---

## Verification

- **Vitals:** `ruby check_vitals.rb` — 0 problems across 40 prose claims in 10 documents.
- **Card budget:** `bin/check_card.rb` — 7 fields present, all within character budgets, 0 problems.
- **Pages verification:** `bin/verify_pages.rb` — all 35 verified pages match baseline byte-for-byte.
- **Studio status:** All 12 gate legs green on `/status`.
- **Full test suite:** 636 runs, 6,840 assertions, 0 failures.
