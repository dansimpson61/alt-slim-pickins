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
6. **At Roadmap Conception (Framing the Stretch Exam):**
   - For **odd-numbered (forward-eye) roadmaps**, select the next **Stretch Exam** (`docs/STRETCH_PROTOCOL.md`) by pulling mature pinches from Section I, architectural goals from Section II, and aesthetic targets from Section IV into a single authentic reference application drafted on paper first.
   - For **even-numbered (backward-eye) roadmaps**, review Section III (Pedagogy & Repo) and audit the `examples/` garden to harvest generalizable words from the last Stretch Exam and retire dated prototype apps that no longer carry their weight.
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

- [ ] **App-Specific Ruby Words (`app-words.rb` / Authoring Words in Ruby):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Today, authors can define application-specific words in `.sp` partials
    via `def`, but defining first-class words in Ruby requires either writing into
    the core language (`lib/slim_pickins/words.rb`) or using an informal Ruby mixin module.
  - *Wish:* A first-class facility allowing authors to write words directly in Ruby scoped
    to an application (e.g. an app-specific `words.rb` or `[app]/words.rb`), complementing
    `.sp` partials with full Ruby capabilities, explicit contracts, and family nesting—without
    needing to modify the core library.

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

- [ ] **Polysemy & Overloaded Terms Audit (Disambiguating Words with Multiple Roles):**
  - *Origin:* Dan (Wishlist Intake & Roadmap 0.6 framing, 2026-10-12).
  - *Concept:* Key terms in slim-pickins are heavily overloaded, serving two, three, or four
    distinct jobs across the `.sp` language itself, the compiler internals, the stylesheet/design
    idiom, and the pedagogical documentation. This polysemy creates subtle cognitive friction
    for authors and readers alike.
  - *Examples identified for audit:*
    1. **`variant`**:
       - *Job A (Styling choice):* An author-chosen stylistic or weight modifier (e.g. `button primary`, `note quiet`).
       - *Job B (Data-driven status):* A status or tone derived automatically from domain models (e.g. `badge status` turning red for `danger`).
       - *Job C (Grammar/Contract):* A formal sentence slot name (`name_slot = :variant`).
       - *Job D (CSS/Spiff):* CSS typography property (`font-variant-numeric: tabular-nums`).
    2. **`children`**:
       - *Job A (Template word):* The language word/keyword that renders the yielded block/children of a partial or wrapper (equivalent to Ruby's `yield` or web components' `<slot>`).
       - *Job B (AST structure):* The node list of nested child nodes on `SlimPickins::Node[:word, :attributes, :children]`.
       - *Job C (Contract slot):* `contract.children` (:any | :none | list of allowed nested words).
       - *Job D (Family containment):* Contained child words nesting lexically inside parent words (`Table::Column`, `item` in `list.sp`).
       - *Job E (DOM):* Rendered HTML element children.
    3. **`content`**:
       - *Job A (Slot):* The positional inline text/payload argument (`tag p, .content`, `badge .label`).
       - *Job B (Contract):* The boolean flag `contract.content` indicating whether a word accepts inline content.
       - *Job C (Domain model):* An entity's text or markdown body (`document.content`).
       - *Job D (CSS/Spiff):* CSS rules such as `display: contents` or generated content `content: ""`.
    4. **`subject`**:
       - *Job A (Target record):* The domain model or record an author passes to frame a page or card (`page document`, `card account`).
       - *Job B (Evaluation context):* The active evaluation receiver in `Builder#subject` where `.attribute` calls resolve.
       - *Job C (Slot):* The positional parameter slot in contracts and signatures.
    5. **`name`**:
       - *Job A (Word identifier):* The symbol identifying a word in the registry (`Word.name`).
       - *Job B (Sentence slot):* The bare identifier slot in a sentence (`word name, ...`).
       - *Job C (HTML input attribute):* `<input name="...">` or `<button name="...">` parameter.
       - *Job D (Domain model attribute):* A record's `#name` attribute (`account.name`), which collides with slot names.
    6. **`word` vs. `primitive` vs. `partial` vs. `built-in` vs. `tag` vs. `app word` vs. `def` vs. `tin` vs. `spiff`**:
       - "Everything is a word" is the grammatical foundation, yet docs and code switch between
         "primitives", "partials", "built-in words", "canonical words", and "app words" without a single shared conceptual model.
       - `tin` names the application frame/chrome (`[app].tin`), while `spiff` names the spatial companion
         stylesheet language (`[app].spiff`, `SlimPickins::Spiff`, `docs/SPIFF.md`). Both sit beside `.sp` files,
         but their conceptual boundaries and relationship to words, layout primitives, and theme roles need a
         unified taxonomy.
    7. **`body`**:
       - An indented block nested beneath a word vs. HTML `<body>` element vs. domain model attribute (`document.body`).
    8. **`parent` / `parents`**:
       - Lexical/family class namespace (`Table` is parent of `Column`) vs. AST container in container-value lookup vs. DOM parent node.
  - *Wish:* Perform a comprehensive audit across the language grammar, compiler symbols, and documentation to
    catalog every overloaded term. Establish clear, unambiguous names and conceptual distinctions so docs and
    pedagogy never use the same word for two different ideas.

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

