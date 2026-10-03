---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  Truth round closed 2026-09-26 (dan's call, after asking whether the BLUESKY
  exercise had been useful — it had, as fertilizer for a later design). Four
  living documents and the design-idiom lexicon were realigned with measurements
  taken this session: the canonical vocabulary is 62 (39 Ruby + 23 .sp), not the
  64 that Package C absorbed away; PRIMER's register count was 59 nouns and is
  57 (bin/word_arguments.rb), because both absorbed words were nouns;
  docs/DESIGN_IDIOM.md's four compiled-CSS examples were re-compiled and
  corrected (container-type on html, align-items: stretch, box-sizing, and an
  emitted-but-undocumented h1 rule); and the theme is 61 roles in one :root, not
  the 53 that BLUESKY wrote on 2026-09-16 against a stylesheet already holding 65
  — that stale number had propagated into ROADMAP-0.3, two daytrips, and twice
  into the :axiomatic entry of lib/slim_pickins/conventions.rb, where
  check_conventions.rb reads it every run and has no opinion about it. All eight
  gates and 445 tests green; two commits, each independently green. The lesson
  recorded in LORE.md: a checker holds the shape of a claim, never its
  arithmetic. No behavior changed. Then, on dan's steer to check
  design_idiom_discussion.md, COMMUNITY_BULLETIN_BOARD.md and LORE.md for the
  missing material: those sources supplied the origin (the discussion's Part II
  lexicon is where the eight documented words came from) and the Council
  spatial manifesto's one-line summary in LORE.md, which named
  horizon/posture/scroll/presence/focus and their four motions. The five
  missing lexicon entries were written from the compiler's real output, and
  docs/DESIGN_IDIOM.md is now served as a guide — which needed the guide route
  itself changed, since it resolved every name to <root>/<name>.md and a
  document in docs/ was unreachable. Then the
  round's last two pieces, both dan's calls: check_design_docs.rb — the ninth
  gate leg, now `check_spiff.rb`, which holds the lexicon to the compiler in
  both directions and found `collapse` undocumented on its first honest run — and
  design_idiom_discussion.md, now `spiff_discussion.md`, served as a guide beside
  the lexicon it explains.
  The checker's own logic is pinned by test/check_spiff_test.rb, and its
  value was proven by mutation (the align-items defect, an invented property,
  and a wrong grid-column value each fail it with exit 1). All nine gates
  green; 451 tests. Dan then had the two guides' rendering fixed — the
  artifact being that both documents were accurate and unreadable:
  DESIGN_IDIOM.md's fifteen <details> wrappers rendered as literal text
  (the markdown engine escapes HTML by contract, and prose has no
  raw-HTML spelling), so they are now markdown headings; and
  design_idiom_discussion.md's twenty backslash escapes rendered their
  backslashes (the engine has no escape either), so they are stripped.
  Verified by fetching both rendered pages, not by reading the source. Then the
  remaining guides, and this is where the round's own claim had to be corrected:
  the earlier count of "raw HTML" in five other guides was wrong — it counted
  inline code spans that quote HTML on purpose (`renders — a <ul>`), which are
  correct and stay. Reading the *rendered* output instead of grepping the source
  found the real defect, and it was in the engine: the list-item renderer called
  `spans` twice, once for the marker line and once for its continuations, so a
  code span that wrapped a line never closed and the reader got literal
  backticks with a stray `<code>` between them. A paragraph with the same text
  rendered correctly, which is why it survived. Six passages were broken that
  way; four more in LORE.md had malformed delimiters (a four-backtick span, and
  spans whose content held three backticks). Fixed at the root, plus the source
  spans; stray backticks across all fourteen served documents: 20 -> 0, with a
  new invariant test over every served document. All nine gates green, 455 tests.
  Then dan had the engine limit itself fixed — a code span could contain no
  backticks, so the fence pattern could not be quoted — and the first attempt
  was reverted for making things worse. The second was built by diffing the
  rendered output of all 29 documents against the old renderer at every step,
  which is how the fix itself was found to be carrying two more defects the old
  pattern had been hiding: spans welded first-backtick-to-last, and emphasis
  applied inside code spans. Code is now masked out before links and emphasis
  are read. Four spans in DEMAND and DAYTRIP-0.4.0f had delimiters their content
  could not pair with and were given ones it can. 462 tests. The invariant that
  would have caught all of it — no backtick in the prose around a code element —
  now measures exactly that, having first been written too crudely to tell
  content from a leak. Then dan pointed at the last survivor of the design
  idiom's founding complaint: the substance words were renamed (`sidebar` →
  `catalog`) when the discussion was held, but the wrapper they were drawn
  inside kept the spatial name, and `sidebar_layout` was still authored in six
  .sp files. It is now `shell` — the word the compiler already used for it
  (`kind: shell`) — with `--shelf-width` for the role that named a screen
  position. The studio chrome's own navigation and taxonomy's `:sidebar`
  structural primitive are different things wearing a similar word and were
  left alone. All nine gates green, 462 tests, every page verified to render
  `class="box shell"` and none to emit the old name. Then an audit for the same
  disease — presentation vocabulary in `.sp`, which the design idiom exists to
  prevent — found the pattern rather than a single artifact: a partial whose
  whole body is `box` + `children` exists only to hand a stylesheet a class,
  which is a presentation decision wearing a substance name. Four qualify
  (`shell`, `split_pane`, `panes`, `word_docs`); `shell`, `panes` and
  `word_docs` are purpose-named and fine, and `split_pane` is the technique
  name left standing. The root cause is that the classic UI has no `.design`
  file, so its presentation pooled in two wrapper partials, in
  `slim-pickins.css` (which every UI loads), and in a root role. That duplicate
  is now gone: `split_pane` became `panes`, one word for one concept, kept
  because the compiler already dissolves a `panes` wrapper inside a `horizon`.
  Its two layout rules were deliberately not merged — they are per-UI
  presentation and genuinely differ — and both UIs were measured in a live
  browser to confirm the layout is unchanged. Census 104 rules, one fewer
  because a class name really went away. Dan's call was
  the smallest item: the workbench's `foot` partial is gone and the layout says
  the canonical `footer` — which was also a live defect, since a
  workbench-specific `.footer` rule had been styling nothing because the
  element was a `.foot`. Recorded and deliberately not done, awaiting dan's
  word instead: the duplicate pane names are unified — the classic UI's
  `split_pane` and the workbench's `panes` were the same region under two names,
  and `panes` is the survivor because the compiler already dissolves a `panes`
  wrapper inside a `horizon`, so the name was load-bearing. The partial moved to
  `studio/shared/partials` (both UIs say it) and the classic grid rule followed
  the name; the two per-UI layout rules stay separate because they genuinely
  differ (classic is a real grid, the workbench dissolves the wrapper so the
  shell places the zones). Verified in a live browser on both UIs. Census
  105 -> 104 rules; README and HANDOFF updated. Then the third: the term
  "layout" is retired from the language. It had named two things — the visual
  arrangement, which the design idiom already took over with
  `surface`/`stage`/`flank`/`zone`/`air`, and the chrome-with-a-hole that
  `page` infers — and dan named the second `tin`, pairing with `.design` the
  way the files pair on disk: `[app].tin` is the metal over the building,
  `[app].design` is how it looks, `[view].sp` is what is inside. Nine files
  became `[app].tin`; `Library#layout` → `#tin`; the `:layout` convention →
  `:tin`; `wrapped_in_layout` → `wrapped_in_tin`; the checkers, boot and docs
  corpora learned `.tin` (they globbed `.sp` and would otherwise have silently
  stopped reading the frames); and "layout" survives only where it is accurate
  — the visual or structural sense, which is the design idiom's. Roth's views
  have no tin, which is a real answer: that page carries its own chrome, and
  `Library.tin_path` returning nil records it. All nine gates green, 462
  tests, every tin resolving, both UIs rendering live. Then the design idiom
  got its name: **Spiff**. "Design Idiom" had been a description doing a
  name's job, which is why the three things it named never agreed — a
  `.design` extension, a `DESIGN_IDIOM.md` lexicon, a `DesignIdiom` class. The
  module is now `SlimPickins::Spiff` (`lib/slim_pickins/compiler/spiff.rb`,
  entrypoints `.compile` and `.compiled_stylesheet`), the lexicon is
  `docs/SPIFF.md`, the discussion `spiff_discussion.md`, the gate
  `check_spiff.rb`, the status leg `Spiff`, the studio guide `SPIFF`, and the
  editor's label "Spiff (.spiff)". The extension followed the name the same
  day: `[app].spiff` now sits beside `[app].tin` and the app's `[view].sp`
  files, so the module, lexicon, gate and suffix all say Spiff and the last
  three-name disagreement is gone. `.sp` is untouched — the compiler never saw
  a filename anyway, since `Spiff.compile` takes source. One latent bug fell
  out of the sweep: `check_spiff.rb` had carried two copies of its own module
  comment since the truth round rewrote it in place.

  2026-09-29 — the workbench's word page renders again, and the defect it was
  wearing spans three layers, which is why it read as "we broke something in
  the view". The compiler dissolved any descendant `.panes`, not the shell's
  own, so `docs.sp`'s nested panes were handed to the page's grid and the
  editor and output were sized by their min-content. The stylesheet's
  `.word_docs` grid declared `1fr 1fr` and placed `.editor`/`.output` in
  column 2, but `display: contents` on `.panes` meant those placement rules
  matched nothing — the real grid items were placed by the compiled zone
  rules. And those rules reach past the shell: `.shell .editor` and
  `.shell .output` are descendant selectors, so inside any nested grid they
  name the shell's columns and, in a two-track grid, an implicit third. Fixed
  at each layer: the dissolution is a child combinator, `.word_docs` is a real
  grid spanning the work area with tracks of its own, and the page says which
  track its own zones take. The page's grid also needed the shell's collapse,
  or `grid-column: 2 / -1` in a one-column grid names a line that is not there
  and puts the work outside it. One thing was not a view defect and was fixed
  beside it: the footer's counts were hand-kept copies of a live number, and
  `studio/vitals.rb` now reads `Census` — Words 62 / Conventions 38 /
  Promises 35. All 10 legs green; 485 runs, 5,731 assertions, 0 failures.
  `assets/workbench.css` is not served at all (the studio compiles that
  stylesheet from `workbench.spiff` per request) and now sits in the tree as a
  stale artifact awaiting dan's call to delete it.

  2026-10-02 — the audit round, recorded in DAYTRIP-0.4.0h.md rather than
  retold here, which is itself one of its findings — this `status` is 11,145
  characters and `bin/check_card.rb` prints that number every green run
  without having an opinion about it. Tier 1 landed. `check_spiff_scope.rb`'s
  `app_root` is bounded (a required `within:`, and `nil` rather than a
  directory, so a Spiff belonging to no app is refused instead of globbing the
  filesystem) — its first version was reverted mid-fix when mutation showed
  the old guard was unreachable and therefore dead. And the vocabulary count
  is now measured where it is graded, `way_exam` q5 and `word_graph`'s two red
  tests both reading `Census`. The round's own discovery, which the audit had
  missed — no gate runs the five example apps' suites, and `word_graph` had
  been red on `64` words and `59` nouns since the vocabulary came down to 62. All
  ten gates green; main suite 488 runs, 5,737 assertions, 0 failures, 0
  errors; all five example suites green.

  Then, on dan's reorder, Tier 4 — recorded in the daytrip, not retold here. The
  shape of the Ruby, and the better instrument found halfway through it: a grep
  for dedented `def` lines sees only signatures, while `ruby -w -c` reports
  mismatches inside method bodies and dead locals, in the interpreter the project
  already runs, with no gem. Seven more mismatches and three dead assignments
  gone; `ruby -w -c` clean repo-wide. `bin/byte_diff.rb` now keeps the byte-diff
  harness instead of each session rebuilding it. Tier 6 was sized and declined,
  which is the honest outcome — the argument the daytrip made for the node
  refactor was wrong and is corrected in place.
  Daytrip 0.4.0i (2026-10-03) built the two legs the audit's own Part 4 said
  were missing, on dan's instruction to settle three open design decisions on the
  merits and proceed. `check_vitals.rb` (eleventh leg) holds every number the
  living prose and the `.rb` comments state about this project to
  `Census.snapshot`, with the dated record exempt and a written reason per entry;
  `check_ruby.rb` (twelfth leg) runs `ruby -w -c` over all 124 Ruby files and
  treats a warning as a failure. The vitals gate's first honest run reported 74
  problems; four nameable classes of text that holds a number without stating one
  (a quoted span, a date, a list marker, a number too far from its noun) became
  four masking rules, each with its reason in the source, leaving 32 real
  findings — all fixed. It caught five of the six instances the audit recorded,
  plus four it had missed: a fourth copy of the stale literals in
  studio_pages_test.rb, promises.rb claiming `22` vocabulary partials when there
  are 23, a comment in word_graph's test, and check_shape printing a different
  quantity under the census's name. The sharpest finding was about a gate:
  `bin/verify_pages.rb` had been proving the studio's pages against locals the
  studio stopped using in September, so the footer it verified said `64` words
  and `32` promises while the footer the app serves said 62 and 35 — three homes for
  that payload are now one, `StudioVitals.locals`. No whitelist was added, and
  the reason is written down: every surviving historical passage read better after
  the fix than it would have behind an exception. The Suite leg stopped keeping
  its own glob and asks `Census.test_files`, which closes the example-suite gap by
  subtraction: 488 runs became 568, one process, 0 failures. Twelve legs green;
  both new legs mutation-tested; the byte-diff digest moved on purpose to
  2172d2bd6c0254a8c611d59a and the move was explained by reading the rendered
  footer rather than trusting the number.
