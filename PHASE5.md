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

**A correction.** The first version of this claimed "zero hardcoded values
outside the theme block". That was measured on *colours only*, and dan's
question — are these tweaks reachable by the theme surface? — is what exposed
it. There were sixty-one literal values outside `:root`: the h1 size, the font
weights, the grid track, the input and chart widths, the code size, the list
indent, the stroke widths, the chart opacities.

The claim is now true, and enforced rather than asserted. Forty-two variables,
and `check_styles.rb` fails on any literal outside `:root` that is not a
structural constant — zero, one, a full width, a grid fraction:

```text
UNTHEMED    2.5rem appears 1x outside :root — a theme cannot reach it
```

`/tmp/spdemo/themed.html` is the proof: the same markup and the same rules,
with fourteen variables overridden, becomes a serif, square-cornered, warm
paper skin. Dark mode is the same mechanism — twelve variables under
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

## Then somebody looked at it

`pages/specimen.sp` puts all forty-seven words on one page, and `bin/demo.rb`
inlines the stylesheet so it opens standalone. Rendering it and reading it in
a browser found five defects that every checker had passed:

1. **The metrics grid overflowed the page.** `repeat(var(--columns), minmax(14rem, 1fr))`
   forced four tracks of at least 14rem, which is wider than the viewport and
   cannot shrink. `columns:` now sets the *track width* and `auto-fit` wraps
   when it will not fit, so the count is an aim rather than a demand.
2. **`icon` rendered nothing at all.** It emits `<use href="#icon-warning">`
   and the language shipped no sprite, so every icon was an empty box. The
   vocabulary names those variants, so the vocabulary ships them: `page` emits
   a sprite of exactly the symbols the page used, the way it emits the doctype.
3. **`.title` was dead CSS.** `title` was the one word emitting no class, and
   `check_styles.rb` could not see it — its orphan rule only asks whether a
   base *corresponds to* a word, not whether anything emits it. Fixed by making
   `title` conform, and `section` gained `section-title` for the same reason.
4. **`fact reviewed_on` printed `2026-08-30`** while `time` printed
   "30 August 2026". A date's shape says how to render it, so `present` now
   knows — the same rule that right-aligns numbers.
5. **Badges ran into each other** and into whatever followed them.

The first three are the interesting ones, because all three passed every
check. A checker can prove a class has a rule; it cannot prove the rule is any
good, that the sprite the rule styles exists, or that anything emits the class
at all.

**None of the five was reachable from the theme surface**, and that is the
right answer rather than a failing. Three were Ruby, not CSS at all. The other
two needed rules that did not exist. A theme changes the *values* of rules;
it cannot create a rule, and it cannot change behaviour. Knowing which
category a complaint falls into is the useful thing, and the boundary is now
checkable in one direction: nothing a theme *should* reach is left outside
`:root`.

## Honest limits

- **An item's layout is read from what it holds.** `.item:has(> .icon)` is a
  row; anything else is a stack. Both shapes are the same HTML — an inline
  thing followed by a `<p>` — and the block forces a break that is right for
  a link with its description and wrong for an icon with its label. The page
  says `item` in both cases, and which layout that means follows from the
  content, which is where it belongs.
- **Variants are open-ended.** An app may name `note anything`, and the
  checker only requires the *base* to be styled. That is deliberate — the
  alternative is a closed list of variants, which the language does not have.
- **The default sprite is seven symbols** — the status variants the vocabulary
  names. An app wanting others still ships its own.

## Done-conditions

| From ROADMAP-0.1.md | Status |
|---|---|
| Decide the relationship to slim-pickins' CSS | **decided: own it** (dan, 2026-08-30) |
| The class-naming convention written into VOCABULARY's `renders` slots | done — stated once at the head of the stylesheet, which is where it belongs |

Suite: 71 tests, 236 assertions, 0 failures. 524 sentences, 0 problems.
68 classes emitted, 58 rules, 0 problems.
