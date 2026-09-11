# COMMUNITY BULLETIN BOARD
## The Ruby Luminaries Council on `alt-slim-pickins`
### Assessing and Refactoring the `action` Primitive

---

## 1. Council Charter & Team Norms

### The Council
We are eight stewards of the Ruby soul, gathered to evaluate `alt-slim-pickins` and restore joy, clarity, and structural honesty to its view grammar:
- **Yukihiro Matsumoto (Matz)** — Creator of Ruby; guardian of developer happiness and the Principle of Least Surprise (POLS).
- **Sandi Metz** — Author of *POODR*; defender of single responsibility, small interfaces, and eradicating parameter code smells.
- **why the lucky stiff (_why)** — Bard of Ruby; champion of poetic conciseness, playful whimsy, and living DSLs.
- **David Heinemeier Hansson (DHH)** — Creator of Ruby on Rails; champion of convention over configuration and conceptual compression.
- **Jim Weirich** — Master craftsman; champion of block composability, structural hierarchy, and tree integrity.
- **Avdi Grimm** — Author of *Confident Ruby*; champion of duck typing, trust between collaborators, and intentional design.
- **Katrina Owen** — Creator of Exercism; champion of therapeutic refactoring, small verifiable steps, and empirical metrics.
- **Sarah Mei** — Architect and founder; champion of long-term maintainability, team readability, and avoiding clever traps.

### Team Norms & Operating Principles
Governed by the **Ode to Joy** (`ODE_TO_JOY.md`) and the **Slim-Pickins Way** (`PRIMER.md`):
1. **Precedence**: Correctness > The House > Clarity > Idiom > Elegance. Cleverness is not on the list.
2. **Honesty over Perfection**: Report suites that are red; never silently patch or conceal broken tests.
3. **Ugliness is a Defect**: A sentence that works but reads like a bureaucratic form is broken.
4. **Omit the Inferable**: *"A line that states the inferable should not exist."* Give every truth one home.
5. **Therapeutic Progress**: Small, disciplined steps. Run checkers and tests before and after every touch.

---

## 2. The Problem: The Longest Sentence in the Language

### The Empirical Evidence
Across all 439 sentences in `alt-slim-pickins` (mean sentence length: 1.28 arguments), three lines in `examples/dashboard/views/partials/queue.sp` stand out as extreme 5-argument outliers:

```slim
action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
action "Archive", to: "/actions/archive", path: first_item.path, return_to: "/triage", variant: neutral
action "Skip 30d", to: "/actions/skip", path: first_item.path, return_to: "/triage", variant: neutral
```

In `lib/vocabulary/action.sp`, `action` is declared as a vocabulary partial:
```slim
expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true

form method: post, to: .to
  hidden path, .path
  hidden return_to, .return_to
  button .variant, .content
```

### The Sibling Symptom: `dormant.sp`
Because `action.sp` hardcoded `path` and `return_to`, when the triage queue needed to offer a fourth button with a `status="dormant"` payload, `action` could not express it. The author was forced to author a one-off ad-hoc partial (`examples/dashboard/views/partials/dormant.sp`):
```slim
form method: post, to: "/actions/status"
  hidden path, .path
  hidden return_to, "/triage"
  hidden status, "dormant"
  button neutral, .content
```

---

## 3. The Council Debate

### Yukihiro Matsumoto (Matz)
> *"Ruby is designed for human beings, not machines. A DSL must bring joy, not fatigue."*

"When I look at this `action` sentence, I feel sorrow. The average sentence in `alt-slim-pickins` is 1.28 arguments. It has words like `text .purpose` or `link "Details"` or `badge .status`. That is natural, light, and joyful.

Then suddenly the programmer encounters:
```slim
action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
```
This is not human prose. This is a command line utility from 1985 with five flags!
In Ruby, we honor the Principle of Least Surprise. What does a programmer want to say here? They want to say: *'Here is a primary button that commits.'* They do not want to construct a multipart HTTP POST form carrying four separate state strings by hand on every button.

Let us return joy to this grammar. The sentence must be concise, expressive, and serene."

---

### Sandi Metz
> *"Five arguments is a distress flare. It is screaming that you have a missing abstraction."*

