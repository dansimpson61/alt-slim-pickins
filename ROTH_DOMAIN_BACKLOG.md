# roth — the domain backlog

Extracted from [ROTH_STUDY.md](ROTH_STUDY.md) so it can be run as its own
project. Nothing here is a view concern, and none of it should be mixed into
the port.

Everything in Part A was measured against the engine. Everything in Part B is a
question about what the tool is *for*, and belongs to dan.

**This document lives here because `~/dev/alt-slim-pickins` is where the study
was done and its tree is clean.** It describes work in `~/dev/roth`, and should
move there when that project wakes up.

---

## Part 0 — Do this before anything else

**Nothing in this backlog can be verified until the suite runs.** It has never
run: `Projector` builds `OpenStruct`s and no file requires `ostruct`. The web
app survives on a transitive require from Sinatra; `rspec` loads neither.

```text
5 examples, 5 failures
NameError: uninitialized constant Engine::Projector::OpenStruct
```

- **0.1 — `require 'ostruct'` in `lib/engine/projector.rb`.** One line. It is
  the root of everything in §5 of the study.
- **0.2 — Finish or revert the abandoned rename.** `~/dev/roth`'s working tree
  has been dirty since **2025-09-11**: `inputs.rb` and `projector.rb` were
  renamed `social_security_*` → `ss_primary_*` + a new `ss_spouse_*` pair;
  `views/controls.slim` and `spec/projector_spec.rb` were not. Until this is
  settled the running app silently drops Social Security — 274,100 against
  412,800 of lifetime tax on its own defaults, indistinguishable from having no
  Social Security at all. **Finishing is the right call** (the spouse pair is
  real work worth keeping), and the port already assumes the new names.
- **0.3 — Get the five specs green** before changing any calculation, so every
  fix below has something to fail against.

---

## Part A — Defects. No judgement required; these are simply wrong.

### A1. Social Security is taxed at 100%

`taxable_social_security` is implemented correctly — provisional income, the
32k/44k thresholds, the 50% and 85% bands, the `0.85 * ss_total` cap — and its
result reaches only the strategy context. The tax computation four lines later
uses the full benefit.

```ruby
gross_income   = base_income + ss_income + rmd + conversion   # not ss_taxable
taxable_income = [gross_income - std_ded, 0].max
```

Measured, $40,000 of Social Security and no other income:

| | |
|---|---|
| provisional income | 20,000 — below the 32,000 threshold |
| correct taxable SS | $0, so correct federal tax **$0** |
| engine | `taxable_income=10500`, `federal_tax=1100` |

**Fix:** use `ss_taxable` in the taxable-income line. Note this also makes the
strategy and the tax calculation agree, which they currently do not.

**Care:** `gross_income` is also fed to MAGI and to the chart's stacked series,
where the *full* benefit is the right number. Taxable income and gross income
genuinely differ here; the model currently has one variable doing both jobs.

### A2. Nothing funds the conversion tax

Converting moves money from `trad` to `roth`. The tax is computed, reported, and
paid by nobody.

```text
ages 60-69, no RMDs, growth 0
no conversion : trad+roth = 600,000   taxes = 0
convert 40k/yr: trad+roth = 600,000   taxes = 9,400
-> total wealth differs by 0
```

This is the largest defect in the app. Where the conversion tax is paid from is
the main thing that decides whether a conversion wins; paying from outside funds
is roughly the whole advantage. roth cannot express the difference and defaults
to "free", which flatters every conversion it models.

**Fix requires a decision** — see B1. The minimum honest version is to subtract
the tax from the Traditional balance, which at least stops the model inventing
money. The right version needs a taxable account.

### A3. RMDs stop at 91

`RMDTable::TABLE` ends at age 90; `rmd_for` returns `0` silently when the table
has no entry.

```text
age 88: rmd=63500   age 90: rmd=60900
age 89: rmd=62500   age 91: rmd=0     <- and every year after
```

A 65-year-old on a 30-year horizon spends five years with the Traditional
balance compounding untouched — the exact scenario the tool exists to warn
about, inverted.

**Fix:** extend the Uniform Lifetime Table to 120 (its real end), and make a
missing factor raise rather than return zero. The 73–90 entries already present
are correct and should not be touched.

### A4. RMDs divide the wrong balance

Growth is applied at the top of the year and the RMD divides the post-growth
balance. A real RMD divides the prior 31 December balance.

```text
trad 1,000,000, growth 5%, age 73 (divisor 26.5)
correct (prior year-end): 37,736
as coded (post-growth)  : 39,600
```

~5% high every year, compounding, and it inflates taxable income in precisely
the years being asked about.

**Fix:** capture the balance before growth, or compute the RMD from the previous
iteration's `trad_end`.

### A5. `fill_bracket` under-converts by one standard deduction

Brackets apply to income *after* the standard deduction; the strategy compares
its headroom to `pre_conversion_taxable`, a pre-deduction figure.

```text
standard deduction = 29,500; the 22% bracket runs to taxable 201,000
should convert: 180,500
converts      : 151,000
leaves exactly 29,500 of the 22% bracket unused
```

The shortfall equals the standard deduction, every year. The app's more advanced
strategy is systematically the weaker one.

