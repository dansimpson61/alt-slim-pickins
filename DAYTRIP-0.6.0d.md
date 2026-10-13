# Daytrip 0.6.0d — The Action of Conventions: Universal Slots, Taxonomy & Gate Hygiene

**Status: planned 2026-10-13, ready for implementation in a fresh session.**

Fulfilling the fourth movement of Roadmap 0.6:
1. **The Action of Conventions & Universal Slot Model**:
   - Establish the universal convention law: *That which can be inferred need not be spoken*.
   - A sentence follows the universal structure: `word [target], [override], [kwargs]`.
   - A bare positional target (`my_word accounts`) resolves against context (`subject`, `locals`, `helpers`), automatically inferring and populating `.label`, `.id`, `.noun`, and `.target`.
   - An optional second positional argument overrides the inferred label directly: `my_word accounts, "Investments"` (or standalone `my_word "Investments"`).
   - Kwargs (`key: value`) serve as the universal, open configuration mechanism, replacing ad-hoc named slots across words.
2. **Decouple `Builder` Parameter Binding**:
   - Update `Builder#define_single_local_word` and `bind_parameters` to bind positional parameters by slot index and contract capability rather than looking for hardcoded magic keys (`bound[:subject]`, `bound[:content]`, `bound[:variant]`).
   - Eliminate domain model shadowing hazards where `bound[:content]` or `bound[:subject]` with `nil` shadowed underlying model attributes like `article.content` or `email.subject`.
   - Refactor vocabulary partials (`card.sp`, `section.sp`, `title.sp`, `footer.sp`, `paragraph.sp`, `time.sp`) to declare meaningful domain parameter names instead of internal compiler jargon.
3. **Formalize System Vocabulary Taxonomy**:
   - Codify the 7 core taxonomy terms in `lib/slim_pickins/taxonomy.rb` (`word`, `primitive`, `partial`, `def`, `contract`, `tin`, `spiff`) with programmatic accessors and tests in `test/taxonomy_test.rb`.
   - Update `bin/census_polysemy.rb` to report against this formal taxonomy.
   - Disambiguate *Word Contract* ([`lib/slim_pickins/contracts.rb`](lib/slim_pickins/contracts.rb), AST constraints) from *App Contract* ([`CONTRACT.md`](CONTRACT.md), how models answer attributes).
4. **Audit and Retire Obsolete Gate Requirements**:
   - `bin/check_conventions.rb`: Retire the hardcoded `unless declared_inferences == %i[card section]` snapshot assertion that prevents other words from declaring inferences.
   - `check_grammar.rb`: Remove the obsolete scan for `expects ...: true` (a syntax retired in 0.5.0).
   - `bin/generate_vocabulary.rb` & `contracts.rb`: Collapse the 10 pseudo-types of `name` (`:variant`, `:destination`, `:notation`, `:topic`, `:attribute`, `:subject`, etc.) into what the grammar and gate actually care about (target name vs. `:none`), ending the self-referential generator circle.
5. **Documentation & Pedagogy from First Principles**:
   - Update `PRIMER.md`, `CONVENTIONS.md`, and `VOCABULARY.md` to teach conventions explicitly from the author's viewpoint: resolution, automatic inferences, explicit overrides, and kwargs.

---

## Part 1 — The Architecture of Conventions

### The Problem
Over five roadmaps, vocabulary words accumulated ad-hoc named slot categories (`:attribute`, `:subject`, `:variant`, `:destination`, `:topic`, `:notation`, `:value`, `:name`). Each was an ad-hoc compiler attempt to map a positional bare symbol into a specific keyword argument.

This produced two forms of damage:
1. **Compiler jargon in partial definitions:** Partials were forced to write `def card, subject, content` and `def section, subject, content` because the compiler looked for keys literally named `:subject` and `:content`.
2. **Model shadowing bugs:** Because `bound` was pushed as an overlay onto the lookup chain, any model responding to `#content` (e.g. `document.content` in `doc_reader`) or `#subject` was shadowed with `nil` whenever a partial was invoked without that slot.

### The Resolution: Target, Inferred Label, Explicit Override, Kwargs
Conventions provide the magic:
```sp
my_word accounts
```
1. **Target**: `accounts` resolves against the context to the underlying collection or record.
2. **Inference**: From that target, slim-pickins automatically infers:
   - `.label` — the humanized name or `label_for(:accounts)` (`"Accounts"`).
   - `.id` — the DOM identifier (`"account-1"`).
   - `.noun` — the singular entity noun (`"account"`).
   - `.target` — the entity itself.