"Matz is right about the feeling, and the code explains why: this method has too many responsibilities and suffers from a textbook **Data Clump**.

Look at the five arguments:
1. `content` and `variant:` belong to **Presentation**.
2. `to:` and `return_to:` belong to **Routing and Navigation**.
3. `path:` belongs to **Entity Identity**.

Three distinct responsibilities in one line!
Even worse: `path: first_item.path` and `return_to: "/triage"` appear identically on lines 12, 14, and 15 of `queue.sp`. When a group of parameters always travels together across multiple call sites, that group is a concept waiting to be born.

Notice what happened when `dormant.sp` was needed: because the data clump was rigid, the abstraction shattered immediately upon encountering a third parameter (`status: "dormant"`).

The missing abstraction is twofold:
1. A **scope** that holds the common payload context (`path` and `return_to`).
2. An **action trigger** that simply names its verb and endpoint."

---

### why the lucky stiff (_why)
> *"Code is poetry! Why make a button drag a filing cabinet across the screen?"*

"Look at this poor little button! It just wanted to say *'Commit'*, and instead someone loaded it down with sacks of gravel: `path: this, return_to: that, to: the_other`!

Look at the rest of the dictionary in `VOCABULARY.md`. We have `actions`! `actions` is already a word! It’s a plural noun. It’s a lovely, roomy box where buttons go to play together. In the portfolio example, we write:
```slim
actions
  link "Deposit", to: ...
  link "Withdraw", to: ...
```
Why on earth are the triage buttons in `queue.sp` wandering out in the cold without an `actions` box?
If you put them in an `actions` box, the box can hold the context, and the buttons inside can just sing:
```slim
actions path: first_item.path, return_to: "/triage"
  action "Commit", to: "/actions/commit", variant: primary
  action "Archive", to: "/actions/archive"
```
Give the buttons their freedom!"

---

### David Heinemeier Hansson (DHH)
> *"Convention over Configuration. Why write down what the system already knows?"*

"This is the exact configuration bloat that Rails was built to destroy.
Why are we repeating `return_to: "/triage"` when the user is literally on the `/triage` page?
Why are we writing `path: first_item.path` on four consecutive lines when the card is titled `card first_item.path`?

Twenty years ago in Rails, we built `button_to`. We applied **conceptual compression**: an action inside a resource card acts on that resource, posts to its endpoint, and returns to the current view by default.

If `alt-slim-pickins` wants to be idiomatic and productive, it should allow conventions to carry the weight. At minimum, the enclosing card or container should establish the subject, and child actions should inherit that subject without noisy repetition."

---

### Jim Weirich
> *"Honor the hierarchy of the tree. Blocks are how Ruby expresses scope."*

"Let’s examine the grammar's architecture. `alt-slim-pickins` is an indentation-based tree language. In a tree language, nesting is the primary mechanism for establishing scope and relationships:
- A `table` encloses `column`s.
- A `form` encloses `field`s.
- A `choose` encloses `when` and `otherwise`.

Every complex concept in this DSL has a container that sets up scope, and children that declare particulars.
The 5-argument `action` was an attempt to flatten a form, two hidden fields, and a submit button into a single line. In trying to make it a one-liner, the author destroyed the language's structural composability.

Look at how `actions.sp` is defined:
```slim
expects children: "link button", shape: encloses
box
  children
```
If we permit `actions` to accept parameters (`path:`, `return_to:`) and enclose `action` children, the indentation tree naturally expresses the shared scope. The structure reflects the meaning."

---

### Avdi Grimm
> *"Confident Ruby: Stop checking pockets and trust your collaborators."*

"The current implementation of `action` is timid Ruby. It doesn't trust the enclosing subject or the page. It forces the caller to manually thread every piece of data through keyword arguments on every invocation.

In *Confident Ruby*, we talk about objects trusting their collaborators. Look at `lib/vocabulary/action.sp`: it has hardcoded `hidden path, .path`. That is not a generic primitive; that is tightly coupled to the dashboard port! What happens when another application needs an action with `user_id` or `token`? `action.sp` is powerless.

A confident `action` should:
1. Accept its primary intent: label (`content`), destination (`to:`), and style (`variant:`).
2. Inherit contextual parameters from the subject chain or enclosing container.
3. Emit hidden fields for whatever payload parameters are in scope, rather than being rigidly chained to `path`."