**Fix:** pass the standard deduction into the strategy context and subtract it,
or hand the strategy taxable income rather than gross.

### A6. IRMAA has no age gate

Medicare starts at 65. The model assigns tiers at any age:

```text
age 60, MAGI 400,000 -> irmaa_tier = :tier4
```

**Fix:** no surcharge before the year the person is 65. Note the two-year
lookback interacts: the MAGI that matters for the first Medicare year is from
age 63.

### A7. `horizon_years: 0` crashes

`aggregate` calls `years.last.trad_end` on an empty array:
`NoMethodError: undefined method 'trad_end' for nil`. Negative balances, a
growth rate of 5.0, and `age_primary: 200` are all accepted silently.

**Fix:** validate at the boundary. This is the input-model work in the
architecture round, not a domain change — listed here only so it is not lost.

### A8. The tax tables have no provenance

`FEDERAL_BRACKETS_MFJ` is commented "Simplified MFJ 2025-ish brackets
(illustrative)"; the standard deduction is "approx". `BASE_YEAR = 2025`, and
every projection inflates from it — so an error in the base compounds across the
whole horizon.

The first threshold is `22000`, which is below the real 2025 MFJ figure, and the
set looks closer to 2024 than to its declared base year. **Verify against
published IRS tables rather than against this note** — the point is precisely
that there is nothing to check them with:

- no citation, no year stamp beyond a comment
- no test pins any value
- no mechanism to update them annually
- `ADDITIONAL_65_MFJ_PER_PERSON` and the IRMAA surcharges have the same problem

**Fix:** one dated, sourced table per year, and a spec that pins at least the
base-year values. For a tool whose only output is a tax number, this is not
optional.

---

## Part B — Decisions. These change what the tool says.

Each of these is a question about scope, not a bug. They are roughly in order of
how much they would change the answer the tool gives.

### B1. Is there a taxable account?

Prerequisite for A2, and the fork the whole model rests on. Options: pay
conversion tax from the Traditional balance (simple, pessimistic); add a third
taxable account with its own growth and drag (realistic, and lets "pay the tax
from outside funds" be modelled, which is the actual advice).

### B2. What is the objective?

The headline metric is **nominal, undiscounted lifetime tax**. That is the wrong
objective — minimising lifetime tax is not the goal, maximising after-tax wealth
is, and the two come apart exactly where conversions live. A conversion raises
tax now to lower it later, and an undiscounted sum treats 2055 dollars as 2026
dollars.

`ending_trad` and `ending_roth` are also reported as raw balances, and a
Traditional dollar is not worth a Roth dollar — which is the entire premise of
the tool.

**Needs:** an after-tax terminal wealth figure (Roth at par, Traditional haircut
by an assumed rate, taxable by basis), and a discount rate. This alone would
change which strategy the tool recommends.

### B3. Does anybody die?

The first death moves the survivor from Married Filing Jointly to Single —
roughly half the brackets and half the standard deduction, on most of the same
income. The "widow's penalty" is one of the strongest arguments for early
conversion. The model tracks `age_spouse` for thirty years and never lets
anybody die.

### B4. Is there an heir?

The SECURE Act ten-year rule on inherited IRAs, and the beneficiary's own
marginal rate, are the *main* reason to convert. Entirely absent.

### B5. Can tax law change?

Today's schedule, inflated, for thirty years. There is no way to say "rates rise
in 2034" — which is the assumption the whole convert-now case rests on.

### B6. What happens before 65?

roth's default user is 60. Five years of ACA marketplace coverage, where a
conversion can cost more in lost premium credits than in tax. Absent, and
unnamed in the README's omissions.

### B7. Does base income ever change?

Constant nominal for the whole horizon — `year 1: 80,000`, `year 30 (age 89):
80,000`. It neither grows with inflation nor stops at retirement. The spec asked
for a Base Income Growth input; it was never built. A retirement year is
probably the more important of the two.

### B8. Is the spouse real?

`age_spouse` is incremented and stored every year and used for one thing:
counting seniors for the standard deduction. No spouse RMD, no separate
balances. The abandoned rename (§0.2) was adding `ss_spouse_*`, so this was
being worked on.

### B9. Does IRMAA cost anything?

Computed every year, in no total, on no screen. Deciding it is a real cost means
adding it to lifetime outlay; deciding it is not means deleting the subsystem.
Leaving it computed and invisible is the one option that is certainly wrong.

### B10. Filing status, and state

MFJ is hardcoded in the constant names. `TaxTables.ny_standard_deduction` exists
and is called from nowhere — the spec asked for a State of Residence dropdown
with the NY retirement-income exclusion. Both are scope, not bugs.

### B11. One growth rate, forever

No sequence-of-returns risk, no volatility. Defensible for a directional tool,
worth naming as a limit on the page rather than only in the README.

---

## Suggested order

1. **Part 0** — one `require`, finish the rename, get five specs green.
2. **A1, A3, A4, A5, A6** — five defects, each with a spec, none needing a
   decision. These change the numbers the tool reports and should land together
   with a note that they do.
3. **A8** — dated, sourced, pinned tables.
4. **B1 then B2** — the taxable account and the objective. Everything else in
   Part B is optional; these two decide whether the tool's answer means
   anything.
5. The rest of Part B as scope allows.
