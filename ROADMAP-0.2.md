# alt-slim-pickins — roadmap 0.2

**A page is a described thing. Spend that.**

0.1 asked whether a view language could keep one sentence all the way down. It
can — fifty words, two apps, no grammar changes, closed in
[ROADMAP-0.1.md](ROADMAP-0.1.md). Asking the same question of a third app
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
Phase 5 builds it; Phases 0 to 4 are what make the case for it, repeatedly, by
being the kind of work where late failure hurts.

## Two constraints that run through every phase

0.2 is a porting roadmap, and porting generates the exact pressure that makes
languages ugly: a wall, a deadline, and a word added to get past it. Every
language that got krufty got that way one reasonable-looking exception at a
time. These two constraints are not phases; they are conditions on all of them.

### 1. It must stay lovely to read

Simplicity, readability and guessability on one side; expressiveness, richness
and extensibility on the other. The tension is real and permanent, and the only
defence that has ever worked here is making an abstract property **checkable**
— which is what `check_grammar.rb` and `check_styles.rb` already do for two
others.

Measured today, as the baseline to hold:

| vital | now | what a rise would mean |
|---|---|---|
| distinct modifiers used in real pages | **10** | configuration creeping in where words should be |
| mean arguments per sentence | **0.37** | sentences being configured rather than said |
| longest sentence | 4 arguments | a word doing more than one job |
| mean nesting depth | 2.59 (max 7) | structure the vocabulary is not carrying |
| words used at least once | **49 of 50** | dead vocabulary, which is kruft |
| structural shapes covering the vocabulary | **7** | irregularity |

`check_shape.rb` is the third checker and Phase 1 builds it. **A vital that
moves is not a failure — it is a conversation.** The check prints them and
fails only on the last row.

The part that cannot be automated stays dan's: `pages/specimen.sp` puts every
word on one page and has never once been read as an aesthetic object. **Read it
aloud.** If it does not read like prose, the vocabulary has drifted and no
metric will say so.

### 2. Adding a word must be easy, and easy to do *well*

Extensibility is what lets richness emerge. If adding a word is arduous, words
get added badly or not at all — and both make the language worse.

It is currently arduous, and 0.1 left the evidence:

- **22 of 50 words reach directly into `Builder`'s instance variables.** There
  are twelve of them, and `builder.rb` is 842 lines — 49% of the library.
- **Three words gather registering children — `table`, `chart`, `choose` — and
  each re-implements the mechanism**, with its own collection ivar and its own
  near-identical guard: `registering!`, `charting!`, `branching!`. One idea,
  three copies.

That third copy is mine. I wrote `charting!` in 0.1's Phase 8 by pattern-matching on
`registering!` without noticing I was duplicating it, which is exactly how kruft
arrives: not by bad judgement but by a reasonable local decision made twice.

**And the duplication was already producing bugs.** Asked whether the
principles were hiding fragile foundations, I went looking, and five minutes of
adversarial probing found two crashes — both of which failed with a Ruby error
rather than one that speaks the language, which is this project's strongest
claim:

- A `table` or a `chart` reached through a `when` **destroyed the collection of
  the one it was nested inside**. `choose` was fine, because `choose` saves and
  restores its state and the other two only cleared theirs. The copy that
  happened to be correct was the one written first.
- **`each item` bound `item`, which is also a word.** Bindings are served by
  `method_missing`; a word is a real method, so the word answered instead and
  handed back its own output. 23 of the 50 words are plausible loop nouns.

Both are fixed, and `test/combination_test.rb` is the guard that was missing —
133 tests found neither, because every one of them was a happy path over a page
somebody wrote on purpose.

The lesson is not that the foundations are rotten; 50 words average 9.6 lines
each and all 13 ivars are a parent word talking to its own children. It is
that **every proscription in this language constrains what a page may say, and
none constrains what happens when words meet.** The grammar guarantees each
sentence is well formed. Nothing guaranteed the tree was.

**So a word should be built from named shapes, not from Builder's insides.** The
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

