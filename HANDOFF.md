# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `ROADMAP-0.2.md` — the live roadmap. `ROADMAP-0.1.md` is closed; its eight phases are all complete
3. `DESIGN.md`, `VOCABULARY.md`, `CONTRACT.md` — grammar, 50 words, what an app must promise
4. `PHASE8.md`, then `PHASE7.md` — the last two phases, and the language defects they found
5. `LORE.md` — what previous sessions *learned*, which is not what they did

Don't re-derive any of that in conversation; it is all written down.

## Where things stand

**Roadmap 0.1 is finished and 0.2 is written.** All eight phases of
[ROADMAP-0.1.md](ROADMAP-0.1.md) are complete; [ROADMAP-0.2.md](ROADMAP-0.2.md)
is the live one and nothing in it is started.

The language runs: one sentence, fifty words, its own stylesheet, and two
Sinatra apps that speak it. `examples/roth` is a deep port of `~/dev/roth`
whose results — six figures, two charts and a thirty-row table — render on the
server, and which uses **no Ruby-defined words at all**. Across every `.sp`
file in the repo the escape hatch stands at **1 use in 356 sentences**.

dan's verdict on the port, recorded 2026-08-31: *clearly worth it. We are
exactly where we had hoped we would be at this phase of the project.*

## What is next — Phase 0 of ROADMAP-0.2.md

**Port one dashboard view: `~/dev/dashboard/views/ports.slim`, 42 lines.**

Not the easiest — the one holding most of the problem in miniature: a form with
two hidden fields, four conditionals, three `each` loops, and an app word
(`ports`, a `SlimPickins::Tabular` subclass in the dashboard's `words/`).

The phase answers one question: **can a page nobody here designed be said in
this language at all?** Port it, and **stop at the first thing that cannot be
said** — do not invent a word to get past a wall, record the wall. The roadmap
has the done-conditions and the pivot criteria, including what to do if it
fails in each of four different ways.

Two things already known before a line is written:

- `ports.slim` has **no `href` of its own.** Every link on it is emitted from
  inside the `ports` Ruby class. Routing is deferred one level, not absent.
- The dashboard's own `words/` directory means **it independently invented app
  words.** A port is the only head-to-head of the two experiments that will
  exist.

Read the whole of `ROADMAP-0.2.md` before starting. It is short, it has a
measured risk register, and two standing constraints that apply to every phase:
the language must stay lovely to read, and adding a word must be easy to do
*well*.

## Design invariants — do not break these without saying so

- One sentence: `word arguments`, indentation nests it.
- **Extending the language adds vocabulary, never syntax.** Even the escape
  hatch is a word.
- A dot means data; a bare word is language.
- **There is no numeric literal.** A bare number is neither a dot nor a word,
  so a figure in a page has nowhere to stand — it belongs to the app.
- A name is a subject and must exist; content is a label. Never runtime-decided.
- Mechanical facts derivable from a value's shape are free. Facts encoding a
  human judgement about the domain belong to the app — ask, don't guess.
- A line that states the inferable should not exist.

## How this project works

- **Verify before asserting.** Never state a count, ratio or claim without
  measuring it, and say what the measurement covered. Several claims in these
  docs were wrong on first writing because they were asserted from memory.
- **Checkers are not enough — look at the rendered output.** `ruby bin/demo.rb
  specimen` builds a standalone page; `ruby examples/roth/app.rb` serves the
  port on 4577. Across 0.1, eleven defects passed every checker and were found
  only by loading the page.
- **Nor are happy-path tests.** `test/combination_test.rb` crosses the words
  that hold state against each other. Two crashes lived behind 133 green tests
  because every one of them rendered a page somebody wrote on purpose. A word
  that gathers, binds or shifts anything gets crossed against the ones that
  already do.
- **Everything green before committing:**
  `ruby check_grammar.rb && ruby check_styles.rb && for f in test/*_test.rb; do ruby $f; done`
  (currently 142 tests / 0 failures, 632 sentences / 0 problems, 65 rules / 0 problems)
- **RIF loop per round**: implement → verify → commit with an intention-revealing
  message → update `PROJECT.md` `next_step` → post lore
  (`POST /api/lore/alt-slim-pickins`; journal messages max 500 chars).
  Recent sessions have committed at the end of each round — check that is still
  what dan wants.
- Report honestly: failures verbatim, limits named, no claim of green that isn't.

## Three caveats to carry

**The escape hatch is not the measurement it looks like.** It stood at once in
284 sentences, then 9 uses in 324 when roth's markup was ported, then 3 uses in
344 when roth's *results* moved to the server, then 1 in 356 when `chart` was
redrafted and roth's last word went. It counts the distance between what a page
needs and where its data is — not the vocabulary's coverage. Read any future
number that way.

**`~/dev/dashboard` must keep working, untouched.** It is the tool that runs
everything else in `~/dev`. The port is a *parallel* set of views that can be
thrown away, never a replacement — the discipline that kept roth clean through
two phases and produced a better result than editing it would have. Its own
`journal.md` churns from lore posts and is exempt.

**`~/dev/roth` is a separate, dormant project and has not been touched.** Its
working tree has been mid-rename since 2025-09-11, and `examples/roth` pins the
new spelling — `lib/engine.rb` raises with an explanation if that is reverted.
roth's own defects are catalogued in `ROTH_STUDY.md` and scheduled in
`ROTH_DOMAIN_BACKLOG.md`; they are deliberately not this project's work.
