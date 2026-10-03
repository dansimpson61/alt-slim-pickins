# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
3. `PROJECT.md` — `next_step`. As of 2026-10-02 it resumes at **Tier 2 of
   `DAYTRIP-0.4.0h.md`**, the eleventh gate leg. Trust it over this file's
   itinerary if the two ever disagree; the card is updated every round and this
   file has lagged it by a week before.
4. `HANDOFF.md` — this document, specifically the active itinerary below
5. `DAYTRIP-0.4.0a.md` through `DAYTRIP-0.4.0h.md` — outcomes of every daytrip so
   far. **Read `0.4.0h` first if you are picking up the current thread**: it is the
   audit round, it carries the prioritized list the next several rounds work
   through, and its *What landed* section says what is already done
6. `COMMUNITY_BULLETIN_BOARD.md` — the council's most recent session (currently:
   the workbench spatial frontier fixes, 2026-09-25); `.claude/skills/council/SKILL.md`
   is the reusable skill, read it before convening the council again
7. `PRIMER.md` — the Way, as it stands now
8. `DESIGN.md`, `CONTRACT.md` — the grammar and the app promise; `VOCABULARY.md`'s checkable bullets per entry are generated (`bin/generate_vocabulary.rb`)
9. `LORE.md` — what previous sessions *learned*; the last entries are this session's
10. `working-with-dan.md` — candid notes on working with him: what his questions mean, what lands, what does not. It is short, it is honest, and **it is yours to keep true** — updating it is part of the round.

**Two names changed on 2026-09-26 and older documents may still use the old ones.**
The frame a page wears is a **tin** (`.tin`, was `layout.sp`), and the design
idiom is **Spiff** (`.spiff`, was `Design Idiom` / `.design`). "Layout" survives
only where it means the visual arrangement, which is Spiff's business.

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

**Roadmap 0.4 is underway as an iterative sequence of winnable daytrip victories:**
- **Volet 1 (The Truthful Floor, `DAYTRIP-0.4.0a.md`)**: Landed 2026-09-22. Established `SlimPickins::Census` (`bin/census.rb`) as the living SSOT; settled F9 (`Chart` declares `table_header`); enriched `Conventions.bullet` with concrete element yields.
- **Volet 2 (Expressive View Composition, `DAYTRIP-0.4.0b.md`)**: Landed 2026-09-22. Delivered R3P2 (subject-shifting `card`, eliminating 7 repeated bindings in `queue.sp`), R3P3 (single-form `formaction` button groups in `actions.sp`), and R3P1 (open partial payload forwarding via `takes: payload` / `open: true`).
- **Volet 3 (Studio & Workbench Wins, `DAYTRIP-0.4.0c.md`)**: Landed 2026-09-22. Delivered W2 (live test suite 8th leg on `/status`) and W3 (combined `Inspect` surface uniting Semantic Tree AST and The Why Pane / inference provenance inspector).
- **Volet 4 (The Empirical Diagnostic Taxonomy, `DAYTRIP-0.4.0d.md`)**: Landed 2026-09-22. Delivered `SlimPickins::Taxonomy` as SSOT for 5-tier deductive hierarchy (Structural, Semantic, Interactive, Behavioral, Visual); a vocabulary-wide empirical diagnostic audit surfacing missing `stack`/`cluster`, ad-hoc `figcaption`/`summary` kernel leaks, and the visual styling idiom standard; multi-category shelf presence with cross-facets on Workbench and Classic UIs; `PRIMER.md` updated.
- **Volet 4b (Studio Partial Minting & Bite-Sized Domain Words, `DAYTRIP-0.4.0e.md`)**: Landed 2026-09-23. Delivered in-buffer `def <word>, *params` authoring with flexible argument binding, declaration-free word execution (Package C proving ground), enhanced `box subject, title` context shifting, positional `link` fallback, Studio `/mint` endpoint, and live editor minting toolbar affordance.
- **Volet 5 (Package C: Lean & Elemental Kernel, `DAYTRIP-0.4.0f.md`)**: Landed 2026-09-23. Privileged `tag` primitive with a compilation-privilege boundary; `figcaption`/`summary` absorbed into their single consumers (`64` words → `62`); `paragraph` re-atomized over `tag p`; flexible argument binding generalized to disk `def` partials.
- 2026-09-24 (no numbered volet): the Visual Architecture & Spatial Manifesto compiler landed (`docs/SPIFF.md`, `lib/slim_pickins/compiler/spiff.rb`), then the Council spatial manifesto (`horizon`/`posture`/`scroll`/`presence`/`focus`) the same round.
- **Volet 6 (The Council Skill & Workbench Spatial Frontier, `DAYTRIP-0.4.0g.md`)**: Landed 2026-09-25. The council pattern formalized as a reusable skill (`.claude/skills/council/SKILL.md`), used to resolve the four workbench spatial frontiers (revised mid-session after dan rejected an authoring-redundancy proposal), then three real rendering defects dan caught by eye — a `max-width` leak, container queries that had never actually worked since the compiler's first commit, and three shell columns at three different heights.
- **2026-09-26 (no numbered volet): the truth round, the naming, and the tin.** Nine rounds of work, all recorded in `ROADMAP-0.3.md`'s Addenda 1–14 and `LORE.md`:
  1. **Truth round** — five living documents realigned to measured counts; `check_design_docs.rb` (now `check_spiff.rb`) built to hold the lexicon to the compiler and `check_design_docs`'s sibling `GuideRenderingTest` added after two guides rendered raw HTML and backslashes; the markdown engine's code-span pairing fixed (a span may now contain backticks).
  2. **`sidebar_layout` → `shell`, then `foot` → `footer`** — the design idiom's founding complaint finished.
  3. **The audit** that found the pattern: *a partial whose whole body is `box` + `children` exists only to hand a stylesheet a class*, which is a presentation decision in substance clothing.
  4. **`layout.sp` → `[app].tin`** — the word "layout" retired from the language; `Library#tin`, the `:tin` convention.
  5. **Spiff named** — `DesignIdiom` was a description doing a name's job; module, doc, gate and suffix now all say Spiff, and the extension followed (`.design` → `.spiff`).
  6. **Per-view resolution** — `[view].tin`/`[view].spiff` beat the app's, one rule in one place (`Library#tin_for`, `Library.spiff_for`), lifted out of the studio.
  7. **Asset inference** — a page gets `slim-pickins.css` unasked, plus `public/css/[app].css` or `[view].css` when they exist and `Library.from(…, public_url:)` says where they are served. A default, not a replacement: `stylesheet`/`script` remain.
  8. **`check_spiff_scope.rb`** — the tenth gate, answering dan's own question: every zone a Spiff names must be renderable in its scope.
