# The Way

A primer for the language in this repository. [`DESIGN.md`](DESIGN.md) is the
grammar; [`VOCABULARY.md`](VOCABULARY.md) is the words; [`CONTRACT.md`](CONTRACT.md)
is the promise an app makes. This is the tour.

This document replaces the Slim-Pickins Way that described the old helper
layer — a vocabulary of `ui_` helpers embedded in Slim. This language is not
that. It has no Slim beneath it, no helpers to call, and no classes written by
hand. What follows describes what it *is*.

## The idea in one paragraph

A template should say **what is on the page**, not how to build it. `section
holdings` is what is on the page. `<div class="sp-cluster sp-cluster--between">`
is scaffolding. This language exists so that a page holds only the first kind
of line, and every piece of scaffolding — the markup, the classes, the
escaping, the loop — lives in one place where it can be fixed once.

A page in this language is a **description of what the page means**, in
sixty-four known words, with every subject resolvable. What the page means is checkable,
before it renders.

## The grammar, in one sentence

> **`word arguments`. Indentation nests it. Everything — elements, components,
> control flow, text — is a word. Extending the language adds vocabulary,
> never syntax.**

There are no sigils, no `=`, no `-`, no `|`, and no closing tags. A line is a
word, its arguments, and the lines indented beneath it:

```
page portfolio
  section holdings
    empty "No holdings yet."
    each holding
      card
        title .name
        money .market_value
```

Everything in that page is a word — the document, the section, the loop, the
card, the text. Nothing is a tag.

## The six argument kinds

Every part of a sentence is optional; the order never varies. There are
exactly six kinds, and each has exactly one spelling:

| Argument | Means | Example |
|---|---|---|
| `name` | a name — interpreted by the word to its left, never evaluated | `section products`, `button primary` |
| `"string"` | literal text | `note "Saved."` |
| `.property` | the current subject's data | `title .name` |
| `binding.property` | a local's or helper's data | `note order.number` |
| `key: value` | a modifier | `image .url, alt: .name` |
| *indented block* | children | |

The spelling rule is the whole of the morphology: **a dot means data, a bare
word is language.** Every value carries a dot. Every name does not.

```
section products      # no dot — a name the language interprets
button primary        # no dot — a name
title .name           # dot — the subject's data
note order.number     # dot — a binding's data
```

## One rule of resolution

`.foo` means the **innermost subject's** `foo`.

There is always a subject. The outermost one is the page itself, whose
attributes are the locals and helpers the app provides — VBA's implied
`Application`, borrowed and never written. So the same rule reads every level:

```
page account
  metric balance
  each holding
    money .market_value
```

`metric balance` asks the page for `balance`; `.market_value` asks the holding.
A typo raises — naming the attribute and the subject that lacked it — rather
than rendering blank. Nothing ever resolves to nothing.

A bare name is never evaluated. The words that take a subject — `page`,
`section`, `form`, `table`, `each` — resolve the name against this same chain,
which is what makes a collection nested inside another mean the obvious thing:
inside `each account`, `table holdings` finds *that account's* holdings.

## Names and content

A name is a subject; content is a label. The grammar tells them apart, so a
word's two jobs are visible in the page, never decided by what the data
happens to hold:

```
section accounts          # a name — the subject shifts to the accounts
section "Where you stand" # content — a heading, and nothing shifts
```

Which job a word's name slot does is fixed per word. `page`, `section`,
`form`, `table` and `each` take subjects; `button` and `badge` take variants;
`title` and `note` take no name at all. Each entry in
[VOCABULARY.md](VOCABULARY.md) says which. A word that names a subject that is
not there fails **on the line that named it** — quiet tolerance would relocate
the error away from its origin.

## One rule of government

A name is interpreted by the word to its left. A word is interpreted by the
word it is nested under.

