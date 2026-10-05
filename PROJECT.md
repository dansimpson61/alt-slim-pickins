---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  A view language whose grammar is one sentence — `word arguments`, indentation
  nests, everything is a word — proved across 62 canonical words, 8 apps and 38
  rendered pages. Roadmaps 0.1 to 0.3 are closed; 0.4 is running as daytrips
  (`DAYTRIP-0.4.0a` through `0.4.0q`). Twelve gate legs green, 606 runs / 6,628
  assertions / 0 failures, `ruby -w -c` clean. DAYTRIP-0.4.0h's prioritized list is
  landed in full. The round-by-round account lives in `history/CHRONICLE.md` and each
  round's own record in its `DAYTRIP-*.md`; this field carries the present, which is
  what a resume card is for, and `bin/check_card.rb` holds it to a budget.
  0.4.0p was **rejected** — it "was requiring the author to take care of the compiler
  rather than the other way around" — and `DAYTRIP-0.4.0q.md` replaces it, written to
  that test. It is the families design: each `.sp` file is a namespace of `def`s, a
  word opens its family for what nests under it, lexically; `def card, subject,
  content` lets the sixteen-slot `expects` preamble go, and `item` inside `list.sp`
  makes containment the rule rather than a declaration. Decisions D3 (shape only when
  it gathers), D6 (shadowing allowed, gate reports) and D6a (`super`) are ruled.
  Nothing is implemented: 0.4.0q is a plan with seven ordered steps.
last_touched: 2026-10-05
next_step: >-
  **Implement `DAYTRIP-0.4.0q.md` — families — starting at Step 1.** Step 0 is done:
  the suite is green (606 runs, 0 failures) after an untracked scratch document at the
  repo root, which `check_vitals` is not exempt from, was folded into HANDOFF. 0.4.0q
  replaces the rejected 0.4.0p and carries the rationale, eight decisions, seven
  ordered steps, risks. **Do not skip Step 3**: it builds the lexical chain and only
  *reports* what would resolve differently, changing no behaviour, and it should find
  exactly `editor` plus the eleven parent-bound words — if it finds more, stop and
  report rather than adjusting the chain until the list looks short. D3, D6 and D6a
  are ruled; nothing else in the plan needs dan. **Still his and not started**: the
  `link` positional alias (removing it and making `name_and_content` refuse a dropped
  value are one change — Step 5b), and parts (i) and (ii) of the variants proposal,
  which are their own round after families. Queued behind families: docs and pedagogy,
  which holds the eleven principles, the three conventions rulings now in HANDOFF, and
  the field family. `HANDOFF.md` carries the detail.
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
