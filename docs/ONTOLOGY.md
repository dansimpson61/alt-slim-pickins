# The Ontology of Slim-Pickins

> **Purpose & Ethos**: A comprehensive architectural treatise on the meta-architecture,
> tri-plane model, spatial canvases, invariant triad, and multi-axial bandpass taxonomy
> of alt-slim-pickins.

---

## 1. The Tri-Plane Meta-Architecture

Slim-pickins is not an ad-hoc template engine; it is a view language whose grammar is one
sentence — `word arguments`, indentation nests, everything is a word. Extending the language
adds vocabulary, never syntax.

To understand how its components compose without friction, the architecture partitions across
three orthogonal planes:

| Plane | Term | Meaning |
|---|---|---|
| **Linguistic & Execution** (The Lexicon & Grammar) | `word` | Atomic syntactic token and invocation unit (`word arguments`) |
| | `primitive` | Atomic leaf word implemented directly in Ruby (`Words::*`) |
| | `composed_word` | First-class word defined in `.sp` syntax (`def word args`) |
| | `def` | Definition keyword: `def word_name subject, kwargs` |
| **Composition & Spatial** (The Canvases) | `frame` | Document envelope chrome (`.frame`, formerly `.tin`) |
| | `layout` | Spatial companion stylesheet (`.layout`, formerly `.spiff`) |
| | `style` | Theme-role companion (`.style`) — sayable theme roles |
| | `substance` | Route-level body template (`.sp`) answering routes |
| **Mechanical Invariant** (The Instruments of Truth) | `contract` | Compile-time syntactic grammar (takes, holds, modifiers) |
| | `convention` | Inference engine when syntax remains silent (39 conventions) |
| | `promise` | Ledger proving declared modifiers have active readers (34 promises) |

---

## 2. Linguistic & Execution Plane (The Lexicon)

The linguistic plane governs the syntax, tokens, and execution semantics of templates:

1. **`word`**: The fundamental syntax unit. Every line begins with a word. A word invokes
   either a primitive or a composed word, binding arguments according to a declared contract.
   The canonical vocabulary contains sixty-three words.
2. **`primitive`**: An atomic leaf word implemented directly in Ruby as a subclass of
   `SlimPickins::Word`. The runtime core contains thirty-seven primitives (`box`, `span`,
   `each`, `table`, `form`, etc.).
3. **`composed_word`**: A first-class word authored in the language itself using `.sp`
   templates in `lib/vocabulary/` or an application's own views. There are twenty-six `.sp`
   composed words (`badge`, `card`, `metric`, `fact`, `snippet`, `note`, `flash`, etc.).
4. **`def`**: The definition keyword opening a word's lexical scope and parameter bindings:
   `def word_name subject, kwargs`. Composed words are invoked identically to primitives.

### Retiring the "Partial" Anachronism

In legacy Rails and Slim, a "partial" was an inert snippet rendered via `render :partial`.
In slim-pickins, words defined with `def` are first-class citizens. They accept subjects,
participate in subject shifting, take modifiers, and compose through universal slots.
Calling them "partials" obscured their ontological parity with built-ins; calling them
**composed words** acknowledges their true nature.

---

## 3. Composition & Spatial Plane (The Canvases)

The composition and spatial plane separates document framing and spatial layout from
domain substance:

1. **`frame` (`.frame`, formerly `.tin`)**:
   The outer HTML document envelope. A `.frame` file defines the `<head>`, charset, viewport,
   theme links, shell navigation, and footer. It speaks the template language and marks the
   insertion point for body templates with `contents`.
2. **`layout` (`.layout`, formerly `.spiff`)**:
   The spatial companion stylesheet language. A `.layout` file declares how elements sit in
   space (`horizon`, `flank`, `stack`, `grid`) using the language's own indentation grammar,
   compiling down to container queries and fluid CSS grid without runtime footprint.
3. **`style` (`.style`)**:
   The theme-role companion. A surface declares its theme roles — `measure wide`,
   `gap loose`, `density airy` — and the compiler maps them to the `:root` custom
   properties the base theme already owns. It separates *macro-layout* (`.layout`)
   from *sayable theme roles* (`.style`).
4. **`substance` (`.sp`)**:
   The route-level template that answers an HTTP request. Substance templates express domain
   knowledge and data without document boilerplate or layout scaffolding.

### Why `page` dissolves

Earlier roadmaps split the document across two canvases and argued over which one owned the
`page` word. Roadmap 0.7 dissolves the question: `page` was one word fusing two jobs — the
document envelope, and the route's subject/title declaration — which is why no single home
fitted it. The two jobs split cleanly. The `.frame` is the shell (`<!DOCTYPE html>`…`<body>`,
chrome, and the `contents` slot); the route `.sp` is a word — its filename is the word name,
its leading line the arguments — so a route is a `def` with its `def <name>` line elided and
the grammar never changes. (The word is now retired: the apps and the studio have
migrated onto the route signature, and `page` is no longer in the vocabulary.)

