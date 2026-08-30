# The retirement portfolio page — the vocabulary's first real test

A whole page, written using only words defined in [VOCABULARY.md](VOCABULARY.md).
The point is not that it reads well. The point is to find out where the
vocabulary stops, because in a language whose only construct is words, a
missing word is a wall rather than an inconvenience.

Three walls were hit. They are recorded at the bottom, along with what was
done about each.

## The page

```
page portfolio, "Your retirement"
  meta description, "Balances, allocation and projections across your accounts."
  stylesheet "/css/portfolio.css"

  nav
    link home, "Overview"
    link accounts
    link projections
    link settings

  section summary, "Where you stand"
    time .as_of
    grid metrics, columns: 4
      metric total_value, "Total value"
      metric ytd_return, as: percent
      metric annual_income, "Projected income"
      metric years_to_rmd, "Years to RMD"

  section allocation
    chart pie, .allocation, label: "By asset class"

    choose
      when .drifted?
        note warning, "Your allocation has drifted more than five percent."
      otherwise
        note quiet, "Allocation is on target."

    table targets
      column asset_class, "Asset class"
      column target, as: percent
      column actual, as: percent
      column drift, as: percent

  section accounts, "Your accounts"
    empty "No accounts linked yet."

    each account
      card
        title .name

        grid metrics, columns: 3
          metric balance
          metric contribution_room, "Room this year"
          metric tax_treatment, "Tax treatment"

        table holdings
          column symbol
          column shares, as: number
          column market_value, "Value"
          column gain, as: money
          column weight, as: percent
          total market_value, "Account total"

        actions
          link show, "Details"
          link rebalance

  section projections
    chart line, .balances, over: .years

    disclosure "Show advanced assumptions"
      field growth_rate, step: 0.01
      field inflation_rate, step: 0.01
      field horizon_years

    note "Coarse assumptions. Directional estimates only. Not tax advice."

  section contribution, "Make a contribution"
    form contribution, to: contribute, method: post
      group amounts
        field amount
        select account_id, "Account"
      group timing
        field frequency
        check auto_invest, "Invest automatically"
      actions
        button primary, "Contribute"
        link cancel, "Never mind"

  footer "This tool provides approximate directional estimates. It omits many tax nuances."
  script "/js/portfolio.js"
```

Sixty-six sentences, against ninety-one lines for `roth/views/controls.slim`
— which is a strictly smaller page, with no holdings table, no allocation
table, no per-account metrics and no nested collection.

That is a real but unspectacular ratio, and it is worth being plain about
why: this language does not win by being terser line-for-line. It wins where
the old page pays in *kind* rather than in lines — a disclosure that costs
four sentences instead of a button, an id, a data attribute, a CSS class and
a handler, or a `field` that names only what cannot be inferred.

## What the page proves

**Nested collections work without ceremony.** `section accounts` → `each
account` → `table holdings` is three levels of collection, and the loop is
written once. The `table` never says `each`, because `table` supplies its own
rows — the same cut as `column` not saying `each`.

**Inference does the heavy lifting where the old page did not.** The
disclosure is four lines against a button, an id, a data attribute, a CSS
class and a JavaScript handler. The nine `field` lines carry no `label`, no
`name`, no `value` and no `type` — `field growth_rate, step: 0.01` says only
the thing that is not inferable.

**`empty` reads as designed.** It sits inside `section accounts` and needs no
condition, because the section already knows what it is about.

## The three walls

### 1. A name could not reach the subject — the real one

`table holdings` inside `each account` was supposed to mean *this account's*
holdings. Under the resolution rule as written — `foo` is a local, else a
helper — it meant a page-level `holdings`, which is wrong, and silently wrong.

Every collection nested inside another hits this. It is not an edge case; it
is the ordinary shape of a page.

**Fixed by amending the rule** in DESIGN.md. A name now resolves against the
subject first:

> `foo` → the **subject's** `foo`, else a **local**, else a **helper**.

This costs nothing at the top level, where there is no subject, and it makes
`each holding` and `table holdings` mean the obvious thing inside `each
account`. It also explains something the draft was already doing on instinct:
`metric balance` reading the account's balance was only ever going to work
under this rule.

### 2. No word for navigation

Predicted as under-tested, and it bit immediately — every real page has one.
**Added `nav`** to the vocabulary. It governs `link` children and infers which
one is current, which is the part templates always get wrong by hand.

### 3. Flash messages had nowhere to live

The contribution form posts, so something has to say "contributed". Adding a
`flash` word was the obvious move and the wrong one: a flash is not something
a page *says*, it is something a page *has*.

**Resolved without a word** — `page` now infers it, and renders any pending
message in a conventional place. This follows the rule already in DESIGN.md:
a line which states the inferable should not exist. Every page would have
carried an identical `flash` line, which is the signature of an inference
rather than a word.

## Still standing

- **The `?` case.** This page never hit it — `when .drifted?` has a dot,
  because the condition was about the subject. It survives as a hole in the
  morphology, but a page this size failing to reach it is weak evidence that
  it is rare.
- **`chart` remains a guess.** `chart pie, .allocation, label: "…"` and `chart
  line, .balances, over: .years` are the two shapes, and they look plausible.
  Nothing here tested axis labels, legends, scales, or a second series, so the
  entry is no better evidenced than it was.
- **Still under-tested:** prose and media. `text`, `image` and `icon` do not
  appear on this page at all, and `list` appears nowhere in it either. A
  content-heavy page would be the honest next test, not another dashboard.
