# Daytrip 0.7.0a — The Publication, on paper (the Stretch Exam's first movement)

**Status: complete.** Roadmap 0.7's opening movement: the Editorial & Micro-Layout
Publication drafted on paper, uncompromised, then held against the language to
inventory the Wall Ledger.

## Objective

Write the unified `doc_reader` + `lore_reader` publication reader the way an
author wishes to write it — a clean `.frame`, route `.sp` templates of pure
substance, a `.layout` that carries the spatial posture, and a `.style` layer
for the theme roles — with zero `tag` escapes, zero bespoke CSS, and zero domain
contortions. Then run that paper against the current language and record every
place it pinches, as the Wall Ledger that Roadmap 0.7 will spend itself on.

The five walls named in `PROJECT.md`'s `next_step` are each measured below, not
assumed: **landing evaluation, self-titling documents, inline metadata cluster
micro-layout, sayable editorial theme roles, and subject/class collision.**

---

## Movement 1 — Paper First: the uncompromised reader

**Archetype: Editorial Prose** (declared per `docs/STRETCH_PROTOCOL.md`). A
publication-grade reader is the newspaper you read at a table, not the console
you operate: a bounded measure of prose, a quiet margin, and small clusters of
metadata that sit beside the text rather than above it as dashboard tiles.

The unified reader reads two kinds of thing — a **document** (a markdown file
with headings, read front to back) and an **entry** (a dated log record with an
author and mentioned words). Both are "readings"; the reader is one surface.

### The frame — `views/publication.frame`

```frame
page "The Publication"
  nav
    link home, "Reading"
    link shelf
    link timeline
    link search
  contents
  footer "Every document and every lesson, read as a reader meets them."
```

### The document page — `views/document.sp`

The author wishes the document to title itself, and the prose to start where the
title ends:

```sp
page document
  cluster meta
    time .changed_on
    metric .reading_minutes
    badge .audience
  prose markdown, .content
```

- `page document` — no `.title`: the page takes its title from the document's
  first heading, and `prose` renders the content *without* repeating it.
- `cluster meta` — a wrapping inline row of small facts. Today the author must
  fall back to `grid metrics` (three equal tiles) because there is no `cluster`.

### The entry page — `views/entry.sp`

```sp
page entry
  cluster meta
    time .date
    badge .author
    metric .reading_minutes
  prose markdown, .body
  section words, "Words mentioned"
    empty "No words indexed in this entry."
    cluster
      each word
        badge .to_s
```

### The audiences page — `views/audiences.sp`

```sp
page shelf
  section users
    documents_list
  section devs
    documents_list
  section history
    documents_list
```

### The layout — `publication.layout`

```layout
surface publication
  stage
    air generous
    flank shelf, beside: reading_pane, balance: subordinate, collapse: tight

  zone reading_pane
    frame flat
    treatment editorial
    measure wide
    gap loose

  zone meta
    cluster inline
    gap tight
```

### The style layer — `publication.style` (the reserved fourth canvas)

```style
publication editorial
  measure wide
  gap loose
  density airy
```

---

## Movement 2 — The Wall Inventory

Each wall is measured against the current language. Three are real; one is
already fixed; one is a conflict between two changes that 0.6 itself made.

### Wall 1 — Landing evaluation, and the conflict it exposes

**Claim to measure:** `page document, .title` means "the document, titled by its
title" — a sentence that names where it lands reads its dots there.

**Measured:** landing evaluation itself works, and it is live. `partial_word.rb`
carries the `landing`/`landed` mechanism, and `examples/doc_reader/views/document.sp`
opens `page document, .title` and renders correctly (it is in the `verify_pages`
corpus, green). The reader's core sentence is already sayable — *in the route*.

**The conflict, measured empirically.** Roadmap 0.6 made two changes that
disagree with each other:

1. The Tri-Plane ontology (`docs/ONTOLOGY.md`) rules that **`page` belongs
   exclusively in the `.frame`**, and the author guides (`docs/PRIMER.md`,
   `checkers/check_pedagogy.rb`) teach the frame as `page "Doc Reader"` wrapping
   `contents`, with route `.sp` files as pure substance — no `page`.
2. Landing evaluation requires **`page document, .title` to be spoken in the
   route `.sp`**, because that sentence is what shifts the subject to `document`
   before the route's own prose reads `.content`.

The two shapes both compile — the runtime's `Builder#render` accepts a route
with or without a `page` node — but only one of them can carry a per-route
subject. Verified with a scratch render:

- **Shape A** (page in the route, as every app still writes it) renders the full
  document, shifts the subject, and `page document, .title` resolves `.title` on
  the document. ✓
- **Shape B** (page in the frame, as the ontology and guides now teach) renders a
  full document for a static title like `page "The Publication"`, **but a
  document route written the way the guides teach fails**: `prose markdown,
  .content` reports "this page has no content", because the substance is
  evaluated *before* the frame's `page document` shifts the subject — `stow_contents`
  stores already-rendered nodes, and the frame's subject shift arrives too late.

