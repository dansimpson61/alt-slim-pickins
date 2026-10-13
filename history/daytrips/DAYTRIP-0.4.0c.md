# DAYTRIP-0.4.0c — Studio & Workbench Wins

**Opened 2026-09-22, on dan's word.** A jaunt off the path, giving orthogonal volume
to the roadmap's linear vector.

> *"The itinerary is just a vector; the daytrips give it volume."*

This daytrip opens and executes Volet 3 of the Roadmap 0.4 progression. Following
Volet 1 (The Truthful Floor) and Volet 2 (Expressive View Composition), Volet 3
focuses on the Studio and Workbench environment — turning the Studio into a
moldable development environment with total runtime transparency.

---

## The brief

**Observations and direction (2026-09-22):**

1. **Orthogonal Volume**: Continue executing small, winnable victories that enrich
   the environment without creating architectural bloat.
2. **Win W2 (Live Test Suite on `/status`)**:
   - The Studio `/status` page currently runs the 7 checkers (`check_grammar`,
     `check_shape`, `check_styles`, `check_promises`, `check_conventions`, `check_card`,
     `verify_pages`), but does not run the test suite itself.
   - Adding the full test suite as an 8th live leg closes the gap where `/status`
     could claim green while an underlying unit test was failing.
3. **Win W3 (The Combined `Inspect` Surface — Tree + Why)**:
   - Expand the Workbench output tabs (`Visual` | `HTML`) with a unified third tab:
     **`Inspect`**.
   - **The Semantic Tree (The What)**: Master pane displaying the parsed AST returned
     by `SlimPickins.evaluate` with collapsible nodes.
   - **The Why Pane (The Why)**: Detail pane displaying the decision provenance of
     each node/property across the 4 tiers (`page`, `app`, `language`, `theme`),
     linking directly to the 38 registered conventions in `SlimPickins::Conventions::ALL`,
     and revealing the override idiom.
4. **No Modes, No Friction**: Unify structure and causality in one synchronized
   surface rather than splitting them into disconnected tabs.

---

## The question

> **How do we make the Studio a truly transparent workbench — bringing the full test
> suite into live status reporting (W2) and uniting the Semantic Tree with Inference
> Provenance in a single, responsive `Inspect` surface (W3) — without compromising
> render speed or polluting the view DSL?**

---

## The Stops

### Stop 1 — Win W2: Live Test Suite Leg on `/status`
1. Update `studio/status.rb`:
   - Expand `LEGS` to include an 8th leg for the full test suite.
   - Ensure `StudioStatus.run` executes the command cleanly and captures the output.
   - Update `StudioStatus.canned` to maintain 8-leg parity for offline verification.
2. Verify `/status` on both Classic and Workbench UIs.
3. Verify that `test/studio_docs_test.rb` (and any related tests) pass with the 8th leg.

### Stop 2 — Win W3 Part 1: The Semantic Tree in `Inspect`
1. In `studio/uis/workbench/views/partials/output.sp`:
   - Add a 3rd tab: `tab "Inspect"`.
2. In `studio/app.rb`:
   - Extend `/render.json` to include `tree: SlimPickins.evaluate(...)`.
3. In `assets/studio.js` (or Stimulus controller):
   - Render the semantic node hierarchy into collapsible tree elements in the `Inspect` pane.
4. Verify tree rendering across specimen and real garden app pages.

### Stop 3 — Win W3 Part 2: The Why Detail Pane
1. Capture inference and convention provenance during evaluation:
   - Record firing conventions and ownership tiers for computed attributes.
2. In the `Inspect` tab, render the synchronized master-detail view:
   - Clicking or focusing a node in the Semantic Tree shows its decisions, convention links, and override idiom in the Why detail pane.

### Stop 4 — Verification, Census & Housekeeping
1. Verify all 7 gates and the new 8-leg `/status` page.
2. Ensure full test suite passes with 0 failures, 0 errors, 0 skips.
3. Update `PROJECT.md`, `LORE.md`, and journal via dashboard API.

---

## Verification & Done Looks Like

- Studio `/status` reports 8 legs live, including `Suite`, with exact pass/fail reporting.
- The Studio Workbench features an `Inspect` tab alongside `Visual` and `HTML`.
- The `Inspect` tab displays the evaluated Semantic Tree with interactive node exploration.
- The Why detail pane displays decision provenance and convention links.
- All gates pass and living census vitals are verified.

---

## Outcome (Volet 3 Landed)

1. **Win W2 Delivered**: Live test suite integrated as the 8th leg in `StudioStatus::LEGS` (`studio/status.rb`). Verified live on port 4580 reporting *"All 8 legs green, run live at ..."* with `<section class="section"><h2 class="section-title">Suite</h2><span class="badge badge--ok">ok</span>`. Canned suite verification updated in `test/studio_docs_test.rb`.
2. **Win W3 Delivered (The Combined Inspect Surface)**:
   - Added `tab "Inspect"` to `studio/uis/workbench/views/partials/output.sp`.
   - Built `StudioInspector` (`studio/inspector.rb`) to format the evaluated semantic AST returned by `SlimPickins.evaluate` into an interactive, master-detail workbench experience.
   - Master pane: Hierarchical, collapsible Semantic Tree with native `<details><summary>`, node type tokens, variants, body previews, and convention indicators.
   - Detail pane (The Why Pane): Synchronized provenance card displaying node attributes, owning precedence tiers (`page`, `app`, `language`, `theme`), active conventions from `SlimPickins::Conventions::ALL`, when-silent defaults, and override idioms.
   - Updated `RenderController` (`assets/studio.js`) and `POST /render.json` (`studio/pages.rb`) to stream `inspect` payload live alongside `visual` and `source`.
3. **Unit Tests Added**: `test/studio_inspector_test.rb` (3 runs, 29 assertions) verifies tree structure, Why convention linkages, JSON payload contracts, and clean refusal handling.
4. **Vitals**: All 7 gates green, 376 tests pass (0 failures, 0 errors, 0 skips), 42 test files.

