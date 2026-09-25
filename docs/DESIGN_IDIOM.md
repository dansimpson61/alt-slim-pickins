# The Design Idiom — Visual Architecture for Slim-Pickins

> **Purpose & Ethos**: The Design Idiom is the visual companion to slim-pickins.
> It separates *substance* from *presentation* so authors only ever have to reason about
> one domain at a time. Substance declares **what** knowledge is; the Design Idiom declares
> **how** that knowledge sits in space.
>
> It speaks slim-pickins's one-sentence grammar and indentation rules, but uses its own
> vocabulary of spatial posture, breathing room, and visual temperament. The compiler
> translates human spatial intent into high-grade modern CSS: Container Queries (`@container`),
> CSS Grid (`minmax()`), fluid viewport/container clamp functions (`clamp()`), and scoped custom properties.

---

## 1. Syntax: 100% Shared Grammar with Slim-Pickins

The design idiom uses `SlimPickins::Transform` directly:
- **One-sentence grammar**: Each line begins with a word.
- **Indentation nests it**: Blocks are indented; no `do ... end`, no curly braces, no semicolons.
- **Bare identifiers become symbols**: `air generous` compiles to `air(:generous)`; `frame quiet` compiles to `frame(:quiet)`.
- **Keyword modifiers**: `beside: reading_pane, balance: subordinate, collapse_at: "48rem"`.
- **Line tracking**: Errors pinpoint the exact line number of the `.design` file.

### Substance vs. Design Idiom Side-by-Side

```
Substance (.sp)                      Design Idiom (.design)
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

Every word in the design idiom models exemplary lexical practice:
1. **What it is**: The conceptual essence.
2. **What it is for**: The design problem it solves and intent it declares.
3. **How to use it**: Syntax, options, and constraints.
4. **Examples**: Code snippet in pure `.design` syntax.
5. **Compiled CSS**: Collapsible `<details>` showing the exact modern CSS emitted under the hood.

---

### `surface`
- **What it is**: The top-level root declaration binding a visual specification to a page or view surface.
- **What it is for**: Defining the scope of a visual manifesto, establishing the namespace for all generated CSS rules, and naming the container context.
- **How to use it**:
  ```
  surface <name>
    # stage and zone declarations indented below
  ```
- **Example**:
  ```
  surface doc_reader
    stage
      flank catalog, beside: reading_pane, balance: subordinate
  ```
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
.surface-doc_reader {
  display: block;
  width: 100%;
}
```
</details>

---

### `stage`
- **What it is**: The primary canvas context within a surface.
- **What it is for**: Establishing an inline-size container query context (`container-type: inline-size`) so that internal spatial postures (`flank`, `stack`) respond to their container's actual width rather than the screen viewport.
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
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
.stage-doc_reader {
  container-type: inline-size;
  container-name: doc_reader;
  display: grid;
  align-items: start;
  padding: clamp(1.5rem, 4cqi, 3rem);
  gap: clamp(1.5rem, 4cqi, 3rem);
}
```
</details>

---

### `flank`
- **What it is**: A spatial declaration of horizontal companionship between two semantic zones.
- **What it is for**: Placing a primary zone beside a companion zone when space allows, with an explicit balance ratio and a responsive collapse threshold.
- **How to use it**:
  ```
  flank lead_zone, beside: companion_zone, balance: subordinate, collapse_at: "48rem"
  ```
  - `balance`: Relative visual prominence (`subordinate`, `equal`, `dominant`).
  - `collapse_at`: Container query threshold below which columns collapse into a vertical stack (default `"48rem"`).
- **Example**:
  ```
  flank catalog, beside: reading_pane, balance: subordinate, collapse_at: "48rem"
  ```
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
.stage-doc_reader {
  grid-template-columns: minmax(14rem, 1fr) minmax(0, 3fr);
}

.stage-doc_reader > .catalog,
.stage-doc_reader > .zone-catalog {
  grid-column: 1;
}

.stage-doc_reader > .reading_pane,
.stage-doc_reader > .zone-reading_pane {
  grid-column: 2;
}

@container doc_reader (inline-size < 48rem) {
  .stage-doc_reader {
    grid-template-columns: 100%;
  }
  .stage-doc_reader > .catalog,
  .stage-doc_reader > .zone-catalog,
  .stage-doc_reader > .reading_pane,
  .stage-doc_reader > .zone-reading_pane {
    grid-column: 1;
  }
}
```
</details>

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
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
.stage-doc_reader {
  display: flex;
  flex-direction: column;
  gap: clamp(1.5rem, 4cqi, 3rem);
}
```
</details>

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
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
.stage-doc_reader > .catalog,
.stage-doc_reader > .zone-catalog {
  background: var(--surface-soft, #f9f8f5);
  border: 1px solid var(--rule, #e5e1d8);
  border-radius: var(--radius, 4px);
  padding: clamp(0.75rem, 1.5cqi, 1rem);
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}
```
</details>

---

### `air`
- **What it is**: The declaration of spatial breathing room (padding and gaps).
- **What it is for**: Controlling internal spacing through tokenized, fluid `clamp()` values using container query inline units (`cqi`).
- **How to use it**: `air tight` | `air balanced` | `air generous`
- **Example**: `air generous`
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
padding: clamp(1.5rem, 4cqi, 3rem);
gap: clamp(1.5rem, 4cqi, 3rem);
```
</details>

---

### `balance`
- **What it is**: The relative visual prominence ratio between flanking companions.
- **What it is for**: Declaring which zone dominates visual weight without calculating percentages or column spans.
- **How to use it**: Modifier to `flank(..., balance: subordinate | equal | dominant)`
- **Example**: `balance: subordinate` (lead is minor column, companion is major column).
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
/* subordinate */
grid-template-columns: minmax(14rem, 1fr) minmax(0, 3fr);

/* equal */
grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);

/* dominant */
grid-template-columns: minmax(0, 3fr) minmax(14rem, 1fr);
```
</details>

---

### `frame`
- **What it is**: The visual boundary enclosure of a zone.
- **What it is for**: Defining surface boundaries, backgrounds, and borders.
- **How to use it**: `frame quiet` | `frame lifted` | `frame bordered` | `frame flat`
- **Example**: `frame quiet`
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
background: var(--surface-soft, #f9f8f5);
border: 1px solid var(--rule, #e5e1d8);
border-radius: var(--radius, 4px);
padding: clamp(0.75rem, 1.5cqi, 1rem);
```
</details>

---

### `cadence`
- **What it is**: The repetition frequency and rhythm for internal children.
- **What it is for**: Controlling how tightly packed items are inside a list or manifest.
- **How to use it**: `cadence compact` | `cadence regular` | `cadence relaxed`
- **Example**: `cadence compact`
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
display: flex;
flex-direction: column;
gap: 0.35rem;
```
</details>

---

### `treatment`
- **What it is**: Typographic temperament and optical measure.
- **What it is for**: Applying optical measure (reading line length), line-height, and typographic rhythm.
- **How to use it**: `treatment editorial` | `treatment prose` | `treatment code` | `treatment tabular`
- **Example**: `treatment editorial`
<details>
<summary><strong>Compiled CSS</strong></summary>

```css
max-width: 65ch;
line-height: 1.7;
font-size: 1.05rem;
```
</details>
