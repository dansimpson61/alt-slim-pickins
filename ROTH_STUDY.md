# Reading roth before porting it deeply

A study of `~/dev/roth` on two axes — architecture, and retirement-planning
domain knowledge. Every claim here was run, not read. The commands are in the
session; the numbers are reproducible against the engine as it stands.

Nothing in `~/dev/roth` was modified to produce this. Its working tree was
already dirty when this study began — four files, last touched 2025-09-11 —
and that turns out to be the most important fact in the report. See §5.

---

## The premise, tested

The brief was to assume an enthusiastic amateur with no sense of architecture
and shallow domain knowledge. Two thirds of that holds. The third part does
not, and getting it wrong would send the port in the wrong direction.

**The domain knowledge is not shallow. It is unfinished.** The tells:

- `RMDTable::TABLE` reproduces the IRS Uniform Lifetime Table for ages 73–90
  **exactly** — 26.5, 25.5, 24.6, 23.7 … 12.2. Not one is wrong.
- `taxable_social_security` implements provisional income properly: the 32k/44k
  thresholds, the 50% band, the 85% band, and the `[…, 0.85 * ss_total].min`
  cap. It is a correct piece of code.
- Those thresholds are **not** inflated with everything else — which is right,
  because the real ones have never been indexed. That is a detail most
  implementations get wrong by being tidy.
- IRMAA is applied on a two-year lag, from `magi_history[-3]`. The lag is real
  and correctly directioned.
- `README.md` opens with a **"Scope Contract (Deliberate Omissions)"**. Someone
  who lists what they are not modelling is not confused about the domain.

So the author knew the material. What is missing is not knowledge but
**wiring**: three of the four items above are computed correctly and then
dropped on the floor. That is the signature of this codebase, on both axes, and
it is the single most useful thing to know before porting it.

---

## Axis 1 — Architecture

### What it does, and how

A Sinatra app in classic style. `app.rb` (59 lines) has two routes: `GET /`
renders one Slim view, `POST /run` parses a JSON body, runs the engine, and
returns a JSON payload. `lib/engine/` holds the model. `public/js/app.js` (276
lines) does everything else.

Some of this is genuinely well made, and the port should keep it:

- **The Strategy pattern is correct.** `FixedAmount` and `FillBracket` share a
  two-method interface (`conversion_amount(ctx)`, `description`), are tiny, and
  are injected into the projector. Adding the spec's third strategy would be a
  new file and nothing else.
- **`YearResult` is a proper value object** — a keyword `Struct` with a `to_h`
  that rounds floats for transport.
- **The tables are separate modules** — `TaxTables`, `RMDTable`, `IRMAATable` —
  each with an inflation-adjusting reader.
- **The engine does not know about HTTP**, and `app.rb` does not know about tax.

The seams are where it comes apart.

### What it does not do

**1. `run` and `run_single` are the same method, twice.** 79 statements against
63, with **45 textually identical lines**. The comment says so out loud:
`# duplicate of run up to aggregation but without baseline recursion`. The
duplication exists to avoid infinite recursion when the baseline run spawns its
own baseline — a problem a `baseline:` flag or a private `simulate` would have
solved. Every domain fix below has to be made twice, and any fix applied once
silently desynchronises the strategy from its baseline.

**2. The result payload is assembled twice, differently.**
`Projector#to_json(result)` exists, is public, is advertised in the README's
Next Steps as "now available" — and **is called from nowhere**. `app.rb` builds
its own hash inline, and builds a *different* one: it splits primary and
baseline, and adds `standard_deduction`, which `to_json` never had.

**3. Dead code with no marker.**

| | |
|---|---|
| `TaxTables.ny_standard_deduction` + `NY_STANDARD_DEDUCTION_MFJ` | defined, called from nowhere |
| `Projector#to_json` | defined, called from nowhere |
| `irmaa_tier`, `irmaa_applied_cost` | computed every year, stored on every `YearResult`, read by no view and no script |

The IRMAA one is the expensive one: a whole subsystem — table, thresholds,
inflation, two-year lag — runs on every request and reaches no human eye.

**4. The test suite has never run.** Not "broke recently" — never.

At the **committed HEAD**, all five specs fail before reaching an assertion:

```text
5 examples, 5 failures
NameError: uninitialized constant Engine::Projector::OpenStruct
```

