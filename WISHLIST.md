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
3. **During Active Sessions & Housekeeping Passes (Continuous Intake):**
   When an experiment, refactor, or user interaction reveals a design friction,
   an unanswered question, or an inspired "what if" that is out of immediate scope:
   do not leave it trapped in an ephemeral chat or buried in a closed log.
   In the housekeeping pass of every daytrip/session, review and propose/ask for new
   wishlist items, recording them here under the appropriate section with date,
   origin, and concrete shape.
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

- [ ] **First-Class Studio Previewing for Composed-Word Definitions (`def` files):**
  - *Origin:* Daytrip 0.8.0d (2026-10-20).
  - *Symptom:* When a `.sp` template file consists solely of a `def <word>` block (such as vocabulary definitions or extracted modular partials), previewing it in Studio or testing it via `studio_pages_test.rb` renders an empty `<div class="sp-canvas"></div>` because executing the template merely registers the word in the local compiler rather than invoking it.
  - *Desired shape:* Studio playground and inspector should recognize when a file's top-level body is an uncalled `def`, automatically rendering an interactive preview by instantiating the defined word with sample/default context.

- [ ] **Contract Inference for Composed App Words with Flexible Arguments:**
  - *Origin:* Daytrip 0.8.0d (2026-10-20).
  - *Symptom:* App-defined words (`examples/*/views/partials/*.sp`) currently rely on looser positional/keyword bindings without rigid shape enforcement in `infer_from_def`. Attempting to enforce canonical vocabulary contracts across app partials broke argument flexibility in `disk_def_partial_test.rb`.
  - *Desired shape:* Generalize `VocabularyShapes#infer_from_def` to provide rich contract checking and provenance inspection for app-level words without constraining author flexibility in argument passing.

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

- [ ] **Class Derivation Decoupled from Subject Attribute Collision:**
  - *Origin:* `examples/publication/WHAT_IF.md` (Pinch & What-if 3); Lore entry 8.
  - *Symptom:* In `section users`, the element loses its `section--users` CSS modifier class
    whenever the active subject also happens to answer `#users`. This occurs because
    name parameters currently double as attribute lookups.
  - *Desired shape:* An emitted class should derive from what the template *said*, not
    from what the underlying model happens to respond to.

- [ ] **Object Identity for DOM IDs:**
  - *Origin:* `examples/publication/WHAT_IF.md` (What-if 4).
  - *Symptom:* Generated element IDs currently follow the local variable binding name
    (e.g. `document-primer` on `document.sp` becomes `result-primer` on `search.sp`),
    causing the same entity to wear different DOM IDs across pages.
  - *Desired shape:* Element IDs derive from the domain object's intrinsic model identity
    or class, remaining stable across views.

- [ ] **Heading Depth Level Gaps (Targeted in Roadmap 0.8):**
  - *Origin:* `examples/publication/WHAT_IF.md` (Pinch & What-if 6).
  - *Symptom:* Metric labels render as `<h3>` with no preceding `<h2>` on several pages because
    `metric.sp` hardcodes `tag h3, .label, class: "metric-label"` instead of participating in
    `Generator#heading`'s `@box_level` depth convention.
  - *Desired shape:* Heading level calculation ensures semantic hierarchy without skipping.

- [ ] **Collection-Scoped Emptiness (Targeted in Roadmap 0.8 for 0.9 CRUD):**
  - *Origin:* `examples/publication/WHAT_IF.md` (Pinch & What-if 7).
  - *Symptom:* When a page's or section's subject is an empty collection, `Builder#prune`
    removes all non-`empty` children, which blanks sibling creation forms or toolbars on an
    empty CRUD index.
  - *Desired shape:* Emptiness prunes content scoped to the empty collection's iteration
    container, not sibling forms or sections.

- [ ] **Entity Routing Helper Primitive:**
  - *Origin:* `history/CHRONICLE.md`, Phase 6.
  - *Symptom:* `link show` derives `/show` rather than the entity's actual resource path
    (`/accounts/:id`), requiring manual string interpolation.
  - *Desired shape:* A humane routing convention or entity path resolution helper that
    avoids hardcoded string templates in template links.

