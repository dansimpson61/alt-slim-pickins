# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs what 0.2 must be
3. `ROADMAP-0.2.md` — the active roadmap; `PROJECT.md` `next_step` points at its current phase
4. `PRIMER.md` — the Way, as it stands now (the tour replaces the old Slim-Pickins primer)
5. `DESIGN.md`, `CONTRACT.md` — the grammar and the app promise; `VOCABULARY.md`'s five checkable bullets per entry are generated (`bin/generate_vocabulary.rb`)
6. `LORE.md` — what previous sessions *learned*; the last entries are this session's
7. `working-with-dan.md` — candid notes on working with him: what his
   questions mean, what lands, what does not. It is short, it is honest, and
   **it is yours to keep true** — updating it is part of the round.

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

**Roadmap 0.1 is closed. Roadmap 0.2 is one phase from closed: Phases 0–5
are complete — the Way, the reviewable word, the un-god-objected Builder,
the payload, the exam (judged by dan), and now Eat it yourself (closed
2026-09-09).** Phase 6 — subtraction — is all that remains. The
2026-09-01 session closed Phases 0–2 (the
Way rewritten in `PRIMER.md`; the vocabulary reviewed as contracts with
`check`→`checkbox`, `select`→`choice`; the Builder un-god-objected — four
gathering copies became one stack, 867 lines/16 ivars became 298/9,
byte-identical throughout) and then landed all of Phase 3:

- **The runtime output model is semantic nodes.** A page evaluates into a
  tree of `[:word, attrs, children]`; `SlimPickins.evaluate` returns it;
  `Generator` interprets it as HTML; `SlimPickins.render(..., filter:)`
  exposes the pipeline's middle stage.
- **The vocabulary left the Builder.** `words.rb` holds the fifty-three words,
  `components.rb` the four gatherers, `generator.rb` the presentation,
  `builder.rb` the evaluation — and the vocabulary is written on the **same
  public surface an app's words get** (subject, chain, label_for, format_of,
  register!, with_gatherer, about, capture, prune, tag, element, html, token,
  arguments, children, evaluate, emit_node). `words_test.rb` forbids `send`
  and Builder ivars in the vocabulary files; `dogfood_test.rb` re-implements
  all four gatherers as app words and renders the repo's real pages
  byte-identically through them.
- **Both parked decisions are closed** (dan, 2026-09-01): `favicon` is a
  `page` modifier, landed and tested; the `when`-deferral asymmetry stays as
  documented in `dogfood_test.rb` — an app word that wants guard-before-read
  uses a bare name, which the grammar never evaluates.
- **The lineno seam is landed.** The transform wraps every compiled sentence
  in `with_line`; the Builder keeps the current sentence's line on a stack
  while it evaluates, and a runtime error is located *where it is raised* —
  path, line, and the sentence itself, in the same voice as a syntax error.
  `test/lineno_test.rb` pins it through nesting, loops, guards, choose
  branches, partials and the layout; the eleven pages stay byte-identical.
- **The report half of the payload is landed** — `bin/verify_pages.rb`
  evaluates all eleven pages (the repo's, both apps' views) against the data
  the app would serve, and reports each: OK, or BAD ANSWER with the located
  error verbatim, or RUBY ERROR. It continues past failures and exits
  non-zero on any, so it can gate a commit. The static half — the word
  contracts — remains check_grammar's; this checker owns only the evaluation
  half.
- **The gate is landed** — every page, partial and layout compiles once
  through `Compilation`: the parse, the contract walk and the emit run on
  the first render, and a violating sentence is refused before evaluation
  in the syntax error's voice (word, line, sentence), each render
  composing its own path. The gate's first catch was a contract that
  under-described the runtime — nested `choice` was tested and supported,
  but the contract said `choice` holds only `option` — so the declaration
  changed, and `bin/generate_vocabulary.rb` kept its bullet honest.
  `test/gate_test.rb` pins the holes that used to pass silently;
  `test/compilation_test.rb` pins the cache.
