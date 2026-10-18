# alt-slim-pickins — roadmap 0.7

**An odd-numbered roadmap. It leads with the forward eye.**

Status: **confirmed by dan 2026-10-16.** Written by the steward from the Wall
Ledger in [DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md). It is a roadmap and not a
plan: it names the question and what success looks like, leaving the
step-by-step work to daytrips, the way 0.4, 0.5, and 0.6 did.

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
>
> *Walk like the chameleon: what lies ahead is watched, what lies behind is
> glanced back at.*

## The question

> **Can the language carry a publication-grade reader — a document reader and a
> lore reader united into one editorial surface — with the author writing zero
> `tag` escapes, zero bespoke CSS, and zero domain contortions?**

It is a forward-eye question, which is what an odd roadmap asks for (README,
*How roadmaps go*). It is the **Stretch Exam** from
[docs/STRETCH_PROTOCOL.md](docs/STRETCH_PROTOCOL.md), Horizon B — the High-Craft
Editorial & Micro-Layout Benchmark — selected and named by dan at the close of
0.6. The exam's target is real: the unified reader replaces `examples/doc_reader`
and `examples/lore_reader`, and the standalone `lore_reader` is retired when the
new reader lands.

## The definition of success

The exam is passed when the paper from
[DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md) renders live, unmodified, and meets the
Editorial Prose benchmark — not when a checker exits 0. A Stretch Exam passes on
four conditions (STRETCH_PROTOCOL, *Visual Sign-Off & Gate Lock*):

1. **The Wall Ledger empties.** Each wall below is healed at the structural
   layer of the language — never by making the author mind the compiler, and
   never by an app-space polyfill.
2. **The paper runs unmodified.** The `.frame`, `.sp`, `.layout`, and `.style`
   files drafted in 0.7.0a are the files the reader serves.
3. **Green, and looked at.** All twelve gate legs and the suite green, and the
   live reader inspected in the browser against the Editorial Prose archetype —
   a bounded measure, quiet margins, metadata clustered beside prose, not
   dashboard tiles above it.
4. **One enters, one retires.** `lore_reader` is retired, folded into the unified
   reader, and the garden does not grow a museum.

## The Wall Ledger — the daytrips

Measured in [DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md), not assumed. Three real
walls, one already fixed, one framing decision:

1. **Landing evaluation vs. the page-in-frame ontology — ruled.** `page`
   dissolves: it was one word fusing the document envelope with the route's
   subject/title declaration. The `.frame` takes the envelope, the route `.sp`
   becomes the word (filename = word name, leading line = arguments), and the
   grammar never changes — a route is a `def` with its `def <name>` line elided.
   The confirmed contract is [DAYTRIP-0.7.0b.md](DAYTRIP-0.7.0b.md), the first
   daytrip to build, because every other wall's sentences are written on top of it.

2. **Self-titling documents.** `page document` should take the document's first
   heading as its title, and `prose` should start where the title ends. Today
   the author writes `page document, .title` and the title renders twice.

3. **Inline metadata cluster micro-layout.** There is no `cluster` — a wrapping
   inline row of small facts — in `.sp` or `.layout`. The author's only posture
   for metadata today is `grid metrics` (responsive tiles), the wrong shape for
   facts beside prose. The daytrip also settles whether `cluster` lives in
   `.sp` or `.layout`.

4. **Sayable editorial theme roles.** `measure: wide`, `gap: loose` — the theme
   roles exist only as CSS custom properties; no sentence can speak them. The
   reserved `.style` layer is this wall's home.

*(Subject/class collision was named in the 0.7.0a brief and is **not** a wall —
measured already fixed.)*

## How 0.7 arrived at this question

Roadmap 0.6 closed on 2026-10-16, having unified the language's taxonomy and
teaching across eleven daytrips. Its last movement named Roadmap 0.7's Stretch
Exam: *the Editorial & Micro-Layout Publication* — uniting `doc_reader` and
`lore_reader` into one publication-grade reader.

Two of the five candidate walls were, on measurement, not walls — a reminder the
0.7.0a daytrip turned into the ledger's own first lesson: subject/class collision
was fixed by the roadmaps since `WHAT_IF.md` named it in 2026-10-04, and landing
evaluation, far from missing, is already live — its wall is that two 0.6 changes
disagree about where `page` lives. The honest opening move was to measure the
premises before planning the fixes, and the ledger above is what survived that
measurement.

## What this document is not

This document is not a design document, and it is not a phase plan. It holds the
question, the definition of success, and how 0.7 arrived here. The working order
belongs in `PROJECT.md`'s `next_step`. Step-by-step progress belongs in
daytrips, run one at a time and verified before moving to the next.