`Projector` builds `OpenStruct`s and nothing requires `ostruct`. The web app
survives because Sinatra or Slim happens to pull it in; `rspec` loads neither,
so **the suite has been dead in the committed tree, at a one-line cause.**

**5. And so a half-finished rename has sat in the working tree for eleven
months.** `~/dev/roth` is not clean. Four files are modified and uncommitted,
last touched **2025-09-11**:

```text
 M PROJECT.md   M README.md   M lib/engine/inputs.rb   M lib/engine/projector.rb
```

The diff is a rename in progress: `social_security_*` becomes `ss_primary_*`
plus a new `ss_spouse_*` pair. It reached `inputs.rb` and `projector.rb` and
stopped. `views/controls.slim` and `spec/projector_spec.rb` still say the old
names, so in the working tree the suite fails differently — `ArgumentError:
unknown keywords: social_security_start_year` — and the running app silently
drops Social Security:

```text
ported names (ss_primary_*)            taxes_paid=412800
roth's live names (social_security_*)  taxes_paid=274100
no social security at all              taxes_paid=274100
```

Posting the old names is **indistinguishable from having no Social Security at
all**. The app you get by running `~/dev/roth` today is off by $138,700 of
lifetime tax on its own defaults, and says nothing.

The causal chain is worth stating in order, because it is one fault, not three:

1. `ostruct` is never required, so **the specs cannot run** — at HEAD and in the
   working tree, for two different reasons.
2. Because nothing runs, a rename could be **abandoned halfway** without any
   signal.
3. Because the rename is halfway, the live app **silently drops an income
   source** and still renders a confident number.

The committed history is coherent — HEAD says `social_security_*` in all three
places. The damage is entirely in uncommitted work, which means it is also
entirely recoverable, and the cheapest possible fix at the root of it is one
`require`.

**6. No validation, anywhere.** `horizon_years: 0` raises
`NoMethodError: undefined method 'trad_end' for nil` from inside `aggregate`.
Negative balances, a growth rate of 5.0 (500%/yr), and `age_primary: 200` are
all accepted without comment. `POST /run` calls `JSON.parse` with no `rescue`,
so a malformed body is a 500.

**7. `round_h` puts presentation in the model.** Every monetary value is
quantised to the nearest $100 — inside the projector, before aggregation. The
totals are sums of rounded numbers, and no caller can ask for a finer figure.

**8. The client owns the results.** The server computes everything and sends
JSON; `app.js` renders all of it. The chart reads its inputs from
`window.__latestResult`, a mutable global, rather than from an argument. The
spec asked for StimulusJS and "the least javascript possible"; what exists is
276 lines of vanilla DOM manipulation in an IIFE.

---

## Axis 2 — Domain

### What it models, and how

Year by year over `horizon_years`, from `current_year`: inflate the brackets and
the standard deduction, grow both balances, work out Social Security and RMD,
ask the strategy how much to convert, sum gross income, subtract the standard
deduction, apply the brackets, assign an IRMAA tier, move the converted money
from Traditional to Roth. Then the whole thing again with a zero-conversion
strategy, for a baseline.

The skeleton is right. Six things hanging off it are not.

### 1. Social Security is taxed at 100%

`taxable_social_security` is computed, assigned to `ss_taxable`, and used for
exactly one thing: the `pre_conversion_taxable` figure handed to the strategy.
The actual tax computation four lines later uses the **full** benefit:

```ruby
gross_income   = base_income + ss_income + rmd + conversion   # not ss_taxable
taxable_income = [gross_income - std_ded, 0].max
federal_tax    = compute_tax(taxable_income, brackets)
```

Measured — $40,000 of Social Security and no other income at all:

```text
provisional income = 20,000, below the 32,000 threshold
correct taxable SS = $0, so correct federal tax = $0
engine: gross_income=40000  taxable_income=10500  federal_tax=1100
```

The one genuinely sophisticated piece of tax code in the repo is computed and
discarded. It also means the strategy and the tax calculation **disagree with
each other** about what Social Security is worth.

### 2. Nobody pays for the conversion

Converting moves money from `trad` to `roth`. The tax is computed, reported,
and **never funded from anything.**

```text
ages 60-69, no RMDs, growth 0
no conversion : trad+roth = 600,000   taxes = 0
convert 40k/yr: trad+roth = 600,000   taxes = 9,400
-> total wealth differs by 0, despite 9,400 of tax
```

