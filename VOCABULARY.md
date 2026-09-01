# Vocabulary — draft 3

Status: **implemented.** Fifty words, every one of them a real method on
`Builder` and every one exercised by a sentence somewhere in the repo —
`check_grammar.rb` fails if either stops being true.

Every entry has now been drafted against a real page. `chart` was the last
holdout — written on paper, unevidenced, and claiming inferences it did not
make — and Phase 8 redrafted it against roth's two charts, adding `band`,
`line` and `level` and cutting `pie`, `bar` and `area` for want of a page.

The grammar is settled and is one sentence ([DESIGN.md](DESIGN.md)). It cannot
really be wrong any more. The vocabulary *can* be incomplete, and in a language
where words are the only construct, every gap is a wall. So the vocabulary is
the risk, and this is the discipline for writing it.

Drafted against a real page — `roth/views/controls.slim`, a retirement
conversion tool — rather than invented examples, because invented examples are
the condition under which a vocabulary looks more complete than it is.

## What an entry must declare

The rule of government from DESIGN.md runs along both axes of the tree:

> A name is interpreted by the word to its left. A word is interpreted by the
> word it is nested under.

So every word needs **two** definitions, not one — what it governs in its
arguments, and what it governs in its children. Seven slots, each answered or
explicitly `none`:

**name** · **content** · **modifiers** · **children** · **subject** ·
**infers** · **renders**

## Rules for entries

1. **No blank slots.** An unanswered slot is a gap in the language, not a
   default. Write `none`.
2. **A name slot names one job** — the subject, a variant, a destination, an
   attribute. If it takes two, the word is doing two things and wants
   splitting.
3. **Every inference is overridable by saying the thing**, and the entry says
   how. A convention you cannot override is a trap.
4. **No word accepts the same information two ways.** Not as a name and a
   modifier, not as a child and a modifier. This is the alias problem.
5. **A word governs only its own children.** No word reaches past its parent
   or into a grandchild.
6. **Every word appears in at least one sentence that passes
   `check_grammar.rb`**, which also checks that every word used in a sentence
   is defined here.

## Universal modifier

`if:` guards any sentence in the language — the word renders only when the
condition holds. It is not repeated in the entries below.

---

# Document

### `page`

- **name** — the subject: what this page is about
- **content** — the page title
- **modifiers** — none
- **children** — anything
- **subject** — the named thing
- **infers** — the `<title>` and the top heading from the name; the doctype,
  `<html>`, `<head>` and `<body>` entirely; and any pending flash message,
  rendered in a conventional place. Override the title with content
- **renders** — the whole document

```
page portfolio
page portfolio, "Your retirement"
```

This absorbs `doctype`, which was the last thing in the grammar fitting no
rule. It is not a keyword; it is something `page` knows.

### `contents`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — nothing; it marks a place rather than presenting anything
- **renders** — the page's own sentences

```
contents
```

Only a layout has one, and a layout must have exactly one. It is the single
word that reuse needed: the chrome is written once, `contents` says where the
page goes, and no page mentions the layout at all.

### `meta`

- **name** — which metadatum (`description`, `viewport`, `charset`)
- **content** — its value
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — `charset` and `viewport` are emitted by `page` without being
  asked; naming them overrides the default
- **renders** — `<meta>` in the head

```
meta description, "A directional Roth conversion sketch."
```

### `stylesheet`

- **name** — none
- **content** — the path
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the app's base stylesheet is included by `page` without asking
- **renders** — `<link rel="stylesheet">` in the head

```
stylesheet "/css/base.css"
```

### `script`

- **name** — none
- **content** — the path
- **modifiers** — `defer:`
- **children** — none
- **subject** — unchanged
- **infers** — placement at the end of the body
- **renders** — `<script src>`

```
script "/js/app.js"
```

### `nav`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — `link`
- **subject** — unchanged
- **infers** — which link is the current page, and marks it; the accessible
  label. This is the part hand-written navigation always gets wrong
- **renders** — `<nav aria-label="Main">` wrapping a list of links

```
nav
nav secondary
```