## The subject: `~/dev/dashboard`

Chosen, not invented. It is the only candidate that tests three unknowns at
once, and reading it changed this roadmap ([BLUESKY-0.2.md](BLUESKY-0.2.md) has
the full argument).

| | dashboard | roth, for scale |
|---|---|---|
| views / lines | 23 / **1,555** | 1 / 91 |
| branch lines (`if`/`unless`/`else`) | **233** | **0** |
| `each` loops | 71 | 0 |
| interpolated `href` — routing | **65** | 0 |
| hidden form inputs | **91** | 0 |
| forms / distinct POST endpoints | 41 / 24 | 1 / 1 |
| inline `style=` attributes | **180** | 0 |

Three things make it the right one:

1. **Nobody here designed it.** Every sentence written in this language so far
   was written by whoever wrote the words. That is 0.1's largest untested
   claim, and this retires it.
2. **It is the sibling project's reference consumer.** The dashboard is built
   on `~/dev/slim-pickins` and has **already invented app words** — seven Ruby
   classes in `words/`, each said as a bare word in a page. Two experiments
   converged on the same idea without coordinating. A port is the only
   head-to-head comparison of them on the same app that will exist.
3. **It is action-heavy.** 41 forms over 24 endpoints, where roth had one of
   each. A whole face of web presentation this language has never touched.

### The encouraging measurement, and its limit

Classifying all 176 `if`s by what they test:

| branches on | count | already dissolved by |
|---|---|---|
| a collection being empty or not | **73** | `empty` |
| the presence of one thing | **69** | the `if:` modifier |
| comparison to a value | 17 | `choose` / `when`, or an app predicate |
| compound and other | 17 | the same |

**142 of 176 — 81%** — are the two cases the language already turns into
vocabulary. That is the best evidence yet for *name the situation, do not write
the branch*, and it comes from a page written without knowledge of the rule.

**It is static analysis of what the branches test, not a port.** It says the
odds are good. Phase 4 is where it is either confirmed or embarrassed.

## The risk register

Highest first. This is what the phase order is for.

| Unknown | Risk | Retired by |
|---|---|---|
| A page someone else designed can be said at all | **High** | Phase 0 |
| Conditionals dissolve into vocabulary *at scale* | **High** | Phase 0, confirmed in Phase 4 |
| **Adding a word is cheap enough to do well** | **High** | Phase 1 |
| Navigation has an answer that is not a guess | **High** | Phase 2 |
| A form can carry what it must without a hole | **High**, narrow | Phase 3 |
| **The language stays lovely as it grows** | **High**, permanent | never — it is a standing constraint |
| What a page cannot say about arrangement | **Medium** | Phase 4 |
| Demands are computable without rendering | Medium | Phase 5 |
| **Words that meet in ways no page has used yet** | **High** | Phase 1, then per word |
| The vocabulary has words with no page behind them | Low, unexamined | Phase 7 |
| The grammar needs changing | Low | eight phases said no |

The first two are retired by one 42-line view, which is the argument for
starting there rather than with the largest page or the newest idea.

The row with no phase against it is the one to watch. **Nothing retires it** —
it is checked every run and judged by eye at every phase boundary, because a
language does not become ugly on a date.

## The one rule that is not negotiable

**The dashboard must keep working, untouched, throughout.**

It is the tool that runs everything else in `~/dev`. A port is a *parallel* set
of views that can be thrown away, never a replacement — the same discipline
that kept `~/dev/roth` clean through two phases and produced a better result
than editing it would have.

`~/dev/dashboard` ends every phase of this roadmap with a clean tree, its own
`journal.md` excepted.

## How this stays accountable

- **This file is the single source of truth.** `PROJECT.md` `next_step` always
  points at the current phase. Commit after each item.
- **Every item has a "done looks like".** If you cannot verify it, it is not
  done.
- **`check_grammar.rb`, `check_styles.rb` and `check_shape.rb` stay green.**
  Every new word arrives with a sentence, a rule and a shape.
