# Phase 8 — `chart`, redrafted

**Result: `chart` is the same shape as `table`. roth's 130 lines of Ruby became
thirteen sentences, and roth's last app word went with them.**

Run it: `ruby examples/roth/app.rb` · `ruby test/phase8_test.rb`

---

## What the first draft was

`chart` was the one entry in [VOCABULARY.md](VOCABULARY.md) written without
evidence. It was drafted on paper, three pages failed to test it, and the
roadmap held it back to last for exactly that reason.

Measured before touching it:

```
chart line, .balances, over: .years
```

```html
<svg class="chart chart--line" viewBox="0 0 320 120" role="img"
     data-over="2025,2026,2027"><polyline points="0.0,78.3 160.0,41.7 320.0,5.0" /></svg>
```

- Its entry claimed to infer **"axes, scale and legend from the data"**. It
  emitted none of the three.
- `over:` became a `data-over` attribute that nothing read.
- It took **parallel flat arrays** — `balances` beside `years` — the one data
  shape nothing else in the language uses.
- One series only. roth needs six.

Nobody noticed, because no page had ever needed a chart anyone would read.

## What the redraft is

**The same shape as `table`.** Not a new idea — an existing one, applied.

```text
table products            chart years
  column name               band base_income
  column price              line federal_tax
```

> A table declares its columns and the rows come from the subject.
> A chart declares its series and the points come from the subject.

Same rule of government, same subject rule, same registration trick — `band`,
`line` and `level` register rather than render, so the scale can be settled
before anything is drawn, exactly as `column` waits for the first row.

Three words added, one cut, and no syntax touched.

### What it infers, and now actually delivers

| | from |
|---|---|
| the scale | the data, rounded up to whole steps |
| the axes and their ticks | the scale |
| the x labels | the singular of the collection's name — `chart years` reads each row's `year` |
| every series label | the row's `label_for` |
| every value's formatting | the row's `format_for` |
| the key | the series that were actually drawn |
| the hover detail | the same, as a native `<title>` |

A page says which attributes to draw. It says nothing else.

### `level`, and the one thing the grammar would not allow

A horizontal reference — a threshold, a target, a deduction:

```
level .standard_deduction, "Standard deduction"
```

The first attempt at this was `level 1000000.0, "A million"`, and
`check_grammar.rb` refused it:

```text
UNKNOWN ARG   specimen.sp:81: "1000000.0" in "level 1000000.0, \"A million\""
```

**The grammar has no numeric literal, and should not.** Content is a quoted
string or a dotted value; a bare number is neither. A dot means data and a bare
word is language, so a figure in a page has nowhere to stand — it belongs to
the app. That was a rule nobody had written down, discovered by trying to break
it.

## roth, which is the evidence

roth's income chart — four stacked bands, a tax overlay, a do-nothing
comparison from a second collection, a deduction line and a bracket for every
tax rate:

```
chart years
  level .standard_deduction, "Standard deduction"
  each bracket
    level .ceiling, .label
  band base_income
  band social_security
  band rmd
  band conversion
  line federal_tax
  line gross_income, "Do nothing", from: .baseline_years
```

**`each` composes with registration.** `chart` knows nothing about loops; a
bracket is a row like any other, and `level` registers from inside `each` the
way it would anywhere. Nothing was added to make that work.

`from:` is the same modifier `each` already took, meaning the same thing —
*this line is about something else*. It is how a comparison is laid over a
chart without a second chart.

### What it cost, and what it saved

| | before | after |
|---|---|---|
| roth's charts | 130 lines of Ruby | **13 sentences** |
| roth's own Ruby | 411 lines | **262** |
| roth's script | 47 lines | **25** |
| roth's stylesheet | ~70 lines | **14** |
| `charting.rb` | 80 lines, one series | **140 lines, serving every page** |

**roth has no words of its own.** Round one of the port needed three app words,
server-rendering removed two, and this removed the last. An app that speaks
nothing but the vocabulary is the strongest form of the claim this project set
out to test, and it took a real app's real charts to get there.