3. **Override**: If the author wants a different UI label, they simply speak it:
   ```sp
   my_word accounts, "Investments"
   ```
   `"Investments"` overrides `.label`.
4. **Kwargs**: Any additional modifier or option is passed via kwargs:
   ```sp
   my_word accounts, variant: :primary, open: true
   ```

---

## Part 2 — The Seven System Taxonomy Definitions

Codified in `SlimPickins::Taxonomy::SYSTEM`:

1. **`word`**: The fundamental syntax unit of slim-pickins (`word arguments`, indentation nests). Everything on a page is a word (64 canonical + app words).
2. **`primitive`**: A built-in word implemented directly in Ruby as a subclass of `SlimPickins::Word` (41 canonical primitives).
3. **`partial`**: A reusable word defined in slim-pickins itself in a `.sp` template file using `def` (23 canonical in `lib/vocabulary/` + app partials).
4. **`def`**: The language keyword that defines a partial's word and parameter list, opening its lexical family and binding call arguments.
5. **`contract`**: The compile-time grammatical specification of what a word takes and holds, enforced by the gate before render.
6. **`tin`**: The outer HTML document chrome (`.tin`), splicing page contents.
7. **`spiff`**: Companion spatial and visual stylesheet language (`.spiff`), compiling layout declarations to CSS without runtime overhead.

---

## Part 3 — Ordered Implementation Steps (For the Fresh Session)

### Step 1: Gate Hygiene & Obsolete Check Retirement
- In `bin/check_conventions.rb`, remove the hardcoded `declared_inferences == %i[card section]` check and ensure inference registration is dynamic.
- In `check_grammar.rb`, remove the dead `expects ...: true` regex check.
- Verify that `ruby -Ilib:test test/instruments_test.rb` and `bin/check_conventions.rb` stay green.

### Step 2: Decouple `Builder` Parameter Binding
- In `lib/slim_pickins/builder.rb`, update `bind_parameters` and `define_single_local_word`:
  - Determine target and content positionally by slot index based on `contract.name` and `contract.content`, not by checking whether keys are named `:subject` or `:content`.
  - Populate `.label` from `label_for` or humanized target name whenever a target is bound, overridden by the content string if provided.
  - Populate `.id` from target if contract indicates entity identification.
  - Forward undeclared kwargs cleanly without requiring ad-hoc contract slots.
- Verify that `test/def_test.rb` and `test/combination_test.rb` pass.

### Step 3: Refactor Vocabulary Partials
- In `lib/vocabulary/card.sp`:
  ```sp
  def card, target, title
    box .variant, id: .id
      choose
        when .title
          heading .title
      contents
  ```
- In `lib/vocabulary/section.sp`:
  ```sp
  def section, target, heading
    box .name
      choose
        when .heading
          heading .heading
      contents
  ```
- Align `title.sp`, `footer.sp`, `paragraph.sp`, and `time.sp` to use domain-revealing parameter names.
- Run `bin/verify_pages.rb` to ensure all 35 pages remain byte-identical.

### Step 4: Formalize System Taxonomy in Code & Census
- In `lib/slim_pickins/taxonomy.rb`, add `SYSTEM` definitions and query methods (`system_terms`, `system_term(name)`).
- Add tests to `test/taxonomy_test.rb` asserting all 7 terms are present, distinct, and documented.
- Update `bin/census_polysemy.rb` to display the formal system taxonomy boundaries.

### Step 5: Docs & Pedagogy Alignment
- Update `PRIMER.md`, `CONVENTIONS.md`, and `VOCABULARY.md` to teach the universal convention model (Target, Inferred Label, Override, Kwargs).
- Clarify *Word Contract* vs. *App Contract* in `CONTRACT.md` and `contracts.rb`.
- Run `bin/generate_vocabulary.rb` and `check_grammar.rb` to ensure vocabulary documentation is fully synchronized.

### Step 6: Full Verification Loop
- Run all 12 gate legs via `ruby -e 'require_relative "studio/status"; puts StudioStatus.run.map(&:state)'`.
- Ensure all 35 verified pages remain byte-identical (`ruby bin/verify_pages.rb`).
- Ensure `ruby -w -c` is clean across the repository.
- Verify full test suite passes with 0 failures (`ruby -Ilib:test -e 'require "slim_pickins/census"; SlimPickins::Census.test_files.sort.each { |f| require f }'`).
