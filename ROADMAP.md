# alt-slim-pickins — roadmap v4

**Retire the risk we have no evidence for, before building the parts we do.**

The grammar is settled: one sentence, one resolution rule, no open questions
([DESIGN.md](DESIGN.md) v0.3). The vocabulary is forty-six words tested
against three real pages from this workspace ([VOCABULARY.md](VOCABULARY.md)
draft 3), and its wall counts across those pages went 3, 6, 1 — converging
rather than growing.

All of that is on paper, and paper has given nearly everything it can.

What remains unproven is not the grammar and not the transform. It is
**inference**. Forty-four of the forty-six words infer something, and thirteen
infer from the app's own domain model — deriving a label, a value, a type or
an attribute from an object. `field base_income` producing a label, an input
name, a current value *and* an input type from one word is either the whole
point of this language or a fantasy, and no amount of writing pages can
settle which.

So the build does not start with the transform. The transform is the part we
are most confident about, it is a hundred and fifty lines, and it touches none
of the risk. Starting there would feel like progress while leaving every real
question open.

## The risk register

This is what the phase order is for. Highest risk first.

| Unknown | Risk | Retired by |
|---|---|---|
| Inference works at all | **High** | Phase 0 |
| What an app must promise to be renderable | **High** | Phase 0 → named in Phase 1 |
| **Reuse is at least as good as Slim's** | **High** | Phase 3 |
| `chart` is right | **High**, narrow | Phase 8, deliberately last |
| The design system the words assume | Medium | Phase 5 |
| Runtime emits correct HTML | Low | Phases 0, 2, 4 |
| Transform is feasible | Low | Phase 0 |
| Grammar parses unambiguously | Low | already evidenced — 273 checked sentences |

The first two High rows are both retired by one small slice. That is the
argument for the phase order.

The third is dan's (2026-08-30), and it is a risk the first draft of this file
missed:

> A gift from Ruby and OOP that I treasure is the value derived from small
> reusable abstractions that empower us to write very clean, DRY code. DRY is
> its own reward, a parent and a child of joy.

Sinatra and Slim already have layouts and partials. A language that cannot
match them is a **regression**, however good its grammar is — and unlike the
other risks, this one would not show up as a wall. It would show up as pages
that work and are tedious, which is the failure mode hardest to notice from
inside.

## How this stays accountable

- **This file is the single source of truth.** `PROJECT.md` `next_step`
  always points at the current phase. Commit after each item.
- **Every item has a "done looks like".** If you cannot verify it, it is not
  done.
- **`check_grammar.rb` must stay green** across every document, and every new
  word must arrive with a sentence.
- **Verification is by diff against a real page**, not by tests that restate
  the implementation. `roth/views/controls.slim` and
  `dashboard/views/pattern.slim` are the fixtures, because they already exist
  and were written by hand without this language.
- **Resume:** `curl http://127.0.0.1:4000/brief/alt-slim-pickins`.

Legend: `dan` (a decision only you can make) · `agent` (me) · `conv` (a
convention followed going forward).

---

## Phase 0 — The vertical slice  ✅ complete (2026-08-30)

Transform, runtime and inference together, about ten words deep, rendering one
real page. This phase exists to answer one question: **does inference work?**

The slice is the roth form, because `field` is the heaviest inference in the
vocabulary — four derivations from one word — and because
`roth/views/controls.slim` already exists to diff against.

Words in scope: `page`, `form`, `group`, `field`, `check`, `select`, `option`,
`button`, `actions`, `disclosure`.

- **The transform** `agent` — indentation to nested blocks, `.foo` to the
  subject, every line a Ruby method call.
  *Done looks like:* the ten-word subset of the roth page parses into a Ruby
  call tree, and a malformed line names the offending word and line number in
  the language's own terms.
- **The subject chain** `agent` — the page as the outermost subject, per
  DESIGN.md. Unknown attributes raise rather than resolving to nothing.
  *Done looks like:* `.foo` resolves against the innermost subject at three
  levels of nesting; a typo raises naming the attribute and the subject.
- **The runtime for ten words** `agent` — each word a real defined method, no
  `method_missing`.
  *Done looks like:* the page renders HTML.
- **Inference, for real** `agent` — `field base_income` derives its label, its
  input name, its current value and its input type from the subject.
  *Done looks like:* the rendered form is diffed against
  `roth/views/controls.slim`'s output and the differences are all deliberate,
  each one named.

**Exit criterion: met.** `field` delivers three of its four claimed
derivations reliably — input name, value and type — and the fourth, the
label, only when the attribute name already reads as English. VOCABULARY.md's
entry is corrected to say so. Results in [PHASE0.md](PHASE0.md).

The contract turned out to be close to free: `Engine::Inputs` is a bare
`Struct` with `keyword_init: true` and needed no changes, because the input
type is inferred from the *value's class* rather than from a schema.

## Phase 1 — The app contract  ✅ complete (2026-08-30) — one item awaits dan

Phase 0 will have discovered, by force, what an object must answer to be
renderable. This phase writes it down.

- **Name the contract** `agent` — what a subject must respond to for labels,
  values, types and collections to be inferable. Phase 0 showed values and
  types are free; **labels are the open question** — `ss_primary_amount`
  means something specific to roth, and only roth knows it.
  *Done looks like:* `CONTRACT.md` states it, and says what happens when an
  app does not satisfy it. **Done** — and it is one sentence: a subject
  answers the attributes it is asked for, by ordinary method call. Types are
  never declared, because they are read from the value. Labels get an optional
  `label_for`, which took the roth form from eleven labels written in the page
  to none.
