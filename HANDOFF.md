# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
   - `ROADMAP-0.4.md` — 0.4's question and the definition of success that closes it
3. `PROJECT.md` — `next_step`. **Trust it over this file** if the two disagree: the
   card is updated every round and this file has lagged it by a week before. It is
   also short now, and deliberately — `bin/check_card.rb` holds it to a budget.
4. `HANDOFF.md` — this document, specifically the active next step below
5. `DAYTRIP-0.4.0a.md` through `DAYTRIP-0.4.0o.md` — one per round, each the record
   of its own. **Read `0.4.0h` first if you are picking up a thread from the audit's
   list**: it carries the prioritized list, and its *What landed* says what was done
   at the time. For the connected account of every round in order, read
   `history/CHRONICLE.md` instead of reconstructing it from fourteen files
6. `COMMUNITY_BULLETIN_BOARD.md` — the council's most recent session (currently:
   the workbench spatial frontier fixes, 2026-09-25); `.claude/skills/council/SKILL.md`
   is the reusable skill, read it before convening the council again
7. `PRIMER.md` — the Way, as it stands now
8. `DESIGN.md`, `CONTRACT.md` — the grammar and the app promise; `VOCABULARY.md`'s checkable bullets per entry are generated (`bin/generate_vocabulary.rb`)
9. `LORE.md` — what previous sessions *learned*; the last entries are this session's
10. `working-with-dan.md` — candid notes on working with him: what his questions mean, what lands, what does not. It is short, it is honest, and **it is yours to keep true** — updating it is part of the round.

**Two names changed on 2026-09-26 and older documents may still use the old ones.**
The frame a page wears is a **tin** (`.tin`, was `layout.sp`), and the design
idiom is **Spiff** (`.spiff`, was `Design Idiom` / `.design`). "Layout" survives
only where it means the visual arrangement, which is Spiff's business.

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

Roadmap 0.4 is underway as a sequence of winnable daytrip victories. **Each round's
record is its own `DAYTRIP-*.md`**, and the connected account of all of them in
order is [history/CHRONICLE.md](history/CHRONICLE.md) — which is where this file's
volet-by-volet chronicle went on 2026-10-03, verbatim.

It went because of what it cost rather than what it said. This file is the
most-churned in the repository's history — 3,807 lines, ahead of the closed
`ROADMAP-0.2.md` at 3,462 and `builder.rb` at 3,009 — and the chronicle was why:
every round appended a volet entry to a document that is step 4 of its own reading
list. It was not a duplicate of the daytrips; sampling sixteen phrases found none of
them anywhere else, so it moved rather than went.

What stays here is what a fresh session needs and cannot get elsewhere: the reading
list above, the vitals below, the active next step, the protocols and the standing
principles.

### Current Vitals (measured 2026-10-11)

Every number below that the census measures is now held by `check_vitals.rb`, so
this block cannot go stale without the gate saying so. The rows it does *not*
measure are quoted as the gate output they are.

- **Census SSOT (`bin/census.rb`)**: 62 canonical words (39 Ruby primitives + 23 `.sp` partials), 8 apps, 29 app words, 35 verified pages, 38 conventions, 35 promises, 113 stylesheet rules, 57 test files.
- **Full Suite**: 627 runs, 6,698 assertions, 0 failures, 0 errors, 0 skips in one
  process — and that includes the example apps' own suites, because both the Suite
  leg *and* the gate command below now ask `Census.test_files`. They did not agree
  until 2026-10-03: the command kept its own `Dir["test/**/*_test.rb"]` glob and ran
  547, so a session could run the gate by hand, see green, and never touch the
  example apps' suites at all. One spelling of "the suite" now, in one home.
- **Check Grammar**: `1359 sentences checked, 98 words defined, 0 problems`.
- **Check Shape**: 62 canonical words, 0 problems.
- **Check Styles**: 28 emittable classes, 59 rendering, 113 rules, 0 problems.
- **Spiff (lexicon)**: 16 entries, 84 documented declarations, 0 problems.
- **Spiff Scope**: `3 spiff(s), 15 compiled classes held to the HTML their pages render, 0 problems` — it holds compiled selectors to rendered HTML now, not zone names to sources.
- **Promises / Conventions / Card / Pages**: 35 / 38 / 7 fields / 35 pages, 0 problems.
- **Twelve gate legs** on `/status`, which re-runs them live: Grammar, Shape, Styles, Spiff, Scope, Promises, Conventions, Card, Pages, Vitals, Ruby, Suite. The Suite leg asks `Census.test_files`, so the example apps' suites are inside the gate now.
- **Byte-diff corpus digest** (`ruby bin/byte_diff.rb`): a digest over every page the gate proves. No number is written down here on purpose — `examples/lore_reader` renders a live count of `LORE.md`'s entries, so the digest moves whenever lore is left. Compare snapshots within a session, which is what `bin/byte_diff.rb`'s own header says.
- **`ruby -w -c`** is clean over `lib/`, `studio/`, `bin/`, the checkers, the suite and the example apps.
- **A trap worth knowing before you leave a note on disk**: `check_vitals` reads
  prose claims from every non-exempt document, and an untracked file at the repo
  root is not exempt. A scratch document stating a count the census disagrees with
  turns the suite red — it did, for a day, on 2026-10-04. Quote a forward-looking
  number (`` `37 conventions` ``) and the gate masks it as exhibited rather than
  asserted; `DAYTRIP-*.md` is exempt by glob, so a round's record never has this
  problem.

