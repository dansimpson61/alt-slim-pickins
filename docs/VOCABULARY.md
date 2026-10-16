# Vocabulary

Status: **implemented.** Sixty-four canonical words — 38 Ruby primitives and 26
`.sp` composed words — every one declared with an explicit contract and every
one exercised by a sentence in the repository, held by `check_grammar.rb`.

The grammar is one sentence ([`DESIGN.md`](DESIGN.md)). The vocabulary is the
language's substance, and this document defines the canonical contract for every
word across the five authoring categories:

1. **Substance — Domain Content & Phrasing** (18 entries)
2. **Skeleton — Structure & Framing** (18 entries)
3. **Affordances — Controls & Interactions** (16 entries)
4. **Flow & Logic — State & Behavior** (6 entries)
5. **Environment — Document & Splicing** (6 entries)

## What an entry declares

The rule of government from [`DESIGN.md`](DESIGN.md) runs along both axes of the
tree:

> A name is interpreted by the word to its left. A word is interpreted by the
> word it is nested under.

Every word answers both axes across seven slots, each answered or explicitly
`none`:

**name** · **content** · **modifiers** · **children** · **subject** ·
**infers** · **renders**

When a word triggers registered conventions from [`CONVENTIONS.md`](CONVENTIONS.md),
the **conventions** bullet is generated directly from the word's contract.

## Rules for entries

1. **No blank slots.** An unanswered slot is a gap in the language, not a
   default. Write `none`.
2. **The universal convention model governs argument slots:**
   - *Target:* A bare positional target (`word target`) resolves against context (`subject`, `locals`, `helpers`), automatically inferring `.label`, `.id`, `.noun`, and `.target`.
   - *Override:* An explicit second positional argument overrides the inferred label (`word target, "Override"`).
   - *Kwargs:* Keyword arguments (`key: value`) serve as the universal configuration mechanism for options and modifiers.
3. **Every inference is overridable by saying the thing**, and the entry says
   how.
4. **No word accepts the same information two ways.** Not as a name and a
   modifier, and not as a child and a modifier.
5. **A word governs only its own children.** No word reaches past its parent or
   into a grandchild.
6. **Every word appears in at least one sentence that passes
   `check_grammar.rb`.**

## Universal modifier

`if:` guards any sentence in the language — the word renders only when the
condition holds. It is not repeated in the individual entries below.

---

# 1. Substance (Domain Content & Phrasing)

*What domain content, quantitative data, or phrasing does this express?*

## Typography & Phrasing

### `heading`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `heading_level` — its level, from how deep it sits (override: none, by design: the nesting is the outline); `box_title` — that it is the box's title, at the box's own level (override: use `title` or `text` instead)
- **infers** — the heading tag level (`<h2>`, `<h3>`, `<h4>`) from its nesting depth inside enclosing landmarks and containers
- **renders** — `<h2>`, `<h3>`, …

```
heading "A line worth a heading."
```

A Ruby primitive. The core typography atom beneath `title` and container
headings. Inside a `card` or `box`, a `heading` acts as that container's title
at the container's own outline depth.

### `title`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `heading_level` — its level, from how deep it sits (override: none, by design: the nesting is the outline)
- **infers** — the text from the named attribute when content is omitted
- **renders** — `<h2>`, `<h3>`, … via `heading`

```
title .name
title "Lifetime taxes"
```

A `.sp` composed word (`def title target, text`) wrapping `heading`. Presents a
child heading inside a container without claiming the container's own box title
slot.

### `paragraph`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **infers** — none
- **renders** — `<p class="paragraph">`

```
paragraph quiet, "A quieter line."
```

A `.sp` composed word (`def paragraph variant, text`). The block phrasing
foundation beneath `text` and `note`, supporting both inline content and nested
phrasing children.

### `text`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — a plain body paragraph
- **renders** — `<p class="text">`

```
text .summary
```

A `.sp` composed word (`def text words`) delegating to `paragraph`. The everyday
sentence for a single line of domain text.

### `note`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — a subdued or toned callout paragraph (`quiet`, `warning`, `error`)
- **renders** — `<p class="note note--warning">`

```
note "Coarse assumptions; not tax advice."
note warning, "Conversions above this bracket raise your IRMAA."
```

