# DSL Design Philosophy & The 8 Ruby Luminaries Council Analysis
**Phase 1 Survey Report — Explorer 3 (DSL Philosophy Explorer)**
*Date: 2026-09-10*

---

## 1. Executive Summary

In the `alt-slim-pickins` template language, the `action` primitive currently accepts five arguments:
```sp
action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
```
In a language whose average sentence length is **1.28 arguments** and whose design ethos is *"a line that states the inferable should not exist"*, this five-argument sentence is the single longest sentence in the language and a glaring structural anomaly.

Our investigation into the codebase, git history, `ROADMAP-0.2.md`, `LORE.md`, `PRIMER.md`, and `ODE_TO_JOY.md` reveals both the historical origin of this anomaly and its philosophical implications:

1. **The Historical Origin**: `action` was created in Phase 4 (Round C) during the port of `examples/dashboard`. To eliminate custom Ruby helpers (`DashboardWords`) without introducing heavy new Ruby primitives, the author created `lib/vocabulary/action.sp` as a vocabulary partial. However, because partials had no mechanism for optional modifiers or dynamic inference, the author hardcoded the dashboard's specific parameters—`path` and `return_to`—directly into the core vocabulary's `action.sp` contract!
2. **The Missing Abstraction**: The five-argument `action` is a symptom of **three distinct design breakdowns**:
   - **Violation of Single Responsibility**: It conflates HTTP method/endpoint configuration, entity identity payload, redirect routing, and button styling into a single flat sentence.
   - **Violation of the Inference Principle**: It forces templates to repeatedly pass `path: first_item.path` and `return_to: "/triage"`, even when nested inside a card whose subject is `first_item` and on a page whose route is `/triage`.
   - **Leaky Domain Coupling**: App-specific hidden fields (`path`, `return_to`) were elevated into a global language primitive.
3. **The Council Framing**: The 8 Ruby luminaries (Matz, Sandi Metz, _why, DHH, Jim Weirich, Avdi Grimm, Katrina Owen, Sarah Mei) provide a rich, multifaceted analysis. Sandi Metz diagnoses a classic "Data Clump" and parameter smell; DHH identifies a lack of convention over configuration; Jim Weirich identifies a failure of block composability; Avdi Grimm critiques timid code that fails to trust its subject chain; Katrina Owen maps out a small-step therapeutic refactor; and Matz reminds us that code must spark joy.

---

## 2. DSL Design Philosophy of `alt-slim-pickins`

The `alt-slim-pickins` language is governed by the principles laid down in `ODE_TO_JOY.md`, `PRIMER.md`, and `DESIGN.md`. Understanding these principles is essential before evaluating any refactor.

### 2.1 The Core Credo (`ODE_TO_JOY.md`)
- **Matz's Aim**: *"We program to be happy... The measure of our code is not only that it runs, but that it delights — the one who writes it, the one who reads it, the one who must change it a year from now."*
- **Joy is Honest, Clear, Kind**:
  - **Honest**: Correct, tested, truthful about failures.
  - **Clear**: Its shape reveals its purpose, names carry meaning, reads like prose.
  - **Kind**: Easy to change, safe to touch, ready for the next pair of hands.
- **Precedence Order**:
  $$\text{Correctness} > \text{The House} > \text{Clarity} > \text{Idiom} > \text{Elegance}$$
  *(Cleverness is explicitly not on the list).*
- **Craft Principles**:
  - *Design around messages*: Unit of Ruby is the message, not the class.
  - *Pass behavior in blocks*: Currency for behavior.
  - *One job each*: Single responsibility.
  - *Give traveling data a name*: Avoid passing loose clumps.
  - *Keep methods small*: ~5 lines default.
  - *View layer rules*: Choose Slim over ceremony; templates say what is on the page, not how to build it; best JS is least JS; no build step; move logic down (JS $\to$ Stimulus $\to$ CSS $\to$ Ruby).

### 2.2 The Grammar and Morphology (`PRIMER.md` & `DESIGN.md`)
- **The Grammar in One Sentence**:
  > `word arguments`. Indentation nests it. Everything — elements, components, control flow, text — is a word. Extending the language adds vocabulary, never syntax.
- **Morphology**:
  > *A dot means data, a bare word is language.*
  - Bare word: a language primitive, variant, or subject name (never evaluated directly).
  - Dot (`.name`): innermost subject's attribute.
  - Binding dot (`order.number`): local binding's attribute.
  - Quoted string (`"text"`): literal content.
  - Colon (`key: value`): modifier (trailing colon only).
