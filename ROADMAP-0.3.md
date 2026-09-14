# alt-slim-pickins — roadmap 0.3

**An odd-numbered roadmap. It leads with the forward eye.**

Status: **draft for dan — 2026-09-14, enriched on his word.** The question is
the load-bearing sentence; the phases are the proposal, and they move when the
work says so.

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
> *Walk like the chameleon: watch what is ahead, glance back at what is behind.*

Both eyes stay open; the number says which one leads. 0.1 asked whether a view
language could keep one sentence all the way down, and answered it — fifty-three
words, two apps, no grammar changes. 0.2 asked whether what was built deserved
to stand, and answered it — the grammar and the vocabulary stand, the Builder
was reshaped, and six phases of subtraction closed. 0.3 asks the next thing the
project cannot yet answer.

## The question

> **Can the language carry real work — the dashboard's markdown served
> untouched, a garden of real apps grown in it, and the studio made into the
> workbench that builds them — growing the kernel only as that work demands?**

Four legs, one question. The first ruling (dan, 2026-09-14, verbatim): *"All
three, in one question."* The second, the same day: make the roadmap richer —
the studio gets a phase of its own, the stranger broadens into a variety of
apps, and the council's recommendations lie on the route. Each leg is already
on the record, with its evidence:

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

### Leg 2 — the garden of apps: the evidence

The standing row in 0.2's risk register was: **nobody outside the project has
written a page.** One stranger's page would test the language's guessability
once; dan broadened it (2026-09-14): a variety of real apps, doing interesting
things, spun up in the language. The judge leg becomes plural: every app is a
page (or twenty) written by hands that must make the language say something
real, and the ledger discipline from Phase 4 survives — every refusal logged
with the sentence that hit it. At least one app is built by hands that did not
write the vocabulary; a garden that shares one brain is decoration.

The page is where the claim lives:

```
section holdings
  empty "No holdings yet."
  each holding
    money .market_value
```

### Leg 3 — the studio: the workbench

The studio is the language's own surface and its current in-between state is
measured, not imagined (read 2026-09-14): the playground receives only the
editor's source — its own guide route names the wall: "`/render` receives only
the editor's `source`, so a page saying `prose markdown, .content` arrives with
no content to read" — so a real page with real data cannot be written or tested
there; the playground's errors are hand-built HTML strings with inline styles,
where everywhere else in the language errors speak the language's own terms;
the two Render buttons exist because one form can only target one iframe
natively — the deliberate Stimulus burr, which dan ruled stays until its
recorded resolution arrives; and the default source is a hardcoded "Hello
World". The studio is also the first garden app: improving it is dogfood at
the sharpest, because the workbench is built in the thing it builds with.

### Leg 4 — the kernel: the floor

[KERNEL.md](KERNEL.md) (draft for dan, never built) asked the Rubinius
question: what stays Ruby because the language *cannot* say it, and what stays
because nobody has moved it yet? Its census measured 42 words in Ruby against
23 in the language, and named the missing primitive — name-directed data
access — as the thing that pins `field`, `checkbox`, `choice` and their kin to
Ruby. It owes dan two decisions: the cost budget, and whether it becomes a
roadmap of its own. This document answers the second: **it becomes the fourth
leg, and it grows only what the other three demand.**

### Why the four bind

A consumer without evidence is dogfood that flatters the author. Evidence
without a consumer is a quiz. A workbench without work is a toy. Kernel work
without a demand is the 0.2 disease — building what nothing asked for. Each
leg keeps the others honest: the dashboard is the real demand; the garden is
the real evidence; the studio is where both get made; the kernel is the floor,
and only a demand may lower it.

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
  when a real sentence from the garden or the dashboard demands it. The
  council's fourth proposal — the dangling `design_conventions` guide — is
  already resolved (verified 2026-09-14: gone from GUIDES, suite green) and is
  recorded here so it is not re-proposed.
- **The garden's seeds already exist in this repo** (KERNEL.md's optional
  spec, read this pass). The word graph drawn in the language itself is
  proposed there with its caveat — build it *after* the kernel rounds it
  depends on, or the port gets re-authored twice. Under this roadmap's
  demand-gated kernel, it is a candidate garden bed, not a hidden phase.

## What dan asked to carry in

| Asked | Lands in |
|---|---|
| "All three, in one question" (2026-09-14) | the shape of this document |
| "Let's make the roadmap a bit richer" — the studio gets a scoping phase, the stranger broadens into a variety of apps, the council's recommendations lie on the route (2026-09-14) | Legs 2 and 3; Phases 0–2 and 4 |
| "Both the dashboard's md docs and the studio's md docs" (2026-09-09) | Leg 1; Phases 3 and 5 |
| KERNEL.md's two decisions — the cost budget, and its place | the second is answered above (Leg 4); the first is Phase 4's gate |
| The council's R3 proposals, demand-gated | Phase 4 |
| The Stimulus burr's resolution, when it comes | Phase 1 |

## The phases

The shape of a phase here is the one 0.2 proved: a goal, a ledger of what was
found, and a *done looks like* that can be verified. Every phase ends green,
committed, and recorded — the RIF loop, no exceptions.

### Phase 0 — The studio, scoped · (dan)

