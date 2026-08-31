# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `ROADMAP.md` — the single source of truth; Phases 0–6 are complete, **Phase 7 is next**
3. `DESIGN.md`, `VOCABULARY.md`, `CONTRACT.md` — grammar, 47 words, what an app must promise
4. `LORE.md` — what previous sessions *learned*, which is not what they did

Don't re-derive any of that in conversation; it is all written down.

## The task: Phase 7 — port roth entirely

Port every view in `~/dev/roth` to this language, then I judge it against the
Slim it replaces. `PHASE0.md` documents the first slice of that page and
`bin/diff_roth.rb` diffs our render against the hand-written original.

**Settle this before you start** (it is written into the roadmap under Phase 7):
`link show, "Details"` derives `/show`, not `/accounts/2`. The language has no
opinion about routing and roth will hit it on its first page. Decide whether
`link` asks the app — a `path_for(name, subject)` on the contract, the same
shape as the existing `label_for` and `format_for` — or whether routes are
simply said with `to:`. The precedent from Phases 0 and 2 says ask the app.

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
  specimen` builds a standalone page. Five real defects passed every checker
  and were only found by looking.
- **Everything green before committing:**
  `ruby check_grammar.rb && ruby check_styles.rb && for f in test/*_test.rb; do ruby $f; done`
  (currently 82 tests / 0 failures, 555 sentences / 0 problems, 58 rules / 0 problems)
- **RIF loop per round**: implement → verify → commit with an intention-revealing
  message → update `PROJECT.md` `next_step` → post lore
  (`POST /api/lore/alt-slim-pickins`; journal messages max 500 chars).
  The previous session committed at the end of each round — check with me that
  that is still what I want.
- Report honestly: failures verbatim, limits named, no claim of green that isn't.

## One caveat to carry

The escape hatch has been used **once in 284 sentences** — but every one of
those pages was written by whoever wrote the vocabulary. Phase 7 is the first
honest test of that number. Expect roth to need words we don't have, and treat
each one as a finding rather than an inconvenience.
