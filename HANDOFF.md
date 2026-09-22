# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
3. `PROJECT.md` — `next_step` points at Volet 3: Studio & Workbench Wins (`DAYTRIP-0.4.0c.md`)
4. `HANDOFF.md` — this document, specifically the active itinerary below
5. `DAYTRIP-0.4.0a.md` & `DAYTRIP-0.4.0b.md` — outcomes of Volet 1 (Truthful Floor) and Volet 2 (Expressive View Composition)
6. `PRIMER.md` — the Way, as it stands now
7. `DESIGN.md`, `CONTRACT.md` — the grammar and the app promise; `VOCABULARY.md`'s checkable bullets per entry are generated (`bin/generate_vocabulary.rb`)
8. `LORE.md` — what previous sessions *learned*; the last entries are this session's
9. `working-with-dan.md` — candid notes on working with him: what his questions mean, what lands, what does not. It is short, it is honest, and **it is yours to keep true** — updating it is part of the round.

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

**Roadmap 0.4 is underway as an iterative sequence of winnable daytrip victories:**
- **Volet 1 (The Truthful Floor, `DAYTRIP-0.4.0a.md`)**: Landed 2026-09-22. Established `SlimPickins::Census` (`bin/census.rb`) as the living SSOT; settled F9 (`Chart` declares `table_header`); enriched `Conventions.bullet` with concrete element yields.
- **Volet 2 (Expressive View Composition, `DAYTRIP-0.4.0b.md`)**: Landed 2026-09-22. Delivered R3P2 (subject-shifting `card`, eliminating 7 repeated bindings in `queue.sp`), R3P3 (single-form `formaction` button groups in `actions.sp`), and R3P1 (open partial payload forwarding via `takes: payload` / `open: true`).
- **Volet 3 (Studio & Workbench Wins, `DAYTRIP-0.4.0c.md`)**: Landed 2026-09-22. Delivered W2 (live test suite 8th leg on `/status`) and W3 (combined `Inspect` surface uniting Semantic Tree AST and The Why Pane / inference provenance inspector).
- **Volet 4 & 4b (The Studio Shelf & Authoring Deductive Structure)**: **ACTIVE NEXT STEP**.
  - Volet 4: 5-tier vocabulary taxonomy (Structural, Semantic, Interactive, Behavioral, Visual) on the Studio shelf and in `PRIMER.md` (Pain Point 1).
  - Volet 4b: Studio partial minting / bite-sized, locally scoped domain words to eliminate long unDRY views (Pain Point 2).

### Current Vitals (measured 2026-09-22)
- **Census SSOT (`bin/census.rb`)**: 64 canonical words (42 Ruby primitives + 22 .sp partials), 7 apps, 26 app words, 31 verified pages, 38 conventions, 35 promises, 105 stylesheet rules, 42 test files.
- **Full Suite**: 376 runs, 4,204 assertions, 0 failures, 0 errors, 0 skips in one process.
- **Check Grammar**: 1,228 sentences checked, 94 words defined, 0 problems.
- **Check Shape**: 64 canonical words, 980 sentences, 0 problems.
- **Check Styles**: 26 emitted classes, 59 rendering, 105 rules, 0 problems.
- **Verify Pages**: 31 pages verified, 0 problems.
- **Promise Ledger**: 35 promises (32 read, 3 forwarded, 0 unread), 0 problems.
- **Convention Register**: 38 conventions, 0 problems.
- **Resume Card**: 7 fields present, last_touched 2026-09-22, 0 problems.

---

## Active Roadmap Progression

### [COMPLETED] Volet 1: The Truthful Floor (`DAYTRIP-0.4.0a.md`)
- Established `SlimPickins::Census` as live executable SSOT.
- Settled F9 (`Chart` infers `table_header`).
- Enriched `Conventions.bullet` with concrete HTML tag yields in `VOCABULARY.md`.

### [COMPLETED] Volet 2: Expressive View Composition (`DAYTRIP-0.4.0b.md`)
- **R3P2**: Subject-shifting `card` (eliminating repeated dotted subject paths in card blocks).
- **R3P3**: Single-form `formaction` button groups in `actions` (collapsing 4 separate forms into 1).
- **R3P1**: Partial payload forwarding (`open: true` / `takes: payload`).

### [COMPLETED] Volet 3: Studio & Workbench Wins (`DAYTRIP-0.4.0c.md`)
- **W2**: Live test suite integrated as 8th leg in `StudioStatus::LEGS` on Studio `/status`.
- **W3**: Combined `Inspect` surface in Workbench output tabs (`Visual` | `HTML` | `Inspect`), uniting collapsible Semantic Tree AST with synchronized Why provenance cards, 4-tier ownership, and convention links.

### [NEXT] Volet 4 & 4b: The Studio Shelf & Authoring Deductive Structure
*Focus: Resolving the two foundational authoring pain points.*
1. **Volet 4 (5-Tier Vocabulary Taxonomy — Pain Point 1)**:
   - Organize vocabulary into a 5-tier deductive hierarchy: Structural, Semantic, Interactive, Behavioral, and Visual on the Studio shelf and in `PRIMER.md`.