A `.sp` composed word (`def note tone, text`) over `paragraph`. Gives an
annotation or callout an explicit semantic tone.

### `flash`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — banner alert styling for transient route feedback
- **renders** — `<p class="flash">`

```
flash .notice
```

A `.sp` composed word (`def flash text`) over `note`. Surfaces a route-level
notification or confirmation banner.

### `prose`

- **name** — the notation
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — `markdown` when no notation is named; escapes and sanitizes all HTML before rendering markdown constructs
- **renders** — `<div class="prose">` containing rendered HTML

```
prose .content
prose plain, .raw_notes
```

A Ruby primitive. The single word in the language that renders formatted prose
markup (`markdown` or `plain`). Because `prose` escapes raw HTML first and only
emits tags from known markdown patterns, templates never need an unescaped
output sigil.

### `snippet`

- **name** — the notation
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<pre>` element
- **infers** — preformatted monospace code block presentation with optional language notation (`ruby`, `sp`, `html`)
- **renders** — `<pre class="snippet snippet--ruby"><code>…</code></pre>`

```
snippet .lore
snippet ruby, .example
```

A `.sp` composed word (`def snippet notation, body`). Presents source code or
command output in a `<pre><code>` block.

### `span`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **infers** — inline phrasing or value formatting when invoked by a value presenter
- **renders** — `<span class="span">`

```
span quiet, .detail
```

A Ruby primitive. The inline leaf phrasing atom beneath `badge`, `money`,
`percent`, `number`, and `time`.

## Data & Metrics

### `metric`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `as:`
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `format` — the presentation — `as:`, then the app, then the value's shape (override: `as:`)
- **infers** — the value from the named attribute on the current subject, its human label, and its domain format
- **renders** — `<div class="metric"><h3 class="metric-label">…</h3><div class="metric-value">…</div></div>`

```
metric lifetime_taxes, "Lifetime taxes"
metric roth_share, as: percent
```

A `.sp` composed word (`def metric attribute, label`). Presents a key-value
figure as a prominent stat tile, deriving both its heading label and formatted
value from a single attribute name.

### `fact`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `box_tag` — the `<dl>` element; `label` — the human label — the page, then the app, then English (override: say the label in the page); `format` — the presentation — `as:`, then the app, then the value's shape (override: `as:`)
- **infers** — the value from the named attribute when content is omitted, plus its label and format
- **renders** — `<dl class="fact"><dt>…</dt><dd>…</dd></dl>`

```
fact origin, .origin_project
fact updated_at
```

A `.sp` composed word (`def fact attribute, value`). Presents the same
attribute-and-value pair as `metric`, sized for compact inline metadata rather
than a headline tile.

### `number`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **conventions** — `number_text` — grouped digits, the currency sign, cents when the value has them, the percent scale; `leaf_tag` — the `<span>` element
- **infers** — digit grouping and up to two decimal places when fractional
- **renders** — `<span class="number">750,000</span>`

```
number .shares
```

A `.sp` composed word (`def number amount`) over `span`. Formats numeric quantities
with grouped thousands and true minus signs on negative values.

### `money`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **conventions** — `number_text` — grouped digits, the currency sign, cents when the value has them, the percent scale; `leaf_tag` — the `<span>` element
- **infers** — whole dollars unless cents are present; `.money--negative` on negative amounts
- **renders** — `<span class="money money--negative">−$1,234</span>`

```
money .balance
money .tax_delta, precision: 2
```

A `.sp` composed word (`def money amount`) over `span`. Carries currency
presentation while the argument carries the domain attribute.

### `percent`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `precision:`
- **children** — none
- **subject** — unchanged
- **conventions** — `number_text` — grouped digits, the currency sign, cents when the value has them, the percent scale; `leaf_tag` — the `<span>` element
- **infers** — scales a ratio by 100 with one decimal place by default
- **renders** — `<span class="percent">4.5%</span>`

```
percent .growth_rate
percent .weight, precision: 2
```

A `.sp` composed word (`def percent ratio`) over `span`. Formats a decimal ratio
as a percentage.

### `time`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `time_text` — the rendered date, and the machine `datetime` attribute (override: `time relative, .stamp`); `leaf_tag` — the `<time>` element
- **infers** — human-readable calendar formatting alongside the ISO-8601 `datetime` attribute
- **renders** — `<time class="time" datetime="2026-08-30">30 August 2026</time>`

```
time .as_of
time relative, .updated_at
```

A `.sp` composed word (`def time variant, stamp`) over `span`. Supports `date`,
`datetime`, and `relative` ("today", "yesterday", "4 days ago", "in 3 days").

### `badge`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `badge_status` — the variant class, when the body names a known status (override: name the variant: `badge ok`); `leaf_tag` — the `<span>` element
- **infers** — the status variant (`ok`, `pending`, `neutral`, `warning`, `error`, `blocker`, `polish`) from the content when no variant is named
- **renders** — `<span class="badge badge--ok">`

```
badge ok, "canonical"
badge .status
```

A `.sp` composed word (`def badge status, label`) over `span`. Draws a semantic
status pill whose color and mark come from the theme's status roles.

### `dictionary`

- **name** — the topic
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — `on`, `otherwise`
- **subject** — unchanged
- **infers** — string, symbol, boolean, and `nil` key indifference when matching the topic value against `on` entries
- **renders** — the matching `on` branch or `otherwise` fallback

```
dictionary .status
  on active, badge
  otherwise
    note quiet, "Inactive"