- [ ] **Capabilities for Micro-Layout and Component-Level Styling:**
  - *Origin:* Dan (Session 2026-10-14, evaluating `actions`, `cluster`, and taxonomy `MISSING_PRIMITIVES`).
  - *Concept:* Today, macro-layout across major application zones is cleanly governed by
    Spiff (`horizon`, `flank`, `stack`), while micro-layout within components (inline horizontal
    wrapping flex flows, tags, badge clusters, button bars, compact rhythm) lacks a declarative
    vocabulary. Authors currently rely on hardcoded CSS classes (`.actions`, `.card`, custom rules)
    or unopinionated `.box`. The taxonomy previously diagnosed `stack`, `cluster`, and `sidebar`
    as missing template primitives; however, geometry and scaffolding belong outside the substance
    template language.
  - *Wish:* Develop first-class capabilities for micro-layout and component styling—whether as an
    extension of Spiff (enabling Spiff to reach inside components/zones or govern micro-rhythm)
    or another intermediation/abstraction of CSS that preserves the core principle ("templates declare
    substance; styling remains an unpolluted abstraction"). Consider the patterns diagnosed by
    `MISSING_PRIMITIVES` (`stack` vertical flow, `cluster` inline flex wrapping, `sidebar` intrinsic
    two-element flow) when designing layout and styling abstractions rather than littering `.sp`
    templates with geometric scaffolding like `<div class="sp-cluster">`.

- [ ] **Bandpass Filter Analysis of Vocabulary Taxonomy:**
  - *Origin:* Dan (Session 2026-10-14, revisiting taxonomy).
  - *Concept:* The 5-tier authoring taxonomy (`structural`, `semantic`, `interactive`, `behavioral`,
    `visual`) was formulated off the top of the head for pedagogy and presentation. To evolve
    it into an analytical instrument that helps resolve stretched or unexpressed concepts, treat
    each category as a bandpass filter.
  - *Wish:* Assess each tier through filter theory:
    1. *Passband (Scope & Width)*: What range of concepts does each tier naturally admit? Where are
       the cutoffs?
    2. *Selectivity (Boundary Strictness & Attenuation)*: How sharply does a tier reject non-qualifying
       words? Where is the boundary fuzzy?
    3. *Crossover, Overlap & Polyhierarchy*: Where do two passbands legitimately overlap (such as
       `form`, `disclosure`, `card`, `actions`), and is the crossover a constructive resonant frequency
       or muddy interference?
    Use this analysis to resolve stretched or unexpressed concepts and formulate a refined, multi-axial
    taxonomy.

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
