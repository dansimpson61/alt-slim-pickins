# Vocabulary — draft 3

Status: **implemented.** Sixty-four words — 42 declared as Ruby classes and 22
written in the language — every one of them declared in its own file and every
one exercised by a sentence somewhere in the repo, which `check_grammar.rb`
fails if either stops being true. (The count is measured, not remembered: this
line said *fifty* for a fortnight after the vocabulary had grown to 64, which
is the drift the promise ledger and this daytrip exist to stop.)

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

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — `favicon:`
- **children** — anything
- **subject** — the named thing
- **conventions** — `document` — the doctype, html/head/body, the charset and the viewport; `title` — the `<title>` and the top heading, humanised from the name (override: `page portfolio, "Your retirement"`); `layout` — the chrome every page wears, with `contents` marking the hole (override: delete the layout, or move the page)
- **infers** — none
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


### `stylesheet`

- **name** — none
- **content** — text or data, when there is any
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
- **content** — text or data, when there is any
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
- **children** — `link`, `link_to`, `input`, `search`
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
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<footer>` element
- **infers** — its position as the last thing in the page
- **renders** — `<footer>`

```
footer "Approximate directional estimates. Not tax advice."
```

---

# Structure

### `section`

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — the named thing
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `box_tag` — the `<section>` element; `box_depth` — the depth their children's headings start at
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

- **name** — the topic
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `group_shape` — fieldset and legend; outside one, a div and an h2; `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — none
- **renders** — `<fieldset><legend>…</legend>…</fieldset>`

```
group assumptions
group assumptions, "Advanced assumptions"
```

### `hidden`

- **name** — a name
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the value from the subject when it is not said, the way `field`
  reads it. A hidden input is what a form carries without showing: the name
  and value travel with the submit.
- **renders** — `<input type="hidden">`

```
form to: "/actions/commit", method: post
  hidden path, .name
  hidden return_to, "/triage"
  button "Commit"
```

### `grid`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — `columns:`
- **children** — anything
- **subject** — unchanged
- **infers** — the column count from the viewport
- **renders** — `<div class="grid grid--cards">`

```
grid cards
grid metrics, columns: 3
```

The name says what the cells are: `grid cards`, `grid metrics`.

### `list`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — `item`, `each`
- **subject** — unchanged
- **conventions** — `box_tag` — the `<ul>` element
- **infers** — none
- **renders** — `<ul>`

```
list plain
```

Draft 1 said each child became an item without saying so. That was cute and
false: it breaks the moment an item holds more than one thing, which is the
ordinary case. `list` governs `item` instead.

### `item`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<li>` element
- **infers** — none
- **renders** — `<li>`

```
list plain
  item
  item "Ruby logic before CSS before Stimulus."
```

### `table`

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — `column`, `total`, `choose`, `each`
- **subject** — the named thing
- **conventions** — `table_rows` — the rows, so no page writes a loop
- **infers** — none
- **renders** — `<table>` with head and body

```
table holdings
table holdings, "As of today"
```

### `column`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `as:`
- **children** — none
- **subject** — unchanged; the enclosing word supplies each row in turn
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row; `table_header` — the header or series label — the row, then the enclosing subject, then English (override: say the header on the column or label on the series); `numeric_alignment` — right alignment; `format` — the presentation — `as:`, then the app, then the value's shape (override: `as:`)
- **infers** — each cell's value from that attribute
- **renders** — one `<th>` in the head, one `<td>` per row

```
table holdings
  column symbol
  column market_value, "Value"
  column weight, as: percent
```

### `total`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row; `format` — the presentation — `as:`, then the app, then the value's shape (override: `as:`)
- **infers** — the sum over the table's collection
- **renders** — a `<tfoot>` row

```
table holdings
  total market_value
  total market_value, "Portfolio"
```

### `card`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `card_id` — the DOM id, as `word-id` (override: say `id:` yourself); `box_tag` — the `<article>` element; `box_depth` — the depth their children's headings start at
- **infers** — none
- **renders** — `<article class="card">`

```
card
card compact
```

### `actions`

- **name** — none
- **content** — none
- **modifiers** — `path:`, `return_to:`
- **children** — anything
- **subject** — unchanged
- **conventions** — `partial_slot_forwarding` — that the value is sought up the chain — how `actions path:` reaches `action` (override: say it on the child instead)
- **infers** — that its children are the operations on the enclosing thing;
  their layout and spacing
- **renders** — `<div class="actions">`

```
actions
```

