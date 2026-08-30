# The app contract

What an object must do to be renderable by this language, and what happens
when it does not.

Everything marked **verified** is exercised by `test/contract_test.rb`.
Everything marked **projected** is a claim the code does not yet make good on,
and is named as such rather than implied.

## The required half: answer your own attributes

**verified**

> A subject answers the attributes it is asked for, by ordinary method call.

That is the whole requirement. There is no base class, no module to include,
no schema and no declaration.

```ruby
Inputs = Struct.new(:base_income, :growth_rate, keyword_init: true)
```

`Engine::Inputs` in `roth` is exactly that, and Phase 0 rendered it with no
changes at all. A `Hash` works too, with symbol or string keys, because a hash
answers `[]`.

**Types are never declared.** The input type is read from the *value's class*
at render time — `60` is a number, `"fixed"` is text, a `Date` is a date. This
is why the contract is nearly free: an app that has values already satisfies
it.

## The optional half: answer for your own labels

**verified**

> A subject *may* respond to `label_for(attribute)` and return a label, or
> `nil` to fall back.

Phase 0 measured what humanising can and cannot do. The input name, the value
and the type were derived correctly every time. The label was right about three
times in ten, because `trad_balance` is not "Traditional Balance" and
`ss_primary_start_year` is not "SS Start (yrs from now)". Acronyms,
abbreviations and domain phrasing are not recoverable from an attribute name —
the information is not in the input.

So labels are the one place the app has to be allowed to speak:

```ruby
Inputs = Struct.new(:ss_primary_amount, keyword_init: true) do
  LABELS = { ss_primary_amount: 'SS annual amount' }.freeze
  def label_for(attribute) = LABELS[attribute]
end
```

### Precedence — each level owned by whoever knows most

1. **The page**, if it says the label — it knows this one instance.
2. **The app**, via `label_for` — it knows its domain.
3. **The language**, humanising the name — it knows only English.

Each level overrides the one below it, which keeps
[VOCABULARY.md](VOCABULARY.md) rule 3 intact: every inference is overridable
by saying the thing.

## The same shape again: answer for your own formats

**verified**

> A subject *may* respond to `format_for(attribute)` and return `:money`,
> `:percent`, `:number` or `nil` to fall back.

Phase 2 found the identical problem one level along. A value's shape says it
is a `Numeric`; it cannot say whether it is money, a count or a rate. The
portfolio table needed `as:` on four of five columns without this, and none
with it.

```ruby
Holding = Struct.new(:shares, :market_value, :gain, :weight, keyword_init: true) do
  FORMATS = { shares: :number, market_value: :money, gain: :money, weight: :percent }.freeze
  def format_for(attribute) = FORMATS[attribute]
end
```

Same three levels, same owners: the page's `as:`, then the app's
`format_for`, then the value's shape.

### The rule both of these are instances of

> **Mechanical facts derivable from a value's shape are free. Facts that
> encode a human judgement about the domain belong to the app, and the
> language should ask rather than guess.**

A number is right-aligned unasked, because alignment follows from being a
number. Whether it is money does not follow from anything the value knows.

## What happens when the contract is not satisfied

**verified.** Errors speak the language, never the implementation, and each
names the thing a reader should go and look at.

| Situation | What is raised |
|---|---|
| The subject has no such attribute | `this account has no name` |
| The subject is empty | `nothing to ask for name — the subject is empty` |
| A word names a subject that is absent | `this page has no account` |

The third is the one worth explaining. `page account` with no `account`
available fails **on the line that named it**. An earlier draft skipped
quietly and left the chain alone, so the failure surfaced three lines later as
"this page has no name" — true, useless, and pointing at the wrong line. A
word that names *no* subject leaves the chain alone; a word that names one
that is not there is an error.

Nothing ever resolves to blank. A typo fails loudly.

## The page is the outermost subject

**verified**

Locals and helpers are the page's attributes — that is the whole of VBA's
implied `Application`, and it is why resolution needs one rule instead of
three. A helper is reached exactly like a local, and `.signed_in?` at the top
level asks the page.

```ruby
SlimPickins.render(source, locals: { scenario: inputs }, helpers: app)
```

## Collections

**verified** — Phase 2.

> A collection answers `each`. `each holding` finds `holdings` on the subject
> by pluralising; when the subject *is* the collection it iterates that; and
> `from:` overrides both.

Any `Enumerable` satisfies this. Pluralising is deliberately two rules — `y`
to `ies`, otherwise `s` — and `from:` is the escape rather than a dictionary
of English irregulars.

## The cost, for judging

`dan` — this is the decision Phase 1 exists to put in front of you.

**Required of an app:** nothing it does not already do. Plain `Struct`,
`Hash` and ordinary PORO all worked untouched.

**Optional, and only if you want good labels:** one method, `label_for`.

dan's judgement (2026-08-30): **not onerous** — *"even that hash is just the
price a dev has to pay for lazy field names."* Read `label_for` as a
diagnostic rather than a workaround: an app that needs it is telling you its
attribute names do not read as English.

**The honest catch:** without `label_for`, a form over attributes with
abbreviated or acronymic names needs its labels written in the page — and
written again on every page that shows the same field. That is the DRY cost,
and it is exactly what `label_for` exists to remove.

Measured on the roth form, which has fourteen labelled controls:

| | labels written in the page |
|---|---|
| humanising alone | **11 of 14** |
| with `label_for` on the app | **0 of 14** |

`bin/diff_roth.rb` shows it: a twelve-line `LABELS` hash on the app, and
[pages/roth_form.sp](pages/roth_form.sp) has no field labels at all while
rendering the same words as the hand-written page.

The three humanising got right unaided — `roth_balance`, `base_income`,
`growth_rate` — are the ones whose attribute names were already English. That
is the rule, and it is why the language does not promise more.