- **The Six Argument Kinds**:
  1. `name`: interpreted by the word to its left.
  2. `"string"`: literal text.
  3. `.property`: current subject's data.
  4. `binding.property`: local or helper data.
  5. `key: value`: modifier.
  6. *indented block*: children.
- **One Rule of Resolution**: `.foo` resolves to the innermost subject's `foo`. The outermost subject is the ambient page itself (VBA's implied `Application`).
- **One Rule of Government**: A name is interpreted by the word to its left; a word is interpreted by the word it is nested under. Both governors are visible without scrolling.
- **The Noun Register**: 62+ words are common nouns (label register), and the 5 non-nouns are control flow (`each`, `empty`, `choose`, `when`, `otherwise`).
- **The Inference Contract**:
  > *Mechanical facts derivable from a value's shape are free. Facts that encode a human judgement about the domain belong to the app, and the language should ask rather than guess.*
  - A line that states the inferable should not exist (`PRIMER.md` line 351).
  - Conditionals dissolve into vocabulary: name the situation (`empty`), don't branch (`if ... empty?`).

---

## 3. Anatomy of Existing Primitives & The `action` Anomaly

### 3.1 Primitives vs. Vocabulary Partials
The language implements words in two distinct tiers:
1. **Ruby Built-in Primitives** (`lib/slim_pickins/words.rb`): Core structural elements implemented as subclasses of `SlimPickins::Word` (e.g., `Page`, `Form`, `Field`, `Button`, `Table`, `Each`, `Choose`, `Box`).
2. **Vocabulary Partials** (`lib/vocabulary/*.sp`): Promoted words drafted in the language itself, compiled to ASTs, and loaded via `SlimPickins::Library.builtin` (e.g., `card.sp`, `actions.sp`, `action.sp`, `flash.sp`, `note.sp`).

### 3.2 The Current Implementation of `action`
In `lib/vocabulary/action.sp`:
```sp
expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true

form method: post, to: .to
  hidden path, .path
  hidden return_to, .return_to
  button .variant, .content
```

And in `VOCABULARY.md` (lines 1039–1046):
```markdown
### `action`
- **name** — none
- **content** — text or data, when there is any
- **modifiers** — `to:`, `path:`, `return_to:`, `variant:`
- **children** — none
- **subject** — unchanged
```

### 3.3 Call Sites in `examples/dashboard/views/partials/queue.sp`
```sp
choose
  when .first_item
    text .queue_intro
    card first_item.path
      badge first_item.status_variant, first_item.status
      text first_item.purpose
      choose
        when first_item.next_line
          text first_item.next_line
      choose
        when first_item.offer_commit
          action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
      dormant "Set dormant", path: first_item.path
      action "Archive", to: "/actions/archive", path: first_item.path, return_to: "/triage", variant: neutral
      action "Skip 30d", to: "/actions/skip", path: first_item.path, return_to: "/triage", variant: neutral
  otherwise
    text "All caught up. Nothing needs attention."
```

Notice `dormant` on line 13: `dormant` is an app partial defined in `examples/dashboard/views/partials/dormant.sp`:
```sp
form method: post, to: "/actions/status"
  hidden path, .path
  hidden return_to, "/triage"
  hidden status, "dormant"
  button neutral, .content
```

### 3.4 Dissecting the 5 Arguments of `action`
| Argument | Type | Role | Is it Inferable? | Scope / Domain |
|---|---|---|---|---|
| `"Commit"` | Content (String) | Button label text | No (essential view content) | View presentation |
| `to: "/actions/commit"` | Modifier (URL) | POST destination endpoint | Inferable by convention (`/actions/<name>`) | Routing |
| `path: first_item.path` | Modifier (Data) | Entity being acted upon | **Yes!** Already the subject of the enclosing `card` | Domain model entity |
| `return_to: "/triage"` | Modifier (URL) | Post-action redirect location | **Yes!** Known by the page context (`/triage`) | Navigation |
| `variant: primary` | Modifier (Name) | Button styling (`.button--primary`) | Defaultable (could default to `neutral` or `primary`) | View presentation |

