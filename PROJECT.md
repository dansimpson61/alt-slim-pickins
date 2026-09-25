---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  DAYTRIP-0.4.0g.md closed 2026-09-25: the council skill (.claude/skills/council/SKILL.md,
  10-voice roster) landed, used it to resolve the four workbench spatial frontiers, then chased
  three real rendering defects dan caught by eye in the live studio — a max-width leak in the
  editor's textareas, container queries that had never actually worked since the compiler was
  first written (a self-referencing @container pattern, fixed with zero new markup by splitting
  container-type onto each wrapper's real DOM parent), and align-items: start leaving the three
  shell columns at three different heights (now align-items: stretch; library/editor match
  exactly, output stays independently sized by design). Two "verified live" claims this same
  session wrote into LORE.md earlier that night were themselves wrong and corrected in place.
  assets/workbench.css: 459 lines / 99 `:has(` -> 162 lines / 0. All 7 quality gates green
  (105 rules, 0 problems, 31 verified pages), 445 unit tests pass with 0 failures, one process.
  Nine commits, each independently green, verified against a genuinely restarted studio server
  and live DOM measurement — not screenshots alone.
kind: project
last_touched: 2026-09-25
next_step: >-
  No active thread — pick the next roadmap question fresh. Three items deliberately left open
  from tonight, candidates for a future token ground-truthing daytrip rather than piecemeal
  patches: collapse: tight's 26rem threshold and balance: subordinate's 14rem lead floor (the
  same underlying question — real values for the .design collapse/balance scale, measured
  against real embedding widths, not preserved-by-habit numbers); output's independent height
  under presence: steady (full three-way row parity needs that calc moved from the zone to the
  stage/row level — the same deferred "surface containment" idea as the first council session's
  Scope Proposal 1); and --footer-height: 2.8rem (corrected from a wrong 2rem this session, but
  still a hardcoded guess about the footer's real rendered size, same fragile character as tight).


run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: >-
  Roadmap 0.2 (ROADMAP-0.2.md, 2026-09-01), the first even-numbered,
  backward-leading roadmap (ataovy dian-tana), is past its backward look:
  Phases 0-2 closed — the Way rewritten (PRIMER.md), the vocabulary reviewed
  as contracts with check→checkbox and select→choice, the Builder
  un-god-objected (867 lines/16 ivars → 298/9, four gathering copies → one
  stack, byte-identical throughout). Phase 3's first half landed the
  semantic-node runtime, the open surface (built-ins and app words eat the
  same food, enforced by test), the filter: seam in render, and dan's
  principle recorded as constraint 3: a rule must outlive its reason. The
  payload — the boot gate — is next. The escape-hatch number is retired, in
  writing. Roadmap protocol set 2026-08-31: odd leads forward, even leads
  back; both eyes stay open. history/ is roadmap 0.1, consulted not
  maintained. HANDOFF.md is the prompt that resumes this work in a fresh
  conversation. DAYTRIP.md (2026-09-06) is a jaunt, not a roadmap — it leads
  with neither eye and took no ground the language did not already hold: the
  gate runs again, the suite tests what ships, the studio's guides work. Its
  findings are all settled; the two it left to Phase 6 are `action` at five
  arguments and vocabulary coverage at 54 of 69. "Tight Coupling in Ruby DSLs.md" (Gemini's critique of the
  Builder) is cited by the roadmap. Phase 4 is closed (2026-09-06), judged
  by dan: the gap ledger G1–G13 is disposed in examples/dashboard/INVENTORY.md,
  flash/action/search stay partials, and the verdict stands in ROADMAP-0.2.md
  Round D. The studio's docs links now render truthful payloads server-side
  (StudioDocs.entries is a plain hash, so word names never dispatch on an
  OpenStruct) with the fence warning note; the playground is unchanged.
  Phase 5 opened 2026-09-09 with a catch the dashboard's single-process test
  runner made: the docs payload assumed every partial is builtin, so the
  portfolio's account_card named a lib/vocabulary file that is not its own.
  A partial now carries its source_path from the Library (one glob, source
  and path together), the docs name the true home, and a partial declared
  inline says so. Prose landed its three forms (2026-09-09): fences, tables
  and ordered lists, still safe by construction — escaping first, no
  markdown engine; lists fold indented continuations and one level of
  nesting, GFM-faithful; the styles share the .snippet and .table rules;
  the guide/docs warning notes are gone. The status page landed
  (2026-09-09): /status runs the four gate legs live as subprocesses and
  serves their output through prose fences; the studio's pages joined the
  checker corpora (the furniture partials learned as an app), so the page
  the gate describes is held by the gate it describes. dan's Phase 5
  question is answered (2026-09-09): "Both the dashboard's md docs and the
  studio's md docs" — the dashboard's markdown surfaces are the next
  dogfood target (read-only, untouched), and the studio's curated guides
  grew README, ROADMAP-0.2, HANDOFF and DAYTRIP. Phase 5 is closed; the
  round record stands in ROADMAP-0.2.md.
  Phase 6 prep (2026-09-10) — the meta/icon audit: `meta` has no consumer in
  any of the six surfaces (the real dashboard's whole head is the charset
  and viewport `page` already infers), so it is the first name on the cut
  list; `icon`'s only consumers were the paper pages, and the studio's
  /status now wears `icon .state` + `badge .state` — its first living
  consumer — with the severity palette given one home (badge and icon share
  the rule per severity, and the sprite ships only the symbol used).
  Then the CSS-mark round (2026-09-10), on dan's call: a state's mark is
  drawn by the stylesheet off the class the markup already declares, so
  `note warning` grows its triangle and the status page's legs wear a tick
  or a dot with no page authoring a glyph and no sprite shipped. That makes
  `icon` superseded rather than merely unused, and it joins `meta` on
  Phase 6's cut list with its evidence; the machinery to retire is
  `Icons::SYMBOLS`, `use_icon`/`sprite_symbols`, `page`'s sprite emission,
  the `.icon` rules and `.item:has(> .icon)`.
  working-with-dan.md (2026-09-10) is the agents' manual for working with
  dan — candid, dated, evidence-anchored, and part of the per-round
  housekeeping (HANDOFF.md's RIF loop and reading list both name it).
  Its standing rules, on dan's word: agents' eyes only; no flattery; and an
  entry dies only when a second session agrees. It carries a banner asking
  whoever can write outside this workspace to promote it machine-wide.
  2026-09-14 — drift realigned before 0.3 drafting: next_step had lagged
  HANDOFF.md (0.2 closed 2026-09-11), and HANDOFF's quoted vitals were
  measured before Phase 6's last deletions; re-measured on the clean tree —
  659 sentences, 93 rules, 64 words all 64 used, 10 pages, 269 runs / 1473
  assertions one-process, 25 affordances — and both files now carry those
  numbers. Roadmap 0.2 is fully closed; 0.3 drafting begins.
  2026-09-14 — Roadmap 0.3 drafted (ROADMAP-0.3.md), then enriched on dan's
  word the same day: the question is "All three, in one question" broadened —
  the dashboard's md surfaces untouched (the consumer), the stranger grown
  into a garden of real apps (the evidence), the studio given its own
  scoping phase (the workbench; its in-between state is measured: the
  playground cannot serve real data, its errors are hand-built strings, the
  Stimulus burr stands), and the kernel grown only by demand (the floor,
  with the council's R3 recommendations lying there demand-gated — R3P4
  already resolved). The draft joins check_grammar's corpus and the studio's
  guides; Phase 0 is scoping the studio.
  2026-09-14 — Roadmap 0.3 challenged on dan's word, the same day. Three
  rulings recorded in the draft: the studio advances by winnable victories
  (no grand scoping gate; the iteration is the scoping); the dashboard is
  not canonized — verified, sp's entire effect on ~/dev/dashboard is two
  requires of its pure-Ruby lib plus the planned read-only markdown, and the
  boundary is scope, not sanctity; and KERNEL.md was re-measured against the
  tree (addendum added: census 42/22/64, cost now 6.38/4.73/0.22 ms, claims
  verified one by one, the word-graph tool broken — its template was never
  committed). Recommendation recorded: studio first, kernel after, demand-
  gated, budget set before the work.
  2026-09-22 — Roadmap 0.4 planning progression: Volet 1 (The Truthful Floor,
  DAYTRIP-0.4.0a.md) landed. Volet 2 (Expressive View Composition,
  DAYTRIP-0.4.0b.md) executes R3P1-3. Volet 3 (Studio & Workbench Wins,
  DAYTRIP-0.4.0c.md) lands W2 (live test suite leg on /status) and W3
  (combined Inspect surface uniting Semantic Tree AST and The Why Pane).
  Authoring pain points noted on dan's word: Pain Point 1 (5-tier vocabulary
  taxonomy) executed in Volet 4 (DAYTRIP-0.4.0d.md) as an empirical diagnostic
  instrument (surfacing missing stack/cluster, ad-hoc figcaption/summary, and
  visual idiom standard) with multi-category shelf presence; Pain Point 2
  (Studio partial minting / OOP bite-sized, locally scoped domain words to combat
  long, unDRY views) reserved for dedicated execution as Volet 4b.
  Volet 5 (Package C, DAYTRIP-0.4.0f.md, 2026-09-23) lowered the compiled Ruby
  core into elemental primitives (64 words -> 62, figcaption/summary absorbed
  into their single consumers) and landed flexible-argument disk `def` partials.
  2026-09-24 — the Visual Architecture & Spatial Manifesto compiler landed
  (docs/DESIGN_IDIOM.md, lib/slim_pickins/compiler/design_idiom.rb), then the
  Council spatial manifesto (horizon/posture/scroll/presence/focus) the same
  round. 2026-09-25 — DAYTRIP-0.4.0g.md: the council skill formalized
  (.claude/skills/council/SKILL.md) and used to resolve the four workbench
  spatial frontiers (qualitative collapse tokens, one compiled-CSS pipeline,
  real selectors replacing a defensive guess list, 100vh -> 100dvh), revised
  mid-session after dan rejected the first Frontier 3 proposal for authoring
  an already-inferable name as a DSL literal — then three real rendering
  defects dan caught by eye (a max-width leak, container queries that had
  never actually worked since the compiler's first commit, three shell
  columns at three different heights), each measured live and two of them
  correcting the session's own earlier wrong "verified" claims. Left open,
  by dan's own call, for a future token ground-truthing daytrip: the
  collapse/balance rem scale, output's independently-governed height, and
  --footer-height's corrected-but-still-guessed value.
conventions: >-
  Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 64 words, its own stylesheet,
and three example apps plus the studio that speak it. See [README.md](README.md)
— its *How roadmaps go* section governs how roadmaps work, and
[ROADMAP-0.3.md](ROADMAP-0.3.md) is the active one (the forward eye, entering
Phase 1: the garden, planted). [ROADMAP-0.2.md](ROADMAP-0.2.md) is
closed; it began with the rewrite of the Slim-Pickins Way.
