# The Way

A primer for the language in this repository. [`DESIGN.md`](DESIGN.md) is the
grammar; [`VOCABULARY.md`](VOCABULARY.md) is the sixty-three canonical words;
[`CONVENTIONS.md`](CONVENTIONS.md) is what the language decides when you stay
silent; [`LAYOUT.md`](LAYOUT.md) is the spatial stylesheet companion;
[`CONTRACT.md`](CONTRACT.md) is the promise an application makes. This is the
tour.

Slim-pickins is a direct view language: no HTML boilerplate, no framework
scaffolding, and no hand-written CSS classes in templates. It has no
intermediate templating layer beneath it. What follows describes how it works,
what it values, and how to write it.

## The idea in one paragraph

A template should say **what is on the page**, not how to build it.
`section holdings` is what is on the page. `<div class="sp-cluster sp-cluster--between">`
is scaffolding. This language exists so that a template holds only the first
kind of line, and every piece of scaffolding — the markup, the classes, the
escaping, the loop — lives in one place where it can be fixed once.

A view in this language is a **description of what the page means**, in
sixty-three canonical words (37 Ruby primitives and 26 `.sp` composed words),
with every subject resolvable. What a template means is checkable before it
renders.

## The four canvases: `.frame`, `.sp`, `.layout`, and `.style`

An application separates its views across four canvases, each with a single
job and all speaking the same indentation grammar:

| Canvas | File | Role |
|---|---|---|
| **Frame** | `views/<app>.frame` | The outer document chrome: navigation, shell landmarks, footer, and `contents` marking where each route's body goes. |
| **Substance** | `views/<route>.sp` | The route-level template expressing domain content as a clean outline, plus composed words authored with `def`. |
| **Layout** | `<app>.layout` | The spatial companion stylesheet declaring how zones sit in space (`horizon`, `flank`, `stack`, `cluster`), compiled to fluid CSS Grid and container queries. |
| **Style** | `<app>.style` | The theme-role companion declaring sayable theme roles (`measure wide`, `gap loose`, `density airy`), compiled to `:root` custom properties. |

### 1. The frame (`views/publication.frame`)

Written once per application (or overridden per page as `views/<route>.frame`),
the frame is the shell every route wears — chrome and the `contents` slot, no
envelope word — and the route never names it:

```frame
nav
  link home, "Reading"
  link shelf
  link timeline
  link search
contents
footer "Every document and every lesson, read as a reader meets them."
```

### 2. The route word (`views/index.sp`)

A route is a word named by its filename: its leading line is the signature
(here a title), and its body reads like a table of contents, delegating its
regions to short, focused composed words defined with `def`:

```sp
"The Publication"
  catalog docs, "Documents"
  reading_pane selected_doc

def catalog documents, title
  section documents, title
    empty "No markdown documents in ~/dev/alt-slim-pickins."
    list
      each document
        link .name, .href

def reading_pane document
  card document, .name
    empty "No document selected."
    prose markdown, .content
```

### 3. The spatial layout (`publication.layout`)

Instead of scattering grid classes into `.sp` templates, a `.layout` file
declares the spatial posture of the zones named in the template:

```text
surface publication
  stage
    air generous
    flank catalog, beside: reading_pane, balance: subordinate, collapse: tight

  zone catalog
    frame flat
    cadence compact

  zone reading_pane
    frame flat
    treatment editorial
```

## The grammar, in one sentence

> **`word arguments`. Indentation nests it. Everything — elements, components,
> control flow, text — is a word. Extending the language adds vocabulary,
> never syntax.**

There are no sigils, no `=`, no `-`, no `|`, and no closing tags. A line is a
word, its arguments, and the lines indented beneath it:

```sp
section "Where you stand"
  grid metrics, columns: 3
    metric total_value
    metric ytd_return, "YTD return"
    metric annual_income, "Projected income"
section accounts, "Your accounts"
  empty "No accounts linked yet."
  each account
    card
      title .name
      money .balance
      actions
        link show, "Details", to: .href
```

Everything in that template is a word — the section, the grid, the loop, the
card, the title, the money presenter. Nothing is an HTML tag.

## The six argument kinds

Every part of a sentence is optional; the order never varies. There are
exactly six kinds, and each has exactly one spelling:

