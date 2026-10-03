---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: >-
  A view language whose grammar is one sentence — `word arguments`, indentation
  nests, everything is a word — proved across 62 canonical words, 7 apps and 34
  rendered pages. Roadmaps 0.1 to 0.3 are closed; 0.4 is running as daytrips
  (`DAYTRIP-0.4.0a` through `0.4.0l`). Twelve gate legs green, 592 runs / 6,482
  assertions / 0 failures, `ruby -w -c` clean. DAYTRIP-0.4.0h's prioritized list is
  landed in full, Tier 7 included. The
  round-by-round account lives in `history/CHRONICLE.md` and each round's own record
  in its `DAYTRIP-*.md`; this field carries the present, which is what a resume card
  is for — and `bin/check_card.rb` now holds it to a budget so it stays that way.
  Tier 7 is DAYTRIP-0.4.0m.md: the card went from 32,179 characters to 3,725 and
  HANDOFF.md from 29,370 to 15,595, with 29,061 moved verbatim and none deleted,
  because sampling forty phrases found that prose nowhere else in the repository.
last_touched: 2026-10-03
next_step: >-
  **There is no queued item: every tier of DAYTRIP-0.4.0h.md's prioritized list is
  landed**, Tier 7 closing in DAYTRIP-0.4.0m.md. What comes next is a direction
  rather than a task, and by this project's own *How roadmaps go* that is dan's to
  set: 0.4 has spent itself on the backward eye, and an odd roadmap leads with the
  forward one by asking something the project cannot yet answer. That question has
  not been asked. Three proposals wait on his word, each named rather than performed
  — the word registry's global last-compile-wins order dependence, now measured
  properly in DAYTRIP-0.4.0n.md (a Library does not scope its words; constructing one
  takes a colliding name, and `editor` in the two studio UIs is the only collision),
  and whether a committed 1,226-line VOCABULARY.md earns its keep. `word_count` is
  done. Relocating VOCABULARY's two appendices was tried and declined: 12 of its 62
  entries live under those headings. Smaller open calls: `Markdown`'s triples are the last unnamed
  positional ones, the workbench word page's proportions, the unserved
  `assets/workbench.css`, the two byte-identical `.tin` files. And one standing
  caution before treating any of those as a task — five consecutive rounds found a
  list item's premises wrong, so measure the sentence before acting on it.
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
