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

**Roadmap 0.1 is closed. Roadmap 0.2's backward look is done, and Phase 3 is
halfway.** The 2026-09-01 session closed Phases 0–2 (the Way rewritten in
`PRIMER.md`; the vocabulary reviewed as contracts with `check`→`checkbox`,
`select`→`choice`; the Builder un-god-objected — four gathering copies became
one stack, 867 lines/16 ivars became 298/9, byte-identical throughout) and
landed Phase 3's first half:

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

## The architecture, in one map

```text
.sp source  →  Transform (one grammar: parses, validates, compiles)
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
- `builder.rb` (298 lines, 9 ivars) — evaluation only. Its public methods are
  the surface; private are exactly `nest`, `render_partial`,
  `define_app_words`.
- `words.rb` — the fifty words, node-builders on the public surface.
- `components.rb` — `Component` + `Table`/`Chart`/`Choose`/`Choice`.
- `generator.rb` — the HTML interpreter; owns escaping, `format`, tag shape,
  and the walk's context (depth, form-ness — tree facts, not word state).
- `check_grammar.rb` / `check_shape.rb` / `check_styles.rb` — the three
  checkers that hold docs, shapes, and styles to the code.

## What is next — the payload

**A page may not render until the app has been proved able to answer it.**
The delete-the-ability-to-fail-late pass, in three steps:

1. **Report, then gate** — a validation pass over the evaluated tree before
   emission: every subject resolvable, every attribute answered, the contract
   satisfied. First as a report-only checker (`bin/verify_pages.rb`-shaped:
   evaluate every repo page and both apps against their defaults/fixtures and
   report), then as the gate (an app boots by proving its pages, loudly).
2. **The roth test** — renaming or removing an attribute makes the roth page
   fail at boot, naming the line and the attribute. The eleven-month silence
   becomes a boot error, by construction.
3. **The cost, measured** — milliseconds per render, with the answer for apps
   that cannot pay them.

**One design note the previous session left for you:** the *runtime* nodes
(`[:word, attrs, children]`) do not carry line numbers — `Transform::Node`
does, but `emit_node` drops them. For step 2 to name the line, thread the
lineno from the transform into evaluation (e.g., the Builder tracks the
current sentence's line as it evaluates). This is the first sub-task; it is
the seam between "the error speaks the language" and "the error names the
line."

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
  `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && for f in test/*_test.rb; do ruby $f; done`
  (currently 171 tests / 0 failures, 693 sentences / 0 problems, 65 rules /
  0 problems)
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
