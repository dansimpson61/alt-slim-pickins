# Codebase Grammar Explorer Report: The `action` Primitive in `alt-slim-pickins`

**Explorer:** Explorer 1 (Codebase Grammar Explorer)  
**Date:** 2026-09-10  
**Repository:** `/home/dan/dev/alt-slim-pickins`  
**Status:** Complete Investigation  

---

## 1. Executive Summary

In `alt-slim-pickins`, `action` is **not** a hardcoded Ruby primitive in `lib/slim_pickins/words.rb`. Rather, it is a **vocabulary partial** defined in `lib/vocabulary/action.sp`. It is loaded at boot time by `SlimPickins::Library.builtin` and compiled dynamically into an anonymous subclass of `SlimPickins::PartialWord`.

`action` currently takes **5 arguments**:
```slim
action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
```
1. `"Commit"` (Rank 1: Positional text content / button label)
2. `to: "/actions/commit"` (Rank 2: HTTP POST destination endpoint)
3. `path: first_item.path` (Rank 2: Domain identifier passed as a hidden form input)
4. `return_to: "/triage"` (Rank 2: Redirect target URL passed as a hidden form input)
5. `variant: primary` (Rank 2: Button styling variant)

This makes `action` the **longest sentence in the language** (`longest 5` in real pages, `longest 6` in declarations including the `expects` line), compared to the language's average sentence length of 1.28 arguments (`check_shape.rb`).

Our investigation reveals that this 5-argument sentence arose during Phase 4 (Round C/D) of the 0.2 Roadmap when porting the `dashboard` application's `/triage` page (`ROADMAP-0.2.md:369-388`). The modifiers `path:` and `return_to:` were hardcoded into this language-level vocabulary partial specifically to satisfy the dashboard's triage buttons. This leaked application-specific hidden payload concerns into what was intended to be a generic UI primitive. Furthermore, when the dashboard required another action button with an additional parameter (`status: "dormant"`), `action` could not express it, forcing the creation of a separate one-off partial (`examples/dashboard/views/partials/dormant.sp`).

---

## 2. Pipeline & Architecture: Where and How `action` is Defined

The lifecycle of `action` spans four main subsystems:
1. **Definition & Discovery:** `lib/vocabulary/action.sp` & `SlimPickins::Library`
2. **Lexing & Code Generation:** `SlimPickins::Transform`
3. **Contract Compilation & Enforcement:** `SlimPickins::VocabularyShapes` & `SlimPickins::Contracts`
4. **Evaluation & HTML Generation:** `SlimPickins::PartialWord`, `SlimPickins::Builder`, and `SlimPickins::Generator`

### 2.1 Definition (`lib/vocabulary/action.sp`)

`action` is written in the slim-pickins DSL itself:
```slim
expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true

form method: post, to: .to
  hidden path, .path
  hidden return_to, .return_to
  button .variant, .content
```

- Line 1 declares the word's contract using the `expects` preamble.
- Lines 4–7 define the expansion: a `form` with HTTP method `post`, two `hidden` inputs (`path` and `return_to`), and a `button` with variant and label.

### 2.2 Compilation & Registry (`lib/slim_pickins/compilation.rb` & `library.rb`)

When `SlimPickins::Library.builtin` runs:
1. `Library.builtin_partials` reads `lib/vocabulary/*.sp` (`lib/slim_pickins/library.rb:75-77`).
2. `Compilation.compile_partial(:action, source, true, path)` (`lib/slim_pickins/compilation.rb:22-36`):
   - Subclasses `PartialWord`: `klass = Class.new(PartialWord)`.
   - Stores metadata: `klass.partial_name = :action`, `klass.is_builtin = true`, `klass.source_path = path`.
   - Compiles the partial's body to Ruby AST and caches it: `klass.compilation = of(source, "partials/action.sp")`.
   - Parses the contract preamble using `VocabularyShapes.parse(source)`.
   - Registers the class in the global registry: `SlimPickins::Word.registry[:action] = klass`.