So `column` means what it means inside `table`, `when` inside `choose`,
`field` inside `form` — and both governors are visible without scrolling, one
on the same line and one on the line above. A reader never carries state to
parse a sentence: the enclosing word tells you how to read the leading word,
and the leading word tells you how to read the rest of the line.

## The register

Counted across the sixty-four words: **59 carry the noun register** — two of them
plural by nature (`actions`, `contents`) — and the five non-nouns are
exactly the control flow (`each` a determiner,
`empty` an adjective, `choose` a verb, `when` a conjunction, `otherwise` an
adverb). A sentence is head noun plus specifier: the register of a
**label**, not of prose. That is why a page reads like a spec sheet of
itself:

```
page scenario
  group assumptions
    field horizon_years
  grid metrics, columns: 3
    metric lifetime_taxes
    metric tax_delta
```

Two words broke the register — `check` and `select` were verbs, imperatives
that described the user's action rather than the widget they render. Phase 1
renamed them `checkbox` and `choice`, and the sweep that found them is now
the instrument that keeps a third verb out.

## Inference, and the contract that makes it honest

A word plus an attribute name is enough, where the fact is mechanical. `field
base_income` derives the input name, the current value and the input type —
from the value's *class*, never from a schema:

```
field base_income
field age_primary, "Age (primary)"
field growth_rate, step: 0.01
```

The line where inference stops is the same line everywhere, and it is the
whole of the app contract: **mechanical facts derivable from a value's shape
are free; facts encoding a human judgement about the domain belong to the
app, and the language should ask rather than guess.** A number is
right-aligned unasked, because alignment follows from being a number. Whether
it is *money* follows from nothing the value knows.

So an app answers two optional questions — `label_for(attribute)` and
`format_for(attribute)` — and each answer sits in a three-level precedence,
owned by whoever knows most: the page said it, or the app said it, or the
language guessed in English. A plain `Struct`, a `Hash` or an ordinary PORO
satisfies the required half by doing nothing at all. The contract is one
sentence: *a subject answers the attributes it is asked for, by ordinary
method call.*

## Loops, tables, and the empty situation

The loop is written once, in the language, and never in a page. `each holding`
iterates `holdings`, binds `holding`, and makes each element the subject; a
`table` never says `each` at all, because its rows are its business:

```
table holdings
  column symbol
  column market_value, "Value"
  column gain, as: money
  total market_value, "Account total"
```

`column` registers rather than renders, so the header can be written before
the first row exists. `total` sums. The presentation is inferred — the
page says `as: money` only when it disagrees with the app's own `format_for`.

And the situation with nothing in it is **named**, not branched over:

```
section accounts
  empty "No accounts linked yet."
  each account
    card
```

`empty` is not `if accounts.empty?`. It is a word meaning *what this section
says when it has nothing*, and the enclosing word already knows what "empty"
refers to. When the collection is empty, `empty` renders and its siblings are
suppressed — a whole class of page state handled by naming it.

## Conditionals dissolve

Most branches should not be written, and the language's own vocabulary makes
most of them unnecessary: `empty` covers the empty collection, and the `if:`
modifier guards any single sentence. What remains — a real choice between
alternative contents — is the escape hatch of conditionals:

```
choose
  when .drifted?
    note warning, "Your allocation has drifted more than five percent."
  otherwise
    note quiet, "Allocation is on target."
```

`when` and `otherwise` are ordinary words valid inside `choose`; `else` is
never a keyword, so nothing needs special parsing. Measured across a real
app's 176 branches, 81% were the two cases this language dissolves — the
branch, most of the time, was the page failing to name its situation.

## Reuse: a layout and app words

A layout is chrome with a hole, written once. `contents` marks the hole, and
no page mentions the layout — `page` infers it, the same way it infers the
doctype and the flash:

```
stylesheet "/assets/slim-pickins.css"
nav
  link home, "Overview"
  link accounts
contents
footer "Approximate directional estimates. Not tax advice."
```

A partial is **a word an app defines**, written in the language, invoked
exactly like a built-in, taking the current subject. A reader cannot tell from
the call site which vocabulary a word came from:

