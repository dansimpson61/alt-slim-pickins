# Phase 3 — reuse: layout and partials

**Result: reuse cost the language exactly one word.** The third High risk is
retired, apart from the judgement item that is yours.

Run it: `ruby bin/show_portfolio.rb` · `ruby test/phase3_test.rb`

## Layout

The chrome every page shares, written once, with `contents` marking the hole:

```
stylesheet "/css/portfolio.css"
nav
  link home, "Overview"
  link accounts
  link projections
contents
footer "Approximate directional estimates. Not tax advice."
```

**No page mentions the layout.** `page` infers it, which is the same rule that
disposed of `flash`: every page would have carried an identical line, and that
is the signature of an inference rather than a word.

Measured across the three drafted pages: **18 chrome lines removed, one
7-line layout added.**

A layout that never says `contents` is an error, and so is `contents` outside
a layout. One hole, exactly one, and it must be there.

### The problem a layout exposed

A layout renders *inside* the body, but `stylesheet` belongs in the `<head>`.
Rather than restrict where a layout may say things, `page` now assembles the
document after its children have run, and head-bound words write to the head
wherever they are said.

> **A word says where it belongs, not where it is written.**

That is worth more than the layout it unblocked: `meta`, `stylesheet` and
`script` all get it for free, from any depth.

## Partials are words an app defines

No new construct. `pages/partials/account_card.sp` defines the word
`account_card`, written in the language, taking the current subject:

```
title .name
table holdings
  column symbol
  column shares
  column market_value, "Value"
  column gain
  column weight
  total market_value, "Account total"
```

Used from a loop in one page and directly in another:

```
    each account
      account_card
```

```
page account, "Account detail"
  account_card
```

Both render the same card. `title` still chose `<h3>` in the loop and `<h2>`
on the detail page, because depth is a property of where a word *runs*, not
where it is written — which is what makes a partial reusable at all.

An app word follows the same rule as `section`: no name keeps the current
subject, a name shifts it and must be there.

**A call site cannot tell the two vocabularies apart**, which was the
done-condition. App words become real singleton methods, so `respond_to?` is
true for `account_card` exactly as for `section`, and an unknown word still
fails with its own name.

`check_grammar.rb` now knows this too: a file in `pages/partials/` defines a
word, so using it is not a drift error, and it is not expected to appear in
VOCABULARY.md — slim-pickins owns the vocabulary of presentation, an app owns
the vocabulary of its own components.

## Shadowing is an error

```
`table` is already a slim-pickins word — an app cannot redefine it
```

Refused at load, not at use. Two meanings for one word is the alias problem
wearing a new hat.

## What it cost the language

One word: `contents`. Nothing else — no new syntax, no new argument kind, no
new rule of government. That is the strongest evidence so far for the founding
claim that extending the language adds vocabulary and never syntax, because
reuse is the feature most likely to have needed an exception.

## For dan — the judgement item

> *Is a layout plus a partial in this language better to read and write than
> `layout.slim` plus a `render` call?*

The comparison, as fairly as I can put it:

|  | Slim + Sinatra | this language |
|---|---|---|
| Layout | `views/layout.slim`, 34 lines | `pages/layout.sp`, 7 lines |
| The hole | `== yield` | `contents` |
| Page opts in | automatic | automatic |
| Partial defined | `views/_card.slim` | `pages/partials/account_card.sp` |
| Partial invoked | `== slim :_card, locals: { account: a }` | `account_card` |
| Data passed | named explicitly, every call | the current subject, implicitly |

**Where this is better:** the call site. `account_card` against
`== slim :_card, locals: { account: account }` is the whole difference between
a word and a mechanism, and it is the difference this language exists to make.
Partials also cannot drift from their data, because they read the subject
rather than a hash someone assembled.

**Where it is worse, or at least not yet proven:** passing anything *other*
than the subject. Slim's `locals:` takes arbitrary extra values; here a
partial gets the subject and whatever the page can already reach. Nothing in
these three pages needed more, so I have not invented a way to do it — but
that is absence of evidence, not evidence of absence.

**My read:** better at the call site, equal for layouts, and untested for the
one thing Slim does that we do not. Yours to judge.

## Honest limits

- **`link` derives `/name` as its path.** Real routing is the app's business
  and will want a helper or a `to:`. It is enough for a layout's nav and no
  more.
- **A partial cannot take extra arguments** beyond a subject, as above.
- **The layout is global.** One layout per library; nothing supports a second
  for a printable view, and nothing has needed one.

## Done-conditions

| From ROADMAP.md | Status |
|---|---|
| Pages lose `stylesheet`, `nav`, `footer` to a layout and render identically | done — 18 lines to 7 |
| Repeated shape collapses into one app-defined word used in two pages | done — `account_card` |
| A reader cannot tell built-in from app-defined at the call site | done |
| Shadowing raises, naming both | done |
| Judge it against Slim | **awaits dan** |

Suite: 55 tests, 167 assertions, 0 failures. 321 sentences, 48 words, 0
problems.