```

A Ruby primitive. Evaluates a domain value (such as `.status`) and dispatches to
the matching `on` clause, or `otherwise` when no key matches. When given a
second positional argument (`dictionary .status, .label`), forwards that content
to any target word named on the matching `on` line.

### `total`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row; `format` — the presentation — `as:`, then the app, then the value's shape (override: `as:`)
- **infers** — the sum of the named attribute across the enclosing table's rows
- **renders** — a `<tfoot>` summary row aligned with the table's columns

```
table holdings
  column symbol
  column market_value, as: money
  total market_value
  total market_value, "Portfolio"
```

A Ruby primitive valid inside `table`. Registers a summary calculation over a
numeric column and emits a `<tfoot>` row.

---

# 2. Skeleton (Structure & Framing)

*What structural skeleton, container boundary, or collection orders the canvas?*

## Landmarks

### `section`

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — the named thing
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `box_tag` — the `<section>` element; `box_depth` — the depth their children's headings start at
- **infers** — shifts the subject when given a bare name; renders an `<h2>` section heading from the inferred or overridden label
- **renders** — `<section class="section section--holdings"><h2 class="section-title">Holdings</h2>…</section>`

```
section holdings
section holdings, "What you own"
section "Where you stand"
```

A `.sp` composed word (`def section target, heading`). Establishes a titled
document landmark region and optionally shifts the subject to a domain
collection or entity.

### `aside`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<aside>` element
- **infers** — complementary sidebar landmark posture
- **renders** — `<aside class="aside">`

```
aside
  note "Supplementary context."
```

A `.sp` composed word (`def aside variant`) over `box`. Marks a complementary
sidebar region.

### `nav`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — `link`, `link_to`, `input`, `search`
- **subject** — unchanged
- **infers** — the accessible `aria-label` (`"Main"` or the variant name)
- **renders** — `<nav class="nav" aria-label="Main">`

```
nav
  link home, "Overview"
  link accounts
nav secondary
```

A Ruby primitive. Wraps application navigation links and search controls in an
accessible `<nav>` landmark, typically placed in a `.frame` envelope.

### `footer`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<footer>` element
- **infers** — document or section footer landmark element
- **renders** — `<footer class="footer">`

```
footer "Approximate directional estimates. Not tax advice."
```

A `.sp` composed word (`def footer text`) over `box`. Renders a `<footer>`
landmark from inline text or nested children.

## Containers

### `box`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — `open:`, `id:`
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_body_over_children` — that the body renders *instead of* the children (override: none, by design: the box shows one of the two)
- **infers** — shifts the subject when the bare name resolves to a non-String domain object or collection on the current subject; promotes to a semantic HTML tag (`<section>`, `<article>`, `<aside>`, `<footer>`, `<figure>`, `<details>`, `<ul>`, `<li>`, `<dl>`, `<pre>`) when serving as the single root of a canonical composed word
- **renders** — `<div class="box">` (or the promoted semantic element)

```
box shelf
  card
