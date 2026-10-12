# Daytrip 0.5.0b — Enforcing Nearest-First Lookup & Deleting the Global Registry Write

**Status: closed 2026-10-11.** Enforced nearest-first lookup, deleted the global write
(`Word.registry[word] = klass`), applied Option A lexical parameter scoping in `Builder`,
memoized `StudioPages.ui_library(ui)`, and verified complete isolation of `editor.sp`
across classic and workbench. All twelve gate legs green, 629 runs / 6,718 assertions / 0 failures.

**Baseline:** all twelve gate legs green, and the suite at 627 runs, 6,698 assertions,
0 failures, at `e5a0bd7`.

---

## The two defects this daytrip closes

### 1. The parameter leak in `def` (Option A)

`DAYTRIP-0.5.0a.md` demonstrated that `def framed, name` wrapping `paragraph .name`
rendered empty because `define_local_word` captured the caller's block *inside*
`chain.with(bound)`. The word's unsupplied parameter (`name = nil`) was pushed onto the
subject chain before the caller's block ran, hiding the caller's own subject attribute
(`point.name`).

On 2026-10-11 dan ruled:
> "Option A (Lexical Scope) combined with Option B1 (Data-Flow Inference)"
> "A standing rule is that we don't ask authors to take care of the compiler, but rather the opposite."

Under Option A, the caller's block is evaluated in the caller's own lexical scope before
the word's parameter binding is applied. Inside the word body, `with_splice(captured)`
spliced children into the word's template, where the word's own parameters are active.

### 2. The global write in `Compilation.compile_partial`

In `lib/slim_pickins/compilation.rb:34`:
```ruby
SlimPickins::Word.registry[word] = klass
```

Every time any library (Studio UI, example app, or test fixture) compiles a partial, it
shoves that partial's class into `SlimPickins::Word.registry`. Whichever library was
compiled last clobbered any earlier partial with the same name.

`ROADMAP-0.5.md` criteria 1 and 2 mandate:
1. **The editor collision is actually gone, not papered over.** Both editors render
   correctly no matter the load order, `StudioPages.ui_library(ui)` can be cached again,
   and a test proves it.
2. **The one line of code that lets this happen is deleted, not guarded against.**
   Line 34 goes. Compiled partials belong to their owning `Library` instance.

---

## The Plan

Four steps:

1. **Apply Option A in `lib/slim_pickins/builder.rb`.**
   In `define_local_word`, evaluate `captured = capture(&caller_block) if caller_block`
   before `chain.with(bound)`.
   Add a test in `test/def_test.rb` proving that an unsupplied parameter (`name`) does
   not shadow a caller's subject attribute (`point.name`).

2. **Delete the global write in `lib/slim_pickins/compilation.rb`.**
   Remove `SlimPickins::Word.registry[word] = klass`.
   In `lib/slim_pickins/library.rb`, store compiled partials in `@compiled_partials[word]`.
   Provide `compiled_partials` and `compiled_partial(word)` accessors on `Library`.

3. **Wire nearest-first resolution into `Compilation`, `Contracts`, and `Builder`.**
   In `Builder#define_app_words`:
   - Primitives from `SlimPickins::Word.registry`
   - Built-in partials from `Library.builtin.compiled_partials`
   - App words from `@library.words`
   - App partials from `@library.compiled_partials`
   - In-buffer `def`s from `@library.partials`
   Thread `library:` into `Compilation.of` and `Contracts.first_violation`, resolving
   contracts nearest-first.

4. **Memoize Studio UI libraries and prove `editor` isolation.**
   Memoize `StudioPages.ui_library(ui)` across requests.
   Add a test proving `classic` and `workbench` each render their own distinct `editor`
   regardless of load order or memoization.
   Update references that checked `Word.registry` for built-in vocabulary
   (`Each#evaluate`, `StudioDocs`, `Phase4Test`) to check `Library.builtin`.

---

## Verification

- Full test suite: 629 runs, 6,718 assertions, 0 failures (+2 runs, +20 assertions from the two new proof tests).
- All twelve gate legs green (`check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, `check_spiff.rb`, `check_spiff_scope.rb`, `bin/check_promises.rb`, `bin/check_conventions.rb`, `bin/check_card.rb`, `bin/verify_pages.rb`, `check_vitals.rb`, `check_ruby.rb`, `Suite`).
- 35 verified pages byte-identical under `bin/verify_pages.rb` (0 problems).
- `check_ruby.rb` clean across 128 files (0 problems).
