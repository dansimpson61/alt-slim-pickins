# Daytrip 0.4.0d — Volet 4: The Empirical Diagnostic Taxonomy

The language's authoring discipline and diagnostic self-examination.

---

## The brief

**Authoring pain points and diagnostic direction (2026-09-22):**

1. **Pain Point 1 (The Deductive Structure)**: A flat, unordered 64-word alphabetical
   list fails to guide top-down deductive articulation. An author building a view
   thinks in stages: *What is the structure? What does the content mean? How does
   the user interact? How does the page react and branch? How is it surfaced?*
2. **The Empirical Diagnostic Instrument**: The 5-tier taxonomy is not a rigid
   filing cabinet; it is an **empirical diagnostic test** of the language itself.
   Holding the 64 words against these tiers surfaces:
   - **What is missing**: fundamental layout axioms like `stack` (uniform vertical rhythm)
     and `cluster` (general horizontal flow).
   - **What sits well vs. awkwardly**: words that are natural linguistic concepts vs.
     words that are weirdly ad-hoc (`figcaption`, `summary` as raw HTML element leaks).
   - **Natural Porosity**: boundaries between tiers are naturally blurred; words like
     `card`, `table`, and `disclosure` legitimately belong in multiple categories.
   - **Cohesion vs. Split**: assessing whether a multi-category word represents a
     single coherent conceptual unity or an overloaded word doing multiple jobs that
     wants splitting.
   - **The Visual Tier Standard**: in a semantic DSL, words describe *what is on the page*,
     not paint. Visual presentation belongs to the theme/variant idiom. Auditing the
     vocabulary tests this standard: no primitive should exist solely as decorative paint.

---

## The question

> **How does a 5-tier deductive taxonomy serve simultaneously as a clear authoring
> guide on the Studio shelf and as an empirical diagnostic instrument that reveals the
> structural gaps, ad-hoc anomalies, and natural porosity of the language?**

---

## The five tiers

| Tier | Authoring Question | Role in View Articulation |
|---|---|---|
| **Structural** | *What is the skeleton, geometry, or layout container?* | Scaffolding, layout geometry, document landmarks, and composition slots. |
| **Semantic** | *What does this content mean or represent?* | Domain data, typography, quantitative measures, and relational information. |
| **Interactive** | *How does the user interact, input data, or trigger an action?* | Affordances, buttons, input controls, query fields, and toggles. |
| **Behavioral** | *How does the page react, branch, iterate, or submit?* | Collection iteration, conditionals, emptiness presence, and form coordination. |
| **Visual** | *How is information surfaced, framed, or styled?* | Bounded surfaces, chrome assets, viewport embeds, and status styling. |

---

## The diagnostic audit ledger (all 64 words)

Every canonical word audited for tier participation, role, cohesion vs. split, and diagnostic status:

| Word | Tiers | Primary | Role | Cohesion Assessment | Diagnostic Status |
|---|---|---|---|---|---|
| `action` | Interactive | Interactive | Single action item inside toolbar | Cohesive | Sits well |
| `actions` | Interactive, Structural, Behavioral | Interactive | Action toolbar clustering buttons and unifying multi-action submissions (R3P3) | Cohesive | Sits well |
| `aside` | Structural | Structural | Sidebar landmark region for secondary content | Cohesive | Sits well |
| `badge` | Visual, Semantic | Visual | Visual status chip with semantic state coloring | Cohesive | Sits well |
| `band` | Semantic | Semantic | Data range / confidence band in chart | Cohesive | Sits well |
| `box` | Structural, Visual | Structural | Generic layout container, surface wrapper, title host | Overloaded | **Candidate for split** |
| `button` | Interactive, Behavioral | Interactive | Clickable command trigger with formaction dispatch | Cohesive | Sits well |
| `card` | Structural, Visual, Semantic | Structural | Entity container, subject-scope shifter (R3P2), and elevated visual surface | Cohesive | Sits well |
| `chart` | Semantic, Visual | Semantic | Quantitative data visualization gathering series | Cohesive | Sits well |
| `checkbox` | Interactive, Semantic | Interactive | Boolean toggle input control inferring checked state | Cohesive | Sits well |
| `children` | Structural | Structural | Partial composition slot marker for caller block content | Cohesive | Sits well |
| `choice` | Interactive, Semantic | Interactive | Dropdown or radio selection gathering options | Cohesive | Sits well |
| `choose` | Behavioral | Behavioral | Multi-branch conditional container evaluating first truthy branch | Cohesive | Sits well |
| `column` | Semantic, Structural | Semantic | Data dimension specification registering header and formatting | Cohesive | Sits well |
| `contents` | Structural | Structural | Layout hole marker where view template splices into chrome | Cohesive | Sits well |
| `disclosure` | Interactive, Behavioral, Structural | Interactive | Collapsible details container with open/close toggle | Cohesive | Sits well |
| `each` | Behavioral, Structural | Behavioral | Collection iteration binding each element as innermost subject | Cohesive | Sits well |
| `empty` | Behavioral, Semantic | Behavioral | Names the situation: renders on empty collection, suppresses siblings | Cohesive | Sits well |
| `fact` | Semantic | Semantic | Key-value metadata pair describing attribute of subject | Cohesive | Sits well |
| `field` | Interactive, Semantic | Interactive | Intelligent form control inferring input type, label, value from subject | Cohesive | Sits well |
| `figcaption` | Semantic | Semantic | Caption text specifically nested under a figure | Single-consumer | **Ad-hoc anomaly** |
| `figure` | Semantic, Structural | Semantic | Self-contained visual illustration paired with optional caption | Cohesive | Sits well |
| `flash` | Behavioral, Semantic, Visual | Behavioral | Transient feedback state message from previous action | Cohesive | Sits well |
| `footer` | Structural | Structural | Footer landmark region for page or container metadata | Cohesive | Sits well |
| `form` | Behavioral, Interactive, Structural | Behavioral | Form submission coordinator managing action, method, input scoping | Cohesive | Sits well |
| `grid` | Structural | Structural | Multi-column 2D grid layout with column specification | Cohesive | Sits well |
| `group` | Structural, Interactive | Structural | Logical grouping container or form fieldset | Cohesive | Sits well |
| `heading` | Semantic | Semantic | Explicit semantic heading block | Cohesive | Sits well |
| `hidden` | Behavioral, Interactive | Behavioral | Silent state payload input passed through form submission | Cohesive | Sits well |
| `iframe` | Visual, Structural | Visual | Isolated foreign viewport frame embedding external HTML | Cohesive | Sits well |
| `input` | Interactive | Interactive | Bare unlabelled form input element | Cohesive | Sits well |
| `item` | Structural, Semantic | Structural | Individual element wrapper inside a list | Cohesive | Sits well |
| `level` | Semantic | Semantic | Reference threshold or tax bracket registered in chart | Cohesive | Sits well |
| `line` | Semantic | Semantic | Data trend curve registered in chart | Cohesive | Sits well |
| `link` | Interactive | Interactive | Hypertext navigation anchor pointing to destination URI | Cohesive | Sits well |
| `list` | Structural | Structural | Sequential vertical container enclosing items | Cohesive | Sits well |
| `metric` | Semantic, Visual | Semantic | Key performance indicator (KPI) pairing label with hero value | Cohesive | Sits well |
| `money` | Semantic | Semantic | Currency-formatted numeric amount with locale conventions | Cohesive | Sits well |
| `nav` | Structural, Interactive | Structural | Navigation landmark region enclosing link affordances | Cohesive | Sits well |
| `note` | Semantic, Visual | Semantic | Advisory callout or annotation with tone variant | Cohesive | Sits well |
| `number` | Semantic | Semantic | Formatted numeric value with separators and precision | Cohesive | Sits well |
| `option` | Interactive, Semantic | Interactive | Selectable value item registered within a choice control | Cohesive | Sits well |
| `otherwise` | Behavioral | Behavioral | Fallback conditional branch in choose | Cohesive | Sits well |
| `page` | Structural, Behavioral | Structural | Document root container and application context host | Cohesive | Sits well |
| `paragraph` | Semantic | Semantic | Paragraph block holding prose or sentences | Cohesive | Sits well |
| `percent` | Semantic | Semantic | Percentage-formatted ratio or fraction | Cohesive | Sits well |
| `prose` | Semantic | Semantic | Rich text block rendering markdown or formatted copy | Cohesive | Sits well |
| `script` | Visual, Interactive | Visual | Client-side script inclusion linking behavior controllers | Cohesive | Sits well |
| `scroll` | Structural, Visual | Structural | Overflow-constrained scrollable viewport container | Cohesive | Sits well |
| `search` | Interactive, Structural | Interactive | Search query input box with target destination | Cohesive | Sits well |
| `section` | Structural, Semantic | Structural | Major document region labelled by heading or subject | Cohesive | Sits well |
| `snippet` | Semantic, Visual | Semantic | Formatted code specimen with syntax display | Cohesive | Sits well |
| `span` | Semantic, Visual | Semantic | Inline phrasing run with variant styling | Styling leak | **Candidate for split** |
| `stylesheet` | Visual, Structural | Visual | Theme stylesheet inclusion linking CSS design tokens | Cohesive | Sits well |
| `summary` | Interactive, Semantic | Interactive | Summary label and toggle trigger inside disclosure | Single-consumer | **Ad-hoc anomaly** |
| `tab` | Interactive, Structural | Interactive | Clickable tab selector trigger and associated panel container | Cohesive | Sits well |
| `table` | Semantic, Structural, Behavioral | Semantic | Relational data table inferring columns, row iteration, and layout | Cohesive | Sits well |
| `tabs` | Behavioral, Structural | Behavioral | Tab group coordinator managing active tab switching state | Cohesive | Sits well |
| `text` | Semantic | Semantic | Plain text line or inline phrasing run | Cohesive | Sits well |
| `textarea` | Interactive, Semantic | Interactive | Multi-line text input control with row height and label inference | Cohesive | Sits well |
| `time` | Semantic | Semantic | Formatted timestamp, date, or relative elapsed interval | Cohesive | Sits well |
| `title` | Semantic, Structural | Semantic | Document or section heading inferring level from nesting depth | Cohesive | Sits well |
| `total` | Semantic | Semantic | Summary row aggregating or summing a table column | Cohesive | Sits well |
| `when` | Behavioral | Behavioral | Conditional branch executing when predicate holds | Cohesive | Sits well |