| Argument | Means | Example |
|---|---|---|
| `name` | a bare name — interpreted by the word to its left, never evaluated | `section products`, `button primary` |
| `"string"` | literal text | `note "Saved."` |
| `.property` | the current subject's data | `title .name` |
| `binding.property` | an outer named subject's data | `note order.number` |
| `key: value` | a named modifier | `field growth_rate, step: 0.01` |
| *indented block* | children | |

The spelling rule is the whole of the morphology: **a dot means data, a bare
word is language.** Every value carries a dot. Every name does not.

```
section products      # no dot — a name the language interprets
button primary        # no dot — a variant name
title .name           # dot — the current subject's data
note order.number     # dot — a named outer subject's data
```

## One rule of resolution

`.foo` means the **innermost subject's** `foo`.

There is always a subject. The outermost one is the view context itself, whose
attributes are the locals and helpers the application provides. Every level
obeys the same lookup rule:

```sp
section account
  metric balance
  each holding
    money .market_value
```

`metric balance` asks `account` for `balance`; inside `each holding`,
`.market_value` asks the current `holding`. A missing attribute raises an error
naming the attribute and the subject that lacked it rather than rendering blank.
Nothing ever resolves silently to nothing, and a dot never borrows from further
out: it means *the current subject*.

A sentence that names where it lands reads its own dots on that target, so
`section account, .title` reads the account's `title`.

**Reaching further out is by name.** Every word that shifts the subject also
binds its name for everything indented beneath it — `section account` binds
`account`, and `each holding` binds `holding` — with the nearest binding
winning:

```sp
section account
  each holding
    text .symbol
    note account.name
```

Inside the loop, `.symbol` reads the holding and `account.name` reaches the
outer account by name.

A bare name is never evaluated as arbitrary code. Words that shift the subject
(`section`, `card`, `form`, `table`, `chart`, `each`) resolve
the bare name against the active subject chain. Inside `each account`, writing
`table holdings` automatically finds *that account's* `holdings`.

## One rule of government

A name is interpreted by the word to its left. A word is interpreted by the
word it is nested under.

So `column` means what it means inside `table`, `when` inside `choose`, `on`
inside `dictionary`, and `field` inside `form` — and both governors are visible
without scrolling, one on the same line and one on the line above. A reader
never carries hidden state to parse a sentence: the enclosing word tells you
how to read the leading word, and the leading word tells you how to read the
rest of the line.

### Names and content

A bare name in the first slot and quoted/dotted content are distinct in the
grammar, so a word's job is visible in the template:

```
section accounts          # bare name — shifts the subject to accounts and titles "Accounts"
section "Where you stand" # content — renders the heading "Where you stand", subject unchanged
```

Which role a word's first slot plays is fixed per word and listed in
[`VOCABULARY.md`](VOCABULARY.md): `section`, `card`, `form`, `table`,
`chart`, and `each` take subjects; `button`, `badge`, and `note` take variants;
`text` takes content only.

## The universal convention model & visible inference

The universal convention law is: **that which can be inferred need not be spoken.**

Every sentence follows a universal positional and keyword structure:

> `word [target], [override], [kwargs]`

1. **Target (`word target`):** A bare positional target resolves against the
   current context (`subject`, `locals`, `helpers`), shifting the subject (for
   subject-taking words) and automatically inferring four properties:
   - `.target` — the resolved domain object or collection
   - `.noun` — the singular domain noun (`"account"`)
   - `.id` — the DOM identifier when the target answers `id` (`"account-7"`)
   - `.label` — the human label (`label_for(:accounts)` from the app, or `"Accounts"` in English)
2. **Override (`word target, "Custom Label"`):** An explicit second positional
   argument overrides the inferred label or heading directly. When no bare
   target is given (`section "Where you stand"`), the string serves as the
   label without shifting the subject.
3. **Kwargs (`key: value`):** Named keyword arguments configure modifiers and
   options (`columns: 3`, `as: money`, `precision: 2`, `if: .active?`).

### What sentences infer automatically

Conventions are predictable and inspectable (`CONVENTIONS.md` documents all 38
conventions and their overrides). Here is what common sentences infer without
being asked:

| Sentence | What it infers | How to override |
|---|---|---|
| `portfolio` | Full HTML5 document, `<title>Portfolio</title>`, `<h1>Portfolio</h1>`, outer `.frame` chrome, and base stylesheet | `portfolio, "Your retirement"` |
| `document` | Full HTML5 document; `<title>` and `<h1>` are the document's first heading, and `prose markdown, .content` begins after it | `document, .title` |
| `section accounts` | Shifts subject to `accounts`, wraps in `<section class="section section--accounts">`, renders `<h2>Accounts</h2>` | `section accounts, "Linked accounts"` |
| `each holding` | Reads plural `holdings` (or current collection subject), binds singular `holding`, shifts subject per item | `each holding, from: .taxable_holdings` |
| `card` (inside `each holding`) | Renders `<article class="card" id="holding-3">`, sets heading depth to `<h3>` | `card id: "featured"` |
| `field growth_rate` (on `0.05`) | Renders `<label for="growth_rate">Growth rate</label>` and `<input type="number" step="0.01" value="0.05">` | `field growth_rate, "Annual growth", step: 0.005` |
| `field retired` (on `false`) | Renders a checkbox `<input type="checkbox" id="retired" name="retired">` | `field retired, type: text` |
| `metric balance` | Reads `balance`, queries `label_for(:balance)` and `format_for(:balance)`, formats value in a stat tile | `metric balance, "Current balance", as: money` |
| `column market_value` | Registers `<th>Market value</th>`, right-aligns numeric cells (`column--numeric`), formats per row | `column market_value, "Value", as: money` |
| `badge .status` | Matches known status (`ok`, `warning`, `error`, `blocker`, `pending`, `polish`, `neutral`) to `.badge--<status>` | `badge ok, .status` |
| `link home` / `link accounts` | Infers `href="/"` for `home` and `href="/accounts"` with label `"Accounts"` for named routes | `link accounts, "All accounts", to: "/v2/accounts"` |

### The application contract

The line where automatic inference stops is the application contract
([`CONTRACT.md`](CONTRACT.md)): **mechanical facts derivable from a value's
class or position in the tree are inferred by the language; facts encoding a
human judgement about the domain belong to the application.**

A number is right-aligned automatically because alignment follows from being a
number. Whether a number represents *money* or a *percentage* is a domain fact.
An application object satisfies the contract with one required rule and two
optional methods:

- **Required:** Answer the attributes templates ask for, by ordinary Ruby
  method call (or Hash/Struct key).
- **Optional:** Implement `label_for(attribute)` and `format_for(attribute)` on
  domain models when English humanization or raw number formatting is not
  enough. Every label and format follows a three-tier precedence: **what the
  template said -> what the model's `label_for` / `format_for` said -> what the
  language inferred from English or the value's class.**

## The noun register

Counted across the sixty-three canonical words: **56 carry the noun register** —
two of them plural by nature (`actions`, `contents`) — and the seven non-nouns
are control flow and association words (`each` a determiner, `empty` an
adjective, `choose` and `map` verbs, `when` a conjunction, `on` a preposition,
`otherwise` an adverb). A sentence is head noun plus specifier: the register of
a **label**, not of imperative code. Interactive controls name the widget they
represent rather than the user's action (`checkbox` and `choice`, not `check`
and `select`), so templates read like a specification of the view:

```sp
section scenario
  group assumptions
    field horizon_years
  grid metrics, columns: 3
    metric lifetime_taxes
    metric tax_delta
```

## Loops, tables, and the empty situation

`each holding` iterates `holdings`, binds `holding`, and makes each element the
current subject. A `table` never writes `each` at all, because its rows are its
own business:

```
table holdings
  column symbol
  column market_value, "Value"
  column gain, as: money
  total market_value, "Account total"
```

`column` and `total` register with the enclosing `table` before rows render, so
headers and footer sums are declared in one pass.

When a collection has no items (or is `nil`), that state is **named** rather
than branched over:

```
section accounts
  empty "No accounts linked yet."
  each account
    card
      title .name
```

`empty` means *what this container says when its collection has nothing*. When
`accounts` is empty, `empty` renders and its siblings (`each account`) are
suppressed automatically.

## Dissolving conditionals

Most branches in traditional templates exist only to guard an empty list or a
single optional element. Here `empty` handles the empty collection, and the
universal `if:` modifier guards any single sentence:

```
badge warning, "Drifted", if: .drifted?
```

When a page genuinely chooses between alternative structures, `choose`, `when`,
and `otherwise` express the branch as ordinary words:

```
choose
  when .drifted?
    note warning, "Your allocation has drifted more than five percent."
  otherwise
    note quiet, "Allocation is on target."
```

## Composed words (`def`), `contents`, and association (`dictionary`, `on`, `map`)

### Authoring composed words with `def`

A **composed word** is a first-class word written in `.sp` using `def`. Twenty-six
of the sixty-three canonical words (`card`, `section`, `metric`, `fact`,
`snippet`, `badge`, `note`, `flash`, `figure`, `disclosure`, `list`, `item`,
and others) are composed words in `lib/vocabulary/`, and applications define
their own composed words either inline in a route `.sp` file or in shared `.sp`
files under `views/`:

```sp
catalog docs, "Documents"
reading_pane selected_doc

def catalog documents, title
  section documents, title
    empty "No markdown documents in ~/dev/alt-slim-pickins."
    list
      each document
        link .name, .href

def reading_pane document
  card document, .name
    empty "No document selected."
    prose markdown, .content
```

A `def` signature lists the word's name followed by its positional parameter
names (`def catalog documents, title`). When invoked, a composed word
participates in the same subject resolution and keyword forwarding as a built-in
primitive; a caller cannot tell whether a word was implemented in `.sp` or Ruby.
An application composed word may also shadow a canonical word within its own
view library (nearest scope wins).

### Splicing with `contents`

`contents` is the universal splice pronoun. It does two jobs with one rule:

1. **In a `.frame` file**, `contents` marks where the route `.sp` template is
   spliced into the outer document chrome.
2. **Inside a `def` composed word**, `contents` marks where the caller's
   indented child block is spliced:

```
def card subject, title
  box .variant, id: .id
    choose
      when .title
        heading .title
    contents
```

### Association primitives: `dictionary`, `on`, and `map`

When domain values map to presentation words or labels — such as rendering
different widgets or tones for a record's status — writing a multi-branch
`choose` / `when` ladder mixes lookup data with control flow. The association
words `dictionary`, `on`, and `map` express value-to-presentation mappings
directly.

**Block dispatch with `dictionary` and `on`:**

`dictionary` evaluates a topic value and dispatches to the matching `on` entry
(or `otherwise` when no key matches). An `on` line can either name a target word
to invoke or open an indented block of sentences:

```
section account
  dictionary .status
    on active
      badge ok, "Active account"
    on dormant
      note warning, "Dormant — review required"
    otherwise
      note quiet, "Status pending"
```

When an `on` entry names a target word directly, `dictionary` forwards any
additional positional arguments to that word:

```
section account
  dictionary .status, .status_label
    on active, badge
    on dormant, note
```

**Inline dispatch with `map`:**

For concise one-line associations, `map` pairs a value (and optional forwarded
content) with keyword mappings to presentation words or values:

```
section account
  map .status, .label, active: badge, dormant: note
```

## The Ruby escape hatch

When a page needs an HTML element the canonical vocabulary does not cover — such
as `<video>` or a specialized embed — an application can define a primitive word
in a `*Words` Ruby module:

```ruby
def video(*args, poster: nil)
  _, source = arguments(args)
  tag(:video, { class: token(:video), src: source, poster: poster,
                controls: true, playsinline: true })
end
```

The template then speaks it like any other word:

```
video .tour_url
```

Extending the language adds vocabulary and never syntax, whether the new word is
composed in `.sp` with `def` or written in Ruby.

## The design system

No author writes CSS classes in templates. The class-naming convention *is* the
grammar, in four shapes:

| Shape | Example |
|---|---|
| `.word` | `.card` |
| `.word--variant` | `.note--warning` |
| `.word-part` | `.metric-title` |
| `.word-part--n` | `.chart-band--0` |

Every presentational token lives in `:root` across 113 style rules in the base
stylesheet (`lib/slim_pickins/assets/slim-pickins.css`). Visual presentation
belongs to the theme's semantic roles, to a word's declared variants (`note
quiet`, `badge ok`), to `.layout` spatial declarations, and to sayable `.style`
roles (`measure wide`, `gap loose`) — never to inline `style:` attributes or
utility classes.

## The five vocabulary categories

Authoring in slim-pickins proceeds top-down across five categories defined in
[`VOCABULARY.md`](VOCABULARY.md) and [`ONTOLOGY.md`](ONTOLOGY.md):