- **The boot moment is landed** — `SlimPickins.prove!(dir)` renders every
  top-level view against the locals the app gives it, before any request
  can: both apps prove at boot, loudly (`proved controls.sp`), and a view
  the app answers nothing for is refused too. `test/boot_test.rb` plays the
  roth test on the real page: a model minus `ss_primary_amount` fails at
  boot naming `controls.sp`, line 14, and the sentence. The eleven-month
  silence is a boot error, by construction.
- **The cost is measured, and the escape is built.** `bin/measure_cost.rb`
  is the instrument (ruby 4.0.1, specimen.sp, 200 runs): cold render
  2.75 ms, warm render 1.37 ms — what a request pays — and 0.10 ms per
  partial-in-`each` row. `Compilation` is the compile-once cache: the
  gate's verdict and the compiled Ruby, keyed by source, behind a mutex; a
  source that will not parse is never cached, so every render names its
  own path. Phase 3 is closed.

## The architecture, in one map

```text
.sp source  →  Compilation (Transform parses, validates, compiles; the
                gate's walk runs once and its verdict is cached with the
                Ruby, keyed by source; each render refuses with its own
                path)
            →  Builder (evaluates: chain, bindings, gatherer stack, capture)
            →  semantic tree [:word, attrs, children]   ← the description
            →  filter: (optional transform of the tree)
            →  Generator (interprets: escaping, formatting, tag shape)
            →  HTML
```

- `lib/slim_pickins/transform.rb` — the grammar's one home; also exposes
  `Transform.tree` for the checkers.
- `contracts.rb` — per-word declarations (name/content/modifiers/children/
  parents/subject/speech/shape) + the generated vocabulary bullets; the
  vocabulary's one list, and the gate's walk (`first_violation`).
- `compilation.rb` — the compile-once cache: the gate's verdict and the
  compiled Ruby, keyed by source; `clear!` is the instrument's reach.
- `builder.rb` (333 lines, 12 ivars) — evaluation only. Its public methods are
  the surface; private are exactly `nest`, `render_partial`,
  `define_app_words`, and the line stack (`with_line`, `eval_with`,
  `locate`).
- `words.rb` — the fifty-three words, node-builders on the public surface.
- `components.rb` — `Component` + `Table`/`Chart`/`Choose`/`Choice`.
- `generator.rb` — the HTML interpreter; owns escaping, `format`, tag shape,
  and the walk's context (depth, form-ness — tree facts, not word state).
- `check_grammar.rb` / `check_shape.rb` / `check_styles.rb` — the three
  checkers that hold docs, shapes, and styles to the code.

## What landed next — word is word is word, then the exam

**dan's directive of 2026-09-02, four items, one design — all landed:** lib/vocabulary as the
single source of what a word is; optional shape declarations a partial
carries; the dogfood *done* (gatherers as partials, thumbnails promoted);
the `when` deferral solved by declared shapes; every word first-class.

**Landed for it:** vocabulary partials carry a comment preamble (`# name:`,
`# content:`, `# modifiers:`, `# children:`, `# gathers:`, `# inside:`,
`# lazy:`, `# shape:`) and `VocabularyShapes` merges them with the Ruby
primitives into the one `CONTRACTS` list; a partial without a preamble stays
unchecked (the preamble is optional kindness). The transform's `when`
special case is dead — a word whose shape declares `lazy: content` receives
that argument unevaluated, so laziness is a declared capability any word may
claim.

**Done since:** partials receive blocks (the `children` splice word), the
`gathers:`/`inside:` shapes are honored by the runtime, and `thumbnails` +
`thumb` are the first promoted words — written entirely in the language,
their preambles their declarations, their VOCABULARY entries generated.

**Name-passing landed too:** a partial declaring `name: variant` receives
its name through the parameters (`.name`), variant-named words accept a
derived variant as data, and a name shifts the subject only when the
declaration says `subject` — preamble-less partials keep the old rule.

