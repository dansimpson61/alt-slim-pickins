# alt-slim-pickins — roadmap 0.2

**A page is a described thing. Spend that.**

0.1 asked whether a view language could keep one sentence all the way down. It
can — fifty words, two apps, no grammar changes, closed in
[ROADMAP-0.1.md](history/ROADMAP-0.1.md). Asking the same question of a third app
produces a third number and no new knowledge.

What 0.1 built and never used is that a `.sp` file is now **a parsed tree in
fifty known words, every subject resolvable and every attribute traceable to an
app object**. Everything below follows from taking that seriously.

## The question

> ### What can a language do for you, once it knows what every page means?

## The proscription that forces it

Each of 0.1's proscriptions removed an escape and forced a discovery. No `div`,
so components had to be words. No syntax, so extension had to be vocabulary. No
numeric literal, so figures had to belong to the app. Nothing was ever added to
get around one, and the language is small because of it.

> ### A page may not render until the app has been proved able to answer it.

It removes an ability the language currently has — **the ability to fail
late** — and like the others it looks like a restriction and pays like a tool.
Phase 2 builds it. Everything before it exists so that it is built on a runtime
worth building on.

---

## Why this document was re-sequenced

The first draft of this roadmap opened with a port of `~/dev/dashboard` and put
the contract at Phase 5, behind four phases of porting someone else's views.
Read back, it was **two roadmaps interleaved** — phases 0, 2, 3 and 4 were the
port; phases 1, 5, 6 and 7 were the language — and the port ones came first.

The cause is recorded in [BLUESKY-0.2.md](BLUESKY-0.2.md), which opens its
dashboard section with *"Added after reading it. It is a better Phase 0 than
anything invented, and it changes the roadmap below."* The 81% measurement is
genuinely thrilling and it captured the document that found it.

In fairness to that draft, the dashboard was not arbitrary. `history/PHASE7.md`
closes by naming the one flank with no evidence — `choose`/`when`/`otherwise`
and `if:` have no real page — and recommends a second port to test it. That
reasoning is sound. **The error was promoting one instrument, for testing one
flank, into the organising principle of the release.**

Two findings since then made the inversion untenable, and both are below in
full: the runtime has three good ideas implemented about twelve times, and the
vocabulary had never once been reviewed as *language*. Neither is discoverable
by porting. Both get worse if words are added first.

| was | is now |
|---|---|
| Phase 1 — The shapes a word comes in | **Phase 0** |
| *(new)* | **Phase 1** — A word is reviewable |
| Phase 5 — The contract, checked at boot | **Phase 2** |
| Phase 6 — Errors that teach | **Phase 3** |
| *(a wish in the closing line)* | **Phase 4** — A stranger writes a page |
| Phase 0 — One view, chosen for difficulty | **Phase 5** |
| Phase 2 — Navigation, settled | **Phase 6** |
| Phase 3 — The word for what a form carries | **Phase 7** |
| Phase 4 — The three hard views | **Phase 8** |
| Phase 7 — Subtraction | **Phase 9** |

Nothing was thrown away. The port is still here, still measured, still the only
head-to-head that will exist — it is now the **exam** rather than the syllabus.

---

## Two constraints that run through every phase

These are not phases; they are conditions on all of them. They are also the two
questions this project keeps having to answer out loud, so they are written down
where they cannot be forgotten.

### 1. It must stay lovely to read

Simplicity, readability and guessability on one side; expressiveness, richness
and extensibility on the other. The tension is real and permanent, and the only
defence that has ever worked here is making an abstract property **checkable** —
which is what `check_grammar.rb` and `check_styles.rb` already do for two
others.

Measured 2026-08-31, as the baseline to hold:

| vital | now | what a move would mean |
|---|---|---|
| distinct modifiers used in real pages | **10** | configuration creeping in where words should be |
| mean arguments per sentence | **0.37** | sentences being configured rather than said |
| longest sentence | 4 arguments | a word doing more than one job |
| mean nesting depth | 2.59 (max 7) | structure the vocabulary is not carrying |
| words used at least once | **49 of 50** | dead vocabulary, which is kruft |
| structural shapes covering the vocabulary | **7** | irregularity |
| words that are nouns | **43 of 50** | see below |
| words whose plain English reading misdescribes them | **2** | see below |