---

## II. Architecture, Library & Language Horizons

Structural definitions, engine boundaries, and library interfaces that establish
what slim-pickins is as a coherent software system.

- [ ] **The Role of Verbs in `sp` (Domain Actions, Mutations & State Transitions):**
  - *Origin:* Dan (Roadmap 0.8 framing, 2026-10-19).
  - *Concept:* Today, the language's vocabulary is overwhelmingly nominal (`speech: :noun`).
    Only four words are classified as verbs (`choose`, `map`, `submit`, `reset`) — two
    control-flow directives and two HTML `<button type>` words — while `action` and `button`
    are classified as nouns. Yet in interactive applications and state machines, a domain
    subject is defined not only by the attributes it *has* (nouns), but by the operations
    and state transitions it *permits* (`archive`, `rebalance`, `transfer`, `close`, `approve`).
  - *Wish:* Explore a first-class place for **verbs** in `sp` — keeping the ontological
    boundary crisp (**nouns declare substance on the page; verbs declare transitions or
    intentions on the subject**). Consider how a verb sentence against the active subject
    can infer its target route, HTTP method, confirmation prompt, or availability from the
    domain object's contract without forcing authors to hand-wire forms and URLs.

- [ ] **Seamless, Joyfully JS-Free Interactivity (Declarative Client Behavior Under the Hood):**
  - *Origin:* Dan (Roadmap 0.8 framing, 2026-10-19).
  - *Concept:* House rule: *"The best JavaScript is the least JavaScript. Ruby > CSS >
    Stimulus > custom JS, in that order of reach."* Native HTML and CSS carry remarkable
    weight on their own (`<details>` for `disclosure`, radio inputs for `tabs`, container
    queries for `.layout`), and when an interaction finally reaches the limits of plain
    HTML/CSS (live recalculation in `roth`, auto-submitting workbench editors in `studio`,
    partial zone refreshes, debounced search, inline confirmation), apps currently fall
    back to bespoke per-app `public/js/app.js` scripts with hardcoded DOM selectors.
  - *Wish:* Abstract client-side interactivity (such as a compact set of Stimulus controllers
    shipped with the engine) seamlessly behind `sp` words and modifiers. The generator
    emits the `data-controller` / `data-action` / `data-target` attributes automatically,
    so `.sp` views remain 100% joyfully JS-free while gaining live partial updates,
    debounced inputs, and declarative transitions without custom JavaScript.

- [ ] **Database Frontend & Authentic CRUD Example Application (`examples/portfolio` in Roadmap 0.9):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12; target selected 2026-10-19).
  - *Concept:* Existing example apps primarily display in-memory fixtures or read-only models.
    Upgrading `examples/portfolio` into a SQLite-backed CRUD application tests relational
    mutations (`Account` → `Holding` / `Contribution`) alongside quantitative tables, totals,
    metrics, and formatting.
  - *Wish:* Build Roadmap 0.9's authentic CRUD Stretch Exam in `examples/portfolio` (backed by
    SQLite and a lightweight Ruby persistence layer) demonstrating create, read, update, delete,
    form submissions, validation error feedback (`422`), empty states, and flash messages in
    idiomatic `.sp`.

- [ ] **Standardizing Domain Contract Declarations (`SlimPickins::Described`, Targeted in Roadmap 0.8):**
  - *Origin:* `examples/publication/WHAT_IF.md` (DRY & OOP shape); `examples/publication/lib/shelf.rb`.
  - *Concept:* `publication` declares display contracts on domain classes (`labels`, `formats`)
    via `SlimPickins::Described` rather than per-instance `Fixtures.labelled` singleton methods.
  - *Wish:* Promote `SlimPickins::Described` to `lib/slim_pickins/` in Roadmap 0.8 and adopt
    it as the shared house standard across all kept example apps.

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