**Docs derived landed:** bin/generate_vocabulary.rb creates missing entries
from the contracts, and the checker holds them, demanding the example
sentence. The primitives landed too: `paragraph`, `heading`, `box`,
`span`, `figcaption` and `summary` are the atoms, classes deriving from the
words, so nothing styleable by hand returns. Root-classing landed (a
partial emits its own name as the class), the optionality spelling landed
(dan, 2026-09-02: declared slots materialise, nil when unsaid — `when
.open` is "was the modifier said"), and with them the promotion pass is
**complete**: twenty-three vocabulary partials — action, flash, search,
thumbnails, thumb, note, title, actions, footer, aside, list, item,
figure, disclosure, empty, text, money, percent, number, badge, time,
card, section. The atoms carry the box: BOX_TAGS (a promoted footer stays
a `<footer>`), BOX_DEPTH (card and section deepen), a heading inside a box
is the box's title (`#{box}-title`, which reproduces `section-title`
exactly and normalises `card--title`), and the preamble grew `parents:`,
`empty:`, `id:`, `label:`, `speech:`, `subject:`. The byte-diff over all
13 pages shows exactly three changes, each the law applying: `text`,
`time` and `disclosure` gained their class (hook-only rules). What stays
Ruby, with written verdicts in ROADMAP-0.2: metric, fact (the app
contract), icon (the sprite registry), snippet (chrome), plus the form
family, gatherers and subject-flow words. Cost re-measured: cold 6.95 ms,
warm 3.98 ms, 0.17 ms/row (up from 2.75/1.37/0.10 — the price of every
word being a composition; the cache's read path is lock-free now).

## What was Phase 4 — the exam, and how it closed

**Phase 4 is closed, judged by dan 2026-09-06 (the judgement stands in
ROADMAP-0.2.md, Round D).** dan chose `triage.slim`, the smallest of the
short-list — and the challenges showed up anyway. The port at
`examples/dashboard/` renders the real `Scan.triage_queue` through the
language: `layout.sp`, `triage.sp`, `confirm_archive.sp`, the queue,
unreviewed card and dormant action as partials, `flash`/`action`/`search`
as vocabulary partials, actions wired to the same `Workspace` calls the
original makes, boot-proven, held by `test/dashboard_test.rb` and
`bin/dashboard_parity.rb` — 25 affordances, 0 missing against the live
dashboard. The exam's harvest is the gap ledger G1–G13 in
`examples/dashboard/INVENTORY.md`, all disposed: G1–G10 resolved by the
negotiated primitives (`hidden`, `input`, `textarea`, `form` widened,
`card` titles, `link active:`, `button size:`) and the partials; G3 and G7
dissolved with the re-frame (the port wears our look); G11 disposed as
documented-and-pinned (a test holds the hatch's emit-vs-value contract —
`tag` emits, `element` returns, the nav renders once); G12 resolved by the
optionality spelling; G13 (first recorded as G14 — the original numbering
skipped 13) resolved by the word-free-locals rule. The promotion decision:
`flash`/`action`/`search` stay partials — promotion is for words that have
proven themselves across pages, and all three are used by exactly one app.
`~/dev/dashboard` stayed untouched and working throughout.

## What was Phase 5 — eat it yourself, and how it closed

**Phase 5 is closed (2026-09-09); the round record stands in ROADMAP-0.2.md.**
Three rounds, each committed, each green on both harnesses — the project
gate *and* the dashboard's single-process runner (which caught a real defect
the gate cannot: see round 1).

1. **The dashboard's health flag caught a lie.** Its runner loads every test
   file in one process, so every app's words share one registry — and
   `StudioDocs.implementation_of` assumed every partial is builtin, so the
   portfolio's `account_card` named `lib/vocabulary/account_card.sp`, which
   is not its home. A partial now carries its `source_path` from the Library
   (one glob reads source and path together), the docs payload names the
   true home, and a partial declared inline says so ("nowhere on disk") —
   a named state, not a KeyError. The dashboard's flag was right.
2. **`prose` grew fences, tables and ordered lists** — measured before
   built: 344 fence lines, 35 pipe tables (0 alignment colons, pipes inside
   code spans), 61 ordered-list lines, and — what the roadmap's opening
   measurement missed — 271 indented continuations under bullets, 40 under
   ordered items, one nested list. `Markdown` now scans lines: fences are
   extracted first (they win over tables and lists), cells split on pipes
   outside backticks, lists fold continuations and one level of nesting.
   Still safe by construction: everything is escaped before any pattern
   becomes a tag; nothing is ever dropped; no general markdown engine. The
   styles share one home each (`.prose pre` with `.snippet`, `.prose table`
   with `.table`); the guide/docs warning notes are gone.