---

### Katrina Owen
> *"Therapeutic refactoring: Take small, measurable, verifiable steps."*

"Let's look at the metrics from `check_shape.rb`:
- Current: 439 sentences, mean 1.28 args, max 5 args.
- Target: Bring the max sentence length down from 5 to 2 or 3, without introducing regressions.

Let's look at the call sites:
- `queue.sp`: 3 calls to `action`, 1 call to `dormant`.
- `test/vocabulary_partials_test.rb`: 1 test of `action`.
- `test/dashboard_test.rb`: tests verifying form actions, methods, and hidden inputs.

We don't need a massive, speculative rewrite of the parser. We have `PartialWord`, which already supports the subject chain with overlay fallback (`chain.with(parameters, overlay: true)`).
When an outer word (like `actions`) pushes parameters onto the chain, any inner partial can read them via `.path` and `.return_to`!

Step by step:
1. Update `actions.sp` to accept `path:` and `return_to:` modifiers and allow `action` children.
2. Update `action.sp` to read `.path` and `.return_to` from the chain when not supplied directly, and support optional parameters like `status:`.
3. Update `queue.sp` to wrap the triage actions in `actions path: first_item.path, return_to: "/triage"`.
4. Replace `dormant` with `action "Set dormant", to: "/actions/status", status: "dormant"`.
5. Run the full test suite and checkers at every step."

---

### Sarah Mei
> *"Make it maintainable for real teams. Avoid clever magic traps."*

"I want to echo Katrina's discipline and issue a cautionary note to DHH and _why:
Do not solve the 5-argument problem by introducing invisible, spooky magic.

If `action` magically inspects the stack, guesses routes by chopping strings, and silently injects hidden inputs that appear nowhere in the template, we will make debugging a nightmare for the next developer who joins the project.

The scoped container proposal (`actions path: ..., return_to: ...`) strikes the perfect balance:
- It is **completely explicit**: anyone reading `queue.sp` can see exactly where `path` and `return_to` come from.
- It is **DRY**: it is written once per group of actions instead of four times.
- It is **locally scoped**: no global state, no spooky action at a distance.

This is honest, kind code that teams can maintain."

---

## 4. The Council Consensus & Design Specification

After deliberation, the Council has reached a unanimous consensus on the refactoring plan:

### Architecture: The Scoped Actions Container

1. **`lib/vocabulary/actions.sp`**:
   Enhance `actions` to take contextual modifiers (`path:`, `return_to:`) and allow `children: any` (including `action`, `link`, `button`, and `choose`):
   ```slim
   expects children: any, path: true, return_to: true, shape: encloses

   box
     children
   ```
   When `actions` evaluates, `PartialWord` pushes `{ path: ..., return_to: ... }` onto the subject chain with `overlay: true`.

2. **`lib/vocabulary/action.sp`**:
   Refactor `action` so that `path:`, `return_to:`, and `status:` are optional modifiers that resolve against the subject chain when not passed directly:
   ```slim
   expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true, status: true

   form method: post, to: .to
     choose
       when .path
         hidden path, .path
     choose
       when .return_to
         hidden return_to, .return_to
     choose
       when .status
         hidden status, .status
     button .variant, .content
   ```
   - If `path:` or `return_to:` is passed directly to `action`, it uses that value.
   - If omitted on `action`, `.path` and `.return_to` seamlessly fall through to the enclosing `actions` container on the subject chain!
   - If `status:` is passed (e.g. `status: "dormant"`), it emits `<input type="hidden" name="status" value="dormant">`.

3. **`examples/dashboard/views/partials/queue.sp`**:
   Refactor the call sites to use the clean scoped container:
   ```slim
   choose
     when .first_item
       text .queue_intro
       card first_item.path
         badge first_item.status_variant, first_item.status
         text first_item.purpose
         choose
           when first_item.next_line
             text first_item.next_line
         actions path: first_item.path, return_to: "/triage"
           choose
             when first_item.offer_commit
               action "Commit", to: "/actions/commit", variant: primary
           action "Set dormant", to: "/actions/status", status: "dormant", variant: neutral
           action "Archive", to: "/actions/archive", variant: neutral
           action "Skip 30d", to: "/actions/skip", variant: neutral
     otherwise
       text "All caught up. Nothing needs attention."
   ```