- **A new word arrives with a combination test.** `test/combination_test.rb`
  crosses the words that hold state against each other. Two crashes lived
  behind 133 happy-path tests; a word that gathers, binds or shifts anything
  gets crossed against the ones that already do.
- **A word is added by declaring a shape, or by arguing in writing for a new
  one.** No word reaches into `Builder`'s insides that a shape could reach for
  it. This is the second standing constraint, enforced per commit.
- **The aesthetic vitals are printed every run and read at every phase
  boundary.** A number that moved is a conversation, not a failure.
- **Verify before asserting.** No count, ratio or claim without measuring it,
  and say what the measurement covered.
- **Checkers are not enough — look at the rendered output.** In 0.1: five
  defects in its Phase 5, two in its Phase 7 and four in its Phase 8 passed
  every checker and were found only by loading the page.
- **Resume:** `curl http://127.0.0.1:4000/brief/alt-slim-pickins`.

Legend: `dan` (a decision only you can make) · `agent` (me) · `conv` (a
convention followed going forward).

---

## Phase 0 — One view, chosen for difficulty

`views/ports.slim`, 42 lines. Not the easiest — the one that holds most of the
problem in miniature: a form with two hidden fields, four conditionals, three
`each` loops (one over a filtered collection), and an app word — `ports`, a
`SlimPickins::Tabular` subclass.

This phase answers one question: **can a page nobody here designed be said in
this language at all?**

It has **no `href` of its own**, and that is a finding before a line is
written: every link on the page is emitted from inside the `ports` word, which
is a Ruby class building `<a>` tags by hand. The routing question is deferred
one level rather than absent — which is worth knowing before Phase 1 decides
where routing belongs.

- **Port it, and stop at the first thing that cannot be said** `agent` — do not
  invent a word to get past a wall. Record the wall.
  *Done looks like:* either the page renders, or a list of exactly what stopped
  it, each entry naming the line and what the language lacks.
- **A presenter for what the view computes** `agent` — `ports.slim` calls
  `Scan.port_open?` and filters `@running` in the page. That is the roth
  `Projection` pattern and needs no new language.
  *Done looks like:* the page names attributes; nothing in it computes.
- **Judge the reading** `dan` — is the ported page better to read than the Slim
  it replaces, at this size, on a page you know well?
  *Done looks like:* the answer, recorded, including if it is no.

**If this phase fails, the rest of the roadmap changes shape**, which is
exactly why it is first and why it is one small file.

## Phase 1 — The shapes a word comes in

**Before any word is added.** Phase 0 will have found walls; Phases 2 and 3
will want to fill them. Adding words into an 842-line class with twelve shared
ivars is how the next three phases would make the language worse, and it is the
one thing on this roadmap that is cheaper to do early than late.

This phase is about the second standing constraint, and it is prep, not
progress. It should be small.

- **Extract gathering** `agent` — one mechanism for `table`/`column`,
  `chart`/`band`/`line`/`level` and `choose`/`when`/`otherwise`, in place of
  three. The guard message writes itself from the declaration, so *"`band`
  belongs inside a chart"* stops being a hand-written string in three places,
  and **reentrancy is a property of the mechanism rather than of whoever wrote
  the copy** — which is how two of the three came to be broken.
  *Done looks like:* the three collection ivars and the three `…!` guards are
  one thing, every test still passes, and no page changed.
- **Cross the state-holding words against each other** `agent` — `form`,
  `select`, `each`, `section` and `page` all carry something for their
  children, and only the gatherers have been probed.
  *Done looks like:* `test/combination_test.rb` covers every pair, and every
  wall in it is a language error rather than a Ruby one.
- **Name the seven shapes, in the vocabulary** `agent` — `VOCABULARY.md`
  already declares seven slots per word; the shape is the eighth thing every
  entry implicitly has and never states.
  *Done looks like:* every entry names its shape, and the shapes are defined
  once at the top.
