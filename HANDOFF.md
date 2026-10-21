# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
3. `PROJECT.md` — `next_step`. **Trust it over this file** if the two disagree: the card is updated every round.
4. `HANDOFF.md` — this document, specifically the active next step below
5. `docs/ONTOLOGY.md` — the Tri-Plane meta-architecture (`.frame`, `.sp`, `.layout`; the contract/convention/promise triad)
6. `docs/STRETCH_PROTOCOL.md` — the Stretch Exam, which an odd roadmap opens with
7. `docs/PRIMER.md`, `docs/CONVENTIONS.md`, `docs/VOCABULARY.md`, `docs/LAYOUT.md` — the author-facing guides
8. `docs/DESIGN.md`, `docs/CONTRACT.md` — the grammar and the app promise
9. `LORE.md` — what previous sessions *learned*; the last entries are this session's
10. `working-with-dan.md` — candid notes on working with him; it is yours to keep true

`history/` is the kept record — roadmaps 0.1 through 0.6, every daytrip, and
`CHRONICLE.md`, the round-by-round account; `roth/` is notes on a different
project. Don't re-derive any of the above in conversation; it is all written
down. Older documents in `history/` may still say `tin` for `.frame` and
`spiff` for `.layout`.

## Current Vitals (held by `checkers/check_vitals.rb`)

Every number below is measured by `bin/census.rb` and held by `check_vitals.rb`,
so this block cannot go stale without the gate saying so:

- **Census**: 63 canonical words (37 Ruby primitives + 26 `.sp` composed words),
  5 apps, 26 app words, 30 verified pages, 38 conventions, 33 promises,
  113 style rules, 55 test files.
- **Twelve gate legs** on `/status`, re-run live on every visit: Grammar, Shape,
  Styles, Layout, Scope, Promises, Conventions, Card, Pages, Vitals, Ruby,
  Suite. The Suite leg asks `Census.test_files`, so the example apps' suites are
  inside the gate.
- **`ruby -w -c`** is clean over `lib/`, `studio/`, `bin/`, the checkers, the
  suite and the example apps.
- **A trap worth knowing before you leave a note on disk**: `check_vitals` reads
  prose claims from every non-exempt document, and an untracked file at the repo
  root is not exempt. A scratch document stating a count the census disagrees
  with turns the suite red. `DAYTRIP-*.md` and `ROADMAP-*.md` are exempt by glob.

## The active next step

**Roadmap 0.8 (the backward eye — the harvest) is active ([ROADMAP-0.8.md](ROADMAP-0.8.md)).** Roadmap 0.7 closed on 2026-10-19 (`history/planning/ROADMAP-0.7.md`).

- **Daytrip 0.8.0a (`metric`, `fact`, `snippet`, and single word-compilation path) — complete ([DAYTRIP-0.8.0a.md](history/daytrips/DAYTRIP-0.8.0a.md)).**
- **Daytrip 0.8.0b (`KeyValue` spine, `Hash` iteration in `each`, & native `kwargs` in `.sp` `def` headers and `Words`) — complete ([DAYTRIP-0.8.0b.md](history/daytrips/DAYTRIP-0.8.0b.md)).**
- **Daytrip 0.8.0c (Blockless `box` default `contents` splice & `.style`/`.layout` handoff) — complete ([DAYTRIP-0.8.0c.md](history/daytrips/DAYTRIP-0.8.0c.md)).**
- **Daytrip 0.8.0d (Harmonize composed words, retire dead variants, explicit `def` headers) — complete ([DAYTRIP-0.8.0d.md](history/daytrips/DAYTRIP-0.8.0d.md)).**
  Harmonized `card.sp` (`subject`), `section.sp` (`subject`), and `title.sp` (`attribute`),
  eliminating all word-name exceptions in `contracts.rb`; retired dead `variant` slots on
  `aside`, `scroll`, `item`, and `tabs`; brought all studio UI partials onto explicit `def`
  headers; and added guards in `Subject#has?` and `Builder#evaluate_word_definition`.
- **Remaining 0.8 daytrips (`ROADMAP-0.8.md`):**
  - **0.8.0e (Garden triage & SOTA app modernization):** Retire
    `milestone_planner` and `way_exam`; stow dated planning/study docs in
    `history/`; modernize `publication`, `portfolio`, `roth`, `dashboard`, and
    `word_graph` to SOTA `.sp`.
  - **0.8.0f (Leveling the path for 0.9 CRUD in `portfolio` & close):**
    Harmonize `form`/`field`/`input` contracts and collection-scoped `empty`
    pruning for Roadmap 0.9's SQLite CRUD stretch exam in `examples/portfolio`.
