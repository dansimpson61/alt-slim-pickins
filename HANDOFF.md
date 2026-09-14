# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
3. `ROADMAP-*.md` — the active roadmap: 0.2 is closed, 0.3 is drafted
   (the forward eye, three legs in one question); `PROJECT.md` `next_step`
   points at its current phase
4. `PRIMER.md` — the Way, as it stands now (the tour replaces the old Slim-Pickins primer)
5. `DESIGN.md`, `CONTRACT.md` — the grammar and the app promise; `VOCABULARY.md`'s five checkable bullets per entry are generated (`bin/generate_vocabulary.rb`)
6. `LORE.md` — what previous sessions *learned*; the last entries are this session's
7. `working-with-dan.md` — candid notes on working with him: what his
   questions mean, what lands, what does not. It is short, it is honest, and
   **it is yours to keep true** — updating it is part of the round. Its top
   note says dan asked for it to be promoted machine-wide; whoever can write
   outside this workspace carries it there.

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

**Roadmap 0.2 is fully closed.** The backward eye's discipline (ataovy dian-tana) has run its course through all six phases:
- The Way was rewritten (`PRIMER.md`).
- The Builder was un-god-objected into semantic nodes.
- The exam was passed (the vocabulary successfully ported `roth` with 0 missing affordances).
- The ecosystem now eats its own dogfood (the dashboard and studio docs are served by `prose`, `link`, and the gate).
- Subtraction is complete (`meta`, `icon`, `thumb` are gone, and `action` is refactored).

The detailed phase-by-phase record of Roadmap 0.2 remains in `ROADMAP-0.2.md`.

## What is next — Roadmap 0.3

**Phase 6 (Subtraction) is complete, officially closing Roadmap 0.2.**
The vocabulary is clean (`meta`, `icon`, `thumb`, `thumbnails` removed), the `action` primitive is refactored, and Phase 5's prose named-limits (`---`, heading boundaries, table alignment colons, and deeply nested lists) are fully natively supported by `prose` (because we discovered they were genuinely needed for structural clarity, validating that we shouldn't strip them).

**The next step is dan's review of Roadmap 0.3.** Roadmap 0.2 was an
even-numbered roadmap (the backward eye); Roadmap 0.3 is the forward eye,
and its question is chosen (dan, 2026-09-14, verbatim): "All three, in one
question" — the dashboard's markdown untouched as the consumer, a page by
hands that did not write the vocabulary as the judge, and the kernel grown
only as those two demand. The draft (ROADMAP-0.3.md) is held by the checker
and served by the studio; Phase 0 is choosing the stranger.

**The studio (`studio/`, port 4580, `STUDIO_PORT` to override) is dan's own
process — it serves whatever code it booted with, so restart it after pulling
new work.** The checkers' status page at `/status` re-runs the gate live on
every visit. A session that needs to look at the studio without touching
dan's process can boot one on another port: `STUDIO_PORT=4581 ruby
studio/app.rb`.

## Comprehensive Housekeeping Protocol (The RIF Loop)

This protocol is fragmented across several system rules. **You must execute every step of this loop per round, not at the end of the session.** Unnamed git state is invisible to dan; if you do not do this, he cannot see your work.

1. **Implement & Verify**: Make your changes and ensure the suite is 100% green (see below).
2. **Commit**: Leave the tree clean. Commit with an intention-revealing message. (Push only when dan says so).
3. **Update `PROJECT.md`**: Update `status`, `last_touched`, and advance the `next_step` to the current phase.
4. **Validate `PROJECT.md` YAML**: The dashboard fails silently if the YAML is invalid (like unquoted colon-spaces). You MUST verify the frontmatter parses:
   `ruby -ryaml -e 'YAML.safe_load(File.read("PROJECT.md")[/\A---\n(.*?)\n---/m, 1], permitted_classes: [Date])'`
5. **Update the Roadmap**: Record your findings, decisions, and any phase completions in the active `ROADMAP-*.md` document.
6. **Update `working-with-dan.md`**: If the round taught you *anything* about working with dan (his preferences, tells, strictures), update the agent manual.
7. **Record Lore**: POST what you *learned* (not just what you did) to the ecosystem's memory: 
   `curl -X POST http://127.0.0.1:4000/api/lore/alt-slim-pickins -H 'Content-Type: application/json' -d '{"message":"...", "who":"Antigravity"}'`
8. **Report to Journal**: POST a brief status update to the machine API:
   `curl -X POST http://127.0.0.1:4000/api/journal -H 'Content-Type: application/json' -d '{"message":"..."}'`

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
  (re-measured 2026-09-14, after Phase 6's final deletions: 269 runs / 1473
  assertions / 0 failures in one process — the dashboard's harness, which
  is the stronger one and worth running too: `ruby -Ilib:test -e
  'Dir["test/**/*_test.rb"].each { |f| require "./#{f}" }'` — plus 659
  sentences / 0 problems, 93 rules / 0 problems, 64 words and all 64 used
  in real pages / 0 problems, 10 pages verified, 25 affordances / 0 missing;
  the 13-page count retired with the paper pages, the 69-word count with
  Phase 6's cuts)
  **Set no environment variable to make this pass.** It used to need
  `RACK_ENV=test`, which switched the prettifier off and made every rendering
  test assert HTML production never emitted. If the suite only passes with
  something exported, that is the bug, not the workaround.
- **The cost, re-measured**: `ruby bin/measure_cost.rb` — the instrument;
  the numbers live in ROADMAP-0.2.md Phase 3's record.
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
