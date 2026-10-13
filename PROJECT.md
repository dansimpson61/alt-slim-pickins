---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  A view language whose grammar is one sentence — `word arguments`, indentation
  nests, everything is a word — proved across 64 canonical words, 8 apps and 35
  rendered pages. Roadmaps 0.1 to 0.5 are closed. Roadmap 0.6 (the backward eye)
  is underway: Daytrip 0.6.0c closed on 2026-10-13 (splice pronoun unified
  on `contents` across `.tin` chrome files and `.sp` partials, retiring `children`
  as a template keyword). Twelve gate legs green, 649 runs / 6,997 assertions / 0 failures,
  `ruby -w -c` clean. The round-by-round account lives in `history/CHRONICLE.md`.
last_touched: 2026-10-13
next_step: >-
  **Daytrip 0.6.0d planned; proceed to implementation in fresh session.** Execute
  `DAYTRIP-0.6.0d.md`: universal convention slot model (target, override, kwargs),
  decouple parameter binding, formalize 7 taxonomy terms, and retire obsolete gate checks.
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

A working view language: one-sentence grammar, 64 words, its own stylesheet,
and seven example apps plus the studio that speak it. See [README.md](README.md)
— its *How roadmaps go* section governs how roadmaps work. [ROADMAP-0.5.md](ROADMAP-0.5.md)
closed on 2026-10-12, delivering families and lexical containment; roadmap 0.6 is next,
and `next_step` above is the live resume point.
