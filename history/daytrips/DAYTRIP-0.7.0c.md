# Daytrip 0.7.0c — Heal Wall 2: self-titling documents

**Status: built and verified.** The second movement of Roadmap 0.7, attacking
Wall 2 from the ledger in [DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md).

## The wall

`document` should take the document's first heading as its title, and `prose`
should start where that heading ends. Today the author writes
`document, .title` and the title renders twice — once as the page's `<h1>`,
once demoted to `<h2>` inside the prose.

## The rule

A route that names a subject and says no title lets the subject title itself.
The subject's own `title` — a document's first heading — becomes the page's
`<title>` and `<h1>`, and markdown prose over that subject's content begins
after that heading, so the title is spoken once.

This is "a name is its own text" extended to content, the idea WHAT_IF.md
named on 2026-10-04 and left unbuilt: the title was already the document's
first heading; the language just could not *ask* for it by staying silent.

## What we'd like

`document.sp` opens with the bare name, and the page and its prose coordinate:

```sp
document
  card
    …
  section chapters
    …
  prose markdown, .content
```

No `.title`. The page titles itself, and `prose` renders the content without
repeating the heading.

## Why the grammar doesn't move

No new word, no new punctuation. Two silent behaviours, both consequences of
one rule:

1. **The title.** A route's signature already falls back to the humanised name
   (`Inference.label`) when the author says no title. The fallback now tries
   the subject's own `title` first — exactly the shape `document, .title`
   spelled out loud, now inferred.
2. **The prose.** The route marks itself self-titled; `prose markdown` reads
   that mark and drops the leading heading from the markdown before rendering.

## The contract, mechanically

### The title crossing

`Builder#route` computes the heading inside `about(name)` — where the subject
is already bound — so a silent title can be read *from* the subject it names.
When the signature carried no title, the route asks the bound subject for
`title`; a subject that answers one is self-titled, and the fallback to the
humanised name remains for subjects that answer none (a bare `portfolio`
still reads "Portfolio").

### The prose crossing

`route` sets `@self_titled` when it takes the subject's title. `prose`
(markdown notation) turns that into `drop_leading_heading` on its node, and
`Markdown.render(source, drop_leading_heading: true)` drops the first heading
*block* — wherever it sits, matching the domain's `Document#title`, which is
the first heading in the content, not only one that happens to open it.

The decision lives in one place (`route` sets the flag) and `prose` reads it —
the same shape `empty` already uses: `about` decides emptiness, `prune` reads
it.

## What landed

- `Builder#route` self-titles and exposes `self_titled?`.
- `Prose` sets `drop_leading_heading`; `Generator#prose` and `Markdown.render`
  honour it.
- `document.sp` drops `, .title` for the bare `document` signature.
- The `:title` convention register entry now states the full rule — subject's
  title, else the humanised name; prose begins after the heading — and the
  author guides (`CONVENTIONS.md`, `VOCABULARY.md`, `PRIMER.md`) moved with it.
- **Certified by the byte-diff harness**: exactly one page changed —
  `document.sp` — and the change is precisely the removal of the demoted
  `<h2>The Way</h2>` (16 bytes). Twelve gate legs green; suite 664 runs /
  7,108 assertions / 0 failures.

## Not in this movement

- Walls 3 and 4 (`cluster` micro-layout, sayable theme roles) — one wall per
  daytrip.
- `lore_reader`'s `entry.sp` still writes `entry, .title`; it self-titles when
  the unified reader lands and the standalone reader retires.
