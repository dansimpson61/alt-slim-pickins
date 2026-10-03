# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
3. `PROJECT.md` — `next_step`. **Trust it over this file** if the two disagree: the
   card is updated every round and this file has lagged it by a week before. It is
   also short now, and deliberately — `bin/check_card.rb` holds it to a budget.
4. `HANDOFF.md` — this document, specifically the active next step below
5. `DAYTRIP-0.4.0a.md` through `DAYTRIP-0.4.0m.md` — one per round, each the record
   of its own. **Read `0.4.0h` first if you are picking up a thread from the audit's
   list**: it carries the prioritized list, and its *What landed* says what was done
   at the time. For the connected account of every round in order, read
   `history/CHRONICLE.md` instead of reconstructing it from thirteen files
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

Roadmap 0.4 is underway as a sequence of winnable daytrip victories. **Each round's
record is its own `DAYTRIP-*.md`**, and the connected account of all of them in
order is [history/CHRONICLE.md](history/CHRONICLE.md) — which is where this file's
volet-by-volet chronicle went on 2026-10-03, verbatim.

It went because of what it cost rather than what it said. This file is the
most-churned in the repository's history — 3,807 lines, ahead of the closed
`ROADMAP-0.2.md` at 3,462 and `builder.rb` at 3,009 — and the chronicle was why:
every round appended a volet entry to a document that is step 4 of its own reading
list. It was not a duplicate of the daytrips; sampling sixteen phrases found none of
them anywhere else, so it moved rather than went.

What stays here is what a fresh session needs and cannot get elsewhere: the reading
list above, the vitals below, the active next step, the protocols and the standing
principles.

### Current Vitals (measured 2026-10-03)

Every number below that the census measures is now held by `check_vitals.rb`, so
this block cannot go stale without the gate saying so. The rows it does *not*
measure are quoted as the gate output they are.

- **Census SSOT (`bin/census.rb`)**: 62 canonical words (39 Ruby primitives + 23 `.sp` partials), 7 apps, 28 app words, 34 verified pages, 38 conventions, 35 promises, 113 stylesheet rules, 57 test files.
- **Full Suite**: 600 runs, 0 failures, 0 errors, 0 skips in one process — and
  that now includes the example apps' own suites, because the Suite leg asks
  `Census.test_files` instead of keeping its own glob.
- **Check Grammar**: `1,239 sentences checked, 92 words defined, 0 problems`.
- **Check Shape**: 62 canonical words, 0 problems.
- **Check Styles**: 27 emittable classes, 59 rendering, 113 rules, 0 problems.
- **Spiff (lexicon)**: 16 entries, 84 documented declarations, 0 problems.
- **Spiff Scope (zones)**: 2 spiffs held to their pages, 0 problems.
- **Promises / Conventions / Card / Pages**: 35 / 38 / 7 fields / 34 pages, 0 problems.
- **Twelve gate legs** on `/status`, which re-runs them live: Grammar, Shape, Styles, Spiff, Scope, Promises, Conventions, Card, Pages, Vitals, Ruby, Suite. The Suite leg asks `Census.test_files`, so the example apps' suites are inside the gate now.
- **Byte-diff corpus digest** (`ruby bin/byte_diff.rb`): a digest over every page the gate proves. No number is written down here on purpose — `examples/lore_reader` renders a live count of `LORE.md`'s entries, so the digest moves whenever lore is left. Compare snapshots within a session, which is what `bin/byte_diff.rb`'s own header says.
- **`ruby -w -c`** is clean over `lib/`, `studio/`, `bin/`, the checkers, the suite and the example apps.

---

---

### The active next step — dan's, because the list is finished

**Every tier of `DAYTRIP-0.4.0h.md`'s prioritized list is landed.** Tier 7 closed in
`DAYTRIP-0.4.0m.md`: the resume card went from 32,179 characters to 3,707 and this
file from 29,370 to about 18,000, with 29,061 characters moved verbatim to
`history/CHRONICLE.md` and `bin/check_card.rb` given the budget the audit asked for.

So there is no queued item. What the audit set out eleven rounds ago is done, and
what comes next is a direction rather than a task — which by this project's own
*How roadmaps go* is dan's to set. **0.4 has spent itself on the backward eye**, and
an odd roadmap leads with the forward one: it asks something the project cannot yet
answer. That question has not been asked yet.

**Before taking anything below as a task, measure the sentence it is written in.**
Five consecutive rounds (0.4.0i to 0.4.0m) found a list item's own premises wrong,
and the pattern held every time: the counts were roughly right and what they implied
was not. Tier 7 was the sharpest case — both this file and the audit said the card
duplicated the daytrips, and sampling twenty-four phrases found none of them
anywhere else. Acting on the premise would have deleted the only copy.

**Three proposals awaiting dan's word**, each named rather than performed:

- **The word registry is global and last-compile-wins**, and `DAYTRIP-0.4.0n.md`
  measured it properly: a `Library` does not scope its words, and merely
  *constructing* one takes a colliding name from another. Exactly one name collides —
  `editor`, in both studio UIs. The live studio is correct only because
  `StudioPages.ui_library` is not memoized and so re-registers at every use;
  `test/studio_try_test.rb` names that mechanism and depends on it. The cheap fix is
  to rename the classic UI's `editor`; the thorough one is a per-library registry,
  which is a change to the runtime's lookup path. Dan's call.
- **`VOCABULARY.md`'s two appendices cannot simply move to `history/`** — the
  proposal was tried and declined on measurement. 12 of the vocabulary's 62 entries
  live under `## What drafting surfaced` and `## What the drafts left open`, all with
  contracts and zero drift, so relocating the sections would strip a fifth of the
  vocabulary from the document that defines it. Doing it means restructuring the
  document — lifting those entries into the main run first — which is not a tidying
  job. The larger question of whether a committed 1,226-line `VOCABULARY.md` earns
  its keep beside the studio's live reference is still open and still dan's.
- **`word_count`/`words_count` is done** (`DAYTRIP-0.4.0n.md`): one name, verified by
  rendering.

**And the smaller open calls**, unchanged: `Markdown`'s `[:element, …]` and the
tokenizer's are the only unnamed positional triples left; the workbench word page's
proportions; the unserved `assets/workbench.css`; the two byte-identical `.tin`
files.

### Two instruments to use rather than rebuild (added in 0.4.0h)

- **`ruby bin/byte_diff.rb`** renders every page the gate proves and reduces the
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
