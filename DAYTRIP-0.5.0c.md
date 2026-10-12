# Daytrip 0.5.0c — Option B1 Data-Flow Inference & Retiring `expects`

**Status: closed.** Retired the legacy `expects` declaration line across 9 partials (5 studio furniture partials + first 4 canonical vocabulary partials) using Option B1 (Data-Flow Inference). All 12 gate legs green, 35 verified pages byte-identical, 0 vocabulary drift, test suite at 630 runs, 6,722 assertions, 0 failures.

**Baseline:** all twelve gate legs green, 35 verified pages byte-identical, and the test suite at 629 runs, 6,718 assertions, 0 failures, at `4ef8cb5`.

---

## The Defect and the Roadmap Goal

`ROADMAP-0.5.md` Criterion 6 states:
> "The old declaration line retires — required, not optional. Today, before any markup, an author has to write one long line spelling out facts about a word by hand — for `card`, ten separate declarations before a single line that actually renders anything... dan's preferred shape for what replaces it: name a parameter plainly for what it is, as in `def card, subject, content` — the parameter's own name carries the declaration, so there is nothing extra to write."

On 2026-10-11 dan ruled:
> "yes, Option A (Lexical Scope) combined with Option B1 (Data-Flow Inference)"
> "A standing rule is that we don't ask authors to take care of the compiler, but rather the opposite."

---

## Census: The 28 Files Carrying `expects`

Measurement over the repository found exactly 28 files carrying `expects`:
- **5 Studio Furniture Partials (`studio/`)**: `shell.sp`, `detail.sp`, `tree.sp`, `twig.sp`, `why_card.sp`. These are local UI partials, not canonical vocabulary words, and have no entries in `VOCABULARY.md` or `CONTRACTS`.
- **23 Built-in Vocabulary Partials (`lib/vocabulary/`)**: canonical words held by `check_grammar`, `check_shape`, `check_promises`, `check_conventions`, and `generate_vocabulary`.

---

## The Three Stages

### Stage 1: Migrate 5 Studio Partials to `def`
1. Updated `studio/shared/partials/shell.sp` to `def shell`.
2. Updated `studio/views/partials/detail.sp` to `def detail`.
3. Updated `studio/views/partials/tree.sp` to `def tree`.
4. Updated `studio/views/partials/twig.sp` to `def twig, nodes`.
5. Updated `studio/views/partials/why_card.sp` to `def why_card`.
6. Verified byte-identity across all 35 pages and verified full suite.

### Stage 2: Implement Option B1 Data-Flow Inference
1. Implemented canonical tables in `SlimPickins::VocabularyShapes`:
   - `CANONICAL_INFERENCES`, `CANONICAL_PARENTS`, `CANONICAL_SPEECH`, `CANONICAL_FLAGS`, `CANONICAL_SHAPES`.
2. Implemented `VocabularyShapes.infer_from_def(word_name, def_node)`:
   - Infers parameter kinds (`variant`, `content`, `attribute`, `subject`, `modifier`) from parameter names and destination calls.
   - Detects `children: :any` when `children` word is called in body.
   - Infers structural shape (`:presents`, `:encloses`) from root element and canonical tables.
   - Merges canonical conventions, speech, parents, and flags.
3. Updated `VocabularyShapes.parse(source, word: nil)` to parse both legacy `expects` and `def` nodes.
4. Updated `Compilation.compile_partial` to pass `word: word` and assign contracts to built-in or `expects` partials.
5. Updated `Builder.bind_parameters` with contract-aware routing: when a word takes a name and content, and a single non-Symbol argument is passed, it routes to content while defaulting name to `nil`.
6. Updated `Builder#define_app_words` to reuse precompiled Ruby AST from `Compilation` when available.

### Stage 3: Migrate First Batch of Vocabulary Partials
1. Migrated leaf presenters to `def`:
   - `lib/vocabulary/flash.sp`: `def flash, text \n note .text`
   - `lib/vocabulary/text.sp`: `def text, words \n paragraph .words`
   - `lib/vocabulary/note.sp`: `def note, tone, text \n paragraph .tone, .text`
   - `lib/vocabulary/badge.sp`: `def badge, status, label \n span .status, .label`
2. Added proof test in `test/contracts_test.rb`: `test_def_data_flow_inference_produces_identical_contracts`.
3. Verified zero drift via `bin/generate_vocabulary.rb`.

---

## Verification

- Full suite: 630 runs, 6,722 assertions, 0 failures (+1 run, +4 assertions from the new proof test).
- All 12 gate legs green (`check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, `check_spiff.rb`, `check_spiff_scope.rb`, `bin/check_promises.rb`, `bin/check_conventions.rb`, `bin/check_card.rb`, `bin/verify_pages.rb`, `check_vitals.rb`, `check_ruby.rb`, `Suite`).
- 35 verified pages byte-identical under `bin/verify_pages.rb` (0 problems).
- 0 drift in `VOCABULARY.md` bullets under `bin/generate_vocabulary.rb`.
- `check_ruby.rb` clean across 128 files (0 problems).
