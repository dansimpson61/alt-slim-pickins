# alt-slim-pickins — roadmap 0.2

**An even-numbered roadmap. It leads with the backward eye.**

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
> *Walk like the chameleon: watch what is ahead, glance back at what is behind.*

Both eyes stay open; the number says which one leads. 0.1 asked whether a view
language could keep one sentence all the way down, and answered it — fifty
words, two apps, no grammar changes. An even roadmap does not ask a new
question. It asks whether what was built **deserves to stand**, and studies the
DSL and the code beneath it as objects in their own right, to the standard of
excellent Ruby. It still has to know where the project is going, or the study
is decoration.

This document is the protocol executed. Its three movements are below, then
the verdict, then the phases the verdict demands.

## The question

> **Does what 0.1 built deserve to stand — and what must the runtime be
> reshaped into, to carry what comes next?**

## The verdict, in one paragraph

The grammar deserves to stand, and so does the vocabulary, with two renames and
an instrument it never had. The Builder does **not** deserve to stand as it is:
it is a small structure supporting a massive mass, and two independent
critiques — our own lore and the Gemini paper in `Tight Coupling in Ruby
DSLs.md` — diagnose the same disease in the same words. The documents
half-stand: two of them drift today. The test posture stands, and it is the
one thing that must keep growing faster than the language. And the one number
this project quoted most — the escape hatch — was measuring the wrong thing,
and is retired here, in writing, so it stops being quoted.

---

## Movement 1 — what was claimed, what was measured

0.1 closed with claims. This movement checks which of them the documents
actually record. Every number below was re-measured on 2026-09-01, not
re-quoted from lore.

| Claimed at 0.1's close | Measured today |
|---|---|
| fifty words | **50** — `Builder::WORDS`, and the checker holds them |
| 133 tests | **142 tests, 550 assertions, 0 failures** |
| 632 sentences, 0 problems | **632 sentences, 0 problems** — checked, not asserted |
| 65 style rules | **65 rules, 0 problems** |
| the grammar never changed across eight phases | true — DESIGN.md v0.3 is the transform |
| escape hatch: 1 use in 356 sentences | true, and **retired** — see below |
| every word exercised | 49 of 50 appear in `.sp` files; `meta` lives only in doc examples |
| the checkers hold the docs to the code | true — and a checker has blind spots by design |

Three of those rows deserve the argument the others do not.

**The escape hatch number is retired.** It counted the distance between what a
page needs and where its data is, never the vocabulary's coverage. It moved
from 1-in-284 to 9-in-324 to 1-in-356 as *rendering* moved, not as the
language grew. It is not quoted again in this roadmap, and it should not be
quoted again anywhere.

**The checkers have blind spots, and knowing them is the discipline.** Eleven
visual defects passed both checkers in 0.1, because a checker verifies
relationships between artefacts it can read — it cannot verify that a rule is
any good, that a sprite the rule references exists, or that a code path anyone
believes in is taken. Nor are happy-path tests enough: two crashes lived
behind 133 green tests because every one rendered a page somebody wrote on
purpose. Checking and looking each cover what the other structurally cannot,
and 0.2 keeps both.

**The documents drift where their examples stop being checkable.** Two drift
defects exist *today*, found during this study:

- `VOCABULARY.md`'s *Still open* section lists three questions — the `?` case,
  `chart` as a guess, and the app contract — that 0.1's own close settled. The
  section answers itself while still claiming to be open.
- `history/README.md` says "Roadmap 0.2's Phase 7 proposes cutting them" —
  pointing at a phase of a roadmap that was written, deleted, and never existed
  in this form. A record that references a deleted plan is a record that lies.

Both are the same class of defect as roth's: a thing was computed correctly and
never connected to the thing that changed.

## Movement 2 — what the history and lore taught

Eight phases, each recorded in `history/`, each leaving findings in `LORE.md`
that were written down and then rarely re-read. Re-read now, the through-line
is this:

**Every proscription removed an escape, and forced a discovery.** No `div`, so
components had to be words. No syntax, so extension had to be vocabulary. No
numeric literal, so figures had to belong to the app. Nothing was ever added to
get around one, and the language is small because of it.

**Inference is the bet, and it holds where it can.** Mechanical facts
derivable from a value's *shape* are free — type, value, input name, alignment.
Facts encoding a human judgement belong to the app — `label_for`,
`format_for` — and the app contract is one sentence plus two optional methods.
Phase 0 measured it on a real page; Phase 1 named it; Phase 2 met the same
shape a second time and generalised it.

**The language's honest register was discovered last.** The part-of-speech
sweep found 43 of 50 words are common nouns, 41 singular, and the seven
non-nouns are almost exactly the control flow. A sentence is head noun plus
specifier — the register of a label, not of prose. That is why pages read the
way they do, and nobody designed it. Two words broke it: `check` and `select`
were verbs, imperatives that misdescribed what they render — Phase 1 renamed
them `checkbox` and `choice`.

