# Daytrip 0.7.0d — Heal Wall 3: the inline metadata cluster

**Status: built and verified.** The third movement of Roadmap 0.7, attacking
Wall 3 from the ledger in [DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md).

## The wall

`cluster meta` should lay out a row of small facts — `time`, `metric`, `badge` —
that wraps inline with a uniform gap: metadata beside prose, not dashboard
tiles above it. Today `cluster` does not exist, and the author's only posture is
`grid metrics, columns: 3`, a responsive tile grid — the wrong shape for facts
beside prose.

## The decision the wall asked for

The paper drafted `cluster` in both `.sp` and `.layout` deliberately, to force
the choice. The answer is **`.layout`**, and it was already on record:

- **dan's own wishlist** (2026-10-14) rules that *"geometry and scaffolding
  belong outside the substance template language"*, and that micro-layout should
  come "as an extension of `.layout` (enabling `.layout` to reach inside
  components)… rather than littering `.sp` templates with geometric scaffolding
  like `<div class="sp-cluster">`."
- **`MISSING_PRIMITIVES`** already filed `cluster` under the same rationale.
- **The one counter-precedent, `grid`,** was examined and set aside: `grid` is a
  `.sp` word doing layout, but it predates the "geometry outside substance"
  clarification, and the clarification is explicit. `cluster` becomes a
  `.layout` zone posture, not a 64th canonical word.

So the language does not grow a word; the spatial companion grows a posture.
The census stays at 63 words.

## What we'd like

The author names the group of facts in `.sp` — a `def` whose box carries the
name — and declares its posture in `.layout`:

```sp
document
  card
    meta
      metric word_count
      metric reading_minutes
      metric changed_on
    …

def meta
  box
    contents
```

```layout
zone meta
  cluster
```

The `.sp` says *what* the facts are and that they form a group; the `.layout`
says *how* the group sits — a wrapping inline row with the theme's uniform gap.

## Why the grammar doesn't move

No new `.sp` word, no new punctuation. `cluster` is a zone posture, the
wrapping-inline sibling of `cadence` (the column rhythm posture). `def meta`
is the ordinary composed-word mechanism every zone already uses — `catalog`
and `reading_pane` are `def`s the same way.

The gap is the theme's `--gap`. Saying `gap tight` / `gap loose` is a sayable
theme role, which is Wall 4's home, not this one.

## What landed

- `ZoneBuilder#cluster` compiles `display: flex; flex-wrap: wrap; gap:
  var(--gap, 0.75rem); align-items: center;` for the named zone's class.
- `docs/LAYOUT.md` gained the `cluster` lexicon entry, and the checker's
  `EXAMPLES` pairing holds it — 17 lexicon entries, 88 documented declarations.
- `doc_reader` migrated: `document.sp`'s `grid metrics, columns: 3` became a
  `meta` cluster (`def meta / box / contents`), and `doc_reader.layout` declares
  `zone meta / cluster`.
- `taxonomy.rb`'s `MISSING_PRIMITIVES` dropped `cluster` — it is no longer
  missing. (`stack` and `sidebar` remain, out of this movement's scope.)
- **Byte-diff**: exactly one page changed — `document.sp` — the swap from
  `<div class="grid grid--metrics">` to `<div class="box meta">`. The census is
  untouched (still 63 words / 37 primitives). Twelve gate legs + pedagogy
  green; suite 665 runs / 7,118 assertions / 0 failures.

## Not in this movement

- Wall 4 — sayable theme roles (`gap tight`/`loose`, `measure wide`) — the
  `.style` layer's home.
- The unified reader's full migration; `doc_reader` demonstrates the posture,
  and `lore_reader` retires when the unified reader lands.
