# Daytrip 0.5.0g — Real Containment: The Eleven Contained Words

**Status: closed.** Fulfilling Criterion 3 of `ROADMAP-0.5.md`:
1. Nested the ten parent-bound Ruby classes inside their parent classes in `lib/slim_pickins/words.rb` (`Table::Column`, `Table::Total`, `Chart::Band`, `Chart::Line`, `Chart::Level`, `Choose::When`, `Choose::Otherwise`, `Tabs::Tab`, `Form::Hidden`, `Choice::Option`).
2. Moved `item` into `lib/vocabulary/list.sp`, retiring `lib/vocabulary/item.sp` as a standalone file so opening `list.sp` reveals `item` as part of its family.
3. Updated `Word.inherited` to read Ruby module nesting and register child classes into `family_registry`, fixing the capture bug in passing.
4. Derived parent containment directly from class nesting and file containment, retiring advisory `parents:` annotations in `words.rb` and `CANONICAL_PARENTS` in `contracts.rb`.
5. Enforced real containment in `Builder`: contained words are excluded from top-level dispatch, activated only within their parent word's lexical scope via `with_family`. Outside parent blocks, `builder.respond_to?(word)` is `false`.
6. Verified all twelve gate legs remain green, 35 pages byte-identical, vitals clean, and full test suite passes (637 runs, 6,869 assertions, 0 failures).

**Baseline:** All twelve gate legs green, 35 verified pages byte-identical, and the test suite at 636 runs, 6,840 assertions, 0 failures, at commit `2bc063f`.
**Outcome:** All twelve gate legs green, 35 verified pages byte-identical, test suite at 637 runs, 6,869 assertions, 0 failures.

---

## Roadmap Context: Criterion 3 of ROADMAP-0.5.md

> "The eleven words that are only supposed to exist inside something else actually only exist inside something else. Ten built-in words (a table's column, a chart's axis line, and others like them) and one hand-written word (an item that only makes sense inside a list) currently carry a note saying 'I belong inside this other word,' but nothing enforces that note today — it is a comment the code trusts. After this work, that containment is real, the way Ruby already lets one class live inside another. Whether a list needs its item becomes something you can see by opening the file, not something you have to take on faith."

---

## The Census: The Eleven Contained Words

| Parent Word | Contained Children | Kind |
| :--- | :--- | :--- |
| `table` | `column`, `total` | 2 Ruby words |
| `chart` | `band`, `line`, `level` | 3 Ruby words |
| `choose` | `when`, `otherwise` | 2 Ruby words |
| `tabs` | `tab` | 1 Ruby word |
| `form` | `hidden` | 1 Ruby word |
| `choice` | `option` | 1 Ruby word |
| `list` | `item` | 1 `.sp` partial |

---

## The Four Stages Completed

### Stage 1: Nesting the 10 Ruby Classes in `words.rb` & Updating `Word.inherited`
- Nested child classes under `Table`, `Chart`, `Choose`, `Tabs`, `Form`, and `Choice` (`Table::Column`, `Table::Total`, etc.).
- Updated `Word.inherited` to detect class nesting (`parts.size > 3 && parts[-3] == 'Words'`) and populate universal `Word.family_registry` and `Word.parent_registry`.
- Left no top-level aliases on `Words` (`Column = Table::Column` etc.), ensuring contained words only exist inside their parent namespace.
- Updated `Library.primitive_keys` and `examples/word_graph/lib/graph.rb` to query `SlimPickins::Word.registry` directly rather than relying on flat `Words.constants`.
- Fixed regex capture bug in `Word.inherited` (`'\1_\2'` rather than `'_'`).
- Retired explicit `parents:` kwargs from all 10 contracts in `words.rb`, defaulting to `[Word.parent_of(word_name)]` automatically.

### Stage 2: Moving `item` into `list.sp`
- Moved `def item, variant, content` into `lib/vocabulary/list.sp`.
- Deleted `lib/vocabulary/item.sp` (`git rm`).
- Updated `Library.builtin_partial_paths`, `VocabularyShapes.load`, and `Census.words` to recognize all `def` declarations within `.sp` files and register partial families (`Word.register_family(base, child)`).
- Updated `check_grammar.rb`, `studio/docs_helper.rb`, `examples/word_graph/lib/graph.rb`, and `bin/word_graph.rb` to consume partials from `Library.builtin.partials`, preserving exact canonical counts (62 words, 39 primitives, 23 partials).

### Stage 3: Real Containment in `Builder`
- Excluded the eleven contained words from top-level `Builder#define_app_words`.
- In `Builder#define_local_word`, routed contained child definitions to `@family_definitions[parent][child]`.
- Implemented `Builder#with_family(parent)` with stack save/restore semantics for both Ruby child classes and local `def` child words.
- Wrapped caller block execution in `with_open`, `Tabs#evaluate`, `Form#evaluate`, `define_single_local_word`, and `PartialWord#evaluate` with `with_family(word_name)`.
- Contained words are strictly undefined outside their parent blocks: `builder.respond_to?(word)` is `false` before entry, `true` during block evaluation, and removed upon return.

### Stage 4: Gate Verification & Test Suite
- Added comprehensive containment verification in `test/contracts_test.rb#test_contained_words_are_not_available_at_top_level_and_scoped_to_parents`.
- `check_vitals.rb`: 0 problems (62 canonical words, 39 primitives, 23 partials, 35 verified pages, 58 test files).
- `bin/check_card.rb`: 0 problems.
- `bin/verify_pages.rb`: 35 pages verified byte-identical, 0 problems.
- `check_ruby.rb`: 0 problems across 129 files (`ruby -w -c` clean).
- All 12 gate legs green on `/status` via `StudioStatus.run` (Grammar, Shape, Styles, Spiff, Scope, Promises, Conventions, Card, Pages, Vitals, Ruby, Suite).
- Full test suite: 637 runs, 6,869 assertions, 0 failures, 0 errors.
- Word graph test suite: 6 runs, 108 assertions, 0 failures.
