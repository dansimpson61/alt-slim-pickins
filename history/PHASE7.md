# Phase 7 — roth, ported

**Result: roth runs on this language, results and all. Its 88-line page and
249-line script become 58 sentences and 47 lines of script, and the six
figures, the two charts and the year-by-year table are rendered on the
server.**

Run it: `ruby examples/roth/app.rb` · `ruby test/phase7_test.rb`

The engine is roth's, required off disk and otherwise untouched. `~/dev/roth`
was not modified. What it gets wrong is measured in
[ROTH_STUDY.md](../roth/ROTH_STUDY.md) and scheduled in
[ROTH_DOMAIN_BACKLOG.md](../roth/ROTH_DOMAIN_BACKLOG.md).

This happened in two rounds, and the difference between them is the finding.

---

## What Phase 7 turned out to be

The roadmap said "every view, not the one page". roth has **one view** —
`views/controls.slim`, 91 lines — and 276 lines of `public/js/app.js`.

The roadmap also named a prerequisite: settle whether `link` asks the app for a
path or takes `to:`. **roth's page contains no links at all.** Drafting
`path_for` here would have been the one word designed without a real page
asking for it, which is the mistake Phase 8 exists to avoid. It stays open, and
it is still the largest gap before a second port.

The wall roth actually hit was that a fifth of its page held no data: ten empty
holes a script filled, nine more lines carrying an id purely as a JS handle.

---

## Round one — replacing the markup

The page became 40 sentences, and every hole became a word in roth's own
module: `pending` for each figure the server did not know, plus mounts for the
chart and the raw JSON pane. Three words, nine uses.

That produced the number Phase 6 asked for. Phase 6 had measured the escape
hatch at **once in 284 sentences** and said plainly that it proved little,
because every page so far had been written by whoever wrote the vocabulary.
With roth's page written to someone else's design it became **9 uses in 324
sentences — 1 in 36**.

Which was the right measurement of the wrong thing. Every one of those nine
uses existed because roth computes its results in the browser. The escape hatch
was not measuring the vocabulary's coverage; it was measuring where rendering
happened.

## Round two — moving the results to the server

dan's call, and it changes the answer:

| | round one | round two |
|---|---|---|
| escape-hatch words | 3 | **1** |
| escape-hatch uses | 9 | **3** |
| across sentences | 324 | 344 |
| ratio | 1 in 36 | **1 in 115** |

`pending` is gone because the figures are real, so `metric` presents them. The
JSON mount is gone because the table replaced it. What is left is `drawing`,
for the one thing that is genuinely roth's own — a picture roth drew.

**The escape hatch was never the measurement it looked like.** It counts the
distance between what a page needs and where its data is, and moving the data
closed most of it.

---

## The architecture

roth already had the separation MVC is usually brought in to create:
`lib/engine` knows nothing about HTTP, `app.rb` knows nothing about tax. The
failures were not a missing layer, they were **unenforced seams** — so this
round adds the two objects that enforce them, and no more.

```text
lib/engine.rb      roth's engine, required off disk (plus the `ostruct` it forgot)
lib/scenario.rb    the inputs: names, defaults, labels, formats, bounds
lib/projection.rb  the results: six figures, the table, the two drawings
lib/chart.rb       the SVG
views/*.sp         the language
app.rb             parse, project, render
```

> **Since superseded.** [PHASE8.md](PHASE8.md) redrafted `chart` against those
> 130 lines of `lib/chart.rb`, which no longer exists — roth's charts are
> sentences now, and its last app word went with them. Every figure in this
> document is what was true at the end of Phase 7.

There is deliberately **no model layer in the persistence sense**. roth has no
persistent state; each request is a pure function from a scenario to a
projection. `Scenario` is a validated value object and the engine is a pure
calculation — between them they are the "M", and inventing a record to sit
behind them would have been ceremony.

### One object owns the names

This is the fault the round exists to fix. roth's field names lived in the
struct, the form and the specs with nothing binding them; a rename in September
2025 reached the first and stopped, and the app has silently dropped Social
Security ever since.

`Scenario::FIELDS` declares each input once. The form derives from it, the
parameters derive from it, and `to_engine_inputs` is the only method that knows
the engine's spelling.

**And the language enforces it.** A page naming an attribute its subject does
not have raises on the line that named it:

