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
  closed; five language irregularities are named and left for dan.
last_touched: 2026-10-03
next_step: >-
  **No queued item; the direction is dan's, and the queue of named-not-performed
  proposals is now eight.** DAYTRIP-0.4.0o's regularity audit added five, each
  measured and each a language decision: (1) `link` has a second, undocumented
  sentence shape that swaps its positional arguments when the first is a string —
  the only finding that contradicts a written claim in DESIGN.md, *the order never
  varies*; it is spoken nowhere in 55 `link` sentences. (2) `tab` is the one
  structural child with no `parents:`, so an orphan renders an empty panel and
  silently drops its content, where `item` refuses; one line. (3) The
  `field`/`input`/`textarea` modifier sets are arbitrary — no rule predicts which
  of six modifiers each takes, and a fluent speaker guesses wrong four times in six.
  (4) `variant` has two spellings, and `action`'s name slot is empty, so it did not
  need the second. (5) `search`'s `q:` holds a value under a parameter's name. Plus
  one in the tooling: HANDOFF's gate command runs 547 tests, the gate's Suite leg
  602. The three older proposals stand — the registry's last-compile-wins order
  dependence (0.4.0n), whether a committed 1,226-line VOCABULARY.md earns its keep,
  and the smaller calls (`Markdown`'s triples, the workbench word page's
  proportions, `assets/workbench.css`, the two byte-identical `.tin` files). And the
  standing caution, which held a sixth time: measure the sentence before acting on
  it. `HANDOFF.md` carries the detail.
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
