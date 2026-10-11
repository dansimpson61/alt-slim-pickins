# Conventions — an author's guide

A **convention** is what the language decides when you say nothing.

You write `page portfolio`, and you get a whole HTML document, a `<title>`, and
a heading that says "Portfolio". You never asked for any of it. That is a
convention working for you.

Every convention makes three promises:

1. **You can look it up.** Each one has a name — written here in `code` — and
   an entry in the register, `lib/slim_pickins/conventions.rb`.
2. **You can override it by saying it.** What you say wins over what the
   language would have decided. Where you *cannot* override one, this guide
   says so.
3. **It is the same everywhere.** A convention does not change its mind
   between one page and the next.

Each entry below has the same four parts:

- **You write** — the shortest sentence that triggers it.
- **You get** — what the language decides. Every example here was rendered;
  the HTML is trimmed to the lines that matter.
- **To override** — what to say instead.
- **Watch for** — its limits and risks, where it has any. These are measured,
  not guessed, and they are where the conventions most need strengthening.

The conventions are grouped by the **principle** they serve — one sentence each
that you can hold in your head. Learn the principles and most of the
conventions follow.

---

## 1. A page wears its frame

> *A page wears its frame: the document, and the tin around it.*

### `document` — every page is a whole document

**You write**

```
page "Hello"
  text "Hi"
```

**You get** the doctype, `<html>`, `<head>`, the charset, the viewport, the
stylesheet, and the body:

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
<p class="text">Hi</p>
</body>
</html>
```

**To override** — nothing. It is what a page is.

### `tin` — the chrome every page wears

A tin is the part of every page that is the same: the navigation, the footer.
Write it once, in a file named after your app, beside your views —
`views/my_app.tin`. The word `contents` marks the hole where each page goes.

**You write** `views/my_app.tin`:

```
nav
  link home
  link accounts
contents
footer "Fine print"
```

and a page that never mentions it:

```
page "Accounts"
  text "Body"
```

**You get** the page inside the tin:

```html
<h1>Accounts</h1>
<nav class="nav" aria-label="Main">
<a href="/home" class="link">Home</a>
<a href="/accounts" class="link">Accounts</a>
</nav>
<p class="text">Body</p>
<footer class="footer">Fine print</footer>
```

**To override** — give one page its own tin: `views/<page>.tin` beats the app's
for that page. Delete the tin to have none.

**Watch for** — `link home` goes to `/home`, not `/`. Say `to: "/"` for the
home link (see `link_href`).

---

## 2. A name is its own text

> *A name is its own text — the heading, the label, the address.*

A name you write is turned into words a reader can see: underscores become
spaces and the first letter is capitalised. `base_income` reads "Base income".

### `title` — the page's heading comes from its name

**You write** `page portfolio`

**You get** `<title>Portfolio</title>` and `<h1>Portfolio</h1>`.

**To override** — say the words: `page portfolio, "Your retirement"` gives
"Your retirement". Or read them from the data: `page account, .name` gives the
account's own name.

### `link_href` — a link's name is its address

**You write**

```
link accounts
link show, "Details"
```

**You get**

```html
<a href="/accounts" class="link">Accounts</a>
<a href="/show" class="link">Details</a>
```

**To override** — `to:` — `link back, to: "/x"`.

**Watch for** — the address is always `/` plus the name. `link home` is
`/home`.

### `label` — a field, column or metric labels itself

The label comes from whoever knows best, in this order: **the page, then the
app, then English**.

**You write**

```
page scenario
  form to: "/save"
    field age, "Your age"
    field base_income
    field growth_rate
```

where the app's `scenario` answers `label_for(:base_income)` with
"Income before tax".

**You get**

```html
<label for="age">Your age</label>                      ← the page said it
<label for="base_income">Income before tax</label>     ← the app said it
<label for="growth_rate">Growth rate</label>           ← English
```

**To override** — say the label in the page, as `field age, "Your age"` does.
To change it everywhere, answer `label_for` in the app.

**Watch for** — English is simple: only the first word is capitalised, so
`ira_balance` reads "Ira balance". A trailing `_on` or `_at` is dropped:
`born_on` reads "Born". When English is wrong, the app should say the label
once, in `label_for`, rather than every page saying it.

### `table_header` — a column's header

The same idea as `label`, for tables and chart series: **the row, then the
enclosing subject, then English**. `column market_value` heads its column
"Market value".

**To override** — say the header on the column: `column market_value, "Value"`.

---

## 3. A name inflects

> *A name inflects: the collection is the plural, each item the singular.*

### `plural_collection` and `singular_binding` — `each` names both ends

**You write**

```
page account
  each holding
    text .symbol
```

**You get** one line for every item in the account's `holdings`:

```html
<p class="text">VTI</p>
<p class="text">BND</p>
```

`each holding` does two things from one word. It reads the **plural**,
`holdings`, and it names each item by the **singular**, `holding`. Inside the
loop, the dot means the holding. To reach further out, use a name:

```
page account
  each holding
    text holding.symbol
    note account.name
```

`account.name` reaches the page's account, because `page account` named it.

**To override** — `from:` names the collection yourself:

```
each place, from: .addresses
```

**Watch for**

- **Plurals are simple.** A `y` after a consonant becomes `ies`; a word that
  ends in a hiss (`s`, `x`, `ch`, `sh`) gains `es`, so `each address` finds
  `addresses`; everything else gains an `s`. The common irregulars are a
  list: child, person, datum, leaf, man, woman, analysis, criterion. English
  has too many exceptions for rules, so anything else, like `each knife`
  looking for `knifes`, needs `from:`. That is a stated limit, by dan's
  ruling of 2026-10-10.
- **You cannot bind a word of the language.** `each item` is refused, because
  `item` is a word. The error tells you the fix:
  `each row, from: .items`.

### `chart_axis` — a chart labels its axis from the singular

**You write**

```
chart years
  line amount
```

**You get** an axis labelled with each row's `year` (2026, 2027) and a series
labelled "Amount".

**To override** — `over:` names the attribute: `chart shapes, over: name`.

**Watch for** — when the name is not a plural (`chart history`), there is no
singular to read, and the chart numbers its points 1, 2, 3… instead. The same
happens when the singular guesses wrong: `chart caches` looks for `cach` and
`chart statuses` for `statuse`, because `es` after `ch` or a single `s` could
have come from either spelling. Say `over:`.

---

## 4. A collection walks itself

> *A collection walks itself, and having nothing is a situation, not a false
> value.*

### `subject_or_collection` — a section over a collection walks it

**You write**

```
section holdings
  each holding
    text .symbol
```

**You get** a section whose items are the holdings. `section holdings` moves
the subject to the holdings; `each holding` then finds that the subject *is*
the collection, and walks it.

```html
<section class="section section--holdings">
<h2 class="section-title">Holdings</h2>
<p class="text">VTI</p>
<p class="text">BND</p>
</section>
```

### `table_rows` — a table is its own loop

**You write** `table holdings` and its columns. **You get** a row per holding.
No page writes a loop for a table. (See `column_registration` for the
columns.)

### `empty_situation` — say what nothing looks like

**You write**

```
section holdings
  empty "No holdings yet."
  each holding
    text .symbol
```

**You get**, when there are no holdings, the message and nothing else:

```html
<section class="section section--holdings">
<h2 class="section-title">Holdings</h2>
<p class="empty">No holdings yet.</p>
</section>
```

When there are holdings, the `empty` line disappears instead. You never write
`if holdings.empty?`.

**To override** — nothing. `empty` *is* the word for it.

**Watch for**

- **`empty` needs a collection above it.** Directly under `page "…"`, there is
  no collection, so `empty` renders nothing — silently.
- **`nil` is not quite nothing.** A section over `holdings: nil` counts as
  empty, but an `each` inside it still tries to walk and raises:
  "nothing has no holdings to go through". An empty list (`[]`) works.
- **A table may not hold `empty`.** Put the table inside a section and give
  the section the `empty`.

### `collection_detection` and `nothing_detection` — what counts as a collection

A value is a **collection** when it can be walked (it is `Enumerable`) and is
not a `Hash` or a `Struct`: those are records, though Ruby lets you walk them.
A collection is **nothing** when it has no items, or is `nil`.

So `section settings` over a Hash moves into it like any object, and `.theme`
reads its key.

**Watch for** — nothing here since 2026-10-10. A `Struct` used to count as a
collection, so one whose fields were all `nil` counted as empty and its
section showed only its `empty` line.

---

## 5. How deep a heading sits decides its level

> *How deep a heading sits decides its level.*

### `heading_level`, `box_title` and `box_depth`

You never write `h2` or `h3`. A heading's level comes from where it sits, and
a heading inside a section or card becomes that box's title.

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

The section titles itself from its name at level 2; the card's heading is the
card's title at level 3.

**No override, by design** (dan, 2026-10-10). The level comes from the nesting
because that is what makes the page's outline true for a screen reader. A page
that could say `level: 2` could write a wrong outline. To make a heading *look*
bigger, ask the theme, which owns the look. To keep a heading from becoming
the box's title, use `title` or `text`.

**Watch for** — a section already titles itself. Add a `heading` inside it
and you get **two** section titles:

```
section accounts
  heading "B"
```

```html
<h2 class="section-title">Accounts</h2>
<h2 class="section-title">B</h2>
```

To give the section different words, say them on the section instead:
`section holdings, "Your holdings"`.

---

## 6. A word owns its element

> *A word owns its element, its class and its id.*

### `box_tag` and `leaf_tag` — the right element, unasked

Each word becomes the HTML element that fits it.

```
section notes          → <section class="section section--notes">
  list                 → <ul class="list">
    item "one"         → <li class="item">
aside                  → <aside class="aside">
footer "end"           → <footer class="footer">
money .v               → <span class="money">
badge ok, "Fine"       → <span class="badge badge--ok">
time .t                → <time class="time" datetime="2026-10-09">
```

`card` is an `<article>`, `figure` a `<figure>`, `disclosure` a `<details>`.

**To override** — nothing. The word owns its element; if you need a
different element, you need a different word.

### `root_class` — your own word carries its own name

When you define a word of your own and it has a single top line, that line
carries your word's name as a class, so your styles can find it.

**You write** `partials/holding_card.sp`:

```
card
  text .symbol
```

and a page that uses it:

```
each holding
  holding_card
```

**You get**

```html
<article class="card holding_card" id="holding-3">
```

**Watch for** — only a word with **one** top line gets the class. A word
whose body is two lines side by side gets no class and no wrapper, so nothing
can style it as a whole. Wrap the lines in a `box`.

### `card_id` — a card over something with an id gets that id

**You write**

```
each holding
  card
    text .symbol
```

**You get** `<article class="card" id="holding-3">` — the subject's noun and
its id. A card over something with no id gets no id.

**To override** — say `id:` yourself. `card id: "featured"` is
`id="featured"`, inside an `each` or out of one, and a card with nothing to
infer from takes the id you give it.

---

## 7. A value chooses its form

> *A value chooses its form — the control, the alignment, the text.*

The language looks at what a value *is* — a number, a date, true or false —
and picks the form that fits. It never guesses what a value *means*: whether
a number is money is the app's to say.

### `input_type`, `input_step` and `boolean_field` — a field fits its value

**You write**

```
page scenario
  form to: "/save"
    field age
    field growth_rate
    field retired
    field born_on
```

with `age: 61`, `growth_rate: 0.05`, `retired: false` and a date for
`born_on`.

**You get**

```html
<input id="age" name="age" type="number" value="61">
<input id="growth_rate" name="growth_rate" type="number" value="0.05" step="0.01">
<input id="retired" name="retired" type="checkbox">
<input id="born_on" name="born_on" type="date" value="1965-03-01">
```

A number is a number field. A fraction below one steps by hundredths; a larger
decimal, like `2.5`, takes `step="any"`, so the browser accepts it as it
stands. True or false is a checkbox. A date is a date picker. Anything else is
text.

**To override** — `type:` and `step:` — `field retired, type: text`,
`field rate, step: 0.5`.

**Watch for** — a rate steps by hundredths, so `0.055` in a field that held
`0.05` will not submit. Say `step:` when a rate needs finer places. A
`BigDecimal` is a decimal like a `Float`: 2.5 is written `2.5` and gets
`step="any"`.

### `numeric_alignment` — numbers line up on the right

A column or cell holding a number is right-aligned (`column--numeric`).
Nothing to say; it follows from being a number.

### `format`, `format_family` and `number_text` — how a number reads

**You write**

```
money .a
percent .b
number .c
money .d, precision: 2
```

with `1234567`, `0.0825`, `98765` and `-12.5`.

**You get**

```html
<span class="money">$1,234,567</span>
<span class="percent">8.2%</span>
<span class="number">98,765</span>
<span class="money money--negative">−$12.50</span>
```

Digits are grouped, money has its sign, a percent is scaled by a hundred, and
a negative number is marked.

In a table, a column's form comes from **`as:`, then the app's `format_for`,
then the value**:

```
table holdings
  column symbol
  column market_value, as: money
  column gain, as: percent
```

**To override** — `as:` in the page, or `format_for` in the app; `precision:`
for decimal places.

**Watch for**

- **Money shows the cents a value has.** `money` of `12.99` is `$12.99`; of
  `0.6` is `$0.60`; a whole amount stays whole. Whatever is not shown is
  rounded, never cut: `money .a, precision: 0` of `12.99` is `$13`.
- **A number shows the fraction it has, up to two places.** `number` of
  `2.7` is `2.7`, of `0.083` is `0.08`, of `12.999` is `13`. Trailing zeros
  are dropped. Below `0.005` it reads `0`: two places is the limit, and
  `precision:` says more.
- **A rate still needs to be named.** A column of `0.083` with no `as:` reads
  `0.08`, not `8.3%`. Whether a fraction is a rate is a domain fact the value
  cannot tell. Say `as: percent`, or have the app answer `format_for`.
- A negative percent uses a hyphen (`-1.2%`); money and number use a true
  minus sign (`−`).

### `time_text` — a date reads as a date

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

The machine-readable `datetime` is always there.

`relative` counts calendar days, as a person does: "today", "yesterday",
"N days ago", and the same forward, "tomorrow", "in N days". It does this up
to a month either way. Beyond that the full date reads better, and it shows
that.

**Watch for** — nothing here since 2026-10-10. `relative` used to measure
from the current moment to a date's midnight, so every afternoon it read
three days ago as "4 days ago". It also had no words for the future.

### `option_selected` — a choice selects the current value

**You write**

```
choice plan
  option basic
  option pro
```

with `plan` set to `:pro` (or `"pro"`).

**You get** `<option value="pro" selected="selected">Pro</option>`.

**To override** — nothing; it compares the value to each option.

### `badge_status` — a badge colours itself from a status

**You write** `badge .status` with `status: "warning"`.

**You get** `<span class="badge badge--warning">warning</span>`.

The statuses it knows are `warning`, `blocker`, `polish`, `ok`, `error`,
`pending` and `neutral`.

**To override** — name the variant yourself: `badge warning, "Look"`.

**Watch for** — a status it does not know gets no colour, silently.
`archived` renders as a plain badge.

---

## 8. Where a word sits chooses its form

> *Where a word sits chooses its form.*

### `button_type` — a button in a form submits it

`button "Save"` inside a `form` is `type="submit"`. Outside one it is
`type="button"`.

**To override** — `type:`.

### `group_shape` — a group in a form is a fieldset

**You write**

```
form to: "/x"
  group ages
    field age
group ages
  text "outside"
```

**You get**

```html
<fieldset class="group">
<legend>Ages</legend>
…
</fieldset>
<div class="group">
<h2>Ages</h2>
…
</div>
```

---

## 9. A gatherer collects before it renders

> *A gatherer collects what is beneath it before anything renders.*

### `column_registration` — columns are announced, not drawn

Inside a `table`, `column` and `total` do not draw anything themselves. They
tell the table what its columns are, so the header can be written before the
first row exists.

**You write**

```
table holdings
  column symbol
  column market_value, as: money
  total market_value
```

**You get** a header row, a row per holding, and a footer that sums the
column:

```html
<th>Symbol</th>
<th class="column--numeric">Market value</th>
…
<td>VTI</td>
<td class="column--numeric">$12,500</td>
…
<td>Market value</td>
<td class="column--numeric">$16,700</td>
```

### `first_truthy_branch` — `choose` picks one

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

**You get** exactly one branch: the first `when` that holds, or `otherwise`.

**No override, by design** (dan, 2026-10-10). Picking one is what `choose`
means. Two independent choices are two `choose`s.

---

## 10. What is said nearest wins

> *What is said nearest wins over what is inherited or inferred.*

This is the principle behind every override in this guide. Two conventions
belong to it directly.

### `box_body_over_children` — content beats children

**You write**

```
box "Body"
  text "child"
```

**You get** `<div class="box">Body</div>` — the content, and **not** the
children.

**No override, by design** (dan, 2026-10-10). Content and children are two
answers to one question, and the box shows one.

**Watch for** — the children are dropped silently. Nothing tells you. Ruled
on 2026-10-10, not yet built: content written in the page together with
children will be refused, since they can never show. Content read from the data
keeps the rule above. The children are what shows when that content is
empty.

### `partial_slot_forwarding` — a word finds a value on the word around it

When a word of your own expects a modifier and the call does not say it, the
word looks for it on the enclosing word that did.

**You write**

```
outer_slot slot: "forwarded"
  inner_slot
```

**You get** `inner_slot` reading `"forwarded"`, although nobody passed it.

**To override** — say it on the inner word.

**Watch for** — the value reaches into lines its author never wrote, by a
name the page does not show. No word in the language relies on it today.

---

## 11. The theme owns the look

> *The theme owns the look, and no page can say otherwise.*

### `theme_roles` — the convention that decides nothing

A page cannot say "wider", "denser" or "more emphasis". The theme owns those
decisions and no page sentence reaches them. This is registered as a
convention so the gap is never forgotten: when a page needs a different look,
a word must carry it.

---

## Conventions together

Conventions are meant to stack. Here is how much a short page gets from them.

### A portfolio

```
page portfolio
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

| You wrote | Conventions that fired |
|---|---|
| `page portfolio` | `document`, `title` |
| `section accounts` | `label` (its title, "Accounts"), `box_tag` (a `<section>`) |
| `empty "…"` | `empty_situation`, `nothing_detection` |
| `each account` | `subject_or_collection`, `singular_binding` |
| `card` | `box_tag` (an `<article>`), `card_id` (`id="account-9"`) |
| `heading .name` | `box_title`, `heading_level` (an `<h3>`) |
| `table holdings` | `table_rows`, `plural_collection` (inside *this* account) |
| `column …` | `column_registration`, `label`, `numeric_alignment` |
| `as: money` | `format`, `number_text` |
| `total market_value` | `column_registration`, `number_text` |

You get a titled document, a titled section, one card per account with its
own id and heading, and inside each a totalled, right-aligned money table.
With no accounts, you get the section and the sentence "No accounts linked
yet." — and nothing else.

### A task board

```
page board, "This week"
  section tasks
    empty "Nothing due."
    each task
      card
        heading .title
        badge .status
        time relative, .due_on
```

```html
<article class="card" id="task-2">
<h3 class="card-title">Ship</h3>
<span class="badge badge--blocker">blocker</span>
<time class="time time--relative" datetime="2026-10-08">2 days ago</time>
</article>
```

The status colours its own badge (`badge_status`), the date speaks relatively
(`time_text`), and each card is addressable by its task's id (`card_id`).
Note the limit from `time_text`: a task due *next* week shows its full date,
not "in 3 days".

### A form

```
page scenario, "Plan your retirement"
  form to: "/plan"
    group about_you
      field age
      field retired
    group money
      field base_income
      field growth_rate
      choice plan
        option basic
        option pro
    button "Save"
```