Found by writing the portfolio page. It was named as under-tested in draft 1
and bit immediately, because every real page has navigation.

### `footer`

- **name** — none
- **content** — the text, when it is a single line
- **modifiers** — none
- **children** — anything, when it is not
- **subject** — unchanged
- **infers** — its position as the last thing in the page
- **renders** — `<footer>`

```
footer "Approximate directional estimates. Not tax advice."
```

---

# Structure

### `section`

- **name** — the subject this section presents; it must be there
- **content** — the heading text
- **modifiers** — none
- **children** — any presentation word; `empty` is governed here
- **subject** — the named thing. With no name, unchanged
- **infers** — the heading from the name (`holdings` → "Holdings"); the class
  from the name. Override the heading with content
- **renders** — `<section class="holdings"><h2>Holdings</h2>…</section>`

```
section holdings
section holdings, "What you own"
section summary, "Where you stand"
```

Six of ten sections across the drafted pages were headings rather than
subjects — `summary`, `allocation`, `projections`, `legend`, `lore`,
`specification`. They are now written as content, which is what content is
for, and they read the same.

Phase 2 first tried making the name shift the subject only when the subject
had it. dan's question — *what if a word can take a subject but it can also
just take a label?* — found the better answer, because the grammar already
distinguishes the two. The opportunistic version made a page's meaning depend
on data no reader could see, and would have let a new model attribute silently
change an untouched page. See the rule in [DESIGN.md](DESIGN.md).

### `group`

- **name** — the topic of the cluster
- **content** — the label
- **modifiers** — none
- **children** — anything; inside a `form`, fields
- **subject** — unchanged
- **infers** — the label from the name; renders as a `fieldset` with a
  `legend` inside a form, and a labelled `div` outside one
- **renders** — `<fieldset><legend>…</legend>…</fieldset>`

```
group assumptions
group assumptions, "Advanced assumptions"
```

### `grid`

- **name** — the variant: what the cells are
- **content** — none
- **modifiers** — `columns:`
- **children** — the cells, repeated as given
- **subject** — unchanged
- **infers** — the column count from the viewport
- **renders** — `<div class="grid grid--cards">`

```
grid cards
grid metrics, columns: 3
```

### `list`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — `item`
- **subject** — unchanged
- **infers** — an unordered list
- **renders** — `<ul>`

```
list plain
```

Draft 1 said each child became an item without saying so. That was cute and
false: it breaks the moment an item holds more than one thing, which is the
ordinary case. `list` governs `item` instead.

### `item`

- **name** — the variant
- **content** — the text, when it is a single line
- **modifiers** — none
- **children** — anything, when it is not
- **subject** — unchanged
- **infers** — nothing
- **renders** — `<li>`

```
list plain
  item
  item "Ruby logic before CSS before Stimulus."
```

### `table`

- **name** — the subject: the collection whose rows these are
- **content** — the caption
- **modifiers** — none
- **children** — `column`, `total`
- **subject** — the named collection; each row in turn for its columns
- **infers** — one row per element, in the collection's order. The loop is
  never written
- **renders** — `<table>` with head and body

```
table holdings
table holdings, "As of today"
```

### `column`

- **name** — the attribute of each row to show
- **content** — the header text
- **modifiers** — `as:` — the presentation word to use for each cell
- **children** — none
- **subject** — unchanged; `table` supplies each row in turn
- **infers** — the header from the name (`due_on` → "Due on"); each cell's
  value from that attribute; the cell's presentation and alignment from the
  value's type, so money is formatted and right-aligned without being asked.
  Override the header with content, the presentation with `as:`
- **renders** — one `<th>` in the head, one `<td>` per row

```
table holdings
  column symbol
  column market_value, "Value"
  column weight, as: percent
```

### `total`

- **name** — the column to total
- **content** — the label
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the sum over the table's collection; the same presentation the
  column uses. Override the label with content
- **renders** — a `<tfoot>` row

```
table holdings
  total market_value
  total market_value, "Portfolio"
```