---

---

### The active next step — plan 0.5

**0.4 closed on 2026-10-11** (`ROADMAP-0.4.md` records each criterion and how it was
met). 0.5 is an odd roadmap, so it leads with the forward eye, and its question is
**families**: each `.sp` file a namespace of words, found nearest-first, lexically.
dan withdrew families from 0.4 on 2026-10-10 as new design that the backward look had
not asked for.

Planning 0.5, in this order:

1. **Measure 0.4.0q's premises before writing anything.** `DAYTRIP-0.4.0q.md` is
   starting material, not a plan. Its header lists what has moved: Step 0 is done, D1
   should be withdrawn, and `partial_slot_forwarding` is carried in. Its own Step 3,
   resolving the corpus through a lexical chain and reporting what would resolve
   differently, is measurement and changes no behaviour. Round after round in this
   project found a list item's premise wrong, and 2026-10-10's badge row was one more.
   Measure the mechanism, with the data the apps actually produce.
2. **Write `ROADMAP-0.5.md` first: the question and a definition of success, as 0.4's
   was.** The steward agent can draft it (Mode 1, Articulate), and dan confirms the
   question and the destination. Keep it a roadmap, not a plan.
3. **Carried into 0.5, each awaiting dan:** the `link` positional alias (0.4.0q Step
   5b), the variants proposal parts (i) and (ii), 0.4.0p's N1 and N2, and
   `partial_slot_forwarding`.

**Done before 0.5 began (2026-10-11): the corpses in `pages/` are buried.** That was
the Phase 0–2 payload, from before the apps existed. Buried: copies and stale drafts
of portfolio's card, views and nav; an old roth form; a broken script; and three
instruments that only served `pages/`. `pages/specimen.sp` stays, as the every-word
specimen. The corpus is now 35 pages, and no gate leg saw less: `check_styles`
renders the live portfolio index in their place. The commit lists everything.

**One rule, accepted by dan 2026-10-10:** no new design document until the last one
has shipped code or been withdrawn.

### Families — withdrawn from 0.4 on 2026-10-10, carried to 0.5

The section below was the active next step from 2026-10-05 to 10-09. It stays as the
record of what families is and what was ruled. **Do not start Step 1.** dan ruled
that families is 0.5's question, not 0.4's work. When 0.5 opens, re-measure the
plan's premises before building: Step 0 is done, and D1 should be withdrawn, because
kind names shadow the subject's own fields.

**By dan's instruction of 2026-10-05.** `DAYTRIP-0.4.0p.md` was **rejected** — dan's
reason, and it is the test every decision in its replacement is measured against:

> it "was requiring the author to take care of the compiler rather than the other way
> around."

`DAYTRIP-0.4.0q.md` replaces it. Read that document; it is the plan, and it carries
the rationale, the eight decisions, seven ordered steps, what it closes, what it does
not touch, and the risks. The short of it:

- **Each `.sp` file is a namespace** holding any number of `def`s; conflicts refused
  within a file, allowed across them. **Calling a word opens its family for the words
  nested under it** — lexically, from the written indentation, never from the runtime
  call stack. Then the app, then the language.
- **Each file begins `def [word], param, param`**, and a parameter's *name* declares
  its kind (`def card, subject, content`). That is what lets the sixteen-slot
  `expects` preamble go, and it makes a declared-but-unread modifier unrepresentable.
- `item` moving inside `list.sp` means **containment is the rule** — which is also the
  answer to the question dan could not hold: *why does `list` need `item`*.

**Rulings already made (2026-10-05), recorded in the document:**

| | |
|---|---|
| **D3** | `shape:` is required only where a word gathers. Four words say it; 58 say nothing. |
| **D6** | An app **may** shadow a language word; the gate reports it. |
| **D6a** | Therefore `super` — the shadowing word reaches the shadowed one along the chain. Ruby's own answer, no new punctuation. |

**Step 0 is done**: the suite is green (606 runs, 0 failures) as of 2026-10-05. **Start
at Step 1**, and do not skip Step 3 — it builds the chain and only *reports* what
would resolve differently, changing no behaviour. That step either confirms or kills
the design, and it should find exactly `editor` plus the eleven parent-bound words. If
it finds more, stop and report rather than adjusting the chain until the list is short.

**Two things in the plan are dan's and not started:** the `link` positional alias
(0.4.0o finding 1 — removing it and making `name_and_content` refuse a dropped value
are *one* change, see Step 5b), and parts (i) and (ii) of the variants proposal, which
should be their own round *after* families lands.