**What words do alone was tested thoroughly; what words do when they meet was
not.** Two crashes in five minutes of adversarial probing, both Ruby errors
rather than language errors: a gatherer reached through `when` destroyed the
collection of the one it was nested inside, and `each item` bound a name the
language already owned. The fix was not more tests of pages someone wrote on
purpose — it was `test/combination_test.rb`, which crosses the words that hold
state against each other. That discipline is standing, and 0.2 extends it
rather than replacing it.

**The durable asset is not the HTML.** Closing 0.1 clarified what was actually
built: a `.sp` file is a parsed, checkable description of what a page means, in
fifty known words, with every subject resolvable. 0.1 spent that asset entirely
on emitting HTML. The tree could answer what it demands *before* it is served —
which would have turned roth's eleven-month silent rename into a boot error.
This roadmap's payload is that sentence.

**The port's lesson was about seams, not views.** roth's problem was almost
never a missing calculation; it was a calculation written correctly and never
connected — taxable Social Security computed and dropped, IRMAA computed and
invisible, `to_json` built and uncalled. And 0.1 caught the same disease in
itself twice: the validation seam shipped half-wired, and the escape-hatch
number measured the wrong thing for three rounds before anyone noticed. The
class of bug this project keeps meeting is *computed but unwired*, and a
roadmap that does not name it will meet it again.

## Movement 3 — the study: the DSL and the code as objects

### The grammar: stands, unchanged

One sentence — `word arguments`, indentation nests it — and one resolution
rule, the innermost subject. Eight phases and fifty words never asked it to
change. The morphology rule — a dot means data, a bare word is language — makes
the language guessable without a phrasebook. The rule of government — a name is
interpreted by the word to its left, a word by the word it is nested under —
keeps every sentence readable in isolation. `Transform` is 135 lines and
deliberately thin; the reserved-word routing (`when`) is the only concession to
the host language, absorbed in exactly the right place.

The verdict on the grammar is not merely "keep it". It is that the grammar
**is no longer the risk**. The vocabulary is.

### The vocabulary: stands, with two renames and an instrument

Fifty words, mean 8.1 lines of implementation across the 48 with ordinary
bodies (`table` the longest at 46), every one drafted against a real page and
held by `check_grammar.rb`. The seven structural shapes
(encloses, presents, says, registers, document, gathers, iterates) cover all
fifty, and a word fitting no shape would now have to argue for itself in
writing.

But it was reviewed for consistency for eight phases — defined, used, styled —
and **never reviewed as language** until the last day of 0.1. Consistency
checking structurally cannot find a word that is consistent and wrong. One
sweep found two. The fix is not the renames alone; it is making the sweep an
instrument, so the next wrong word is found by a checker instead of by a
question.

### The Builder: does not stand as it is

`builder.rb` is **867 lines — 50% of the library**. It holds **16 instance
variables**; re-measured, **25 of the 50 words** reach into them directly:

```text
page(@out @head @icons_used)  stylesheet(@head)  meta(@head)  script(@deferred)
footer(@out)  contents(@contents)  section(@level)  title(@level)
each(@bindings @chain)  empty(@suppressed)  table(@columns @chain)
column(@columns)  total(@columns)  icon(@icons_used)  chart(@series @levels)
level(@levels)  choose(@branches)  when(@branches)  otherwise(@branches)
form(@in_form)  group(@in_form)  check(@out)  select(@selected)  option(@selected)
button(@in_form)
```

Names as measured at 0.2's opening; Phase 1 renamed `check` → `checkbox` and
`select` → `choice`.

Sorted by purpose, those sixteen are **three ideas implemented about twelve
times**: a place for a word's children to register, a flag for the situation
the word is in, and a chain of subjects. The sharpest instance, re-verified by
reading rather than recalled:

**Four copies of one gathering mechanism.** `table`/`column`/`total`,
`chart`/`band`/`line`/`level`, `choose`/`when`/`otherwise`, and
`select`/`option` each implement *collect the registering children, then act on
them*. The first three each have their own collection ivar and their own
near-identical guard (`registering!`, `charting!`, `branching!`). The fourth
has **no guard at all** — `option` renders silently outside a `select` — and it
clears rather than restores, so a nested `select` destroys the outer one's
selection. The save-and-restore discipline the other three now follow was
learned one crash at a time; the fourth copy has not yet had its crash.

**Guards fire at the wrong moment.** `when .x` outside a `choose` says *"this
page has no x"* — because Ruby evaluates the argument before the method body
can run, so the guard arrives after the failure it was meant to prevent. The
error names the wrong problem, on the one construct with no real page behind
it.

