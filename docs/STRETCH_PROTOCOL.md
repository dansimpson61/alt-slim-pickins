# The Stretch Exam Protocol: The Moving-Target Reference Product

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
> *Walk like the chameleon: what lies ahead is watched, what lies behind is glanced back at.*

## Why This Protocol Exists (The Rationale)

Our own lore diagnosed the trap that catches every DSL designed in a closed room:

> *"Invented examples are the exact condition under which a vocabulary looks more complete than it is, because you only invent examples for words you already have."* — `LORE.md`, 2026-08-30

When example applications are commissioned *after* language features are built simply to exercise those features, two failures follow:
1. **The Circularity Trap:** We subconsciously route around the language's blind spots, writing templates that flatter the compiler as it exists today rather than templates an author actually wants to write.
2. **The Wireframe Ceiling:** Examples built as grammatical unit tests settle for utilitarian markup and default gray boxes. They prove that a sentence parses, not that the language can express a world-class interface.

The antidote is to invert the dependency. Instead of building toy demos to verify what the language can already say, **every forward-looking roadmap is anchored by a Stretch Exam**: a reference application (or an uncompromising upgrade to an existing one) written on paper first, in the cleanest `.sp`, `.frame`, and `.layout` we can imagine, that *cannot yet be realized cleanly* without improving the language.

This is the *Ode to Joy* applied to language evolution: we make machines understand humans, never asking the human to take care of the compiler. Where a real product pinches, the language heals.

---

## How It Fits *Ataovy dian-tana*

The Stretch Exam binds directly to our odd/even roadmap cadence (`README.md`, *How roadmaps go*):

| Roadmap Parity | Role of the Moving-Target Reference Product |
| :--- | :--- |
| **Odd Roadmaps (The Forward Eye)** | **The Wall & The Build.** Open by drafting the Stretch Exam on paper—uncompromised `.sp` views, a clean `.frame`, and an expressive `.layout` manifest. Run it against the compiler and the browser to inventory the **Walls** (refusals, compiler-appeasing workarounds, missing micro-layouts, or aesthetic limits). Spend the roadmap's daytrips solving those walls structurally in the language until the paper templates render live without a single compromise. |
| **Even Roadmaps (The Backward Eye)** | **The Harvest & The Purge.** Study what the odd roadmap built to pass the exam as an object of craft in its own right. Promote generalizable app words into `lib/vocabulary/`, fold recurring spatial postures into `.layout`, untangle any polysemy introduced under pressure, and **retire legacy scaffolding apps** that the new reference product has superseded. |

---

## The Four-Step Stretch Cycle

Every Stretch Exam runs through four strict movements:

### 1. Paper First (Uncompromised Authoring)
Before touching `lib/`, draft the target application's `.sp`, `.frame`, and `.layout` files as an author *wishes* to write them:
- Short, outline-like pages calling short, focused `def` words.
- Zero `tag` escapes in application space.
- Zero bespoke CSS files or utility-class escape hatches to work around `.layout`.
- Zero domain-model contortions (such as artificial alias methods on Ruby structs) to appease `Subject` lookup rules.

### 2. The Wall Inventory (Measuring the Pinch)
Attempt to boot, render, and visually inspect the paper application. Record every failure in a **Wall Ledger**, classified by where the language fell short:
1. **Grammar or Scope Pinch:** A sentence that reads naturally to a human (`document, .title` or `actions` nested inside `form`) but fails or misbehaves because of compiler evaluation order or scoping rules.
2. **Vocabulary or Inference Gap:** A domain-agnostic presentation pattern or mechanical fact that the language forces the author to wire by hand.
3. **Spatial or Micro-Layout Gap:** A visual arrangement (inline wrapping badge clusters, compact action bars, content-aware pane splits) that `.layout` cannot express without raw CSS rules.
4. **Aesthetic or Theme Ceiling:** A typographic hierarchy, density posture, or atmospheric palette that `:root` tokens cannot currently articulate.

### 3. Structural Resolution (Healing the Language)
Each daytrip in the roadmap attacks a wall from the ledger under three standing rules:
- **Never make the author mind the compiler.** If a fix requires a new pragma, manual type hint, or restated literal, reject the fix.
- **Solve at the structural layer, not by patch.** Ask what general convention or spatial primitive dissolves the class of problem, not just the line that failed.
- **Paper first, then reality, one at a time.** Prove the design on the specimen before migrating the corpus.

### 4. Visual Sign-Off & Gate Lock
A Stretch Exam is not passed when `verify_pages.rb` exits 0; checkers cannot see visual mediocrity. The exam passes when:
1. All twelve gate legs and the single-process test suite are green.
2. The paper `.sp` and `.layout` files run unmodified.
3. The live application is inspected in the browser and meets the visual benchmark for its archetype (Editorial Prose, Dense Analytical Dashboard, or Focused Transactional Tool).
4. An older, superseded demo app is named and either retired or consolidated so the garden never rots into a museum of early prototypes.

---

## The Three Standing Guardrails

1. **No App-Space Polyfill Cheating:** If passing the Stretch Exam requires hiding raw HTML in an app-specific Ruby word or sneaking an uncompiled `.css` file into `public/`, the exam is still red. The reference app must eat the exact dogfood an external author gets.
2. **One Enters, One Graduates or Retires:** The `examples/` directory is a curated garden, not an archive. Every time a Stretch Exam elevates the bar, we audit `examples/` during the following even roadmap and prune any app whose only remaining value is historical.
3. **Aesthetic Diversity is Part of the Spec:** Each Stretch Exam must declare its visual archetype upfront and prove that `.layout` and the theme engine can produce distinct, exceptional interfaces—never defaulting to uniform gray wireframes.

---

## Candidate Stretch Horizons (From `WISHLIST.md`)

To be selected and confirmed by Dan at the opening of each odd roadmap:

- **Horizon A — The Authentic CRUD & State-Mutation Benchmark:**
  A persistent, SQLite-backed application exercising full Create/Read/Update/Delete lifecycles, server-side validation failures, dirty form re-rendering, flash feedback, entity routing conventions (`/milestones/:id/tasks`), collection-scoped emptiness, and context-sensitive `actions` inside and outside `<form>`.
- **Horizon B — The High-Craft Editorial & Micro-Layout Benchmark:**
  A publication-grade reader and documentation studio demanding landing evaluation for sentence arguments (`document, .title`), self-titling markdown documents, component-level micro-layout in `.layout` (`cluster`, `stack`), pluggable rendering adapters, and sayable theme roles (`measure: wide`, `gap: loose`).
- **Horizon C — The Self-Hosted Moldable Workbench ("Rubinius" Endgame):**
  The Studio Workbench itself held as the ultimate Stretch Exam: an interactive Bret Victor "Inference Inspector" tracing the live subject chain, line-numbered editor gutters with inline error diagnostics, and content-aware split panes—authored 100% in idiomatic `.sp`, `.frame`, and `.layout`.