There is no taxable account in the model, so there is nowhere for the tax to
come from. This is the most consequential domain gap in the app, because
**where the conversion tax is paid from is the main thing that decides whether
a conversion wins.** Paying it from outside funds is roughly the whole
advantage; paying it out of the IRA is a much weaker case. roth cannot express
the difference, and by defaulting to "free" it flatters every conversion it
models.

### 3. RMDs stop at 91

`RMDTable::TABLE` ends at age 90 and `rmd_for` says `return 0 unless factor`:

```text
age 86: rmd=65800   age 89: rmd=62500
age 87: rmd=64900   age 90: rmd=60900
age 88: rmd=63500   age 91: rmd=0      <- and every year after
```

Silent. A 65-year-old with a 30-year horizon runs to 95 and spends its last five
years with the Traditional balance compounding untouched — which is precisely
the scenario a conversion tool exists to warn about, inverted.

### 4. RMDs are taken on the wrong balance

Growth is applied at the top of the year and the RMD divides the **post-growth**
balance. A real RMD divides the prior 31 December balance.

```text
trad 1,000,000, growth 5%, age 73 (divisor 26.5)
correct (prior year-end):  37,736
as coded (post-growth)  :  39,600
```

About 5% high, every year, compounding — and it pushes taxable income up in
exactly the years the tool is being asked about.

### 5. `fill_bracket` misses the bracket by one standard deduction

Brackets apply to income *after* the standard deduction. The strategy compares
its headroom against `pre_conversion_taxable`, which is a pre-deduction figure:

```text
standard deduction = 29,500; the 22% bracket runs to taxable 201,000
it should have converted: 180,500
it actually converted   : 151,000
resulting taxable income: 171,500 — leaving 29,500 of the 22% bracket unused
```

The shortfall is exactly the standard deduction. The app's more advanced
strategy under-converts by that amount every single year.

### 6. IRMAA is charged to nobody, and to people who are 60

`aggregate` returns `taxes_paid, conversions, rmds, ending_trad, ending_roth`.
No surcharge appears in any total, so IRMAA affects no reported number. And
there is no age gate — Medicare starts at 65, but:

```text
age 60, MAGI 400,000 -> irmaa_tier = :tier4
```

`magi = gross_income # simplified` is also flagged in the code itself; real
IRMAA MAGI is AGI plus tax-exempt interest, and gross income overstates it by
the standard deduction and more.

### What it does not model at all

Some of these the README claims deliberately. Listing them together anyway,
because the size of the pile is the point for a tool whose single output is a
tax number:

**Named as deliberate omissions:** state tax, capital gains, QBI, AMT, credits,
itemised deductions.

**Not named, and structurally larger:**

- **No taxable/brokerage account.** Follows from §2, and rules out modelling the
  conversion honestly.
- **No heir.** The SECURE Act ten-year rule on inherited IRAs, and the
  beneficiary's tax rate, are the *main* argument for converting. Absent.
- **No survivor transition.** The first death moves the survivor from Married
  Filing Jointly to Single — roughly half the brackets and half the standard
  deduction, on most of the same income. The "widow's penalty" is one of the
  strongest cases for early conversion, and the model tracks `age_spouse` for
  30 years without ever letting anybody die.
- **No filing status at all.** MFJ is hardcoded in the constant names.
- **No ACA subsidy cliff.** roth's own default user is 60 — five years of
  marketplace coverage, where a conversion can cost more in lost premium
  credits than in tax.
- **Base income never changes.** Constant nominal for the whole horizon:
  `year 1 base_income=80000, year 30 (age 89)=80000`. It neither grows with
  inflation nor stops at retirement. The spec asked for a Base Income Growth
  input; it was never built.
- **Spouse is decorative.** `age_spouse` is incremented and stored every year and
  used for exactly one thing: counting seniors for the standard deduction. No
  spouse RMD, no separate balances.
- **No legislative change.** Today's schedule, inflated, for thirty years. There
  is no way to express "rates rise in 2034", which is the assumption the entire
  convert-now case rests on.
- **One deterministic growth rate.** No sequence-of-returns, no volatility.
- **No basis, no 5-year rules, no QCDs.**

### The metric problem, which outranks all of it

The headline number is **lifetime taxes paid, nominal and undiscounted.**