### `card`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged; usually the element of an enclosing `each`
- **infers** — its DOM id from the subject, so `id` is never written
- **renders** — `<article class="card">`

```
card
card compact
```

### `actions`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — `link`, `button`
- **subject** — unchanged
- **infers** — that its children are the operations on the enclosing thing;
  their layout and spacing
- **renders** — `<div class="actions">`

```
actions
```

### `aside`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **infers** — that everything *not* in an `aside` is the main column, so no
  `main` word is needed; the column split and its collapse on small screens
- **renders** — `<aside>`

```
aside
```

Replaces the CSS arithmetic — a three-column grid whose body spans two — that
`dashboard/views/pattern.slim` uses to mean "sidebar".

### `disclosure`

- **name** — none
- **content** — the toggle label
- **modifiers** — `open:`
- **children** — the content that is revealed
- **subject** — unchanged
- **infers** — closed until opened; the toggle control and its state, so no
  script is written. Override with `open:`
- **renders** — `<details><summary>…</summary>…</details>`

```
disclosure "Show advanced assumptions"
disclosure "Show raw JSON", open: true
```

The whole point of this word is that `roth/views/controls.slim` spends a
button, an id, a data attribute, a CSS class and a JavaScript handler on it.

---

# Content

### `title`

- **name** — none
- **content** — the text
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — its heading level from how deep it sits, so `h2` versus `h3` is
  never chosen by hand
- **renders** — `<h2>`, `<h3>` …

```
title .name
title "Lifetime taxes"
```

`heading` was a second word for this and has been cut. One job, one word.

### `text`

- **name** — none
- **content** — the prose
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — a paragraph
- **renders** — `<p>`

```
text .summary
```

### `note`

- **name** — the variant
- **content** — the prose
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — a subdued paragraph; `quiet`, `warning` and `error` are the
  variants
- **renders** — `<p class="note note--warning">`

```
note "Coarse assumptions; not tax advice."
note warning, "Conversions above this bracket raise your IRMAA."
```

### `prose`

- **name** — the notation: `markdown`, `asciidoc`, `plain`
- **content** — the document
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — markdown when no notation is named; sanitises in every case.
  There is no way to ask for the content to be trusted instead
- **renders** — a `<div class="prose">` of rendered HTML

```
prose .content
prose plain, .raw_notes
```

The one word that renders markup, which is what lets the language have no
escaping sigil at all. Slim spends `=` versus `==` on this distinction;
here the safe thing is the only thing, and rich inline text — links inside
sentences, emphasis, lists inside paragraphs — is markdown's job rather than
the grammar's.

**The notation is a variant, but only across notations that share this
presentation.** Markdown, asciidoc and plain text all produce a block of
prose, so they are variants of one word. MathML, MusicXML and source code do
not: an equation, a score and a highlighted listing are three different
presentations, and the word carries the presentation. Grouping them under one
word would organise the vocabulary by *mechanism* — "things we pass through a
renderer" — which is the one axis this vocabulary deliberately does not use.
The immediate evidence is that `prose code, …` would alias `snippet`, which
already exists and renders something else.

### `badge`

- **name** — the variant: `ok`, `pending`, `neutral`, `warning`
- **content** — the label
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the label from the value when content is omitted; the variant
  from the value when it is a known status
- **renders** — `<span class="badge badge--ok">`

```
badge ok, "canonical"
badge .status
```

### `fact`

- **name** — the attribute
- **content** — the value
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the label from the name (`origin_project` → "Origin project");
  the value from that attribute when content is omitted
- **renders** — a `<dt>`/`<dd>` pair

```
fact origin, .origin_project
fact updated_at
```

The same information as `metric` at a different size — a labelled fact inline,
rather than a tile. Two presentations, so two words; the word carries the
presentation.

Called `detail` in draft 2, which was a misnomer: HTML's `<details>` is the
disclosure element, and this vocabulary already has `disclosure` for exactly
that. A reader who knows HTML would have read `detail` as the singular of
`<details>` and been wrong. `fact` collides with nothing and reads as prose.

### `snippet`

