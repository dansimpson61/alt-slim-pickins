# alt-slim-pickins — Wishlist, Loose Ends & Flights of Imagination

> **The forward horizon.** A living ledger of unresolved technical pinches,
> author ergonomics, desired capabilities, architectural horizons, and bluesky
> flights of imagination. Consulted whenever planning a roadmap or daytrip to
> ensure known seams and creative possibilities are remembered and weighed rather
> than lost.

---

## The Standing Protocol: How We Consult & Maintain This Document

1. **At Roadmap Conception:**
   When framing a new roadmap (especially odd-numbered forward-eye roadmaps),
   review Section V (Bluesky), Section II (Architecture & Library), and
   Section III (Pedagogy & Repo). Pull mature ideas or structural questions
   into roadmap criteria.
2. **At Daytrip Planning:**
   Before locking the scope of a daytrip, review Section I (Loose Ends) and
   Section IV (Aesthetics & Workbench) to check whether the files or subsystems
   being touched harbor an adjacent pinch that can be cleanly resolved in stride.
3. **During Active Sessions (Continuous Intake):**
   When an experiment, refactor, or user interaction reveals a design friction,
   an unanswered question, or an inspired "what if" that is out of immediate scope:
   do not leave it trapped in an ephemeral chat or buried in a closed log.
   Record it here under the appropriate section with date, origin, and concrete shape.
4. **At Roadmap Close (Retrospective Intake):**
   At the close of each roadmap, systematically ask whether we have anything to
   add to the wishlist. Review deferred ideas, compromises made during execution,
   or newly discovered possibilities and log them here before moving to the next phase.
5. **Graduation & Retirement:**
   - **Graduated:** When an item ships in a daytrip, mark it `[x]`, link the
     commit or `DAYTRIP-*.md`, and record what was decided.
   - **Retired:** When an item is formally rejected by Dan or superseded by a
     simpler Ruby idiom, move it to the *Retired* subsection with Dan's ruling
     and the rationale.

---

## I. Loose Ends & Technical Pinches (The Pinch Ledger)

Unsettled details, known edge-case collisions, and mechanical seams identified
during prior roadmaps and daytrips.

- [ ] **Context-Sensitive `actions` ("Where a word sits chooses its form"):**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (Pinch & What-if 1), 2026-10-04.
  - *Symptom:* `actions` (`lib/vocabulary/actions.sp`) unconditionally opens its own
    `<form method="post">`. When placed inside a `<form>`, it emits an invalid nested
    `<form>` in the DOM (`milestone_planner`'s "Add Task" button posts to `/milestones/m1`
    instead of `/milestones/m1/tasks`).
  - *Desired shape:* Inside an enclosing form, `actions` renders a container for buttons
    (`<div class="actions">`); outside an enclosing form, it renders its own posting form.
    Matches the existing precedent of `button` and `group`.

- [ ] **`link` Syntax Duality (Roadmap 0.5 Criterion 7, Item 1):**
  - *Origin:* `ROADMAP-0.5.md` (Criterion 7, open question 1); `examples/portfolio/`.
  - *Symptom:* The word `link` supports conflicting spellings: positional subject/destination
    (`link show, "Details", to: "/path"`), name-inferred href (`link shelf`), and bare
    label/target (`link "Overview", to: "/"`). At least one app uses multiple variants
    internally without a settled canonical convention.
  - *Desired shape:* Settle whether `link` has a single unified signature or two distinct
    idiomatic forms, and align the vocabulary and examples.

- [ ] **Two Sentence-Parsing Fixes (Roadmap 0.5 Criterion 7, Item 3):**
  - *Origin:* `ROADMAP-0.5.md` (Criterion 7, open question 3); withdrawn design in 0.4.0p.
  - *Symptom:* Two parser edge cases were identified:
    1. How a bare name gets looked up in argument expressions.
    2. What expressions and escapes are allowed inside quoted string interpolations.
    Both were argued for and marked "decided" in a document rejected for compiler-bookkeeping,
    so Dan has not separately confirmed whether either fix survives on its own merits.
  - *Desired shape:* Re-evaluate each parser fix individually under the Ode's simplicity test,
    ensuring authors don't mind the compiler while sentence parsing remains robust.

- [ ] **Landing Evaluation for Sentence Arguments (`page document, .title`):**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (Pinch & What-if 2); `lore_reader`.
  - *Symptom:* `page document, .title` raises `this page has no title` because dotted
    arguments (`.title`) evaluate against the *enclosing* subject before the sentence
    shifts to its new subject target (`document`). Authors currently resort to Ruby
    escapes (`page document, document.title`).
  - *Desired shape:* A sentence's arguments evaluate where the sentence lands, allowing
    `page document, .title` and `section accounts, .name` to resolve naturally.

