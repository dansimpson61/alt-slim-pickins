# Conventions — an author's guide

A **convention** is what the language decides when you say nothing.

You write a route named `portfolio.sp` whose leading line is `portfolio`, and
you get a complete HTML document, a `<title>`, an `<h1>` that says "Portfolio",
and your application's outer `.frame` chrome and `.layout` spatial stylesheet.
You never asked for any of it. That is the inference engine working for you.

Every convention makes three promises:

1. **You can look it up.** Each of the 38 conventions has a name — written here
   in `code` — and a single entry in the convention register.
2. **You can override it by saying it.** What you write in a template wins over
   what the language would have inferred. Where a convention defines what a word
   means and therefore has no override, this guide says so explicitly.
3. **It is the same everywhere.** A convention never changes its mind from one
   page to the next.

Each entry below follows the same four-part structure:

- **You write** — the shortest sentence that triggers it.
- **You get** — what the language decides and emits.
- **To override** — what to write when you want something else.
- **Watch for** — its boundaries and stated limits.

The 38 conventions are grouped by the **eleven principles** they serve — one
sentence each that you can hold in your head. Learn the principles and the
individual conventions follow naturally.

---

## The Universal Convention Law

> **That which can be inferred need not be spoken.**

Every sentence follows the universal argument and inference structure:

> `word [target], [override], [kwargs]`

1. **Target (`word target`):** A bare positional target (`section accounts`,
   `card account`) resolves against the active context (`subject`, `locals`,
   `helpers`), shifting the subject (for subject-taking words) and automatically
   populating four inferred properties:
   - `.target` — the resolved entity or collection
   - `.noun` — the singular entity noun (`"account"`)
   - `.id` — the DOM identifier (`"account-1"`) when the entity answers `id`
   - `.label` — the human label (`label_for` from the model, or `"Accounts"` in English)
2. **Override (`word target, "Your accounts"`):** An explicit second positional
   argument overrides the inferred label directly (or serves as the standalone
   label when no bare target is given, as in `section "Where you stand"`).
3. **Kwargs (`key: value`):** Named keyword arguments configure modifiers and
   options (`card account, variant: :primary`, `field rate, step: 0.005`).

---

## 1. A route is a word; its frame is the shell

> *The frame is the shell; the route is the word it names.*

A route is a `def` whose `def <name>` line is elided: its filename is the word,
and its leading line is the signature — the subject, then the title. The frame
is the document shell the runtime wraps that word in, and the runtime owns the
envelope; no file ever says `page`.

### `document` — every route is a whole document

**You write** the shell, `views/hello.frame`:

```frame
contents
```

and the word `hello`, in `views/hello.sp`:

```sp
"Hello"
```

**You get** the HTML5 doctype, `<html>`, `<head>`, the charset, the viewport,
the base stylesheet, any compiled `.layout` stylesheet, and `<body>`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Hello</title>
<link rel="stylesheet" href="/assets/slim-pickins.css">
</head>
<body>
<h1>Hello</h1>
</body>
</html>
```

**To override** — nothing. The envelope is what a route means.

### `frame` — the shell every route wears

A frame is the outer chrome shared across routes: the navigation bar, shell
landmarks, and footer. Write it once beside your views as `views/<app>.frame`,
using `contents` to mark where each route's body is spliced in. When a matching
`<app>.layout` or `<page>.layout` file sits in the application, its compiled
spatial CSS is linked into `<head>` automatically.

**You write** `views/my_app.frame`:

```frame
nav
  link home
  link accounts
contents
footer "Fine print"
```

and the word `accounts`, in `views/accounts.sp`, whose leading line is its
signature:

```sp
accounts, "Accounts"
  text "Body"
```

**You get** the route's body spliced inside the shell, under the subject the
signature bound:

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Accounts</title>
<link rel="stylesheet" href="/assets/slim-pickins.css">
</head>
<body>
<h1>Accounts</h1>
<nav class="nav" aria-label="Main">
<a href="/" class="link">Home</a>
<a href="/accounts" class="link">Accounts</a>
</nav>
<p class="text">Body</p>
<footer class="footer">Fine print</footer>
</body>
</html>
```

**To override** — give an individual route its own frame (`views/<page>.frame`),
which takes precedence over `views/<app>.frame` for that page, or omit the
`.frame` file when a standalone page needs no shared chrome.