- **name** — the variant: the language, when it is code
- **content** — the text
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — that it is for copying: monospaced, selectable whole, not
  editable, with a copy control
- **renders** — `<pre>` with a copy button

```
snippet .lore
snippet ruby, .example
```

### `money`

- **name** — none
- **content** — the amount
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **infers** — the currency and locale from the app; whole dollars unless
  cents matter; a class on negatives so red is CSS's job, not the template's
- **renders** — `<span class="money money--negative">−$1,234</span>`

```
money .balance
money .tax_delta, precision: 2
```

Renamed from `price`. The word carries the presentation and the argument
carries the domain, so the word has to be the presentation — "format this as
currency" — not a domain noun. A portfolio has balances, not prices, and
`price .balance` would have read as a category error.

### `percent`

- **name** — none
- **content** — the fraction
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **infers** — that the value is a fraction and multiplies it; one decimal
  place
- **renders** — `<span class="percent">4.5%</span>`

```
percent .growth_rate
percent .weight, precision: 2
```

### `number`

- **name** — none
- **content** — the value
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **infers** — thousands separators from the locale
- **renders** — `<span class="number">750,000</span>`

```
number .shares
```

### `time`

- **name** — the variant: `date`, `datetime`, `relative`
- **content** — the moment
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the date format from the app's locale; a machine-readable
  attribute alongside the human text
- **renders** — `<time datetime="2026-08-30">30 August 2026</time>`

```
time .as_of
time relative, .updated_at
```

### `image`

- **name** — none
- **content** — the source
- **modifiers** — `alt:`
- **children** — none
- **subject** — unchanged
- **infers** — lazy loading; dimensions when the app can supply them
- **renders** — `<img>`

```
image .image_url, alt: .name
```

### `figure`

- **name** — none
- **content** — the caption
- **modifiers** — none
- **children** — the thing being figured: an `image`, a `chart`, a `snippet`
- **subject** — unchanged
- **infers** — that the caption belongs to the child, and associates them for
  screen readers
- **renders** — `<figure>` with a `<figcaption>`

```
figure "The studio index, as it stands"
```

Content is the caption and the child is the subject of it, which is the way
round that lets a figure hold a chart or a listing rather than only an image.

### `icon`

- **name** — which icon
- **content** — none
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — that it is decorative and hidden from screen readers unless it
  is the only content of a control
- **renders** — inline `<svg>`

```
icon warning
```

### `metric`

- **name** — the attribute
- **content** — the label
- **modifiers** — `as:`
- **children** — none
- **subject** — unchanged
- **infers** — the label from the name; the value from that attribute of the
  subject; the presentation from the value's type. Override the label with
  content, the presentation with `as:`
- **renders** — a stat tile: `<div class="metric"><h3>…</h3><div
  class="metric-value">…</div></div>`

```
metric lifetime_taxes, "Lifetime taxes"
metric roth_share, as: percent
```

Found by reading a real page, not by imagining one. `#metrics` in
`roth/views/controls.slim` is six hand-built tiles of identical shape.

### `chart`

- **name** — the collection to chart
- **content** — a caption
- **modifiers** — `over:` — which attribute the x axis reads
- **children** — `band`, `line`, `level`
- **subject** — becomes the collection, for its children
- **infers** — the scale, the axes and their ticks, the x labels from the
  singular of the name, every series label from the row's `label_for`, every
  value's formatting from the row's `format_for`, and the key from the series
- **renders** — inline `<svg>`

```
chart balances, "Projected balance"
  band total
```

**The same shape as `table`, and for the same reason.** A table declares its
columns and the rows come from the subject; a chart declares its series and the
points come from the subject. It was redrafted this way in Phase 8 against the
two real charts in `~/dev/roth` — before that it took parallel flat arrays, the
one data shape nothing else in the language uses, and claimed inferences it did
not make.

`chart years` reads each row's `year`. `over:` says it where the collection's
name does not singularise to an attribute the rows have; failing both, the axis
counts.

---

### `band`