Every field labels itself (`label`, with the app's "Income before tax"
winning over English), picks its control (`input_type`, `boolean_field`,
`input_step`), each group becomes a fieldset (`group_shape`), the plan arrives
already selected (`option_selected`), and the button submits
(`button_type`). Apart from the form's address, the page writes no HTML
attribute at all.

### Your own word

```
# partials/holding_card.sp
card
  heading .symbol
  money .market_value
  percent .gain
```

```
page account
  section holdings
    empty "Nothing held."
    each holding
      holding_card
```

```html
<article class="card holding_card" id="holding-3">
<h3 class="card-title">VTI</h3>
<span class="money">$12,500</span>
<span class="percent">8.3%</span>
</article>
```

Your word is a card, so it inherits everything a card gets — the element, the
id, the title — and adds its own class (`root_class`). The page that uses it
cannot tell it from a word of the language.

---

## Where the conventions are weakest

Every risk above, in one place. This is the starting list for strengthening
them. Each was found by rendering, not by reading.

| Convention | What goes wrong | Today's workaround |
|---|---|---|
| `empty_situation` | With no collection above, `empty` vanishes silently | put it under the collection's word |
| `nothing_detection` | An `empty` line under a section over `nil` does not show, though over `[]` it does. A word over `nil` that reads a field raises "the subject is empty" by design (`ContractTest`), so which should win is open for dan | have the app give `[]` |
| `box_title` | A `heading` inside a section makes a second title | say the words on the section |
| `box_body_over_children` | Children are dropped silently. The override, "give the box children and no content", is inadequate (dan, 2026-10-10) | children, or content — not both |
| `badge_status` | An unknown status gets no colour, silently | name the variant |
| `root_class` | A word with two top lines gets no class | wrap them in a `box` |
| `link_href` | `link home` is `/home`, not `/` | `to: "/"` |
| `partial_slot_forwarding` | A value reaches lines its author did not write | say it on the inner word |
| `empty_situation` | A table may not hold `empty` | put it in a section |

Three patterns run through the list, and they are the questions worth asking
first:

1. **A convention that fails silently.** `empty` with nothing above it, a box
   that drops its children, an unknown status. When a convention cannot do
   its job, should it say so?

   **Ruled (dan, 2026-10-10): it depends on who can know.** A mistake you
   can see by reading the page is refused, with an error that names the
   fix, the way `hidden` outside a `form` already is. That covers `empty`
   with no collection above it, a box with written content and children, a
   `heading` that would make a second section title (`box_title`), and a
   word file with two top lines (`root_class`). A problem only the data can
   show gets a deliberate, documented fallback and never a broken page,
   because a live page must not fail when an app grows a new value. An
   unknown status gets the `neutral` badge.
2. **An override that does not override.** A convention you cannot overrule
   is a trap. `card id:` was the one found, and it is fixed (2026-10-10). No
   page in the corpus said it, so the gate never saw the fault. The question
   it raised, how many other documented overrides nothing exercises, was
   answered the same day by breaking each override in turn and running the
   suite. Three went unnoticed: `as:` on a `metric`, `type:` on a `button`,
   and a value said on the inner word over one forwarded from outside. All
   three worked; none was tested. Each now has a test that fails if the
   convention wins, so the count is zero.

   **Ruled (dan, 2026-10-10): three conventions are not guesses, so they
   have no override.** `heading_level`, `first_truthy_branch` and
   `box_body_over_children` decide what a word means, not what it probably
   means. Their entries above now say so plainly, rather than offering a
   restructuring that looks like an override.
3. **A convention that knows too little.** Three irregular plurals; a number
   that cannot tell a rate from a count; `relative` time with no future.
   Each is a place where teaching the convention one more thing would save
   every author the same workaround.

   **Ruled (dan, 2026-10-10): teach all six.** None of them gives the
   author anything new to write.

   - A number with a fraction shows up to two decimals, trailing zeros
     dropped. *(built)*
   - A short list of common irregular plurals, with `from:` for the rest.
     *(built)*
   - `each` over `nil` shows nothing. *(built)*
   - A Struct is a record, never a collection. *(built)*
   - `relative` counts calendar days and speaks of the future. *(built)*
   - `link home` goes to `/`.
