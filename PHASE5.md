# Phase 5 — the design system

**Result: 280 lines in one file, against 967 across sixteen, with zero
hardcoded values outside the theme block and a checker that proves the
stylesheet and the runtime cannot drift apart.**

Run it: `ruby check_styles.rb`

## The decision, and the evidence for it

dan's three objections to `slim-pickins.css`, measured before answering:

| | |
|---|---|
| Total CSS the dashboard depends on | 967 lines across 16 files |
| Custom properties | 21 |
| Hardcoded colours leaking past them | 15 |
| Navigation systems in the same file | 2 — `sp-nav` *and* `sp-navigation` |
| Classes used in views that **no stylesheet defines** | **12** |

The last row is the finding. `sp-inline-code`, `sp-list--bulleted`,
`sp-grid--3`, `sp-text-lg`, `sp-rule`, `sp-danger` and six more are written in
dashboard views and styled nowhere. They render as nothing today, and nothing
could have told anyone, because no list said what ought to exist.

So: own it rather than inherit it. Not because that file is bad work, but
because it is built for a language where humans write classes, and ours is not.

## The naming rule is the grammar

No prefix. A prefix avoids collisions with classes a human might write, and
**in this language no human writes a class** — every one is emitted by a word.

Four shapes, all derived:

| Shape | Example |
|---|---|
| `.word` | `.card` |
| `.word--variant` | `.note--warning` |
| `.word-part` | `.metric-label` |
| `.word-part--n` | `.chart-slice--0` |

A reader who knows the language already knows the stylesheet. `note quiet`
emits `.note.note--quiet`; nothing else was ever possible.

Two of our own emissions broke the rule and were fixed: `numeric` became
`column--numeric`, and `slice` became `chart-slice`. Class names are now built
in exactly one place — `Builder#token` — so the rule cannot be broken by hand.
That also normalised several words that had been emitting *no* base class at
all: a `section` with no name, an `item` with no variant, a `footer`.

## No utility layer

`text-muted`, `text-sm`, `text-lg`, `text-center` exist so a template author
can reach for styling. In this language they cannot: styling is what a word
carries. `note quiet` replaces `p.sp-text-muted.sp-text-sm`.

That deletes about fifteen classes and, more usefully, the entire category
that produced the twelve undefined ones. Layout primitives go the same way —
`stack`, `cluster`, `row`, `inset`, `grow` are layout verbs written in markup,
and our words already say layout: `grid`, `list`, `actions`, `aside`.

## Themeable by construction

Every value below the theme block is a `var()` or a structural constant.
Measured: **zero hardcoded colours outside `:root`**, against fifteen. A theme
is one `:root`, and because classes derive from words it cannot silently miss
one. Dark mode is the same twelve variables under
`prefers-color-scheme: dark`.

## `check_styles.rb`

`check_grammar.rb`'s trick pointed at CSS:

- every class the code **can** emit has a rule
- every rule corresponds to a word
- every class name obeys the four shapes

**A checker that has never failed has never been verified**, so it was tested
against both directions of drift. That test found a hole worth recording.

The first version checked only classes seen while *rendering* the repo's
pages. Deleting the rule for `.empty` was not caught, because `empty` renders
only when a collection is empty and no page in the repo has one. A
render-only check is blind to exactly the classes that go unstyled — which is
precisely how twelve of them survived in the file this replaces.

So it now reads what the code **can** emit, by grepping for `token(:word)` and
class literals in `lib/`, rather than only what it did emit. Both directions
of drift are caught:

```text
UNSTYLED    "empty" can be emitted but no rule defines it
ORPHAN      "sidebar-widget" is defined but no word can emit it
```

## What changed elsewhere

- The layout now says `stylesheet "/assets/slim-pickins.css"`, so every page
  gets it and no page mentions it.
- Fixtures moved to `test/fixtures.rb`, shared by `bin/render_pages.rb` and
  `check_styles.rb` — the checker has to render every page, so there is one
  definition rather than two that drift.
- Seven test expectations updated. All seven were the naming rule now applying
  without exception: `money--negative` rather than `money negative`,
  `column--numeric` rather than `numeric`, `<li class="item">`.

## Honest limits

- **The stylesheet is untested visually.** It renders in a browser; nobody has
  looked at it. `check_styles.rb` proves every class has a rule, not that the
  rule is any good.
- **Variants are open-ended.** An app may name `note anything`, and the
  checker only requires the *base* to be styled. That is deliberate — the
  alternative is a closed list of variants, which the language does not have.
- **`icon` still assumes a sprite sheet** the app must ship. Ours styles the
  `<svg>`, not the symbols.

## Done-conditions

| From ROADMAP.md | Status |
|---|---|
| Decide the relationship to slim-pickins' CSS | **decided: own it** (dan, 2026-08-30) |
| The class-naming convention written into VOCABULARY's `renders` slots | done — stated once at the head of the stylesheet, which is where it belongs |

Suite: 71 tests, 236 assertions, 0 failures. 431 sentences, 0 problems.
58 classes emitted, 57 rules, 0 problems.
