# alt-slim-pickins — roadmap v1

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
| `chart` is right | **High**, narrow | Phase 7, deliberately last |
| The design system the words assume | Medium | Phase 4 |
| Runtime emits correct HTML | Low | Phases 0, 2, 3 |
| Transform is feasible | Low | Phase 0 |
| Grammar parses unambiguously | Low | already evidenced — 267 checked sentences |

The two High rows are both retired by one small slice. That is the argument
for the phase order and the whole of it.

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

## Phase 0 — The vertical slice

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

**Exit criterion:** we know whether `field` can do what its entry claims. If
it cannot, the vocabulary changes here, before forty-six words are built on a
false premise.

## Phase 1 — The app contract

Phase 0 will have discovered, by force, what an object must answer to be
renderable. This phase writes it down.

- **Name the contract** `agent` — what a subject must respond to for labels,
  values, types and collections to be inferable.
  *Done looks like:* `CONTRACT.md` states it, and says what happens when an
  app does not satisfy it.
- **Judge the cost** `dan` — if the contract is onerous, the language is
  unusable and we say so here rather than discovering it at Phase 6.
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

## Phase 3 — The rest of the vocabulary

The remaining words. Low risk, real work, and the only phase that is mostly
typing.

- **Every word implemented** `agent`, in the five groups.
  *Done looks like:* all three test pages render — [PORTFOLIO.md](PORTFOLIO.md),
  [CONTENT.md](CONTENT.md), [FIGURES.md](FIGURES.md) — and
  `check_grammar.rb` is green.

## Phase 4 — The design system

The vocabulary renders classes; something must define them.

- **Decide the relationship to slim-pickins' CSS** `dan` — the dashboard
  already ships `slim-pickins.css` with `sp-card`, `sp-btn`, `sp-badge`,
  `sp-list`, `sp-grid` and more. If our words render those class names, this
  phase is nearly free and the two projects share a design system. If not, we
  own a second one.
  *Done looks like:* a decision, recorded, with the class-naming convention
  written into VOCABULARY.md's `renders` slots.

## Phase 5 — Integration

- **A Sinatra template handler** `agent` — so a view file in this language is
  rendered the way `.slim` is today.
  *Done looks like:* a Sinatra app renders a page from a file on disk.
- **The escape hatch** `agent` — what an app does when the vocabulary has no
  word for what it needs. The language has no `div`, which is deliberate, so
  this needs an answer that is not "add a word to slim-pickins".
  *Done looks like:* a documented way through, and evidence it is rarely
  needed.

## Phase 6 — Port a real app

- **Port roth entirely** `agent` — every view, not the one page.
  *Done looks like:* roth runs on this language, and the diff against its old
  views is reviewed line by line.
- **Judge it** `dan` — is this better to read and write than the Slim it
  replaced?
  *Done looks like:* the answer, recorded, including if it is no.

## Phase 7 — `chart`

Deliberately last. It is the one entry written without evidence, it has more
irreducible configuration than any other word, and three pages have failed to
test it.

- **Find a real charting need** `dan` — roth has an SVG balance chart already.
  *Done looks like:* `chart` is redrafted against something real, the way
  every other word was, or it is cut.

---

## What "how far along" means

Phases 0 and 1 are small and retire both High risks. Phase 3 is the largest
by effort and the smallest by risk. If Phase 0 fails, phases 2 through 7 do
not exist in their current form, which is exactly why it is first.

A thin transform on its own would have completed part of one item in Phase 0.
