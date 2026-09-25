# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
3. `PROJECT.md` — `next_step`: no active thread as of 2026-09-25; three items
   deliberately left open for a future token ground-truthing daytrip
4. `HANDOFF.md` — this document, specifically the active itinerary below
5. `DAYTRIP-0.4.0a.md` through `DAYTRIP-0.4.0g.md` — outcomes of every daytrip so far
6. `COMMUNITY_BULLETIN_BOARD.md` — the council's most recent session (currently:
   the workbench spatial frontier fixes, 2026-09-25); `.claude/skills/council/SKILL.md`
   is the reusable skill, read it before convening the council again
7. `PRIMER.md` — the Way, as it stands now
8. `DESIGN.md`, `CONTRACT.md` — the grammar and the app promise; `VOCABULARY.md`'s checkable bullets per entry are generated (`bin/generate_vocabulary.rb`)
9. `LORE.md` — what previous sessions *learned*; the last entries are this session's
10. `working-with-dan.md` — candid notes on working with him: what his questions mean, what lands, what does not. It is short, it is honest, and **it is yours to keep true** — updating it is part of the round.

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

**Roadmap 0.4 is underway as an iterative sequence of winnable daytrip victories:**
- **Volet 1 (The Truthful Floor, `DAYTRIP-0.4.0a.md`)**: Landed 2026-09-22. Established `SlimPickins::Census` (`bin/census.rb`) as the living SSOT; settled F9 (`Chart` declares `table_header`); enriched `Conventions.bullet` with concrete element yields.
- **Volet 2 (Expressive View Composition, `DAYTRIP-0.4.0b.md`)**: Landed 2026-09-22. Delivered R3P2 (subject-shifting `card`, eliminating 7 repeated bindings in `queue.sp`), R3P3 (single-form `formaction` button groups in `actions.sp`), and R3P1 (open partial payload forwarding via `takes: payload` / `open: true`).
- **Volet 3 (Studio & Workbench Wins, `DAYTRIP-0.4.0c.md`)**: Landed 2026-09-22. Delivered W2 (live test suite 8th leg on `/status`) and W3 (combined `Inspect` surface uniting Semantic Tree AST and The Why Pane / inference provenance inspector).
- **Volet 4 (The Empirical Diagnostic Taxonomy, `DAYTRIP-0.4.0d.md`)**: Landed 2026-09-22. Delivered `SlimPickins::Taxonomy` as SSOT for 5-tier deductive hierarchy (Structural, Semantic, Interactive, Behavioral, Visual); 64-word empirical diagnostic audit surfacing missing `stack`/`cluster`, ad-hoc `figcaption`/`summary` kernel leaks, and the visual styling idiom standard; multi-category shelf presence with cross-facets on Workbench and Classic UIs; `PRIMER.md` updated.
- **Volet 4b (Studio Partial Minting & Bite-Sized Domain Words, `DAYTRIP-0.4.0e.md`)**: Landed 2026-09-23. Delivered in-buffer `def <word>, *params` authoring with flexible argument binding, declaration-free word execution (Package C proving ground), enhanced `box subject, title` context shifting, positional `link` fallback, Studio `/mint` endpoint, and live editor minting toolbar affordance.
- **Volet 5 (Package C: Lean & Elemental Kernel, `DAYTRIP-0.4.0f.md`)**: Landed 2026-09-23. Privileged `tag` primitive with a compilation-privilege boundary; `figcaption`/`summary` absorbed into their single consumers (64 words → 62); `paragraph` re-atomized over `tag p`; flexible argument binding generalized to disk `def` partials.
- 2026-09-24 (no numbered volet): the Visual Architecture & Spatial Manifesto compiler landed (`docs/DESIGN_IDIOM.md`, `lib/slim_pickins/compiler/design_idiom.rb`), then the Council spatial manifesto (`horizon`/`posture`/`scroll`/`presence`/`focus`) the same round.
- **Volet 6 (The Council Skill & Workbench Spatial Frontier, `DAYTRIP-0.4.0g.md`)**: Landed 2026-09-25. The council pattern formalized as a reusable skill (`.claude/skills/council/SKILL.md`), used to resolve the four workbench spatial frontiers (revised mid-session after dan rejected an authoring-redundancy proposal), then three real rendering defects dan caught by eye — a `max-width` leak, container queries that had never actually worked since the compiler's first commit, and three shell columns at three different heights.
- **Active next step**: **none** — three items deliberately left open for a future token ground-truthing daytrip (see `PROJECT.md next_step` and `DAYTRIP-0.4.0g.md`'s closing section).

### Current Vitals (measured 2026-09-25)
- **Census SSOT (`bin/census.rb`)**: 62 canonical words (39 Ruby primitives + 23 .sp partials), 7 apps, 26 app words, 31 verified pages, 38 conventions, 35 promises, 105 stylesheet rules, 49 test files.
- **Full Suite**: 445 runs, 5,619 assertions, 0 failures, 0 errors, 0 skips in one process.
- **Check Grammar**: 1,254 sentences checked, 94 words defined, 0 problems.
- **Check Shape**: 62 canonical words, 1,006 sentences, 0 problems.
- **Check Styles**: 27 emittable classes, 59 rendering, 105 rules, 0 problems.
- **Verify Pages**: 31 pages verified, 0 problems.
- **Promise Ledger**: 35 promises (32 read, 3 forwarded, 0 unread), 0 problems.
- **Convention Register**: 38 conventions, 0 problems.
- **Resume Card**: 7 fields present, last_touched 2026-09-25, 0 problems.

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

### [COMPLETED] Volet 4: The Empirical Diagnostic Taxonomy (`DAYTRIP-0.4.0d.md`)
- **Taxonomy Engine (`lib/slim_pickins/taxonomy.rb`)**: Single source of truth for the 5-tier deductive hierarchy (Structural, Semantic, Interactive, Behavioral, Visual) and complete 64-word empirical audit ledger.
- **Empirical Diagnostic Revelations**:
  - Missing primitives diagnosed: `stack` (uniform vertical rhythm layout), `cluster` (horizontal flow).
  - Ad-hoc single-consumer anomalies diagnosed: `figcaption` (in-degree 1 in `figure`) and `summary` (in-degree 1 in `disclosure`) pinpointed as kernel HTML element leaks, validating Package C.
  - Cohesion vs. split: `box` and `span` identified as split/overload candidates; 38 multi-category words confirmed as cohesive concepts.
  - The Visual Tier standard: confirmed that no vocabulary primitive exists solely for decorative paint; styling belongs to theme/variant idioms.
- **Studio Shelf & Documentation**:
  - Studio shelf (Workbench `library.sp` and Classic `vocabulary.sp`) organized into 5 tiers with authoring questions, counts, and multi-category presence with secondary cross-facets.
  - `PRIMER.md` updated with "The Deductive Structure (The Five Tiers)".

### [COMPLETED] Volet 4b: Studio Partial Minting & Bite-Sized Domain Words (`DAYTRIP-0.4.0e.md`)
- **In-Buffer Words via `def <word_name>, *params` (`lib/slim_pickins/transform.rb`)**: Top-level definitions hoisted in AST and evaluated as local builder words before page body execution.
- **Flexible Argument Binding (`lib/slim_pickins/builder.rb`)**: Positional ordering, order-independent keyword mapping, nil defaults for omitted parameters, open kwargs forwarding into chain scope, child block splicing via `children`.
- **Declaration-Free Execution**: Author words run with zero `contract` metadata or `expects` preambles; serves as the living proving ground for Package C.
- **Enhanced Primitives**: `box subject, title` shifts context and handles empty/nil subjects gracefully; positional `link label, href` fallback.
- **Studio Minting Affordance (`studio/pages.rb`, `studio/app.rb`, `assets/studio.js`)**: Interactive `Mint <word>(*params) → partial` toolbar button in editor; `POST /mint` endpoint promotes local definitions to disk partials and re-renders live.

### [COMPLETED] Volet 5: Package C — Lean & Elemental Kernel (`DAYTRIP-0.4.0f.md`)
- **Privileged `tag` Primitive**: strictly refused in app/user templates by compiler error; compilation cache partitioned on `[source, privileged]`.
- **Absorbed Single-Consumers**: `figcaption`/`summary` folded into `figure`/`disclosure` (canonical vocabulary 64 → 62).
- **Re-atomized `paragraph`**: expressed as a `.sp` partial over `tag p`.
- **Flexible Argument Binding for Disk Partials**: `Builder.bind_parameters` generalizes Volet 4b's binding engine to `.sp` partials on disk, not just in-buffer.
- Byte-diff verified against all application pages; warm render 6.24 ms (budget 10 ms).

### [COMPLETED] The Design Idiom Compiler & Council Spatial Manifesto (no volet number, 2026-09-24)
- **`SlimPickins::Compiler::DesignIdiom`** (`lib/slim_pickins/compiler/design_idiom.rb`, `docs/DESIGN_IDIOM.md`): a companion `.design` language compiling qualitative spatial vocabulary (`surface`, `stage`, `zone`, `flank`, `stack`, `air`, `frame`, `cadence`, `treatment`) to modern CSS Grid + Container Queries.
- Same round: `horizon`/`posture` (multi-zone planes), `scroll`/`presence`/`focus` zone qualities, Sandi Metz hygiene (`min-height: 0`), `.panes` dissolution via `display: contents`.

### [COMPLETED] Volet 6: The Council Skill & Workbench Spatial Frontier (`DAYTRIP-0.4.0g.md`)
- **`.claude/skills/council/SKILL.md`**: the multi-persona architecture-debate pattern formalized as a reusable skill — one continuous transcript, never one subagent per persona; every round after the first must engage a specific prior claim by name.
- **The four workbench spatial frontiers resolved** (qualitative collapse tokens, one compiled-CSS pipeline with provenance, real selectors replacing a defensive 6/7-way guess list, `100vh` → `100dvh`) — Frontier 3 revised mid-session after dan rejected authoring an already-inferable zone name as a `data-*` HTML attribute literal.
- **Three real rendering defects**, each found by dan in the live studio and measured before being touched: a `max-width` leak in the editor's textareas; container queries that had never worked since the compiler's first commit (a self-referencing `@container` pattern — fixed with zero new markup); `align-items: start` leaving the three shell columns at three different heights (now `stretch`).
- Left open, by dan's own call: the `collapse`/`balance` rem scale, `output`'s independently-governed height, `--footer-height`'s corrected-but-still-guessed value — candidates for a future token ground-truthing daytrip, not decided this round.

### No active next step

Nothing is mandated next. Candidates, none prioritized over the others —
open with dan rather than picking unilaterally:
- **The token ground-truthing daytrip** named above (`DAYTRIP-0.4.0g.md`'s closing section) — real values for the `.design` collapse/balance scale and the workbench's menu/footer-height constants, measured against real embedding widths instead of preserved-by-habit numbers.
- **Package D** below (still unstarted, still valid).
- Whatever roadmap question dan brings to the next session — this project's own convention (`README.md`, *How roadmaps go*) is to re-read the history and lore before choosing a direction, not to assume the last session's tail is the next session's head.

### Package D — House Honesty & Integrity (Census, Registry & Doc Parity)
*Focus: Aligning every prose document and registry with the living reality of the codebase.*
1. **Harmonize Historical Prose Census**:
   - Realign `README.md`, `DESIGN.md`, `PRIMER.md`, and `CONTRACT.md`.
   - Update historical figures (outdated "53 words / 2 apps / 10 pages") to the true living counts (62 words / 7 apps / 31 pages).
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
- **A `.design`/`.sp` file edit takes effect on the next request, with no
  restart** — the compiler reads those fresh every time. A `lib/` Ruby
  code edit does not; Ruby doesn't reload changed source, so the running
  process keeps serving the old code until it's actually restarted.
- **Restarting reliably is the trap** (cost two dead-end detours in
  2026-09-25's session, `DAYTRIP-0.4.0g.md`): Puma renames its own process
  title to `puma 8.0.2 (tcp://localhost:4580) [alt-slim-pickins]`, so
  `pgrep -f "ruby studio/app.rb"` silently matches nothing, `kill`s
  nothing, and a second `ruby studio/app.rb &` then fails to bind (port
  still held) while the stale process keeps answering every request as if
  the restart worked. Kill by the listening socket's actual PID instead:
  `kill $(lsof -t -i:4580)` (or `ss -ltnp | grep 4580`), confirm the port
  is free, *then* start the new process — and verify with a direct
  `curl`/`fetch` for a string only the new code would emit, not just an
  HTTP 200, before trusting anything rendered against it.
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
  inferable should not exist. This is a noun language — 57 of 62.
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