- **name** — the attribute to draw
- **content** — a label, overriding the row's own
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — its label and its number formatting from the row
- **renders** — a filled `<path>`, stacked on the bands before it

```
chart years
  band base_income
  band social_security
```

Valid only inside `chart`. Bands accumulate: the second sits on the first, so a
chart of four bands is a stacked area and the top of the stack is the total.

---

### `line`

- **name** — the attribute to draw
- **content** — a label, overriding the row's own
- **modifiers** — `from:` — take the points from another collection
- **children** — none
- **subject** — unchanged
- **infers** — as `band`
- **renders** — a stroked `<path>`, over the bands rather than added to them

```
chart years
  line federal_tax
  line gross_income, "Do nothing", from: .baseline_years
```

Valid only inside `chart`. `from:` is the same modifier `each` takes and means
the same thing — this line is about something else. It is how a comparison is
laid over a chart without a second chart.

---

### `level`

- **name** — none
- **content** — the value, then a label
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — nothing; both its parts are said
- **renders** — a horizontal rule across the plot, labelled where it sits

```
chart years
  level .standard_deduction, "Standard deduction"
```

Valid only inside `chart`. A threshold, a target, a deduction — read against
the data rather than looked up in the key, which is why it is labelled in place
and does not appear there.

A level does not stretch the scale. The data sets the scale and a reference
that falls outside it is not drawn, because a threshold far above the data
tells a reader nothing and flattens everything that would have.

---

# Interaction

### `link`