### `aside`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<aside>` element
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
- **content** — text or data, when there is any
- **modifiers** — `open:`
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<details>` element
- **infers** — none
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

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `heading_level` — its level, from how deep it sits (override: nest it differently; no page says a level)
- **infers** — none
- **renders** — `<h2>`, `<h3>` …

```
title .name
title "Lifetime taxes"
```

`heading` was a second word for this and has been cut. One job, one word.

### `text`

- **name** — none
- **content** — text or data, when there is any
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
- **content** — text or data, when there is any
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

- **name** — the notation
- **content** — text or data, when there is any
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

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `badge_status` — the variant class, when the body names a known status (override: name the variant: `badge ok`); `leaf_tag` — the `<span>` element
- **infers** — the label from the value when content is omitted
- **renders** — `<span class="badge badge--ok">`

```
badge ok, "canonical"
badge .status
```

The known variants are the statuses the vocabulary names — `ok`, `pending`,
`neutral`, `warning`, `error`, `blocker`, `polish` — and the stylesheet draws
each one's mark off the class the badge already wears (there is no `icon` word;
it was cut in 0.2 Phase 6, and this line went on naming it).

### `fact`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `format` — the presentation — `as:`, then the app, then the value's shape (override: `as:`)
- **infers** — the value from that attribute when content is omitted
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

- **name** — the notation
- **content** — text or data, when there is any
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
- **content** — text or data, when there is any
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **conventions** — `number_text` — grouped digits, the currency sign, the percent scale; `leaf_tag` — the `<span>` element
- **infers** — whole dollars unless cents matter; a class on negatives so
  red is CSS's job, not the template's
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
- **content** — text or data, when there is any
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **conventions** — `number_text` — grouped digits, the currency sign, the percent scale; `leaf_tag` — the `<span>` element
- **infers** — one decimal place
- **renders** — `<span class="percent">4.5%</span>`

```
percent .growth_rate
percent .weight, precision: 2
```

### `number`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **conventions** — `number_text` — grouped digits, the currency sign, the percent scale; `leaf_tag` — the `<span>` element
- **infers** — none
- **renders** — `<span class="number">750,000</span>`

```
number .shares
```

### `time`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `time_text` — the rendered date, and the machine `datetime` attribute (override: `time relative, .stamp`); `leaf_tag` — the `<time>` element
- **infers** — none
- **renders** — `<time datetime="2026-08-30">30 August 2026</time>`

```
time .as_of
time relative, .updated_at
```

The variants are `date`, `datetime` and `relative`.

### `figure`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<figure>` element
- **infers** — that the caption belongs to the child, and associates them for
  screen readers
- **renders** — `<figure>` with a `<figcaption>`

```
figure "The studio index, as it stands"
```

Content is the caption and the child is the subject of it, which is the way
round that lets a figure hold a chart or a listing rather than only an image.

### `metric`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `as:`
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `format` — the presentation — `as:`, then the app, then the value's shape (override: `as:`)
- **infers** — the value from that attribute of the subject
- **renders** — a stat tile: `<div class="metric"><h3>…</h3><div
  class="metric-value">…</div></div>`

```
metric lifetime_taxes, "Lifetime taxes"
metric roth_share, as: percent
```

Found by reading a real page, not by imagining one. `#metrics` in
`roth/views/controls.slim` is six hand-built tiles of identical shape.

### `chart`

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — `over:`
- **children** — `band`, `line`, `level`, `each`, `choose`
- **subject** — the named thing
- **conventions** — `chart_axis` — the axis labels, from each row's singular (override: `over:` names the attribute); `format_family` — number, percent or money, from the value (override: `as:`); `table_header` — the header or series label — the row, then the enclosing subject, then English (override: say the header on the column or label on the series)
- **infers** — the scale, the axes and their ticks, and the key from the
  series
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

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row
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

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `from:`
- **children** — none
- **subject** — unchanged
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row
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
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row
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
- **content** — text or data, when there is any
- **modifiers** — `to:`, `active:`
- **children** — none
- **subject** — unchanged
- **conventions** — `link_href` — `href="/show"` (override: `to:`); `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — none
- **renders** — `<a href>`

```
link show
link show, "View holding"
```

### `button`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — `to:`, `target:`, `type:`, `size:`
- **children** — none
- **subject** — unchanged
- **conventions** — `button_type` — `type="submit"`; outside one, `type="button"` (override: `type:`)
- **infers** — none
- **renders** — `<button class="button button--primary">`

```
button primary, "Run"
button "Show baseline", to: baseline
```

### `form`

- **name** — the subject this word presents; it must be there
- **content** — none
- **modifiers** — `to:`, `method:`, `target:`
- **children** — `group`, `field`, `checkbox`, `choice`, `actions`, `disclosure`, `button`, `hidden`, `input`, `textarea`, `choose`
- **subject** — the named thing
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
- **content** — text or data, when there is any
- **modifiers** — `type:`, `step:`, `required:`
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `input_type` — the input type, from the value's class (override: `type:`); `input_step` — `step="0.01"` (override: `step:`); `boolean_field` — that the field is a checkbox, because a value that is already true or false knows the shape it wants (override: `type: text`)
- **infers** — the input name from the attribute; the current value from the
  subject
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

### `input`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `type:`, `placeholder:`
- **children** — none
- **subject** — unchanged
- **conventions** — `input_type` — the input type, from the value's class (override: `type:`)
- **infers** — the current value from the subject. Unlike `field`,
  it says no label — a search box names nothing, it just sits there.
- **renders** — a bare `<input>`

```
input q, placeholder: "search…"
```

### `textarea`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `rows:`, `required:`, `readonly:`
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — the name and the current value from the subject, as
  `field` reads them.
- **renders** — `<label>` plus `<textarea>`

```
form
  textarea notes, "What changed?", rows: 3