The last two rows are new, and they are the reason Phase 1 exists. A sweep of
the fifty words by **part of speech** — never done before — found that this is a
noun language: 43 common nouns, and the seven non-nouns are almost exactly the
control flow (`each` a determiner, `empty` an adjective, `choose` a verb, `when`
a conjunction, `otherwise` an adverb). That is a real and pleasing structure,
and it explains why pages read like a spec sheet rather than a program.

It also found two words that break it. **`check` and `select` are verbs** — the
only two words in the vocabulary you cannot point at. `check show_baseline`
reads as an imperative describing the *user's* action rather than the widget,
and states the wrong default. `select` has no noun sense in English at all
outside HTML. Eight phases of daily use missed both, and one sweep found them,
which is the argument for making the sweep a checker.

`check_shape.rb` is the third checker and Phase 0 builds it. **A vital that
moves is not a failure — it is a conversation.** The check prints them and fails
only on the shape row.

The part that cannot be automated stays dan's: `pages/specimen.sp` puts every
word on one page and has never once been read as an aesthetic object. **Read it
aloud.** If it does not read like prose, the vocabulary has drifted and no
metric will say so.

### 2. Adding a word must be easy, and easy to do *well*

Extensibility is what lets richness emerge. If adding a word is arduous, words
get added badly or not at all — and both make the language worse.

Adding a word is *cheap*: fifty words average 9.6 lines. It is not easy to do
**well**, because there is nothing to add it to. You open an 867-line file, find
the nearest word that resembles yours, and copy it — and copying a neighbour is
the actual recorded mechanism of decay in this project, not bad judgement.

---

## The state of the foundations

Asked whether strong principles were hiding fragile ones, I measured rather than
reassured. `builder.rb` is **867 lines of 1,735 — 50% of the library**, with
**16 instance variables**, and **25 of the 50 words read or write one directly**.

Three of this roadmap's own figures were understated in its first draft: twelve
ivars (16), 22 words (25), 842 lines (867). In a document whose first rule is
*verify before asserting*, that is worth leaving visible.

But size is not the diagnosis. Sorted by what they are actually for, the sixteen
ivars are **three ideas**:

| mechanism | ivars | words |
|---|---|---|
| a parent gathers registering children | `@columns`, `@series`+`@levels`, `@branches`, `@selected` | table/column/total · chart/band/line/level · choose/when/otherwise · select/option |
| ambient context for children | `@level`, `@in_form`, `@suppressed`, `@chain`+`@bindings` | section/title · form/group/button · empty · each/table |
| emission out of band | `@head`, `@deferred`, `@icons_used`, `@contents` | meta/stylesheet/page · script · icon/page · contents |

**Three ideas, roughly twelve implementations.** The lore records three copies of
the gathering mechanism; there are **four** — `select`/`option` is the same
pattern with a different ivar, and it was never counted because it does not look
like a table.

Four copies, four different qualities. Probed rather than inferred:

```text
column outside table     → "column belongs inside a table"
level outside chart      → "level belongs inside a chart"
otherwise outside choose → "otherwise belongs inside a choose"
when .x outside choose   → "this page has no x"    ← guards after evaluating its argument
option fixed, "Fixed"    → <option value="fixed">Fixed</option>   ← no guard at all
```

`choose` saves and restores its state; `table`, `chart` and `select` clear
theirs — which is why the first two crash when nested and `choose` does not. The
copy that happened to be correct was the one written first. `select` has no
`selecting!` guard. And `when` evaluates its condition before its guard runs, so
the language's most-advertised property — errors that speak the language —
reports the wrong problem on the one construct `history/PHASE7.md` already
flagged as having no evidence behind it.

Two crashes were found in five minutes of adversarial probing, and 133
happy-path tests had missed both:

- A `table` or a `chart` reached through a `when` **destroyed the collection of
  the one it was nested inside.**