- **Active next step**: **none.** The tin/Spiff work is closed. Open threads are named in `PROJECT.md next_step` and in the section below.

### Current Vitals (measured 2026-10-03)

Every number below that the census measures is now held by `check_vitals.rb`, so
this block cannot go stale without the gate saying so. The rows it does *not*
measure are quoted as the gate output they are.

- **Census SSOT (`bin/census.rb`)**: 62 canonical words (39 Ruby primitives + 23 `.sp` partials), 7 apps, 24 app words, 31 verified pages, 38 conventions, 35 promises, 104 stylesheet rules, 54 test files.
- **Full Suite**: 568 runs, 0 failures, 0 errors, 0 skips in one process — and
  that now includes the example apps' own suites, because the Suite leg asks
  `Census.test_files` instead of keeping its own glob.
- **Check Grammar**: `1,239 sentences checked, 92 words defined, 0 problems`.
- **Check Shape**: 62 canonical words, 0 problems.
- **Check Styles**: 27 emittable classes, 59 rendering, 104 rules, 0 problems.
- **Spiff (lexicon)**: 16 entries, 84 documented declarations, 0 problems.
- **Spiff Scope (zones)**: 2 spiffs held to their pages, 0 problems.
- **Promises / Conventions / Card / Pages**: 35 / 38 / 7 fields / 31 pages, 0 problems.
- **Twelve gate legs** on `/status`, which re-runs them live: Grammar, Shape, Styles, Spiff, Scope, Promises, Conventions, Card, Pages, Vitals, Ruby, Suite. The Suite leg asks `Census.test_files`, so the example apps' suites are inside the gate now.
- **Byte-diff corpus digest** (`ruby bin/byte_diff.rb`): `d85aac01f281cb9a15e73e03` as of commit 74842bc — but see the note in that file: the digest moves when `LORE.md` does, so compare snapshots within a session rather than against a number written down over 31 pages.
- **`ruby -w -c`** is clean over `lib/`, `studio/`, `bin/`, the checkers, the suite and the example apps.

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
- **Taxonomy Engine (`lib/slim_pickins/taxonomy.rb`)**: Single source of truth for the 5-tier deductive hierarchy (Structural, Semantic, Interactive, Behavioral, Visual) and a complete vocabulary-wide empirical audit ledger.
- **Empirical Diagnostic Revelations**:
  - Missing primitives diagnosed: `stack` (uniform vertical rhythm layout), `cluster` (horizontal flow).
  - Ad-hoc single-consumer anomalies diagnosed: `figcaption` (in-degree 1 in `figure`) and `summary` (in-degree 1 in `disclosure`) pinpointed as kernel HTML element leaks, validating Package C.
  - Cohesion vs. split: `box` and `span` identified as split/overload candidates; the multi-category words confirmed as cohesive concepts.
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