---

## 2. A name is its own text

> *A name is its own text — the heading, the label, the address.*

A bare name is turned into human words automatically: underscores become spaces
and the first letter is capitalised (`base_income` reads `"Base income"`).

### `title` — the page's heading comes from its name

**You write** `portfolio.sp`, whose leading line is the bare name `portfolio`

**You get** `<title>Portfolio</title>` and `<h1>Portfolio</h1>`.

**To override** — pass the title as the second positional: `portfolio, "Your retirement"`
renders `"Your retirement"`, and `account, .name` reads the account's own `name`.

### `link_href` — a link's name is its address

**You write**

```
link home
link accounts
link show, "Details"
```

**You get**

```html
<a href="/" class="link">Home</a>
<a href="/accounts" class="link">Accounts</a>
<a href="/show" class="link">Details</a>
```

The address is `/` plus the bare name, except `home`, which resolves to the root
path `/`.

**To override** — pass `to:`: `link back, "Back to overview", to: "/overview"`.

**Watch for** — any bare name other than `home` becomes `/<name>` whether or not
the application defines that route; use `to:` when linking to a parameterized
path.

### `label` — a field, column, metric, fact, or section labels itself

The human label comes from whoever knows best, in three-level precedence:
**the template override, then the model's `label_for(attribute)`, then English.**

**You write**

```sp
form to: "/save"
  field age, "Your age"
  field base_income
  field growth_rate
```

where the application's `scenario` model answers `label_for(:base_income)` with
`"Income before tax"`.

**You get**

```html
<label for="age">Your age</label>                      ← the template said it
<label for="base_income">Income before tax</label>     ← the model said it
<label for="growth_rate">Growth rate</label>           ← English inferred it
```

**To override** — pass a second positional argument on the sentence
(`field age, "Your age"`), or implement `label_for` on the model to set the
label across all templates.

**Watch for** — English humanization capitalises only the first word (so
`ira_balance` reads `"Ira balance"`) and strips a trailing `_on` or `_at`
(`born_on` reads `"Born"`). Acronyms and domain-specific phrasing belong in
`label_for`.

### `table_header` — a column's header or chart series label

Follows the same three-level precedence for table columns and chart series:
**the sentence's override, then the row or enclosing subject's `label_for`,
then English.** `column market_value` heads its column `"Market value"`.

**To override** — pass the label on the column or series:
`column market_value, "Value"`.

---

## 3. A name inflects

> *A name inflects: the collection is the plural, each item the singular.*

### `plural_collection` and `singular_binding` — `each` names both ends

**You write**

```sp
section account
  each holding
    text .symbol
```

**You get** one paragraph for each item in the account's `holdings`:

```html
<p class="text">VTI</p>
<p class="text">BND</p>
```

`each holding` does two things from one word: it looks up the **plural**
collection (`holdings`), and it binds each element to the **singular** name
(`holding`) while making it the innermost subject. Inside the loop, `.symbol`
reads the holding, and outer subjects remain reachable by their bound names:

```sp
section account
  each holding
    text .symbol
    note account.name
```

**To override** — pass `from:` to name the collection explicitly:

```
each place, from: .addresses
```

**Watch for**

- **Pluralization rules are intentionally compact:** a `y` after a consonant
  becomes `ies`; a word ending in `s`, `x`, `ch`, or `sh` gains `es` (`each
  address` finds `addresses`); eight common irregulars are built in (`child`,
  `person`, `datum`, `leaf`, `man`, `woman`, `analysis`, `criterion`); everything
  else gains `s`. For any other irregular plural, pass `from:`.
- **A loop variable cannot shadow a canonical word.** Writing `each item` is
  refused because `item` is a vocabulary word; write `each row, from: .items`.

### `chart_axis` — a chart labels its horizontal axis from the singular

**You write**

```
chart years
  line amount
```

**You get** an x-axis labelled with each row's `year` (`2026`, `2027`, …) and a
series labelled `"Amount"`.

**To override** — pass `over:` to name the axis attribute explicitly:
`chart history, over: year`.

**Watch for** — when the collection name is not a plural (`chart history`) or its
singular does not match a row attribute, the chart numbers its points `1, 2, 3…`
unless `over:` is given.

---

## 4. A collection walks itself

> *A collection walks itself, and having nothing is a situation, not a false
> value.*