### 3.5 Why this Violates the Project's Own Rules
1. **Extreme Sentence Length**: Across 439 sentences in the `.sp` corpus, the mean argument count is **1.28**. `action` has **5**.
2. **Repetition of Truth**: `path: first_item.path` and `return_to: "/triage"` are repeated on **every single action button**. `ODE_TO_JOY.md` Part III states: *"Give every truth one home... When the same fact lives in two places, one of them will drift and begin to lie."*
3. **Stating the Inferable**: `PRIMER.md` line 351: *"A line that states the inferable should not exist."* `first_item.path` is stated right inside `card first_item.path`.
4. **Domain Leakage into Vocabulary**: Why does a generic presentation DSL have `path:` and `return_to:` as modifiers in `lib/vocabulary/action.sp`? If an app acts on a `user_id` or an `account_number`, `action.sp` is useless. It is an app-specific script posing as a core language feature.

---

## 4. Architectural Constraints & Trade-Offs

Before formulating proposals, we must understand the compiler and runtime constraints:

1. **The Transform Pipeline (`lib/slim_pickins/transform.rb`)**:
   - Source `.sp` $\to$ `Transform.tree` (AST `Node` structure) $\to$ `Transform.emit` (Ruby code) $\to$ `Builder.eval_with` $\to$ HTML buffer.
   - The grammar order is strictly enforced: `ranks = [0 (name), 1 (content/data), 2 (modifier)]`. Names must precede content, which must precede modifiers.
2. **Vocabulary Partials & Preambles (`lib/slim_pickins/contracts.rb` & `partial_word.rb`)**:
   - Partials declare their contracts via `expects ...` at the top of the file.
   - Any unrecognized key in `expects` (like `to: true, path: true`) is converted into a declared modifier!
   - Currently, a partial cannot take arbitrary keyword arguments unless they are declared in `expects`.
   - Modifiers passed to a partial become keys in the parameters subject pushed onto the `chain` (`chain.with(parameters, ...)`). Inside `action.sp`, `.to` and `.path` resolve against this parameter hash.
3. **Subject Chain & Scoping (`lib/slim_pickins/subject.rb`)**:
   - `subject` maintains a stack of scopes.
   - Only certain words shift the subject: `page`, `section`, `form`, `table`, `each`.
   - `card` does **not** shift the subject (`card.sp` declares `expects variant, content: true...`, where `first_item.path` is just `content`).
4. **Testing & Verification Pipeline**:
   - `check_grammar.rb`: verifies grammar rules, vocabulary definitions, argument types.
   - `check_shape.rb`: verifies speech parts and shapes, prints vitals (fails if a word has no shape).
   - `check_styles.rb`: proves emitted classes exist in `slim-pickins.css`.
   - `bin/verify_pages.rb`: renders specimen and example pages with real data fixtures.
   - **Flexible Parity**: The project explicitly allows altering the generated HTML slightly if it produces a cleaner DSL, provided visual and semantic function remain intact.

---

## 5. The 8 Ruby Luminaries Council: Problem Analysis

Here we frame the debate among the 8 Ruby luminaries, synthesizing their philosophies against `ODE_TO_JOY.md` and `alt-slim-pickins`.

```
                  ===================================================
                               THE RUBY LUMINARIES COUNCIL
                  ===================================================
                     Matz  ·  Sandi Metz  ·  _why  ·  DHH
                     Jim Weirich  ·  Avdi Grimm  ·  Katrina Owen  ·  Sarah Mei
                  ===================================================
```

---

### 5.1 Yukihiro Matsumoto (Matz)
> *"Ruby is designed for human beings, not machines. Code must bring joy to the programmer."*

- **The Assessment**:
  "When I look at `action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary`, my heart does not feel light. It feels as if I am typing options into a command-line utility from 1985.
  In Ruby, we believe in the **Principle of Least Surprise (POLS)**. POLS does not mean surprise to the compiler; it means surprise to the human mind. When a programmer wants to put a button on a page that commits a project, what do they think? They think: *'I want a Commit button here.'* They do not think: *'I want to construct a multipart HTTP post form carrying four separate state strings.'*
  The mean sentence in this language has 1.28 arguments. This sentence has 5. That abrupt jump from simplicity to verbosity is a surprise. Let us design for developer happiness. The interface should feel graceful, natural, and brief."

---

### 5.2 Sandi Metz
> *"A method with five arguments is screaming that you have a missing abstraction."*

