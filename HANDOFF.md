# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `ROADMAP.md` — the single source of truth; Phases 0–7 are complete, **Phase 8 is next**
3. `DESIGN.md`, `VOCABULARY.md`, `CONTRACT.md` — grammar, 47 words, what an app must promise
4. `PHASE7.md` — the last phase, and the two language defects it found
5. `LORE.md` — what previous sessions *learned*, which is not what they did

Don't re-derive any of that in conversation; it is all written down.

## Where things stand

The language runs. Two Sinatra apps speak it — `examples/portfolio` and
`examples/roth`, the latter a deep port of `~/dev/roth` whose results render on
the server: its 88-line page and 249-line script became 58 sentences and 47
lines, plus 370 lines of Ruby.

**One thing is outstanding before Phase 8:** dan's judgement of that port — is
it better to read and write than the Slim it replaced? An outside review in
August 2026 called the work green and honest; dan's own verdict is recorded in
`LORE.md` and it is *yes, clearly worth it*.

## The task: Phase 8 — `chart`

`chart` is the one word drafted without evidence. It has more irreducible
configuration than any other, three pages failed to test it, and the roth port
did not use it — roth's two charts are drawn by `examples/roth/lib/chart.rb`,
in Ruby, through the escape hatch.

**That file is the evidence Phase 8 was waiting for.** It draws stacked bands,
a tax overlay, bracket shading, a legend and a hover layer, in 130 lines.
Redraft `chart` against it, or cut the word.

### Still open, and older

`link show, "Details"` derives `/show`, not `/accounts/2`. Phase 7 was supposed
to settle whether `link` asks the app — a `path_for(name, subject)` on the
contract, the same shape as `label_for` and `format_for` — or whether routes
are simply said with `to:`. **roth had no links at all**, so there was nothing
real to draft against and it was deliberately left alone. The precedent from
Phases 0 and 2 says ask the app. It needs a page that actually navigates.

### And a flank with no evidence

The outside review's sharpest point: roth exercised forms and tables, which are
this language's home turf, and never exercised **conditional or bespoke UI**.
`choose`/`when`/`otherwise` and the `if:` modifier have no real page behind
them. A second port should target that.

## Design invariants — do not break these without saying so

- One sentence: `word arguments`, indentation nests it.
- **Extending the language adds vocabulary, never syntax.** Even the escape
  hatch is a word.
- A dot means data; a bare word is language.
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
  (currently 116 tests / 0 failures, 615 sentences / 0 problems, 58 rules / 0 problems)
- **RIF loop per round**: implement → verify → commit with an intention-revealing
  message → update `PROJECT.md` `next_step` → post lore
  (`POST /api/lore/alt-slim-pickins`; journal messages max 500 chars).
  Recent sessions have committed at the end of each round — check that is still
  what dan wants.
- Report honestly: failures verbatim, limits named, no claim of green that isn't.

## Two caveats to carry

**The escape hatch is not the measurement it looks like.** It stood at once in
284 sentences, then 9 uses in 324 when roth's markup was ported, then 3 uses in
342 when roth's *results* moved to the server. It counts the distance between
what a page needs and where its data is — not the vocabulary's coverage. Read
any future number that way.

**`~/dev/roth` is a separate, dormant project and has not been touched.** Its
working tree has been mid-rename since 2025-09-11, and `examples/roth` pins the
new spelling — `lib/engine.rb` raises with an explanation if that is reverted.
roth's own defects are catalogued in `ROTH_STUDY.md` and scheduled in
`ROTH_DOMAIN_BACKLOG.md`; they are deliberately not this project's work.