```

### `checkbox`

Formerly `check`. Renamed in Phase 1: a verb describes the user's action
rather than the widget, and this is a noun language.

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — the checked state from the subject
- **renders** — `<label>` plus `<input type="checkbox">`

```
checkbox show_baseline, "Show baseline"
```

### `choice`

Formerly `select`. Renamed in Phase 1: `select` has no noun sense in English
outside HTML, and its children — `option` — already read as nouns.

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — `option`, `choice`, `each`
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `option_selected` — which option is selected, by comparing value to value
- **infers** — the choices from the attribute's own domain when it has no
  `option` children
- **renders** — `<label>` plus `<select>`

```
choice conversion_strategy, "Strategy"
```

### `option`

- **name** — the value
- **content** — text or data, when there is any
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
- **children** — anything
- **subject** — each element in turn
- **conventions** — `plural_collection` — which collection to read — `y`→`ies`, otherwise `+s` (override: `from:` on the collection word); `singular_binding` — that the bound name is `holding`, reachable from inside (override: name it something else and say `from:`); `subject_or_collection` — that the subject *is* the collection, so it iterates itself
- **infers** — none
- **renders** — nothing of its own; the children repeat

```
each holding
each holding, from: .taxable
```

### `empty`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `empty_situation` — that `empty` renders and its siblings do not
- **infers** — none
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
- **conventions** — `first_truthy_branch` — that exactly one branch renders — the first that holds (override: two sequential `choose`s for two independent rows)
- **infers** — none
- **renders** — nothing of its own

```
choose
```

### `when`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
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
- **children** — anything
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


### `action`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `to:`, `path:`, `return_to:`, `variant:`, `status:`
- **children** — none
- **subject** — unchanged


### `flash`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged


### `search`

- **name** — none
- **content** — none
- **modifiers** — `q:`, `placeholder:`, `to:`
- **children** — none
- **subject** — unchanged

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
- **Under-tested by this page.** Prose and media, navigation chrome, and
  collections nested more than one deep were exercised by the original paper
  pages (retired in Phase 6).

### `children`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — none
- **subject** — unchanged

Marks where the caller's children go, inside a partial's body. A partial
that took no children has nothing to splice, and says so.

```
children
```

### `paragraph`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged

The atom under the leaf presenters — `note` and `text` are its vocabulary.
A partial composes over it the way a Ruby word composes over `tag`.

```
paragraph quiet, "A quieter line."
```


### `box`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — `open:`, `id:`
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_body_over_children` — that the body renders *instead of* the children (override: give the box children and no content)

The atom under the wrappers — the box a word owns. Classes still derive
from the word, so nothing a human could style by hand comes back.

```
box shelf
  card
```


### `heading`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `heading_level` — its level, from how deep it sits (override: nest it differently; no page says a level); `box_title` — that it is the box's title, at the box's own level (override: use `title` or `text` instead)

The atom under `title` — the heading level derives from where it sits,
which is a tree fact the interpreter reads.

```
heading "A line worth a heading."
```


### `span`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged


### `figcaption`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged


### `summary`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged



### `iframe`

- **name** — a name
- **content** — none
- **modifiers** — `src:`, `srcdoc:`, `width:`, `height:`
- **children** — none
- **subject** — unchanged

```
iframe preview
iframe report, src: "/projection"
```

The name is the frame's `name` attribute, which is what a `form` targets: a
form whose `target:` is `preview` renders into the frame called `preview`,
and the page never reloads. That is the whole mechanism, and it is HTML's.


### `tabs`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged

```
tabs
  tab "Visual", active: true
    paragraph "What the page looks like."
  tab "HTML"
    paragraph "What it emits."
```

The panels are switched by a radio input and its labels — no script. `tabs`
draws the nav from the tabs it holds, so the two never disagree about how
many there are.


### `tab`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `active:`
- **children** — anything
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page)

```
tab "Raw HTML"
tab "Visual", active: true
```

The content is the tab's label; `active:` says which panel opens first. A
`tab` outside a `tabs` renders its panel and no nav, which is the honest
degradation rather than an error.


### `scroll`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged

