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
  fixed set of symbols. Its only users are `pages/figures.sp` and
  `pages/specimen.sp` — **both also on this list**, which is circular evidence
  and worse than none. The dashboard uses no icons at all.
- ~~**`markdown.rb`**~~ — **wrong, and worth leaving visible.** I listed it
  after checking the specimen and not the subject. Three dashboard views render
  markdown (`brief`, `doc`, `pattern`), so `prose` is needed by the very port
  0.2 is built around. Measured, it handles paragraphs, headings, lists, bold,
  inline code, links and blockquotes but **not code fences, tables or ordered
  lists** — all of which appear in the documents those views display. It is a
  gap to decide about, not a thing to cut.
- **The three drafted-on-paper pages** — `PORTFOLIO.md`, `CONTENT.md`,
  `FIGURES.md` — have done their job. They were the evidence for the vocabulary
  before there was code; they are now three more documents to keep true.
- **`bin/diff_roth.rb`** compares against a hand-written page that the port has
  superseded.

Roughly 100 lines of library and four documents. The project's own rule — *a
word with no page behind it goes* — should be applied to files, and **only
after checking the app the roadmap is about.** That is how `markdown.rb` got
onto this list, in a document that says verify before asserting.

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

## The candidate: `~/dev/dashboard`

Added after reading it. It is a better Phase 0 than anything invented, and it
changes the roadmap below.

**It is twenty times roth.** 23 views, **1,555 lines** of Slim against roth's
91. The largest single view is 305 lines; the largest page written here is 42
sentences.

**It is the sibling project's reference consumer.** The dashboard is built on
`~/dev/slim-pickins` — 1,495 lines, eighteen `ui_*` helpers — and it has
**already invented app words**: `words/attention.rb`, `words/ports.rb`,
`words/projects.rb` and four more, each a Ruby class, each said as a bare word
in a page. Two experiments converged on the same idea independently. A port
would be the only head-to-head comparison of them on the same app that will
ever be available.

**And it is the missing evidence, exactly.** Measured across all 23 views:

| | count |
|---|---|
| branch lines (`if` / `unless` / `else`) | **233** |
| `each` loops | 71 |
| interpolated `href` — routing | **65** |
| hidden form inputs | **91** |
| forms, over 24 distinct POST endpoints | 41 |
| inline `style=` attributes | **180** |
| `ui_*` helper calls | 107 |

roth had **zero** branches, one form and no links. Everything 0.1 could not
test is here in quantity.

### The encouraging half

Classifying all 176 `if`s by what they actually test:

| what it branches on | count | already dissolved by |
|---|---|---|
| a collection being empty or not | **73** | `empty` |
| the presence of one thing | **69** | the `if:` modifier |
| comparison to a value | 17 | `choose` / `when`, or an app predicate |
| compound and other | 17 | the same |

**142 of 176 — 81% — are the two cases the language already turns into
vocabulary.** That is the strongest evidence yet for "conditionals dissolve
into vocabulary; do not write the branch, name the situation", and it comes
from a page nobody here designed.

Stated honestly: this is static analysis of what the branches *test*, not a
port. It says the odds are good, not that it works.

### The three real blockers

**1. Routing — 65 interpolated hrefs.** `href="/projects/#{p[:path]}"`. The
question deferred twice for want of evidence. The dashboard is nothing but
navigation, and it settles it.

**2. Hidden form values — 91 of them.** Every action carries `path`,
`return_to`, sometimes `cmd`. There is **no word for a value a form carries but
does not show**, and this is a genuine gap rather than a thing to route around.

**3. 180 inline styles.** `style="justify-content: space-between; align-items:
baseline; gap: 1rem;"`, over 41 distinct `sp-` classes. Most of these should
*not* port — they are what `grid`, `actions`, `card` and `section` exist to
replace. But some will not map, and the honest outcome is a list of what a page
still cannot say about arrangement.