### `subject_or_collection` — a section or box over a collection walks it

**You write**

```
section holdings
  each holding
    text .symbol
```

**You get** a section whose items are the holdings. `section holdings` shifts
the subject to `holdings`; `each holding` sees that the current subject is
already a collection and iterates it directly:

```html
<section class="section section--holdings">
<h2 class="section-title">Holdings</h2>
<p class="text">VTI</p>
<p class="text">BND</p>
</section>
```

### `table_rows` — a table is its own loop

**You write** `table holdings` and declare its columns. **You get** one `<tr>`
per holding without writing `each`.

### `empty_situation` — say what nothing looks like

**You write**

```
section holdings
  empty "No holdings yet."
  each holding
    text .symbol
```

**You get**, when `holdings` is empty (or `nil`), the `empty` message and
nothing else:

```html
<section class="section section--holdings">
<h2 class="section-title">Holdings</h2>
<p class="empty">No holdings yet.</p>
</section>
```

When `holdings` has items, `empty` disappears and its siblings render.

**To override** — nothing; `empty` is the dedicated word for an empty
collection.

**Watch for**

- **`empty` requires a named subject above it.** Placing `empty` inside a
  label-only container (`section "Summary"`) in a route template is refused at
  check time because no collection was named that could be empty. Inside a `def`
  composed word, `empty` checks the subject passed by the caller.
- **A `table` does not hold `empty` directly.** Wrap the `table` in a `section`
  or `box` over the collection and place `empty` there so the empty message
  replaces the entire table cleanly.

### `collection_detection` and `nothing_detection` — what counts as a collection

A value is treated as a **collection** when it is `Enumerable` and is neither a
`Hash` nor a `Struct` (which are key-value records even though Ruby includes
`Enumerable` on them). A collection counts as **nothing** when it has no elements
or is `nil`.

---

## 5. How deep a heading sits decides its level

> *How deep a heading sits decides its level.*

### `heading_level`, `box_title`, and `box_depth`

You never write `h2` or `h3`. A heading's tag level derives from its nesting
depth inside landmarks and containers, and a `heading` directly inside a `box`
or `card` becomes that container's title:

**You write**

```
section accounts
  each account
    card
      heading .name
```

**You get**

```html
<section class="section section--accounts">
<h2 class="section-title">Accounts</h2>
<article class="card" id="account-9">
<h3 class="card-title">Joint</h3>
</article>
</section>
```

The `section` titles itself at level 2 (`<h2>`), and increases the heading depth
for its children (`box_depth`), so the card's title renders at level 3 (`<h3>`).

**No override on `heading_level`, by design.** Deriving heading levels from tree
depth guarantees a valid document outline for assistive technologies. To render
a child heading inside a container without claiming the container's own title
slot, use `title` instead of `heading`. Placing a `heading` directly inside a
`section` or `card` that already has a title is refused as a duplicate title.

---

## 6. A word owns its element

> *A word owns its element, its class, and its id.*

### `box_tag` and `leaf_tag` — the semantic HTML element, unasked

Each canonical word emits the semantic HTML element that matches its role:

```text
section notes          → <section class="section section--notes">
  list                 → <ul class="list">
    item "one"         → <li class="item">
aside                  → <aside class="aside">
footer "end"           → <footer class="footer">
card                   → <article class="card">
figure "Caption"       → <figure class="figure">
disclosure "More"      → <details class="disclosure">
fact origin            → <dl class="fact">
snippet .code          → <pre class="snippet">
money .v               → <span class="money">
badge ok, "Fine"       → <span class="badge badge--ok">
time .t                → <time class="time" datetime="2026-10-09">
```

**To override** — nothing. The word owns its element; a different element is a
different word.

### `root_class` — a composed word with a single root carries its own class

When you define a composed word with `def` whose body has a single top-level
container, that root element automatically receives your composed word's name as
a CSS class so `.layout` zones and theme rules can target it.

**You write**

```sp
each document
  document_card

def document_card document
  card
    text .title
```

**You get**

```html
<article class="card document_card" id="document-3">
  <p class="text">The Way</p>
</article>
```

**Watch for** — a composed word with multiple top-level lines renders as a
multi-node fragment without a wrapper element, so no single node carries the
composed word's class. When a composed word represents a distinct visual zone,
give it a single root container (`box` or `card`).

### `card_id` — a card over an identifiable subject gets its DOM `id`

