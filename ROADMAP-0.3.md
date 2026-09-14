# alt-slim-pickins — roadmap 0.3

**An odd-numbered roadmap. It leads with the forward eye.**

Status: **draft for dan — 2026-09-14.** The question is the load-bearing
sentence; the phases are the proposal, and they move when the work says so.

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
> *Walk like the chameleon: watch what is ahead, glance back at what is behind.*

Both eyes stay open; the number says which one leads. 0.1 asked whether a view
language could keep one sentence all the way down, and answered it — fifty-three
words, two apps, no grammar changes. 0.2 asked whether what was built deserved
to stand, and answered it — the grammar and the vocabulary stand, the Builder
was reshaped, and six phases of subtraction closed. 0.3 asks the next thing the
project cannot yet answer.

## The question

> **Can the language serve the ecosystem it lives in — the dashboard's own
> markdown surfaces, read-only and untouched — and pass the judgement of a page
> written by hands that did not write the vocabulary, growing the kernel only
> as those two demands force it?**

Three legs, one question — dan's ruling, verbatim (2026-09-14): *"All three, in
one question."* Each leg is already on the record, with its evidence:

### Leg 1 — the dashboard's markdown: the consumer

Phase 5 put the question to dan, and he answered it (2026-09-09, recorded
verbatim in [ROADMAP-0.2.md](ROADMAP-0.2.md)): *"Both the dashboard's md docs
and the studio's md docs."* The studio half landed — README, ROADMAP-0.2,
HANDOFF and DAYTRIP are curated guides, and the studio's `/status` re-runs the
gate live on every visit. The dashboard half was recorded as "the next
roadmap's business", with the one hard constraint named in the same sentence:
**the dashboard must keep working, untouched.** `prose` already renders
everything the dashboard's documents are made of — fences, tables, ordered
lists, indented continuations — measured against this repo's own documents in
Phase 5 and completed in Phase 6.

The demand, in the language's own words (an untagged fence, so the checker
holds it like every example in the checked documents):

```
prose markdown, .content
```

### Leg 2 — the stranger's page: the judge

The standing row in 0.2's risk register: **nobody outside the project has
written a page.** 0.1's close-out named the flank; Phase 4's exam ported a page
someone else wrote — but the port was read by its author, so the judgement is
half-passed. The language's founding claim — that a fluent speaker needs only
the grammar table — has never been tested by hands that did not write the
vocabulary.

### Leg 3 — the kernel: the floor

[KERNEL.md](KERNEL.md) (draft for dan, never built) asked the Rubinius
question: what stays Ruby because the language *cannot* say it, and what stays
because nobody has moved it yet? Its census measured 42 words in Ruby against
23 in the language, and named the missing primitive — name-directed data
access — as the thing that pins `field`, `checkbox`, `choice` and their kin to
Ruby. It owes dan two decisions: the cost budget, and whether it becomes a
roadmap of its own. This document answers the second: **it becomes the third
leg, and it grows only what the other two legs demand.**

### Why the three bind

A consumer without a judge is dogfood that flatters the author. A judge
without a consumer is a quiz. Kernel work without a demand is the 0.2 disease —
building what nothing asked for. Each leg keeps the other two honest: the
dashboard's surfaces are the real demand; the stranger's page is the real
judge; the kernel is the floor, and only a demand may lower it.

## What the re-read taught

The protocol: an odd roadmap still re-reads the history and the lore before it
chooses a direction. The pass, and what it yielded:

