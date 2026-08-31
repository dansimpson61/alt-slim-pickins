# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `ROADMAP-0.1.md` — the roadmap that is now finished; Phases 0–8 are all complete
3. `DESIGN.md`, `VOCABULARY.md`, `CONTRACT.md` — grammar, 50 words, what an app must promise
4. `PHASE8.md`, then `PHASE7.md` — the last two phases, and the language defects they found
5. `LORE.md` — what previous sessions *learned*, which is not what they did

Don't re-derive any of that in conversation; it is all written down.

## Where things stand

**Roadmap 0.1 is finished.** All eight phases are complete and
[ROADMAP-0.1.md](ROADMAP-0.1.md) is closed; the next one is not written yet.
[BLUESKY-0.2.md](BLUESKY-0.2.md) is where it should start from.

The language runs: one sentence, fifty words, its own stylesheet, and two
Sinatra apps that speak it. `examples/roth` is a deep port of `~/dev/roth`
whose results — six figures, two charts and a thirty-row table — render on the
server, and which uses **no Ruby-defined words at all**. Across every `.sp`
file in the repo the escape hatch stands at **1 use in 356 sentences**.

dan's verdict on the port, recorded 2026-08-31: *clearly worth it. We are
exactly where we had hoped we would be at this phase of the project.*

## What is next

Nothing is scheduled. The three things worth doing, in the order the evidence
argues for:

### A second port, aimed at conditional and bespoke UI

The sharpest point an outside review made, and the biggest hole. roth exercised
**forms and tables**, which are this language's home turf; `choose`, `when`,
`otherwise` and the `if:` modifier have no real page behind them, and neither
does anything genuinely irregular. Every claim about the vocabulary's coverage
rests on two apps that happened to suit it.

### Still open, and older

`link show, "Details"` derives `/show`, not `/accounts/2`. Phase 7 was supposed
to settle whether `link` asks the app — a `path_for(name, subject)` on the
contract, the same shape as `label_for` and `format_for` — or whether routes
are simply said with `to:`. **roth had no links at all**, so there was nothing
real to draft against and it was deliberately left alone. The precedent from
Phases 0 and 2 says ask the app. It needs a page that actually navigates.

### And the thing nobody has tried

**Nobody but this project has written a page in it.** Every sentence in the
repo was written by whoever wrote the vocabulary — the roth port came closest,
and even there the *page* was ported by the same hand that owned the words.
Handing it to someone else is the only test that has not been run.

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
  port on 4577. Five defects in Phase 5 and two more in Phase 7 passed every
  checker and were found only by looking.
- **Everything green before committing:**
  `ruby check_grammar.rb && ruby check_styles.rb && for f in test/*_test.rb; do ruby $f; done`
  (currently 133 tests / 0 failures, 632 sentences / 0 problems, 65 rules / 0 problems)
- **RIF loop per round**: implement → verify → commit with an intention-revealing
  message → update `PROJECT.md` `next_step` → post lore
  (`POST /api/lore/alt-slim-pickins`; journal messages max 500 chars).
  Recent sessions have committed at the end of each round — check that is still
  what dan wants.
- Report honestly: failures verbatim, limits named, no claim of green that isn't.

## Two caveats to carry

**The escape hatch is not the measurement it looks like.** It stood at once in
284 sentences, then 9 uses in 324 when roth's markup was ported, then 3 uses in
344 when roth's *results* moved to the server, then 1 in 356 when `chart` was
redrafted and roth's last word went. It counts the distance between what a page
needs and where its data is — not the vocabulary's coverage. Read any future
number that way.

**`~/dev/roth` is a separate, dormant project and has not been touched.** Its
working tree has been mid-rename since 2025-09-11, and `examples/roth` pins the
new spelling — `lib/engine.rb` raises with an explanation if that is reverted.
roth's own defects are catalogued in `ROTH_STUDY.md` and scheduled in
`ROTH_DOMAIN_BACKLOG.md`; they are deliberately not this project's work.
