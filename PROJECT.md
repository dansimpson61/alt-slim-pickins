---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  A view language whose grammar is one sentence — `word arguments`, indentation
  nests, everything is a word — proved across 62 canonical words, 8 apps and 35
  rendered pages. Roadmaps 0.1 to 0.4 are closed. 0.4 (closed 2026-10-11) asked whether
  the conventions keep their promises, so that an author only has to name things:
  every documented override is proved by a test, `CONVENTIONS.md`'s weak-spots table
  is empty, and `ROADMAP-0.4.md` records each criterion. Twelve gate legs green, 627
  runs / 6,698 assertions / 0 failures, `ruby -w -c` clean. The round-by-round account
  lives in `history/CHRONICLE.md` and each round's record in its `DAYTRIP-*.md`; this
  field carries the present, and `bin/check_card.rb` holds it to a budget. 0.5 is
  next: `ROADMAP-0.5.md` holds its question (families) and definition of success,
  confirmed by dan across several rounds of correction and closed 2026-10-11.
last_touched: 2026-10-11
next_step: >-
  **Start 0.5's first daytrip, in a fresh session.** `ROADMAP-0.5.md` holds the
  question and the definition of success; `HANDOFF.md`'s active next step points
  here too. Two things need designing before any mechanical migration: what replaces
  the old declaration line (dan's preferred shape is `def word, [param], [param],
  ...`; the one problem to solve humanely, without new author bookkeeping, is a
  parameter named after a structural kind colliding with a record's own field of
  the same name), and the nearest-first lookup chain itself, built first in
  reporting-only mode — the way 0.4.0q's Step 3 did — so it only confirms what
  would resolve differently (expected: `editor`, plus the eleven parent-bound
  words) before any behaviour changes. Carried in, still dan's call: the `link`
  positional alias, the overloaded `variant` idea, two unconfirmed parsing rulings,
  and `partial_slot_forwarding`'s relationship to formal containment.
kind: project
run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: >-
  The roadmap history and the round-by-round account that used to live here are in
  `history/CHRONICLE.md`, verbatim — 29,061 characters moved out of this
  frontmatter on 2026-10-03 and not one deleted, because sampling found none of it
  anywhere else in the repository. What belongs in this field is a standing caution
  a session should read before starting, and there is one: measure the premises of
  any list item before acting on it. Four consecutive rounds (0.4.0i to 0.4.0l)
  found an item's own sentence wrong — the counts roughly right, what they implied
  not. Tier 7 made it five: the assumption that this card duplicated the daytrips
  was false, and acting on it would have deleted prose that exists nowhere else.
  0.4.0o made it six, and in a new shape: the dead declaration was real, but the
  obvious inference — that the mechanism behind it was dead code — was wrong.
  Instrumenting it proved it works and fires nowhere, which is a different finding
  and a different fix. Measure the mechanism, not only the usage. On 2026-10-05 it
  happened an eighth time, and to the reviewer: a "live defect" reported in
  `queue.sp` was an artefact of a probe passing a String where the app passes a
  Symbol. **Probe with the data the application actually produces, not with data of
  the right shape.**
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