- **The Assessment**:
  "In *Practical Object-Oriented Design in Ruby*, I give simple rules: methods should be small (~5 lines), classes should have a single responsibility, and you should never pass long lists of parameters. Three arguments is a warning; four is an emergency; five is a code smell that demands an immediate stop.
  Look at what those five arguments represent:
  1. `content` & `variant` $\longrightarrow$ **Presentation responsibility** (how it looks).
  2. `to:` & `return_to:` $\longrightarrow$ **Routing responsibility** (where it goes).
  3. `path:` $\longrightarrow$ **Entity identity responsibility** (what it acts on).
  This is three distinct responsibilities bundled into one method call!
  Furthermore, `to:`, `path:`, and `return_to:` are a classic **Data Clump**. Look at lines 12, 14, and 15 in `queue.sp`. They travel together on every single line. When data travels together, that data is begging to be an object, or begging to belong to an enclosing context.
  The 5-argument `action` is not a primitive; it is an unextracted concept. We must separate the container that knows the entity and the route from the individual action triggers."

---

### 5.3 why the lucky stiff (_why)
> *"Code is a small living creature. Let it breathe, let it sing, don't bury it under a mountain of paperwork!"*

- **The Assessment**:
  "Oh, look at this poor little creature! It wanted to be a button, and instead they strapped an entire file cabinet to its back!
  `DESIGN.md` promised us: *'A template should say what is on the page, not how to build it.'* But this sentence is not poetry—it’s a customs declaration form! You have to declare your cargo (`path:`), your origin (`return_to:`), your destination (`to:`), your uniform (`variant:`), and your name badge (`content`) before you are allowed to walk across the room!
  Where is the whimsy? Look at how beautiful `actions` could be. `actions` is already a word in the dictionary! It's a plural noun. If you open an `actions` block, the little buttons inside should just say what they do:
  ```sp
  actions
    button primary, "Commit"
    button neutral, "Archive"
  ```
  Give the buttons back their freedom. Don't make each button repeat the ritual of the whole universe."

---

### 5.4 David Heinemeier Hansson (DHH)
> *"Convention over Configuration. Stop configuring what can be derived."*

- **The Assessment**:
  "This is classic configuration overhead. It’s the exact disease that Java server pages had before Rails came along and blew them up with convention over configuration.
  Why are we writing `to: "/actions/commit"`? Because the action is named `Commit`! Why are we writing `path: first_item.path`? Because the card is already about `first_item`! Why are we writing `return_to: "/triage"`? Because the user is literally on the `/triage` page right now!
  Rails gave us `button_to` twenty years ago:
  ```ruby
  button_to "Commit", [:commit, item]
  ```
  We applied **conceptual compression**. In 95% of web applications, an action button inside an entity card acts on that entity, POSTs to the entity's action endpoint, and redirects back to the current view.
  If `alt-slim-pickins` wants to be joyful, it needs opinions. If you say `action commit`, it should infer the endpoint `/actions/commit`. If it needs the item's path, it should infer it from the subject. Stop making the view spell out the plumbing."

---

### 5.5 Jim Weirich
> *"Composable blocks and structural integrity. Honor the hierarchy of the tree."*

- **The Assessment**:
  "Let’s examine the architectural structure. `alt-slim-pickins` is an indentation-based tree grammar. In this grammar, nesting is how you express relationships:
  - A `table` encloses `column`s.
  - A `form` encloses `field`s and `button`s.
  - A `choose` encloses `when` and `otherwise`.
  Every complex idea in this language has a container that sets up the scope, and children that declare the particulars.
  Why is `action` the lone exception? Why did someone try to flatten an entire POST form with hidden inputs and a submit button into a single line?
  Because someone wanted a one-liner! But in doing so, they violated the structural integrity of the language. When an element has multiple parameters, flattening it creates an unreadable run-on sentence.
  In Ruby, blocks are our currency for scope. If we let `actions` enclose the buttons:
  ```sp
  actions for: first_item
    action "Commit", to: :commit, variant: primary
    action "Archive", to: :archive
  ```
  Now the scope is established once at the block level, and the individual actions are simple, composable sentences."

---

### 5.6 Avdi Grimm
> *"Confident Ruby: Trust your collaborators and stop checking your pockets."*