```

A Ruby primitive. The structural container foundation beneath composed container
words (`card`, `section`, `aside`, `footer`, `figure`, `disclosure`, `list`,
`item`, `fact`, `snippet`, `scroll`, `actions`) and application `def` words.

### `card`

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — `variant:`
- **children** — anything
- **subject** — the named thing
- **conventions** — `card_id` — the DOM id, as `word-id` (override: say `id:` yourself); `box_tag` — the `<article>` element; `box_depth` — the depth their children's headings start at
- **infers** — `id="<noun>-<id>"` from the current or named subject; renders an `<h3>` card title when given content
- **renders** — `<article class="card" id="holding-3">`

```
card
card compact
card account, .name
```

A `.sp` composed word (`def card target, title`) over `box`. Wraps a self-contained
domain entity in an `<article class="card">` with automatic DOM identity and
heading depth.

### `figure`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<figure>` element
- **infers** — pairs its content as a `<figcaption>` alongside its children
- **renders** — `<figure class="figure">…<figcaption>…</figcaption></figure>`

```
figure "The studio index, as it stands"
  prose .summary
```

A `.sp` composed word (`def figure caption`) over `box`. Associates a caption
with a chart, code listing, or embedded illustration.

### `group`

- **name** — the topic
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `group_shape` — fieldset and legend; outside one, a div and an h2; `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — `<fieldset>` with `<legend>` inside a `form`; `<div class="group">` with `<h2>` outside a form
- **renders** — `<fieldset class="group"><legend>…</legend>…</fieldset>`

```
group assumptions
group assumptions, "Advanced assumptions"
```

A Ruby primitive. Clusters related fields or content under a shared topic
heading without shifting the active subject.

### `scroll`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **infers** — bounded overflow scroll container for wide tables or tall lists
- **renders** — `<div class="scroll">`

```
scroll
  table holdings
    column symbol
```

A `.sp` composed word (`def scroll variant`) over `box`. Provides an isolated
scrolling viewport around dense content.

## Collections

### `list`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<ul>` element
- **infers** — unordered list container (`plain` variant removes bullets)
- **renders** — `<ul class="list">`

```
list plain
  item "First"
```

A `.sp` composed word (`def list variant`) over `box`. Encloses `item` children
(or `each` loops emitting items or links) in a `<ul>`.

### `item`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<li>` element
- **infers** — list item element valid inside `list`
- **renders** — `<li class="item">`

```
list plain
  item
  item "Ruby logic before CSS before Stimulus."
```

A `.sp` composed word (`def item variant, content`) defined alongside `list` in
`lib/vocabulary/list.sp`. Renders an `<li>` holding either inline text or nested
children.

### `table`

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — `column`, `total`, `choose`, `each`
- **subject** — the named thing
- **conventions** — `table_rows` — the rows, so no page writes a loop
- **infers** — iterates the named collection automatically, rendering `<thead>`, `<tbody>`, and optional `<tfoot>` from registered `column` and `total` children
- **renders** — `<table class="table">` with caption, head, body, and foot

```
table holdings
table holdings, "As of today"
```

A Ruby primitive. Gathers `column` and `total` declarations first, then walks
its collection to emit the header row, one `<tr>` per item, and any totalled
footer row.

### `column`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `as:`
- **children** — none
- **subject** — unchanged; the enclosing word supplies each row in turn
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row; `table_header` — the header or series label — the row, then the enclosing subject, then English (override: say the header on the column or label on the series); `numeric_alignment` — right alignment; `format` — the presentation — `as:`, then the app, then the value's shape (override: `as:`)
- **infers** — each cell's value from the named attribute on each row, its column header, numeric right-alignment, and value formatting
- **renders** — one `<th>` in `<thead>` and one `<td>` per row in `<tbody>`

```
table holdings
  column symbol
  column market_value, "Value"
  column weight, as: percent
```

A Ruby primitive valid inside `table`. Registers a column on the enclosing
table.

### `grid`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — `columns:`
- **children** — anything
- **subject** — unchanged
- **infers** — responsive multi-column CSS Grid track sizing that collapses cleanly on narrow viewports
- **renders** — `<div class="grid grid--cards">`