- **`each item` bound `item`, which is also a word.** Bindings are served by
  `method_missing`; a word is a real method, so the word answered and handed
  back its own output. 23 of the 50 words are plausible loop nouns.

Both are fixed and `test/combination_test.rb` is the guard that was missing.

**The diagnosis is not rot.** Fifty words at 9.6 lines each; every ivar is a
parent talking to its own children. It is that **every proscription in this
language constrains what a page may say, and none constrains how the runtime is
built.** The grammar has a design. The runtime has a habit.

So a word should be built from **named shapes**, not from Builder's insides. The
fifty existing words already fall into seven:

| shape | what it does | words |
|---|---|---|
| **encloses** | opens, nests children, closes | 13 |
| **presents** | an attribute → a value, with label and format precedence | 12 |
| **says** | content only, no subject | 9 |
| **registers** | contributes to a gatherer | 7 |
| **document** | places itself in head or body, wherever written | 5 |
| **gathers** | collects registering children, then renders | 3 |
| **iterates** | `each` | 1 |

If a new word fits a shape, adding it is a declaration. **If it fits none, that
is the thing to argue about in writing** — which turns irregularity from
something that accumulates silently into something that has to be defended.

---

## The exam: `~/dev/dashboard`

Chosen, not invented, and now sat late rather than first.

| | dashboard | roth, for scale |
|---|---|---|
| views / lines | 23 / **1,555** | 1 / 91 |
| branch lines (`if`/`unless`/`else`) | **233** | **0** |
| `each` loops | 71 | 0 |
| interpolated `href` — routing | **65** | 0 |
| hidden form inputs | **91** | 0 |
| forms / distinct POST endpoints | 41 / 24 | 1 / 1 |
| inline `style=` attributes | **180** | 0 |

Three things still make it the right subject:

1. **Nobody here designed it.** Every sentence written in this language so far
   was written by whoever wrote the words.
2. **It is the sibling project's reference consumer**, and has already invented
   app words — seven Ruby classes in `words/`. A port is the only head-to-head
   of the two experiments that will exist.
3. **It is action-heavy.** 41 forms over 24 endpoints, where roth had one of
   each.

Classifying all 176 `if`s by what they test:

| branches on | count | already dissolved by |
|---|---|---|
| a collection being empty or not | **73** | `empty` |
| the presence of one thing | **69** | the `if:` modifier |
| comparison to a value | 17 | `choose` / `when`, or an app predicate |
| compound and other | 17 | the same |

**142 of 176 — 81%.** That is the best evidence yet for *name the situation, do
not write the branch*, from a page written without knowledge of the rule. It is
static analysis of what the branches test, **not a port**. Phase 8 is where it is
confirmed or embarrassed.

### Why it comes late

Beyond the sequencing argument above, one finding is specific to it. Its word
`ports` — the app word Phase 5 was built around — is **not a word**. Reviewed by
part of speech: all 43 of alt's nouns are *common* nouns naming a kind, and 41
of the 43 are singular; `ports` is a proper plural noun naming one dataset, it
can never take an argument, and its children are bare content where every other
word's children are words. It appears in exactly one view, the view of the same
name, and is 100% of that view below the chrome.

That is not an argument against the dashboard. It is an argument that **what an
app word may be has to be decided before the port, not during it** — because the
port is otherwise a comparison of alt against a design that neither project has
defended. Deciding costs a paragraph in `CONTRACT.md`. Discovering it mid-port
costs a phase.

---

## The risk register

Highest first. This is what the phase order is for.

| Unknown | Risk | Retired by |
|---|---|---|
| **Words that meet in ways no page has used yet** | **High** | Phase 0, then per word |
| **Adding a word is cheap enough to do well** | **High** | Phase 0 |
| **The vocabulary is good *as language*, not just consistent** | **High**, new | Phase 1 |
| Demands are computable without rendering | **High** — it is the payload | Phase 2 |
| **Someone else can write a page and be told what they got wrong** | **High** | Phase 4 |
| A page someone else designed can be said at all | **High** | Phase 5 |
| Conditionals dissolve into vocabulary *at scale* | **High** | Phase 5, confirmed in Phase 8 |
| Navigation has an answer that is not a guess | **High** | Phase 6 |
| A form can carry what it must without a hole | **High**, narrow | Phase 7 |
| **The language stays lovely as it grows** | **High**, permanent | never — standing constraint |
| What a page cannot say about arrangement | **Medium** | Phase 8 |
| The vocabulary has words with no page behind them | Low, unexamined | Phase 9 |
| The grammar needs changing | Low | eight phases said no |

