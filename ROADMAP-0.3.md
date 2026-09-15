# alt-slim-pickins — roadmap 0.3

**An odd-numbered roadmap. It leads with the forward eye.**

Status: **draft for dan — 2026-09-14, enriched and challenged on his word.**
The question is the load-bearing sentence; the phases are the proposal, and
they move when the work says so.

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
> *Walk like the chameleon: watch what is ahead, glance back at what is behind.*

Both eyes stay open; the number says which one leads. 0.1 asked whether a view
language could keep one sentence all the way down, and answered it — fifty-three
words, two apps, no grammar changes. 0.2 asked whether what was built deserved
to stand, and answered it — the grammar and the vocabulary stand, the Builder
was reshaped, and six phases of subtraction closed. 0.3 asks the next thing the
project cannot yet answer.

## The question

> **Can the language carry real work — a garden of real apps grown in it, the
> studio won iteratively into the workbench that builds them, and the kernel
> lowered only as the work demands?**

Three legs, one question — dan's rulings of 2026-09-14, verbatim where they
matter: *"All three, in one question"*, then *"make the roadmap a bit
richer"*, then the challenges this draft answers: the studio advances by
winnable victories, the dashboard is not canonized, and the kernel's work
waits on the demand ledger.

### Leg 1 — the garden of apps: the evidence

The standing row in 0.2's risk register was: **nobody outside the project has
written a page.** One stranger's page would test the language's guessability
once; dan broadened it (2026-09-14): a variety of real apps, doing interesting
things, spun up in the language. The judge leg is plural: every app is pages
written by hands that must make the language say something real, and the
ledger discipline from Phase 4 survives — every refusal logged with the
sentence that hit it. At least one app is built by hands that did not write
the vocabulary, and the record names which; a garden that shares one brain is
decoration.

The page is where the claim lives:

```
section holdings
  empty "No holdings yet."
  each holding
    money .market_value
```

**One bed in the garden, not a sacred one: the dashboard's markdown.** dan's
audit of this draft (2026-09-14): much of the dashboard is full of kludges,
and its views were deliberately never rewritten in slim-pickins — precisely to
avoid being sidetracked by dashboard maintenance and re-engineering. Verified
against the tree the same day: slim-pickins' entire effect on `~/dev/dashboard`
is two `require`s of its pure-Ruby lib (`examples/dashboard/app.rb`,
`bin/verify_pages.rb`); nothing is ever written, no view has been touched, and
the only planned interaction is rendering its markdown docs **read-only** — a
cheap, valuable dogfood item, not yet built. The boundary is scope, not
sanctity: we do not maintain the dashboard, we do not rewrite its views, we do
not fix its kludges, and we walk normally — no eggshells. Its markdown is one
demand among the garden's many.

### Leg 2 — the studio: the workbench, won iteratively

The studio is the language's own surface, and its in-between state is
measured, not imagined (read 2026-09-14): the playground receives only the
editor's source — its own guide route names the wall: "`/render` receives only
the editor's `source`, so a page saying `prose markdown, .content` arrives with
no content to read" — so a real page with real data cannot be written or
tested there; the playground's errors are hand-built HTML strings with inline
styles, where everywhere else in the language errors speak the language's own
terms; the two Render buttons exist because one form can only target one
iframe natively — the deliberate Stimulus burr, which dan ruled stays until
its recorded resolution arrives; and the default source is a hardcoded "Hello
World". dan's method for fixing it (2026-09-14): an iterative process
accumulating **winnable victories** — each round scopes the next small win,
lands it, and moves on. No grand scoping gate; the scoping *is* the iteration.
The studio is also the first garden app: improving it is dogfood at the
sharpest, because the workbench is built in the thing it builds with.

### Leg 3 — the kernel: the floor, lowered only by demand

[KERNEL.md](KERNEL.md) asked the Rubinius question: what stays Ruby because
the language *cannot* say it, and what stays because nobody has moved it yet?
Its keystone — name-directed data access — pins `field`, `checkbox`, `choice`
and their kin to Ruby, and nothing in it has been built. The spec was
re-measured against the current tree (2026-09-14, recorded in its addendum):
the census is 42 Ruby / 22 `.sp` / 64 total; the claims that hold were
verified one by one; the floor list retires `meta` and `icon` with Phase 6;
the cost has climbed (warm render 3.55 → 4.73 ms, per row 0.15 → 0.22 ms); and
the word-graph tool the spec advertises is broken — its template was never
committed. The kernel's work waits: it grows only what the garden's and the
dashboard's sentences demand, after the studio's victories, against a budget
dan sets before the work begins.

### Why the three bind

Evidence without a workbench is friction: every garden app is built through
the studio, or the studio phase was wrong. A workbench without work is a toy:
the studio's victories are judged by the garden using them. Kernel work
without a demand is the 0.2 disease — building what nothing asked for: the
kernel moves only when a real sentence from the garden or the dashboard names
what it cannot say. Each leg keeps the other two honest.

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
- **Real pages find real gaps** (Phase 4). The exam's ledger G1–G13 was found
  by porting one real page, and every gap was settled as a word or a power,
  never guessed.
