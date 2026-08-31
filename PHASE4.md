# Phase 4 — the rest of the vocabulary

**Result: all 47 words implemented, and the three pages drafted on paper
render.**

Those pages were written before any code existed, against no implementation.
Rendering them is the closest thing this project has to an acceptance test,
because nothing in them was written to suit what had been built.

Run it: `ruby bin/render_pages.rb` · `ruby test/phase4_test.rb`

```text
pages/portfolio.sp      57 sentences ->  6058 bytes of HTML
pages/content.sp        18 sentences ->  1437 bytes of HTML
pages/figures.sp        35 sentences ->  2826 bytes of HTML
```

## Two collisions with the host language

Both only surfaced when real pages ran, and neither was visible on paper.

### `when` is a Ruby keyword

It can be *defined* as a method but never *called* as one, so `when .drifted?`
was a syntax error in the generated Ruby. The language does not give up its
own word for this: the transform routes reserved words past Ruby's parser.

```
when .drifted?    →    send(:when, subject.drifted?)
```

The reserved list is in `Transform::RESERVED`, so `in`, `next`, `end`, `class`
and the rest are safe if the vocabulary ever wants them.

### A word's own arguments see the enclosing subject

`page pattern, .title` reads naturally and cannot work. Arguments are
evaluated before the word runs, so `.title` asks the *page*, not the pattern
the page is about to establish. The spelling that works is the binding:

```
page pattern, pattern.title
```

This is not a defect to fix — it follows from `.foo` meaning *the current
subject*, and the current subject at that moment genuinely is the page. It is
written down because it is the kind of thing that would otherwise be
rediscovered painfully.

## Three pages, corrected

Rendering them found three sentences that were wrong before the rules that
made them wrong existed:

- `form contribution` under `section contribution` — naming the subject twice,
  the "states the inferable" case from Phase 0.
- `section applied` — a heading, not a subject, so it is content now.
- `page pattern, .title` — the argument-ordering case above.

Each was the language correctly refusing a page, which is the point.

## `prose` is safe by construction

Markdown is rendered without a new dependency, in about forty lines, and it is
safe by *construction* rather than by filtering: the input is HTML-escaped
first, and only then are a fixed set of patterns turned into tags. No input
can produce a tag markdown does not define.

```
prose .body   with   <script>alert(1)</script>   →   &lt;script&gt;…
```

That is why the language has no escaping sigil and no "trust me" spelling.
Slim spends `=` versus `==` on this distinction; here the safe thing is the
only thing.

## `chart` — still the guess it was

Implemented enough to render: line, area, bar and pie, as inline SVG with no
axes, no legend and no scales. It is the one word with more irreducible
configuration than the grammar wants to carry, and ROADMAP Phase 8 exists to
redraft it against a real charting need or cut it. Nothing here changes that.

## What the pages exercise

Every word now has both a vocabulary entry and a sentence that runs. Worth
naming what the pages show working that no test would have caught:

- `card` infers its DOM id from the subject — `<article class="card"
  id="account-1">` — so no page writes `id .id`.
- `metric` derives its label, value and format from one word, across a grid.
- `choose`/`when`/`otherwise` picks a branch with no keyword anywhere.
- `figure` holds an `image` and captions it; `icon` accepts either a name
  (`icon warning`) or data (`icon .severity`).
- `time` emits machine-readable and human forms from one value.

## A bug the pages found

`pattern.title` returned the raw object rather than a subject, so reaching out
by name worked for a `Struct` and failed for a `Hash` — the same asymmetry
Phase 2 found in `fetch`/`respond_to?`, in a different place. Bindings are
wrapped now, so a struct, a hash and a plain object read alike.

## Honest limits

- **`link` still derives `/name`.** Real routing wants a helper; Phase 6.
- **`chart` has no axes or legend**, as above.
- **`icon` emits a sprite reference** (`<use href="#icon-warning">`), so it
  assumes the app ships a sprite sheet. That is a design-system question, and
  Phase 5 owns it.
- **Markdown is a subset**: paragraphs, headings, lists, blockquotes, bold,
  italic, code and links. No tables, no nested lists, no images. Enough for
  the prose a view holds, and the limit is deliberate.

## Done-conditions

| From ROADMAP-0.1.md | Status |
|---|---|
| Every word implemented, in the five groups | done — 47 of 47 |
| PORTFOLIO.md renders | done |
| CONTENT.md renders | done |
| FIGURES.md renders | done |
| `check_grammar.rb` green | done — 431 sentences, 48 words, 0 problems |

Suite: 71 tests, 236 assertions, 0 failures.
