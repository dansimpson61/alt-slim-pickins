# Spiff — slim-pickins' design idiom

> **Purpose & Ethos**: Spiff is the visual companion to slim-pickins — a design
> idiom, in the sense the language means it: its own small vocabulary for saying how
> things sit. It separates *substance* from *presentation* so authors only ever have
> to reason about one domain at a time. Substance declares **what** knowledge is;
> Spiff declares **how** that knowledge sits in space.
>
> It speaks slim-pickins's one-sentence grammar and indentation rules, but uses its own
> vocabulary of spatial posture, breathing room, and visual temperament. The compiler
> translates human spatial intent into high-grade modern CSS: Container Queries (`@container`),
> CSS Grid (`minmax()`), fluid viewport/container clamp functions (`clamp()`), and scoped custom properties.

---

## 1. Syntax: 100% Shared Grammar with Slim-Pickins

Spiff uses `SlimPickins::Transform` directly:
- **One-sentence grammar**: Each line begins with a word.
- **Indentation nests it**: Blocks are indented; no `do ... end`, no curly braces, no semicolons.
- **Bare identifiers become symbols**: `air generous` compiles to `air(:generous)`; `frame quiet` compiles to `frame(:quiet)`.
- **Keyword modifiers**: `beside: reading_pane, balance: subordinate, collapse: cozy`.
- **Line tracking**: Errors pinpoint the exact line number of the `.spiff` file.

### Substance vs. Spiff Side-by-Side

```
Substance (.sp)                      Spiff (.spiff)
──────────────────────────────       ──────────────────────────────────────────
page "Doc Reader"                    surface doc_reader
  catalog docs, "Documents"            stage
  reading_pane selected_doc              air generous
                                         flank catalog, beside: reading_pane, balance: subordinate
def catalog, documents, title
  box documents, title                 zone catalog
    list documents                       frame quiet
      each document                      cadence compact
        link .name, .path
                                       zone reading_pane
def reading_pane, document               frame quiet
  box document, .name                    treatment editorial
    prose markdown, .content
```

---

## 2. The Lexicon

Every word in Spiff models exemplary lexical practice:
1. **What it is**: The conceptual essence.
2. **What it is for**: The design problem it solves and intent it declares.
3. **How to use it**: Syntax, options, and constraints.
4. **Examples**: Code snippet in pure `.spiff` syntax.
5. **Compiled CSS**: the exact modern CSS emitted under the hood, in a fenced
   block under its own heading — real output, not a sketch.

---

### `surface`
- **What it is**: The top-level root declaration binding a visual specification to a page or view surface.
- **What it is for**: Defining the scope of a visual manifesto and naming which of two known container conventions its `stage` targets — `kind: :shell` for an app tool that owns the viewport (the studio workbench: `.shell`, the one real shell wrapper this project has, pinned by the emitted `.shell` class), or the default `kind: :document` for a page that flows normally under `body`. `surface` itself compiles to no CSS of its own; `kind` is read once, by the `stage` it encloses.
- **How to use it**:
  ```
  surface <name>, kind: shell
    # stage and zone declarations indented below
  ```
- **Example**:
  ```
  surface doc_reader
    stage
      flank catalog, beside: reading_pane, balance: subordinate
  ```
  (No `kind:` — `doc_reader` is a document surface; its zones flow directly
  under `body`, which is also why the compiled rule below targets `body`
  rather than a wrapper element that doesn't exist in this page's markup.)

---

### `stage`
- **What it is**: The primary canvas context within a surface.
- **What it is for**: Establishing an inline-size container query context (`container-type: inline-size`) so that internal spatial postures (`flank`, `stack`) respond to their container's actual width rather than the screen viewport. It targets the real element implied by its surface's `kind` — never a guessed class.
- **How to use it**:
  ```
  stage
    air generous
    flank catalog, beside: reading_pane
  ```
- **Example**:
  ```
  stage
    air generous
    flank catalog, beside: reading_pane, balance: subordinate
  ```
**Compiled CSS**

```css
html {
  container-type: inline-size;
  container-name: doc_reader;
}

body {
  display: grid;
  align-items: stretch;
  padding: clamp(1.5rem, 4cqi, 3rem);
  gap: clamp(1.5rem, 4cqi, 3rem);
  box-sizing: border-box;
}
```

---