**The small warts are evidence, not decoration.** `check` writes `@out`
directly where every other word goes through the escaping helpers. The
portfolio app sets `Library`'s `@words` with `instance_variable_set`, because
`Library.from` cannot take words — an app reaching into our ivars is exactly
the coupling we accuse the Builder of.

### The critique from the Tight Coupling paper

The paper in `Tight Coupling in Ruby DSLs.md` was written against this actual
Builder. Its diagnosis, in its own words: **"a small structure supporting a
massive, entangled mass."** The Builder is at once the parser, the state
machine, the HTML formatter, the presentation-inference engine, and the entire
component library. The call site is beautiful and the cost is architectural
rigidity.

The paper offers two stages, and the distinction is the structural substance
0.2 needs:

- **Component objects.** Each heavy concept — `table`, `chart`, `choose`,
  `choice` — becomes its own object owning its state and lifecycle; the Builder
  becomes a router. This *isolates* the complexity. It stays coupled to HTML.
- **An AST pipeline.** Parse to a tree, apply filters to the tree, generate
  from the tree. This *decouples*: the tree can be introspected, validated
  before anything is emitted, and pointed at a second generator later.

Its own summary sentence is the load-bearing one: **"Component isolation tames
immediate procedural complexity, but pipeline decoupling unlocks long-term
architectural leverage."** 0.2 does the first for certain. The second is the
one real architecture decision of the release, and the payload below is what it
buys — so the decision is taken where the payload is, not before.

### The mirror from roth

`roth/ROTH_STUDY.md` was a study of a different project, and it is in this
roadmap for one paragraph: **roth almost never lacks a calculation, it lacks a
connection** — subsystems complete and unreferenced, a validation seam shipped
half-wired, a rename abandoned silently. Every one of those failure modes has a
local echo here: the tree described but never asked, the checkers' blind
spots, the two drifting documents. The roth study is not our backlog; it is
our cautionary mirror, and the phases below are built so that a future reader
of this project cannot write the same sentence about it.

## Where the project is going

The forward eye stays open throughout, or the study is decoration. What the
runtime must next carry:

1. **A second port, aimed at the untested flank.** 0.1's close-out names it:
   conditional and bespoke UI — `choose`/`when`/`otherwise` and `if:` have no
   real page behind them — plus a page that navigates, and a page written by
   somebody who did not write the vocabulary. `~/dev/dashboard` is the
   subject: its 23 views carry 176 branches, and lore's measurement found 81%
   of them are exactly the two cases the language dissolves (`empty`, `if:`).
   It has already invented seven app words of its own, independently — two
   experiments converged on one idea without coordinating.
2. **The Slim-Pickins Way must be replaced.** The current PRIMER describes the
   helper layer this language is not: a grammar embedded in Slim, `ui_card`
   helpers, `sp-` classes written by humans. It is no longer a useful guide to
   the language as built, nor to what we are trying to build. Writing the
   replacement is not documentation work bolted onto the release — it is the
   orienting exercise, the study of the language as language, written down.
3. **The link routing question is still open**, and Phase 4 settles it the
   only way this project settles anything: against a real page that asks.
4. **Dogfood.** See the section below — it is not a footnote, it is a phase.

### What dan asked to carry in

| Asked | Lands in |
|---|---|
| Replace the Slim-Pickins Way document; let it orient the ethos | **Phase 0** |
| Study the critique embedded in the `roth/` docs | the study above, and **Phase 3** |
| The Builder's bloat, plus the Tight Coupling paper's structural substance | the study above, and **Phase 2** |
| Ataovy dian-tana — the protocol itself | this whole document |
| Single source of truth and excellent OOP, here and everywhere | the constraints above, and Phases 1, 2 and 3 |
| Dogfood opportunities, and choices that prepare them | the section below, and **Phase 5** |

## The dogfood question

What can this project use its own language for, and what choices make that
likely and fruitful?

**The opportunities, measured rather than imagined:**

- **This project's own documents are content-heavy pages the language cannot
  yet render.** Across `README.md`, `LORE.md`, `DESIGN.md`, `VOCABULARY.md`,
  `CONTRACT.md`, `HANDOFF.md`, `history/` and `roth/`: **122 fenced code
  blocks, 172 table rows, 33 ordered-list lines, 306 headings**. `prose` renders
  paragraphs, headings, unordered lists, blockquotes and inline code — and
  none of fences, tables, or ordered lists. The sharpest tension lore named
  ("a doc viewer that cannot render a code fence is useless") has a real
  consumer now: this repo's own pages.
- **The checkers already produce language-shaped output.** 632 sentences, 0
  problems; 65 rules, 0 problems. A status page is a page.
- **The dashboard** is the sibling that runs all of `~/dev` and has already
  spoken this language's app-word idea on its own. Its markdown surfaces
  (brief, doc, pattern) are prose consumers. It is also the one surface that
  must keep working, untouched — so the dogfood form there is a read-only
  rendering experiment, never an edit.
- **The Way document itself** will be a markdown document whose examples are
  checked sentences. It is half a page before it is written.

**The choices that prepare dogfood** — each is a phase below, named here so
the connection is visible:

1. `prose` grows only what those measured docs use — fences, tables, ordered
   lists — and stays safe by construction. No general markdown engine; that
   would be the feature creep 0.2 refuses.
2. Navigation and routing get settled in Phase 4, because a multi-page doc
   site is the first real navigation this project has ever needed.
3. The app contract stays nearly free, because dogfood dies the day an app
   must write ceremony to be renderable.
4. Static validation (Phase 3) makes dogfood *safe*: a studio page that
   renders this repo's docs cannot silently drift from them the way roth
   drifted from its inputs.

## The proscription that forces it

Each of 0.1's proscriptions removed an escape and forced a discovery. 0.2's
adds one, and like the others it looks like a restriction and pays like a
tool:

> ### A page may not render until the app has been proved able to answer it.

It removes an ability the language currently has — **the ability to fail
late** — and it is exactly the ability roth used to go eleven months with a
silently dropped income source. Phase 3 builds it. Everything before it exists
so that it is built on a runtime worth building on.

## Three constraints on every phase

Not phases; conditions on all of them.

**1. Every truth has one home.** Single source of truth, stated as a rule
rather than a hope. The grammar is implemented once, in `Transform`, and the
checker consumes it rather than mirroring it. A word's contract is declared
once, as an object, and both the checker and `VOCABULARY.md` are derived from
it. The vocabulary registry is `Library`, and nothing else lists it. The
evidence that this is not free was measured at 0.2's opening: the checker and
the transform disagreed — the transform accepted `level 1000000.0` and the
checker refused it, so the no-numeric-literal invariant was enforced by
nothing except the checker. Phase 1 closed that seam: the transform refuses
now, and the checker holds no grammar of its own. Every phase ends by
counting the copies of each truth it touched, and the number may only fall. This is the Ode's *give every
truth one home* made operational, and it is the same medicine as the OOP the
Builder phase prescribes: objects with one job, dependencies injected, nothing
re-implemented by hand.

**2. It must stay lovely to read.** The vitals below are the baseline,
re-measured 2026-09-01 across every `.sp` file in `pages/` and `examples/`
(356 sentences). A vital that moves is not a failure — it is a conversation.
`check_shape.rb` (Phase 1) prints them and fails only on the shape rows.

| vital | today | what a move would mean |
|---|---|---|
| distinct modifiers used in real pages | **8** (`alt as columns from method over step to`) | configuration creeping in where words should be |
| mean arguments per sentence | **1.21** | sentences being configured rather than said |
| longest sentence | **3 arguments** | a word doing more than one job |
| deepest nesting | **8 levels** | structure the vocabulary is not carrying |
| words used in real pages | **49 of 50** (`meta` only in doc examples) | dead vocabulary, which is kruft |
| nouns among the fifty | **45** | the register of a label, not prose |
| words whose English misdescribes them | **0** — `check` and `select` renamed to `checkbox` and `choice` in Phase 1 | a verb arriving unnoticed |

**3. A rule must outlive its reason.** dan's principle, now the standing one.
Most of this project's rules were descriptive observations of the code or the
language at some past moment. When a rule blocks something that empowers devs
and users *and* makes the code better, the rule is examined, not obeyed — the
question is whether its foundation is worth more than what it blocks. Phase 3
applied it to the small-hatch proscription: its foundation was keeping the
runtime private; the value that outweighed it was the vocabulary itself
proving the surface. The hatch opened, words.rb and the components were
rewritten on it, and the purity test now enforces that built-ins and app
words eat the same food.

**4. Nothing is verified by a checker alone.** A checker can prove a class has
a rule; it cannot prove the rule is good. Every phase ends by rendering and
*looking*, by measuring what it claims, and by running the whole gate:

```text
ruby check_grammar.rb && ruby check_styles.rb && for f in test/*_test.rb; do ruby $f; done
```