```text
SlimPickins::Error: this scenario has no no_such_input
```

That is the drift roth went eleven months without noticing, made loud by the
same rule that resolves every other `.foo`.

### Validation, which roth had none of

`horizon_years: 0` raised `NoMethodError` from inside `aggregate`. Negative
balances, a 500% growth rate and `age_primary: 200` were all accepted silently.

```json
{"complaints":["Age (primary) must be between 0 and 120 — using 120",
               "Horizon (years) must be between 1 and 60 — using 1"]}
```

Blank and unparseable input falls back to the field's default rather than
reaching the engine as `nil`.

### The full page and the fragment cannot drift

`views/partials/report.sp` is a word. The page says `report`; `POST /projection`
renders **the same file** for the swap. A test asserts the fragment is a
substring of the whole page.

---

## What moved off the client

`app.js` went from **249 code lines to 47** — the two jobs a server genuinely
cannot do: ask for a fresh projection without a reload, and follow the pointer.

- **Two hand-rolled toggles.** One became `disclosure`, a `<details>` the
  browser drives. The other, the raw JSON pane, has no reason to exist now the
  table does its job.
- **One handler was dead.** `#strategy-value-wrapper` was shown when the
  strategy is `fixed` *or* `fill_bracket`, over a select with exactly those two
  options. It never once hid anything.
- **All formatting.** `formatMoney` rounded to thousands; the language's
  `:money` gives `$412,800`, and `format_for` says which columns are money.
- **Both charts**, drawn in Ruby with a `viewBox` — so they are responsive with
  no script at all. roth's measured `clientWidth` once at load and never redrew
  on resize.

### The chart the specification asked for

The spec asked for a stacked area of **account balances**, Traditional against
Roth. `app.js` drew annual **income components**. Both are reasonable; they are
not the same chart, and the specified one was never built — while its data sat
on the wire and `extractSeries` threw it away.

It exists now. So does the year-by-year table, and with it the IRMAA
subsystem — table, thresholds, inflation, two-year lag — which ran on every
request in roth and reached no screen at all. It has a column.

### The honest cost

The port is **not smaller in total**.

| | roth | ported |
|---|---|---|
| view | 88 lines of Slim | 60 sentences |
| script | 249 lines | 47 lines |
| Ruby | — | 411 lines |
| **total** | **337** | **518** |

It trades ~200 lines of untested browser code for 411 lines of testable Ruby,
and buys four things roth did not have: input validation, a data table, the
balance chart, and a chart that stays readable when the window changes size.

