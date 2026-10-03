# Daytrip 0.4.0m — The Card Surgery, and the Premise That Would Have Deleted It

Tier 7, the last item on `DAYTRIP-0.4.0h.md`'s prioritized list. The resume card went from 32,179 characters to 3,725 and `HANDOFF.md` from 29,370 to 15,595 — 29,061 characters moved verbatim to `history/CHRONICLE.md`, and not one deleted. `bin/check_card.rb` has the opinion the audit asked for. The round's finding is that the premise it started from was false, and acting on it would have destroyed the only copy of the project's connected history.

---

## The brief

Dan said *proceed*. Both `HANDOFF.md` and the audit's Tier 7 described the card as
restating the `DAYTRIP-*.md` files, so the surgery looked like deletion. The
handoff's own first instruction was to measure the premise before acting on it,
which had paid four rounds running.

Verified before touching anything: twelve legs green, 592 runs / 0 failures.

---

## Part 1 — The premise was false, and this was the round where that mattered most

The card's prose was sampled against the rest of the repository: twelve six-word
phrases from `status`, twelve from `notes`, spaced evenly through both fields, each
searched across every `.md` in the tree.

```
status   0 of 12 sampled phrases found anywhere else
notes    0 of 12
HANDOFF  0 of 16
```

**None of it is a duplicate.** It is independently written prose about the same
events, and it is the only connected, compressed account of the project's rounds in
order — the thing thirteen separate `DAYTRIP-*.md` files do not provide. The
assumption stated in the audit and repeated by me in `HANDOFF.md` would have
deleted 29,061 characters that exist nowhere else.

So the defect was real and it was not redundancy. Measured, it was three things:

- **Size.** `status` was 20,000 characters and `notes` 9,060 — 92% of a
  frontmatter block that is 98% of the file, in a document read at the start of
  every session so that the session need not read the repo. Together longer than
  `transform.rb`, `builder.rb` and `generator.rb` combined.
- **The wrong container.** Both were single folded YAML scalars with no paragraph
  breaks. A chronicle in frontmatter cannot be skimmed, linked or navigated; the
  only way to read it is to read all of it.
- **No budget.** `bin/check_card.rb` printed `status 11145 chars` on every green run
  and had no opinion about it — which the audit noticed and named.

**So the surgery was move, not delete**, and the move is verifiable: the chronicle's
body, with headings and the explanatory preamble stripped and whitespace normalised,
is **29,061 characters and byte-identical** to the two fields it came from.

## Part 2 — What moved, and what stayed

`history/CHRONICLE.md` holds the card's two fields and `HANDOFF.md`'s volet
chronicle. It sits in `history/` because that is already where this project keeps
what is consulted rather than read, and it says in its own header that it is not
maintained: a round's record is its `DAYTRIP-*.md`, and the card carries the
present.

The headings are the five round boundaries the text could be split on with
confidence. Within the first — a 12,817-character stretch covering the truth round,
the naming, the tin and the audit — paragraph breaks fall at the narrative's own
"Then …" transitions. **No round attribution was invented**, because the text does
not support one and a fabricated heading is worse than a long paragraph.

`HANDOFF.md` lost its volet-by-volet chronicle for a measured reason rather than an
aesthetic one: it is the **most-churned file in the repository's history** — 3,807
lines, ahead of the closed `ROADMAP-0.2.md` at 3,462 and `builder.rb` at 3,009 —
and the chronicle was why, since every round appended an entry to a document that
is step 4 of its own reading list. (An earlier claim of mine, that it was *second*
most-churned, was wrong: it has overtaken the roadmap.)

**One mistake worth recording.** The first split swept too much: the active next
step, the ordered plan, the instruments and the open candidates were all nested
under `## Active Roadmap Progression`, so a slice on section boundaries carried the
forward-looking half of the document into a history file. Caught by listing the
headings afterwards and noticing the next step had vanished. The lesson is small and
general — **when a document's structure and its meaning disagree, the structure will
mislead a mechanical edit**, and the check is to read back what the edit produced
rather than what it was supposed to produce.

What stayed in `HANDOFF.md`: the reading list, the current vitals, the active next
step, the protocols, the standing principles. The superseded plan moved to the
chronicle too, labelled as superseded, because this round's rule was move-not-delete
and a stale plan is still unique text.

## Part 3 — The budget, and why it says what it says

```ruby
BUDGETS = { 'status' => 1_500, 'next_step' => 2_000, 'notes' => 1_500 }.freeze
```

The numbers are a judgement and the source says so: roughly a minute's reading each,
proportionate to a field read before every session, with `next_step` given the most
because it is the one thing a session must act on. They are dan's to change and
changing them is one line.

The refusal matters as much as the limit:

```
OVER BUDGET    `status` is 1921 chars against a budget of 1500 — a card that costs
               more to read than the repo it stands in for has stopped working
               (move the overflow somewhere it can be read; do not delete it)
```

That second line is this round's finding turned into the gate's own advice. **A
budget that invites deleting the only copy of something is a worse instrument than
no budget at all**, and without that sentence the next session to hit the ceiling
would do exactly what this one nearly did.

Every green run now prints the headroom — `status 673/1500, next_step 1142/2000,
notes 713/1500` — so overflow is visible long before it fails.

---

## What landed

```
PROJECT.md             32,179 ->  3,725 chars   (status 20,000 -> 673; notes 9,060 -> 713)
HANDOFF.md             29,370 -> 15,595 chars
history/CHRONICLE.md       new -> 46,445 chars   (29,061 of it moved verbatim)
bin/check_card.rb      a budget, and a refusal that says to move rather than delete
test/check_card_test.rb    new -> 8 tests
```

- **`README.md` and `history/README.md`** describe `history/` as the kept record
  rather than as roadmap 0.1 alone, which is what it now is.
- **`test/check_card_test.rb`** drives the gate in its own process, as the gate
  command does. It holds the budget, the refusal's wording, and the job this script
  was built for in the first place — naming an unparseable colon-space rather than
  letting the dashboard render a silently blank brief.

## Deliberately not done

- **Nothing was condensed.** Moving 29,061 characters and then rewriting them would
  have made the move unverifiable, which is the one property that made it safe.
  Condensing the chronicle is a separate job with a separate risk.
- **`history/CHRONICLE.md` is outside `check_vitals.rb`'s scope**, like every other
  dated record. Its numbers were true when written and the gate exempts it for that
  reason.
- The three standing proposals are still proposals.

## Verification

- **Twelve legs green.** Suite: **600 runs, 6,510 assertions, 0 failures, 0 errors,
  0 skips**; each example suite green on its own.
- **The move is byte-verified twice**: the card's two fields reduce to 29,061
  characters that match the chronicle's body exactly, and every one of the 305 lines
  of the old `HANDOFF.md` is present in either the new one or the chronicle — zero
  unaccounted for.
- **The budget is mutation-tested**: padding `status` to 1,921 characters fails the
  gate with exit 1 and names the field, the size and the limit.
- Every number here was measured this round: the sizes by `wc` and by parsing the
  frontmatter, the churn by `git log --numstat` over the whole history, the
  duplication by sampling forty phrases, the preservation by normalising and
  comparing.