---

## Diagnostic findings & revelations

### 1. Missing layout primitives
- **`stack` (Primary finding)**: Vertical rhythm (uniform gap between stacked children)
  is the most common layout pattern in web authoring. Slim-Pickins currently lacks a
  dedicated `stack` primitive; authors lean on `box` or custom margins.
- **`cluster`**: Horizontal wrapping flex flow with uniform gap. Currently only available
  specialized for buttons via `actions`.
- **`sidebar`**: Two-column layout where one column has intrinsic/fixed width and the
  other fills remaining space. Currently hand-rolled across applications as `sidebar_layout`.

### 2. Ad-hoc single-consumer anomalies
- **`figcaption`**: In-degree 1 inside `figure.sp`. Exists solely because HTML has `<figcaption>`.
- **`summary`**: In-degree 1 inside `disclosure.sp`. Exists solely because HTML has `<summary>`.
- *Significance*: Both are raw HTML leaks into the kernel. This diagnostic directly validates
  **Package C (Kernel Lowering)**, where these atoms can be absorbed or lowered into `.sp` compositions.

### 3. Cohesion vs. split candidates
- **`box`**: Serves as a generic `div`, a layout container, and a title-carrier (`box_title`).
  It is overloaded and wants splitting into a layout primitive (`stack`) and a surface container.
- **`span`**: A bare inline styling hook that represents an unmodelled semantic role or variant leak.

### 4. The Visual tier standard
- In a pure semantic DSL, words describe *what is on the page*, not paint.
- The diagnostic confirms that **zero** words in the language exist solely as decorative paint.
- Primary visual words are strictly chrome/assets (`stylesheet`, `script`), isolated frames (`iframe`),
  or semantic status dressed as a pill (`badge`).

### 5. Natural porosity
- **38 words** participate in multiple tiers.
- A card is legitimately a Structural container, a Visual elevated surface, and a Semantic entity.
- A table is legitimately Semantic relational data, a Structural 2D grid, and a Behavioral implicit loop.
- Rigid single-inheritance categorization is an anti-pattern; on the Studio shelf, words appear in
  **all** relevant categories with cross-category badges.

---

## Studio & Workbench delivery

1. **`SlimPickins::Taxonomy` (`lib/slim_pickins/taxonomy.rb`)**:
   - Living SSOT for the 5 tiers, 64-word metadata, cohesion ledger, and diagnostic queries.
   - 8 unit tests in `test/taxonomy_test.rb` (1,136 assertions, 0 failures).
2. **Studio Shelf Grouping**:
   - `StudioDocs.words_by_tier(ui)` groups words by the 5 tiers with dynamic counts and authoring questions.
   - Multi-category words appear under every applicable tier, wearing a subtle badge of secondary facets.
   - Updated Workbench `library.sp` and Classic `vocabulary.sp`.
3. **Verification**:
   - All 8 status legs green live on port 4580.
   - All 31 pages verified green across all apps and studio UIs.
   - 384 tests passing with 5,340 assertions.
