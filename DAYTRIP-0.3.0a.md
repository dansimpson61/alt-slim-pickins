# DAYTRIP-0.3.0a — outline, for discussion

**Status: an outline only. Not opened, not a daytrip yet.** This is the
proposal dan asked for on 2026-09-16 ("outline a daytrip that would elaborate
those premises, leaving space for the decisions that they will support"). It
becomes a daytrip on his word, and it will move when he does. Nothing here is
taken.

Named for the moment it would serve: **Roses Before Dirt** — his phrase, and
the brief's own order (look, then dream, then decide). A different name is
fine; the file name follows the house convention: roadmap 0.3, Phase 0,
first jaunt.

---

## What this would be, in the daytrip genre

A daytrip takes a number from nobody and advances the project's question not at
all; both eyes go to the ground in front of the feet. That much carries over.

**What is new is the ground.** Every daytrip so far fixed what was *wrong here*
— a broken gate, a lying link, a word with no rule. This one would elaborate
what is *unproven here*: the premises [BLUESKY.md](BLUESKY.md) leaves standing.
Its deliverable is evidence, not behaviour: prototypes that may be thrown away,
measurements that may be quoted, and a decision table with the space still
open. If every stop were taken and none of the decisions ruled, the project
would be able to do exactly what it can do now — and would know eight things
about itself that it currently only suspects.

## The one argument it would earn its existence on

**The workbench and the style language are about to be decided from a design
essay rather than from ground truth — and three of the premises they rest on
are cheap to test.**

BLUESKY's two central claims are premises, not findings: that the studio's
landscape is column-blind and vertically starved, and that the language cannot
say its own theme. Each has a plausible decision hanging off it (rebuild the
workbench's real estate; give pages a style vocabulary). Deciding either one
from the essay is the 0.2 disease inverted — *deciding what nothing
demonstrated* — and this project already paid for that lesson once, when the
Builder was reshaped without knowing what it had to carry.

---

## The question

> **What would have to be true for each of BLUESKY's decisions to be made on
> evidence — and which of those things can be found in a day?**

---

## The premises it would elaborate

| # | Premise (from BLUESKY) | What is actually unknown | Decision it feeds |
|---|---|---|---|
| P1 | The landscape is column-blind and vertically starved | Which panes a writer must see *at once*, and which can be a shelf | D4, D7 |
| P2 | 64 words for *what*, 53 theme roles for *how it looks*, no way to say one in terms of the other | Whether the theme is sayable at all, and in which shape of sentence | D1 |
| P3 | The local-styling tier is filled by an undesigned escape (`tag`) | The blast radius of closing it, and which side must go first | D2 |
| P4 | `if:`, `class:`, `id:` are gate-whitelisted and read by nothing | How many such promises exist — this may be a family, not four instances | D3, D6 |
| P5 | The runtime knows who decided every value, and inference has no axiomatic grade | Whether every value *can* be attributed, and what the residue is | D5, D1 |
| P6 | The studio answers three questions (what does it look like, what did it emit, is it green) | Which fourth question a workbench for a language of intent owes | D5 |

---

## The border, drawn first

A daytrip's chief risk is that it keeps walking. This one's chief risk is the
mirror: that it *builds* the thing it was only supposed to test. So the line is
drawn before any stop is taken, and it is stricter than 0.2's.

**In scope** — anything that produces evidence and can be thrown away:

- measurements, counts, and sweeps, with their coverage stated;
- **spikes**: a scratch script, a `filter:` over the tree, a prototype that
  lives outside `lib/` and dies at the end of the day;
- drafts on paper: candidate sentences written to see whether they can be
  written, not entered into the vocabulary;
- wireframes and real-estate models, drawn rather than implemented;
- corrections to a *claim* — a record that says something untrue about the
  code, corrected — because that is a truth with a home, not a feature.

**Out of scope, and named so it is not taken by accident:**

- **No new vocabulary.** Nothing enters `lib/vocabulary/` or `words.rb`. The
  vitals may not move; a daytrip that adds a style word has decided D1 by
  fiat.
- **No restyling of the shipping studio.** Candidate layputs are drawn and
  prototyped, never committed to `studio/views` or the stylesheet.
- **No fix for the promises found in Stop 1.** The ledger is the artifact; the
  strikes and implementations are D3's business.
- **`~/dev/dashboard` stays read-only**, as the roadmap's risk register
  requires. Stop 3 *reads* its stylesheet and views as an outside corpus; it
  does not touch, port, or fix them, and it does not become their maintainer.
- **The parked wins** (W1–W3 in ROADMAP-0.3.md) stay parked. A daytrip is not
  the place to sneak one in.

**Out of scope for a second reason — they are phase work, not day work:** the
garden (Phase 1), the demand measure (Phase 2), and any kernel motion
(Phase 3). If a stop finds something that belongs there, it is logged with its
sentence and left.

---

## The stops

Five, ordered so that each one's evidence exists before the next needs it.
Every stop names what it feeds; none names an answer.

### Stop 1 — The ledger of promises with no reader  `agent` — evidence only

*Elaborates P4.* The first round's lore reduced three separate findings to one
sentence: *a name and its consumer parted company, and nothing noticed.* This
stop asks whether that sentence describes a family.

- **Method.** Sweep the repo for the pattern in its three known forms — a
  **permission** the gate grants and nothing reads (`if:`, `class:`, `id:`), a
  **claim** a record makes and no path takes (the census's "same render the
  playground will give it"), a **loader** that loads nothing
  (`PrimitiveShapes`, `PRIMITIVES == {}`) — and then look for a fourth form.
  For each hit: the promise, the file and line that makes it, and the search
  that proves no reader.
- **Artifact.** A table, in this document. Count first, fix never.
- **Feeds.** D3 (which promises get readers and which get struck), D6, and the
  shape of the style conversation — a language that cannot read `if:` has no
  conditional vocabulary to offer a style sentence.
- **Done looks like.** Every documented feature, gate whitelist entry, and
  loader in the repo appears in the table as *has a reader* or *does not*, and
  the second column's members are counted rather than estimated.

### Stop 2 — What a writer must see at once  `agent`, dan looks too — evidence only

*Elaborates P1 and P6.* The measurement says the panes are sized by fractions
rather than by intent. It does not say what the writer's intent is. That is not
knowable from the DOM.

- **Method.** Use the workbench for real work — write a page that does not
  exist yet, and load two that do — and keep a log of every moment the work is
  interrupted: a scroll to reach the palette, a tab to see the HTML, a
  round-trip to the docs to check a word's contract, a refusal read in another
  pane from the line that caused it. Then draw **three real-estate models**
  against the measured constraints (793px of height, 1130px of content, 274px
  dangerous for text): (a) one surface, modes as panes; (b) writing pane +
  artifact pane + library shelf; (c) three zones with the ground always
  visible. For each, mark which logged interruption it removes and which it
  keeps.
- **Artifact.** The interruption log; the three models drawn; a table of
  coupled pairs (source↔output, page↔its data, word↔its docs, error↔its line)
  against the models that hold them.
- **Feeds.** D4, D7, D8.
- **Honest instrument, named:** the population is two people at one screen
  size. It can rank interruptions; it cannot discover one.
- **Done looks like.** Every interruption in the log is either removed by a
  named model or explicitly kept, and the panel that survives is the one the
  evidence supports rather than the one that reads best.

### Stop 3 — Can the theme be said?  `agent` — paper only

*Elaborates P2.* The centre of gravity, and the largest stop. The claim is
that the language cannot say its own theme. The test is to try to say it.

- **Method.** Take the styling decisions that actually exist and were actually
  chosen, from **two corpora**: the studio's own nine layout partials and the
  rules they land on, and — as the closest available outside author — the
  dashboard's real views and stylesheet, designed by other hands and read-only.
  For each real decision (a pane's width, a palette's cap, a sidebar's rule,
  a measure, a density, an emphasis), attempt a sentence in each of BLUESKY's
  three candidate shapes: **variants** (`prose narrow`), a **role-modifier
  family** (`measure: wide`), and **axioms with exceptions** (`section bleed`).
  Record, for each, whether the shape can say it, what the sentence reads like,
  and — the finding that matters — **which decisions no shape can say**, and
  why.
- **Artifact.** A matrix of ~12 real decisions × 3 shapes, plus the failures
  in the language's own terms. Drafted on paper or in a scratch file; nothing
  enters `lib/vocabulary/`.
- **Feeds.** D1 (which shape, or none), D2, and D5's second half — *must a
  style role be able to say who owns it?*
- **Honest limit, named now:** both corpora were styled by people who also
  write the vocabulary. This stop can prove a shape *insufficient* (a real
  decision it cannot say). It cannot prove one *sufficient* for a stranger.
  That is the garden's job (Phase 1), and the record should say so.
- **Done looks like.** For every real decision in both corpora, either a
  sentence that says it, or a written reason no candidate shape can.

### Stop 4 — Who decided?  `agent` — throwaway spike

*Elaborates P5.* The runtime's precedence chain (page, then app, then language)
is already implemented; nothing surfaces it. This stop asks whether it can be
surfaced at all, and what is left over when it is.

- **Method.** A read-only spike that annotates one real page's rendered values
  with their owner. Two candidate seams already exist and should both be tried
  — the `filter:` argument to `SlimPickins.render` (a tree transform, no
  runtime change) and a scratch subclass of the Builder — and the cheaper one
  recorded. Run it over `examples/dashboard/views/triage.sp` (app judgements and
  inferred facts in one page) and `pages/specimen.sp` (every word).
- **Artifact.** The annotated page; the count of values attributed; **the
  residue** — the values nothing can attribute, named. The residue is the
  finding; an empty residue would be the surprising result.
- **Feeds.** D5 (does the studio show the inference, and is that its identity
  or a pane), D1.
- **Done looks like.** Every visible value on one page carries an owner or a
  named reason it cannot, and the spike is deleted or explicitly marked
  throwaway.

### Stop 5 — The cost of closing the undesigned door  `agent` — measurement

*Elaborates P3.* `tag` is a public Builder method with no contract, so a page
can write machine code today. KERNEL.md calls a page-reachable `tag` *"the one
change that could ruin the language"* and demand-gates it as Tier 0. Before the
ordering can be decided, its reach must be known.

- **Method.** Measure who uses `tag` and from where — pages, example apps,
  `lib/vocabulary/`, the studio's hatch words — and classify each use as
  *vocabulary building itself* (the partials, which are the privilege's point)
  or *an app or page reaching past the vocabulary* (the leak). Then prototype
  the refusal: a throwaway harness that permits `tag` only from
  `lib/vocabulary/` and run the gate and the suite against it, to see exactly
  what breaks.
- **Artifact.** The blast radius, in files and words; whether the studio's
  `wired_form` and portfolio's `video` survive; and the three orderings
  (close first, design first, both together) each written with what it costs
  and what it forecloses.
- **Feeds.** D2, D1.
- **Done looks like.** The three orderings exist with real costs beside them,
  and none of them has been chosen.

---

## The decisions this leaves open

The point of the daytrip. Each is written here as a decision **with its options
intact**; the daytrip's job is to make the choice cheap, not to make it.

| # | Decision | Options now on the table | Evidence that would settle it | Who rules |
|---|---|---|---|---|
| D1 | Does a page say style at all, and how? | shape (a) variants · (b) role modifiers · (c) axioms with exceptions · **none, deliberately** | Stop 3's matrix and its unsayable decisions | dan |
| D2 | Does `tag` close before a designed style language exists? | close first · design first · together · leave it and stop calling it a leak | Stop 5's blast radius and orderings | dan |
| D3 | `if:`, `class:`, `id:`: reader or strike? | implement `if:` (and find a `false` spelling) · strike the docs · keep the whitelist for a stated reason | Stop 1's ledger; `if:`'s own tests | dan |
| D4 | The workbench's real estate | one surface · writing + artifact + shelf · three zones · leave it | Stop 2's interruption log | dan |
| D5 | Does the studio show who decided? | a fourth pane · a gutter/annotation on the editor · the studio's whole identity · no | Stop 4's residue | dan |
| D6 | The census's promise | the load's render (W1) · "renders with no data", kept and labelled · something else | already measured; W1 is one line | dan |
| D7 | Responsive target | intrinsically responsive (no breakpoints) · a fixed target size · both | Stop 2's models at more than one size | dan |
| D8 | Where errors live | gutter · refusal page · both, by audience | Stop 2's log; the located `Error` already carries path/line/sentence | dan |

---

## What this daytrip would deliberately not answer

- **Whether a stranger needs the style language.** Both Stop 3 corpora share
  the vocabulary's authors. The garden (Phase 1) is the only honest test, and
  this daytrip should say so rather than imply otherwise.
- **Whether the language is fast enough to pay for any of it.** The cost
  instrument has not been run since 2026-09-16 (warm 5.65 ms, 0.26 ms/row) and
  the budget dan owes Phase 3 is still unset. A style vocabulary and an
  inference pane both spend against that budget; the daytrip measures neither.
- **Whether the studio should be two surfaces or one, as a matter of *identity*
  rather than layout.** Stop 2 can say which model removes the most
  interruptions; it cannot say what the studio is *for*. That is dan's, and it
  is the one question the ten wins left open.
- **Anything about roth, or the dashboard beyond reading it.**

---

## Risk register

| Unknown | Risk | Retired by |
|---|---|---|
| The daytrip becomes the style-language implementation | **High** | *The border, drawn first*: no new vocabulary, no shipping restyle — a prototype that enters `lib/` has broken the border |
| Stop 3 proves a shape sufficient for a self-authored corpus and it is believed | **High** | the honest limit named in Stop 3: it can prove insufficiency, not sufficiency |
| Spike code outlives the daytrip | Medium | every stop's *done looks like* names deletion or a marked throwaway |
| The premises are re-derived instead of read | Medium | every stop cites the BLUESKY section it elaborates; the first round's findings are already recorded, not re-found |
| The ledger (Stop 1) turns into a fixing round | Medium | the border: corrections only to *claims*; implementations are D3's |
| The dashboard acquires a maintainer by accident | Medium | read-only, named in the border, as 0.3's own risk register already requires |
| Eight decisions are opened and none closed | Low, and the real risk | the decision table is the deliverable; dan may close any of them the day the evidence lands, or none |

## How this stays accountable

The usual command, unchanged — and for a daytrip that ships nothing, the
stronger form of it: **the gate must be exactly as green at the end as at the
start**, and `git status` must show the day's artifacts as documents rather
than code.

```bash
ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby "$f"; done
```

If a stop's prototype has to touch `lib/` to be tested, it is tested on a
branch, or in a scratch copy, and never committed. A daytrip that closes with a
moved vital has decided something.

## Open questions for dan — the discussion

1. **Is the shape right?** Evidence only, shipping nothing — or would you
   rather one stop *lands* something so the daytrip has a floor under it?
2. **Is Stop 3 too big for a day?** It is the centre of gravity and the one
   stop that could swallow the rest. It could be split (studio corpus first,
   dashboard corpus second) or moved out to become the style language's own
   opening round.
3. **Is the dashboard acceptable as the outside corpus?** It is the closest
   thing to a hand that did not write the vocabulary, and the boundary says
   read-only — but reading its stylesheet is nearer to it than any other stop.
4. **Stops 2 and 5 are the cheap ones. Should they go first** so the day is
   worth having even if Stop 3 is deferred?
5. **The name.** *Roses Before Dirt* is from your brief; `DAYTRIP-0.3.0a` is
   the convention. Both are yours.
