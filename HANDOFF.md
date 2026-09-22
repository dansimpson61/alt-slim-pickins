# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
3. `ROADMAP-0.3.md` — Roadmap 0.3 is completed (all 5 phases 0–4 closed and judged). `PROJECT.md` `next_step` points at candidate package prioritization (Packages A–D) for the next roadmap.
4. `HANDOFF.md` — this document, specifically the candidate packages menu below
5. `PRIMER.md` — the Way, as it stands now (the tour replaces the old Slim-Pickins primer)
6. `DESIGN.md`, `CONTRACT.md` — the grammar and the app promise; `VOCABULARY.md`'s five checkable bullets per entry are generated (`bin/generate_vocabulary.rb`), and so are the `conventions` bullets of the 39 words that declare one
7. `LORE.md` — what previous sessions *learned*; the last entries are this session's
8. `working-with-dan.md` — candid notes on working with him: what his questions mean, what lands, what does not. It is short, it is honest, and **it is yours to keep true** — updating it is part of the round.

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

**Roadmap 0.3 is fully closed.** The forward eye's discipline has answered its core question:
- **Phase 0 (Studio won iteratively)**: Wins 1–11 closed; multi-UI architecture landed with classic and workbench UIs; try-it integration verified live.
- **Phase 1 (The garden, planted)**: All 4 demonstration applications landed (`lore_reader`, `way_exam`, `milestone_planner`, `word_graph`), including an outside-author build for `lore_reader`.
- **Phase 2 (Measure the demand)**: Read-only dashboard surfaces (`brief.sp`, `doc.sp`, `pattern.sp`) ported; 54 ecosystem markdown docs audited; 26 demand gaps ($G_1$–$G_{26}$) logged in `DEMAND.md`.
- **Phase 3 (Grow only what the demand named)**: All 26 demand gaps settled (17 landed in core/runtime/vocabulary/markdown, 9 resolved via architectural boundaries/app space); live instruments (`check_promises.rb`, `check_conventions.rb`) preserved green.
- **Phase 4 (Serve, and be judged)**: Upgraded all garden apps and dashboard views to native affordances, eliminating workarounds: `choice radio`, `search to:`, predicate queries, `textarea readonly`; markdown engine repaired.

### Current Vitals (measured 2026-09-21)
- **Full Suite**: 418 runs, 4,561 assertions, 0 failures, 0 errors, 0 skips across 40 test files (one-process: 364 runs, 4,141 assertions).
- **Check Grammar**: 1,225 sentences checked, 94 words defined, 0 problems.
- **Check Shape**: 64 of 64 words used in real pages (plus 29 app words), 977 sentences, 0 problems.
- **Check Styles**: 26 emitted classes, 60 rendering, 105 rules, 0 problems.
- **Verify Pages**: 31 pages verified, 0 problems.
- **Promise Ledger**: 33 promises (30 read, 3 forwarded, 0 unread), 0 problems.
- **Convention Register**: 38 conventions, 0 problems.
- **Cost**: Cold 7.99 ms, Warm 6.10 ms (< 10 ms guardrail), Per row 0.25 ms (< 0.5 ms guardrail).

---

## The Candidate Packages Menu (Ready for Prioritization & Planning)

The deferred and blue-sky items from Roadmaps 0.2 and 0.3 have been organized into four coherent, executable candidate packages:

### Package A — Council's View Affordances (View DSL & Composition)
*Focus: Deepening view expressiveness without violating the single-sentence grammar.*
1. **Subject-shifting `card` (R3P2)**:
   - Allow `card holding` or `card .subject` to shift the subject context for its inner block, exactly like `section` does.
   - Solves repeated dotted attribute paths (e.g. `title item.title`, `badge item.status`) within repeated card components.
2. **`formaction` Button Groups (R3P3)**:
   - Support multiple submission actions within a single `<form>` using `<button formaction="/...">`.
   - Eliminates awkward workarounds where multi-action toolbars require multiple independent HTML forms or custom JS.
3. **Partial Payload Forwarding (R3P1)**:
   - Support `**payload` or open keyword forwarding into partial calls (`partial "name", **payload`).
   - Allows wrapper partials and layout decorators to pass undeclared options through without having to hardcode every modifier.

### Package B — Studio & Workbench Wins (Developer Tooling & Transparency)
*Focus: Turning the Studio into a moldable development environment with total runtime transparency.*
1. **Win W2: Test Suite Leg on `/status`**:
   - Run the full 418-test suite as a 5th live leg on the Studio `/status` page alongside `check_grammar`, `check_shape`, `check_styles`, and `verify_pages`.
2. **Win W3: "The Why Pane" / Inference Provenance Inspector**:
   - Inspired by Bret Victor's visible state and Tudor Gîrba's moldable development (`BLUESKY.md` Part 4).
   - In the Studio Workbench, an interactive inspector pane that annotates every `.sp` sentence with:
     - **What was decided**: the exact computed inference (e.g., `text-align: right`, `input type="number"`, `label: "Gross Margin"`, `format: currency`).
     - **Who owned the decision**: the 4-tier ownership provenance:
       - `page`: explicit kwargs (`as: money`, `placeholder: "..."`).
       - `app`: domain methods (`label_for`, `format_for`).
       - `language`: mechanical shape rules (`Inference.label`, numeric alignment).
       - `theme`: axiomatic visual tokens (the 53 CSS custom properties; the absent grade in views).
     - **Which convention fired**: links to one of the 38 registered conventions in `SlimPickins::Conventions::ALL`.
     - **How to override it**: shows the view author the exact idiom to take back control.
3. **Unified Workbench (Collapsible Shelf)**:
   - Fold the docs try-it pane and the vocabulary palette into one cohesive, collapsible library shelf, eliminating cognitive friction between browsing words and exploring templates.

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