```
grid cards
grid metrics, columns: 3
```

A Ruby primitive. Arranges child cards or metrics into a responsive multi-column
grid.

### `chart`

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — `over:`
- **children** — `band`, `line`, `level`, `each`, `choose`
- **subject** — the named thing
- **conventions** — `chart_axis` — the axis labels, from each row's singular (override: `over:` names the attribute); `format_family` — number, percent or money, from the value (override: `as:`); `table_header` — the header or series label — the row, then the enclosing subject, then English (override: say the header on the column or label on the series)
- **infers** — the y-axis scale, tick formatting, x-axis labels from the collection's singular noun, and series legend
- **renders** — an accessible inline `<svg>` chart with legend

```
chart balances, "Projected balance"
  band total
```

A Ruby primitive. Like `table`, `chart` gathers its series declarations (`band`,
`line`, `level`) and walks its collection of rows to emit a complete inline SVG
plot without client-side charting libraries.

### `band`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row
- **infers** — series label and number formatting from the row attribute; stacks cumulatively on preceding bands
- **renders** — a filled stacked area `<path>` inside `chart`

```
chart years
  band base_income
  band social_security
```

A Ruby primitive valid inside `chart`. Registers a stacked area series.

### `line`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `from:`
- **children** — none
- **subject** — unchanged
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row
- **infers** — series label and number formatting from the row attribute
- **renders** — a stroked overlay `<path>` inside `chart`

```
chart years
  line federal_tax
  line gross_income, "Do nothing", from: .baseline_years
```

A Ruby primitive valid inside `chart`. Plots an unstacked line series over the
chart, optionally reading an alternate comparison collection via `from:`.

### `level`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `column_registration` — that it registers rather than renders, so the header exists before a row
- **infers** — draws only when the threshold falls within the data's y-axis range so an outlier threshold never flattens the plot
- **renders** — a horizontal reference rule across `chart`, labelled in place

```
chart years
  level .standard_deduction, "Standard deduction"
```

A Ruby primitive valid inside `chart`. Marks a constant threshold or target line
across the plot.

---

# 3. Affordances (Controls & Interactions)

*How does the user interact, input data, or navigate the application?*

## Actions

### `link`

- **name** — the destination
- **content** — text or data, when there is any
- **modifiers** — `to:`, `active:`
- **children** — none
- **subject** — unchanged
- **conventions** — `link_href` — `href="/show"` (override: `to:`); `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — `href="/"` when named `home`, or `href="/<name>"` and a humanized label from the destination name
- **renders** — `<a class="link" href="…">`

```
link show
link show, "View holding"
```

A Ruby primitive. Renders a hyperlink, inferring both address and label when
given a route name.

### `button`

- **name** — the variant
- **content** — text or data, when there is any
- **modifiers** — `to:`, `target:`, `type:`, `size:`, `name:`, `value:`
- **children** — none
- **subject** — unchanged
- **conventions** — `button_type` — `type="submit"`; outside one, `type="button"` (override: `type:`)
- **infers** — `type="submit"` inside a `form` and `type="button"` outside one; `formaction` when given `to:`
- **renders** — `<button class="button button--primary">`

```
button primary, "Run"
button "Show baseline", to: baseline
```

A Ruby primitive. Renders an interactive `<button>` with optional variant weight
(`primary`, `neutral`, `danger`) and per-button form submission target (`to:`).

### `actions`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **infers** — horizontal action toolbar spacing and alignment for child buttons and links
- **renders** — `<div class="actions">`

```
actions
  button primary, "Save"
```

A `.sp` composed word (`def actions`) over `box`. Groups buttons, links, and
`action` controls into a semantic toolbar cluster.

### `action`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `to:`, `variant:`, `status:`
- **children** — none
- **subject** — unchanged
- **infers** — delegates to `button`, attaching `name="status"` and `value:` when `status:` is provided
- **renders** — `<button class="button" formaction="…">`

```
actions
  action "Commit", to: "/actions/commit", variant: primary
  action "Set dormant", to: "/actions/status", status: "dormant", variant: neutral