- [ ] **Adapter Pattern for Pluggable Backends (Library-Agnostic Extensions):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Certain features currently rely on bespoke implementations or hardcoded
    helpers (e.g. chart rendering, markdown parsing, syntax highlighting).
  - *Wish:* Establish an adapter pattern that preserves a consistent, declarative `.sp`
    vocabulary interface (e.g. `chart`, `prose`, `snippet`) while making the underlying
    engine swappable and impartial. An author writes pure `.sp`; the host application
    supplies or configures the rendering adapter.

- [ ] **The "Rubinius" Vision — Writing `sp` in `sp` to the Practical Limit:**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Rubinius proved the elegance of self-hosting by implementing Ruby in Ruby.
    Slim-pickins proved the first stage of this by migrating 24 canonical vocabulary words
    from Ruby primitives into `.sp` composed words with `def`.
  - *Wish:* Continually investigate and push the boundary of self-hosting:
    How much of the studio (inspect views, error reporting, docs renderer), the debug
    tooling, and even internal AST/representation inspectors can be authored purely as `.sp`?

- [ ] **Systematic Audit of Container Value Inheritance (Roadmap 0.5 Criterion 7, Item 4):**
  - *Origin:* `ROADMAP-0.5.md` (Criterion 7, open question 4).
  - *Concept:* Words missing values look up to enclosing words via `chain.container_value`.
  - *Wish:* Review how container inheritance interacts with nearest-first lexical scoping
    now that Option A/B1 and family scoping have landed.

- [ ] **App-Specific Ruby Words (`app-words.rb` / Authoring Words in Ruby):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Today, authors can define application-specific words in `.sp` composed words
    via `def`, but defining first-class words in Ruby requires either writing into
    the core language (`lib/slim_pickins/words.rb`) or using an informal Ruby mixin module.
  - *Wish:* A first-class facility allowing authors to write words directly in Ruby scoped
    to an application (e.g. an app-specific `words.rb` or `[app]/words.rb`), complementing
    `.sp` composed words with full Ruby capabilities, explicit contracts, and family nesting—without
    needing to modify the core library.

---

## III. Pedagogy, Terminology & Repository Health

How the project presents itself, names its concepts, organizes its artifacts, and teaches
authors to think in slim-pickins.

> **Graduated:** the terminology audit, polysemy audit, and first-principles pedagogy
> rewrite closed with Roadmap 0.6 — see Section VI.

- [ ] **Project Identity: Dropping `alt-` and Consolidating `slim-pickins`:**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* The repository is still named `alt-slim-pickins`, reflecting its historical
    origin as an alternative spike to an earlier prototype in `~/dev/slim-pickins`.
    The "alternative" has become the canonical engine.
  - *Wish:* Drop the `alt-` prefix from the project; archive or delete the obsolete earlier
    versions of `slim-pickins` across `~/dev`, leaving one clean, authoritative repository.

- [ ] **Stowing Remaining Planning & Study Artifacts (Targeted in Roadmap 0.8):**
  - *Origin:* Dan (Roadmap 0.8 framing, 2026-10-19).
  - *Concept:* While past daytrips and roadmaps were stowed in `history/` during 0.6.0g and
    0.7 close, several dated planning/study documents (`KERNEL.md`, `ON_PAPER.md`, `WHAT_IF.md`,
    `INVENTORY.md`, `ROTH_DOMAIN_BACKLOG.md`, `ROTH_STUDY.md`) and a stray `word_graph.html`
    still sit in the working directories.
  - *Wish:* Stow historical study/planning docs into `history/` and keep only live reference
    and pedagogical documents in `docs/` and `examples/`.

---

## IV. Aesthetics, Examples & Workbench

Visual quality, diversity of design, and the developer environment.

- [ ] **Aesthetic Diversity in Showcase Apps (Distinct Visual Expressions):**
  - *Origin:* Dan (Wishlist Intake, 2026-10-12).
  - *Concept:* Several existing example apps look similar or plain, giving the impression
    that slim-pickins only produces one visual flavor.
  - *Wish:* Create example apps that look genuinely exceptional, and look exceptional in
    *different* ways:
    - Editorial prose and reading interfaces (`examples/publication` — shipped in 0.7).
    - Quantitative & relational CRUD (`examples/portfolio` — targeted in 0.8 / 0.9).
    - Interactive domain simulation (`examples/roth`).
    - Operational triage (`examples/dashboard`).
    Demonstrate that `.style`, `.layout`, and the theme engine support diverse, beautiful designs.