The first three are retired without touching another app, and two of them get
worse if words are added first. That is the whole argument for the new order.

The row with no phase against it is the one to watch. **Nothing retires it** —
it is checked every run and judged by eye at every phase boundary, because a
language does not become ugly on a date.

## The one rule that is not negotiable

**The dashboard must keep working, untouched, throughout.**

It is the tool that runs everything else in `~/dev`. A port is a *parallel* set
of views that can be thrown away, never a replacement — the same discipline that
kept `~/dev/roth` clean through two phases and produced a better result than
editing it would have.

`~/dev/dashboard` ends every phase of this roadmap with a clean tree, its own
`journal.md` excepted.

## How this stays accountable

- **This file is the single source of truth.** `PROJECT.md` `next_step` always
  points at the current phase. Commit after each item.
- **Every `agent` and `dan` item has a "done looks like".** If you cannot verify
  it, it is not done. A `conv` is a standing convention, not a task, so it has
  none — and if a `conv` could have one, it is really an item.
- **`check_grammar.rb`, `check_styles.rb` and `check_shape.rb` stay green.**
  Every new word arrives with a sentence, a rule and a shape.
- **A new word arrives with a combination test.** A word that gathers, binds or
  shifts anything gets crossed against the ones that already do.
- **A word is added by declaring a shape, or by arguing in writing for a new
  one.** No word reaches into `Builder`'s insides that a shape could reach for
  it.
- **The aesthetic vitals are printed every run and read at every phase
  boundary.** A number that moved is a conversation, not a failure.
- **Verify before asserting.** No count, ratio or claim without measuring it,
  and say what the measurement covered. Three of this document's own numbers
  were wrong on first writing.
- **Checkers are not enough — look at the rendered output.** In 0.1: five
  defects in its Phase 5, two in its Phase 7 and four in its Phase 8 passed
  every checker and were found only by loading the page.
- **Stop quoting the escape-hatch ratio.** It measures the distance between what
  a page needs and where its data is, not vocabulary coverage.
- **Resume:** `curl http://127.0.0.1:4000/brief/alt-slim-pickins`.

Green baseline at the start of 0.2, measured 2026-08-31: **142 tests / 0
failures · 632 sentences / 0 problems · 65 rules / 0 problems.**

Legend: `dan` (a decision only you can make) · `agent` (me) · `conv` (a
convention followed going forward).

---

# Part I — The foundations

*Nothing here is visible to a user. All of it is cheaper now than after three
phases of adding words.*

## Phase 0 — The shapes a word comes in

**Before any word is added.** Later phases will want to fill walls with words,
and adding them into an 867-line class with sixteen shared ivars is how this
roadmap would quietly make the language worse.

- **One gathering mechanism, in place of four** `agent` — `table`/`column`,
  `chart`/`band`/`line`/`level`, `choose`/`when`/`otherwise` and
  `select`/`option`. The guard message writes itself from the declaration, so
  *"`band` belongs inside a chart"* stops being a hand-written string, and
  **reentrancy becomes a property of the mechanism rather than of whoever wrote
  the copy** — which is how three of the four came to be wrong.
  *Done looks like:* the four collection ivars and the three `…!` guards are one
  thing, `option` outside a `select` is an error that speaks the language, every
  test still passes, and no page changed.
- **A guard fires before its word evaluates its arguments** `agent` — `when .x`
  outside a `choose` currently reports *"this page has no x"*, naming the wrong
  problem on the construct with the least evidence behind it.
  *Done looks like:* it says `when belongs inside a choose`, and a test pins the
  message for every guarded word.