```

A `.sp` composed word (`def action label`) over `button`. Expresses a named
command button inside an `actions` bar or `form`, forwarding `to:`, `variant:`,
and optional `status:` payload values.

### `tabs`

- **name** — the variant
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **infers** — builds the tab bar navigation automatically from its child `tab` panels using CSS radio state with zero JavaScript
- **renders** — `<div class="tabs">` containing radio inputs, `<label>` tabs, and `<div class="tab-panel">` bodies

```
tabs
  tab "Visual", active: true
    paragraph "What the page looks like."
  tab "HTML"
    paragraph "What it emits."
```

A Ruby primitive. Coordinates a set of `tab` panels and renders their switching
bar from a single declaration.

### `tab`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `active:`
- **children** — anything
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — its tab button label from content and its initial open state from `active:`
- **renders** — `<div class="tab-panel" role="tabpanel">` inside `tabs`

```
tabs
  tab "Raw HTML"
  tab "Visual", active: true
```

A Ruby primitive valid only inside `tabs`. Declares one labelled panel and its
enclosed content.

## Inputs

### `form`

- **name** — the subject this word presents; it must be there
- **content** — none
- **modifiers** — `to:`, `method:`, `target:`
- **children** — `group`, `field`, `checkbox`, `choice`, `actions`, `disclosure`, `button`, `hidden`, `input`, `textarea`, `choose`, `contents`, `box`, `each`
- **subject** — the named thing
- **infers** — shifts the subject when a bare name is given; defaults `method` to `get` unless overridden
- **renders** — `<form class="form" action="…" method="…">`

```
form scenario
form to: run, method: post
```

A Ruby primitive. Encloses form controls (`field`, `input`, `textarea`,
`checkbox`, `choice`, `hidden`, `button`) and binds them to the active subject.

### `field`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `type:`, `step:`, `required:`
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `input_type` — the input type, from the value's class (override: `type:`); `input_step` — `step="0.01"` below one, `step="any"` above (override: `step:`); `boolean_field` — that the field is a checkbox, because a value that is already true or false knows the shape it wants (override: `type: text`)
- **infers** — the `<label>`, the input `name` and `id`, the current value from the subject, the HTML input `type` (`number`, `date`, `checkbox`, `text`), and numeric `step`
- **renders** — `<div class="field"><label for="…">…</label><input …></div>`

```
field base_income
field age_primary, "Age (primary)"
field growth_rate, step: 0.01
```

A Ruby primitive. The primary form control word: pairs a `<label>` and an
`<input>` whose type, step, and state are inferred from the attribute's value on
the current subject.

### `input`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `type:`, `placeholder:`
- **children** — none
- **subject** — unchanged
- **conventions** — `input_type` — the input type, from the value's class (override: `type:`)
- **infers** — the current value and input `type` from the named attribute on the subject, without rendering a `<label>` wrapper
- **renders** — a bare `<input class="input">`

```
input q, placeholder: "search…"
```

A Ruby primitive. Emits an unlabelled `<input>` for compact bars such as
navigation search boxes.

### `choice`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — `option`, `choice`, `each`
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page); `option_selected` — which option is selected, by comparing value to value
- **infers** — the `<label>`, the current value from the subject, and which child `option` is selected
- **renders** — `<div class="choice"><label>…</label><select>…</select></div>`

```
choice conversion_strategy, "Strategy"
  option fixed, "Fixed amount"
```

A Ruby primitive. Renders a labelled `<select>` menu (or radio group when
named `radio`) over its `option` children.

### `option`

- **name** — the value
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the human label from the option's value name when content is omitted, and `selected="selected"` when matching the enclosing `choice`'s value
- **renders** — `<option value="…">`

```
choice conversion_strategy
  option fixed, "Fixed amount"
  option fill_bracket, "Fill bracket"