- **`check_shape.rb`** `agent` — the third checker, in the family of the other
  two. Every word fits a declared shape; the aesthetic vitals are printed every
  run.
  *Done looks like:* it is green, it prints the six numbers from the table
  above, and it fails only when a word fits no shape.
- **Adding a word is a declaration** `agent` — demonstrate by rewriting two
  existing words against the shapes, chosen from different families.
  *Done looks like:* the diff is smaller than the word was, and a reader can
  see what kind of word it is without reading its body.
- **Judge the surface** `dan` — is adding a word now something you would
  cheerfully do at 11pm?
  *Done looks like:* the answer. If it is no, this phase is not finished.

**The trap to avoid:** shapes are a description of what the vocabulary already
is, not a framework it must now fit. If naming them requires bending three
words to match, the taxonomy is wrong and the words are right.

## Phase 2 — Navigation, settled

Forced by Phase 0 rather than chosen. `link show, "Details"` derives `/show`;
the dashboard has **65 interpolated hrefs** and is nothing but navigation.
Deferred twice in 0.1 for want of evidence — there is now enough.

- **Decide how a page says where a link goes** `dan` — does `link` ask the app
  through a `path_for(name, subject)` on the contract, the same shape as
  `label_for` and `format_for`; or are routes simply said with `to:`? The
  precedent from 0.1's Phases 0 and 2 says ask the app.
  *Done looks like:* the decision, and the reason, in `CONTRACT.md`.
- **Implement it, and the current-page rule with it** `agent` — `nav` already
  claims to mark the current link and the dashboard's layout spends five lines
  of Ruby doing it by hand.
  *Done looks like:* `ports.slim`'s links resolve, the nav marks itself, and no
  page states a path.
- **The `to:` escape survives** `conv` — an external URL is not a route.
  `http://127.0.0.1:4577` must stay sayable.

## Phase 3 — The word for what a form carries

**91 hidden inputs.** Every dashboard action carries `path` and `return_to`,
some carry `cmd`. There is no word for *a value a form carries but does not
show*, and 91 uses is vocabulary, not an escape hatch.

This is the first genuinely new word since the `chart` redraft, and it gets
drafted the way the good ones were: **after the pages have hurt.**

- **Write the pages that need it first** `agent` — the five `confirm_*.slim`
  views are nothing but a warning and a form, carry three to four hidden fields
  each, and the smallest is fourteen lines. Port them and let the gap be felt.
  *Done looks like:* the pages exist with the hole named in a comment.
- **Draft the word against them** `agent` — one entry in
  [VOCABULARY.md](VOCABULARY.md), seven slots, no blanks.
  *Done looks like:* the entry, and every `confirm_*` page saying it.
- **Check it is not two words wearing one hat** `dan` — a hidden value and a
  return path may not be the same idea.
  *Done looks like:* one word, or two, decided on the evidence.

## Phase 4 — The rest of it, in anger

Conditional and bespoke UI at 1,555 lines. The 81% is a prediction; this is the
test.

- **Port the remaining views** `agent` — in order of ugliness, worst first.
  `project.slim` (305), `dispatch.slim` (257) and `index.slim` (244) are where
  the answer lives; the small ones will not teach anything the first three did
  not.
  *Done looks like:* every view ported or refused, with the refusals listed.
- **Measure the branches honestly** `agent` — how many of the 233 really
  dissolved, how many needed `choose`, how many needed an app predicate, how
  many needed something that does not exist.
  *Done looks like:* the four counts, against the prediction above.
- **Name what a page still cannot say about arrangement** `agent` — 180 inline
  styles over 41 `sp-` classes. Most should not port; the interesting output is
  the list of those that should and could not.
  *Done looks like:* the list, and a recommendation for each — a word, a
  variant, or nothing.
- **The head-to-head** `dan` — the same app, in two languages, both by hand.
  This comparison will not be available again.
  *Done looks like:* the judgement, recorded, including what the sibling does
  better.

## Phase 5 — The contract, checked at boot