- [ ] **Retiring `milestone_planner` & `way_exam` and Modernizing Kept Apps (Targeted in Roadmap 0.8):**
  - *Origin:* `ROADMAP-0.5.md` (Criterion 4, bullet 2); Dan's 2026-10-19 ruling.
  - *Concept:* With `portfolio` selected as the 0.9 CRUD app, `milestone_planner` and `way_exam`
    have served their historical purpose.
  - *Wish:* Retire `milestone_planner` and `way_exam` in Roadmap 0.8, and modernize the five
    kept apps (`publication`, `portfolio`, `roth`, `dashboard`, `word_graph`) to exemplify
    state-of-the-art `.sp`.

- [ ] **The Classic UI Has No `.layout` (Awaiting Dan's Call):**
  - *Origin:* HANDOFF.md "Candidates still standing" (carried from 0.4.0h).
  - *Symptom:* The classic studio UI wears a `.frame` but no `.layout`, so its
    presentation still pools in `slim-pickins.css` rather than a spatial companion.
  - *Desired shape:* Give the classic UI a `.layout`, or retire it in favour of
    the workbench.

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

- [ ] **Seeing the State: Visualizing the Inference Engine (Bret Victor / Moldable Development):**
  - *Origin:* `BLUESKY.md` (Part 2, Bret Victor / Tudor Gîrba).
  - *Vision:* The language performs sophisticated inference (data flow, subject shifts,
    conventions, formatting, frame wrapping). Today, all of that magic is invisible—you
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

- [ ] **Modular Component Frames (Localized Framing):**
  - *Origin:* Discussion in Daytrip 0.4.0q / 0.5.0a.
  - *Vision:* Currently `[app].frame` provides chrome for whole pages. What if complex
    sub-assemblies or widgets could wear localized frames or wrappers using the same
    modest frame concept?

---

## VI. Retired or Graduated Items

- [x] **Composed-Word Parameter Harmonization & Dead Variant Retirement:**
  - *Graduated in:* `DAYTRIP-0.8.0d.md` (Roadmap 0.8).
  - *Resolution:* Harmonized `card.sp` (`subject`), `section.sp` (`subject`), and `title.sp` (`attribute`),
    eliminating all hardcoded word-name exceptions in `contracts.rb`; retired dead `variant` slots on
    `aside`, `scroll`, `item`, and `tabs`; brought all studio UI partials onto explicit `def` headers.
- [x] **`.style` vs. `.layout` Measure & Lead Token Handoff:**
  - *Graduated in:* `DAYTRIP-0.8.0c.md` (Roadmap 0.8).
  - *Resolution:* `Compiler::Layout::TREATMENT_TOKENS` reads `var(--measure, ...)` and `var(--lead, ...)`,
    allowing `.style` companion files to control typographic rhythm without `.layout` clobbering `:root` tokens.
- [x] **`metric` and `fact` Signature & Runtime Discrepancy:**
  - *Graduated in:* `DAYTRIP-0.8.0a.md` (Roadmap 0.8).
  - *Resolution:* Harmonized `metric.sp` and `fact.sp` on `attribute, value` (with `label:` and `as:` modifiers),
    nested `heading` inside `metric.sp`, eliminated hardcoded word exceptions in `Builder#define_single_local_word`,
    and unified `.sp` word compilation.
- [x] **Making the Theme Sayable (A Style DSL Without Machine Bloat):**
  - *Graduated in:* `DAYTRIP-0.7.0e.md` (Roadmap 0.7).
  - *Resolution:* Shipped `.style` companion files and `Compiler::Style`, mapping three
    high-level semantic declarations (`palette`, `measure`, `lead`) to `:root` theme custom
    properties and healing the axiomatic `theme` absence in `CONVENTIONS.md`.
- [x] **Capabilities for Micro-Layout and Component-Level Styling (`cluster`):**
  - *Graduated in:* `DAYTRIP-0.7.0d.md` (Roadmap 0.7).
  - *Resolution:* Added `cluster` to `.layout` zones (`display: flex; flex-wrap: wrap;
    gap: var(--gap, 0.75rem); align-items: center;`), keeping geometry in `.layout` while
    `.sp` names the substance.
- [x] **Date Formatting Register Discrepancy:**
  - *Graduated in:* `DAYTRIP-0.7.0c.md` (Roadmap 0.7).
  - *Resolution:* Registered `date_or_moment_cell` in `CONVENTIONS.md` and `conventions.rb`,
    and generalized `Generator.format` so `table`, `fact`, and `metric` format `Date`/`Time`
    values uniformly via `Inference.moment`.
- [x] **Landing Evaluation for Sentence Arguments (`page document, .title`) & Self-Titling Documents:**
  - *Graduated in:* `DAYTRIP-0.7.0b.md` (Roadmap 0.7).
  - *Resolution:*Retired the `page` word in favor of the route's leading signature sentence;
    `Transform#lands?` evaluates arguments inside the shifted subject; self-titling routes
    adopt `subject.title` and `prose markdown` drops the duplicate leading heading.
- [x] **First-Principles Pedagogy & Historical Artifact Stowing:**
  - *Graduated in:* `DAYTRIP-0.6.0e.md`, `0.6.0g.md`, and `0.6.0k.md` (Roadmap 0.6).
  - *Resolution:* Rewrote `docs/PRIMER.md`, `CONVENTIONS.md`, `VOCABULARY.md`, and `LAYOUT.md`
    from the author's perspective; stowed historical notes in `history/CHRONICLE.md`,
    `history/daytrips/`, and `history/planning/`.
- [x] **Context-Sensitive `actions` ("Where a word sits chooses its form"):**
  - *Graduated in:* `DAYTRIP-0.6.0h.md` (Roadmap 0.6).
  - *Resolution:* Decoupled `actions` from form transport (`def actions / box / contents`);
    `action` emits its own `<button formaction="...">` or standalone form control.
- [x] **Library vs. Development Project Structure (Clean, Lean Gemification):**
  - *Graduated in:* `DAYTRIP-0.6.0f.md` (Roadmap 0.6).
  - *Resolution:* Extracted `checkers/` out of `lib/`, created `slim_pickins.gemspec` with
    zero runtime dependencies, and isolated `studio/` and `examples/`.
- [x] **Terminology Audit & Systematization:**
  - *Graduated in:* Roadmap 0.6 (`DAYTRIP-0.6.0j.md`).
  - *Resolution:* `partial` → `composed word`, `tin` → `.frame`, `spiff` → `.layout`;
    one definition each for `word`, `primitive`, `composed word`, `def`, `contract`,
    `frame`, and `layout` in `docs/ONTOLOGY.md`.
- [x] **Polysemy & Overloaded Terms Audit:**
  - *Graduated in:* Roadmap 0.6 (`DAYTRIP-0.6.0a.md`, `0.6.0b.md`, `0.6.0c.md`, `0.6.0d.md`).
  - *Resolution:* `variant` split into author-chosen presentational weight and
    data-driven status (`dictionary`/`on`/`map`); `children` the template word retired
    for `contents`; `content`/`subject`/`name` delineated by the universal slot model.
- [x] **Shadowing Built-in Language Words (Dan's 2026-10-05 Ruling):**
  - *Graduated in:* `DAYTRIP-0.5.0e.md` (Commit `536684e`).
  - *Resolution:* App composed words and Ruby words may shadow language built-in words within
    their owning library family. The gate reports shadowed words under vitals; Studio
    isolates multi-app playground libraries. Portfolio's `account_card` successfully
    became plain `card`.
- [x] **Retire Legacy `expects` Declaration Line:**
  - *Graduated in:* `DAYTRIP-0.5.0d.md` (Commit `81b2a9d`).
  - *Resolution:* All 28 `.sp` composed words across the repository migrated to `def <word>, *params`
    with Option B1 Data-Flow Inference and Option A Lexical Scope.