**A correction that belongs here**, because it is the eighth time a list item's
premise has not survived measurement in this project and the first time the reviewer
wrote the bad item: I reported `queue.sp:5` — `badge .status_variant, .status` — as a
live defect dropping the status text. **It is not.** The app's `status_variant`
returns a Symbol, so it binds to the name slot correctly, and `test/dashboard_test.rb`
covers the branch with a real `first_item`. The record is corrected in
`DAYTRIP-0.4.0q.md`. The latent hazard behind it is real but harmless today.

### Queued — docs and pedagogy, which was top priority on 2026-10-04

> **Since 2026-10-10:** the note below says this was queued behind families.
> Families has moved to 0.5, so this is queued behind 0.4's conventions work.


> **On the ordering, so nobody has to guess whether it was a slip.** Dan made docs and
> pedagogy the top priority on 2026-10-04, ahead of the field family and scoping. On
> 2026-10-05 he returned to first principles, rejected 0.4.0p, and directed the
> families plan — so families is the active work and this section is queued behind it.
> That is his sequencing, not a drift. The two are less opposed than they look:
> families *is* pedagogy, since `item` living in `list.sp` is what makes the
> `list`/`item` question answerable by looking. What this section still holds and
> families does not touch: the eleven principles, the three rulings on the conventions
> register above, and the field family.

> **Read *The route, as it went on 2026-10-04* below before acting on this
> section.** The work moved on the same day, by dan's direction: the
> principles and scoping work *is* the pedagogy work, not a detour from it.
> The audience lists asked for below were drafted and reacted to; do not
> draft them again.

**Dan made this the first discussion on 2026-10-04, ahead of the field family and
scoping, and said it must precede them.** It is not a tidying job and it is not a
documentation refresh. It starts from an observation he made about himself, which is
the most important sentence in this file:

> "I have been ill and am having trouble keeping track of all of the safeguards and
> checks that seem to be involved in crafting a very simple, convention-rich
> (inference-reliant) DSL."

**The author of the language could not hold its safeguard layer in his head.** Treat
that as data about the project, not about him. It is the strongest evidence yet for
the over-built question the dev audience below is supposed to answer.

#### What he had lost track of — this list is the syllabus

Answer these, in the documents, in language that survives being read once:

1. **`contracts` vs `promises`.** Both are registers; neither names the other in its
   own first paragraph.
2. **`expects` vs `takes:`.** `expects` is the preamble keyword at the top of a `.sp`
   partial; `takes:` is one key inside it. Nothing says so in one place.