Across every `.sp` file in the repo the escape hatch now stands at **1 use in
356 sentences** — the `video` in the portfolio example, which is still the only
thing the vocabulary genuinely has no word for.

### The tooltip that needed no script

The hover columns carry their numbers in a `<title>`, so browsers show them for
free. roth spent forty lines of JavaScript and a mount point on this; the
`data-` attributes remain for anyone who wants a richer one, and a script that
reads them never has to recompute a scale.

That is the last thing that moved off the client. `app.js` is now **25 lines**
doing the one job a server cannot: asking for a fresh projection without a
reload.

## `pie` is cut

`chart pie, .allocation` had one use, in a demo page, drawing an allocation the
table directly beneath it already showed better. A pie has no x axis and does
not fit the series model, and forcing it in is what made the first draft
useless. No real app asked for one.

The evidence rule cuts both ways: a word with no page behind it goes.

## Four defects, all found by looking

Every one passed `check_grammar.rb` and `check_styles.rb`.

**1. A reference stretched the scale.** roth's top tax bracket sits at $760k
against $200k of income. Letting levels into the ceiling calculation stretched
the axis fourfold and pressed every band flat along the bottom. The data sets
the scale now; a reference outside it is clipped, because a threshold far above
the data tells a reader nothing and flattens everything that would have.

**2. An empty series still drew.** roth's do-nothing line takes `from:` a
baseline that does not exist until something is converted. `from: []` is
truthy, so it drew an empty path and claimed a place in the key. A series with
no points is not a series.

**3. Hover columns spilled outside the plot.** Centred columns overhang both
ends, and with few points they overhang a long way — the first one started at
`x="-116"`. They are held inside the plot now.

**4. Crowded level labels overlapped.** Only visible under stress: a $450k
income brings seven brackets into view, and "12%" landed four pixels from
"Standard deduction". The rule always draws; the label is dropped where it
would sit on another, and **declaration order decides who survives** — so the
page keeps the say, and roth writes its deduction before its brackets.

## Honest limits

- **Bracket shading became bracket lines.** roth drew filled, alternating bands
  between thresholds; `level` draws a rule at each. The information is the
  same and the lines are quieter, but the "you are in the 22% band" feel is
  gone. A `zone low, high` word would restore it and has exactly one page of
  evidence, which is not enough.
- **No bar chart, no pie, no second axis, no stacking of lines.** Only what
  roth and the portfolio actually needed. `bar` and `area` from the first draft
  are gone with `pie` — none had a page.
- **`chart` cannot be styled per series beyond four bands and two lines.**
  `.chart-band--0` through `--3` and `.chart-line--0`/`--1` have rules; a fifth
  band falls back to the base class. An app wanting more owns the styling, the
  same boundary Phase 6 named.
- **`check_styles.rb` still does not cover an app's own words** — though roth
  no longer has any, so for the first time that limit costs nothing.
- **The x axis is labels, not a scale.** Points are evenly spaced by position,
  not by value, so a collection with gaps in its years would draw them evenly.
  Neither page has gaps.
- **The singular rule fired on one of the three real charts.** `chart years`
  finds each row's `year`, which is why roth's two need no `over:`. The
  portfolio's `chart balances` does — its rows are balances and its axis is
  years, and a collection named for its contents cannot name its axis. The
  convention is right where the collection is named for the axis and says so
  otherwise, which is the shape of every convention here; but it is worth
  saying that it earned its keep twice and cost a modifier once.

## Done-conditions

| From ROADMAP-0.1.md | Status |
|---|---|
| Find a real charting need | done — roth's two charts, and 130 lines of Ruby |
| `chart` redrafted against something real, or cut | **redrafted** — and `pie` cut |

Suite: 133 tests, 522 assertions, 0 failures. 632 sentences, 0 problems.
65 rules, 0 problems.