- [ ] **Class Derivation Decoupled from Subject Attribute Collision:**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (Pinch & What-if 3); Lore entry 8.
  - *Symptom:* In `section users`, the element loses its `section--users` CSS modifier class
    whenever the active subject also happens to answer `#users`. This occurs because
    name parameters currently double as attribute lookups.
  - *Desired shape:* An emitted class should derive from what the template *said*, not
    from what the underlying model happens to respond to.

- [ ] **Object Identity for DOM IDs:**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (What-if 4).
  - *Symptom:* Generated element IDs currently follow the local variable binding name
    (e.g. `document-primer` on `document.sp` becomes `result-primer` on `search.sp`),
    causing the same entity to wear different DOM IDs across pages.
  - *Desired shape:* Element IDs derive from the domain object's intrinsic model identity
    or class, remaining stable across views.

- [ ] **Heading Depth Level Gaps:**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (Pinch & What-if 6).
  - *Symptom:* Metric labels render as `<h3>` with no preceding `<h2>` on several pages.
    While heading depth is calculated from nesting depth, nothing prevents skipping levels
    in the semantic outline.
  - *Desired shape:* Heading level calculation ensures semantic hierarchy without skipping.

- [ ] **Collection-Scoped Emptiness:**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (Pinch & What-if 7).
  - *Symptom:* When a page's root subject is an empty collection, the current pruning
    mechanism blanks the entire page, including sibling sections that discuss other
    attributes.
  - *Desired shape:* Emptiness prunes content scoped to the empty collection, not the
    entire page frame.

- [ ] **Entity Routing Helper Primitive:**
  - *Origin:* `history/CHRONICLE.md`, Phase 6.
  - *Symptom:* `link show` derives `/show` rather than the entity's actual resource path
    (`/accounts/:id`), requiring manual string interpolation.
  - *Desired shape:* A humane routing convention or entity path resolution helper that
    avoids hardcoded string templates in template links.

- [ ] **Date Formatting Register Discrepancy:**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (Register pinch).
  - *Symptom:* Dates in table cells are formatted automatically via `Inference.moment`,
    but `CONVENTIONS.md` registered only "number, percent or money". The documentation
    register understates runtime behavior.
  - *Desired shape:* Formalize and register date/moment formatting in conventions.

---

## II. Architecture, Library & Language Horizons

Structural definitions, engine boundaries, and library interfaces that establish
what slim-pickins is as a coherent software system.

- [ ] **Defining the Slim-Pickins MVP (Core Language Specification):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Slim-pickins has grown organically through phases and daytrips, but lacks
    a definitive statement of what constitutes a complete `sp` MVP / 1.0.
  - *Wish:* Formalize what belongs in the core MVP:
    1. Essential vocabulary elements (containers, text/data leaves, controls, structures).
    2. Fundamental runtime behaviors and inference guarantees (data-flow routing, subject shifts).
    3. Theming facility and design token baseline.
    4. Essential layout primitives.
    Differentiate what is core language versus what belongs in app-space or domain extensions.

- [ ] **Library vs. Development Project Structure (Clean, Lean Gemification):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* The repository currently mixes the engine (`lib/slim_pickins`), the canonical
    vocabulary (`lib/vocabulary`), the test/gate harnesses (`check_*.rb`), the development
    studio (`studio/`), and eight example applications (`examples/`).
  - *Wish:* Clearly delineate `slim_pickins` as a standalone, distributable library/gem
    versus the surrounding development project. Ensure the core library is clean, lean,
    strictly scoped, and readily gemifiable without coupling to dev harnesses.

- [ ] **Adapter Pattern for Pluggable Backends (Library-Agnostic Extensions):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Certain features currently rely on bespoke implementations or hardcoded
    helpers (e.g. chart rendering, markdown parsing via Redcarpet/Kramdown, syntax highlighting).
  - *Wish:* Establish an adapter pattern that preserves a consistent, declarative `.sp`
    vocabulary interface (e.g. `chart`, `markdown`, `code`) while making the underlying
    engine swappable and impartial. An author writes pure `.sp`; the host application
    supplies or configures the rendering adapter.

- [ ] **Database Frontend & Authentic CRUD Example Application:**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Existing example apps primarily display in-memory fixtures or read-only models.
    Is a database frontend already fully consistent with what we have built, or does it
    introduce unconsidered seams in form handling, validation states, and data mutations?
  - *Wish:* Build at least one authentic CRUD application in our examples (backed by SQLite
    and a lightweight Ruby persistence layer) demonstrating create, read, update, delete,
    form submissions, mutation handling, validation error feedback, and flash messages in
    idiomatic `.sp`.