### [COMPLETED] The Spiff Compiler & Council Spatial Manifesto (no volet number, 2026-09-24)
- **`SlimPickins::Compiler::Spiff`** (`lib/slim_pickins/compiler/spiff.rb`, `docs/SPIFF.md`): a companion `.spiff` language compiling qualitative spatial vocabulary (`surface`, `stage`, `zone`, `flank`, `stack`, `air`, `frame`, `cadence`, `treatment`) to modern CSS Grid + Container Queries.
- Same round: `horizon`/`posture` (multi-zone planes), `scroll`/`presence`/`focus` zone qualities, Sandi Metz hygiene (`min-height: 0`), `.panes` dissolution via `display: contents`.

### [COMPLETED] Volet 6: The Council Skill & Workbench Spatial Frontier (`DAYTRIP-0.4.0g.md`)
- **`.claude/skills/council/SKILL.md`**: the multi-persona architecture-debate pattern formalized as a reusable skill — one continuous transcript, never one subagent per persona; every round after the first must engage a specific prior claim by name.
- **The four workbench spatial frontiers resolved** (qualitative collapse tokens, one compiled-CSS pipeline with provenance, real selectors replacing a defensive 6/7-way guess list, `100vh` → `100dvh`) — Frontier 3 revised mid-session after dan rejected authoring an already-inferable zone name as a `data-*` HTML attribute literal.
- **Three real rendering defects**, each found by dan in the live studio and measured before being touched: a `max-width` leak in the editor's textareas; container queries that had never worked since the compiler's first commit (a self-referencing `@container` pattern — fixed with zero new markup); `align-items: start` leaving the three shell columns at three different heights (now `stretch`).
- Left open, by dan's own call: the `collapse`/`balance` rem scale, `output`'s independently-governed height, `--footer-height`'s corrected-but-still-guessed value — candidates for a future token ground-truthing daytrip, not decided this round.

### [COMPLETED] The workbench word page, three layers deep (2026-09-29)

A page renders through a stack of grids and every layer thought it owned the
layout: the compiler dissolved any *descendant* `.panes` rather than the shell's
own; `display: contents` made `.word_docs`' placement rules match nothing; and
compiled zone rules are descendant selectors, so `.shell .editor` names the
shell's columns inside any nested grid. Fixed at each layer. The studio's footer
counts stopped being hand-kept literals and now read `Census`.

### [COMPLETED] Volet 7: The audit round (`DAYTRIP-0.4.0h.md`, 2026-10-02)

The backward eye, on dan's ask: a critique on the project's own terms, then the
sharper question — do the ten checkers carry their weight? Measured: yes, and
they are aimed one layer too high. Eight of ten compare a declaration to a
declaration; both defect classes that have actually cost sessions here (the
rendered pixel, the arithmetic in prose) fall outside that. Four exist only
because a truth has two homes. The diversion is real and the documents are doing
it — 40,082 lines of markdown churned against 33,153 of Ruby.