The proscription, built. By now the port will have made the case for it several
times over, which is the right order — 0.1's mistake with `chart` was drafting
before the evidence.

- **A page can say what it demands, without rendering** `agent` — walk the tree,
  collect every attribute every word will ask of every subject.
  *Done looks like:* `SlimPickins.demands(path)` returns the list, and a test
  pins it against `ports.sp`.
- **The app is checked once, at boot** `agent` — every demand met, or an error
  naming the page, the line, the word and the attribute.
  *Done looks like:* renaming an attribute in roth's `Scenario` fails the boot
  rather than a render.
- **Did-you-mean** `agent` — the demand and the offer are both in hand at that
  moment, so the cost is nearly nothing.
  *Done looks like:* `this scenario has no ss_primary_amout — did you mean
  ss_primary_amount?`
- **What presents this attribute** `agent` — the same walk, inverted.
  *Done looks like:* one command answers it across every `.sp` file in a
  project.

## Phase 6 — Errors that teach

Cheap, and it compounds with everything above. 0.1's best-kept secret is that
its errors already speak the language rather than the implementation; almost
nothing has been done with that.

- **The failing line, in context** `agent` — with the subject chain that led to
  it, because "this page has no account" is true and unhelpful without knowing
  which page and which line.
- **A wall names its nearest word** `conv` — an unknown word is a typo more
  often than a gap, and the vocabulary is fifty entries long.

## Phase 7 — Subtraction

A language that only grows is not being designed. Applied to files, using the
project's own rule: **a word with no page behind it goes.**

- **The candidates, measured** `agent` — `icons.rb` and `markdown.rb` are ~90
  lines serving one word each, with the specimen as their only evidence, and
  specimen pages are not evidence. `bin/diff_roth.rb` compares against a page
  the port superseded. `PORTFOLIO.md`, `CONTENT.md` and `FIGURES.md` were the
  evidence for the vocabulary before there was code.
  *Done looks like:* for each, the pages that use it and whether any is real.
- **Cut** `dan` — the call is yours; the measurement is mine.
  *Done looks like:* the repo is smaller, and `check_grammar.rb` is still
  green.

---

## What 0.2 refuses to do

Stated up front, because the pressure will come and the refusals are why the
language is small.

- **No component library.** The vocabulary is presentation, not a design
  system's catalogue. `card`, `metric` and `badge` are the ceiling.
- **No client-side runtime.** 0.1 took roth's script from 249 lines to 25 by
  moving work to the server. A JavaScript companion would undo the most
  valuable thing this project has shown.
- **No plugin system.** The escape hatch is one module of Ruby methods, used
  once in 356 sentences. That is the right size.
- **No second syntax, ever.** Not for conditionals, not for loops, not for
  interpolation. Eight phases held the line; the ninth is where it usually
  breaks.
- **No general-purpose templating.** An invoice PDF or an XML feed is a
  different tool. The scope is web presentation.
- **No editing the dashboard to suit the language.** If a page cannot be said,
  that is a finding about the language, not a defect in the page.

## What "how far along" means

Phases 0 to 3 are small and retire four of the five High risks that a phase can
retire — one view, one extraction, one decision and one word. Phase 4 is the
largest by effort and confirms or destroys the central prediction. Phase 5 is
the point of the roadmap, and it is deliberately after the work that argues for
it.

**Phase 1 buys nothing a user could see, and it is second on purpose.** Phases
3 and 4 will want to add words, and adding them into an 842-line class with
twelve shared ivars is how the next three phases would quietly make the
language worse. It is the only item here that is cheaper early than late.

If Phase 0 fails, everything after it changes shape. That is why it is first,
and why it is forty-two lines.

The sixth High risk — that the language stays lovely — has no phase, because
nothing retires it. It is the one that will be lost slowly if it is lost at
all.

**The one thing I would most like to be true at the end of 0.2:** that someone
who did not build it wrote a page, got it wrong, and the language told them —
before it served anything — exactly which word was lying.