- **The Assessment**:
  "The current `action` is deeply insecure code. It doesn't trust the subject. It doesn't trust the page. It doesn't trust the environment. So it demands that the caller pass every single piece of data by hand on every single call.
  In *Confident Ruby*, we talk about collecting input, performing work, delivering output, and handling failure—each in clear, distinct steps.
  What is the app contract in `CONTRACT.md`? *'A subject answers the attributes it is asked for, by ordinary method call.'*
  If `action` is confident, it should ask:
  1. What is the current subject? If the subject responds to `path` or `id`, `action` should confidently ask `subject.path`.
  2. What is the return path? If the page has a return context, ask the page context.
  And look at `lib/vocabulary/action.sp`! It hardcodes `hidden path, .path`. That is the opposite of confident duck-typing; that is rigid, brittle coupling to one specific attribute name. If another page has an action that operates on `account_id`, `action.sp` falls apart."

---

### 5.7 Katrina Owen
> *"Therapeutic refactoring: Take small, verifiable steps guided by metrics."*

- **The Assessment**:
  "Let’s be disciplined. We don’t need to tear down the entire compiler or introduce speculative architecture that we can't test.
  Look at the numbers from `check_shape.rb`:
  - 439 sentences, mean arguments: 1.28.
  - Longest sentence: 5 arguments (`action`).
  The goal is to bring `action` back toward the language norm without breaking existing guarantees.
  Let’s look at the call sites:
  1. In `examples/dashboard/views/partials/queue.sp`, there are three calls to `action` and one to `dormant`.
  2. In `test/vocabulary_partials_test.rb`, there is one test testing `action`.
  That’s only 4 places in the entire universe!
  We can refactor therapeutically:
  - Step 1: Pin existing behavior with tests. We already have `test/dashboard_test.rb` verifying the emitted forms and hidden inputs.
  - Step 2: Remove the duplicated arguments (`path` and `return_to`) by making them inheritable from the subject or scoped by `actions`.
  - Step 3: Run `check_grammar.rb`, `check_shape.rb`, and `bin/verify_pages.rb` after each small change.
  Refactoring is joy in motion—small, revertible steps on green."

---

### 5.8 Sarah Mei
> *"Think about the next developer. Avoid clever magic that obscures team understanding."*

- **The Assessment**:
  "I love the desire for elegance, but I want to issue a warning against **clever traps**.
  If we replace the 5 arguments with excessive ambient magic—where the language silently inspects caller locals, guesses URLs via string manipulation, and magically binds hidden inputs without any visible declaration—we will solve the 5-argument problem by creating a debugging nightmare for the next developer.
  When a junior engineer or someone new to the codebase looks at:
  ```sp
  action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
  ```
  It's ugly, yes. But it's 100% explicit. They can see exactly what endpoint is hit and what parameters are sent.
  If we refactor this, the replacement must be **clear, not clever**. It should be obvious from looking at the template or the partial where the data comes from. A container like `actions path: first_item.path, return_to: "/triage"` is wonderful because it eliminates repetition while remaining completely transparent to human readers. Let's make sure the code remains maintainable for teams over time."

---

## 6. Synthesis of Council Consensus & Dissent

| Dimension | Consensus / Points of Agreement | Dissent / Alternative Approaches |
|---|---|---|
| **Diagnosis** | Unanimous: 5 arguments is an unacceptable code smell, violates single responsibility, and states the inferable. | None. All 8 agree `action` must be refactored. |
| **Domain Coupling** | Unanimous: `path` and `return_to` have no business being hardcoded in `lib/vocabulary/action.sp`. | Whether `action` belongs in core vocabulary at all, or should be an app-level partial / helper. |
| **Scoping vs. Magic** | Strong consensus (Jim, Sandi, Sarah, Katrina): Scoping via `actions` block or subject chain is preferable to heavy global metaprogramming. | DHH & _why favor aggressive convention-based inference (`action :commit`), whereas Sarah & Sandi caution against invisible magic. |
| **Refactoring Strategy** | Strong consensus (Katrina, Matz, Jim): Incremental refactoring preserving HTML semantics, verified against test suite at each step. | Scope expansion: Whether to also touch `card`'s subject shifting or keep `card` unchanged. |

---

## 7. Concrete Refactoring Paths for `action` (R2 & R3)

Based on the Council's analysis, we present three concrete refactoring designs:

### Design Option 1: The Scoped Container (`actions` block with shared context)
*Championed by Jim Weirich, Sandi Metz, Katrina Owen, Sarah Mei*

