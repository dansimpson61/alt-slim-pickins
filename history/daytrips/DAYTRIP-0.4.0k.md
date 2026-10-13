# Daytrip 0.4.0k — The Showcase Speaks the Language

Tier 6 item 19: `studio/inspector.rb` rewritten in the language it inspects. 436 lines of Ruby writing HTML became 135 lines of data plus 109 lines of `.sp`, `.spiff` and theme. No new vocabulary was needed, no JavaScript survived, and Tier 4's last item — pointing `check_styles` at `studio/` — went from 24 refusals to green. Along the way the gate 0.4.0j retargeted caught a defensive selector inside the Spiff compiler, which is the defect class 0.4.0g set out to remove.

---

## The brief

Dan said *proceed*. `HANDOFF.md` warned that this item "will surface vocabulary
gaps needing dan's rulings — expect to stop and ask rather than invent words."
Two rulings were asked for and both were answered; a third question answered
itself by measurement.

Verified before touching anything: twelve legs green, 575 runs / 0 failures.

---

## Part 1 — The audit's description was wrong in every particular

0.4.0h described the target as "a 255-line method that is mostly one HTML
heredoc: 39 raw tags, 37 hardcoded hex colours, and `100vh` twice." Measured:

```
page_for                       254 lines
  of which <style> block       200 lines   (79%)
distinct raw tags               23          (not 39)
hex values                      37
  inside var(--role, #x)        26          (71% are theme-role fallbacks)
  bare                          11          (five tier palettes)
100vh                            2          (correct)
```

**It was 79% CSS, not HTML.** And the colours were not hardcoded values but
*fallbacks* on sixteen theme roles the surface already used correctly — present
because this document linked no stylesheet. Ten lines below it in the same file,
`error_page_for` linked `/assets/slim-pickins.css` and needed no fallbacks at
all. One author, one file, two documents: one linked the theme and one carried
twenty-six copies of it instead.

That is the third round running where measuring a list item's own sentence
changed the work. It is now a habit and it is written into `HANDOFF.md`.

## Part 2 — No new vocabulary, which is the finding

The surface wrote 23 class literals in Ruby. Every one of them had a word
already:

| the literal | the word |
|---|---|
| `node-chip`, `convention-badge` | `badge` |
| `tree-list`, `tree-item` | `list`, `item` |
| `detail-card`, `convention-item` | `card` |
| `detail-title`, `table-title` | `title` |
| `override-code` | `snippet` |
| `empty-note` | `empty` |
| `refusal` | `flash` |
| `node-type`, `node-variant`, `convention-name` | `span` with a variant |

The two that had no word — `inspector` and `inspector__pane` — are a *layout*,
which is Spiff's business and is now `studio/views/inspect.spiff`.

Three mechanisms had to be proved rather than assumed, and each was:

- **Recursion.** A tree partial can call itself, but it must be rooted at `list`
  rather than `item`, because `item` has to be lexically inside a `list` and a
  recursive partial cannot promise its caller one.
- **The DOM id.** `:target` needs a card with a known id, and no contract
  declares `id:`. It did not need to: the **`card_id` convention already exists**
  — "the DOM id, as `word-id`", when `card` is used over a subject that has an
  `id`. `card node` emits `id="node-n_0"` unasked.
- **The stylesheet link.** The surface is delivered by `srcdoc`, and an absolute
  `/assets/...` link resolves against the parent. `error_page_for` had been
  proving that all along.

**Selection is `:target`, and dan ruled it CSS-only.** The mechanism changed
during the build and that is recorded rather than substituted quietly: the
approved option was `choice`/`option`, which renders radios nested inside the
tree's `<li>`s — and no CSS sibling combinator reaches from there to a card in
the other pane, so it would need `:has()` or one generated rule per node id,
which means an inline `<style>` again. `:target` needs neither. Three static
rules in the theme replace a `selectNode` function and a `DOMContentLoaded`
listener.

**The colour went where colour belongs.** The four tier palettes became four
`:root` roles and four `badge` variants, matching how the theme's badge variants
already work — colour only, no backgrounds, which is a deliberate simplification
and a visible change. The four grades are exhaustive, so there is no
`otherwise` branch: it would have been a dead guard whose badge variant was a
rule nothing could style, and `check_styles` would have refused it. It did
refuse the version that had one.

## Part 3 — What the gates refused, which was most of the work

The round's own gates did the reviewing, and each refusal was right.

- **`check_styles` refused seven variants** nothing could style, including
  `box--roots` and `box--details`. Those came from `box roots` as a way to shift
  the subject — but **`box`'s name slot is a variant**, so `box roots` says a
  variant named `roots`, and the gate was right. Replaced with `each node, from:
  .roots`, which says what is passed and is shorter.