```
each account
  account_card
```

An app word that collides with a slim-pickins word is an error, refused at
load — two meanings for one word is the alias problem wearing a new hat.

## The escape hatch

When the vocabulary has no word for what a page needs — a `<video>`, a
third-party embed — the app adds a word of its own, in Ruby:

```ruby
def video(*args, poster: nil)
  _, source = arguments(args)
  tag(:video, { class: token(:video), src: source, poster: poster,
                controls: true, playsinline: true })
end
```

The page then says:

```
video .tour_url
```

which reads exactly like `image .url`. Extending the language still adds
vocabulary and never syntax — even at the exit. An app word may use the whole
surface the vocabulary itself is written with: `token`, `html`, `element`,
`tag` and `arguments` for structure, `capture` for a word's children; `subject`, `chain`,
`label_for` and `format_of` for the contract; `register!` and
`with_gatherer` for gathering; `about`, `capture` and `prune` for the
subject flow. There is no other surface, and no secret one: the built-ins
and an app's words eat the same food, which a test enforces.

The hatch is for the genuinely missing word, and the vocabulary earns its keep
by making that rare: across every page in this repository, one app word covers
one need. (The older ratio-of-uses figure was retired in writing — it measured
where rendering happened, never the vocabulary's coverage.)

## The design system

No human writes a class in this language, so the class-naming convention *is*
the grammar, in four shapes:

| Shape | Example |
|---|---|
| `.word` | `.card` |
| `.word--variant` | `.note--warning` |
| `.word-part` | `.metric-label` |
| `.word-part--n` | `.chart-band--0` |

A reader who knows the language already knows the stylesheet. There is no
utility layer — `note quiet` replaces a class someone had to remember — and
every presentational value lives in one theme block, so a theme is one `:root`
and can miss nothing. [`check_styles.rb`](check_styles.rb) proves the
stylesheet and the runtime cannot drift apart.

Styling belongs to the theme's semantic roles and to a word's declared variants.
It does not belong to ad-hoc inline CSS. An author who writes `tag span, style: "..."`
has stepped outside the language and into machine code; the house discipline is
to speak the existing semantic roles and variants, or to propose a word or role
when genuine repetition demands it.

## The deductive structure (The Five Tiers)

Authoring in the language proceeds top-down, answering five deductive questions:

1. **Structure & Layout** (*What is the skeleton, geometry, or layout container?*):
   `page`, `section`, `grid`, `box`, `card`, `list`, `item`, `aside`, `nav`, `footer`, `scroll`, `contents`, `children`.
2. **Meaning & Domain** (*What does this content mean or represent?*):
   `title`, `heading`, `paragraph`, `prose`, `text`, `span`, `note`, `metric`, `fact`, `table`, `column`, `total`, `money`, `percent`, `number`, `time`, `chart` (`band`, `line`, `level`), `snippet`, `figure`.
3. **Controls & Actions** (*How does the user interact, input data, or trigger an action?*):
   `button`, `link`, `action`, `actions`, `field`, `input`, `textarea`, `checkbox`, `choice`, `option`, `search`, `tab`, `disclosure`.
4. **Flow, State & Dispatch** (*How does the page react, branch, iterate, or submit?*):
   `each`, `empty`, `choose`, `when`, `otherwise`, `form`, `hidden`, `flash`, `tabs`.
5. **Surfaces & Chrome** (*How is information surfaced, framed, or styled?*):
   `badge`, `stylesheet`, `script`, `iframe`.

### Porosity and the visual standard

Boundaries between tiers are porous. A `card` is simultaneously a structural container, an elevated visual surface, and an entity scope (`R3P2`). A `table` is semantic domain data, a structural grid, and an implicit behavioral loop. On the Studio shelf, words appear under **every** tier they participate in, marked with cross-category badges so authors find them wherever they naturally reach.

Crucially, **no word in the language exists solely for decorative paint.** Visual presentation belongs to the theme's semantic roles and to declared word variants (`note quiet`, `badge ok`). Words that appear in the visual tier represent chrome assets, isolated viewports, or semantic status dressed as a pill. The language describes *what is on the page*, never how to paint it.

## The Studio Workbench

The language ships with its own living environment: the studio (running on port
`4580`). The studio supports multiple UIs (`classic` and `workbench`), selected
via `?ui=` or switched via `/ui/:name`.

The workbench UI organizes authoring into two zones:
- **The Shelf**: Holds the 62 vocabulary words organized by the five-tier deductive
  hierarchy (with multi-category presence and secondary cross-facets), the
  repository's living pages with their census verdicts (verified against real data
  payloads), and the project guides.
