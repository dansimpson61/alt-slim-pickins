# slim-pickins 0.2 — a blue-sky imagining

Written at the close of roadmap 0.1, 2026-08-31, as the thing the next roadmap
should argue with rather than the roadmap itself.

**0.1 asked: can a view language keep one sentence all the way down?** The
answer is yes, with fifty words, on two apps.

**0.2 should ask a harder question**, because the first one is answered and
asking it again on a third app would only produce a third number.

---

## Where 0.1 actually leaves us

Not "done". Narrowly proven.

| Proven | On what |
|---|---|
| One sentence carries a real app | roth: form, table, six figures, two charts |
| Inference is not a fantasy | 0 of 14 labels written in a page |
| Extension adds vocabulary, never syntax | eight phases, fifty words, zero grammar changes |
| A checker can hold docs and code together | 632 sentences, 65 rules, both gated |

| Unproven | Why |
|---|---|
| Anything irregular | `choose`/`when`/`otherwise` and `if:` have **no real page** |
| Navigation | roth had **no links**; `link show` still derives `/show` |
| Someone else's hands | every sentence in the repo was written by whoever wrote the words |
| Anything at scale | the largest page is 42 sentences |

The escape-hatch number — 1 use in 356 sentences — is the most quoted figure in
this project and the most misleading. Phase 7 established what it actually
measures: **the distance between what a page needs and where its data is.** It
fell from 1-in-36 to 1-in-115 not because the vocabulary grew but because the
data moved to the server. A third app that renders client-side would push it
straight back up, and that would say nothing about the words.

**0.2 should stop quoting it.**

---

## The idea 0.2 should be built around

> **The language knows what a page means. Nothing else in the stack does.**

This is the asset 0.1 built and never spent. A `.sp` file is not a template —
it is a parsed, checkable description of what a page presents, in fifty known
words, with every subject resolvable and every attribute traced to an app
object. `check_grammar.rb` already walks all 632 sentences and knows every word
in each. That is a rare position and almost nothing has been done with it.

Everything below follows from taking it seriously.

---

## 1. The page can answer questions about itself

Today the language renders. It could also **report**, without rendering
anything, because it already knows the whole tree.

```text
what presents .ss_primary_amount
  → roth/controls.sp:13   field ss_primary_amount
  → roth/report.sp:24     column ss_primary_amount
```

An attribute-to-page index falls out of the transform for free. So does the
inverse — every attribute a page will ask a subject for, before it is rendered:

```ruby
SlimPickins.demands("views/controls.sp")
#=> [:age_primary, :age_spouse, :trad_balance, …]
```

**Which makes the app contract checkable at boot rather than at render.** The
eleven-month rename that broke roth becomes a startup error the first time
anyone runs it, not a wrong number nobody sees. `CONTRACT.md` describes a
promise the language currently checks one attribute at a time, lazily, at the
worst possible moment. It does not have to.

This is the single highest-value thing in this document, and it is small.

## 2. The stylesheet stops being a second source of truth

`check_styles.rb` proves every emitted class has a rule and every rule
corresponds to a word. That is drift *detection*. The next step is not needing
it: **generate the class names from the word list**, and let a theme be what a
theme already nearly is — one `:root`.

Then `slim-pickins.css` is not a file anyone maintains alongside the
vocabulary; it is a projection of it, and the checker becomes a test of the
generator rather than a guard against human error.

Honest counterweight: hand-written CSS is *readable*, and generated CSS often
is not. If it costs the stylesheet's legibility, it is not worth it — this one
is a genuine trade, not a free win.

## 3. `.sp` files answer to something other than a browser

The tree is the point, and HTML is one rendering of it. Others are cheap once
the tree is real:

- **Plain text**, for an email or a terminal. `metric total_value` has an
  obvious text form; so does `table`.
- **A skeleton**, for a page whose data has not arrived — every word already
  knows its shape.
- **A diff of two pages**, structurally, in words rather than in markup.

None of these should be built speculatively. They are listed because they are
what having a tree *means*, and 0.1 spent it entirely on one target.

## 4. The vocabulary is finished; the *grammar of composition* is not

Fifty words is enough. The gap is not more words — it is that a page cannot
say a thing twice conveniently.

