# Phase 2 — the table slice

**Result: both done-conditions met, the second one only after the vocabulary
was corrected twice.**

Nine words added — `section`, `title`, `each`, `empty`, `table`, `column`,
`total`, `money`, `percent` (and `number`, `text`, which came free) — rendering
[pages/portfolio_table.sp](pages/portfolio_table.sp) against nested `Struct`s.

Run it: `ruby bin/show_portfolio.rb` · `ruby test/phase2_test.rb`

## The table writes no loop

Fourteen sentences produce a page with two accounts, three holdings, a
formatted table per account and a summed footer:

```
    each account
      title .name
      table holdings
        column symbol
        column shares
        column market_value, "Value"
        column gain
        column weight
        total market_value, "Account total"
```

`table` never says `each`. `column` does not render when it is read — it
*registers*, so the header row can be written before the first row is
touched. `total` sums over the collection. `title` chose `<h3>` because it
sits one section deep, and nothing said so.

The `empty` word works as designed: with no accounts it renders its message
and suppresses the whole table; with accounts it renders nothing.

## Two corrections the vocabulary needed

### A name is a subject; content is a label

The first render disproved draft 3's `section` entry — `section summary` asked
a portfolio for a `summary` it does not have. Counted across the three drafted
pages, **six of ten sections** were headings rather than subjects.

The first fix was to shift the subject *only when the subject has it*. dan
rejected it with a better question — *what if a word can take a subject but it
can also just take a label?* — and the answer is that the grammar already
distinguishes those, by argument kind:

```
section accounts          # a name — the subject shifts
section "Where you stand" # content — a heading, nothing shifts
```

The opportunistic version was worse than it looked. It made a page's meaning
depend on data no reader could see, and adding an `allocation` attribute to a
model later would have silently made `section allocation` start shifting the
subject — every `.foo` beneath it resolving somewhere new, in a page nobody
had edited. That is the failure Phase 1 taught us to refuse, wearing different
clothes.

So the rule is now fixed per word and stated in DESIGN.md: a word's name slot
either takes a subject or it does not, and when it does, the named thing must
be there. The six heading-sections are written as content, and read the same.

### `each` iterates the subject when the subject is the collection

`section accounts` shifts the subject to the collection — which is exactly
what lets `empty` know what is empty — so `each account` inside it must
iterate *that*, not go looking for `accounts` on an array. It looks for
`plural(name)` first, and falls back to the subject when the subject is
itself a collection.

## The second done-condition, and what it cost

> *Done looks like: no `as:` modifier is needed for the ordinary cases.*

**Not met by type inference, and it never could be.** A value's shape says it
is a `Numeric`. It cannot say whether it is money, a count, or a rate.
Written honestly, the first draft of the page needed `as:` on four of five
columns.

This is the same finding as labels in Phase 0, and it took the same remedy:
**`format_for(attribute)` on the app**, mirroring `label_for` exactly, with
the same three-level precedence.

| | `as:` written in the page |
|---|---|
| shape alone | **4 of 5 columns** |
| with `format_for` on the app | **0 of 5** |

A four-entry hash on `Holding` and the page says nothing about formatting
while producing `$356,120`, `−$3,180`, `42.0%` and `1,240`. Shape still earns
its keep unaided: any number is right-aligned without being asked, because
*that* much is derivable.

This is now a pattern rather than a special case, and worth stating as one:

> **Mechanical facts derivable from a value's shape are free. Facts that
> encode a human judgement about the domain belong to the app, and the
> language should ask rather than guess.**

Labels and formats are the two instances so far. [CONTRACT.md](CONTRACT.md)
carries both.

## A bug the tests found that the demo did not

`Subject#fetch` understood hash keys; `Subject#respond_to?` did not. So a
hash-backed subject behaved differently from a struct-backed one — and every
demo so far used `Struct`s, so nothing noticed. Both now go through one
`has?`.

Worth keeping: the demo pages and the tests fail in different ways, and the
tests found this precisely because they used the cheaper fixture.

## Honest limits

- **`total` renders in the first column.** With a summed column that is not
  adjacent, the label sits under whichever column comes first. It reads fine
  on this page and would not on a wide one.
- **Pluralising is two rules** — `y` to `ies`, otherwise `s`. `each person`
  would look for `persons`. `from:` is the escape, and English is not a
  problem this project should try to solve.
- **An unknown word carrying a bad argument reports the argument first**,
  because Ruby evaluates arguments before the call. Both messages are true;
  this one names the inner problem. Recorded as a test rather than hidden.

## Done-conditions

| From ROADMAP-0.1.md | Status |
|---|---|
| `each` inside `section` inside `page` | done |
| A `table` that writes no loop | done |
| The portfolio holdings table renders from real objects | done |
| Money right-aligned and negative-classed | done |
| Percent multiplied | done |
| No `as:` needed for the ordinary cases | done **via `format_for`**, not via type inference |

Suite: 43 tests, 128 assertions, 0 failures. 316 sentences, 46 words, 0
problems.