```

A Ruby primitive valid inside `choice`. Registers a selectable option value and
label.

### `search`

- **name** — none
- **content** — none
- **modifiers** — `q:`, `placeholder:`, `to:`
- **children** — none
- **subject** — unchanged
- **infers** — a `GET` form submitting `q` to `"/search"` (or `to:`)
- **renders** — `<form class="form search" method="get" action="/search"><input name="q" …></form>`

```
search placeholder: "Search…", q: .q
```

A `.sp` composed word (`def search`) over `form` and `input`. Provides a
ready-made search bar for navigation chrome and filter headers.

### `checkbox`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — the `checked` state from the boolean value of the attribute on the subject, plus its human label
- **renders** — `<label class="checkbox"><input type="checkbox" …>…</label>`

```
checkbox show_baseline, "Show baseline"
```

A Ruby primitive. Renders an explicit boolean checkbox control and label.

### `hidden`

- **name** — a name
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — the value from the named attribute on the subject when content is omitted
- **renders** — `<input type="hidden" name="…" value="…">`

```
form to: "/actions/commit", method: post
  hidden path, .name
  hidden return_to, "/triage"
  button "Commit"
```

A Ruby primitive valid inside `form`. Carries a hidden parameter along with a
form submission.

### `textarea`

- **name** — the attribute
- **content** — text or data, when there is any
- **modifiers** — `rows:`, `required:`, `readonly:`
- **children** — none
- **subject** — unchanged
- **conventions** — `label` — the human label — the page, then the app, then English (override: say the label in the page)
- **infers** — the `<label>` and current multi-line text value from the named attribute on the subject
- **renders** — `<div class="field"><label>…</label><textarea …>…</textarea></div>`

```
form
  textarea notes, "What changed?", rows: 3
```

A Ruby primitive. Renders a labelled multi-line `<textarea>` bound to an
attribute on the current subject.

### `on`

- **name** — a name
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **infers** — registers a lookup key (`active`, `dormant`, or `default`) on the enclosing `dictionary`
- **renders** — invokes its target word or renders its indented child block when the enclosing `dictionary`'s topic matches its key

```
dictionary .status
  on active, badge
```

A Ruby primitive valid only inside `dictionary`. Pairs a domain key with either
a target word (`on active, badge`) or an indented block of sentences.

---

# 4. Flow & Logic (State & Behavior)

*How does the template iterate, branch, or disclose state?*

## Iteration

### `each`

- **name** — the singular of the collection; also binds that name
- **content** — none
- **modifiers** — `from:`
- **children** — anything
- **subject** — each element in turn
- **conventions** — `plural_collection` — which collection to read — `y`→`ies`, a hiss→`+es`, otherwise `+s` (override: `from:` on the collection word); `singular_binding` — that the bound name is `holding`, reachable from inside (override: name it something else and say `from:`); `subject_or_collection` — that the subject *is* the collection, so it iterates itself
- **infers** — pluralizes the singular name to find the collection (or walks the current subject if it is already a collection), binds the singular name, and shifts the subject for each item
- **renders** — repeats its children once per element; renders nothing when the collection is empty or `nil`

```
each holding
  money .market_value
each holding, from: .taxable
  money .market_value
```

A Ruby primitive. The single iteration word in the language.

### `empty`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **conventions** — `empty_situation` — that `empty` renders and its siblings do not
- **infers** — inspects the enclosing collection subject; when the collection has no items (or is `nil`), `empty` renders and all sibling nodes under the parent container are pruned
- **renders** — `<p class="empty">`

```
section holdings
  empty "No holdings yet."
```

A `.sp` composed word (`def empty message`) paired with `Builder#prune`. Names
the empty collection state declaratively instead of branching with `if`.

## Branching

### `choose`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — `when`, `otherwise`
- **subject** — unchanged
- **conventions** — `first_truthy_branch` — that exactly one branch renders — the first that holds (override: none, by design: picking one is what `choose` means)
- **infers** — evaluates child `when` conditions in order and renders only the first truthy branch (or `otherwise`)
- **renders** — the children of the selected branch

```
choose
  when .in_stock?
    badge ok, "Available"
  otherwise
    badge neutral, "Out of stock"
```

A Ruby primitive. Encloses mutually exclusive `when` and `otherwise` branches.

### `when`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **infers** — evaluates its dotted argument for truthiness inside `choose`
- **renders** — its children when the condition holds

```
choose
  when .in_stock?
    text "Ready to ship."
```

A Ruby primitive valid only inside `choose`. Guards one branch of a choice.

### `otherwise`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — anything
- **subject** — unchanged
- **infers** — serves as the fallback branch when no preceding `when` (in `choose`) or `on` (in `dictionary`) matched
- **renders** — its children when selected as the fallback