(142 tests, 632 sentences, 65 rules — all green at this document's writing.)

## The risk register

| Unknown | Risk | Retired by |
|---|---|---|
| The Builder refactor breaks the two apps or the suite | **High** | Phase 2, on green, one word-family at a time, with byte-diffs of every page before and after |
| Static validation refuses apps that render fine today | **High** | Phase 3's two stages — report-only first, gate second — measured on both apps before the gate exists |
| The Way replacement drifts like its predecessor | Medium | Phase 0 writes it under the checker convention from day one: every example an untagged fence |
| The checker rewrite silently loosens what the old checker refused | Medium | the sentences it once refused are pinned as golden failures before the first deletion, and stay red through the phase |
| `prose` grows into a markdown engine | Medium | Phase 5 grows only what the measured docs use; safe-by-construction survives |
| The port becomes the syllabus again | Medium | Phase 4 is one phase, judged, not the organising principle — the lesson of the deleted draft is written above |
| Nobody outside the project has written a page | standing | Phase 4 ports pages written by someone else; dan's own page is invited in Phase 0 and Phase 5 |

---

## The phases

Ordered foundations first, payload next, exam, dogfood, subtraction — the
lesson the deleted 0.2 draft taught by getting it backwards. Nothing here was
invented for this roadmap; every phase is the answer to a finding named above.

### Phase 0 — The Way, rewritten  ✅ complete (2026-09-01)

The backward eye's deliverable in prose: the study of the language as
language, written down as the replacement for the Slim-Pickins Way.

- **Write it** `agent` — one document in this repo, describing the language as
  it stands: the one-sentence grammar, the morphology (a dot means data), the
  rule of government, the app contract and its three levels of precedence, the
  inference rule (mechanical facts free, judgements asked), the noun register,
  how a word is added (vocabulary, never syntax), how an app adds its own
  words, the class-name shapes, and the ethos to carry forward: *grow the
  language, never work around it; a line that states the inferable should not
  exist; a condition is named, not written; the word carries the presentation,
  the argument carries the domain.*
- **Hold it** `agent` — every example is an untagged fence, so
  `check_grammar.rb` holds the new document the way it holds DESIGN.md, and
  every quantitative claim is measured before it is written. This roadmap is
  held the same way, from the day it is written:

```
page "The way, served"
  prose .body
```
- **Decide its address** `dan` — whether `~/dev/slim-pickins`'s PRIMER is
  replaced by a pointer to this document, left as the helper layer's own tour,
  or copied. The machine-wide required-reading list points at the old path, so
  this decision ripples; it is yours, not mine.

*Done looks like:* the document exists in this repo, passes the checker, and
the old PRIMER's fate is recorded.

### Phase 1 — A word is reviewable  ✅ complete (2026-09-01)

The part-of-speech sweep becomes an instrument instead of an afternoon — and
the checker stops being a second copy of the grammar it checks.

- **The checker consumes the grammar** `agent` — `check_grammar.rb` compiles
  each block through `Transform` and reports its errors, and its private
  `KINDS`, `split_args` and `WORD` copies are deleted. The no-numeric-literal
  refusal moves into `Transform`, so checker and runtime share one grammar and
  the divergence measured today — the transform accepts `level 1000000.0`,
  the checker refuses it — becomes impossible. The sentences the old checker
  refused are pinned as golden failures first, so the rewrite cannot silently
  loosen what it once caught. The `UNEXEMPLIFIED` check scopes to the corpus
  actually given, and the app-word registry is `Library` itself rather than a
  `module *Words` convention scan.
- **The seven slots become objects** `agent` — a word's name, content,
  modifiers and children stop being prose in `VOCABULARY.md` and become
  declarations the code reads. The checker then holds every sentence to its
  word's signature and its nesting government, so `when` outside `choose` and
  `option` outside `choice` fail statically, in docs and pages, before any
  render — and `VOCABULARY.md`'s slots are generated from the declarations
  rather than written by hand. These are the same objects Phase 3's gate runs
  on.
- **The third checker** `agent` — `check_shape.rb` holds each word to its
  declared part of speech and its declared shape, prints the vitals table, and
  fails only on violations — so no third verb can arrive unnoticed. A word
  that fits no shape must be argued for in writing, in the checker's own
  output.
- **The two renames** `dan` `agent` — decided and done (dan, 2026-09-01):
  `check` → `checkbox`, `select` → `choice`, whose children `option` already
  read as the noun they are. The sweep touched the vocabulary entries, the
  builder methods, the stylesheet rules, the pages, the tests, and every
  document the checkers hold — and the `formerly` note in VOCABULARY.md lets
  the records in history/ keep speaking the old names.
- **Doc hygiene** `agent` — `VOCABULARY.md`'s *Still open* section rewritten
  to the settled truth, and `history/README.md`'s reference to a deleted
  roadmap corrected, so no future reader follows a pointer into nothing.

*Done looks like:* three checkers green; `check_grammar.rb` holds no grammar
of its own; the seven slots live once, as objects; the two verb-words renamed
or explicitly excused by dan; the vitals table printed by a checker.

### Phase 2 — The Builder, un-god-objected  ✅ complete (2026-09-01)

The Tight Coupling paper's first stage, done for certain: the heavy concepts
become objects that own their state, and the Builder becomes what its name
says.

- **One gathering mechanism, four users** `agent` — `table`, `chart`,
  `choose` and `choice` become component objects sharing one
  collect-and-restore mechanism, each owning its collection and its guards.
  `option` gains the guard the other three have; `when` guards *before* its
  argument can be evaluated, so a misused `when` names the misuse rather than
  the page; every gatherer saves and restores, including the one that never
  has. `@columns`, `@series`, `@levels`, `@branches`, `@selected` leave
  `Builder`.
- **The warts** `agent` — `checkbox` returns to the escaping helpers; `Library.from`
  learns to take `words:`, and the portfolio app stops reaching into our ivars.
- **The one architecture decision** `dan` `agent` — the paper's second stage,
  the tree pipeline, argued honestly: it buys introspection, static
  validation, and a second generator someday; it costs the transform's output,
  the escaping plumbing, and the hatch surface. The criterion is Phase 3's
  payload, so the decision is recorded here and built there.

  **Recorded 2026-09-01, argued from the work above.** The pipeline has
  already half-arrived, and it arrived by extraction rather than by plan:
  `Transform.tree` is the parse stage, the contracts are the grammar the
  filters hold against, and the checkers are the filters. What remains of the
  paper's offer is a choice about the *generator* — and the honest reading is
  that nothing in the next payload needs a new one.

  - The introspection payoff is already spent: three checkers walk the tree.
  - Phase 3's payload — *a page may not render until the app has been proved
    able to answer it* — is a filter over the tree the parse stage already
    produces. It needs resolution against the page's own locals, which exist
    at render time; it does not need the HTML generator rewritten, and it
    does not need the compiled Ruby abandoned. The generator stays; the gate
    walks the tree before the generator runs.
  - The second generator (JSON, or anything else) has no consumer. Building
    it now would be the wrong-abstraction tax the Ode charges for imagined
    futures: a name to learn, an indirection to follow, no rent.

  **The decision: adopt the pipeline as parse → validate → generate, with the
  generator staying exactly what it is.** The tree is the middle stage; the
  checkers and Phase 3's gate are its filters; the compiled-Ruby emitter
  remains the last stage until a real second target asks for its own. dan may
  override; this is the recommendation the evidence supports.

*Done looks like:* gatherers live in their own files; `builder.rb` is a router
and the presentation words; each new object reviewed as Ruby rather than
machinery — one responsibility, its dependencies passed in, nobody reaching
into another object's ivars; byte-diffs of both apps' pages unchanged except
the deliberate renames; the gathering-copy count is **1**, measured;
`test/combination_test.rb` extended with the crash cases and green.

### Phase 3 — Spend the description  ✅ complete (2026-09-01)

The payload. 0.1 built a parsed, checkable description of what a page means and
spent it only on HTML. This phase spends it on the one question that matters
before a byte is served.

**What the study above asked for, and what has already landed** — the runtime
output model was re-decided with dan, in two named axes, after the Phase 2
record conflated them:

1. *Compile-time pipeline* (parse → validate → generate): unchanged, as
   recorded — the generator stays; no second target exists.
2. *Runtime output model* (strings-and-side-effects vs nodes-and-assembly):
   **decided for nodes** — words build semantic nodes (`[:word, attrs,
   children]`), the Generator interprets them as HTML, suppression became
   pruning, and `SlimPickins.evaluate` exposes the tree a second interpreter
   would walk — unbuilt, because none has asked.

Round by round: (1) the node runtime, eleven pages byte-identical against the
old runtime; (2) the vocabulary left the Builder — `words.rb`, written with
the same surface apps get, Builder 747 → 263 lines; (3) `words_test.rb` pins
that contracts, Words and the Generator agree on all fifty; (4) dan's
app-word examples were worked, found two real defects (a nil child crashed
the generator; nested `tag` calls double-rendered), and the hatch became six
methods — `token`, `html`, `element`, `tag`, `children`, `arguments` —
`element` the value-form for nesting. (5) the lineno seam — the payload's
first sub-task. The transform wraps every compiled sentence in `with_line`,
the Builder keeps the sentence's line on a stack while it evaluates, and a
runtime error is located *where it is raised*, before any stack unwinds:
path, line, and the sentence itself, in the same voice as a syntax error.
`test/lineno_test.rb` pins it through nesting, loops, guards, re-rendered
choose branches, partials and the layout; the eleven pages stay
byte-identical. (6) the report half of the payload — `bin/verify_pages.rb`
evaluates all eleven pages (the repo's, both apps' views) against the data
the app would serve, and reports: a page the app cannot answer names the
page, the attribute, the line and the sentence — the seam's voice — and the
run continues to the next page. It exits non-zero on any problem, so it can
gate a commit; the boot gate is what remains. (7) the gate itself —
`Contracts.enforce!` refuses a page, partial or layout whose sentence
violates its word's contract, before evaluation, in the syntax error's
voice (word, line, sentence). What rendered silently — `money name`, a
block dropped under `title`, my own test fixture's `title` under `nav` —
now fails by construction. The gate's first catch was a contract that
under-described the runtime: nested `choice` was tested and supported (the
gatherer stack restores), but the contract said `choice` holds only
`option` — the declaration, not the language, changed, and
`bin/generate_vocabulary.rb` kept the one bullet honest. Eleven pages stay
byte-identical; both apps still serve. What remains of the payload: the
boot moment (the roth test) and the measured cost. (8) the boot moment —
`SlimPickins.prove!` renders every top-level view against the locals the
app gives it, before any request can: both apps prove at boot, loudly
(`proved controls.sp`), and a view the app answers nothing for is refused
too. The roth test, played on the real page: a model minus
`ss_primary_amount` fails at boot naming `controls.sp`, line 14, and the
sentence — the eleven-month silence is a boot error, by construction. Only
the cost remains. (9) the cost, measured and paid once: the gate used to
parse each source twice per render — `Contracts.enforce!` now takes the
tree, so the renderer's one `Transform` serves both the gate and the
compile, and a partial inside `each` pays per iteration. Measured by
`bin/measure_cost.rb` (ruby 4.0.1, pages/specimen.sp, 200 runs): full
render 3.59 ms, without the gate 2.50 ms, the gate itself 1.09 ms, a
partial inside a 50-row `each` 0.29 ms per row. The answer for apps that
cannot pay them: none has asked — 3.59 ms for the heaviest page is
payable everywhere this project has apps — and the known shape of the
escape is a compile-once cache of the gate's verdict and the compiled
Ruby, keyed by source. Eleven pages byte-identical throughout.
(10, after Phase 4 began, at dan's direction) the escape became real:
`Compilation` caches the gate's verdict and the compiled Ruby together,
keyed by the source, behind a mutex — the parse, the walk and the emit
run once per source, not once per render, and a partial inside `each`
pays once, not once per row. The cached verdict carries no path, so each
render composes its own refusal (roth's report.sp renders as a partial
and as a page, and each names itself); a source that will not parse is
never cached, so every render names its own path. Re-measured, same
instrument: cold render 3.42 ms, warm render 1.66 ms — what a request
pays, halved — and 0.12 ms per partial-in-`each` row. `test/compilation_test.rb`
pins the cache; eleven pages byte-identical.

**The dogfood finding, recorded for dan — and corrected by his questions.**
The vocabulary is the language's own lowest layer: a `.sp` composition of
`note` would have to be `note` itself, because compositions need finer atoms
the exclusivity contract deliberately refuses. But the first pass understated
what apps can do: an app word runs *on the Builder*, so it can **delegate to
any built-in** (`stat` is `metric` wrapped), and `SlimPickins.render` now
takes **`filter:`** — the pipeline's middle stage, exposed — so
declaration-then-render is evaluate-then-transform (`thumbnails` counting its
children before presenting them is a filter). Then the sweep opened the
surface entirely: `subject`, `chain`, `label_for`, `format_of`, the gatherer
stack, `about`, `capture` and `prune` are public, and a test forbids `send`
and Builder ivars in words.rb and components.rb — the built-ins and an app's
words provably eat the same food, and every one of the fifty words is now
app-expressible. The sweep's harvest: the only four words carrying build-time
context — section, title, card (heading depth) and form (form-ness) — moved
that context into the Generator, where it is a tree fact; `@level` and
`@in_form` are gone. What remains vocabulary, not power, where dan's own
answer stands: `favicon` is a **word** (a `page` modifier, like the doctype
`page` already absorbs), not a hatch extension. The test the questions
forged stands: for every candidate, ask *is this a word, or a power?* — the
language grows by words, and the surface grows only when the answer is
honestly a power.

**The when-asymmetry, decided (dan, 2026-09-01).** The transform defers the
built-in `when`'s condition so its guard fires before the argument runs; an
app word cannot have that, because Ruby evaluates arguments before any method
and the deferral is grammar-level. dan ratified the recommendation: keep the
asymmetry, documented in `test/dogfood_test.rb` — an app word that wants
guard-before-read uses the language's own idiom, a bare *name* (`if_yes
signed_in`, read by the word after guarding), because a name is never
evaluated. No grammar change; the evidence asks for none.

- **Report, then gate** `agent` — a validation pass over the tree, running on
  the word contracts Phase 1 objectified: every subject resolvable, every
  attribute answered, the contract satisfied — first as a report-only checker,
  then as the gate. A page may not render until the app has been proved able
  to answer it. Both halves are landed (rounds 6–7: `bin/verify_pages.rb`
  reports; the refusal — the gate — compiles once through `Compilation` and
  is raised per render with that render's own path). The boot moment is the
  roth test's other half, landed in round 8.
- **The roth test** `agent` — renaming or removing an attribute makes the roth
  page fail at boot, naming the line and the attribute. The eleven-month
  silence becomes a boot error, by construction. Landed (round 8,
  `test/boot_test.rb`): the real page, the model minus the attribute, the
  boot refuses it naming line 14 and the sentence.
- **The cost, measured** `agent` — the milliseconds the pass adds per render,
  recorded, with the answer for apps that cannot pay them. Landed (round 9,
  `bin/measure_cost.rb`): full render 3.59 ms, the gate 1.09 ms, 0.29 ms per
  partial-in-`each` row (ruby 4.0.1, specimen.sp, 200 runs). The answer
  landed later (round 10, at dan's direction, after Phase 4 began): the
  compile-once cache — `Compilation` — is built; warm render 1.66 ms, cold
  3.42 ms, 0.12 ms per partial-in-`each` row.

*Done looks like:* both apps still serve, every repo page still renders, and
the failure mode the whole project exists to remove is removed from this
project first. All three hold, all three checked each round.

### Phase 4 — The exam: the untested flank

The second port, aimed at exactly what 0.1 never exercised, judged and then
put down.

- **Choose the view** `dan` — one dashboard view (or a small set) heavy in
  branches, navigation, hidden inputs and inline styles — the three things
  lore measured as the real blockers. The port reads the dashboard's files the
  way the roth port read roth's: **`~/dev/dashboard` stays untouched and
  working throughout.**
- **Inventory first** `agent` — what the original could *do*, not what it
  said: the parity-plus lesson from the Phase 7 review, which caught the
  checkbox that vanished unlogged.
- **Settle routing** `agent` — `link` finally meets a real page that asks for
  more than `/name`, and the answer is recorded in the vocabulary, not
  drafted in the abstract.
- **Judge it** `dan` — as Phase 7 was judged. The exam is not the syllabus.

*Done looks like:* the view renders through the language; the branch inventory
matches with every difference logged; routing is settled and recorded; dan's
judgement stands in this file.

### Phase 5 — Eat it yourself

Dogfood, prepared by the earlier phases and taken here.

- **A studio page** `agent` — this repo's own documents served through the
  language: LORE.md or VOCABULARY.md as a `prose` page, the checkers' output
  as a status page, the Way document as a page. `prose` grows exactly what
  those documents use — fences, tables, ordered lists — and stays safe by
  construction; no general markdown engine.
- **The question for dan** `dan` — whether the dashboard's markdown surfaces
  are next, knowing that port is the dogfood with the highest value and the
  one hard constraint: it must keep working, untouched.

*Done looks like:* one of this project's own surfaces is served by the
language that this project built, and the choices that made it possible —
prose, navigation, the free contract, the gate — are named in the record.

### Phase 6 — Subtraction

The backward eye's last discipline. Everything must have a consumer or go.

- **The cut list** `agent` `dan` — candidates already on it: the three paper
  pages (half-retired to `history/` already; their fate is the reversible half
  of a dan decision), `icon`'s circular evidence (its only users are pages on
  the cut list), `meta` with no sentence in any real page, any style rule the
  checker orphans, any document that duplicates another.
- **The measure** `agent` — usage counted before and after, cut and kept
  listed with reasons, everything still green.

*Done looks like:* the vocabulary and the pages are smaller and honest, and
the record says what went and why.

---

## How this stays accountable

The same machine 0.1 ran on, and it is not negotiable:

- **`PROJECT.md` `next_step` always points at the current phase.** Commit
  after each item; the commit is dan's call, and so is the push.
- **Every item has a "done looks like".** If you cannot verify it, it is not
  done.
- **Verify before asserting.** Counts, ratios and claims are measured, and the
  measurement's coverage is stated. Three figures in this project's history
  were wrong on first writing because they were asserted from memory.
- **Look, don't only check.** `ruby bin/demo.rb specimen` builds a standalone
  page; `ruby examples/roth/app.rb` serves the port on 4577. Across 0.1,
  eleven defects passed every checker and were found only by loading the page.
- **RIF per round**: implement → verify → commit with an intention-revealing
  message → update `PROJECT.md` → post lore. Lore is what was *learned*, not
  what was done.
- **The three caveats stand** (from HANDOFF): the escape hatch number is
  retired, not re-measured; `~/dev/dashboard` keeps working untouched;
  `~/dev/roth`'s defects are roth's backlog, not ours.

## Honest limits, named now

- **The two apps here were chosen by the people who chose the words.** Every
  coverage claim carries that until Phase 4 ports a page written by someone
  else — and even then, the port is read by its author. dan writing a page is
  invited at any phase.
- **Static validation cannot prove the app's *values* are right** — only that
  the page can ask for them. roth's wrong arithmetic rendered confidently in
  Phase 7, and would again. The gate removes silent *drift*; it does not bless
  numbers.
- **The Way document will be wrong in places on the day it is written.** That
  is what the checker convention is for: a document whose examples cannot rot
  is a document that earns correction instead of trust.