### `horizon`
- **What it is**: A spatial declaration of several semantic zones as *planes* in one row.
- **What it is for**: Arranging a shell's zones side by side — a navigation shelf, a working surface, a mirror of results — when two zones in a `flank` are not enough and more would nest flank inside flank. It is the multi-zone form of horizontal composition, and the one that costs no extra markup: an intermediate `.panes` wrapper that happens to sit between the stage and its zones is dissolved with `display: contents`, so the zones reach the grid whether or not it exists.
- **How to use it**:
  ```
  horizon zone_a, zone_b, zone_c
    posture role_a, role_b, role_c
    collapse roomy
  ```
  - `posture`: one role per zone, in order — see the `posture` entry below. Omitting it gives every zone `equal`.
  - `collapse`: the container-query threshold below which the row stacks (same token scale as `flank`).
  - It also carries the hygiene baseline: every named zone gets `min-height: 0; min-width: 0`, so a wide child cannot blow the track out (Sandi Metz's rule, injected rather than asked for).
- **Example**:
  ```
  horizon library, editor, output
    posture shelf, workspace, mirror
    collapse roomy
  ```
**Compiled CSS**

```css
.shell {
  grid-template-columns: minmax(14rem, 19rem) minmax(0, 3fr) minmax(0, 2fr);
}

.shell > h1:first-child {
  grid-column: 1 / -1;
}

.shell > .panes {
  display: contents;
}

.shell .library,
.shell .editor,
.shell .output {
  min-height: 0;
  min-width: 0;
}

.shell .library {
  grid-column: 1;
}

.shell .editor {
  grid-column: 2;
}

.shell .output {
  grid-column: 3;
}

@container workbench (inline-size < 56rem) {
  .shell {
    grid-template-columns: 100%;
  }
  .shell .library,
  .shell .editor,
  .shell .output {
    grid-column: 1;
  }
}
```

---

### `posture`
- **What it is**: The width role each zone takes in a `horizon`.
- **What it is for**: Naming the relative prominence of several planes at once, the way `balance` does for two. It is a *modifier of `horizon`*, not a word that stands alone — and it is strict: it refuses a count that does not match the horizon's zones, with a message naming both lists, rather than silently leaving a column unsized.
- **How to use it**: one role per zone, in the order the zones were declared.
  ```
  horizon library, editor, output
    posture shelf, workspace, mirror
  ```
  - `shelf` — a fixed, browsable strip: `minmax(14rem, 19rem)`.
  - `workspace` — the fluid primary surface: `minmax(0, 3fr)`.
  - `mirror` — a fluid secondary surface: `minmax(0, 2fr)`.
  - `aside` — a fixed companion: `minmax(16rem, 1fr)`.
  - `equal` — an even share: `minmax(0, 1fr)` (the default when `posture` is omitted).
- **Example**: `posture shelf, workspace, mirror`
**Compiled CSS**

```css
/* shelf, workspace, mirror */
grid-template-columns: minmax(14rem, 19rem) minmax(0, 3fr) minmax(0, 2fr);
```

---

### `collapse`
- **What it is**: The container width below which a horizontal arrangement gives up and stacks.
- **What it is for**: Deciding when a row of zones becomes a column, as a *qualitative* threshold rather than a length. The author says `tight` or `roomy`; the scale lives once in `Spiff::COLLAPSE_TOKENS`, so retuning it does not mean editing every `.spiff` file. It is the reason a `.spiff` never holds a raw CSS length.
- **How to use it**: a modifier of both `flank` and `horizon`.
  ```
  flank catalog, beside: reading_pane, collapse: tight
  horizon library, editor, output
    collapse roomy
  ```
  - `tight` — 26rem: collapse only in genuinely narrow embeddings.
  - `cozy` — 48rem, the default when a `flank` says nothing.
  - `roomy` — 56rem.
  - `wide` — 64rem.
  - The emitted query is `@container <surface> (inline-size < <threshold>)` — measured against the surface's container, never the viewport, so an embedded preview collapses on its own width.
- **Example**: `collapse roomy`
**Compiled CSS**

```css
@container workbench (inline-size < 56rem) {
  .shell {
    grid-template-columns: 100%;
  }
}
```

---

### `flank`
- **What it is**: A spatial declaration of horizontal companionship between two semantic zones.
- **What it is for**: Placing a primary zone beside a companion zone when space allows, with an explicit balance ratio and a responsive collapse threshold.
- **How to use it**:
  ```
  flank lead_zone, beside: companion_zone, balance: subordinate, collapse: cozy
  ```
  - `balance`: Relative visual prominence (`subordinate`, `equal`, `dominant`).
  - `collapse`: Qualitative container query threshold token below which columns
    collapse into a vertical stack — `tight` (26rem), `cozy` (48rem, the
    default), `roomy` (56rem), or `wide` (64rem). Never a raw CSS length; the
    scale lives once in `Spiff::COLLAPSE_TOKENS`.
- **Example**:
  ```
  flank catalog, beside: reading_pane, balance: subordinate, collapse: cozy
  ```
**Compiled CSS**

```css
html {
  container-type: inline-size;
  container-name: doc_reader;
}

body {
  grid-template-columns: minmax(14rem, 1fr) minmax(0, 3fr);
}

body > h1:first-child {
  grid-column: 1 / -1;
}

body .catalog {
  grid-column: 1;
}

body .reading_pane {
  grid-column: 2;
}

@container doc_reader (inline-size < 48rem) {
  body {
    grid-template-columns: 100%;
  }
  body .catalog,
  body .reading_pane {
    grid-column: 1;
  }
}
```

---

### `stack`
- **What it is**: A spatial declaration of vertical linear rhythm.
- **What it is for**: Arranging zones or elements in a vertical sequence with uniform spacing, without manual margins or wrapper divs.
- **How to use it**:
  ```
  stack header, content, footer, air: balanced
  ```
- **Example**:
  ```
  stack overview, details, air: generous
  ```
**Compiled CSS**

```css
body {
  display: grid;
  align-items: stretch;
  padding: clamp(1.5rem, 4cqi, 3rem);
  gap: clamp(1.5rem, 4cqi, 3rem);
  box-sizing: border-box;
}

body {
  display: flex;
  flex-direction: column;
}
```

---

### `zone`
- **What it is**: A declaration of styling affordances, boundaries, cadence, or treatment targeted at a specific semantic zone.
- **What it is for**: Applying visual characteristics to a named component without adding presentation classes to the template.
- **How to use it**:
  ```
  zone zone_name
    frame quiet
    cadence compact
    treatment editorial
  ```
- **Example**:
  ```
  zone catalog
    frame quiet
    cadence compact
  ```
**Compiled CSS**

```css
.catalog {
  background: var(--surface-soft, #f9f8f5);
  border: 1px solid var(--rule, #e5e1d8);
  border-radius: var(--radius, 4px);
  padding: clamp(0.75rem, 1.5cqi, 1rem);
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}
```
A zone's selector is its own bare class — the same class its `.sp` partial
already renders via this project's app_class-promotion convention, and
already scoped safely because a compiled `.spiff` stylesheet is only ever
loaded by the pages that use it.

---

### `air`
- **What it is**: The declaration of spatial breathing room (padding and gaps).
- **What it is for**: Controlling internal spacing through tokenized, fluid `clamp()` values using container query inline units (`cqi`).
- **How to use it**: `air tight` | `air balanced` | `air generous`
- **Example**: `air generous`
**Compiled CSS**

```css
padding: clamp(1.5rem, 4cqi, 3rem);
gap: clamp(1.5rem, 4cqi, 3rem);
```

---

### `balance`
- **What it is**: The relative visual prominence ratio between flanking companions.
- **What it is for**: Declaring which zone dominates visual weight without calculating percentages or column spans.
- **How to use it**: Modifier to `flank(..., balance: subordinate | equal | dominant)`
- **Example**: `balance: subordinate` (lead is minor column, companion is major column).
**Compiled CSS**

```css
/* subordinate */
grid-template-columns: minmax(14rem, 1fr) minmax(0, 3fr);

/* equal */
grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);

/* dominant */
grid-template-columns: minmax(0, 3fr) minmax(14rem, 1fr);
```

---

### `frame`
- **What it is**: The visual boundary enclosure of a zone.
- **What it is for**: Defining surface boundaries, backgrounds, and borders.
- **How to use it**: `frame quiet` | `frame lifted` | `frame bordered` | `frame flat`
- **Example**: `frame quiet`
**Compiled CSS**

```css
background: var(--surface-soft, #f9f8f5);
border: 1px solid var(--rule, #e5e1d8);
border-radius: var(--radius, 4px);
padding: clamp(0.75rem, 1.5cqi, 1rem);
```

---

### `cadence`
- **What it is**: The repetition frequency and rhythm for internal children.
- **What it is for**: Controlling how tightly packed items are inside a list or manifest.
- **How to use it**: `cadence compact` | `cadence regular` | `cadence relaxed`
- **Example**: `cadence compact`
**Compiled CSS**

```css
display: flex;
flex-direction: column;
gap: 0.35rem;
```

---

### `treatment`
- **What it is**: Typographic temperament and optical measure.
- **What it is for**: Applying optical measure (reading line length), line-height, and typographic rhythm.
- **How to use it**: `treatment editorial` | `treatment prose` | `treatment code` | `treatment tabular`
- **Example**: `treatment editorial`
**Compiled CSS**

```css
max-width: 65ch;
line-height: 1.7;
font-size: 1.05rem;
```

---

### `scroll`
- **What it is**: Whether a zone scrolls its own overflow.
- **What it is for**: Giving a bounded pane its own scrollbar instead of growing the page — the shelf whose list is longer than the viewport, the panel whose tab content is taller than its slot. Without it, a long list pushes the whole shell taller and the shell stops owning the viewport.
- **How to use it**: `scroll internal` or `scroll own`
  - `internal` — the zone becomes a scroll container (`overflow-y: auto`, `overscroll-behavior: contain`) **and** its tab panels get a capped height of their own. Say this when the zone holds tabs.
  - `own` — the zone becomes a scroll container and nothing else is said. Say this when it does not.
  - Omitted, the zone does not scroll; its content contributes to the page's height, which is what a document surface wants.

  `internal` was the only token for its first month, and it did both jobs whether or not the zone had tabs — so a zone without them compiled a `.zone .tab-panel` rule that matched nothing. That is the defensive-selector defect the 2026-09-25 round set out to remove, and it was still in the compiler; `check_spiff_scope.rb` found it the first time a new Spiff was held to the HTML its pages render (DAYTRIP-0.4.0k). An unknown token now raises rather than compiling to silence.
- **Example**:
  ```
  zone library
    scroll internal
  ```
**Compiled CSS**

```css
.library {
  overflow-y: auto;
  overscroll-behavior: contain;
  min-height: 0;
}

.library .tab-panel {
  max-height: var(--panel-height, 28rem);
  overflow-y: auto;
  overflow-x: hidden;
  overscroll-behavior: contain;
}
```

---

### `presence`
- **What it is**: How a zone holds its place against the viewport.
- **What it is for**: Keeping a zone in view while the rest of the shell scrolls, and giving it a height derived from the viewport rather than from its own content. This is the declaration that makes a shell a shell: the output pane is the same height whatever the editor beside it does.
- **How to use it**: `presence steady`
  - `steady` — the zone is sticky below the menu, aligned to the top of its track, and sized to the viewport minus the menu, the footer and one loose gap; its tabs, panels and iframes are told to fill that height.
  - Omitting it lets the zone size to its content, and to the row's stretch.
- **Example**:
  ```
  zone output
    presence steady
  ```
**Compiled CSS**

```css
.output {
  position: sticky;
  top: var(--gap, 0.75rem);
  align-self: start;
  height: calc(100dvh - var(--menu-height, 2.75rem) - var(--footer-height, 2rem) - var(--gap-loose, 1.5rem));
  max-height: calc(100dvh - var(--menu-height, 2.75rem) - var(--footer-height, 2rem) - var(--gap-loose, 1.5rem));
  overflow: hidden;
  box-sizing: border-box;
}

.output .tabs {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
}

.output .tabs-content {
  flex: 1 1 0;
  min-height: 0;
  height: 100%;
}

.output .tab-panel {
  height: 100%;
  min-height: 0;
  overflow-y: auto;
}

.output iframe,
.output .iframe {
  width: 100%;
  height: 100%;
  border: none;
}
```

---

### `focus`
- **What it is**: Which zone is the one being worked in.
- **What it is for**: Marking the primary interactive surface of a layout and giving the fields inside it the room to be worked in. In the workbench that is the editor: three stacked textareas that each need real height and a monospace face, and that a general `.field textarea` rule had been sizing as if they were short form fields.
- **How to use it**: `focus primary`
  - `primary` — the zone becomes a column flex container, and every textarea in it (directly, or inside a `.form`) is reset to full width with the code face; the first three fields are given source/design/data minimum heights. The `max-width: none` is load-bearing: it is what undoes the generic form-field cap.
- **Example**:
  ```
  zone editor
    focus primary
  ```
**Compiled CSS**

```css
.editor {
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.editor textarea,
.editor .form textarea {
  width: 100%;
  max-width: none;
  font-family: var(--face-mono, monospace);
  font-size: var(--size-small, 0.875rem);
  line-height: var(--lead-tight, 1.25);
  background: var(--surface, #ffffff);
  border: var(--rule-width, 1px) solid var(--rule, #e5e1d8);
  border-radius: var(--radius, 4px);
  padding: var(--step, 0.25rem) var(--gap, 0.75rem);
  box-sizing: border-box;
  resize: vertical;
}

.editor .field:nth-of-type(1) textarea {
  min-height: var(--editor-source-height, 12rem);
}

.editor .field:nth-of-type(2) textarea {
  min-height: var(--editor-design-height, 9rem);
}

.editor .field:nth-of-type(3) textarea {
  min-height: var(--editor-data-height, 6rem);
}
```

