---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  Roadmap 0.7's Wall Ledger is empty: all four walls healed — `page` dissolved,
  documents title themselves, `cluster` lands in `.layout`, and theme roles are
  sayable in the `.style` companion. The exam's next movement is assembly: the
  unified reader built from the paper's files, then the visual sign-off and
  `lore_reader`'s retirement. Twelve gate legs + pedagogy green, 667 runs /
  7,130 assertions / 0 failures.
last_touched: 2026-10-18
next_step: 'Assemble the unified publication reader from the paper''s files (DAYTRIP-0.7.0a): the `.frame`, `.sp`, `.layout` and `.style` drafted there rendered live, unmodified, against the Editorial Prose archetype — then retire `lore_reader` (Roadmap 0.7, definition of success).'
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

A working view language: one-sentence grammar, 63 words, its own stylesheet,
and eight example apps plus the studio that speak it. See [README.md](README.md)
— its *How roadmaps go* section governs how roadmaps work. [ROADMAP-0.6.md](history/planning/ROADMAP-0.6.md)
closed on 2026-10-16, unifying the language's taxonomy and teaching. Roadmap 0.7
is framed in [ROADMAP-0.7.md](ROADMAP-0.7.md) — the Editorial & Micro-Layout
Publication Stretch Exam. Its opening paper is [DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md)
(the Wall Ledger), and Wall 1's confirmed contract is
[DAYTRIP-0.7.0b.md](DAYTRIP-0.7.0b.md); `next_step` above is the live resume point.