- [ ] **The "Rubinius" Vision — Writing `sp` in `sp` to the Practical Limit:**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Rubinius proved the elegance of self-hosting by implementing Ruby in Ruby.
    Slim-pickins proved the first stage of this by migrating 23 canonical vocabulary words
    from Ruby primitives into `.sp` partials with `def`.
  - *Wish:* Continually investigate and push the boundary of self-hosting:
    How much of the studio (inspect views, error reporting, docs renderer), the debug
    tooling, and even internal AST/representation inspectors can be authored purely as `.sp`?

- [ ] **Untangling the Dual Nature of "Variant" (Roadmap 0.5 Criterion 7, Item 2):**
  - *Origin:* `ROADMAP-0.5.md` (Criterion 7, open question 2).
  - *Concept:* "Variant" currently conflates two distinct concerns:
    1. Author-chosen stylistic weight (e.g. `button primary`, `note quiet`).
    2. Data-driven status derived automatically from models (e.g. `badge status`
       rendering red for `blocker` or green for `canonical`).
  - *Wish:* Distinct semantic models so presentational options and data-derived states
    do not collide in the modifier slot.

- [ ] **Systematic Audit of Container Value Inheritance (Roadmap 0.5 Criterion 7, Item 4):**
  - *Origin:* `ROADMAP-0.5.md` (Criterion 7, open question 4).
  - *Concept:* Words missing values look up to enclosing words via `chain.container_value`.
  - *Wish:* Review how container inheritance interacts with nearest-first lexical scoping
    now that Option A/B1 and family scoping have landed.

- [ ] **Standardizing Domain Contract Declarations (`labels`, `formats`):**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (DRY & OOP shape).
  - *Concept:* `doc_reader` declares display contracts on domain classes (`labels`,
    `formats`) rather than per-instance fixtures.
  - *Wish:* Establish a clean, shared house standard for domain model presentation
    contracts across all example apps.

---

## III. Pedagogy, Terminology & Repository Health

How the project presents itself, names its concepts, organizes its artifacts, and teaches
authors to think in slim-pickins.

- [ ] **Terminology Audit & Systematization:**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Terminology has accumulated haphazardly across different development eras:
    `built-ins`, `partials`, `.sp`, `defs`, `tin`, `spiff`, `contracts`, `primitives`,
    `words`. Document names (`PRIMER.md`, `CONVENTIONS.md`, `VOCABULARY.md`, `SPEC.md`,
    `KERNEL.md`) reflect past phases rather than a coherent conceptual taxonomy.
  - *Wish:* Conduct a thorough terminology audit. Establish unified, precise definitions
    that reflect current architecture and intent, clearing out stale jargon and contradictory
    labels.

- [ ] **Project Identity: Dropping `alt-` and Consolidating `slim-pickins`:**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* The repository is still named `alt-slim-pickins`, reflecting its historical
    origin as an alternative spike to an earlier prototype in `~/dev/slim-pickins`.
    The "alternative" has become the canonical engine.
  - *Wish:* Drop the `alt-` prefix from the project; archive or delete the obsolete earlier
    versions of `slim-pickins` across `~/dev`, leaving one clean, authoritative repository.

- [ ] **Repository Cleanup & Historical Artifact Stowing:**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* The root directory is crowded with dozens of historical planning files,
    past daytrips (`DAYTRIP-*.md`), audit notes, and scratch artifacts.
  - *Wish:* Stow historical daytrips and planning artifacts into clean archive directories
    (e.g. `history/daytrips/`, `history/planning/`). Cleanly organize `examples/` and
    `studio/` (classic vs workbench). A tidy repository layout makes it much easier to
    see what is current, what needs modernizing, and what should be retired.

- [ ] **Pedagogy from First Principles (Teaching the Way of Slim-Pickins):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Our documentation currently suffers from being written by compiler developers
    for compiler developers—dense with historical development context, shorthand, and
    internal mechanisms.
  - *Wish:* Greatly improve pedagogy:
    1. Define what *good pedagogy* is for slim-pickins.
    2. Show significantly more actual written `.sp`.
    3. Demonstrate idiomatic structure: short, outline-like pages calling short, focused
       word `def`s.
    4. Rewrite pedagogical materials from the author's viewpoint, stripping away historical
       justifications, compiler mechanics, and obsolete jargon.

---

## IV. Aesthetics, Examples & Workbench

Visual quality, diversity of design, and the developer environment.

- [ ] **Aesthetic Diversity in Showcase Apps (Distinct Visual Expressions):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Several existing example apps look similar or plain, giving the impression
    that slim-pickins only produces one visual flavor.
  - *Wish:* Create example apps that look genuinely exceptional, and look exceptional in
    *different* ways:
    - Editorial prose and reading interfaces (refined typography, generous measure).
    - Dense analytical dashboards (metrics, tables, compact data grids).
    - Focused transactional tools (clean form ergonomics, crisp feedback).
    Demonstrate that the theme engine and CSS architecture support diverse, beautiful designs.