4. **Retire `dormant.sp`**:
   The ad-hoc partial `examples/dashboard/views/partials/dormant.sp` was a workaround for `action`'s inflexibility. With `action` supporting `status:`, `dormant.sp` is deleted or redirected, restoring a single unified vocabulary.

5. **Regenerate Documentation Bullets**:
   Run `ruby bin/generate_vocabulary.rb` to update `VOCABULARY.md` so `check_grammar.rb` passes with 0 problems.

---

## 5. Flexible Parity & HTML Justification

The council explicitly documents the intentional changes to the HTML structure under the project's flexible parity charter:

1. **Elimination of the ad-hoc `.dormant` CSS class on `<form>`**:
   - *Previous*: `dormant.sp` generated `<form class="form dormant" action="/actions/status" method="post">` because it was a custom partial named `dormant.sp`.
   - *Refactored*: Emits `<form class="form" action="/actions/status" method="post">` with `<input type="hidden" name="status" value="dormant">`.
   - *Justification*: `check_styles.rb` proves that `slim-pickins.css` has no rules for `.dormant`. The class was an accidental byproduct of partial file naming. The semantic payload (`status=dormant`, `path`, `return_to`) and button behavior remain 100% identical.

2. **Semantic Affordances Preservation**:
   - `bin/dashboard_parity.rb` requires 25 affordances:
     - Forms: `post /actions/commit`, `post /actions/status`, `post /actions/archive`, `post /actions/skip`.
     - Hiddens: `path=<item.path>`, `return_to=/triage`, `status=dormant`.
     - Buttons: `Commit`, `Set dormant`, `Archive`, `Skip 30d`.
   - All 25 affordances are fully preserved.

---

## 6. Proposed Additional Scope (R3)

Through this investigation, the Council identified four deeper architectural constraints in `alt-slim-pickins` that should be considered for future roadmaps:

### Scope Proposal 1: Dynamic Parameter Splatting / Forwarding in Vocabulary Partials
Currently, `lib/slim_pickins/contracts.rb` converts unrecognized keys in `expects` into rigid modifier lists. A partial cannot accept arbitrary HTML hidden inputs or keyword arguments without declaring each one in `expects` (`path: true, return_to: true, status: true`).
*Recommendation*: Support a `payload: :any` or `hidden: :hash` contract slot in `expects` so that any action or form can forward arbitrary hidden key-values without polluting the core grammar.

### Scope Proposal 2: Subject Shifting in `card`
In `queue.sp`, lines 58–64 repeatedly write `first_item.status`, `first_item.purpose`, `first_item.next_line`, and `first_item.path` because `card` does not shift the subject (`contract name: :variant, content: true`).
*Recommendation*: Allow `card` to declare `name: :subject`, enabling child sentences to write `.status`, `.purpose`, and `.path` directly. This would eliminate 7 redundant references to `first_item` and bring `queue.sp` into harmony with the rest of the DSL.

### Scope Proposal 3: HTML5 `formaction` Button Consolidation
`lib/slim_pickins/words.rb:465` already defines `button` with `to:`, and `generator.rb:533` emits `<button formaction="...">`.
*Recommendation*: In HTML5, multiple submit buttons with different `formaction` URLs can live inside a single `<form>` block. Future versions could express an action group as a single form with multiple buttons, reducing 4 separate `<form>` elements to 1.

### Scope Proposal 4: Housekeeping of Dangling Guide in `studio/docs_helper.rb`
`test/studio_docs_test.rb:68` currently fails because commit `0b054a4` deleted `design_conventions.md`, but left `design_conventions` in `StudioDocs::GUIDES`.
*Recommendation*: Remove `design_conventions` from `StudioDocs::GUIDES` in `studio/docs_helper.rb` so the test suite is 100% green.

---

Signed by the Council:
*Yukihiro Matsumoto · Sandi Metz · why the lucky stiff · David Heinemeier Hansson*  
*Jim Weirich · Avdi Grimm · Katrina Owen · Sarah Mei*
