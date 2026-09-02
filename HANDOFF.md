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

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

**Roadmap 0.1 is closed. Roadmap 0.2's backward look is done, and Phase 3 —
the payload — is complete.** The 2026-09-01 session closed Phases 0–2 (the
Way rewritten in `PRIMER.md`; the vocabulary reviewed as contracts with
`check`→`checkbox`, `select`→`choice`; the Builder un-god-objected — four
gathering copies became one stack, 867 lines/16 ivars became 298/9,
byte-identical throughout) and then landed all of Phase 3:

- **The runtime output model is semantic nodes.** A page evaluates into a
  tree of `[:word, attrs, children]`; `SlimPickins.evaluate` returns it;
  `Generator` interprets it as HTML; `SlimPickins.render(..., filter:)`
  exposes the pipeline's middle stage.
- **The vocabulary left the Builder.** `words.rb` holds the fifty words,
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
- **The gate is landed** — `Contracts.enforce!` refuses a page, partial or
  layout whose sentence violates its word's contract, before evaluation, in
  the syntax error's voice (word, line, sentence). The gate's first catch was
  a contract that under-described the runtime — nested `choice` was tested
  and supported, but the contract said `choice` holds only `option` — so the
  declaration changed, and `bin/generate_vocabulary.rb` kept its bullet
  honest. `test/gate_test.rb` pins the holes that used to pass silently.
- **The boot moment is landed** — `SlimPickins.prove!(dir)` renders every
  top-level view against the locals the app gives it, before any request
  can: both apps prove at boot, loudly (`proved controls.sp`), and a view
  the app answers nothing for is refused too. `test/boot_test.rb` plays the
  roth test on the real page: a model minus `ss_primary_amount` fails at
  boot naming `controls.sp`, line 14, and the sentence. The eleven-month
  silence is a boot error, by construction.
- **The cost is measured, and Phase 3 is closed.** `bin/measure_cost.rb` is
  the instrument: full render 3.59 ms, without the gate 2.50 ms, the gate
  itself 1.09 ms, a partial inside a 50-row `each` 0.29 ms per row (ruby
  4.0.1, specimen.sp, 200 runs). The gate once parsed each source twice;
  `Contracts.enforce!` now takes the tree, so one `Transform` serves the
  gate and the compile. No app here cannot pay; the escape, should one
  appear, is a compile-once cache keyed by source.

## The architecture, in one map

```text
.sp source  →  Transform (one grammar: parses, validates, compiles)
            →  the gate (Contracts.enforce!: each sentence against its
               word's contract, refused before evaluation)
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
  vocabulary's one list.
- `builder.rb` (333 lines, 12 ivars) — evaluation only. Its public methods are
  the surface; private are exactly `nest`, `render_partial`,
  `define_app_words`, and the line stack (`with_line`, `eval_with`,
  `locate`).
- `words.rb` — the fifty words, node-builders on the public surface.
- `components.rb` — `Component` + `Table`/`Chart`/`Choose`/`Choice`.
- `generator.rb` — the HTML interpreter; owns escaping, `format`, tag shape,
  and the walk's context (depth, form-ness — tree facts, not word state).
- `check_grammar.rb` / `check_shape.rb` / `check_styles.rb` — the three
  checkers that hold docs, shapes, and styles to the code.

## What is next — Phase 4, the exam

**Phase 3 is closed: a page may not render until the app has been proved
able to answer it, at report, at gate, at boot, and the proof costs 1.09 ms
measured.** Roadmap 0.2's next phase is the exam — the second port, aimed
at exactly what 0.1 never exercised. The candidate short-list is in front
of dan (scored in this session): `index.slim`/Studio 81, `project.slim` 73,
`dispatch.slim` 73, `compare.slim` 61, `triage.slim` 50. Key recon fact:
the dashboard speaks the **original** slim-pickins gem — `ui_button`,
`ui_badge`, `ui_flash`, `ui_table` built-ins and `Tabular`/`Word` component
classes — so the port re-expresses old-language views in the current
language, against the dashboard's pure-Ruby `lib/` modules, with partials
where the original used app words.

- **Choose the view** `dan` — the short-list above is the material; the
  pick is his.
- **Inventory first** `agent` — what the original could *do*, not what it
  said: the parity-plus lesson from the Phase 7 review, which caught the
  checkbox that vanished unlogged.
- **Settle routing** `agent` — `link` finally meets a real page that asks
  for more than `/name`, and the answer is recorded in the vocabulary.

See `ROADMAP-0.2.md` Phase 4 for the rest of the phase. **`~/dev/dashboard`
stays untouched and working throughout.**

**The design note the previous session left is now closed.** The runtime
nodes (`[:word, attrs, children]`) still do not carry line numbers — that
decision stands: the line is *provenance, not meaning*, and the semantic
tree stays a description. The seam landed differently, and better: the line
is threaded from the transform into *evaluation* (`with_line` around every
compiled sentence, a stack in the Builder), and errors are located at raise
time, before the stack unwinds. A later validator that must name lines on
tree nodes will need to say so — but the roth test no longer does.

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
  (currently 187 tests / 0 failures, 693 sentences / 0 problems, 65 rules /
  0 problems, 11 pages verified)
- **The cost, re-measured**: `ruby bin/measure_cost.rb` — the instrument;
  the numbers live in ROADMAP-0.2.md Phase 3's record.
- **RIF loop per round**: implement → verify → commit with an intention-revealing
  message → update `PROJECT.md` `next_step` → post lore
  (`POST /api/lore/alt-slim-pickins`; lore entries max 2000 chars). dan has
  wanted a commit and push per round this session; check that still holds.
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
