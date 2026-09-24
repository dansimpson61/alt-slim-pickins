# Daytrip 0.4.0f — Volet 5: Package C (Lean & Elemental Kernel)

Lowering the compiled Ruby core into elemental primitives, eliminating single-consumer ad-hoc kernel leaks, and establishing the privileged vocabulary composition seam.

---

## The brief

**Operationalizing the Rubinius question (KERNEL.md, 2026-09-23):**
*What is left in Ruby because the language cannot say it, and what is left in Ruby because nobody has moved it yet?*

Volet 5 delivers Package C:
1. **Privileged `tag` Primitive & Compilation Boundary**:
   - Introduces `tag` as an elemental escape hatch strictly reserved for built-in vocabulary definitions in `lib/vocabulary/*.sp`.
   - Refused in user/app templates and app partials with a truthful compiler error: `` `tag` is a privileged primitive and may not be used in app pages ``.
   - Compilation cache partitioned on `[source, privileged]` to guarantee zero cache pollution across privilege boundaries.
2. **Absorption of Single-Consumers (`figcaption` & `summary`)**:
   - `figcaption` and `summary` were single-consumer words in the public vocabulary that only ever made sense nested directly inside `figure` and `disclosure`.
   - Absorbed directly into `lib/vocabulary/figure.sp` (`tag figcaption, .content`) and `lib/vocabulary/disclosure.sp` (`tag summary, .content`).
   - Deleted `Words::Figcaption`, `Words::Summary`, `Generator#figcaption`, and `Generator#summary` from compiled Ruby core.
   - Public canonical vocabulary reduced from 64 to 62 words.
3. **Re-atomize `paragraph` over `tag p`**:
   - `paragraph` re-expressed as a `.sp` partial in `lib/vocabulary/paragraph.sp` over `tag p, .content, variant: .variant`.
   - Preserves variant token generation (`paragraph--warning`) and root class deduplication.
   - Core primitives shrink from 40 to 39; vocabulary partials expand from 22 to 23 (total canonical: 62).
4. **Flexible Argument Binding for Disk Partials**:
   - `Builder.bind_parameters` establishes unified positional + keyword argument binding with Symbol resolution and Proc evaluation.
   - Disk partials in `partials/` can be authored with top-level `def <word>, *params` (with zero `expects` boilerplate), supporting positional args, keyword args, scope forwarding, comments, and block children splicing via `children`.

---

## Architectural mechanics

1. **Privileged Compilation Cache (`lib/slim_pickins/compilation.rb`, `contracts.rb`)**:
   `Compilation.of(source, path, privileged: false)` is keyed on `[source, privileged]`. In `Library`, built-in vocabulary partials compile with `privileged: true`, while app templates and user partials compile with `privileged: false`. `Contracts.first_violation` and `Contracts.complaints` inspect the tree, rejecting any occurrence of `tag` when unprivileged.
2. **Tag Root Classing & Variant Synthesis (`lib/slim_pickins/generator.rb`)**:
   When a vocabulary partial emits `:tag`, `Generator#emit` synthesizes the canonical base class (`attrs[:class_base]`) and variant modifier token (`attrs[:variant]`), cleanly merging with any outer app classes (`attrs[:app_class]`) and deduplicating tokens (`.compact.join(' ').split.uniq.join(' ')`).
3. **Disk Def Partials (`lib/slim_pickins/builder.rb`, `test/disk_def_partial_test.rb`)**:
   `Builder#define_app_words` scans `@library.partials` for top-level `def` definitions (tolerating leading comments and whitespace via `/\A(?:\s*|#.*?\n)*def\b/`) and evaluates them into `define_local_word` singleton methods, complete with block capture for `children` splicing.

---

## Verification & Acceptance

- **Byte-Diff Acceptance**:
  - All 20 application pages render 100% byte-identical HTML.
  - All 11 pages listing vocabulary dynamically reflect the exact 64 -> 62 reduction (`figcaption` and `summary` rows removed), with 0 unintended diffs.
- **Warm Render Cost Budget**:
  - Measured at **6.24 ms** warm render (well within the **10.0 ms** budget guardrail; baseline was 5.64 ms).
  - Per-row cost: **0.24 ms**.
  - Cold render: **7.28 ms**.
- **Automated Test Suite**:
  - **418 tests** across 45 test files, **5,409 assertions**, 0 failures, 0 errors, 0 skips.
- **Quality Gates**:
  - All 7 gates pass cleanly:
    1. `check_grammar.rb`: 1,237 sentences checked, 92 words defined, 0 problems.
    2. `check_shape.rb`: 62 canonical words (39 Ruby, 23 partials), 0 problems.
    3. `check_styles.rb`: 27 emittable classes, 59 seen rendering, 105 rules, 0 problems.
    4. `bin/check_promises.rb`: 35 promises, 0 problems.
    5. `bin/check_conventions.rb`: 38 conventions, 0 problems.
    6. `bin/check_card.rb`: 7 fields present, last_touched 2026-09-23, 0 problems.
    7. `bin/verify_pages.rb`: 31 pages verified, 0 problems.
