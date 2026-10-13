# Daytrip 0.4.0e — Volet 4b: Studio Partial Minting & Bite-Sized Domain Words

A fluid, in-buffer authoring experience for bite-sized domain vocabulary.

---

## The brief

**Eliminating monolithic `.sp` view scripts (Pain Point 2, 2026-09-23):**

An author writing a view should not have to leave their editor buffer or create multiple files upfront to decompose a page into clean, readable domain vocabulary. 

Volet 4b delivers:
1. **In-buffer word definitions (`def <word_name>, *params`)**: Author bite-sized local domain words directly inside `.sp` view buffers alongside the main page.
2. **Flexible argument binding**:
   - Positional arguments map in order to declared parameters.
   - Named keyword arguments map by key, order-independent.
   - Undeclared named arguments forward into chain scope.
   - Omitted arguments default to `nil`.
3. **Declaration-free word definitions**: No bulky 16-parameter `contract` metadata or `expects` preambles needed for author-defined words; serves as the proving ground for the upcoming Package C (Lean & Elemental Kernel).
4. **Enhanced primitives**:
   - `box subject, title`: Shifts subject context, evaluates children under that subject, handles empty/nil subjects gracefully with `empty`, and emits title heading when children are present.
   - `link label, href`: Flexible positional href argument support alongside `link label, to: href`.
5. **Studio Partial Minting Affordance**:
   - The Studio live-render engine automatically detects in-buffer definitions (`POST /render.json` returns `definitions`).
   - The Studio editor toolbar presents an interactive minting affordance: `Mint <word>(*params) → partial`.
   - Clicking the affordance posts to `POST /mint`, promotes the local word into a permanent standalone `.sp` partial on disk, cleanly excises the `def` block from the editor buffer, and live re-renders using the newly minted partial.

---

## The canonical specimen: Dan's Doc Reader

```sp
page "Doc Reader"
  sidebar docs, "Documents"
  reading_pane selected_doc, selected_doc.name

def sidebar, documents, title
  box documents, title
    empty "No markdown documents in ~/dev/alt-slim-pickins."
    list documents
      each document
        link .name, .path

def reading_pane, document, filename
  box document, filename
    empty "No document selected."
    prose markdown, .content
```

Tested and proven across three real states:
- **Populated state**: renders sidebar list with document links, reading pane with rendered markdown prose and heading.
- **Empty selection state**: renders sidebar list, reading pane gracefully shows empty message `"No document selected."`.
- **Empty library state**: sidebar gracefully shows empty message `"No markdown documents in ~/dev/alt-slim-pickins."`, reading pane shows `"No document selected."`.

---

## Architectural mechanics

1. **AST Hoisting (`lib/slim_pickins/transform.rb`)**:
   Top-level `def` nodes are extracted during `Transform#call` and emitted as `define_local_word(word_name, [params]) do ... end` before the page body evaluates, allowing words to be called above or below their definitions.
2. **Flexible Argument Binding (`lib/slim_pickins/builder.rb`)**:
   `define_local_word` binds positional and keyword arguments, captures caller blocks for child splicing via `children`, and establishes an overlay scope on `Chain` so outer context remains accessible.
3. **Subject Context & Empty State Safety (`lib/slim_pickins/subject.rb`, `words.rb`)**:
   `Subject#fetch` recognizes active empty states (`@builder.empty_active?`), allowing attribute navigation without raising `UnknownAttribute` or `Nothing` before `prune` suppresses the empty branch.
4. **Studio Minting Seam (`studio/pages.rb`, `studio/app.rb`, `assets/studio.js`)**:
   - `StudioPages.extract_definitions`: parses in-buffer `def` blocks, line ranges, and unindents bodies.
   - `StudioPages.mint_partial!`: writes standalone `def` partials to the target app directory and clears compilation caches.
   - `POST /mint`: API endpoint returning `remaining_source` for instant buffer update.
   - `RenderController` in `studio.js`: manages the live minting toolbar and async promotion.

---

## Verification

- **Automated Test Suite**: 402 tests across 44 test files, 5,436 assertions, 0 failures, 0 errors, 0 skips.
- **Quality Gates**: All 7 gates pass cleanly (Grammar, Shape, Styles, Promises, Conventions, Card, Pages).
- **Visual Verification**: Tested with headless Chromium on port 4580 across Workbench UI and Classic UI.