roth's report says `metric` six times and `column` ten times, and each line is
honest. But `each` exists precisely because repetition is a smell, and there is
no way to write:

```text
metrics from .headline_figures
```

…and get six of them, labelled and formatted, from a collection the app names.
`table` does exactly this for columns and nobody misses `row`. **The same move
is available for `metric`, `field` and `column`, and has not been made.**

That is the most likely place a fifty-first word earns its keep — and the most
likely place to over-reach, so it needs a page that hurts first.

## 5. Errors as a first-class surface

The best thing in 0.1 is barely advertised:

```text
this account has no name
nothing to ask for name — the subject is empty
this page has no account
```

Errors that speak the language rather than the implementation. 0.2 should push
this much further, because it is where a small language beats a large one:

- **Did-you-mean.** The subject knows its attributes and the vocabulary knows
  its words. `this scenario has no ss_primary_amout — did you mean
  ss_primary_amount?` is a three-line change and it is the single most useful
  thing a language can say.
- **The failing line, in context**, with the subject chain that led to it.
- **A page that will not render should say so before it is served**, which is
  §1 again from another direction.

## 6. What should be *cut*

A blue-sky document that only adds is a wish list.

- **`icons.rb` and the sprite.** Thirty-four lines serving one word, with a
  fixed set of symbols. It has one page of evidence — the specimen — and
  specimen pages are not evidence.
- **`markdown.rb`.** `prose` renders a hand-rolled safe subset. It is 55 lines
  of a problem other people have solved, and its only real use is the dashboard
  page that was drafted on paper and never built.
- **The three drafted-on-paper pages** — `PORTFOLIO.md`, `CONTENT.md`,
  `FIGURES.md` — have done their job. They were the evidence for the vocabulary
  before there was code; they are now three more documents to keep true.
- **`bin/diff_roth.rb`** compares against a hand-written page that the port has
  superseded.

Roughly 200 lines of library and four documents. The project's own rule — *a
word with no page behind it goes* — should be applied to files.

---

## What 0.2 should refuse to do

Stated plainly, because the pressure will come:

- **No component library.** The vocabulary is presentation, not a design
  system's catalogue. `card`, `metric` and `badge` are the ceiling.
- **No client-side runtime.** Phase 7 and 8 spent 250 lines of JavaScript down
  to 25 by moving work to the server. A JavaScript companion would undo the
  most valuable thing the project has demonstrated.
- **No plugin system.** The escape hatch is one module of Ruby methods and has
  been used once in 356 sentences. That is the right size.
- **No second syntax, ever.** Not for conditionals, not for loops, not for
  interpolation. Eight phases held the line; the ninth is where it usually
  breaks.
- **No general-purpose templating.** If someone wants to render an invoice PDF
  or an XML feed, that is a different tool. The scope is web presentation.

---

## The shape of the roadmap I would write

Same discipline as 0.1 — retire the risk you have no evidence for first — with
the risks reordered by what 0.1 learned.

**Phase 0 · A page nobody here designed.** Someone else writes a page, or an
existing app is ported without its vocabulary being adjusted to suit. Every
wall gets recorded. This is the top risk and 0.1 never touched it.

**Phase 1 · Conditional and bespoke UI.** The named gap. Find an app whose
pages are genuinely irregular — a wizard, a permissions screen, something with
real branching — and see whether `choose` survives contact or whether
conditionals need a better answer than "name the situation".

**Phase 2 · The contract, checked at boot.** §1. Small, and it retires the
class of failure that motivated the whole roth study.

**Phase 3 · Navigation.** `link`, `path_for`, and a page that actually moves
between things. Deferred twice for want of evidence; a multi-page app supplies
it.

**Phase 4 · Errors that teach.** §5. Cheap, and it compounds with everything.

**Phase 5 · Subtraction.** §6. Cut the words and files with no page behind
them. A language that only grows is not being designed.

`chart` should be left alone. It was redrafted against real evidence last and
is the newest thing here; the temptation to add bar, pie and a second axis
should be resisted until a page asks.

---

## The one thing I would most like to be true at the end of 0.2

That someone who did not build it wrote a page, hit a wall, and the error
message told them what to do.

Everything else in this document is an optimisation of a thing that already
works. That is the thing that has never been tried.