### 2.3 Lexer / Grammar Transformer (`lib/slim_pickins/transform.rb`)

`alt-slim-pickins` does not use an external parser generator; `SlimPickins::Transform` translates `.sp` source directly into executable Ruby blocks wrapped with source location tracking (`with_line`).

For a call like:
```slim
action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
```
`Transform` processes it as follows:
- **Partitioning (`build`, lines 105–109):** `word` is `"action"`, rest is `"\"Commit\", to: \"/actions/commit\", path: first_item.path, return_to: \"/triage\", variant: primary"`.
- **Argument Splitting (`split_args`, lines 189–208):** Splits commas while respecting quotes and parentheses.
- **Classification & Ranking (`rank`, lines 180–186):**
  - Rank 0: bare name / identifier (none present in this call)
  - Rank 1: content / data (`"Commit"`)
  - Rank 2: modifiers (`to: ...`, `path: ...`, `return_to: ...`, `variant: ...`)
  - Ordering check: `ranks == ranks.sort` ensures no bare name follows content or modifiers.
- **Ruby Emission (`argument`, lines 148–175 & `emit`, lines 81–103):**
  - `"Commit"` stays `"Commit"`
  - `to: "/actions/commit"` stays `to: "/actions/commit"`
  - `path: first_item.path` stays `path: first_item.path`
  - `return_to: "/triage"` stays `return_to: "/triage"`
  - `variant: primary` transforms bare identifier `primary` to symbol `:primary`
  - Emits Ruby code:
    ```ruby
    with_line(12) do
      action("Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: :primary)
    end
    ```

### 2.4 Contract Grammar Enforcement (`lib/slim_pickins/contracts.rb`)

`VocabularyShapes.parse` parses the `expects` line of `action.sp`:
- `content: true` sets `contract.content = true`.
- `shape: encloses` sets `contract.shape = :encloses`.
- Unrecognized keys (`to: true, path: true, return_to: true, variant: true`) are converted into allowed modifiers:
  `contract.modifiers = [:to, :path, :return_to, :variant]`.
- Defaults apply: `name: :none`, `children: :none`, `parents: :any`, `speech: :noun`, `subject: :keep`.

During `Contracts.complaints(node, ancestry)` (and `Contracts.call_complaint`):
- Any bare name passed to `action` triggers: `` `action` takes no name — <names> ``.
- Any modifier outside `[:to, :path, :return_to, :variant, :if, :class, :id]` triggers: `` `action` has no `<mod>:` modifier ``.
- Any indented children nested under `action` trigger: `` `action` holds nothing — a `<child>` has nowhere to go ``.

### 2.5 Builder & Evaluation (`lib/slim_pickins/partial_word.rb` & `builder.rb`)

When the generated Ruby executes `action(...)`:
1. `Builder` instantiates `PartialWord` subclass registered for `:action`.
2. In `PartialWord#evaluate` (`lib/slim_pickins/partial_word.rb:11-78`):
   - Validates arguments against contract.
   - Extracts parameters:
     ```ruby
     parameters = {
       content: "Commit",
       to: "/actions/commit",
       path: "item/path",
       return_to: "/triage",
       variant: :primary
     }
     ```
   - Dynamically pushes `parameters` as the current subject via `chain.with(parameters, described_as: "this action", overlay: true)`.
   - Executes the compiled Ruby AST of `action.sp`.
   - The body executes:
     - `form method: :post, to: subject.to`: creates a `:form` node with `action: attrs[:to]`, `method: :post`.
     - `hidden :path, subject.path`: creates `[:hidden, { name: :path, value: "item/path" }, []]`.
     - `hidden :return_to, subject.return_to`: creates `[:hidden, { name: :return_to, value: "/triage" }, []]`.
     - `button subject.variant, subject.content`: creates `[:button, { variant: :primary, label: "Commit", ... }, []]`.
   - Sets `box[:class_base] = :action` on the form node (`partial_word.rb:68`).
   - Spliced nodes are emitted to the builder.