last_touched: 2026-10-03
next_step: >-
  Tiers 1, 2, 3 and 4 of DAYTRIP-0.4.0h.md are landed and green; the round is
  recorded in DAYTRIP-0.4.0i.md. The gate is twelve legs and the suite now runs
  every test file the census can find (568 runs). Three things dan may want to
  confirm rather than discover: KERNEL.md was moved to the vitals gate's exempt
  set against the written scope decision, because its own first paragraph pins
  its measurements to tree 5d43fe9 — the argument is in DAYTRIP-0.4.0i.md Part 1
  and aligning the written scope is his call; README's "Everything green" was
  replaced with a sentence that says what green does and does not cover,
  including that no leg renders to a browser; and `word_count`/`words_count`
  remain two names for one number, named in StudioVitals rather than reconciled,
  because renaming a local changes every page that says it. Next on the list is
  Tier 5 (stop committing a generated VOCABULARY.md; delete or retarget
  check_spiff_scope.rb — both subtract), then Tier 6 resequenced so the Inspect
  surface is rewritten in the language before the semantic node is named, which
  also unblocks pointing check_styles at studio/. Tier 7 is the card surgery, and
  the clearest instance of it is now measured: HANDOFF.md restates the contents
  of nine DAYTRIP files and is the second most-churned file in the repository's
  history. Older calls still open — the workbench word page's proportions, the
  unserved `assets/workbench.css`, and the two byte-identical `.tin` files.
