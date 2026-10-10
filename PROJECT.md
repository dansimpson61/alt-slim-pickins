---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  A view language whose grammar is one sentence — `word arguments`, indentation
  nests, everything is a word — proved across 62 canonical words, 8 apps and 38
  rendered pages. Roadmaps 0.1 to 0.3 are closed. 0.4 ran as daytrips
  (`DAYTRIP-0.4.0a` through `0.4.0q`) and, since 2026-10-10, has a question in
  `ROADMAP-0.4.md`: do the conventions keep their promises, so that an author only has
  to name things? It closes when `CONVENTIONS.md`'s weak-spots table is empty and
  every documented override is proved by a test. Twelve gate legs green, 613 runs /
  6,676 assertions / 0 failures, `ruby -w -c` clean. The round-by-round account lives
  in `history/CHRONICLE.md` and each round's record in its `DAYTRIP-*.md`; this field
  carries the present, and `bin/check_card.rb` holds it to a budget. 0.4.0p was
  rejected; 0.4.0q (families) is withdrawn from 0.4 and carried to 0.5 as its
  question, unbuilt. The four plain defects the 2026-10-10 review named are fixed.
last_touched: 2026-10-10
next_step: >-
  **Work `ROADMAP-0.4.md`'s definition of success, starting with criterion 1**: count
  which of the fourteen documented overrides no test exercises, and add a test that
  fails if the convention wins for each one that has none. Done 2026-10-10: the
  `BigDecimal` row (`Generator.plain` is the one home for writing a value as text),
  and the dead `Builder#parameters_for`/`#evaluate_body` deleted. One commit per fix,
  each with a test that fails on the old code. Probe with the data the apps produce,
  and diff the corpus with `bin/byte_diff.rb` before and after. dan ruled
  `heading_level`'s and `choose`'s overrides inadequate, so they are table rows, not
  overrides. Then walk the table's three patterns with dan. Rule, accepted by dan 2026-10-10: **no new design document until
  the last one has shipped code or been withdrawn.** Rejected as configuration:
  `word.x` (R2), and a bare name carrying no meaning (A1). Still dan's: the `link`
  positional alias, variants parts (i) and (ii), and 0.4.0p's N1 and N2 on their own
  merits.
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
