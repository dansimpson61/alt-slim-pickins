# Phase 7 — roth, ported

**Result: roth runs on this language. 88 lines of hand-written Slim become 40
sentences, and 35 lines of its script go with them.**

Run it: `ruby examples/roth/app.rb` · `ruby test/phase7_test.rb`

The engine is roth's, untouched, required straight off disk. Only the view
changed.

---

## What Phase 7 turned out to be

The roadmap said "every view, not the one page". roth has **one view** —
`views/controls.slim`, 91 lines — and 276 lines of `public/js/app.js`. It is a
single-page app, so porting it entirely means porting that one page entirely.

The roadmap also named a prerequisite: settle whether `link` asks the app for a
path or takes `to:`. **roth's page contains no links at all** — the only `link`
in it is the stylesheet. Drafting `path_for` here would have been the one word
in the vocabulary designed without a real page asking for it, which is exactly
the mistake Phase 8 exists to avoid for `chart`. It stays open, and it is still
the largest gap before a second port.

The wall roth actually hit is a different one.

## roth is a JavaScript mount surface

Measured on the 88 non-blank lines of `controls.slim`:

| | lines |
|---|---|
| empty holes a script fills — six `div.value --`, the SVG, the legend, the tooltip, the `<pre>` | **10** |
| lines carrying an id purely as a JS handle | **9** |
| plus two class hooks: `.advanced`, `.metric .value` | |

About a fifth of the page holds no data at all. The language has no `div` and
no `id`, deliberately, so this — not routing — is what a real app walls into on
its first page.

**dan's call: each hole becomes a word in roth's own module.** Not an `id:`
modifier — that is markup returning through the modifier slot, and it would
become the thing every later irregularity leaks through.

## The words roth needed

Three, in `RothWords`:

```
pending tax_delta, "Tax delta"
balance_chart
raw_output
```

`pending` is the interesting one. `metric` presents a value; this presents the
*absence* of one, and says so. The hand-written page left that implicit in a
`--`, so a reader could not tell which figures the server knows and which it
does not. Six of the nine escape-hatch uses in the repo are this word, all for
one reason: roth computes its results in the browser.

`balance_chart` swallowed two more mounts. The legend and the tooltip are parts
of the chart, not things a page should have to name — the same way `metric`
emits its own label and value. That took the count from five words to three,
and the page from 42 sentences to 40.

### The honest number

Phase 6 measured the escape hatch at **once in 284 sentences** and said plainly
that it did not prove much, because every page had been written by whoever wrote
the vocabulary. Phase 7 is the first page whose subject matter someone else
chose. Measured across every `.sp` file in the repo:

| | |
|---|---|
| sentences | **324** |
| escape-hatch words used | **9** |
| ratio | **1 in 36** |

That is the claim taking its first real hit, and it should be read as one. It is
still a small number — 40 sentences needed 3 new words and 9 uses — but "once in
284" was an artefact of who was writing.

## What the language took away

Not everything moved one-for-one. Three things in roth dissolved:

- **Two JS toggles became `disclosure`.** `#toggle-adv` with its `.advanced.hidden`
  section, and `#toggle-json` with its `pre#output.hidden`, were both
  hand-rolled show/hide. `disclosure` is a `<details>`; the browser does it.
  Two of the ten JS hooks and their handlers are gone.
- **One handler was dead.** `#strategy-value-wrapper` was shown when the
  strategy is `fixed` *or* `fill_bracket`, over a select with exactly those two
  options. It never once hid anything.
- **Every `value="…"` attribute became data.** The page states no defaults, and
  no field labels — fourteen labelled controls, none of them written in the
  page, which is CONTRACT.md's optional half doing the whole of its job.

`examples/roth/public/js/app.js` is roth's script with those removals and three
selector renames, listed below. **267 non-blank lines become 232.**

### The selectors that had to change

The port did not get to keep every name, and each change is the language
asserting something:

| roth | ported | why |
|---|---|---|
| `#metrics .metric .value` | `.metric .metric-value` | the class shapes are the vocabulary's |
| `#strategy` | `#conversion_strategy` | a control's id is its attribute name |
| `#show-baseline` | `#show_baseline` | same |
| `div.className='item'` | `'key'` | `item` is a word; its rules reached the legend |