- **name** — the destination
- **content** — the label
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the path from the name and the subject (`show` on a holding
  gives that holding's page); the label from the name when content is omitted
- **renders** — `<a href>`

```
link show
link show, "View holding"
```

### `button`

- **name** — the variant
- **content** — the label
- **modifiers** — `to:`, `type:`
- **children** — none
- **subject** — unchanged
- **infers** — `type="submit"` inside a `form`, `type="button"` outside one.
  Override with `type:`
- **renders** — `<button class="button button--primary">`

```
button primary, "Run"
button "Show baseline", to: baseline
```

### `form`

- **name** — the subject the form edits; omitted, it keeps the current one
- **content** — none
- **modifiers** — `to:`, `method:`
- **children** — `group`, `field`, `checkbox`, `choice`, `actions`
- **subject** — the named thing, so fields read their values from it
- **infers** — the action from the subject and the method from whether it
  exists yet. Override with `to:` and `method:`
- **renders** — `<form>`

```
form scenario
form to: run, method: post
```

Under `page scenario` the form's subject is already the scenario, so naming it
again states the inferable. A word that names no subject leaves the chain
alone.

### `field`

- **name** — the attribute
- **content** — the label
- **modifiers** — `type:`, `step:`, `required:`
- **children** — none
- **subject** — unchanged; reads from the form's subject
- **infers** — the input name from the attribute; the current value from the
  subject; the input type from the *value's class*, so a number is a number
  without being told. The label is inferred from the name only when that name
  already reads as English — acronyms, abbreviations and domain phrasing are
  not derivable and must be said. Override any of them
- **renders** — `<label>` plus `<input>`

```
field base_income
field age_primary, "Age (primary)"
field growth_rate, step: 0.01
```

Nine of these replace the eighteen hand-paired `label`/`input` lines in
`roth/views/controls.slim`, and none of them repeats the field's name three
times.

Phase 0 built this word and measured it. The name, value and type were right
every time; the label was right about three times in ten, which is why the
`infers` slot above no longer promises it unconditionally. See
[PHASE0.md](history/PHASE0.md).

### `checkbox`

Formerly `check`. Renamed in Phase 1: a verb describes the user's action
rather than the widget, and this is a noun language.

- **name** — the attribute
- **content** — the label
- **modifiers** — none
- **children** — none
- **subject** — unchanged; reads from the form's subject
- **infers** — the label from the name; checked state from the subject
- **renders** — `<label>` plus `<input type="checkbox">`

```
checkbox show_baseline, "Show baseline"
```

### `choice`

Formerly `select`. Renamed in Phase 1: `select` has no noun sense in English
outside HTML, and its children — `option` — already read as nouns.

- **name** — the attribute
- **content** — the label
- **modifiers** — none
- **children** — `option`
- **subject** — unchanged; reads from the form's subject
- **infers** — the label from the name; the selected option from the subject.
  When it has no `option` children, the choices come from the attribute's own
  domain
- **renders** — `<label>` plus `<select>`

```
choice conversion_strategy, "Strategy"
```

### `option`

- **name** — the value
- **content** — the label
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the label from the name. Override with content
- **renders** — `<option>`

```
choice conversion_strategy
  option fixed, "Fixed amount"
  option fill_bracket, "Fill bracket"
```

---

# Situation

### `each`

- **name** — the singular of the collection; also binds that name
- **content** — none
- **modifiers** — `from:`
- **children** — repeated once per element
- **subject** — each element in turn
- **infers** — the collection by pluralising the name (`holding` →
  `holdings`). Override with `from:`
- **renders** — nothing of its own; the children repeat

```
each holding
each holding, from: .taxable
```

### `empty`

- **name** — none
- **content** — what to say instead
- **modifiers** — none
- **children** — anything, when a sentence is not enough
- **subject** — unchanged
- **infers** — the condition: it renders when the enclosing subject has
  nothing in it, and suppresses its siblings when it does
- **renders** — `<p class="empty">`

```
empty "No holdings yet."
```

The word that proves the thesis. It is not `if holdings.empty?` — it names the
situation instead of writing the branch, and the enclosing `section` or
`table` already knows what "empty" refers to.

### `choose`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — `when`, `otherwise`
- **subject** — unchanged
- **infers** — that the first `when` whose condition holds wins, and that
  `otherwise` is last
- **renders** — nothing of its own

```
choose
```

### `when`

- **name** — none
- **content** — the condition
- **modifiers** — none
- **children** — what to render
- **subject** — unchanged
- **infers** — nothing
- **renders** — nothing of its own

```
choose
  when .in_stock?
```

### `otherwise`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — what to render
- **subject** — unchanged
- **infers** — that it is the last branch
- **renders** — nothing of its own

```
choose
  otherwise
```

---

## What drafting surfaced

Predictions from the spec, and what actually happened.

- **`heading` and `title` collapse.** Predicted, and confirmed — cut to
  `title`, which infers its level from depth.
- **`grid` and `list` collapse.** Predicted, and **wrong.** `grid` lays out
  cells that are already blocks; `list` makes its children into items. They
  govern their children differently, so they are two words.
- **`doctype`.** Absorbed by `page`. It was never a keyword, it was something
  `page` knows.
- **`price` was a domain noun, not a presentation word.** Renamed to `money`.
  Caught only by drafting against a portfolio, where "price" would have been
  a category error against a balance.
- **Three words the estimate missed entirely** — `metric`, `chart` and
  `disclosure` — all found by reading `roth/views/controls.slim`. Every one of
  them is hand-built there out of markup, classes and JavaScript.
- **Thirty-eight words**, against an estimate of forty. The estimate was
  close, but three of the additions were invisible until a real page was read,
  which is the argument against ever drafting this from imagination.

## What the drafts left open

Every item below was open when this document was drafted. All of them landed
during 0.1; the list is a record, not a to-do.

- **The `?` case.** Closed in Phase 4 — a bare helper used as a value has
  nowhere to live *because it should not*: the page is the outermost subject,
  so it is `.signed_in?` like everything else. Three real pages never reached
  the hole, which was the clue that it was not a hole in the language but a
  missing object at the bottom of the chain.
- **`chart`.** Redrafted in Phase 8 as the same shape as `table`; see its
  entry above.
- **What the app must promise.** Named in Phase 1, and written down in
  [CONTRACT.md](CONTRACT.md): one sentence plus two optional methods.
- **Under-tested by this page.** Prose and media were exercised by
  [CONTENT.md](history/CONTENT.md) and [FIGURES.md](history/FIGURES.md);
  navigation chrome by the layout; collections nested more than one deep by
  the portfolio page.