That is the wrong objective. Minimising lifetime tax is not the goal; maximising
after-tax wealth is. The two come apart exactly where conversions live — a
conversion *raises* tax now to lower it later, and a nominal undiscounted sum
treats a dollar of tax in 2055 as equal to a dollar in 2026.

The app reports no after-tax terminal wealth. `ending_trad` and `ending_roth` are
reported as raw balances, and a Traditional dollar is not worth a Roth dollar —
which is the entire premise of the tool. The two "Final Roth %" metrics are the
closest it comes, and they measure the ratio rather than the value.

---

## What was specified versus what exists

`roth_analysis_specification.md` is ambitious and quite good — Tufte,
event annotations, an IRMAA timeline, sparklines in table rows. It is worth
reading as the statement of intent it is. Measured against it:

| Specified | Status |
|---|---|
| Ages, balances, base income, growth, inflation, horizon | **built** |
| Fixed Amount and Fill Bracket strategies | **built** (Fill Bracket off by a deduction) |
| Two parallel simulations, strategy vs "do nothing" | **built** |
| Baseline comparison toggle, tax line overlay | **built** |
| Slim templates | **built** |
| Social Security per person, both spouses | engine yes; the form only ever showed the primary |
| Federal tax | SS taxed at 100% |
| IRMAA | computed, costed to nobody, no age gate |
| RMDs | stop at 91, taken on the wrong balance |
| Balance updates | tax never funded |
| Summary metrics | 6 of them; no net worth, no IRMAA total |
| Filing status dropdown | **absent** |
| State of residence, NY retirement exclusion | **absent** (constant defined, unused) |
| Base income growth | **absent** |
| Target MAGI strategy | **absent** |
| Milestone checks at 59½, 65, 73 | **absent** |
| Sliders with live sparklines | **absent** — plain number inputs |
| Plain-language prose ("your yearly Roth conversion goal") | **absent** — says "Conversion Strategy" |
| Two screens: Controls, then the Tufte display | **absent** — one page |
| Event annotations on the chart | **absent** |
| IRMAA tier timeline | **absent** |
| Tax efficiency gauge | two text metrics |
| Year-by-year table with sparklines | **absent** — a raw JSON dump instead |
| StimulusJS, "least javascript" | **absent** — 276 lines of vanilla in an IIFE |
| "Thoroughly tested" | 5 of 5 specs red |

### The chart answers a different question than the one specified

The spec asked for a stacked area of **account balances** — Traditional against
Roth, over time — with a tax line over it. That is the wealth story.

What `app.js` draws is a stacked area of **annual income components**: base
income, Social Security, RMD, conversion. That is the tax story.

Both are reasonable charts. They are not the same chart, and the specified one
was never built. The data for it is *already in the JSON* — every `YearResult`
carries `trad_end` and `roth_end`, and `extractSeries` throws both away:

```js
function mapYears(obj){ return obj.years.map(y=>({
  year:y.year, base:…, ss:…, rmd:…, conv:…, gross:…, tax:…
})); }   // trad_end and roth_end are never read
```

The same pattern as `ss_taxable`, as IRMAA, as `to_json`: computed, transported,
dropped.

---

## What this means for a deeper port

The pattern is consistent enough to plan against. **roth's problem is almost
never a missing calculation — it is a calculation that was written correctly and
never connected.** Four separate subsystems (taxable Social Security, IRMAA, the
balance series, `to_json`) are complete and unreferenced.

That has a direct bearing on what "port more deeply" should mean, because it
splits into two jobs that are worth keeping apart:

**Connecting what is already there is a view problem, and it is ours.** The
balance chart the spec asked for, the IRMAA timeline, the year-by-year table
that currently arrives as a raw JSON dump — all three are already computed and
already on the wire. Rendering them is exactly what this language is for, and
doing it server-side is what would let most of those 276 lines of JavaScript go.
This is the job that actually tests the language, and it needs no domain
judgement at all.

**Fixing the six domain defects is a different project.** Funding the conversion
tax, taxing Social Security correctly, extending the RMD table, fixing the
divisor year, fixing `fill_bracket`, gating and costing IRMAA — none of that is
a view concern, and several are consequential enough that they change what the
tool says. They are also not mine to decide: whether roth should model a taxable
account, or a survivor transition, or a rate-regime change, is a question about
what the tool is for.

The honest recommendation is to do the first and put the second in front of dan
as a list, which is what this document is.
