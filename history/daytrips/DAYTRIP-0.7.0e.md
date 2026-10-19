# Daytrip 0.7.0e — Heal Wall 4: sayable editorial theme roles

**Status: built and verified.** The fourth and final movement of Roadmap 0.7,
attacking Wall 4 from the ledger in [DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md).

## The wall

The author should be able to say `measure: wide` and `gap: loose`, and the theme
respond — a wider reading column, looser breathing room — without naming a
pixel. Today those roles exist only as CSS custom properties (`--measure: 68ch`,
`--gap`, `--gap-loose`) and no sentence can speak them; `treatment editorial`
hardcodes `max-width: 65ch` and `line-height: 1.7` because "wide" versus
"narrow" was a token the author could not say.

## The decision the wall asked for

Where do theme roles live? The paper drafted them in two places — `.layout`
(`zone reading_pane / measure wide / gap loose`) and `.style`
(`publication.style`). The roadmap already names the home: *"the reserved
`.style` layer is this wall's home."* So the settlement is the `.style`
companion — the fourth canvas `docs/ONTOLOGY.md` reserved, now implemented:

- **`.layout` says how things sit** — `flank`, `horizon`, `stack`, `cluster`.
- **`.style` says how the theme speaks** — `measure wide`, `gap loose`,
  `density airy` — compiled to the `:root` custom properties the base theme
  already owns.

The leading line names the surface and its archetype (`doc_reader editorial`);
both are labels, and the roles beneath them carry the styling.

## What we'd like

```style
doc_reader editorial
  measure wide
  gap loose
  density airy
```

The frame's `<head>` links the compiled `.style` after the base theme and the
`.layout`, so its `:root` roles override the theme's defaults.

## Why the grammar doesn't move

No new `.sp` word, no new punctuation. `.style` speaks the same one-sentence
grammar (`Transform` compiles it), and each role is a word whose argument is a
token — `measure wide` is `measure(:wide)`, exactly as `.layout`'s
`cadence compact` is `cadence(:compact)`. The token scales live in the compiler
beside `.layout`'s, the values the theme already names:

| role | tokens | property |
| :--- | :--- | :--- |
| `measure` | `narrow` 55ch · `wide` 72ch | `--measure` |
| `gap` | `tight` 0.5rem · `loose` 1.5rem | `--gap` |
| `density` | `compact` 1.35 · `airy` 1.7 | `--lead` |

## What landed

- `Compiler::Style` (and the `SlimPickins::Style` entrypoint) compiles a
  `.style` file to a `:root` block; an unknown token is refused by name.
- `Library.style_path` finds `[app].style`; `Builder#style_stylesheet_url` links
  it in the frame's `<head>`; `doc_reader` serves `doc_reader.style.css` and
  declares `measure wide`, `gap loose`, `density airy`.
- The `theme_roles` convention — the register's single axiomatic entry — moved
  from recording an *absence* ("NOTHING — the theme owns 65 roles and no page
  can say one") to naming the *home* (the `.style` companion).
- `docs/ONTOLOGY.md`, `docs/PRIMER.md` (three canvases → four), and
  `docs/CONVENTIONS.md` moved with it; `taxonomy.rb`'s `style` term is no
  longer "reserved future layer".
- Twelve gate legs + pedagogy green; suite 667 runs / 7,130 assertions / 0
  failures. No census movement — `.style` is a canvas, not a word.

## The Wall Ledger, now empty

All four walls are healed at the structural layer: `page` dissolved (0.7.0b),
documents title themselves (0.7.0c), `cluster` lands in `.layout` (0.7.0d), and
theme roles are sayable in `.style` (0.7.0e). What remains for the exam is the
assembly — the unified reader built from the paper's files — and the visual
sign-off, not another wall.