- **Judge the cost** `dan` — **awaiting you.** The measured cost is: nothing
  required that an app does not already do, and one optional method if you
  want good labels. [CONTRACT.md](CONTRACT.md) ends with the numbers.
  *Done looks like:* a decision, recorded.

## Phase 2 — The second slice: the table

`column` is the other four-inference word: header, value, presentation, and
alignment, all from one name.

Words added: `section`, `table`, `column`, `total`, `money`, `percent`,
`each`, `title`, `empty`.

- **Collections and nesting** `agent` — `each` inside `section` inside `page`,
  and a `table` that writes no loop.
  *Done looks like:* the portfolio page's holdings table renders from real
  objects.
- **Formatting inference** `agent` — money right-aligned and negative-classed,
  percent multiplied, both chosen from the value's type rather than said.
  *Done looks like:* no `as:` modifier is needed for the ordinary cases.

## Phase 3 — Reuse: layout and partials

Before forty-six words are built, find out how they compose. If reuse changes
how words nest or how the subject is passed, it is far cheaper to learn it
now than after Phase 4.

**The evidence this phase is built on**, measured across the three drafted
pages:

- `stylesheet`, `nav` and `footer` appear at page level in **all three**
  pages; `meta` and `script` in some. Identical in shape, different in
  content — a template with holes, which is the definition of a layout.
- `list plain` → `each` → `item` → contents recurs **three times across two
  pages**. `grid metrics` followed by several `metric` lines recurs twice, and
  `metric` is used ten times overall.

So both abstractions are earned by real repetition rather than anticipated.

- **Layout** `agent` — the chrome every page shares, defined once, with the
  page's own content filling the hole.
  *Done looks like:* the three drafted pages lose their `stylesheet`, `nav`
  and `footer` lines to a layout, and still render identically.
- **Partials as app-defined words** `dan` `agent` — the design question, and
  it has a candidate answer that keeps the founding principle literally true.
  *Extending the language adds vocabulary, never syntax* — so a partial is
  simply **a word an app defines**, invoked exactly like a built-in, taking
  the current subject as its own. slim-pickins owns the vocabulary of
  presentation; an app owns the vocabulary of its own components.
  *Done looks like:* the repeated `list`/`item` shape collapses into one
  app-defined word used in both pages, and a reader cannot tell from the call
  site whether a word is built-in or app-defined.
- **Shadowing** `conv` — an app-defined word that collides with a
  slim-pickins word is an error, not an override. Two meanings for one word is
  the alias problem wearing a new hat.
  *Done looks like:* the collision raises, naming both definitions.
- **Judge it against Slim** `dan` — is a layout plus a partial in this
  language better to read and write than `layout.slim` plus a `render`
  call?
  *Done looks like:* the answer, recorded, including if it is no.

## Phase 4 — The rest of the vocabulary

The remaining words. Low risk, real work, and the only phase that is mostly
typing.

- **Every word implemented** `agent`, in the five groups.
  *Done looks like:* all three test pages render — [PORTFOLIO.md](PORTFOLIO.md),
  [CONTENT.md](CONTENT.md), [FIGURES.md](FIGURES.md) — and
  `check_grammar.rb` is green.

## Phase 5 — The design system

The vocabulary renders classes; something must define them.

- **Decide the relationship to slim-pickins' CSS** `dan` — the dashboard
  already ships `slim-pickins.css` with `sp-card`, `sp-btn`, `sp-badge`,
  `sp-list`, `sp-grid` and more. If our words render those class names, this
  phase is nearly free and the two projects share a design system. If not, we
  own a second one.
  *Done looks like:* a decision, recorded, with the class-naming convention
  written into VOCABULARY.md's `renders` slots.

## Phase 6 — Integration

- **A Sinatra template handler** `agent` — so a view file in this language is
  rendered the way `.slim` is today.
  *Done looks like:* a Sinatra app renders a page from a file on disk.
- **The escape hatch** `agent` — what an app does when the vocabulary has no
  word for what it needs. The language has no `div`, which is deliberate, so
  this needs an answer that is not "add a word to slim-pickins".
  *Done looks like:* a documented way through, and evidence it is rarely
  needed.

## Phase 7 — Port a real app

- **Port roth entirely** `agent` — every view, not the one page.
  *Done looks like:* roth runs on this language, and the diff against its old
  views is reviewed line by line.
- **Judge it** `dan` — is this better to read and write than the Slim it
  replaced?
  *Done looks like:* the answer, recorded, including if it is no.

## Phase 8 — `chart`

Deliberately last. It is the one entry written without evidence, it has more
irreducible configuration than any other word, and three pages have failed to
test it.

- **Find a real charting need** `dan` — roth has an SVG balance chart already.
  *Done looks like:* `chart` is redrafted against something real, the way
  every other word was, or it is cut.

---

## What "how far along" means

Phases 0 and 1 are small and retire two of the three High risks. Phase 3
retires the third. Phase 4 is the largest by effort and the smallest by risk.
If Phase 0 fails, everything after it changes shape, which is exactly why it
is first.

A thin transform on its own would have completed part of one item in Phase 0.
