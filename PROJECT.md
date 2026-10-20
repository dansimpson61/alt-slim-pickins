---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  Roadmap 0.8 (the backward eye — the harvest) is active ([ROADMAP-0.8.md](ROADMAP-0.8.md)).
  Daytrip 0.8.0a ([DAYTRIP-0.8.0a.md](history/daytrips/DAYTRIP-0.8.0a.md)) is complete
  (2026-10-20): `metric` and `fact` are harmonized on `def <word> attribute, value`
  (`label:` and `as:` modifiers, `heading .label` inside `metric.sp`), bare
  `metric <attr>`, dotted `metric .attr` / `fact .attr`, and 2-arg `fact <name>, <value>`
  are healed, all hardcoded `word_name` branches in `Builder` and dead
  `Generator#fact`/`#metric`/`#snippet` are removed, and `PartialWord` is collapsed
  onto `Builder#evaluate_word_definition`. Twelve gate legs + pedagogy green,
  658 runs / 7,087 assertions / 0 failures.
last_touched: 2026-10-20
next_step: 'Run Daytrip 0.8.0b (`DAYTRIP-0.8.0b.md`): introduce `SlimPickins::KeyValue` (`key`, `label`, `value`, `format`) to unify `metric`/`fact`, `table` (`column`/`total`), `chart` (`band`/`line`), and `form` controls (`field`, `input`, `textarea`, `checkbox`, `choice`, `option`, `hidden`), allow `each` to iterate a `Hash` as `KeyValue` items, share indifferent key lookup between `Subject` and `Dictionary`, let `.sp` `def` headers declare keyword modifiers natively (retiring `CANONICAL_MODIFIERS`), and replace `@kwargs.key?(:x)` ternary lines in `words.rb`.'
kind: project
run: ruby examples/publication/app.rb
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
and seven example apps plus the studio that speak it. See [README.md](README.md)
— its *How roadmaps go* section governs how roadmaps work. Roadmap 0.6 closed
on 2026-10-16, unifying the language's taxonomy and teaching. Roadmap 0.7
closed on 2026-10-19 — the Editorial & Micro-Layout Publication Stretch Exam,
passed — and is kept in [ROADMAP-0.7.md](history/planning/ROADMAP-0.7.md).
Roadmap 0.8 is active in [ROADMAP-0.8.md](ROADMAP-0.8.md); `next_step` above is
the live resume point.