**You write**

```
each holding
  card
    text .symbol
```

**You get** `<article class="card" id="holding-3">` — combining the subject's
singular noun and its `id`. A subject without an `id` produces no `id`
attribute.

**To override** — pass `id:` explicitly: `card id: "featured"`.

---

## 7. A value chooses its form

> *A value chooses its form — the control, the alignment, the text.*

The runtime inspects what a value *is* — an `Integer`, `Float`, `BigDecimal`,
`Date`, `Time`, `true`, or `false` — and chooses the appropriate input control,
table alignment, and number formatting. It never guesses domain meaning (such as
whether a number is currency); domain meaning comes from the word (`money`,
`percent`) or the model's `format_for`.

### `input_type`, `input_step`, and `boolean_field` — a field fits its value

**You write**

```sp
form to: "/save"
  field age
  field growth_rate
  field retired
  field born_on
```

with `age: 61`, `growth_rate: 0.05`, `retired: false`, and `born_on: Date.new(1965, 3, 1)`.

**You get**

```html
<input id="age" name="age" type="number" value="61">
<input id="growth_rate" name="growth_rate" type="number" value="0.05" step="0.01">
<input id="retired" name="retired" type="checkbox">
<input id="born_on" name="born_on" type="date" value="1965-03-01">
```

- Integers and decimals become `type="number"`.
- Decimals strictly between `-1` and `1` receive `step="0.01"`; larger decimals
  receive `step="any"`.
- Booleans (`true` or `false`) become `type="checkbox"`.
- `Date` and `Time` values become `type="date"`.
- Everything else becomes `type="text"`.

**To override** — pass `type:` or `step:` (`field retired, type: text`,
`field growth_rate, step: 0.001`).

### `numeric_alignment` — numeric columns right-align

A table column or cell whose value is numeric receives `class="column--numeric"`
and right-aligns automatically.

### `format`, `format_family`, and `number_text` — how numbers format

**You write**

```
money .a
percent .b
number .c
money .d, precision: 2
```

with `1234567`, `0.0825`, `98765`, and `-12.5`.

**You get**

```html
<span class="money">$1,234,567</span>
<span class="percent">8.2%</span>
<span class="number">98,765</span>
<span class="money money--negative">−$12.50</span>
```

In a `table`, `metric`, or `fact`, formatting follows a three-level precedence:
**`as:` on the sentence, then the model's `format_for(attribute)`, then the
value's class:**

```
table holdings
  column symbol
  column market_value, as: money
  column gain, as: percent
```

**To override** — pass `as:` (`as: money`, `as: percent`, `as: number`), define
`format_for` on the model, or pass `precision:` to control decimal places.

**Watch for**

- `money` shows whole dollars when the amount is exact, or two decimal places
  when cents are present, and marks negatives with `.money--negative` and a true
  minus sign (`−`).
- `number` shows up to two fractional places with trailing zeros stripped; pass
  `precision:` when finer precision is needed.

### `time_text` — dates and timestamps format for humans and machines

**You write**

```
time .t
time relative, .t
```

**You get**

```html
<time class="time" datetime="2026-10-06">6 October 2026</time>
<time class="time time--relative" datetime="2026-10-06">4 days ago</time>
```

The machine-readable ISO-8601 `datetime` attribute is always emitted. The
`relative` variant counts calendar days up to 30 days in the past or future
(`"today"`, `"yesterday"`, `"4 days ago"`, `"tomorrow"`, `"in 3 days"`), falling
back to the full calendar date beyond 30 days.

### `option_selected` — `choice` marks the active option

**You write**

```
choice plan
  option basic
  option pro
```

with `plan` equal to `:pro` or `"pro"`.

**You get** `<option value="pro" selected="selected">Pro</option>`.

### `badge_status` — `badge` colours itself from known status values

**You write** `badge .status` with `status: "warning"`.

**You get** `<span class="badge badge--warning">warning</span>`.

Known statuses are `ok`, `pending`, `neutral`, `warning`, `error`, `blocker`,
and `polish`. Any other status string renders as a neutral badge so a new status
value never breaks a page.

**To override** — name the variant in the first slot: `badge warning, .status`.

---

## 8. Where a word sits chooses its form

> *Where a word sits chooses its form.*

### `button_type` — a button inside a form submits it

`button "Save"` inside a `form` emits `type="submit"`. Outside a form it emits
`type="button"`.

**To override** — pass `type:`.

### `group_shape` — a group inside a form is a `<fieldset>`

**You write**

```
form to: "/x"
  group ages
    field age
group ages
  text "outside"
```

**You get** `<fieldset class="group"><legend>Ages</legend>…</fieldset>` inside
the form, and `<div class="group"><h2>Ages</h2>…</div>` outside it.

---

## 9. A gatherer collects before it renders

> *A gatherer collects what is beneath it before anything renders.*

### `column_registration` — table columns and chart series register first

Inside `table` and `chart`, child declarations (`column`, `total`, `band`,
`line`, `level`) register their metadata with the parent container before rows
are iterated, allowing headers, scales, and legends to be emitted before the
first row.

### `first_truthy_branch` — `choose` renders one branch

**You write**

```
choose
  when .a
    text "A"
  when .b
    text "B"
  otherwise
    text "neither"
```

**You get** only the first `when` branch whose condition holds, or `otherwise`
if none holds.

**No override, by design.** Selecting a single branch is what `choose` means;
two independent conditions belong in two separate sentences.

---

## 10. What is said nearest wins

> *What is said nearest wins over what is inherited or inferred.*

This principle governs every override in the language and two structural
conventions directly.

### `box_body_over_children` — inline content and child blocks are mutually exclusive

**You write**

```
box .summary
  text "Fallback when summary is nil"
```

**You get** `<div class="box">Summary text</div>` when `.summary` is present, or
the child block when `.summary` is `nil`. Writing a literal string together with
an indented child block on a `box` is refused at check time because the child
block could never render.

### `partial_slot_forwarding` — composed words resolve omitted modifiers from enclosing scopes

When a composed word reads a slot or modifier that was not passed on the call
line, the subject chain checks enclosing composed word scopes before falling
back to `nil`.

**To override** — pass the argument or keyword directly on the inner call.

---

## 11. The theme owns the look

> *The theme owns the look, and no page can say otherwise.*

### `theme_roles` — the axiomatic boundary

A template cannot specify ad-hoc pixel widths, font sizes, or colors. The base
stylesheet owns 65 `:root` theme roles (`--measure`, `--gap`, `--ink`,
`--surface`, and status tokens) across 113 style rules, and spatial composition
lives in `.layout` files. When a concept requires distinct visual treatment, a
word or variant carries it.

---

## Conventions working together

Conventions are designed to stack so a short template expresses a complete,
accessible document.

### A portfolio template

```sp
section accounts
  empty "No accounts linked yet."
  each account
    card
      heading .name
      table holdings
        column symbol
        column market_value, as: money
        total market_value
```

Line by line:

| Sentence | Conventions that fire |
|---|---|
| `section accounts` | `label` (`"Accounts"`), `box_tag` (`<section>`), `box_depth` |
| `empty "…"` | `empty_situation`, `nothing_detection` |
| `each account` | `subject_or_collection`, `singular_binding` |
| `card` | `box_tag` (`<article>`), `card_id` (`id="account-9"`), `box_depth` |
| `heading .name` | `box_title`, `heading_level` (`<h3>`) |
| `table holdings` | `table_rows`, `plural_collection`, `collection_detection` |
| `column …` | `column_registration`, `table_header`, `numeric_alignment` |
| `as: money` | `format`, `format_family`, `number_text`, `leaf_tag` |
| `total market_value` | `column_registration`, `format`, `number_text` |

---

## Stated limits of the inference engine

The weak-spots table is empty: every documented override is verified by test,
and the boundaries below are intentional design limits:

- **Outline and branching invariants (`heading_level`, `first_truthy_branch`,
  `box_body_over_children`):** Define what those words mean rather than guessing,
  so they have no override.
- **Multi-root composed words (`root_class`):** A `def` word with multiple top
  lines emits a fragment without a wrapper tag; wrap the body in `box` or `card`
  when a single addressable root element is desired.
- **Empty tables (`empty_situation`):** `empty` belongs on the enclosing
  `section` or `box` around a `table`, not inside `table` itself.
- **Irregular plurals (`plural_collection`):** Beyond standard English suffixes
  and the eight built-in irregulars, pass `from:`.
- **Default decimal places (`number_text`):** `number` displays up to two
  fractional digits by default; pass `precision:` for more.