- **Cross the state-holding words against each other** `agent` — `form`,
  `select`, `each`, `section` and `page` all carry something for their children,
  and only the gatherers have been probed.
  *Done looks like:* `test/combination_test.rb` covers every pair, and every wall
  in it is a language error rather than a Ruby one.
- **Name the seven shapes, in the vocabulary** `agent` — `VOCABULARY.md` already
  declares seven slots per word; the shape is the eighth thing every entry
  implicitly has and never states.
  *Done looks like:* every entry names its shape, and the shapes are defined once
  at the top.
- **`check_shape.rb`** `agent` — the third checker, in the family of the other
  two.
  *Done looks like:* it is green, it prints the vitals table above, and it fails
  only when a word fits no shape.
- **Adding a word is a declaration** `agent` — demonstrate by rewriting two
  existing words against the shapes, from different families.
  *Done looks like:* the diff is smaller than the word was, and a reader can see
  what kind of word it is without reading its body.
- **Judge the surface** `dan` — is adding a word now something you would
  cheerfully do at 11pm?
  *Done looks like:* the answer. If it is no, this phase is not finished.

**The trap to avoid:** shapes are a description of what the vocabulary already
is, not a framework it must now fit. If naming them requires bending three words
to match, the taxonomy is wrong and the words are right.

## Phase 1 — A word is reviewable

`check_grammar.rb` proves every word is defined and used. **Nothing proves a
word is a good word.** One manual sweep by part of speech found two defects that
eight phases of daily use had not. This phase makes the sweep an instrument.

- **Three axes, mechanically extracted** `agent` — part of speech; what the name
  slot governs; which shape. All three are already derivable from
  `VOCABULARY.md` and `builder.rb`.
  *Done looks like:* `check_shape.rb` prints all three per word, and an outlier
  on any axis is listed rather than merely counted.
- **Decide `check` and `select`** `dan` — they are the only two words you cannot
  point at, and both read as imperatives that misdescribe what they render.
  `checkbox` and `dropdown` are free; `choice` is not, it would sit badly beside
  `choose`. The counter-argument is that HTML made them nouns and our readers
  know HTML.
  *Done looks like:* renamed, or the reason for keeping them written into
  `VOCABULARY.md` so the next sweep does not re-raise it.
- **The naming rule gets its second half** `conv` — 0.1's rule was *check a
  presentation word against the HTML element of the same name, because our
  readers know HTML*. It caught `detail` → `fact`. It cannot catch `check` or
  `select`, because there HTML and alt agree and it is English that dissents.
  **Check it against English too, and prefer the noun sense.**
- **Decide what an app word may be** `dan` — the escape hatch says an app adds a
  word in Ruby, and `history/PHASE7.md` notes it still cannot ask for a label.
  The dashboard's `ports` shows where that leads unconstrained: a proper plural
  noun, one page, no argument, content for children.
  *Done looks like:* one paragraph in `CONTRACT.md` saying what an app word must
  be — and it must be answerable before Phase 5, not during it.
- **The name slot's five jobs, written down** `agent` — reading `X y` you cannot
  tell whether `y` is a complement (`table holdings`), an adjective (`badge ok`),
  an attribute (`column symbol`), a destination (`link dashboard`) or a notation
  (`prose markdown`). Every word obeys the one-job rule; the *slot*, across the
  language, does not.
  *Done looks like:* the five relations named in `DESIGN.md`, and each entry
  saying which it takes. This is documentation, not a change — the label register
  absorbs it, and it is why an entry needs two definitions rather than one.

---

# Part II — The payload

*The question this roadmap actually asks.*

## Phase 2 — The contract, checked at boot

The proscription, built.

- **A page can say what it demands, without rendering** `agent` — walk the tree,
  collect every attribute every word will ask of every subject.
  *Done looks like:* `SlimPickins.demands(path)` returns the list, and a test
  pins it against a real page.
- **The app is checked once, at boot** `agent` — every demand met, or an error
  naming the page, the line, the word and the attribute.
  *Done looks like:* renaming an attribute in roth's `Scenario` fails the boot
  rather than a render. roth's eleven-month silent rename becomes an error the
  first time anyone starts the app.