3. **The status page.** `studio/status.rb` runs the four gate legs live as
   subprocesses; `/status` serves each leg's output through a prose fence,
   re-run every visit (~0.9 s) — a status page that remembered its verdict
   could claim green while red. The studio's pages joined the gate in the
   same round: `check_grammar`/`check_shape` learn `studio/views` as an app
   via `Library.from` (the whole of the work the lore had measured). The
   gate's first catch of the phase was the page built to display it —
   `each .results` refused (each takes a name, never data) — and the runtime
   taught the idiom's other half: `each result` reads `results`.
   **dan's answer, verbatim: "Both the dashboard's md docs and the studio's
   md docs."** — the dashboard's markdown surfaces are the next dogfood
   target (read-only, must keep working, untouched), and the studio's
   curated guides grew README, ROADMAP-0.2, HANDOFF and DAYTRIP.

Named limits, left for a future prose round or Phase 6: headings swallow
body lines when the author left no blank line (6 places); `---` renders as
a paragraph; nesting stops at one level; alignment colons render unaligned.

## What is next — Phase 6, subtraction

**Phase 6 is the last phase of roadmap 0.2** — the backward eye's final
discipline: everything must have a consumer or go. The cut list is already
drafted in ROADMAP-0.2.md: the three paper pages (half-retired to
`history/`; their fate is dan's reversible half), any style rule the checker
orphans, any document that duplicates another. The measure: usage counted
before and after, cut and kept listed with reasons, everything still green.
Phase 4 parked two vitals rows here — `action` at five arguments, and
vocabulary coverage (54 of 69 on the table's corpus; the checker's wider
corpus prints 66 of 69 since the studio joined). The prose named-limits
above are candidates for the same conversation.

**Two names were audited before the knife, and their evidence is in the
Phase 6 record (2026-09-10).** `meta` has no consumer in any of the six
surfaces — `page` already infers the only two metas any real page declares
(the dashboard's own head is exactly doctype, title, charset, viewport,
stylesheet). `icon` is **superseded, not merely unused**: every state it
marked is a class the markup already declares, so the stylesheet draws the
marks now (`.note--warning`, `.badge--ok`, `.badge--error` — the studio's
status page authors no glyph and ships no sprite), and with it go
`Icons::SYMBOLS`, `use_icon`/`sprite_symbols`, `page`'s sprite emission, the
`.icon` rules and `.item:has(> .icon)`. Two rotten claims retire with it: an
unshipped symbol renders a silent empty box, and VOCABULARY promises apps may
add symbols while `Icons::SYMBOLS` is frozen. If the paper pages survive,
re-author them on the CSS marks.

**The lesson worth carrying into Phase 6:** when a state is already a class
in the markup, its presentation is CSS's job — reaching for a language
mechanism there would have been the wrong layer, and the house's own
precedence (Ruby > CSS > Stimulus > JS) already said so.

**The studio (`studio/`, port 4580, `STUDIO_PORT` to override) is dan's own
process — it serves whatever code it booted with, so restart it after pulling
new work.** The checkers' status page at `/status` re-runs the gate live on
every visit. A session that needs to look at the studio without touching
dan's process can boot one on another port: `STUDIO_PORT=4581 ruby
studio/app.rb`.

## How this project works

- **Verify before asserting.** Never state a count without measuring it and
  saying what it covered.
- **Checkers are not enough — look.** Eleven 0.1 defects passed every checker.
  `ruby bin/demo.rb specimen` builds a standalone page; `ruby examples/roth/app.rb`
  serves the port on 4577.
- **Nor are happy-path tests.** `test/combination_test.rb` crosses words that
  hold state; extend it for anything that gathers, binds, or shifts.
- **The byte-diff harness is the acceptance test for refactors.** Snapshot all
  eleven pages (repo pages + both apps' views), `git stash` the refactor,
  render before and after, `diff -r` — byte-identical is the whole argument.
  The snapshot script's shape is recreated per session; the pages are
  `pages/*.sp` (via `Fixtures.for`), `examples/portfolio/views/*` (with the
  `video` AppWord), `examples/roth/views/*` (via `Scenario.defaults` +
  `Projection.of`).
- **Everything green before committing:**
  `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done`
  (re-measured 2026-09-10: 261 tests / 1506 assertions / 0 failures in one
  process — the dashboard's harness, which is the stronger one and worth
  running too: `ruby -Ilib:test -e 'Dir["test/**/*_test.rb"].each { |f|
  require "./#{f}" }'` — plus 887 sentences / 0 problems, 103 rules / 0
  problems, 69 words / 0 problems, 13 pages verified, 25 affordances /
  0 missing)
  **Set no environment variable to make this pass.** It used to need
  `RACK_ENV=test`, which switched the prettifier off and made every rendering
  test assert HTML production never emitted. If the suite only passes with
  something exported, that is the bug, not the workaround.
