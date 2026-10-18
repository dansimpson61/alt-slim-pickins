# Daytrip 0.7.0f — Assemble the unified publication reader; retire lore_reader

**Status: built and verified — the paper's reader is live, and the standalone
`lore_reader` is retired.** Roadmap 0.7's closing movement: the four healed
walls assembled into one reader, then the garden pruned.

## The move

The Wall Ledger is empty; what remained was assembly. Take the paper's files —
the `.frame`, the `document`/`entry`/`shelf` routes, the `.layout`, the `.style`
drafted in [DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md) — and make them the files a
live reader serves, then fold `lore_reader`'s `Lore`/`Entry` domain in and
delete the standalone app.

## What landed

- **`examples/doc_reader` became `examples/publication`** (git mv, history
  preserved): the frame, layout and style renamed `publication.*`, the module
  renamed `Publication`, and the reader now reads *both* things a publication
  holds — a **document** (a markdown file, read front to back) and an **entry**
  (a dated `LORE.md` record). `lore_reader`'s `Lore`/`Entry` folded into
  `publication/lib/lore.rb`.
- **The paper's files, served.** `views/publication.frame` (nav Reading /
  shelf / timeline / search, footer "Every document and every lesson…"),
  `document.sp`, `entry.sp`, and `shelf.sp` (the paper's `audiences.sp`, renamed
  so `link shelf` resolves) render live, unmodified except where the four healed
  walls changed the grammar:
  - `page` is gone — each route opens with a signature (`document`, `entry`,
    `shelf, "Who each document is for"`).
  - `cluster meta` became `def meta / box / contents` plus `zone meta / cluster`
    in `.layout`; the entry's unnamed word `cluster` became `def chips` plus
    `zone chips / cluster`.
  - `measure wide`, `gap loose`, `density airy` live in `publication.style`,
    not in the `.layout` zones.
- **Six routes**: `/` (index — catalog + reading pane), `/shelf` (documents by
  audience), `/timeline` (entries, searchable), `/search`, `/docs/:id`,
  `/entries/:id`. The frame's `<head>` links the base theme, the compiled
  `.layout`, and the compiled `.style`.
- **`lore_reader` retired.** Its two test files go with it; the reader's
  `Entry` gained `reading_minutes`, and the entry page self-titles exactly as a
  document does.

## Two things measured, not assumed

1. **A dotted metric loses its label.** The paper writes `metric .reading_minutes`.
   Rendered, that is `"Metric: 16"` — the dotted value leaves no name for the
   domain's `labels` declaration to answer. The bare form renders the *raw
   value* as the label (`"16: 16"`). Neither says "Minutes"; every other app in
   the garden writes the label explicitly. The reader therefore writes
   `metric reading_minutes, "Minutes"` — a one-word deviation from the paper,
   flagged here as a wall the ledger missed rather than silently absorbed.
2. **An entry titles itself twice unless the domain splits.** `entry` self-titles
   to its first sentence, but `prose markdown, .body` rendered that same
   sentence again (once as `<h1>`, once as the prose's opening). The fix is in
   the domain, the honest shape: an entry's `title` is its first sentence and
   its `body` is the *rest*, so the title is spoken once — the same way a
   self-titling document drops its leading heading.

## The census moves, all together

| fact | was | is |
| :--- | :--- | :--- |
| apps | 8 | **7** |
| verified pages | 35 | **34** |
| test files | 61 | **59** |
| canonical words | 63 | 63 |
| app words | 29 | 29 |

Twelve gate legs + pedagogy green; suite 658 runs / 7,061 assertions / 0
failures.

## Not in this movement

- The visual sign-off: the reader is booted and screenshotted for dan's eye,
  but the Editorial Prose verdict — bounded measure, quiet margins, metadata
  beside prose — is his to render, not a checker's.
- The two measured findings above (dotted-metric label, and the `measure wide`
  role's `--measure: 72ch` losing to `treatment editorial`'s hardcoded `65ch`)
  are recorded for the next roadmap's harvest, not healed here.