- **The durable asset is not the HTML** (0.1's close-out). A `.sp` file is a
  parsed, checkable description of what a page means, and 0.1 spent it entirely
  on emitting HTML. The description is what a read-only dashboard renderer
  would consume.
- **The grammar and the vocabulary stand** (0.2's verdict), and so does the
  discipline: every word has seven slots, every truth one home, nothing
  verified by a checker alone.
- **Real pages find real gaps** (Phase 4). The exam's ledger G1–G13 — hidden
  inputs, two form theories, the class scheme — was found by porting one real
  page, and every gap was settled as a word or a power, never guessed.
- **Everything must have a consumer or go** (Phase 6). Subtraction is the same
  discipline the kernel leg needs, pointed forward instead of back.
- **The kernel's cost is measured and unpaid** (KERNEL.md). The promotion pass
  took warm render from 1.37 ms to 3.55 ms — 2.6× — and the spec warns that the
  words most likely to move are the ones inside loops. The budget is a
  decision, not a surprise.
- **The council's proposals wait for consumers** (the bulletin board,
  2026-09-10). Payload forwarding in partials, subject-shifting `card`, one
  form with `formaction` buttons. Each is carried in here, and each lands only
  when a real sentence from Phase 1 or Phase 2 demands it.

## What dan asked to carry in

| Asked | Lands in |
|---|---|
| "All three, in one question" (2026-09-14) | this whole document |
| "Both the dashboard's md docs and the studio's md docs" (2026-09-09) | Leg 1; Phases 2 and 4 |
| KERNEL.md's two decisions — the cost budget, and its place | the second is answered above (Leg 3); the first is Phase 3's gate |
| The council's R3 proposals, demand-gated | Phase 3 |

## The phases

The shape of a phase here is the one 0.2 proved: a goal, a ledger of what was
found, and a *done looks like* that can be verified. Every phase ends green,
committed, and recorded — the RIF loop, no exceptions.

### Phase 0 — Choose the stranger · (dan)

The judge leg's honesty gate. The exam's weakness was named at the time: its
port was read by its author. A stranger is someone who has not written the
vocabulary, and the first question is who that can honestly be — dan writing a
page (invited since 0.2), a colleague's page, or an author handed only the
published documents ([DESIGN.md](DESIGN.md), [PRIMER.md](PRIMER.md),
[VOCABULARY.md](VOCABULARY.md), [CONTRACT.md](CONTRACT.md)) and told to build
something real. The page must be a thing somebody needs, not an exam written
for the language; an invented page measures the author's imagination, not the
language's walls.

*Done looks like:* an author named, a real page named, and the rule for what
the author may read written down — in this document, not in a conversation.

### Phase 1 — The stranger writes; the language is measured

The author works from the published documents and nothing else. Nobody smooths
the way: every refusal, crash and workaround is logged as a gap, in the
G-ledger discipline Phase 4 established — a gap names the sentence that hit
it, not the feeling of it. Nothing is fixed mid-write, because the refusals
are the data; the fixes wait for Phase 3, where they must earn their place
against the other leg's demand.

*Done looks like:* a real page renders through the language, and a ledger
names every gap with its sentence — the first genuinely unauthored measurement
the vocabulary has ever had.

### Phase 2 — Measure the dashboard's demand, untouched

Read the dashboard's markdown surfaces the way Phase 4 read `triage.slim`:
inventory `brief`, `doc` and `pattern` — what prose must render, what
navigation and links they assume, what the untouched constraint forbids. Then
a read-only rendering experiment, in this repository, consuming the
dashboard's real files: the dashboard stays untouched and working throughout,
and the experiment proves which of the stranger's gaps the ecosystem actually
demands and which the exam invented.

*Done looks like:* an inventory in the shape of Phase 4's INVENTORY.md, and a
rendering experiment that names the demand sentence by sentence.

### Phase 3 — Grow only what the demand named

The two ledgers merge. Each gap is settled as a word or a power — the standing
question — and each landing names its consumer from Phase 1 or Phase 2. The
kernel leg moves only what a real sentence demanded: name-directed access if
the ledgers say so, payload forwarding if the dashboard's actions say so, and
nothing that they did not. KERNEL.md's cost budget is dan's, set here before
the work begins, and the byte-diff harness is the acceptance test for anything
that touches rendering.

*Done looks like:* the merged ledger closed or explicitly kept open, cost
re-measured against the budget, suite and byte-diffs green.

### Phase 4 — Serve, and be judged

The dashboard's markdown renders through the language in its read-only form;
the stranger's page renders with 0 missing affordances; dan judges both. The
record names what the language still cannot say — the honest limits a forward
eye exists to find.

*Done looks like:* the question answered — yes, with the gaps logged; or no,
with the walls named. Either is a result.

## The risk register

| Risk | Severity | Retired by |
|---|---|---|
| The dashboard breaks, or is touched | highest | every round verifies it works; experiments live here and read, never write; the standing caveat carries |
| The stranger is not a stranger | high | Phase 0's rule for what the author may read, named in the record |
| Kernel work no demand named (the 0.2 disease) | high | Phase 3 lands nothing the merged ledger did not name |
| The cost budget discovered after the work (KERNEL.md's warning) | high | dan sets it before Phase 3 begins |
| The renderer drifts from the dashboard (computed-but-unwired) | medium | it reads live files and never remembers — the /status discipline |
| A checker-only pass (eleven defects passed every checker in 0.1) | standing | look, per round: load the stranger's page and the rendered surfaces |
| The privilege leak, if `tag` becomes a kernel word | high, conditional | KERNEL.md's Round 1 discipline: refused in app pages, by test, before any word depends on it |

## How this stays accountable

The machine 0.2 ran on, unchanged: `PROJECT.md`'s `next_step` always points at
the current phase; every item has a *done looks like*; verify before asserting
— counts measured, coverage stated; look, don't only check; RIF per round —
implement, verify, commit, card, lore. The three caveats stand: the
escape-hatch number stays retired, `~/dev/dashboard` keeps working untouched,
and roth's defects are roth's backlog.

## Honest limits, named now

- **The author-method is unproven.** This roadmap's first decision is who
  counts as a stranger; a judge who shares the author's brain is decoration,
  and the record will say which it was.
- **Static validation cannot prove the app's values are right** — carried from
  0.2: it removes silent drift, it does not bless numbers.
- **The dashboard may demand nothing new.** If Phase 2 finds the language
  already says everything the surfaces need, that is a finding, not a failure
  — the answer is "the language already could", and the roadmap records it and
  stops asking.
- **This document is a draft.** The question is the load-bearing sentence; the
  phases are the proposal, and they move when the work says so.