- [ ] **Retiring or Modernizing Dated Example Apps:**
  - *Origin:* `ROADMAP-0.5.md` (Criterion 4, bullet 2); Dan (2026-10-12).
  - *Concept:* Eight example apps exist, several written when slim-pickins was much less
    evolved (`way_exam`, `word_graph`, `milestone_planner`).
  - *Wish:* Audit the example apps in tandem with the repo cleanup; retire or modernize
    those that no longer carry their weight or fail to showcase current conventions cleanly.

- [ ] **Studio Editor Gutter & Inline Diagnostics:**
  - *Origin:* `BLUESKY.md` (Part 1, point 4).
  - *Concept:* The Studio editor is currently a plain `textarea`. While the compiler
    knows the exact line and sentence of every failure, errors only surface in the
    rendered preview pane three columns away.
  - *Wish:* A line-numbered gutter with inline failure indicators pointing directly to
    the offending line in the editor buffer.

- [ ] **Content-Aware Workbench Pane Sizing:**
  - *Origin:* `BLUESKY.md` (Part 1, points 1–2).
  - *Concept:* The Studio layout splits panes by rigid fractions (`1fr 1fr`), forcing
    narrow letterbox previews while leaving other areas awkward.
  - *Wish:* Content-aware sizing or flexible split thresholds so large source templates,
    diffs, and rendered documents receive space appropriate to their content.

---

## V. Bluesky & Flights of Imagination (The Forward Eye)

Expansive architectural visions, speculative designs, and paradigm shifts.

- [ ] **Making the Theme Sayable (A Style DSL Without Machine Bloat):**
  - *Origin:* `BLUESKY.md` (Part 3).
  - *Vision:* Slim-pickins has 62 canonical words for *what* and 53 theme CSS variables
    in `:root` for *how it looks*, but the two cannot speak to each other.
  - *Flight:* Allow templates to express high-level design intents that map directly
    to semantic theme roles (`measure: wide`, `gap: loose`, `emphasis: quiet`), verified
    by `check_styles.rb` so every page role exists in `:root` and every `:root` role is
    reachable—without descending into utility-class noise (`text-sm`, `p-4`).

- [ ] **Seeing the State: Visualizing the Inference Engine (Bret Victor / Moldable Development):**
  - *Origin:* `BLUESKY.md` (Part 2, Bret Victor / Tudor Gîrba).
  - *Vision:* The language performs sophisticated inference (data flow, subject shifts,
    conventions, formatting, tin wrapping). Today, all of that magic is invisible—you
    see the input and the final HTML, but not the reasoning in between.
  - *Flight:* An interactive "Inference Inspector" pane in the Studio that visually maps
    the subject chain, reveals inferred labels and formatting decisions, and traces
    container value propagation live as code is typed.

- [ ] **Intrinsic Responsive Layout Primitives (Every Layout in the DSL):**
  - *Origin:* `BLUESKY.md` (Part 2, Every Layout).
  - *Vision:* Breakpoints are manual overrides. True responsive design flows from
    container-intrinsic primitives (Stack, Switcher, Cluster).
  - *Flight:* Vocabulary words for responsive layout composition (e.g. `switcher` that
    automatically flips between row and column based on container measure threshold),
    freeing template authors from writing bespoke viewport media queries.

- [ ] **Self-Titling & Content-Aware Documents:**
  - *Origin:* `examples/doc_reader/WHAT_IF.md` (What-if 5).
  - *Vision:* In prose-heavy documents, the template author often writes `page document, "Title"`
    and then immediately includes markdown whose first line is `# Title`, resulting in
    redundant declarations or double headings.
  - *Flight:* When a document's body begins with a heading, `page` automatically adopts
    that heading as its title and suppresses the duplicate prose heading.

- [ ] **Modular Component Tins (Localized Framing):**
  - *Origin:* Discussion in Daytrip 0.4.0q / 0.5.0a.
  - *Vision:* Currently `[app].tin` provides chrome for whole pages. What if complex
    sub-assemblies or widgets could wear localized frames or wrappers using the same
    modest tin concept?

---

## VI. Retired or Graduated Items

- [x] **Shadowing Built-in Language Words (Dan's 2026-10-05 Ruling):**
  - *Graduated in:* `DAYTRIP-0.5.0e.md` (Commit `536684e`).
  - *Resolution:* App partials and Ruby words may shadow language built-in words within
    their owning library family. The gate reports shadowed words under vitals; Studio
    isolates multi-app playground libraries. Portfolio's `account_card` successfully
    became plain `card`.
- [x] **Retire Legacy `expects` Declaration Line:**
  - *Graduated in:* `DAYTRIP-0.5.0d.md` (Commit `81b2a9d`).
  - *Resolution:* All 28 `.sp` partials across the repository migrated to `def <word>, *params`
    with Option B1 Data-Flow Inference and Option A Lexical Scope.