That trade was the question this phase put to dan, and
[his answer is below](#dans-judgement).

---

## Two defects in the language, found by a real page

Both are the kind Phase 7 exists to surface: neither was visible until someone
else's page asked for something.

**1. `columns:` made a grid permanently non-responsive.** `grid metrics,
columns: 3` emitted `--track: calc((100% - 2 * var(--gap)) / 3)`. A track that
is a percentage of its container scales *with* the container, so `auto-fit`
never has cause to reflow — three columns at 1280px and three at 375px, 101px
each. Now floored at a new `--track-min`, so it gives three where they fit and
one where they do not.

**2. `column` asked the wrong object for its label.** `format_of` had always
asked the *row* for its format; labels asked whatever subject held the
collection. A table of `Year`s therefore read its headers off the `Projection`
that merely contained them, and rendered "Irmaa applied cost", "Rmd", "Trad
end". `column` now defers the header until the first row is in hand, and
resolves it by the same three levels as everything else — the page said it, or
the row said it, or English.

The second is the more interesting: two methods eight lines apart implemented
the same precedence rule against different objects, and every page written so
far had a table whose rows and whose container agreed.

### And one in the port, found the same way

Every checker passed the page before it was ever served. Loading it showed an
empty bordered box under both charts: the tooltip div shipped without `hidden`,
so it was visible until a pointer first moved. It ships hidden now, and a test
pins it — but nothing except looking would have caught it, which is the lesson
Phase 5 already wrote down and this round confirmed again.

### And four an outside review found

An outside reviewer read the finished port. Everything it raised was real, and
two of the four were things this round had itself created.

**1. The validation seam was only half wired — the disease it was built to
cure.** `POST /run` refused unsound input with a 422; `POST /projection`, which
is what the *form* actually posts to, did not. `age_primary=200` with
`horizon_years=0` reached the engine and came back a **500** from inside
`aggregate`. Scenario now clamps out-of-range values to the edge and says what
it did, so a projection always exists; the JSON endpoint still refuses. One
object, two policies, chosen by the caller.

```text
Age (primary) must be between 0 and 120 — using 120
```

**2. A control went missing unlogged.** roth's page had *three* interactive
controls and this document counted two. The "Show Baseline" checkbox overlaid
the do-nothing series on the chart, and the ported charts had no such series at
all — the comparison survived only as headline numbers. It is drawn now, and
needs no checkbox: roth deferred it because a script had to redraw, and there
is nothing to defer on the server. A control the reader does not have to find
is one fewer control.

The legend had gone the same way, unremarked. It is drawn inside the SVG now,
so it survives the fragment swap for free — and it describes only what the
caller actually drew, after inferring it put a "Do nothing" swatch on the
balance chart, which has no such line.

**3. The port pins itself to roth's uncommitted working tree.** `Scenario`
speaks the `ss_primary_*` spelling of the rename that has sat half-finished
since 2025-09-11. Finishing it keeps this working; reverting it breaks this —
and the break would have surfaced as a *wrong number* rather than an error,
which is exactly the failure mode being ported away from.
`lib/engine.rb` now checks `Engine::Inputs.members` at load and raises with the
reason and a pointer to ROTH_DOMAIN_BACKLOG §0.2.

**4. `ruby examples/roth/app.rb` did not work.** A `Sinatra::Base` subclass
does not parse ARGV, so `-p` was silently ignored and `run!` took 4567 — which
roth itself is usually holding. Both examples now take `PORT`, defaulting to
4577 and 4576.

### And one in the checker

`check_grammar.rb` finds app words by scanning for `module *Words`, anchored on
`^end`. Nesting the module inside `module Roth` — ordinary Ruby — made it read
straight past its own `end` and count `project` and `request_params` as
vocabulary. It now matches the `end` at the module's own indentation. A
convention that punishes correct nesting was hiding, in principle, a genuinely
undefined word.

---

## Honest limits

- **The numbers on the page are wrong**, because roth's engine is wrong. The
  page says so: an `aside` lists the six defects. Fixing them is
  [ROTH_DOMAIN_BACKLOG.md](../roth/ROTH_DOMAIN_BACKLOG.md), deliberately a separate
  project.
- **The page adds structure roth did not have** — three `group` fieldsets where
  roth had flat divs. It flatters the sentence count slightly.
- **roth's two spouse Social Security fields are still unreachable.** The
  engine has them; roth's page never showed them, so neither does this.
- **`check_styles.rb` still does not cover an app's own words**, so
  `.drawing`, `.chart-canvas` and everything inside the SVG are unchecked. The
  limit Phase 6 named, now with a chart engine behind it.
- **The library is cached per views directory**, so editing a partial needs a
  restart. Phase 6 named this too; it cost real time this round.
- **A stale stylesheet cost half an hour.** `send_file` with no `Cache-Control`
  let a browser hold an old sheet while the served file was correct. The
  example now sets `no_store`.
- **`conversion_value` renders as `0.0`**, because the default is a Float so
  that `step_for` infers `0.01`.
- **An app word still cannot ask for a label.** The hatch's five methods do not
  include `label_for`. It did not bite this round — `drawing` takes no label —
  but it is why round one's `pending` had to state all six.

---

## Done-conditions

| From ROADMAP-0.1.md | Status |
|---|---|
| Port roth entirely — every view | done — roth has one view, and it is ported |
| The diff against its old views reviewed line by line | done — this document |
| Judge it: better to read and write than the Slim it replaced? | **done** — see below |

## dan's judgement

Recorded 2026-08-31, after an outside review: **clearly worth it.** "We are
exactly where we had hoped we would be at this phase of the project. We have
strong foundations and we are learning as we build."

The one flank with no evidence, and the review's sharpest point: roth exercised
forms and tables, which are this language's home turf, and never exercised
**conditional or bespoke UI**. `choose`/`when`/`otherwise` and the `if:`
modifier still have no real page behind them. A second port should target that.

Suite: 116 tests, 475 assertions, 0 failures. 615 sentences, 0 problems.
58 rules, 0 problems.