**The finding:** no application has migrated to Shape B, which is why
`check_pedagogy.rb` passes while the guides describe a shape that cannot express
the reader's single most important sentence. The ontology and landing evaluation
are both from 0.6, and they are in tension. This is the first wall: **either the
frame must learn to shift the subject for the substance it splices (Shape B
healed), or the ontology must admit `page` in the route (Shape A ratified).** It
is a framing decision for Roadmap 0.7, and it is dan's call.

### Wall 2 — Self-titling documents

**Claim:** `page document` should take the document's first heading as its
`<title>` and `<h1>`, and `prose` should start where that heading ends.

**Measured:** not implemented. Today `document.sp` must write `page document,
.title` explicitly, and `prose markdown, .content` renders the whole file —
including the `#` heading — so the title appears twice: once as the page's
`<h1>`, once demoted inside the prose. `WHAT_IF.md` named this ("what if a
document titled itself?") and left it unbuilt. The domain already computes the
answer (`DocReader::Document#title`, `#headings`); the language does not yet let
the page *ask* for it by staying silent.

### Wall 3 — Inline metadata cluster micro-layout

**Claim:** `cluster meta` lays out a row of small facts (`time`, `metric`,
`badge`) that wraps inline with a uniform gap.

**Measured:** `cluster` does not exist. It is a recognised missing primitive —
`lib/slim_pickins/taxonomy.rb`'s `MISSING_PRIMITIVES` names it "horizontal
wrapping flex layout capability with uniform gap" and defers it to `.layout` or
a styling layer. The closest today is `grid metrics, columns: 3`, which is a
*responsive tile grid*, not a *wrapping inline cluster* — the wrong posture for
metadata beside prose. `stack` exists, but only in `.layout`, and only as a
vertical arrangement of named zones, not a component-level wrapping row. Two
open sub-questions: does `cluster` live in `.sp` (a substance word like `grid`)
or in `.layout` (a zone posture like `cadence`)? The paper drafts it in both
places deliberately, to force that decision out.

### Wall 4 — Sayable editorial theme roles

**Claim:** the author says `measure: wide` and `gap: loose`, and the theme
responds — a wider reading column, looser breathing room — without naming a
pixel.

**Measured:** the roles exist only as CSS custom properties (`--measure: 68ch`,
`--gap`, `--gap-loose` in `lib/slim_pickins/assets/slim-pickins.css`); no
`.sp` or `.layout` sentence can speak them. `treatment editorial` already sets a
fixed `max-width: 65ch` and `line-height: 1.7`, but "wide" versus "narrow" is a
*token the author cannot say*. The absence is already registered, not merely
felt: the convention register's axiomatic grade holds a single entry named
`NOTHING` — "the theme owns 65 roles and no page can say one" — recorded so it
cannot be forgotten. The `.style` layer — the reserved fourth canvas named in
`docs/ONTOLOGY.md` — is exactly this gap: micro-layout and theme roles with no
implementation behind them. This wall is the reason the paper drafts
`publication.style`.

### Wall 5 — Subject/class collision (measured: already fixed)

**Claim:** `section users` loses its `section--users` class whenever the subject
also answers `users`.

**Measured — no longer a wall.** `WHAT_IF.md` recorded this defect on
2026-10-04; the subsequent roadmaps (0.5 lexical containment, 0.6 the class
mechanism) appear to have resolved it. A scratch render of `page shelf` over a
`Shelf` that answers both `users` and `devs`, followed by `section users` /
`section devs`, emits `section section--users` and `section section--devs`
correctly. The class now follows the name the page *said*. The `next_step`
premise was stale; this is the "measure the premises of any list item" caution
from `PROJECT.md`, applied.

### Adjacent finding — the guides and the apps have drifted

The same tension as Wall 1, stated as a hygiene fact: the guides teach Shape B,
the eight apps all still write Shape A, and `check_pedagogy.rb` checks only the
guides' fenced snippets — so the drift is invisible to every gate. Whatever
Roadmap 0.7 decides about where `page` lives, the migration has to reach the
apps and the checker together, or the drift returns.

---

## Movement 3 — Framing ROADMAP-0.7.md

The roadmap is framed in [`ROADMAP-0.7.md`](../planning/ROADMAP-0.7.md): the question is
whether the language can carry a publication-grade reader with zero author
workarounds, success is the paper rendered live without one compromise plus one
superseded app retired, and the daytrips are the Wall Ledger above, one wall per
daytrip.

---

## What landed

- The unified reader drafted on paper, uncompromised: one frame, three route
  pages that hit the walls, a `.layout` that names `cluster`/`measure`/`gap`, and
  a sketch of the reserved `.style` layer.
- The Wall Ledger, measured not assumed: **three real walls** (self-titling,
  `cluster` micro-layout, sayable theme roles), **one already fixed**
  (subject/class collision), and **one conflict** (landing evaluation vs. the
  page-in-frame ontology) that is the roadmap's first framing decision.
- `ROADMAP-0.7.md` framed, ready for dan's review.

## Not done here (and deliberately so)

- No `lib/` changed; no wall healed. This is the paper half of "paper, then
  reality" — healing the walls is the daytrips that follow.
- The paper's templates are not yet real files under `examples/`; they move there
  when the first wall is attacked and the reader gets a home.