---

## 4. Mechanical Invariant Plane (The Instruments of Truth)

Three distinct instruments ensure architectural integrity, each operating at a different
lifecycle stage:

| Instrument | Role | Stage | Responsibility |
|---|---|---|---|
| **`contract`** | Grammar | Compile-time | Enforces syntactic bounds: what a word takes, holds, allows as children, and modifies. Checked by `check_grammar.rb` and `check_shape.rb`. |
| **`convention`** | Inference Engine | Runtime | Governs what the engine infers when an author stays silent (thirty-nine conventions across structure, shape, domain, and theme). |
| **`promise`** | Feature Ledger | Verification | Proves that every declared modifier keyword has a live, active reader in Ruby or `.sp` code (thirty-four promises). |

### The Boundary Between the Instruments

- A **contract** prevents an author from writing invalid sentences before code runs.
- A **convention** saves an author from writing tedious boilerplate while code runs.
- A **promise** guarantees that what the author writes actually executes in code.

---

## 5. Refined Multi-Axial Taxonomy & Filter Theory

Moving beyond a broad `semantic` bucket and an apologetic `visual` bucket, the vocabulary
organizes into five intuitive categories:

1. **Substance (Domain Content & Phrasing)**
   - **Typography & Phrasing**: `heading`, `paragraph`, `text`, `note`, `flash`, `prose`, `snippet`, `title`, `span`
   - **Data & Metrics**: `metric`, `fact`, `number`, `money`, `percent`, `time`, `badge`, `dictionary`, `total`
2. **Skeleton (Structure & Framing)**
   - **Landmarks**: `section`, `aside`, `nav`, `footer`
   - **Containers**: `box`, `card`, `figure`, `group`, `scroll`
   - **Collections**: `list`, `item`, `table`, `column`, `grid`, `chart`, `band`, `line`, `level`
3. **Affordances (Controls & Interactions)**
   - **Actions**: `link`, `button`, `actions`, `action`, `tabs`, `tab`
   - **Inputs**: `form`, `field`, `input`, `choice`, `option`, `search`, `checkbox`, `hidden`, `textarea`, `on`
4. **Flow & Logic (State & Behavior)**
   - **Iteration**: `each`, `empty`
   - **Branching**: `choose`, `when`, `otherwise`
   - **Disclosure**: `disclosure`
5. **Environment (Document & Splicing)**
   - **Resources**: `stylesheet`, `script`, `iframe`
   - **Splicing**: `contents`, `map`

### Bandpass Filter Diagnostic Model

Holding the sixty-three words against filter theory surfaces empirical truths:

1. **Passband Width (Filter Scope)**:
   - *Skeleton*: `26` words (40.6%) — The backbone of layout and tabular structure.
   - *Substance*: `22` words (34.4%) — The domain content, text, and numeric metrics.
   - *Affordances*: `19` words (29.7%) — Interactive controls and input fields.
   - *Flow*: `6` words (9.4%) — Tight, surgical control flow primitives.
   - *Environment*: `6` words (9.4%) — Document chrome, external assets, and slot splicing.

2. **Boundary Selectivity (Filter Attenuation)**:
   - *Environment* exhibits the sharpest selectivity (0.83), cleanly isolating document resources.
   - *Substance* maintains high selectivity (0.68), keeping domain formatting distinct from structure.
   - *Flow* and *Affordances* exhibit 0.67 and 0.63 selectivity respectively.
   - *Skeleton* exhibits 0.50 selectivity because structural containers (`card`, `table`, `form`)
     naturally house substance and affordances.

3. **Polyhierarchical Resonance**:
   Fifteen words bridge multiple categories. Rather than muddy interference, these crossovers
   represent constructive architectural resonance:
   - `card`, `table`, `chart`, `fact`, `dictionary` bridge *Skeleton* and *Substance* (containers carrying domain data).
   - `actions`, `form`, `field`, `tabs`, `group`, `nav` bridge *Skeleton* and *Affordances* (structures grouping controls).
   - `disclosure` bridges *Skeleton* and *Flow* (a container whose open state controls visibility).
   - `badge` bridges *Substance* and *Affordances* (status pill doubling as interactive filter).
   - `empty` bridges *Flow* and *Substance* (conditional flow branch speaking fallback text).

---

## 6. Synthesis

By purifying its ontology, alt-slim-pickins achieves architectural honesty:
- Templates say **what is on the page**.
- Frames provide the **outer chrome**.
- Layouts declare **spatial posture**.
- Contracts, conventions, and promises ensure **every line is true**.