```
choose
  when .in_stock?
    text "In stock"
  otherwise
    text "Backordered"
```

```
dictionary .status
  on active, badge
  otherwise
    note quiet, "Unknown"
```

A Ruby primitive valid inside `choose` or `dictionary`.

## Disclosure

### `disclosure`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `open:`
- **children** — anything
- **subject** — unchanged
- **conventions** — `box_tag` — the `<details>` element
- **infers** — wraps its content argument in `<summary>` and places its children inside a native `<details>` element
- **renders** — `<details class="disclosure"><summary>…</summary>…</details>`

```
disclosure "Show advanced assumptions"
  field growth_rate
disclosure "Show raw JSON", open: true
  snippet .raw_json
```

A `.sp` composed word (`def disclosure summary`) over `box`. Provides progressive
disclosure using native HTML `<details>` and `<summary>` with zero JavaScript.

---

# 5. Environment (Document & Splicing)

*How is the document framed, resourced, and spliced into the outer context?*

## Document

### `page`

- **name** — the subject this word presents; it must be there
- **content** — text or data, when there is any
- **modifiers** — `favicon:`
- **children** — anything
- **subject** — the named thing
- **conventions** — `document` — the doctype, html/head/body, the charset and the viewport; `title` — the `<title>` and the top heading, humanised from the name (override: `page portfolio, "Your retirement"`); `frame` — the chrome every page wears, with `contents` marking the hole (override: delete the frame, or move the page)
- **infers** — the HTML5 doctype, `<head>`, charset, viewport, base stylesheet, `<title>`, `<h1>`, and automatic wrapping in the application's `.frame` chrome and `.layout` stylesheet
- **renders** — the complete HTML document

```frame
page portfolio
  contents
```

A Ruby primitive spoken exclusively in `.frame` files. Establishes the document root,
`<head>`, and `<body>` around `contents`.

## Resources

### `stylesheet`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — hoisted into `<head>` by `page` (the base `slim-pickins.css` and compiled `.layout` stylesheets are included automatically)
- **renders** — `<link rel="stylesheet" href="…">`

```
stylesheet "/css/base.css"
```

A Ruby primitive. Declares an additional stylesheet asset for the document head.

### `script`

- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `defer:`
- **children** — none
- **subject** — unchanged
- **infers** — placement at the end of `<body>`
- **renders** — `<script src="…"></script>`

```
script "/js/app.js"
```

A Ruby primitive. Includes an external script tag in the document.

### `iframe`

- **name** — a name
- **content** — none
- **modifiers** — `src:`, `srcdoc:`, `width:`, `height:`
- **children** — none
- **subject** — unchanged
- **infers** — sets the frame's `name` attribute from the bare name so a `form` with `target:` can submit directly into it without a full page reload
- **renders** — `<iframe class="iframe" name="…">`

```
iframe preview
iframe report, src: "/projection"
```

A Ruby primitive. Embeds an isolated browsing viewport that pairs with `form
target:` for zero-JavaScript live previews.

## Splicing

### `contents`

- **name** — none
- **content** — none
- **modifiers** — none
- **children** — none
- **subject** — unchanged
- **infers** — nothing; marks the splice point for enclosed sentences
- **renders** — the route template's sentences (inside a `.frame` file) or the caller's indented child block (inside a `def` composed word)

```sp
def card target, title
  box .variant, id: .id
    choose
      when .title
        heading .title
    contents
```

A Ruby primitive. The universal splice pronoun connecting outer `.frame`
envelopes to route `.sp` templates and connecting composed `def` words to their
callers' children. Spoken inside `.frame` files or inside `def` composed words.

### `map`

- **name** — the topic
- **content** — text or data, when there is any
- **modifiers** — any
- **children** — none
- **subject** — unchanged
- **infers** — resolves the topic value against inline keyword mappings (or a named `dictionary` via `in:`) with string, symbol, boolean, and `nil` key indifference
- **renders** — invokes the mapped presentation word (forwarding any content argument) or emits the mapped value

```
map .status, active: badge, dormant: note
```

A Ruby primitive. The inline association partner to `dictionary`: maps a domain
value directly to a word or value in a single sentence.
