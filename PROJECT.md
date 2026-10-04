---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  A view language whose grammar is one sentence — `word arguments`, indentation
  nests, everything is a word — proved across 62 canonical words, 7 apps and 34
  rendered pages. Roadmaps 0.1 to 0.3 are closed; 0.4 is running as daytrips
  (`DAYTRIP-0.4.0a` through `0.4.0o`). Twelve gate legs green, 602 runs / 6,527
  assertions / 0 failures, `ruby -w -c` clean. DAYTRIP-0.4.0h's prioritized list is
  landed in full. The round-by-round account lives in `history/CHRONICLE.md` and each
  round's own record in its `DAYTRIP-*.md`; this field carries the present, which is
  what a resume card is for, and `bin/check_card.rb` holds it to a budget.
  0.4.0o ran the `writing-dsls` regularity audit over the whole vocabulary and found
  the grammar regular — 31 modifier spellings, each shared one holding one meaning.
  What it found instead was a promise the gate could not check: `action` declared
  `path:` and `return_to:`, never said either, and three documents, one test name and
  the gate all recorded a reader that did not read. Fixed, with the gate's hole
  closed. Of the five language irregularities it named, three landed on dan's word,
  two were escalated as larger than reported, and three questions became queued
  daytrip discussions.
last_touched: 2026-10-03
next_step: >-
  **Dan ruled on the 0.4.0o audit on 2026-10-03 and queued three daytrip
  discussions.** Each wants a decision and its argument, not a patch: (1)
  **scoping** — the registry is global and last-compile-wins, and his framing is
  wider than the `editor` collision DAYTRIP-0.4.0n.md measured; (2) **docs and
  pedagogy** — whether a committed 1,226-line VOCABULARY.md earns its keep beside
  the studio's live reference, and what each surface is *for*; (3) **the field
  family** — `field`/`input`/`textarea` share six modifiers in no predictable
  pattern, and the rule comes before the table. Landed since the audit: the
  promise-ledger defect and the gate hole that hid it, the argument-order message,
  `tab`'s `parents:` (which overrode a VOCABULARY claim that the silent loss was
  deliberate — his to reverse), and one spelling of "the suite" in the gate command.
  **Two findings were escalated rather than closed, both because they were presented
  as smaller than they are**: `search`'s `q:` is not a rename (the modifier's
  spelling had to match `input`'s name slot or the no-query case raises, and three
  apps read `params[:q]`), and `link`'s second sentence shape is a deliberate,
  tested alias rather than an oversight — redundant, since `link .doc_name, to:
  .doc_path` renders identically. The smaller calls are re-measured in HANDOFF, and
  one was stale: `Markdown`'s `[:element, …]` triples no longer exist.
  `HANDOFF.md` carries the detail.
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
  and a different fix. Measure the mechanism, not only the usage.
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