kind: project
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
  arguments and vocabulary coverage at `54 of 69`. "Tight Coupling in Ruby DSLs.md" (Gemini's critique of the
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
  `659 sentences, 93 rules, 64 words all 64 used, 10 pages, 269 runs / 1473
  assertions one-process, 25 affordances` — and both files now carry those
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
  core into elemental primitives (`64` words -> `62`, figcaption/summary absorbed
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
  2026-09-26 — the truth round, opened by dan's question about whether the
  BLUESKY exercise had been useful. It had: a decision instrument at a scoping
  boundary, whose structure reached the code (the Inspect surface's
  page/app/language/theme provenance tiers are BLUESKY's Part 4 annotation, and
  the four inference grades became the convention register's own grades) while
  some of its numbers did not survive. The round fixed the numbers it left
  behind plus four siblings of the same kind, none of which any checker could
  see. Full lesson in LORE.md, 2026-09-26.
conventions: >-
  Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 62 words, its own stylesheet,
and seven example apps plus the studio that speak it. See [README.md](README.md)
— its *How roadmaps go* section governs how roadmaps work. [ROADMAP-0.3.md](ROADMAP-0.3.md)
is the last phase plan (closed 2026-09-21); roadmap 0.4 runs as a sequence of
daytrip victories instead, and `next_step` above is the live resume point.
[ROADMAP-0.2.md](ROADMAP-0.2.md) is
closed; it began with the rewrite of the Slim-Pickins Way.