1. **Substance — Domain Content & Phrasing** (*What domain content, quantitative data, or phrasing does this express?*):
   - *Typography & Phrasing:* `heading`, `paragraph`, `text`, `note`, `flash`, `prose`, `snippet`, `title`, `span`
   - *Data & Metrics:* `metric`, `fact`, `number`, `money`, `percent`, `time`, `badge`, `dictionary`, `total`
2. **Skeleton — Structure & Framing** (*What structural skeleton, container boundary, or collection orders the canvas?*):
   - *Landmarks:* `section`, `aside`, `nav`, `footer`
   - *Containers:* `box`, `card`, `figure`, `group`, `scroll`
   - *Collections:* `list`, `item`, `table`, `column`, `grid`, `chart`, `band`, `line`, `level`
3. **Affordances — Controls & Interactions** (*How does the user interact, input data, or navigate the application?*):
   - *Actions:* `link`, `button`, `actions`, `action`, `tabs`, `tab`
   - *Inputs:* `form`, `field`, `input`, `choice`, `option`, `search`, `checkbox`, `hidden`, `textarea`, `on`
4. **Flow & Logic — State & Behavior** (*How does the template iterate, branch, or disclose state?*):
   - *Iteration:* `each`, `empty`
   - *Branching:* `choose`, `when`, `otherwise`
   - *Disclosure:* `disclosure`
5. **Environment — Document & Splicing** (*How is the document framed, resourced, and spliced into the outer context?*):
   - *Document:* the route signature (the filename is the word, the leading line the arguments)
   - *Resources:* `stylesheet`, `script`, `iframe`
   - *Splicing:* `contents`, `map`

### Cross-category resonance and the visual standard

Fifteen words naturally bridge multiple categories — for example, `card`,
`table`, `chart`, `fact`, and `dictionary` bridge *Substance* and *Skeleton*;
`form`, `field`, `actions`, `tabs`, `group`, and `nav` bridge *Skeleton* and
*Affordances*. On the Studio shelf, words appear under every category they
participate in so authors find them wherever they reach.

Crucially, **no word in the language exists solely for decorative paint.** Every
word carries structural, semantic, behavioral, or environmental meaning; visual
styling is derived from that meaning.

## The Studio Workbench

The language ships with its own live authoring environment on port `4580`
(`classic` and `workbench` UIs):

- **The Shelf:** Organizes the 63 canonical words across the five vocabulary
  categories, alongside the 7 example applications (34 verified pages) and the
  project guides.
- **The Work Area:** Evaluates `.sp` source and JSON data payloads live as you
  type, displaying Visual and HTML outputs side by side.
- **Truthful Refusals:** When a sentence names a missing attribute or violates a
  word's contract, the studio renders a Refusal page in the language's own
  terms (`this account has no balance`), pinpointing the line.
- **Try-It Seeds:** Every vocabulary entry includes *"In the wild"* sentences
  cited from real templates (`path:lineno`) with one-click Try-It links.

## Where the language stops

- **There is no numeric literal in content position.** Content is a quoted
  string or a dotted data reference; domain numbers live on the model rather
  than hardcoded in templates:

```text
level 1000000.0, "A million"                   # refused — not a sentence
level .standard_deduction, "Standard deduction" # valid — reads model data
```

- **A word takes only the arguments its contract declares.** Every word has a
  single, checkable signature in [`VOCABULARY.md`](VOCABULARY.md).
- **An unknown word fails with its own name.** Every word is an explicit method
  or composed word, so a typo fails loudly on the line where it was written.

When a page hits a wall, the rule is simple: **grow the language by composing a
word with `def` or proposing a canonical word — never work around it in the
template.**

## The ethos

- **The word carries the presentation; the argument carries the domain.**
  `money .market_value` means *present this value as money*.
- **Four canvases, four jobs.** Document chrome lives in `.frame`, domain
  substance and composed words live in `.sp`, spatial posture lives in
  `.layout`, and sayable theme roles live in `.style`.
- **A line that states the inferable should not exist.** That which can be
  inferred from the subject, the tree depth, or the value's class is inferred
  by convention.
- **A situation is named, not branched over.** Write `empty`, `if:`, or
  `dictionary` / `map` rather than procedural conditionals.
- **Every truth has one home.** Contracts, conventions, and promises are
  declared once and verified continuously against every document and page.