Softer, and all previously solved: views calling `Scan.port_open?` and
`Arrival.greeting` directly, `.first(5)` slicing in the page, and headings built
by interpolation. Every one is the roth `Projection` pattern again — move it to
a presenter and let the page name an attribute.

### The caveat that matters

**The dashboard is the tool dan runs everything else with.** A port must be a
parallel set of views that can be thrown away, never a replacement, and the
existing app must keep working untouched throughout — the same discipline that
kept `~/dev/roth` clean through two phases.

---

## The shape of the roadmap I would write

Same discipline as 0.1 — retire the risk you have no evidence for first — with
the risks reordered by what 0.1 learned.

**Phase 0 · One dashboard view, chosen for difficulty.** Not the easiest —
`ports.slim` at 42 lines, which has a form, a hidden field, an interpolated
href, a conditional list and an app word, in miniature. It is the whole problem
at a size that can be thrown away. Done looks like: it renders, or a list of
exactly what stopped it.

**Phase 1 · Navigation, settled.** Forced by Phase 0 rather than chosen. Does
`link` ask the app for a path — `path_for(name, subject)`, the same shape as
`label_for` and `format_for` — or are routes said with `to:`? 65 hrefs is
enough evidence to decide, and the precedent from Phases 0 and 2 says ask.

**Phase 2 · The word for what a form carries.** 91 hidden inputs say this is
real vocabulary, not an escape. It is the first genuinely new word since the
chart redraft, and it should be drafted the way every good one was — against
the pages that need it, after they have hurt.

**Phase 3 · The rest of the dashboard, in anger.** Conditional and bespoke UI
at 1,555 lines. Does `choose` survive contact? Do the 81% really dissolve? What
does a page still fail to say about arrangement?

**Phase 4 · The contract, checked at boot.** §1. Small, and by now the port
will have made the case for it several times over.

**Phase 5 · Errors that teach.** §5. Cheap, and it compounds with everything.

**Phase 6 · Subtraction.** §6. Cut the words and files with no page behind
them. A language that only grows is not being designed.

`chart` should be left alone. It was redrafted against real evidence last and
is the newest thing here; the temptation to add bar, pie and a second axis
should be resisted until a page asks.

---

## The question for 0.2

0.1's proscriptions were liberating because each one removed an escape and
forced a discovery. No `div`, so components had to be words. No syntax, so
extension had to be vocabulary. No numeric literal, so figures had to belong to
the app. Nothing was ever added to get around them, and the language is small
because of it.

0.1 asked a question about **expression**:

> *Can a view language keep one sentence all the way down?*

It can. Fifty words, two apps, no grammar changes. Asking it again of a third
app produces a third number and no new knowledge.

The asset 0.1 built and never spent is that **a page is now a described thing**
— a parsed tree in fifty known words, every subject resolvable, every attribute
traceable to an app object. So 0.2's question should be about **knowledge**:

> ### *What can a language do for you, once it knows what every page means?*

And the proscription that would force the answer, in the same family as the
others:

> ### **A page may not render until the app has been proved able to answer it.**

No lazy failure. No rendering thirty lines and raising on the thirty-first. A
page declares what it demands, the app is checked against it once, and a
mismatch is a boot error with a name.

It is a proscription because it removes an ability the language currently has —
**the ability to fail late** — and like the others it looks like a restriction
and pays like a tool:

- roth's eleven-month silent rename becomes an error the first time anyone
  starts the app.
- The attribute-to-page index falls out of the same walk, so *what presents this
  field* becomes answerable.
- Did-you-mean becomes possible, because the demand and the offer are both in
  hand at the same moment.
- `CONTRACT.md` stops being prose describing a promise and becomes a thing that
  is checked.
- And a tree that can be walked without rendering is a tree that can be
  rendered as something other than HTML.

Every item in §1 through §5 of this document is a consequence of that one
proscription. That is the test of a good one.

## The one thing I would most like to be true at the end of 0.2

That someone who did not build it wrote a page, got it wrong, and the language
told them — before it served anything — exactly which word was lying.

Everything else here is an optimisation of a thing that already works. That is
the thing that has never been tried.