- **Did-you-mean** `agent` — the demand and the offer are both in hand at that
  moment, so the cost is nearly nothing.
  *Done looks like:* `this scenario has no ss_primary_amout — did you mean
  ss_primary_amount?`
- **What presents this attribute** `agent` — the same walk, inverted.
  *Done looks like:* one command answers it across every `.sp` file in a project.

## Phase 3 — Errors that teach

Cheap, and it compounds with everything above. 0.1's best-kept secret is that its
errors already speak the language rather than the implementation.

- **The failing line, in context** `agent` — with the subject chain that led to
  it, because "this page has no account" is true and unhelpful without knowing
  which page and which line.
  *Done looks like:* every `SlimPickins::Error` carries the file, the line, the
  word and the chain of subjects open when it was raised, and a test pins the
  whole message for one failure of each kind.
- **A wall names its nearest word** `agent` — an unknown word is a typo more
  often than a gap, and the vocabulary is fifty entries long.
  *Done looks like:* ``there is no word `sectoin` — did you mean `section`?``,
  and no suggestion when nothing is close.

---

# Part III — The exam

*Evidence from outside. None of it is available until the language is worth
examining.*

## Phase 4 — A stranger writes a page

**The one thing I would most like to be true at the end of 0.2:** that someone
who did not build it wrote a page, got it wrong, and the language told them —
before it served anything — exactly which word was lying.

That was the closing line of the previous draft, where it was a wish. It is a
phase now, because Phases 2 and 3 are exactly what make it possible and nothing
else on this roadmap tests it. Every sentence in this repo was written by
whoever wrote the words.

- **Find one** `dan` — a person, not an app. It does not need to be a Ruby
  developer; that is arguably the better test.
  *Done looks like:* a name, or an honest statement that there is nobody
  available, which changes what Phase 5 is evidence for.
- **Give them the vocabulary and a page to write** `agent` — no tutorial beyond
  `VOCABULARY.md` and one worked example.
  *Done looks like:* their page, their questions, and the wall count.
- **Record what they reached for that does not exist** `agent` — and separately,
  what they *misread*, which is the thing no checker can find.
  *Done looks like:* two lists. The second is the more valuable.
- **Judge it** `dan` — did the language teach them, or did you?
  *Done looks like:* the answer, recorded, including if it is no.

## Phase 5 — One view, chosen for difficulty

`views/ports.slim`, 42 lines. Not the easiest — the one holding most of the
problem in miniature: a form with two hidden fields, four conditionals, two
`each` loops (one over a filtered collection), and an app word.

*(The previous draft said three loops. There are two, at lines 14 and 30.)*

This phase answers one question: **can a page nobody here designed be said in
this language at all?**

Three things are known before a line is written:

- **It has no `href` of its own.** Every link is emitted from inside the `ports`
  word. Routing is deferred one level, not absent.
- **Three lines compose a sentence from a fragment plus a value** — lines 18, 20
  and 33. That is the wall `history` records being *refused* in 0.1, by name: one
  line is one node, and inline fragments would be Slim's `:` all over again. So
  the first wall here is likely a standing refusal rather than a new gap, which
  is a different result and needs a different response.
- **`ports.rb` reaches around its own contract twice**, with
  `view.instance_variable_get("@running")`. The sibling experiment invented app
  words and then invented a way around its contract to feed them.

- **Inventory what the page *does*, before porting what it says** `agent` — the
  Phase 7 external review caught a control and a legend vanishing from the roth
  port unlogged, because that port was measured against roth's *page* rather than
  roth's *behaviour*. This page stops processes, adopts inferred ports into
  `PROJECT.md`, and launches apps.
  *Done looks like:* a list of what the original can do, written before the port
  and checked after it.
- **Port it, and stop at the first thing that cannot be said** `agent` — do not
  invent a word to get past a wall. Record the wall.
  *Done looks like:* either the page renders, or a list of exactly what stopped
  it, each entry naming the line and what the language lacks.
- **A presenter for what the view computes** `agent` — `ports.slim` calls
  `Scan.port_open?` and filters `@running` in the page. That is the roth
  `Projection` pattern and needs no new language.
  *Done looks like:* the page names attributes; nothing in it computes.