- **The cost, re-measured**: `ruby bin/measure_cost.rb` — the instrument;
  the numbers live in ROADMAP-0.2.md Phase 3's record.
- **RIF loop per round**: implement → verify → commit with an intention-revealing
  message → update `PROJECT.md` `next_step` → post lore
  (`POST /api/lore/alt-slim-pickins`; lore entries max 2000 chars) → update
  `working-with-dan.md` if the round taught you something about working with
  him.
  **Do this per round, not at the end of the session** — dan restated it
  2026-09-06: *"I don't have another way to know what should be done with
  git."* He is not reading `git status`, so unnamed git state is invisible
  state. **Commit per round; push only when dan says so** — the push is his,
  and it is the one part of the loop that is not the agent's to take.
- **`PROJECT.md` frontmatter is real YAML, and the dashboard fails silently on
  it.** If it does not parse, `/brief` returns `Status: unknown` with every
  field `-`, while health, anatomy, lore and the DIRTY flag keep rendering — so
  a broken card is indistinguishable from an empty one. This project sat that
  way for weeks: `notes:` was an unquoted multi-line scalar containing
  colon-space ("the filter: seam in render"), which Psych refuses. Prose fields
  are folded block scalars (`>-`) now. After editing the card, check it:
  `ruby -ryaml -e 'YAML.safe_load(File.read("PROJECT.md")[/\A---\n(.*?)\n---/m, 1], permitted_classes: [Date])'`
- Report honestly: failures verbatim, limits named, no claim of green that isn't.

## Standing principles — do not break without saying so

- One sentence: `word arguments`, indentation nests it. Extending the language
  adds vocabulary, never syntax. A dot means data; a bare word is language.
  There is no numeric literal. A name is a subject and must exist. Mechanical
  facts are free; judgements belong to the app. A line that states the
  inferable should not exist. This is a noun language — 45 of 50.
- **Every truth has one home** (the grammar in Transform, the vocabulary in
  contracts, the checkers consuming, never mirroring).
- **A rule must outlive its reason** — when a proscription blocks empowerment
  *and* better code, examine its foundation; it survives only if the
  foundation is worth more than what it blocks.
- **Word, or power?** — for every candidate surface, the language grows by
  words; the surface grows only when the answer is honestly "power."
- **The dogfood is enforced**: built-ins and app words eat the same food, by
  test, and the gatherers are re-provable as app words, byte for byte.

## Three caveats to carry

**The escape-hatch number is retired.** It measured where rendering happened,
never the vocabulary's coverage. Stop quoting it.

**`~/dev/dashboard` must keep working, untouched.** It is the tool that runs
everything else in `~/dev`, and nothing this project does is worth breaking it.

**`~/dev/roth` is a separate, dormant project and has not been touched.** Its
working tree has been mid-rename since 2025-09-11; `examples/roth` pins the
new spelling and raises if it is reverted. roth's defects are catalogued in
`ROTH_STUDY.md` and `ROTH_DOMAIN_BACKLOG.md` — deliberately not this project's
work.