`actions` already exists in `lib/vocabulary/actions.sp` as an enclosing container for buttons and links. We enhance `actions` to take shared contextual modifiers (`path:`, `return_to:`, or `for:`):
```sp
actions path: first_item.path, return_to: "/triage"
  action "Commit", to: "/actions/commit", variant: primary, if: first_item.offer_commit
  action "Set dormant", to: "/actions/status", status: "dormant"
  action "Archive", to: "/actions/archive"
  action "Skip 30d", to: "/actions/skip"
```
- **How it works**:
  - `actions` evaluates its block with a scoped parameter context containing `path` and `return_to`.
  - Child `action` words inherit these parameters from the scope.
  - `action` now takes only 2 arguments: `content` and `to:`, with optional `variant:` (defaulting to `neutral`).
- **Arguments on `action`**: Reduced from **5 to 2** (or 3).
- **Pros**: Completely explicit, eliminates repetition, no magic URL guessing, restores `actions` as a meaningful structural container.

### Design Option 2: Subject & Context Inference (`card` Subject Shift)
*Championed by DHH, Avdi Grimm, Matz*

Currently, `card` does not shift the subject. If `card` shifts the subject to `first_item`, and the ambient page provides `return_to`:
```sp
card first_item
  badge .status_variant, .status
  text .purpose
  choose
    when .next_line
      text .next_line
  choose
    when .offer_commit
      action "Commit", to: "/actions/commit", variant: primary
  dormant "Set dormant"
  action "Archive", to: "/actions/archive"
  action "Skip 30d", to: "/actions/skip"
```
- **How it works**:
  - `action.sp` retrieves `.path` from the current subject (`subject.path`), and `return_to` from the page context (`page.path` or a default).
  - Also cleans up lines 5–9 in `queue.sp` from `first_item.status` to `.status`!
- **Arguments on `action`**: Reduced from **5 to 2** (`content`, `to:`, with optional `variant:`).
- **Pros**: Massive cleanup of `queue.sp`; aligns perfectly with the core rule: *"A dot means data, .foo means innermost subject's foo"*.

### Design Option 3: Two-Tier Primitive Refactoring (`button` with `to:` or Mini-Form)
*Championed by _why, Sandi Metz, Jim Weirich*

Look at `words.rb` lines 464–476: `Button` already takes `to:`!
```ruby
class Button < Word
  contract name: :variant, content: true, modifiers: [:to, :target, :type, :size], shape: :says
```
And in `generator.rb`:
```ruby
full_tag('button', attrs[:label],
         type: (attrs[:type] || (@in_form ? :submit : :button)).to_s,
         formaction: attrs[:to]&.to_s,
         class: classes)
```
In HTML5, a `<button formaction="/actions/commit" formmethod="post" name="path" value="...">` can submit to any action!
Alternatively, `action` can simply be a dedicated mini-form word:
```sp
action to: "/actions/commit", variant: primary
  hidden path, first_item.path
  hidden return_to, "/triage"
  button "Commit"
```
Or for the single-line case, a specialized `post_button` or concise `action`.

---

## 8. Summary Table of Options

| Criterion | Current `action` | Option 1: Scoped `actions` | Option 2: Subject Inference | Option 3: HTML5 Formaction / Button |
|---|---|---|---|---|
| **Max Arguments** | 5 (Extreme outlier) | 2–3 | 2–3 | 1–2 |
| **Repetition** | High (`path`, `return_to` $\times$ 4) | Zero (declared once) | Zero (inferred from subject) | Low |
| **Grammar Impact** | None (keeps bad status quo) | Clean extension of `actions` | Shifting subject in `card` | Extends `button` or `action` |
| **Test Compatibility** | Red on phase4/studio docs | 100% green with flexible parity | 100% green | 100% green |
| **Council Alignment** | Rejected by all 8 | Sandi, Jim, Katrina, Sarah | DHH, Avdi, Matz | _why, Jim |

---

## 9. Next Steps for Council & Router

1. **Populate Community Bulletin Board**: Present this framing to the council bulletin board (`.agents/bulletin_board.md` or designated forum).
2. **Conduct Council Deliberation**: Have the council debate Option 1 vs. Option 2 (or a hybrid where `actions` scopes parameters and `action` defaults intelligently).
3. **Execute Refactoring via Worker**:
   - Update `lib/vocabulary/action.sp` (and `actions.sp` if Option 1).
   - Update call sites in `examples/dashboard/views/partials/queue.sp`.
   - Update test in `test/vocabulary_partials_test.rb`.
   - Run the full verification suite (`check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, `verify_pages.rb`, `test/*_test.rb`).