- **Say `ports` in the language** `agent` — against the Phase 1 decision. `table
  ports` is well-formed where `ports` is not; whether its five columns *can* be
  columns is the real question, since two of them render behaviour rather than a
  value.
  *Done looks like:* the sentence, or the reason there isn't one.
- **Judge the reading** `dan` — is the ported page better to read than the Slim
  it replaces, at this size, on a page you know well?
  *Done looks like:* the answer, recorded, including if it is no.

**If this phase fails, Part III changes shape.** Concretely:

- **Two or three walls, each a nameable gap.** Expected. Phases 6 and 7 hold the
  two most likely. Continue.
- **A wall that needs new syntax.** Stop. That is the founding claim failing, and
  it outranks everything else in this document.
- **It ports, but reads worse than the Slim.** Also stop, and ask why — the
  language is for reading. 0.1 never risked this, because roth's page was ugly to
  begin with and the dashboard's is not.
- **More than half the page needs the app rewritten around it.** Then the
  language is portable-*to* only in theory, which is a smaller claim than this
  document assumes. Say so and re-scope.

## Phase 6 — Navigation, settled

Forced by Phase 5 rather than chosen. `link show, "Details"` derives `/show`; the
dashboard has **65 interpolated hrefs** and is nothing but navigation. Deferred
twice in 0.1 for want of evidence — there is now enough.

- **Decide how a page says where a link goes** `dan` — does `link` ask the app
  through a `path_for(name, subject)` on the contract, the same shape as
  `label_for` and `format_for`; or are routes simply said with `to:`? The
  precedent from 0.1 says ask the app.
  *Done looks like:* the decision, and the reason, in `CONTRACT.md`.
- **Implement it, and the current-page rule with it** `agent` — `nav` already
  claims to mark the current link and the dashboard's layout spends five lines of
  Ruby doing it by hand.
  *Done looks like:* `ports`' links resolve, the nav marks itself, and no page
  states a path.
- **The `to:` escape survives** `conv` — an external URL is not a route.

## Phase 7 — The word for what a form carries

**91 hidden inputs.** Every dashboard action carries `path` and `return_to`, some
carry `cmd`. There is no word for *a value a form carries but does not show*, and
91 uses is vocabulary, not an escape hatch.

This is the first genuinely new word since the `chart` redraft, and it gets
drafted the way the good ones were: **after the pages have hurt.** It also gets
declared as a shape and swept by part of speech, which is what Part I was for.

- **Write the pages that need it first** `agent` — the five `confirm_*.slim`
  views are nothing but a warning and a form, carry three to four hidden fields
  each, and the smallest is fourteen lines.
  *Done looks like:* the pages exist with the hole named in a comment.
- **Draft the word against them** `agent` — one entry in `VOCABULARY.md`, eight
  slots now, no blanks.
  *Done looks like:* the entry, its shape, its part of speech, and every
  `confirm_*` page saying it.
- **Check it is not two words wearing one hat** `dan` — a hidden value and a
  return path may not be the same idea.
  *Done looks like:* one word, or two, decided on the evidence.

## Phase 8 — The three hard views

**`project.slim` (274), `dispatch.slim` (236) and `index.slim` (220)** — 730
lines, and every construct in the dashboard appears in at least one of them. The
other fourteen views, 655 lines, are **not in this roadmap**; they are mechanical
once these three are done and porting them proves nothing.

Conditional and bespoke UI is what these three are made of. The 81% is a
prediction; this is the test.

- **Port the three, worst first** `agent` — stop at anything that cannot be said.
  *Done looks like:* three ported views, or a list of exactly what stopped each.
- **Measure the branches honestly** `agent` — how many of the 233 really
  dissolved, how many needed `choose`, how many an app predicate, how many
  something that does not exist.
  *Done looks like:* the four counts, against the prediction.
- **Name what a page still cannot say about arrangement** `agent` — 180 inline
  styles over 41 `sp-` classes. Most should not port; the interesting output is
  the list of those that should and could not.
  *Done looks like:* the list, and a recommendation for each — a word, a variant,
  or nothing.