- **Everything must have a consumer or go** (Phase 6). Subtraction is the same
  discipline the kernel leg needs, pointed forward instead of back.
- **The kernel's spec holds up under re-measurement** (KERNEL.md's addendum,
  2026-09-14). Its warnings hold too: the cost is compounding, and the budget
  is a decision, not a surprise.
- **The council's proposals wait for consumers** (the bulletin board,
  2026-09-10). Payload forwarding in partials, subject-shifting `card`, one
  form with `formaction` buttons. Each is carried in here, and each lands only
  when a real sentence demands it. The council's fourth proposal — the
  dangling `design_conventions` guide — is already resolved (verified
  2026-09-14) and is recorded here so it is not re-proposed.
- **Untracked files rot into broken tools** (lore, twice). The word-graph
  tool's template was never committed and is gone; a repair embeds the
  template in the tool, and it earns its round only when a consumer asks for
  the picture.

## What dan asked to carry in

| Asked | Lands in |
|---|---|
| "All three, in one question" (2026-09-14) | the shape of this document |
| "Make the roadmap a bit richer" — a studio phase, a garden of apps in place of one stranger, the council's recommendations on the route (2026-09-14) | Legs 1–3; the phases |
| "Scoping and implementing changes to the studio as an iterative process accumulating winnable victories" (2026-09-14) | Leg 2; Phase 0 |
| "Do not canonize the dashboard — much of it is full of kludges; sp's only effect is reading its lib and the planned read-only markdown" (2026-09-14) | Leg 1; Phase 2 |
| "KERNEL.md may be dated — refresh it, and recommend whether kernel work precedes or follows the studio" (2026-09-14) | KERNEL.md's addendum; Phase 3's ordering — the recommendation is **studio first** |
| "Both the dashboard's md docs and the studio's md docs" (2026-09-09) | Leg 1's one bed; Phase 2 |
| The council's R3 proposals, demand-gated | Phase 3 |
| The Stimulus burr's resolution, when it comes | Phase 0 |

## The phases

The shape of a phase here is the one 0.2 proved: a goal, a ledger of what was
found, and a *done looks like* that can be verified. Every phase ends green,
committed, and recorded — the RIF loop, no exceptions.

### Phase 0 — The studio, won iteratively

No grand scoping gate; the iteration is the scoping. Each round picks the
next **winnable victory** from the measured menu — the playground learning to
serve real pages with real data, errors speaking the language's own terms
instead of hand-built strings, the editor growing a palette of the repo's own
pages (landed 2026-09-15, with its census — the wins below), the Stimulus resolution that obviates the second Render button (with
its *why* preserved beside the fix), the word-graph repair if a consumer asks
for the picture — scopes it to the size one round can land, dan rules the
pick, and the round lands it. Roughness that stays is named as deliberate.

*Done looks like:* a sequence of landed wins, each committed and judged, and
a studio that can be *used* — the workbench the garden phase leans on.

**Wins landed, 2026-09-15:**

- **1 — The palette, with its census** (dan's pick, same day, while the
  identities stay "strategically in flux"): the editor now offers the repo's
  own pages as starting points — thirteen of them, across portfolio,
  dashboard, roth and the studio itself — each a plain link that fills the
  editor (zero JavaScript; the load is a GET), the loaded page marked
  `aria-current` and named in the editor's heading. The palette carries the
  census as it loads: every entry wears the verdict of the same render the
  playground will give it, run live at page build, the refusal recorded in
  the language's own words with path and line. Completeness is held by test
  — a census that skips pages understates the demand. The first census:
  **13 of 13 pages refuse, and every refusal is the data wall** — no
  portfolio, no notice, no scenario, no title — because every real page
  reads its data before it reads its partials, so the missing-app-partials
  wall stays masked behind the first missing local. The next pick's ledger,
  in what the census named, in order: the data wall (the one wall all
  thirteen share), the partial wall (masked behind it), errors in the
  language's own terms (the `/render` route's refusals still display as
  hand-built strings), and one found gap carried in — `bin/verify_pages.rb`
  proves the example apps but never the studio's own views, the only corpus
  pages the gate does not render.

