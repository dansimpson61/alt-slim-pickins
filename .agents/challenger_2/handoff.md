# Hard Handoff Report: Challenger 2 (Empirical Audit & Adversarial Review)

**Date:** 2026-09-10  
**Agent:** Challenger 2 (Empirical Challenger)  
**Roles:** critic, specialist  
**Project:** alt-slim-pickins  
**Working Directory:** `/home/dan/dev/alt-slim-pickins/.agents/challenger_2`  
**Verdict:** **REQUEST_CHANGES**

---

## 1. Observation

1. **Checkers and Suite Verification**:
   - `ruby check_shape.rb`:
     `vitals: words: 67, shapes: 7, sentences: 442 · mean 1.26 args · longest 7 · deepest nesting 7 · 0 problems`.
     - Corpus longest sentence: 7 arguments (`lib/vocabulary/action.sp:1` `expects` contract declaration).
     - Real page longest sentence: 4 arguments (`confirm_archive.sp:textarea`, `queue.sp:action`, `editor_form.sp:button`).
     - Real page 5-argument sentences: **0** (eliminated).
   - `ruby check_grammar.rb`: `667 sentences checked, 80 words defined, 0 problems`.
   - `ruby check_styles.rb`: `25 classes the code can emit, 61 seen rendering, 95 rules, 0 problems`.
   - `ruby bin/verify_pages.rb`: `10 pages verified, 0 problems`.
   - `for f in test/*_test.rb; do ruby $f; done`: `22 test files ran; 0 failures, 0 errors`.
   - `ruby bin/dashboard_parity.rb`: `25 affordances compared, 0 missing`.

2. **Adversarial Discovery — Standalone and Unscoped `action` Runtime Crash**:
   Executing the following standard sentences via `SlimPickins.render`:
   ```ruby
   SlimPickins.render(%(action "Logout", to: "/logout"))
   ```
   produces a fatal crash:
   ```
   SlimPickins::UnknownAttribute: this page has no path
     partials/action.sp, line 5
       when .path
   ```
   Similar crashes occur for:
   - `action "Delete", to: "/delete", path: "abc"` -> `UnknownAttribute: this page has no return_to`
   - `actions\n  action "Logout", to: "/logout"` -> `UnknownAttribute: this page has no path`
   - `actions path: "abc"\n  action "Logout", to: "/logout"` -> `UnknownAttribute: this page has no return_to`

3. **Code Location of Defect**:
   - `lib/vocabulary/action.sp:5,8`: `choose` blocks query `when .path` and `when .return_to`.
   - `lib/slim_pickins/partial_word.rb:96`:
     ```ruby
     elsif !%i[path return_to].include?(modifier)
       declared[modifier] = nil
     end
     ```
     Omitting `path` and `return_to` from `declared` was intended to enable fall-through to `actions`, but causes `Subject#fetch` to reach `Page` and raise `UnknownAttribute` when neither `actions` nor `page` defines them.
   - `PartialWord#parameters_for` hardcodes `%i[path return_to]`, leaking domain-specific modifiers into the core engine.

4. **Tested Scenarios Passing**:
   - `actions` holding `link` and `button` without error.
   - Child `action` overriding container `path:` and `return_to:`.
   - Sibling actions isolating optional modifiers (`status:`).
   - Nested `actions` resolving inherited parameters correctly.
   - HTML entity escaping of special characters and query strings.

---

## 2. Logic Chain

1. From Observation 1, Worker 1 met the baseline quantitative criteria: checkers pass, 5-argument sentences in `queue.sp` were removed, mean sentence length dropped to 1.26 args, and live dashboard parity is 100%.
2. From Observation 2, `action` is a core vocabulary primitive documented in `VOCABULARY.md` taking modifiers `to:`, `path:`, `return_to:`, `variant:`, and `status:`.
3. In SlimPickins, `Subject#fetch` strictly enforces that querying an unprovided attribute raises `UnknownAttribute`. It does not evaluate to `nil` or `false`.
4. In Observation 3, Worker 1's implementation in `parameters_for` omits `:path` and `:return_to` from `declared` so that child actions look up the chain. But when an action is used standalone or without both modifiers provided in an enclosing container, looking up `.path` raises `UnknownAttribute`.
5. Existing tests in `test/vocabulary_partials_test.rb` missed this because every test case provided both `path:` and `return_to:`.
6. Under the Ode to Joy (`ODE_TO_JOY.md`), **Correctness > The House > Clarity > Idiom > Elegance**. A vocabulary word that crashes on standard standalone use is a correctness defect.
7. Therefore, changes must be requested before merging.

---

## 3. Caveats

- Internal escaped quotes in text strings (`"Commit \"now\""`) fail in `Transform.tree`, but this is a pre-existing grammar limitation of the tokenizer and is not a regression of the `action` refactoring.
- The pre-existing test failure in `studio/docs_helper.rb` was fixed by Worker 1 and verified to be correct.

---

## 4. Conclusion

**Verdict: REQUEST_CHANGES.**

The refactoring of `action` and `actions` successfully resolved the 5-argument sentence in `queue.sp`, but introduced a critical runtime crash for standalone and partially-parameterized usages of `action`. Additionally, `lib/slim_pickins/partial_word.rb` contains an architectural smell by hardcoding `%i[path return_to]`.

Worker 1 must update `PartialWord#parameters_for` to dynamically detect enclosing chain attributes via `@builder.send(:chain).current.has?(modifier)` (omitting the modifier only when an enclosing subject actually defines it, and defaulting to `nil` otherwise), and add corresponding test coverage for standalone actions.

---

## 5. Verification Method

To reproduce the failure:
```bash
ruby -e '
require_relative "lib/slim_pickins"
SlimPickins.render(%(action "Logout", to: "/logout"))
'
```
**Expected:** Renders `<form class="form" action="/logout" method="post"><button type="submit" class="button">Logout</button></form>`.  
**Actual:** Raises `SlimPickins::UnknownAttribute: this page has no path`.

To verify the complete test suite:
```bash
ruby check_grammar.rb
ruby check_shape.rb
ruby check_styles.rb
ruby bin/verify_pages.rb
for f in test/*_test.rb; do ruby $f; done
ruby bin/dashboard_parity.rb
```