- **Decide how far `prose` goes** `dan` — three dashboard views render markdown
  from files, and alt's renderer is 55 lines against the dashboard's 181.
  Measured, `prose` handles paragraphs, headings, lists, bold, inline code, links
  and blockquotes; it does **not** handle **code fences, tables or ordered
  lists**, all of which appear in the documents those views display.

  This is the roadmap's sharpest tension in miniature. A document viewer that
  cannot render a fenced code block is useless, and "support all of markdown" is
  precisely the feature creep this document refuses.
  *Done looks like:* the decision — extend it, bound it explicitly, or take a
  gem — and the reason.
- **The head-to-head** `dan` — the same app, in two languages, both by hand. This
  comparison will not be available again.
  *Done looks like:* the judgement, recorded, including what the sibling does
  better.

---

# Part IV

## Phase 9 — Subtraction

A language that only grows is not being designed. Applied to files, using the
project's own rule: **a word with no page behind it goes.**

**`markdown.rb` was on this list and should not have been.** Three dashboard
views render markdown, so `prose` is needed by the very port this roadmap uses as
its exam. It was listed after checking the specimen and not the subject, which is
the error this document warns against twice. It is a Phase 8 gap, not a cut.

- **The candidates, measured** `agent` — `icons.rb` is 34 lines serving one word,
  used only by `pages/figures.sp` and `pages/specimen.sp` — **both of which are
  themselves on this list**, which is circular evidence and worse than none.
  `bin/diff_roth.rb` compares against a page the port superseded. `PORTFOLIO.md`,
  `CONTENT.md` and `FIGURES.md` were the evidence for the vocabulary before there
  was code.
  *Done looks like:* for each, the pages outside this list that use it, and
  whether any is real.
- **Check every candidate against the dashboard first** `conv` — the mistake
  above, made a rule. A thing is only unused if it is unused by the app the
  roadmap is about.
- **Cut** `dan` — the call is yours; the measurement is mine.
  *Done looks like:* the repo is smaller, and the checkers are still green.

---

## What 0.2 refuses to do

Stated up front, because the pressure will come and the refusals are why the
language is small.

- **No component library.** The vocabulary is presentation, not a design
  system's catalogue. `card`, `metric` and `badge` are the ceiling.
- **No client-side runtime.** 0.1 took roth's script from 249 lines to 25 by
  moving work to the server. A JavaScript companion would undo the most valuable
  thing this project has shown.
- **No plugin system.** The escape hatch is one module of Ruby methods and five
  exposed methods. That is the right size.
- **No second syntax, ever.** Not for conditionals, not for loops, not for
  interpolation. Eight phases held the line; the ninth is where it usually
  breaks.
- **No general-purpose templating.** An invoice PDF or an XML feed is a different
  tool. The scope is web presentation.
- **No editing the dashboard to suit the language.** If a page cannot be said,
  that is a finding about the language, not a defect in the page.
- **No framework where a taxonomy will do.** Phase 0 names what the vocabulary
  already is. If it starts prescribing what words must become, it has failed.

## What "how far along" means

**Part I buys nothing a user could see, and it is first on purpose.** Two of the
three highest risks on the register get *worse* if words are added before it, and
the evidence is not speculative: three of the four copies of one mechanism are
wrong, and two of them crashed under five minutes of probing.

**Part II is the point of the roadmap.** If everything after Phase 3 were
abandoned, 0.2 would still have answered its question.

**Part III is evidence, in increasing cost.** Phase 4 costs a conversation and
tests the thing nothing else tests. Phase 5 is 42 lines and can invalidate the
four phases after it. Phase 8 is the largest by effort and confirms or destroys
the 81%.

If Phase 5 fails, Part III changes shape and Parts I and II stand regardless.
That is the strongest argument for this order: **the previous draft put the
release's payload behind the part most likely to fail.**

The one risk with no phase against it — that the language stays lovely — is the
one that will be lost slowly if it is lost at all. It is checked every run and
read aloud at every phase boundary.
