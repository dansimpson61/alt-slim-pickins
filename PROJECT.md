---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  PHASE 0 — the studio, won iteratively. **Win 11 landed 2026-09-17: the studio
  holds multiple UIs, and the workbench is the first new one.** dan's ruling —
  the studio is one workbench and the library a movable shelf — was rewritten by
  his next instruction into "manage multiple UIs from which we can pick", an
  exploration before guides are updated and agents are turned loose on garden
  apps. A UI is now a directory: `layout.sp` (the frame the `page` word infers),
  `views/`, `words.rb` (a module `include`-ing the shared interface kata
  `StudioUI`), and `about.rb` (its title, its design, and its route templates).
  `studio/uis.rb` is the registry; `?ui=` selects, a cookie remembers, `/ui/:name`
  switches, and the picker is a partial each UI draws. The seam that makes
  several UIs possible is `paths`: every link is minted by the UI that is
  speaking, via `link_to`, so no view holds a route and one UI cannot link into
  another. The classic UI is kept whole as the control; the workbench is
  `main_menu` / `library` / `panes` / `footer`, its shelf holding the words, the
  repo's pages with their census, and the guides, and `/docs/:word` is a state of
  the shelf rather than a page — so there is one editor and `try_it.sp` is gone.
  Both UIs read **18 of 18 `ok`** in their own shelves, verified by looking in
  Chromium as well as by the gate. The round also fixed eight defects that had
  been invisible, including `page` reading its head before the layout ran (so a
  layout's assets never reached `<head>`), `Library` harvesting inherited
  methods and so refusing the language's own `format`, and `plainify` laundering
  unnameable values into nil and destroying whole payloads. Landed earlier:
  DAYTRIP-0.3.0b (The Accent) closed the same day, ten studio wins before it, the
  three instruments, the register's reference shape. The gate is 96 rules, 339
  runs and seven legs, all exit 0.
kind: project
last_touched: 2026-09-17
next_step: >-
  The multi-UI trunk is landed and green; **the pick after it is dan's**. The
  live candidates, each with its consumer: **more UIs** — dan's own words were
  "we may try generating a few different UIs just for the sake of exercising
  ourselves and the language", and the vocabulary question is the point (a word
  one UI needs is that UI's business; a word two UIs need is evidence for the
  language; a word neither needs is evidence for the vocabulary — neither UI has
  asked for anything yet); **the gutter** — errors belong on the line the
  language already carries `path`/`lineno` for, and under the one-workbench
  shape that lands in one file instead of two; **the inference/ownership pane**
  (ROADMAP-0.3's parked W3, and BLUESKY Part 4's deepest job) — the studio
  showing *who decided* each value, which the conventions register half-built
  already; and **the shelf's search**, a real `search` word with no behaviour
  wired. Held for the end-of-phase mopping up, on dan's instruction, unless one
  bites: F8 (five claims no code kept, ruled *record it, build nothing*), F9 (the
  `table_header`/`label` rename), `bin/word_graph.rb`'s broken template, the
  `puts` probe in `builder.rb:62-65`, `words.rb`'s three `___dummy` stubs, the
  vetoed `.agents/worker_1/report.md`, `studio/app.rb`'s consumer-less
  `/render_html` route, and the stale word counts in prose (`README.md:138`,
  `PRIMER.md:366`). `DAYTRIP-0.3.0a` is held and due a re-reading; causes B's
  repairs wait in Phase 3; E4/E6/E7/E8 stay dan's. Left as recorded divergences:
  the 42 Ruby `contract` calls keep `content: true`, and HANDOFF and README each
  carry a current copy of the gate command.
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
conventions: >-
  Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 64 words, its own stylesheet,
and three example apps plus the studio that speak it. See [README.md](README.md)
— its *How roadmaps go* section governs how roadmaps work, and
[ROADMAP-0.3.md](ROADMAP-0.3.md) is the active one (the forward eye, in
Phase 0: the studio, won iteratively). [ROADMAP-0.2.md](ROADMAP-0.2.md) is
closed; it began with the rewrite of the Slim-Pickins Way.