- **`check_grammar` refused four UNDEFINED words**, because `studio/views` was
  not in its app-word directory list — immediately above a comment claiming the
  checker "asks the registry rather than listing directories, so a UI added
  tomorrow is checked the moment it exists". It lists directories for everything
  but UIs, and a new directory proved it one line below the claim.
- **`check_spiff_scope` refused the new Spiff**, twice. First because
  `studio/views/inspect.sp` was not in the proved corpus — a Spiff whose pages
  nobody renders is refused rather than passed, which is the rule 0.4.0j wrote.
  Then for `.tab-panel`, which is Part 4.
- **`check_vitals` refused six stale claims** as the counts moved (app words 24 →
  28, style rules 104 → 113, pages 32 → 34), and in doing so caught a defect in
  the census: `verified_pages_count` scrapes the gate's source for `pages/` and
  `examples/` and undercounted by two the day a page arrived under `studio/`. It
  cannot require the gate — that would close a circle through the studio's own
  vitals — so the scrape stays and a test now holds it to what the gate reports.

## Part 4 — The gate found a defensive selector in the compiler

`check_spiff_scope` refused `.tab-panel`: the compiler emits a
`.zone .tab-panel` rule inside every zone that says `scroll internal`, and the
Inspect panes have no tabs, so the selector matched nothing.

This was not a mistake in the Spiff. `docs/SPIFF.md` documented the doubling
deliberately — "`internal` — the only token today, and the honest one: the zone
becomes a scroll container **and its tab panels get a capped height of their
own**." One token, two jobs, and no way to ask for the first alone.

**That is the defect 0.4.0g set out to remove, still in the compiler.** That
round cut `workbench.css` from 459 lines and 99 `:has(` to 162 and zero by
replacing a seven-way guess with one real class, and wrote down that "a compiled
selector that matches nothing in the real DOM is a correctness defect however
short it is." The guess that survived was the compiler's own.

Dan's ruling: split the token. `scroll own` scrolls the zone and says nothing
about tabs; `scroll internal` keeps both behaviours, so `workbench.spiff` is
untouched — **verified byte-identical, 184 lines before and after**. And since
the method was open, `scroll` now checks its token, as `air` and `treatment`
check theirs: `scroll internl` used to compile to silence and now raises.

**The gate 0.4.0j retargeted found this on the first new Spiff it saw.** That
round could claim only that the retarget would catch things; this one is the
catch.

---

## What landed

```
studio/inspector.rb   436 ->  135 lines   (data only; no HTML, no CSS, no JS)
studio/views/         new ->  109 lines   (inspect.sp, refusal.sp, 4 partials, inspect.spiff)
assets/slim-pickins.css  +9 rules         (4 grade roles, 4 badge variants, 4 spans, 3 :target)
check_styles.rb       now reads studio/   (24 refusals -> 0: Tier 4's last item, done)
```

- **The Inspect surface is a page in the language it inspects**, its layout is a
  Spiff, its colour is the theme's, and it has no JavaScript.
- **`scroll own`** in the compiler, the docs and the lexicon gate.
- **`examples/doc_reader` and the Inspect surface joined the proved corpus** —
  34 pages now.
- **`test/studio_inspector_test.rb` rewritten** (11 tests) around what the
  surface must do plus the three things the rewrite is only correct if they
  hold: every tree link points at a card that exists, nothing is styled inline,
  and there is no script.
- Two tests stopped pinning numbers that move — the census report's page count
  and the scope gate's spiff count. A number pinned twice is a number with one
  stale copy.

## Deliberately not done

- **The registry's global last-compile-wins order dependence** is still named and
  not fixed, from 0.4.0j.
- **Item 18, `Data.define` for the semantic node**, is next and is now smaller:
  this round deleted three of its twenty read sites, which is why 0.4.0h
  resequenced it behind this one.
- **`word_count`/`words_count`** are still two names for one number.

## Verification

- **Twelve legs green**, 4.52 s end to end. Scope now reports *3 spiffs, 15
  compiled classes held to the HTML their pages render*; Styles reports 113
  rules over `lib/` **and** `studio/`.
- **Suite: 586 runs, 6,466 assertions, 0 failures, 0 errors, 0 skips**, and each
  example suite green on its own.
- **`workbench.spiff` compiles byte-identically** before and after the compiler
  change, which is what makes "`scroll internal` is untouched" a measurement
  rather than a hope.
- **`check_styles` widened to `studio/` was run before and after** the rewrite:
  24 problems, then 0. That number is the item's whole justification and it was
  measured at both ends.
- Every number in this document was measured this round: the 79%, the 26
  fallbacks, the 23 tags, the 436 → 135, the 184 unchanged lines.