3. **What `children` are.** The word is overloaded three ways and the documents never
   disambiguate: `children:` the contract key (what *may* nest), the indented block
   itself (what *did* nest), and `children` the word (where a partial splices the
   caller's block). `contents` is the fourth, at the tin's scale.
4. **Why or whether `list` needs `item`, and `tabs` needs `tab`.** The honest answer
   is that the dependency runs one way only and nothing says so: `item` needs `list`,
   `list` does not need `item` (`children: any`). Measured 2026-10-04 — every one of
   the 7 `shape: registers` words is held to a parent, plus `when`, `otherwise`,
   `tab` and `hidden`. **Corrected the same day: they are held for two reasons, not
   one.** Most *hand something to their parent instead of rendering on their own*
   (`column`, `total`, `band`, `line`, `level`, `when`, `otherwise`, `tab`). But
   `item` renders itself as an `<li>` (its body is `box .name, .content`) and
   `hidden` renders an input in place: those two only *mean* something inside
   their parent. `item` nonetheless declares `shape: registers`, which looks
   mis-declared. `option` is unverified. Neither sentence exists in the documents.

#### Two audiences, in his words

- **Devs** "need to understand why the code is structured as it is and need to be
  able to assess whether the thing is over-built or under-built, where there is
  duplication and where there are gaps."
- **Users** "need to hear the language sing, experience the potential of each word
  without learning the history of the development of the codebase. Users need to know
  the conventions and reliably expect what will be inferred."

The second sentence is an indictment of the current documents: they are organised by
*when things were decided* — phases, rounds, daytrips, "what drafting surfaced" — and
a user has to read the project's biography to learn its vocabulary.

#### What the discussion is actually weighing

The scale, measured 2026-10-04, so the discussion starts from facts:

- **Three registers**: `CONTRACTS` (62 words x 16 slots), `Promises::ALL` (35),
  `Conventions::ALL` (38). Plus 7 shapes and a 16-entry Spiff lexicon.
- **Twelve gate legs.**
- **3,054 lines of prose** a reader may face before writing a page: `README.md` 217,
  `PRIMER.md` 420, `DESIGN.md` 321, `KERNEL.md` 684, `CONTRACT.md` 173,
  `VOCABULARY.md` 1,239.

The open question is not "are the safeguards correct" — the gate says they are. It is
whether a language whose whole claim is *one sentence, everything is a word* can
require three registers and 3,000 lines to explain, and what the honest minimum is
for each audience. **This is where the over-built / under-built judgement gets made**,
and dan is the one making it.

**Do not start by writing documents.** Start by deciding what each audience must
hold in their head, then see which register or document has no audience at all.

#### The route, as it went on 2026-10-04

**The audience lists were drafted, and dan reacted to them.** The lists went top
down, one level of abstraction at a time, because dan asked for exactly that: each
higher level should save the reader from remembering the ones below it. As drafted,
with the corrections the day's measurements made:

- **Users:**
  0. The sentence: `word arguments`, indentation nests, everything is a word.
  1. Arguments come in ranks (name, content or data, modifiers). The draft said
     "three kinds"; PRIMER's chapter is "The six argument kinds", so this level
     needs its own reconciliation.
  2. Say it, or it is decided. The draft said "four deciders"; the honest count
     is three (the tree, the value, the app) plus one known gap (the theme owns
     61 roles no page can say).
  3. The seven shapes: what a word does with what is beneath it.
  4. The subject: kept, shifted, or walked item by item.
  5. The 62 words, looked up, not memorised.
  6. Making your own word: a `.sp` file whose first line `expects …` is its
     contract, with `takes:` one key on that line. `children` has three meanings,
     and `contents` is the tin's version of one of them.

  Never on a user's path: promises, gate legs, taxonomy tiers, any daytrip.
- **Devs:**
  - The contract is the hub. Conventions hang off its `infers:` slot and promises
    off its `modifiers:` slot. Promises are an audit of the contracts, not a part
    of the language: the first over-built finding.
  - The gate legs, each to be mapped to what it protects (not yet done).
  - Words are classified four ways (shape, speech, convention grade, taxonomy
    tier). `taxonomy.rb` is the strongest surplus candidate; its readers are
    unmeasured.
  - `gathers` and `inside` are contract slots no word sets.
  - The promise ledger holds two entries that are not modifiers.

**dan's six impressions**, given as examples, not an exhaustive list:

1. The project has almost always reached for structural solutions rather than
   patches. Keep doing that.
2. Words and contracts before conventions is the cart before the horse. A new word
   could spawn a convention that duplicates or muddles another. Examine whether
   conventions can carry the structure instead.
3. There are three ways to mint a word (Ruby, an `.sp` file, a `def`), and no good
   explanation of why some `.sp` files need a contract and others mint words
   without the paperwork. (Measured: a word with no contract is unchecked, so a
   misspelled modifier is accepted and ignored. Candidate: infer contracts from
   bodies.)
4. The difference between "the app" and "the theme" as deciders was unclear
   (answered above: the theme is a gap, not a decider).
5. `encloses`, `iterates` and `gathers` need careful thought about their semantic,
   structural and functional differences. (Measured: the five non-nouns are the
   control flow, scattered across four shapes; `empty` is shaped `says`.)
6. Exceptions point to structural opportunities: the five non-nouns, and shapes
   that are all verbs except `document`.

**Then dan changed the route.** "We are reasoning from the compiler to the
language, rather than the other way around." From that point, finding the higher
abstractions that make the language holdable *was* the pedagogy work.

1. **Principles.** The 38 conventions were regrouped under 11 principles, which
   are rules a user can hold (commit `00180d6`).
2. **Exemplar.** doc_reader became the app the principles were played against
   (`bb54e09`, recorded in `examples/doc_reader/WHAT_IF.md`).
3. **Scoping.** dan's rule, *everything available to a parent is available to its
   descendants*, became the scoping rules, written on paper and then built
   (`6b0c9f6`, recorded in `examples/doc_reader/ON_PAPER.md`).

**Rulings made that day:**

- Dots mean "it". They never borrow from further out, and reaching further is by
  name.
- A sentence that names where it lands reads its dots there.
- Paper first, then reality, one at a time.
- Broken words are expected, because they were written for a language that is
  being healed. That is improvement, not a problem.
- **doc_reader stays, as an exemplar, not just an example.** Its pages should show
  the language at its best, so it is held to a higher bar than the demo apps.
  *Revised the same day:* doc_reader is **an example**, like the others. It began
  in the studio as a proof of concept, with `data.json` as filler and no Ruby app
  behind it. Raising the bar is for every example app at once, in a session of
  its own, not for one.

**Next, in order:**

1. ~~**Make the gate green by registering doc_reader.**~~ Done. The gate proves
   its five pages against `DocReader::App.locals_for`, so what is proved is what
   is served, and its two partials through the pages that speak them. The
   playground's census holds all seven, through a provider that names each
   document and shelf field by field. The item said four pages; there were five.
   Two defects surfaced and are fixed: `Document#id` kept spaces, and a
   heading's markdown rode into `title`; headings now render through
   `Markdown.spans` and are read as text. The playground shows doc_reader as it
   shows every example: plain JSON, so the app's own labels and formats do not
   show there. Giving the playground real objects was considered and dropped
   when doc_reader became an example; it would need a channel the live render
   does not have (`/render.json` receives only JSON text). If it returns, it
   returns for every example app.
2. **Words, names and the `.sp` format: [DAYTRIP-0.4.0p.md](DAYTRIP-0.4.0p.md).**
   dan ruled on 2026-10-04: names by position (N1); interpolation holds one
   argument, fixed with the `"in #{x}"` bug (N2); each `.sp` file is a family
   of words (N3); every word file begins with `def` (N3a). The document proposes
   answers to the twelve questions those left open (C1-C12; **C1 and C2 touch
   earlier rulings**) and a six-phase plan. **Start by asking dan to confirm or
   overturn the C-questions**, then build phase 1. Do not re-measure what the
   document already measured.
3. **Rulings still owed:** the principle grouping, the three mis-grades, and the
   `format` / `format_family` / `number_text` overlap, framed with their evidence
   in `three-rulings-dan-owes.md`, which dan is holding for later.

**Still open, not yet scheduled:**

- **Elevate every example app to exemplary slim-pickins** (dan, 2026-10-04), in a
  session of its own. doc_reader is one of eight, not the model for the others.
- the contract decides what a bare name means, not `subject.has?` (17 sites, measured 2026-10-04): DAYTRIP-0.4.0p phase 4 closes it for every `.sp` word; Ruby words remain
- `actions` nests a form inside a form, which is broken on `main` in
  milestone_planner
- the interpolation splitter refuses `"in #{x}"`: DAYTRIP-0.4.0p phase 2
- an empty page subject prunes unrelated sections
- headings skip levels

### Three rulings dan owes on the conventions register

**Written by the pedagogy session (2026-10-04) and moved here verbatim on 2026-10-05**,
because it was sitting untracked at the repo root where a `git clean` would have taken
it — and because its one forward-looking count (`37 conventions`) was turning the suite
red: `check_vitals` reads prose claims from every non-exempt document, and an untracked
file at root is not exempt. The count is now quoted, which is the form the gate masks
as exhibited rather than asserted. Nothing else is changed.

These are **not** part of `DAYTRIP-0.4.0q.md` and do not block it. They belong to the
conventions register and so to the docs-and-pedagogy discussion.

#### R1. The principle grouping

On this branch, the 38 conventions are filed under 11 principles. The question is whether those 11 become the rules users are taught. As it stands:

| Principle | Entries |
|---|---|
| A value chooses its form | **10** |
| A collection walks itself… | 5 |
| A name is its own text / A word owns its element | 4 each |
| A name inflects / How deep a heading sits | 3 each |
| Page frame / Where a word sits / A gatherer collects / Nearest wins | 2 each |
| The theme owns the look | 1 |

To decide:
- **Accept the eleven as the user-facing rules?** They would go into PRIMER.
- **"A value chooses its form" holds a quarter of the register.** It could split cleanly into *a value chooses its control* (input type, step, boolean field, selected option) and *a value chooses its text* (number, time, format, alignment, badge status). That would make 12 principles. R3 also changes how many entries this principle has.
- **"What is said nearest wins" could also be the home for the scoping rule.** Then "the nearest name wins" isn't a new rule, just an existing one applied to names. Option N1(b) fits there too. With N1(a) it isn't needed.

#### R2. The three mis-grades

The grade says who decides, and it isn't hidden. The studio's Inspect panel shows it as the owner: "Language (Structure)" or "Language (Shape)". The grades are: **structural** (the tree decides), **shape** (the value's class decides), **domain** (the app decides) and **axiomatic** (the theme decides).

| Convention | Graded | What actually decides |
|---|---|---|
| `option_selected` | structural | The value: the option whose value equals the field's value is the selected one |
| `badge_status` | structural | The value: a body that reads `ok`, `warning`, … picks the variant |
| `leaf_tag` | shape | The word: `money` is always a `<span>` and `time` a `<time>` |

Here's the catch. The first two are decided by the value's *content*, not its *class*, so neither existing grade fits them exactly. The options:
- **(a) Widen "shape" to "the value decides" and move both there (my recommendation).** It's a one-line change to the definition, and it's how users already think about it.
- **(b) Add a fifth grade for the value's content.**

`leaf_tag` should be graded structural either way, so it matches its siblings `box_tag`, `card_id` and `root_class`, which are also decided by the word.

#### R3. The format overlap

What the code does is one chain, but the register lists it as three conventions:

1. **Which form?** `as:` on the page, then the app's `format_for`, then the value's shape. This is `format` (graded domain) in [builder.rb:207](lib/slim_pickins/builder.rb#L207). `format_family` (graded shape) is the last step of the same decision, in `Generator.format`.
2. **How is that form written?** Grouped digits, the currency sign, the percent scale. This is `number_text`, and `time_text` does the same job for dates.

The register also understates what happens: `format_family` says "number, percent or money", but its fallback formats dates as well (doc_reader found this).

- **(a) Two stages (my recommendation).** `format` keeps the whole decision: which form, as `as:`, then the app, then the value's shape, dates included. `format_family` folds into it. `number_text` and `time_text` stay as the "how it's written" stage. That's `37 conventions` instead of the 38 the census measures today.
- **(b) One entry** that owns the whole chain. That reads more simply, but it loses the difference between deciding a form and writing it.
- **(c) Keep three, and fix the false claim.**

Two notes on how these connect: R3(a) brings "a value chooses its form" down to 9 entries, which bears on R1's split, and R2's leaf_tag move takes it down to 8.

**Order:** N1 first, because it decides whether "nearest wins" has to carry the scoping rule. The others are independent of each other. None of this is in HANDOFF yet. Should I record this framing there, so a later session doesn't re-measure it? It would be one commit, and I wouldn't push.

### The two discussions this one precedes

Both were queued on 2026-10-03 and were *after* docs and pedagogy by dan's word.
**Scoping has since begun, as part of that work** (see *The route, as it went*): the
scoping rules are built. The namespace was to be the next step, but it is families,
which moved to 0.5 on 2026-10-10. The field family has not started.

1. **Scoping.** The word registry is global and last-compile-wins; a `Library` does
   not scope its words, and merely constructing one takes a colliding name
   (`DAYTRIP-0.4.0n.md` measured it; `editor` in the two studio UIs is the only
   collision, and the live studio is correct only because `StudioPages.ui_library`
   is not memoized). Dan's framing is **scoping variables**, wider than the
   collision. There is a live fragility here, so it should not wait forever.
2. **The field family.** `field`/`input`/`textarea` take six modifiers between them
   in no predictable pattern (`required:` on field and textarea not input,
   `placeholder:` on input not field, `readonly:` only textarea, `step:` only
   field). Four of six reasonable guesses are refused. **The rule comes first, then
   the table follows** — probably by answering what `field` infers that `input` does
   not. Do not patch the table without the rule.

**What landed before all three**, green and pushed: the promise-ledger defect and the
gate hole that hid it, the argument-order error message, `tab`'s `parents:` (which
overrode a VOCABULARY claim that the silent loss was deliberate — dan's to reverse), and one
spelling of "the suite" in the gate command. Two of the audit's five findings were
escalated rather than closed — see *Two the audit got wrong about its own costs*.

### How the 0.4.0h list ended

**Every tier of `DAYTRIP-0.4.0h.md`'s prioritized list is landed.** Tier 7 closed in
`DAYTRIP-0.4.0m.md`: the resume card went from 32,179 characters to under 4,000 and this
file from 29,370 to about 18,000, with 29,061 characters moved verbatim to
`history/CHRONICLE.md` and `bin/check_card.rb` given the budget the audit asked for.

So there is no queued item. What the audit set out eleven rounds ago is done, and
what comes next is a direction rather than a task — which by this project's own
*How roadmaps go* is dan's to set. **0.4 has spent itself on the backward eye**, and
an odd roadmap leads with the forward one: it asks something the project cannot yet
answer. That question has not been asked yet.

**Before taking anything below as a task, measure the sentence it is written in.**
Five consecutive rounds (0.4.0i to 0.4.0m) found a list item's own premises wrong,
and the pattern held every time: the counts were roughly right and what they implied
was not. Tier 7 was the sharpest case — both this file and the audit said the card
duplicated the daytrips, and sampling twenty-four phrases found none of them
anywhere else. Acting on the premise would have deleted the only copy.

0.4.0o made it six, in a new shape worth knowing: the defect was real — `action`
declared two modifiers and discarded them — but the obvious inference, that the
forwarding mechanism behind them was dead code, was false. Instrumenting
`Chain#container_value` and rendering every page the gate then held proved the mechanism **works**
and **fires nowhere**, which is a different finding and a different fix. So
measure the mechanism, not only its usage.

### Two the audit got wrong about its own costs

Three of the audit's five findings are settled: `tab` got its `parents:`, the gate
command got one spelling, and the field family became discussion 3 above. The other
two were each presented to dan as small and are not.

- **`search`'s `q:` is not a rename.** Dan approved renaming it to `query:`; the
  rename was made, broke four pages, and was reverted. `Input#evaluate` does its own
  `shown = value.nil? ? subject.fetch(name) : value`, so an `input` with no value
  goes looking for an attribute named after its *name slot*. `q:` worked only
  because its spelling matched that slot: the lookup landed on the partial's own
  declared-but-unset `q` parameter instead of walking up to the page and raising.
  Rename the modifier and the workbench's `search placeholder: "Search the library"`
  — which passes no query at all — dies with `this page has no q`. **The wire name
  cannot move either**: `params[:q]` is read by `word_graph`, `dashboard` and
  `lore_reader`. So the real question is whether `input` should fetch an attribute
  it was never told it had, which is a change to a loud-failure guarantee and so
  dan's. The abbreviation is the symptom; the coupling is the finding.
- **`link`'s second sentence shape is an alias, and it is tested on purpose.** The
  audit said it was used nowhere. It is used once —
  `test_flexible_link_with_positional_arguments` in `test/def_test.rb` asserts both
  `link "Docs", "/documentation"` and `link .doc_name, .doc_path`, deliberately, and
  its name calls the shape *flexible*. What makes it an alias rather than a feature
  is that the regular spelling says the same thing: `link .doc_name, to: .doc_path`
  renders identically, byte for byte, measured. Dan's reply — that named arguments
  may come in any order — is correct and separate: modifiers do commute, proved on
  `iframe`, `button` and `field`. This branch is not named arguments. It is two
  *positional* arguments swapping roles on the runtime class of the first, which is
  the one thing `DESIGN.md` says never happens.

**The two older proposals became discussions 1 and 2** at the top of this section,
by dan's ruling of 2026-10-03; the detail that fed them is in `DAYTRIP-0.4.0n.md`
(the registry's `editor` collision and the `ui_library` memoization trap) and in the
declined appendix relocation (12 of 62 entries live under those two headings).
`word_count`/`words_count` is done — one name, verified by rendering.

**And the smaller open calls, re-measured 2026-10-03** — dan asked what they were,
and one of the four turned out to be stale, which is the seventh time a list item's
own sentence has not survived being measured:

- **`Markdown`'s unnamed triples: gone, and the item is stale.** `markdown.rb`
  contains no `[:element, …]` literal; the only mention of that form in `lib/` is a
  comment in `node.rb` describing what the named `Node[…]` replaced, which 0.4.0l
  did. What remains in the markdown *tokenizer* is a different thing and arguably
  not a defect: `pairs << [at, at + length, close_at, close_at + length]`, four
  integer offsets in one local emphasis-matching loop. That is an algorithm's
  arithmetic, not data that travels, so naming it buys little.
- **The workbench word page's proportions** — a visual judgement on
  `studio/uis/workbench`'s word page, awaiting dan's eye rather than measurement.
- **`assets/workbench.css` is genuinely dead, and the reason is worth knowing.**
  The file exists (3,420 bytes, 2026-09-29) and the route never reads it:
  `studio/app.rb`'s `SPIFFS` maps `'workbench.css'` to
  `uis/workbench/workbench.spiff` and compiles it per request, so the generated
  stylesheet shadows the disk file of the same name. Deleting the file changes no
  render. Awaiting dan's word.
- **The two byte-identical `.tin` files**: resolved 2026-10-11. `pages/pages.tin` was
  buried with the rest of `pages/`'s copies, and portfolio's is the only one.

### Two instruments to use rather than rebuild (added in 0.4.0h)

- **`ruby bin/byte_diff.rb`** renders every page the gate proves and reduces the
  corpus to one digest; `ruby bin/byte_diff.rb /tmp/before` also writes each page
  for `diff -r`. Current digest: `d85aac01f281cb9a15e73e03` as of commit 74842bc — but see the note in that file: the digest moves when `LORE.md` does, so compare snapshots within a session rather than against a number written down. This is the
  acceptance test for any shape or refactor work — every "byte-identical" claim in
  Tier 4 was made with it. `bin/verify_pages.rb` is now requirable (its execution
  sits behind `if $PROGRAM_NAME == __FILE__`) so `PAGES` has one home.
- **`ruby -w -c <file>`** reports indentation mismatches and dead locals, in the
  interpreter the project already runs, with no gem. It found seven mismatches a
  grep for dedented `def` lines could not see, and three dead assignments nothing
  else had. The repo is clean against it today. **Wiring it as a gate leg is
  proposed and not done** — it changes the gate command, the README and the status
  page's leg count, which is dan's call. The whole implementation is one loop:

      for f in lib/**/*.rb studio/*.rb bin/*.rb check_*.rb test/*.rb; do
        ruby -w -c "$f" 2>&1 | grep -v '^Syntax OK$'
      done

### Candidates still standing, none prioritized

- **The token ground-truthing daytrip** (`DAYTRIP-0.4.0g.md`'s closing section) —
  real values for the `.spiff` collapse/balance scale (`tight`'s 26rem,
  `subordinate`'s 14rem floor), `output`'s independently governed height, and
  `--footer-height` (2.8rem is corrected but still guessed, and Spiff's generated
  CSS still carries a stale 2rem fallback).
- **Package D** below — re-read before starting; its item 1 is largely done.
- **A leftover, dan's call**: the classic UI still has no `.spiff`, so its
  presentation still pools in `slim-pickins.css`. (The byte-identical tin it was
  listed with was buried on 2026-10-11.)
- **Retire a generated file that is committed and then gated** —
  `bin/generate_vocabulary.rb` writes five bullets per `VOCABULARY.md` entry from
  `contracts.rb`, and `check_grammar`'s whole `UNGENERATED` section then verifies
  the artifact still matches its generator. Render it at read time and that check
  becomes unnecessary rather than unenforced.
- **`check_spiff_scope.rb`: delete or retarget.** No recorded catch, and its job —
  names matching names — is the narrowest slice of the layer that stays correct on
  its own. Retargeting it to assert the zone's element *reaches the render* would
  make it the gate the project actually lacks.
- **The unserved `assets/workbench.css`** — awaiting dan's word to delete.
- Whatever roadmap question dan brings. This project's convention (`README.md`,
  *How roadmaps go*) is to re-read the history and the lore before choosing a
  direction, not to assume the last session's tail is the next session's head.

### Package D — House Honesty & Integrity (Census, Registry & Doc Parity)
*Focus: Aligning every prose document and registry with the living reality of the codebase.*
**Mostly done, verified 2026-09-26 — re-measure before starting any of it.**
1. ~~**Harmonize Historical Prose Census**~~ — **done.** The truth round realigned
   `README.md`, `PRIMER.md`, `DESIGN.md`, `VOCABULARY.md` and `PROJECT.md`, and
   `grep` finds no stale "53 words / 2 apps / 10 pages" in any of them.
2. ~~**Registry Hygiene & Dead Stub Removal**~~ — **an illusion, per the
   2026-09-22 audit** (`LORE.md`): the "14 blank slots" are words that declare
   no inferences, and the "dead stubs" do not exist. `VOCABULARY.md`'s rule 1
   is *no blank slots*, and it holds.
3. ~~**Unify Row-Oriented Label Conventions (F9)**~~ — **done in
   `DAYTRIP-0.4.0a.md`**: `chart` declares `table_header`, matching
   `Builder#label_of`.

What is left of Package D is a re-measurement pass, not a list of known work.

---

## Studio Process & Verification Protocol

The studio (`studio/`, port 4580, `STUDIO_PORT` to override) is agent-managed.
- Check the port: `curl -s -m 2 http://127.0.0.1:4580/`.
- If down or after code changes, run in background:
  `cd ~/dev/alt-slim-pickins && exec ruby studio/app.rb`
- **A `.spiff`/`.sp` file edit takes effect on the next request, with no
  restart** — the compiler reads those fresh every time. A `lib/` Ruby
  code edit does not; Ruby doesn't reload changed source, so the running
  process keeps serving the old code until it's actually restarted.
- **Restarting reliably is the trap** (cost two dead-end detours in
  2026-09-25's session, `DAYTRIP-0.4.0g.md`): Puma renames its own process
  title to `puma 8.0.2 (tcp://localhost:4580) [alt-slim-pickins]`, so
  `pgrep -f "ruby studio/app.rb"` silently matches nothing, `kill`s
  nothing, and a second `ruby studio/app.rb &` then fails to bind (port
  still held) while the stale process keeps answering every request as if
  the restart worked. Kill by the listening socket's actual PID instead:
  `kill $(lsof -t -i:4580)` (or `ss -ltnp | grep 4580`), confirm the port
  is free, *then* start the new process — and verify with a direct
  `curl`/`fetch` for a string only the new code would emit, not just an
  HTTP 200, before trusting anything rendered against it.
- The checkers' status page at `/status` re-runs the gate live on every visit.

## Comprehensive Housekeeping Protocol (The RIF Loop)

You must execute every step of this loop per round, not at the end of the session:
1. **Implement & Verify**: Ensure suite is 100% green. The gate has **twelve legs**
   (the same ten `/status` runs live):
   `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby check_spiff.rb && ruby check_spiff_scope.rb && ruby bin/check_promises.rb && ruby bin/check_conventions.rb && ruby bin/check_card.rb && ruby bin/verify_pages.rb && ruby bin/census.rb && ruby -Ilib:test -e 'require "slim_pickins/census"; SlimPickins::Census.test_files.each { |f| require File.expand_path(f) }'`
2. **Commit**: Leave the tree clean. Commit with an intention-revealing message. (Push only when dan says so).
3. **Update `PROJECT.md`**: Update `status`, `last_touched`, and advance `next_step`.
4. **Validate `PROJECT.md` YAML**:
   `ruby -ryaml -e 'YAML.safe_load(File.read("PROJECT.md")[/\A---\n(.*?)\n---/m, 1], permitted_classes: [Date])'`
5. **Update the Roadmap**: Record findings, decisions, and phase completions in active `ROADMAP-*.md`.
6. **Update `working-with-dan.md`**: Record any durable lessons learned about working with dan.
7. **Record Lore**: POST what you *learned* to the ecosystem's memory:
   `curl -X POST http://127.0.0.1:4000/api/lore/alt-slim-pickins -H 'Content-Type: application/json' -d '{"message":"...", "who":"<your-name>"}'`
8. **Report to Journal**: POST a brief status update:
   `curl -X POST http://127.0.0.1:4000/api/journal -H 'Content-Type: application/json' -d '{"message":"..."}'`

## Standing principles — do not break without saying so

- One sentence: `word arguments`, indentation nests it. Extending the language
  adds vocabulary, never syntax. A dot means data; a bare word is language.
  There is no numeric literal. A name is a subject and must exist. Mechanical
  facts are free; judgements belong to the app. A line that states the
  inferable should not exist. This is a noun language — 57 of 62.
- **Every truth has one home** (the grammar in Transform, the vocabulary in
  contracts, the checkers consuming, never mirroring).
- **A rule must outlive its reason** — when a proscription blocks empowerment
  *and* better code, examine its foundation; it survives only if the
  foundation is worth more than what it blocks.
- **Word, or power?** — for every candidate surface, the language grows by
  words; the surface grows only when the answer is honestly "power."
- **The dogfood is enforced**: built-ins and app words eat the same food, by
  test, and the gatherers are re-provable as app words, byte for byte.
- **The escape-hatch number is retired.** Stop quoting it.
- **`~/dev/dashboard` must keep working, untouched.**
- **`~/dev/roth` is a separate, dormant project and has not been touched.**