- **2 — The word docs grow teeth** (dan's pick, 2026-09-15; the identity
  instrument's harmony row, landing): every vocabulary entry now carries an
  *"In the wild"* section — up to three real sentences from the repo's own
  corpus, each in the language's fence with its `path:line` — and a **try-it
  pane** beside the reading: the same editor, form and outputs the
  playground uses, Visual and HTML side by side, seeded by a Try-it link on
  each example (a GET, zero JavaScript). All sixty-four words have real
  examples — held by test against VOCABULARY.md. Seeded pages carry no data:
  content sentences render live, data sentences refuse — `money .total_value`
  answers "this page has no total_value" — so the docs page now *displays*
  the data wall at the exact place the word is documented. That refusal,
  rendered through the `/render` route's hand-built error string, is the
  next pick's demand, with a consumer standing on the page.

### Phase 1 — The garden, planted

A variety of small real apps, each doing an interesting thing, each exercising
a different region of the vocabulary, each with a consumer named. dan rules
which apps; the seeds already in the repo are the candidates: the word graph
drawn in the language (KERNEL.md's spec, after the kernel rounds it names), a
lore reader over LORE.md, an exam on the Way itself, a planner with the
conditional vocabulary a real page still owes. Every author works through the
studio — the workbench pays for itself here or it was the wrong phase — and
every refusal, crash and workaround is logged as a gap with the sentence that
hit it. Nothing is fixed mid-write; the fixes wait for Phase 3, where they
earn their place against the other legs' demand. At least one app is built by
hands that did not write the vocabulary, and the record names which.

*Done looks like:* the garden renders — N apps, each named with its consumer
and its region — and the ledger names every gap with its sentence.

### Phase 2 — Measure the demand

The garden's ledger is the spine. Beside it, one inventory item, kept at its
true size: the dashboard's markdown surfaces (`brief`, `doc`, `pattern`) are
read the way Phase 4 read `triage.slim` — what prose must render, what
navigation they assume — and a read-only rendering experiment, in this
repository, consuming the dashboard's real files, proves which of the
garden's gaps the ecosystem actually demands. The dashboard stays untouched
because maintaining it is not this project's work — not because it is holy.

*Done looks like:* the merged demand, named sentence by sentence — garden
gaps and dashboard gaps side by side, each with its consumer.

### Phase 3 — Grow only what the demand named

Each gap is settled as a word or a power — the standing question — and each
landing names its consumer from Phase 1 or Phase 2. The kernel leg moves only
what a real sentence demanded: name-directed access if the ledgers say so,
payload forwarding if a real form needs keys it cannot declare, and nothing
that they did not. **The council's recommendations lie here, demand-gated**:
R3P1 (payload forwarding) if a real form demands it; R3P2 (subject-shifting
`card`) if a real page writes the same binding five times; R3P3 (`formaction`
groups) if a real action group wants one form instead of four. KERNEL.md's
cost budget is dan's, set here before the work begins — the re-measured cost
(4.73 ms warm, 0.22 ms per row) is the baseline it is set against — and the
byte-diff harness is the acceptance test for anything that touches rendering.

*Done looks like:* the merged ledger closed or explicitly kept open, cost
re-measured against the budget, suite and byte-diffs green.

### Phase 4 — Serve, and be judged

The garden renders with 0 missing affordances; the dashboard's markdown, if
the demand was real, renders read-only through the language; dan judges all
of it. The record names what the language still cannot say — the honest
limits a forward eye exists to find.

*Done looks like:* the question answered — yes, with the gaps logged; or no,
with the walls named. Either is a result.

## The risk register

| Risk | Severity | Retired by |
|---|---|---|
| The dashboard becomes a maintenance sidetrack | high | the scope boundary, stated once: sp reads its lib and may render its markdown read-only; it never edits, never rewrites views, never fixes kludges — and no phase may add one |
| The garden shares one brain | high | at least one app by hands that did not write the vocabulary, named in the record — a fleet of self-portraits is decoration |
| The studio's victories become unbounded polish | high | each win names its consumer and its size before it starts; dan rules each pick |
| The Stimulus burr is smoothed over silently | medium | its *why* is recorded beside the fix when it goes |
| Kernel work no demand named (the 0.2 disease) | high | Phase 3 lands nothing the merged ledger did not name |
| The cost budget discovered after the work (KERNEL.md's warning) | high | dan sets it before Phase 3's work begins, against the re-measured baseline |
| A checker-only pass (eleven defects passed every checker in 0.1) | standing | look, per round: load the garden's pages and the rendered surfaces |
| The privilege leak, if `tag` becomes a kernel word | high, conditional | KERNEL.md's Round 1 discipline: refused in app pages, by test, before any word depends on it |

## How this stays accountable

The machine 0.2 ran on, unchanged: `PROJECT.md`'s `next_step` always points at
the current phase; every item has a *done looks like*; verify before asserting
— counts measured, coverage stated; look, don't only check; RIF per round —
implement, verify, commit, card, lore. The caveats stand: the escape-hatch
number stays retired, and roth's defects are roth's backlog.

## Honest limits, named now

- **The garden's apps are still chosen by the people who chose the words.**
  Every coverage claim carries that until the garden includes its outside
  author — and the record says which app that was.
- **The studio's in-between state is partly deliberate.** The burr is a
  burr; a victory that cannot tell roughness from defect has failed before
  the work begins.
- **Static validation cannot prove the app's values are right** — carried
  from 0.2: it removes silent drift, it does not bless numbers.
- **The dashboard's markdown may demand nothing new.** If Phase 2 finds the
  language already says everything the surfaces need, that is a finding, not
  a failure — the answer is "the language already could", and the roadmap
  records it and stops asking.
- **This document is a draft.** The question is the load-bearing sentence; the
  phases are the proposal, and they move when the work says so.