`#controls`, `#balance-chart`, `#chart-legend`, `#chart-tooltip` and `#output`
are unchanged — the words emit exactly what roth's script already looked for.

## A bug the port fixed on the way past

`Engine::Inputs` was renamed to `ss_primary_*` / `ss_spouse_*`. The view and the
specs still say `social_security_*`:

```text
spec-style keywords: ArgumentError — unknown keywords: social_security_start_year
view posts social_security_amount=45000 -> inputs.ss_primary_amount = nil
```

So **Social Security is silently dropped in the running app** — on the default
inputs, lifetime taxes come out at 274,100 instead of 412,800, a difference of
138,700, and the page reports it with no sign anything was ignored. The ported
page uses the engine's own names, so it fixes this by construction;
`test_the_ported_field_names_reach_the_engine` pins it.

This is roth's bug, in roth's repo, and **nothing there has been touched.**
`~/dev/roth` is exactly as it was. Fixing it is dan's call.

Two smaller ones, also roth's and also untouched: `lib/engine/projector.rb`
builds `OpenStruct`s without requiring `ostruct` (it worked on a transitive
require), and `spec/projector_spec.rb` cannot construct an `Inputs` at all.

## What looking at it found

`check_grammar.rb` and `check_styles.rb` both passed the port before it was ever
served. Loading it found one real defect they could not have seen:

**The chart was capped at 512px inside a 1217px frame.** `balance_chart`
originally emitted `class="chart"` via `token(:chart)`, which looked tidy and was
wrong — the vocabulary's `.chart` carries `max-width: var(--measure-chart)`,
right for a figure the language draws and wrong for roth's full-bleed one. It
emits `.chart-canvas` now.

The general lesson is worth keeping: **an app word that borrows a vocabulary
class inherits styling written for a different thing.** `check_styles.rb` cannot
catch it — it only renders `pages/`, and Phase 6 already named that limit.

One thing that looked like a defect was not: four of the six metrics show `--`
on a served page, because the projector only produces a baseline when a
conversion is actually made. Correct, and now pinned by a test.

## Honest limits

- **The page adds structure roth did not have.** Three `group` fieldsets (Ages,
  Balances, Social security) where roth had flat `.form-group` divs. That
  follows `pages/roth_form.sp` from Phase 0, but it is a presentational change,
  not a pure port, and it flatters the line count a little.
- **roth's two spouse Social Security fields are still unreachable.** The engine
  has `ss_spouse_start_year` and `ss_spouse_amount`; roth's page never showed
  them, so neither does the port. Adding them is a product change.
- **`conversion_value` renders as `0.0`, not `0`.** The default is a Float so
  that `step_for` infers `0.01`, as roth's page hardcoded.
- **`section` cannot take a variant.** roth wanted "the chart section" as a
  presentational variant; `section`'s name slot is a subject, so it must exist.
  The `chart-frame` wrapper inside `balance_chart` sidesteps it. Worth a look
  before the next port.
- **An app word cannot ask for a label.** The hatch's five methods do not
  include `label_for`, so `pending` cannot reach the page → app → humanising
  chain that `metric` gets for free, and every `pending` states its label.
  That is six labels written in the page that a built-in would not have needed.
- **`check_styles.rb` still does not cover an app's own words**, so
  `.chart-canvas`, `.chart-legend`, `.chart-tooltip` and everything `app.js`
  draws into the SVG are unchecked. Same limit Phase 6 named, now with more
  behind it.
- **The chart does not redraw on resize.** roth's script draws once at load
  width. Pre-existing, carried over unchanged.

## Done-conditions

| From ROADMAP.md | Status |
|---|---|
| Port roth entirely — every view | done — roth has one view, and it is ported |
| The diff against its old views reviewed line by line | done — this document |
| Judge it: better to read and write than the Slim it replaced? | **dan** — open |

Suite: 95 tests, 356 assertions, 0 failures. 598 sentences, 0 problems.
58 rules, 0 problems.