The workbench leg's honesty gate: scope before polish. The studio's in-between
state is measured above; the scoping names which roughness is a burr (the two
Render buttons, kept on purpose) and which is a defect, and gives every
improvement a consumer — a real use one of the later phases will make of it.
Candidates already on the record: the playground learning to serve real pages
with real data (the guides route's own comment names the wall), errors speaking
the language's terms instead of hand-built strings, the editor growing a
palette of the repo's own pages, and the Stimulus resolution that obviates the
second Render button. dan rules the cut; nothing else is built until he has.

*Done looks like:* a scoped list of studio changes, each with its consumer and
its *done looks like*, recorded in this document — and the roughness that
stays, named as deliberate.

### Phase 1 — The studio, implemented

The scoped changes land, each verified the way the studio already verifies
itself — the studio's pages are in the checker corpora, so the page the
workbench becomes is held by the gate it displays. The Stimulus burr resolves
here exactly as its comment foretold (one form, both iframes), and the reason
it existed is recorded beside the fix — a rule must outlive its reason, and a
burr must leave its why behind when it goes.

*Done looks like:* the scoped list is closed; the studio serves it; the gate
is green with the new pages in the corpus; dan has used it to do something
real.

### Phase 2 — The garden, planted

A variety of small real apps, each doing an interesting thing, each exercising
a different region of the vocabulary, each with a consumer named. dan rules
which apps; the seeds already in the repo are the candidates: the word graph
drawn in the language (KERNEL.md's spec, after the kernel rounds it names), a
lore reader over LORE.md, an exam on the Way itself, a planner with the
conditional vocabulary a real page still owes. Every author works through the
studio — the workbench pays for itself here or it was the wrong phase — and
every refusal, crash and workaround is logged as a gap with the sentence that
hit it. Nothing is fixed mid-write; the fixes wait for Phase 4, where they
earn their place against the other legs' demand. At least one app is built by
hands that did not write the vocabulary, and the record names which.

*Done looks like:* the garden renders — N apps, each named with its consumer
and its region — and the ledger names every gap with its sentence.

### Phase 3 — The dashboard, measured

Read the dashboard's markdown surfaces the way Phase 4 of 0.2 read
`triage.slim`: inventory `brief`, `doc` and `pattern` — what prose must
render, what navigation and links they assume, what the untouched constraint
forbids. Then a read-only rendering experiment, in this repository, consuming
the dashboard's real files: the dashboard stays untouched and working
throughout, and the experiment proves which of the garden's gaps the ecosystem
actually demands and which the garden invented.

*Done looks like:* an inventory in the shape of Phase 4's INVENTORY.md, and a
rendering experiment that names the demand sentence by sentence.

### Phase 4 — Grow only what the demand named

The garden's ledger and the dashboard's merge. Each gap is settled as a word
or a power — the standing question — and each landing names its consumer from
Phase 2 or Phase 3. The kernel leg moves only what a real sentence demanded:
name-directed access if the ledgers say so, payload forwarding if the
dashboard's actions say so, and nothing that they did not. **The council's
recommendations lie here, demand-gated**: R3P1 (payload forwarding in
partials) if a real form needs hidden keys it cannot declare; R3P2
(subject-shifting `card`) if a real page writes the same binding five times;
R3P3 (`formaction` groups) if a real action group wants one form instead of
four. KERNEL.md's cost budget is dan's, set here before the work begins, and
the byte-diff harness is the acceptance test for anything that touches
rendering.

*Done looks like:* the merged ledger closed or explicitly kept open, cost
re-measured against the budget, suite and byte-diffs green.

### Phase 5 — Serve, and be judged

The dashboard's markdown renders through the language in its read-only form;
the garden renders with 0 missing affordances; dan judges both. The record
names what the language still cannot say — the honest limits a forward eye
exists to find.

*Done looks like:* the question answered — yes, with the gaps logged; or no,
with the walls named. Either is a result.

## The risk register

| Risk | Severity | Retired by |
|---|---|---|
| The dashboard breaks, or is touched | highest | every round verifies it works; experiments live here and read, never write; the standing caveat carries |
| The garden shares one brain | high | at least one app by hands that did not write the vocabulary, named in the record — a fleet of self-portraits is decoration |
| The studio phase becomes unbounded polish | high | Phase 0's scoping rule: every change names its consumer; dan rules the cut before anything is built |
| The Stimulus burr is smoothed over silently | medium | Phase 1 records the reason it existed beside the fix |
| Kernel work no demand named (the 0.2 disease) | high | Phase 4 lands nothing the merged ledger did not name |
| The cost budget discovered after the work (KERNEL.md's warning) | high | dan sets it before Phase 4's work begins |
| The renderer drifts from the dashboard (computed-but-unwired) | medium | it reads live files and never remembers — the /status discipline |
| A checker-only pass (eleven defects passed every checker in 0.1) | standing | look, per round: load the garden's pages and the rendered surfaces |
| The privilege leak, if `tag` becomes a kernel word | high, conditional | KERNEL.md's Round 1 discipline: refused in app pages, by test, before any word depends on it |

## How this stays accountable

The machine 0.2 ran on, unchanged: `PROJECT.md`'s `next_step` always points at
the current phase; every item has a *done looks like*; verify before asserting
— counts measured, coverage stated; look, don't only check; RIF per round —
implement, verify, commit, card, lore. The three caveats stand: the
escape-hatch number stays retired, `~/dev/dashboard` keeps working untouched,
and roth's defects are roth's backlog.

## Honest limits, named now

- **The garden's apps are still chosen by the people who chose the words.**
  Every coverage claim carries that until the garden includes its outside
  author — and the record says which app that was.
- **The studio's in-between state is partly deliberate.** The burr is a
  burr; Phase 0's scoping names which roughness is which, and a scoping that
  cannot tell them apart has failed before the work begins.
- **Static validation cannot prove the app's values are right** — carried
  from 0.2: it removes silent drift, it does not bless numbers.
- **The dashboard may demand nothing new.** If Phase 3 finds the language
  already says everything the surfaces need, that is a finding, not a failure
  — the answer is "the language already could", and the roadmap records it and
  stops asking.
- **This document is a draft.** The question is the load-bearing sentence; the
  phases are the proposal, and they move when the work says so.