**Tier 1 landed**: `check_spiff_scope.rb`'s `app_root` bounded (the suite's
standing error); the vocabulary count now measured where it is graded
(`way_exam` q5, `word_graph`'s two red tests). **Tier 4 landed**: the thirteen
dedented `def`s, seven more indentation mismatches inside method bodies, the
duplicate `Builder#chain`, two dead comments, `about`'s guard restructured, three
dead locals. **New instruments**: `bin/byte_diff.rb` and `ruby -w -c`.

### The active next step — Tier 5 of `DAYTRIP-0.4.0h.md`, and three things to confirm

Tiers 1 through 4 are landed, green and recorded — the audit round in
`DAYTRIP-0.4.0h.md`, the two new legs in `DAYTRIP-0.4.0i.md`. **Read 0.4.0i
before picking this up**; it carries the design arguments you would otherwise
re-derive.

**What changed that the rest of this file assumes.** The gate is **twelve legs**:
`check_vitals.rb` holds every number the living prose and the `.rb` comments
state about this project to `Census.snapshot`, and `check_ruby.rb` runs
`ruby -w -c` over every Ruby file with a warning counting as a failure. The Suite
leg no longer keeps its own glob — it asks `Census.test_files`, so the five
example apps' suites are inside the gate and the suite is 568 runs in one
process. `StudioStatus::LEGS` is still the one home for the leg list, and
`README`'s gate command is the second copy of it.

**Three things to confirm rather than discover**, each a judgement this round
made and named rather than absorbed:

1. **`KERNEL.md` is exempt from the vitals gate**, against the scope decision
   written here last round. Its own first paragraph pins its measurements to tree
   `5d43fe9`, which is the test every other exemption uses. The argument is in
   `DAYTRIP-0.4.0i.md` Part 1; aligning the written scope with it is dan's call.
2. **`README`'s "Everything green" is gone**, replaced by a sentence saying what
   green does and does not cover — including that no leg renders to a browser and
   that this is deliberate.
3. **`word_count` and `words_count` are still two names for one number**, named
   in `StudioVitals` rather than reconciled. Renaming a local changes every page
   that says it, so it is a proposal.

**Next on the list is Tier 5, and both of its items subtract.** Stop committing a
generated `VOCABULARY.md` (`bin/generate_vocabulary.rb` makes it, and
`check_grammar`'s `UNGENERATED` section exists only to verify the committed copy
still matches its generator — the Ode's answer to two copies of one truth is one
home, not a checker). Then delete or retarget `check_spiff_scope.rb`, which is
the one leg with no recorded catch.

**Then Tier 6, resequenced**: rewrite `studio/inspector.rb` in the language it
inspects *before* naming the semantic node with `Data.define`, because the
rewrite deletes three of the twenty node-read sites and unblocks pointing
`check_styles` at `studio/` (Tier 4's last item, still red on that file). Item 19
will surface vocabulary gaps that need dan's rulings.

**Tier 7 is the card surgery, and this file is now the clearest instance of it.**
`HANDOFF.md` restates the contents of nine `DAYTRIP-*.md` files and is the second
most-churned file in the repository's history (3,227 lines) behind a closed
roadmap. Its numbers are correct and gate-held now; the duplication is not. That
is Part 4 of the audit — "the diversion is real, and the documents are doing it"
— pointing at the resume prompt itself.

### Then, in order — and the order changed

- **Tier 4's last item is blocked.** Pointing `check_styles.rb` at `studio/*.rb`
  (it reads `lib/**/*.rb` only) goes red immediately on `studio/inspector.rb`'s 37
  hardcoded hex colours and two `100vh`. Do it *after* the rewrite below, not
  before, or you add a gate with no remedy.
- **Tier 6 is resequenced: item 19 before item 18.** `studio/inspector.rb:17` is a
  255-line method that is mostly one HTML heredoc — 39 raw tags — in the one
  surface a visitor opens to see what the language *means*. Rewriting it in the
  language is the best dogfooding test the studio could run and will likely
  surface vocabulary gaps worth more than the fix. It also *deletes* 3 of the 20
  node-read sites that item 18 would otherwise have to touch.
- **Tier 6 item 18, with corrected numbers.** Give the semantic node a name
  (`Data.define(:word, :attributes, :children)`). The audit claimed the anonymous
  triple "forces most of the 60 `is_a?` tests" — **that was wrong**, and the
  correction matters for the decision: `is_a?(Array)` in `lib/` is 7, of which ~6
  are node-vs-string guards. The 60 are dominated by `Symbol` (15), `String` (9),
  `Proc` (6) and `Hash` (6) — argument discrimination in the DSL's own calling
  convention, which this refactor does not touch. Real scope: **20 read sites, 29
  construction sites**, in `builder.rb`, `generator.rb`, `partial_word.rb` and
  `studio/inspector.rb`. Payoff: one good name, plus ~6 guards. Note
  `kind, attrs, children = node` destructuring will not survive `Data` (no
  `to_ary`), and children arrays legitimately hold Strings and nils.
- **Tier 7**: the card surgery. `PROJECT.md`'s `status` is now over 12,000
  characters and `bin/check_card.rb` prints the number every green run without an
  opinion. Give it a budget and fail over it; the narrative belongs in `LORE.md`,
  which already holds most of it.

### Two instruments this round added — use them, do not rebuild them

- **`ruby bin/byte_diff.rb`** renders all 31 pages the gate proves and reduces the
  corpus to one digest; `ruby bin/byte_diff.rb /tmp/before` also writes each page
  for `diff -r`. Current digest: `d85aac01f281cb9a15e73e03` as of commit 74842bc — but see the note in that file: the digest moves when `LORE.md` does, so compare snapshots within a session rather than against a number written down. This is the
  acceptance test for any shape or refactor work — every "byte-identical" claim in
  Tier 4 was made with it. `bin/verify_pages.rb` is now requirable (its execution
  sits behind `if $PROGRAM_NAME == __FILE__`) so `PAGES` has one home.
- **`ruby -w -c <file>`** reports indentation mismatches and dead locals, in the
  interpreter the project already runs, with no gem. It found seven mismatches a
  grep for dedented `def` lines could not see, and three dead assignments nothing
  else had. The repo is clean against it today. **Wiring it as a gate leg is
  proposed and not done** — it changes the gate command, the README and the status
  page's leg count, which is dan's call. The whole implementation is one loop:

      for f in lib/**/*.rb studio/*.rb bin/*.rb check_*.rb test/*.rb; do
        ruby -w -c "$f" 2>&1 | grep -v '^Syntax OK$'
      done

### Candidates still standing, none prioritized

- **The token ground-truthing daytrip** (`DAYTRIP-0.4.0g.md`'s closing section) —
  real values for the `.spiff` collapse/balance scale (`tight`'s 26rem,
  `subordinate`'s 14rem floor), `output`'s independently governed height, and
  `--footer-height` (2.8rem is corrected but still guessed, and Spiff's generated
  CSS still carries a stale 2rem fallback).
- **Package D** below — re-read before starting; its item 1 is largely done.
- **Two leftovers, dan's call**: `pages/pages.tin` and
  `examples/portfolio/views/portfolio.tin` are byte-identical; the classic UI still
  has no `.spiff`, so its presentation still pools in `slim-pickins.css`.
- **Retire a generated file that is committed and then gated** —
  `bin/generate_vocabulary.rb` writes five bullets per `VOCABULARY.md` entry from
  `contracts.rb`, and `check_grammar`'s whole `UNGENERATED` section then verifies
  the artifact still matches its generator. Render it at read time and that check
  becomes unnecessary rather than unenforced.
- **`check_spiff_scope.rb`: delete or retarget.** No recorded catch, and its job —
  names matching names — is the narrowest slice of the layer that stays correct on
  its own. Retargeting it to assert the zone's element *reaches the render* would
  make it the gate the project actually lacks.
- **The unserved `assets/workbench.css`** — awaiting dan's word to delete.
- Whatever roadmap question dan brings. This project's convention (`README.md`,
  *How roadmaps go*) is to re-read the history and the lore before choosing a
  direction, not to assume the last session's tail is the next session's head.

### Package D — House Honesty & Integrity (Census, Registry & Doc Parity)
*Focus: Aligning every prose document and registry with the living reality of the codebase.*
**Mostly done, verified 2026-09-26 — re-measure before starting any of it.**
1. ~~**Harmonize Historical Prose Census**~~ — **done.** The truth round realigned
   `README.md`, `PRIMER.md`, `DESIGN.md`, `VOCABULARY.md` and `PROJECT.md`, and
   `grep` finds no stale "53 words / 2 apps / 10 pages" in any of them.
2. ~~**Registry Hygiene & Dead Stub Removal**~~ — **an illusion, per the
   2026-09-22 audit** (`LORE.md`): the "14 blank slots" are words that declare
   no inferences, and the "dead stubs" do not exist. `VOCABULARY.md`'s rule 1
   is *no blank slots*, and it holds.
3. ~~**Unify Row-Oriented Label Conventions (F9)**~~ — **done in
   `DAYTRIP-0.4.0a.md`**: `chart` declares `table_header`, matching
   `Builder#label_of`.

What is left of Package D is a re-measurement pass, not a list of known work.

---

## Studio Process & Verification Protocol

The studio (`studio/`, port 4580, `STUDIO_PORT` to override) is agent-managed.
- Check the port: `curl -s -m 2 http://127.0.0.1:4580/`.
- If down or after code changes, run in background:
  `cd ~/dev/alt-slim-pickins && exec ruby studio/app.rb`
- **A `.spiff`/`.sp` file edit takes effect on the next request, with no
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
1. **Implement & Verify**: Ensure suite is 100% green. The gate has **twelve legs**
   (the same ten `/status` runs live):
   `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby check_spiff.rb && ruby check_spiff_scope.rb && ruby bin/check_promises.rb && ruby bin/check_conventions.rb && ruby bin/check_card.rb && ruby bin/verify_pages.rb && ruby bin/census.rb && ruby -Ilib:test -e 'Dir["test/**/*_test.rb"].each { |f| require "./#{f}" }'`
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
