# Daytrip 0.6.0h — Actions Purification: Semantic Toolbar Register & Form Transport Decoupling

**Status: closed 2026-10-14.** All movements implemented and verified across all 12 gate legs, 35 pages verified OK, full test suite passing (652 runs, 7,041 assertions, 0 failures).

## Context & Motivation

In Daytrip 0.4.0q, `actions` was conceived with hidden form transport logic (`form method: post`, `hidden path, .path`, `hidden return_to, .return_to`). While this offered a shortcut for multi-submit queue rows in the dashboard, it created a severe architectural leak:
1. **Spurious Form Wrappers**: Any navigation link or secondary affordance placed inside `actions` was wrapped inside a `<form>` element.
2. **Invalid Nested Forms**: In apps like `milestone_planner`, `roth`, and `way_exam`, placing `actions` inside a form created illegal nested `<form>` tags in HTML.
3. **Domain Pollution in Canonical Vocabulary**: Modifiers like `path:` and `return_to:` belong to application transport conventions (specifically the triage queue), not the universal grammar of a view language.

Following a thorough evaluation of three structural options (Path A: Primitive split with `cluster`, Path B: Pure Semantic Register, Path C: Explicit Scaffolding), **Path B** was selected by dan. Additionally, a future exploration of micro-layout / component-level styling capabilities was recorded in `WISHLIST.md`.

## Movements Completed

1. **Purified `actions.sp` Partial (`lib/vocabulary/actions.sp`)**:
   - Stripped the `<form method="post">` wrapper, hidden `path` and `return_to` input fields, and all transport conditionals.
   - Refactored `actions` to a pure semantic toolbar container:
     ```sp
     def actions
       box
         contents
     ```
   - Emits `<div class="actions">...</div>`, providing a semantic toolbar container for affordances without interfering with DOM structure or forms.

2. **Decoupled Application Multi-Submit Queue (`examples/dashboard/views/partials/queue.sp`)**:
   - Explicitly wrapped the triage actions in `form method: post` with explicit `hidden path, .path` and `hidden return_to, "/triage"`.
   - Preserved exact triage functionality and form submission semantics without burdening the language primitive.

3. **Updated Taxonomy & Contracts**:
   - In `lib/slim_pickins/taxonomy.rb`, updated `:actions` entry: removed `:behavioral` from tiers (now `%i[interactive structural]`), updated role to `"Action toolbar grouping buttons and navigation affordances"` and diagnostic note.
   - In `lib/slim_pickins/contracts.rb`, cleared modifiers (`actions: []`) and removed `:partial_slot_forwarding` inference from `actions`.
   - Regenerated `docs/VOCABULARY.md` via `bin/generate_vocabulary.rb`.

4. **Conventions & Promise Ledger Updates**:
   - Marked `:partial_slot_forwarding` in `lib/slim_pickins/conventions.rb` with `owned_by: :runtime` (as it is a runtime dynamic fallback lookup for missing partial modifiers, no longer declared as an inference of `actions`).
   - Retired `path` and `return_to` promises from `lib/slim_pickins/promises.rb`, reducing canonical promises from 35 to 33.
   - Updated vitals in `README.md` and `HANDOFF.md` from 35 to 33 promises.

5. **Wishlist Addition (`WISHLIST.md`)**:
   - Added Section IV entry: *Micro-layout & Component-Level Styling Capabilities*. Documented the distinction between Spiff macro-layout (semantic grid zones) and component micro-layout (gap, alignment, clustering), framing future potential abstractions over CSS.

6. **Test Suite & Gate Verification**:
   - Updated `test/vocabulary_partials_test.rb` to test `actions` as a pure container outside forms (emitting buttons of `type="button"` and clean links) and inside forms (emitting buttons of `type="submit"` and cooperating with form fields).
   - Added regression assertions verifying `actions` raises `SyntaxError` on legacy `path:` or `return_to:` modifiers.
   - Updated `test/census_test.rb` and `test/instruments_test.rb` to reflect 33 promises and 5 unowned conventions.
   - Verified all 12 Studio gate legs green: Grammar, Shape, Styles, Spiff, Scope, Promises, Conventions, Card, Pages, Vitals, Ruby, Suite.