- **The Work Area**: Provides live, debounced rendering as you type (300 ms),
  evaluating source and JSON data locals against the language's runtime,
  displaying the Visual and HTML outputs side by side.
- **Truthful Refusals**: When a page names a missing attribute or contract
  violation, the failure renders in the artifact pane as a *Refusal* page the
  language itself drew, speaking in the language's own terms.
- **Try-It Seeds**: Every vocabulary entry carries *"In the wild"* sentences
  cited from real code (`path:lineno`) and a Try-It link that seeds the
  workbench with the word and its real-world data payload.

## Where the language stops

Worth knowing before you fight it.

**There is no numeric literal.** Content is a quoted string or a dotted
value; a bare number is neither. A figure in a page has nowhere to stand — it
belongs to the app, which is the same division of labour as everywhere else:

```text
level 1000000.0, "A million"    # refused — not a sentence
level .standard_deduction, "Standard deduction"
```

**A word's arguments are evaluated before the word runs.** `.foo` asks the
*enclosing* subject, not the one the word is about to establish. So
`page pattern, .title` reads perfectly and cannot work; `pattern.title` is the
spelling:

```
page pattern, pattern.title
```

**Items are text, not objects.** A word cannot be handed a row from the
database; a collection finds its own data from its name, and reaching out by
name reaches the binding instead.

**A word takes the arguments its entry declares, and no others.** Where two
variants are needed, that is two words — the vocabulary carries the meaning,
and the grammar stays one sentence because of it.

**An unknown word fails with its own name.** Every word is a real method —
never `method_missing` — so a typo is loud, on the line, in the language's own
terms. Errors speak the language: `this account has no name`, not a Ruby
stack.

The rule when you hit one of these: **grow the language. Never work around it
in the page.**

## The ethos

What this document exists to carry forward, sentence by sentence:

- **The word carries the presentation; the argument carries the domain.**
  `money .market_value` means *present this as money*, and the formatting
  belongs to the word.
- **Grow the language, never work around it.** The fix for a missing word is a
  word — drafted against a real page, never invented in isolation.
- **A line that states the inferable should not exist.** `id .id` is the
  template doing the machine's job; `form scenario` under `page scenario`
  names the same subject twice.
- **A condition is named, not written.** `empty`, not `if … empty?`. Name the
  situation; let the enclosing word already know what it refers to.
- **Verify, don't assert.** Counts are measured and their coverage stated;
  rendered pages are looked at, because a checker cannot see everything and
  looking catches what checking structurally cannot.
- **Every truth has one home.** The grammar is implemented once and checked
  against, not re-implemented by the checker; a word's contract is declared
  once and its documentation derived from it. Two copies of a truth are one
  lie waiting.

## Adding a word

Sixty-four words is where the vocabulary stands, and the discipline for
the next is the same one that wrote the first sixty-four: draft it against a
real page that already hand-builds the thing, fill the seven slots (name,
content, modifiers, children, subject, infers, renders) without a blank, and
give it a sentence that [`check_grammar.rb`](check_grammar.rb) holds. A word
that fits no shape, or that breaks the noun register, has to argue for itself
in writing. The language grows by words, and that is the whole of its syntax.