### 2.6 Generator / Renderer (`lib/slim_pickins/generator.rb`)

`Generator` receives the AST:
```ruby
[
  :form,
  { name: nil, to: "/actions/commit", method: :post, target: nil, class_base: :action },
  [
    [:hidden, { name: :path, value: "ode-to-joy" }, []],
    [:hidden, { name: :return_to, value: "/triage" }, []],
    [:button, { variant: :primary, label: "Commit", to: nil, target: nil, type: nil, size: nil }, []]
  ]
]
```

Rendering rules:
1. `form`: Calls `open_tag('form', class: token(:form), id: attrs[:name]&.to_s, action: attrs[:to]&.to_s, method: 'post')`.
   - *Crucial Observation:* `Generator#form` lines 447-452 emits `class: token(:form)`. It does **not** consume `attrs[:class_base]`. Therefore, the emitted `<form>` has `class="form"`, **not** `class="action"` or `class="form action"`.
2. `hidden`: Calls `void_tag('input', type: 'hidden', name: attrs[:name].to_s, value: attrs[:value]&.to_s)`.
3. `button`: Calls `full_tag('button', attrs[:label], type: 'submit', class: 'button button--primary')`. Note that `type` defaults to `:submit` because `@in_form` is true.

---

## 3. The 5 Arguments: Syntax and Semantics

| Position / Modifier | Rank | Value in Call Site | Semantic Role | Target HTML Mapping |
|---|---|---|---|---|
| **1. Content (Positional)** | 1 | `"Commit"`, `"Archive"`, `"Skip 30d"` | Button label | Body text of `<button type="submit">...</button>` |
| **2. `to:`** | 2 | `"/actions/commit"`, etc. | Form submission URL | `<form action="...">` |
| **3. `path:`** | 2 | `first_item.path`, `.name` | Domain resource ID | `<input type="hidden" name="path" value="...">` |
| **4. `return_to:`** | 2 | `"/triage"` | Post-action redirect route | `<input type="hidden" name="return_to" value="...">` |
| **5. `variant:`** | 2 | `primary`, `neutral` | Button visual style | CSS class modifier `<button class="button button--<variant>">` |

### The Parameter Smell & Missing Abstraction

1. **Domain Leakage into Core Grammar:** `path:` and `return_to:` are concepts unique to the dashboard workspace triage. Placing them in `lib/vocabulary/action.sp` makes a general-purpose presentation DSL know about specific form payloads of a single Sinatra application.
2. **Rigid Inflexibility:**
   - What if an action needs 3 hidden inputs? (e.g. `status: "dormant"`).
   - What if an action needs no `return_to` or a confirmation token?
   - In `examples/dashboard/views/partials/dormant.sp`, the author was unable to use `action` because `status: "dormant"` was needed. They were forced to duplicate the entire form:
     ```slim
     form method: post, to: "/actions/status"
       hidden path, .path
       hidden return_to, "/triage"
       hidden status, "dormant"
       button neutral, .content
     ```
3. **Violates Vitals & Ergonomics:**
   - Longest sentence in the language (5 arguments in views).
   - Alt-slim-pickins sentences average 1.28 arguments.
   - Pushes 8 modifiers into the language that are used by only one app (`ROADMAP-0.2.md:369-375`).

---

## 4. Rendered HTML Output

For the call:
```slim
action "Commit", to: "/actions/commit", path: "ode-to-joy", return_to: "/triage", variant: primary
```

The exact rendered HTML is:
```html
<form class="form" action="/actions/commit" method="post">
  <input type="hidden" name="path" value="ode-to-joy">
  <input type="hidden" name="return_to" value="/triage">
  <button type="submit" class="button button--primary">Commit</button>
</form>
```