2. **Volet 4b (Studio Partial Minting & Bite-Sized Domain Words — Pain Point 2)**:
   - Provide Studio-driven authoring of locally scoped, bite-sized `.sp` partials to eliminate long, unDRY view scripts.
3. **Unified Workbench (Collapsible Shelf)**:
   - Fold the docs try-it pane and the vocabulary palette into one cohesive, collapsible library shelf.

### Package C — Lean & Elemental Kernel (Kernel Purity & Primitives)
*Focus: Shrinking the compiled Ruby core and building words out of simpler, elemental primitives.*
1. **Privileged `tag` Primitive (`KERNEL.md` Round 1)**:
   - Introduce a privileged `tag` primitive in the kernel that is strictly forbidden in app views by test/gate, but permitted in `lib/vocabulary/`.
2. **Lower First Wave of Ruby Atoms to `.sp` Compositions**:
   - Re-atomize single-consumer or thin-wrapper Ruby words (`figcaption`, `summary`, `box`, `paragraph`) into pure `.sp` partial compositions.
   - Inverts the kernel: moves alt-slim-pickins further toward the Rubinius ideal where the core is minimal and vocabulary is authored in the language itself.
3. **Cost Budget Verification**:
   - Re-measure cost before and after lowering words, ensuring warm render stays strictly under the 10 ms guardrail.

### Package D — House Honesty & Integrity (Census, Registry & Doc Parity)
*Focus: Aligning every prose document and registry with the living reality of the codebase.*
1. **Harmonize Historical Prose Census**:
   - Realign `README.md`, `DESIGN.md`, `PRIMER.md`, and `CONTRACT.md`.
   - Update historical figures (outdated "53 words / 2 apps / 10 pages") to the true living counts (64 words / 6 apps / 31 pages).
2. **Registry Hygiene & Dead Stub Removal**:
   - Fill 14 blank slots in `VOCABULARY.md`.
   - Purge dead or deprecated stubs from `builder.rb` and `words.rb`.
3. **Unify Row-Oriented Label Conventions (F9)**:
   - Resolve convention asymmetry between `table_header` vs `label` across `column` and `chart`.

---

## Studio Process & Verification Protocol

The studio (`studio/`, port 4580, `STUDIO_PORT` to override) is agent-managed.
- Check the port: `curl -s -m 2 http://127.0.0.1:4580/`.
- If down or after code changes, run in background:
  `cd ~/dev/alt-slim-pickins && exec ruby studio/app.rb`
- The checkers' status page at `/status` re-runs the gate live on every visit.

## Comprehensive Housekeeping Protocol (The RIF Loop)

You must execute every step of this loop per round, not at the end of the session:
1. **Implement & Verify**: Ensure suite is 100% green:
   `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/check_promises.rb && ruby bin/check_conventions.rb && ruby bin/check_card.rb && ruby bin/verify_pages.rb && ruby -Ilib:test -e 'Dir["test/**/*_test.rb"].each { |f| require "./#{f}" }'`
2. **Commit**: Leave the tree clean. Commit with an intention-revealing message. (Push only when dan says so).
3. **Update `PROJECT.md`**: Update `status`, `last_touched`, and advance `next_step`.
4. **Validate `PROJECT.md` YAML**:
   `ruby -ryaml -e 'YAML.safe_load(File.read("PROJECT.md")[/\A---\n(.*?)\n---/m, 1], permitted_classes: [Date])'`
5. **Update the Roadmap**: Record findings, decisions, and phase completions in active `ROADMAP-*.md`.
6. **Update `working-with-dan.md`**: Record any durable lessons learned about working with dan.
7. **Record Lore**: POST what you *learned* to the ecosystem's memory:
   `curl -X POST http://127.0.0.1:4000/api/lore/alt-slim-pickins -H 'Content-Type: application/json' -d '{"message":"...", "who":"<your-name>"}'`
8. **Report to Journal**: POST a brief status update:
   `curl -X POST http://127.0.0.1:4000/api/journal -H 'Content-Type: application/json' -d '{"message":"..."}'`

## Standing principles — do not break without saying so

- One sentence: `word arguments`, indentation nests it. Extending the language
  adds vocabulary, never syntax. A dot means data; a bare word is language.
  There is no numeric literal. A name is a subject and must exist. Mechanical
  facts are free; judgements belong to the app. A line that states the
  inferable should not exist. This is a noun language — 59 of 64.
- **Every truth has one home** (the grammar in Transform, the vocabulary in
  contracts, the checkers consuming, never mirroring).
- **A rule must outlive its reason** — when a proscription blocks empowerment
  *and* better code, examine its foundation; it survives only if the
  foundation is worth more than what it blocks.
- **Word, or power?** — for every candidate surface, the language grows by
  words; the surface grows only when the answer is honestly "power."
- **The dogfood is enforced**: built-ins and app words eat the same food, by
  test, and the gatherers are re-provable as app words, byte for byte.
- **The escape-hatch number is retired.** Stop quoting it.
- **`~/dev/dashboard` must keep working, untouched.**
- **`~/dev/roth` is a separate, dormant project and has not been touched.**