- **Next step:** write a detailed plan for **Daytrip 0.8.0e** for Dan's approval before proceeding.

## Studio Process & Verification Protocol

The studio (`studio/`, port 4580, `STUDIO_PORT` to override) is agent-managed.
- Check the port: `curl -s -m 2 http://127.0.0.1:4580/`.
- If down or after code changes, run in background: `cd ~/dev/alt-slim-pickins && exec ruby studio/app.rb`
- A `.frame`/`.sp`/`.layout` file edit takes effect on the next request, with no
  restart. A `lib/` Ruby code edit does not; restart to serve it.
- Restarting reliably is the trap: Puma renames its process to
  `puma 8.0.2 (tcp://localhost:4580) [alt-slim-pickins]`, so
  `pgrep -f "ruby studio/app.rb"` matches nothing. Kill by the listening socket's
  PID — `kill $(lsof -t -i:4580)` — confirm the port is free, *then* start the
  new process, and verify with a direct `curl` for a string only the new code
  would emit, not just an HTTP 200.
- The checkers' status page at `/status` re-runs the gate live on every visit.

## Comprehensive Housekeeping Protocol (The RIF Loop)

Execute every step per round, not at the end of the session:

0. **Plan First**: Proceed ONLY on the basis of a detailed, written plan approved by Dan. If no plan exists, the first task is to write one for Dan's approval.
1. **Implement & Verify**: suite 100% green. The gate has **twelve legs** (the
   same ones `/status` runs live), in the order `StudioStatus::LEGS` names them:

   ```sh
   ruby checkers/check_grammar.rb && ruby checkers/check_shape.rb && ruby checkers/check_styles.rb &&
   ruby checkers/check_layout.rb && ruby checkers/check_layout_scope.rb && ruby bin/check_promises.rb &&
   ruby bin/check_conventions.rb && ruby bin/check_card.rb &&
   ruby bin/verify_pages.rb && ruby checkers/check_vitals.rb && ruby checkers/check_ruby.rb &&
   ruby -Ilib:test -e 'require "slim_pickins/census"; SlimPickins::Census.test_files.sort.each { |f| require f }'
   ```

2. **Commit**: leave the tree clean, with an intention-revealing message. (Push only when dan says so.)
3. **Update `PROJECT.md`**: `status`, `last_touched`, and advance `next_step`.
4. **Validate `PROJECT.md` YAML**:
   `ruby -ryaml -e 'YAML.safe_load(File.read("PROJECT.md")[/\A---\n(.*?)\n---/m, 1], permitted_classes: [Date])'`
5. **Update the Roadmap**: record findings, decisions, and phase completions in the active `ROADMAP-*.md`.
6. **Update `working-with-dan.md`**: record durable lessons about working with dan.
7. **Propose and/or ask for new wishlist items**: review and update `WISHLIST.md` (graduate completed items, record new pinches/ideas).
8. **Report Context Window Status**: state truncation status, step count, transcript volume, and remaining headroom.
9. **Record Lore**:
   `curl -X POST http://127.0.0.1:4000/api/lore/alt-slim-pickins -H 'Content-Type: application/json' -d '{"message":"...", "who":"<your-name>"}'` (or append to `LORE.md` when dashboard is down).
10. **Report to Journal**:
   `curl -X POST http://127.0.0.1:4000/api/journal -H 'Content-Type: application/json' -d '{"message":"..."}'`

## Standing principles — do not break without saying so

- One sentence: `word arguments`, indentation nests it. Extending the language
  adds vocabulary, never syntax. A dot means data; a bare word is language.
  There is no numeric literal. A name is a subject and must exist. Mechanical
  facts are free; judgements belong to the app. A line that states the
  inferable should not exist. This is a noun language — 56 of 63.
- **Every truth has one home** (the grammar in Transform, the vocabulary in
  contracts, the checkers consuming, never mirroring).
- **A rule must outlive its reason** — when a proscription blocks empowerment
  *and* better code, examine its foundation; it survives only if the
  foundation is worth more than what it blocks.
- **No sacred cows.** When we decide to improve the language, the corpus
  follows — apps, studio, tests, docs, and the census number all move together.
  No legacy code has standing to impede a universal improvement.
- **Word, or power?** — for every candidate surface, the language grows by
  words; the surface grows only when the answer is honestly "power."
- **The dogfood is enforced**: built-ins and app words eat the same food, by
  test, and the gatherers are re-provable as app words, byte for byte.
- **The escape-hatch number is retired.** Stop quoting it.
- **`~/dev/dashboard` must keep working, untouched.**
- **`~/dev/roth` is a separate, dormant project and has not been touched.**