When formatted with `Generator.lay_out` within a card context:
```html
<form class="form" action="/actions/commit" method="post">
  <input type="hidden" name="path" value="ode-to-joy">
  <input type="hidden" name="return_to" value="/triage">
  <button type="submit" class="button button--primary">Commit</button>
</form>
```

### Stylesheet Interaction (`assets/slim-pickins.css`)
- Line 395 of `assets/slim-pickins.css` defines:
  ```css
  .action { display: inline; }
  ```
- Line 177 defines:
  ```css
  .actions { display: flex; flex-wrap: wrap; gap: var(--gap); align-items: center; }
  ```
- *Interesting finding:* Even though `.action { display: inline; }` exists in CSS, `Generator#form` never emits `class="action"` on the `<form>` element because `form` outputs `class="form"` directly. `check_styles.rb` only required `.action` because line 70 checks `can_emit |= (CONTRACTS.keys - Words.instance_methods).map(&:to_s)`, assuming every vocabulary partial's name is emitted as a class base.

---

## 5. Verification Tools & Test Coverage

### 5.1 Verification Scripts

| Script | Purpose | Relation to `action` |
|---|---|---|
| `check_grammar.rb` | Validates sentence compilation, word definitions, contract adherence, and `VOCABULARY.md` bullets | Enforces `action` contract: 0 names, content allowed, modifiers `to:`, `path:`, `return_to:`, `variant:`, 0 children. Validates that `action` is in `VOCABULARY.md` and has at least 1 example. |
| `check_shape.rb` | Verifies shapes, parts of speech, and prints corpus vitals | Verifies `action` has shape `encloses` and speech `noun`. Reports `longest 5` sentence in real pages (`longest 6` with `action.sp`'s `expects`). |
| `check_styles.rb` | Pairs emittable classes with CSS rules | Enforces that `.action` is defined in `assets/slim-pickins.css`. |
| `bin/verify_pages.rb` | Renders 10 production/example pages against real/fixture locals | Proves `examples/dashboard/views/triage.sp` and `confirm_archive.sp`. |
| `bin/dashboard_parity.rb` | Compares live affordances against running dashboard at `http://127.0.0.1:4000/triage` | Verifies the 4 POST actions (`/actions/commit`, `/actions/status`, `/actions/archive`, `/actions/skip`), hidden fields, and button labels match (25 affordances, 0 missing). |
| `bin/generate_vocabulary.rb` | Rewrites 5 checkable bullets in `VOCABULARY.md` from contracts | Generates `VOCABULARY.md` section for `action`. |

### 5.2 Test Suites (`test/*_test.rb`)

| Test File | Relevant Tests | Specific Assertion |
|---|---|---|
| `test/vocabulary_partials_test.rb` | `test_action_is_the_minimal_post_form` (lines 25-36) | Renders `action "Commit", to: ..., path: .name, return_to: ..., variant: primary` and asserts `<form class="form" action="/actions/commit" method="post">`, hidden `path`, hidden `return_to`, and `<button type="submit" class="button button--primary">Commit</button>`. |
| `test/dashboard_test.rb` | `test_the_four_actions_post_the_original_payloads` (lines 44-54) | Verifies the 4 forms (`commit`, `status`, `archive`, `skip`), the hidden inputs (`path`, `return_to`, `status`), and button labels. |
| `test/dashboard_test.rb` | `test_commit_is_offered_only_when_the_app_offers_it` (lines 56-61) | Verifies conditional presence/absence of `action="/actions/commit"`. |
| `test/partial_args_test.rb` | `test_a_partial_reads_its_modifiers` (lines 26-34) | Tests custom partial `test_test_go_form` with `form method: post, to: .to`, `hidden path, .path`, and `button .content`. |
| `test/ui_words_test.rb` | `test_a_form_can_carry_an_action_button_and_hidden_inputs` (lines 17-29) | Direct test of primitive `form`, `hidden`, and `button` composition. |
| `test/studio_docs_test.rb` | `test_every_guide_exists_at_the_root` | **Pre-existing Failure:** Failed baseline check because `design_conventions.md` is in `StudioDocs::GUIDES` list but missing from repo root. |

---

## 6. Call Sites Matrix

| File Path | Line(s) | Code Snippet | Context |
|---|---|---|---|
| `examples/dashboard/views/partials/queue.sp` | 12 | `action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary` | Conditional commit action for top queue item |
| `examples/dashboard/views/partials/queue.sp` | 14 | `action "Archive", to: "/actions/archive", path: first_item.path, return_to: "/triage", variant: neutral` | Archive action |
| `examples/dashboard/views/partials/queue.sp` | 15 | `action "Skip 30d", to: "/actions/skip", path: first_item.path, return_to: "/triage", variant: neutral` | Skip action |
| `test/vocabulary_partials_test.rb` | 28 | `action "Commit", to: "/actions/commit", path: .name, return_to: "/triage", variant: primary` | Test exercising `action` vocabulary partial |
| *(Contrast)* `examples/dashboard/views/partials/dormant.sp` | 1-5 | `form method: post, to: "/actions/status"\n  hidden path, .path\n  hidden return_to, "/triage"\n  hidden status, "dormant"\n  button neutral, .content` | Custom partial required because `action` lacks `status:` modifier |

---

## 7. Architectural Observations for the Luminary Council

When assessing the refactoring of `action`, the council should consider the following architectural mechanisms already present in the codebase:

1. **`actions` container already exists (`lib/vocabulary/actions.sp`):**
   ```slim
   expects children: "link button", shape: encloses

   box
     children
   ```
   In `portfolio` and `roth`, buttons live inside `actions`:
   ```slim
   actions
     button primary, "Run"
   ```
2. **`form` is a block primitive (`lib/slim_pickins/words.rb:345-358`):**
   ```slim
   form to: "/actions/commit", method: post
     hidden path, .path
     hidden return_to, "/triage"
     button primary, "Commit"
   ```
3. **Block vs. Macro Distinction:**
   Is `action` trying to be an inline macro for something that is naturally a block structure?
   Or is `action` a missing verb/noun for single-button form actions?
4. **HTML Parity Flexibility:**
   The prompt explicitly grants: *"You have the flexibility to alter the resulting HTML structure slightly if it leads to a significantly cleaner DSL, provided the visual and semantic function remains intact."*
   For instance:
   - Does each button need its own `<form>`, or can `<button formaction="..." formmethod="post">` be used inside a shared form or container?
   - Can `action` take a block for arbitrary hidden inputs or parameters?
   - Can `action` delegate payload construction to the current subject?
5. **Vitals & Checker Gates:**
   Any change to `action` will directly affect:
   - `check_shape.rb`: Sentence length (will reduce `longest 5`), modifiers count.
   - `check_grammar.rb`: Contract in `action.sp` and bullets in `VOCABULARY.md` (must be updated via `bin/generate_vocabulary.rb`).
   - `check_styles.rb`: CSS rules.
   - `test/vocabulary_partials_test.rb` & `test/dashboard_test.rb`: Test assertions.
   - `bin/dashboard_parity.rb`: Affordances must remain at 25 / 0 missing.

---

## 8. Summary of Findings

1. `action` is a vocabulary partial defined in `lib/vocabulary/action.sp`.
2. It expands into a `form` with method `post`, two `hidden` inputs (`path` and `return_to`), and a `button`.
3. Its 5 arguments are: 1 positional button label (`content`) and 4 modifiers (`to:`, `path:`, `return_to:`, `variant:`).
4. It is the longest sentence in `alt-slim-pickins` and exists only because Phase 4 tailored it for `examples/dashboard/views/partials/queue.sp`.
5. It fails to generalize even to other actions in the same dashboard (such as `dormant.sp`).
6. The test and verification pipeline is strict, comprehensive, and automated, with 0 grammar or shape problems, and 25/25 live parity affordances.
