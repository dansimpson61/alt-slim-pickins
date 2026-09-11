# Handoff Report: Challenger 1 (Action Refactoring Stress Test)

**Verdict:** 🚨 **REQUEST_CHANGES**

---

## 1. Observation

1. **Existing Test Suite and Checkers Passing**:
   Running the standard suite command:
   ```bash
   ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done
   ```
   Outputs:
   - `check_grammar.rb`: `667 sentences checked, 80 words defined, 0 problems`
   - `check_shape.rb`: `442 sentences · mean 1.26 args · 0 problems`
   - `check_styles.rb`: `25 classes the code can emit, 61 seen rendering, 95 rules, 0 problems`
   - `verify_pages.rb`: `10 pages verified, 0 problems`
   - `test/*_test.rb`: 24 test suites pass with 0 failures, 0 errors
   - `ruby bin/dashboard_parity.rb`: `25 affordances compared, 0 missing`

2. **Fatal Crashes on Standalone `action` and Incomplete `actions`**:
   Executing standalone `action`:
   ```bash
   ruby -e 'require_relative "lib/slim_pickins"; puts SlimPickins.render("page\n  action \"Go\", to: \"/go\"", path: "t.sp")'
   ```
   Fails with uncaught exception:
   ```
   /home/dan/dev/alt-slim-pickins/lib/slim_pickins/subject.rb:80:in 'SlimPickins::Subject#fetch': this page has no path (SlimPickins::UnknownAttribute)
     partials/action.sp, line 5
       when .path
   ```
   Similarly:
   - `actions path: "/p"` (omitting `return_to:`) fails with: `this page has no return_to (SlimPickins::UnknownAttribute)` at `partials/action.sp:8`.
   - `actions return_to: "/r"` (omitting `path:`) fails with: `this page has no path (SlimPickins::UnknownAttribute)` at `partials/action.sp:5`.
   - `actions` (no kwargs) fails with: `this page has no path (SlimPickins::UnknownAttribute)` at `partials/action.sp:5`.

3. **Silent Scope Leakage**:
   Executing:
   ```bash
   ruby -e 'require_relative "lib/slim_pickins"; puts SlimPickins.render("page p\n  actions return_to: \"/triage\"\n    action \"Do\", to: \"/do\"", path: "t.sp", locals: { p: { path: "unintended_file.txt" } })'
   ```
   Emits:
   ```html
   <form class="form" action="/do" method="post"><input type="hidden" name="path" value="unintended_file.txt"><input type="hidden" name="return_to" value="/triage"><button type="submit" class="button">Do</button></form>
   ```
   The action silently traverses past `actions` to `p.path` on the page model and emits an unwanted hidden input.

4. **Hardcoded Modifiers in Core Framework Engine**:
   In `lib/slim_pickins/partial_word.rb:73-75`:
   ```ruby
   contract.modifiers.each do |modifier|
     if kwargs.key?(modifier)
       declared[modifier] = kwargs[modifier]
     elsif !%i[path return_to].include?(modifier)
       declared[modifier] = nil
     end
   end
   ```
   The symbols `%i[path return_to]` are hardcoded into `PartialWord`, coupling the universal framework engine to dashboard-specific parameters.

---

## 2. Logic Chain

1. From Observation 1, the pre-existing test suite passes because every existing call site (`queue.sp`, `test_action_inherits_path_and_return_to_from_enclosing_actions_container`, `test_action_emits_status_when_specified`, and `test_action_is_the_minimal_post_form`) supplies BOTH `path:` and `return_to:`. No existing test exercised standalone `action` or `actions` without both modifiers.
2. In `lib/vocabulary/action.sp`, lines 4–9 specify:
   ```slim
   choose
     when .path
       hidden path, .path
   choose
     when .return_to
       hidden return_to, .return_to
   ```
   In the SlimPickins compiler (`transform.rb:157`), `.path` compiles to `subject.path`.
3. In `lib/slim_pickins/partial_word.rb:73` (Observation 4), `parameters_for` deliberately omits unpassed `path` and `return_to` from `declared` so that attribute lookup falls through to the subject chain.
4. When `path` or `return_to` is not supplied by an enclosing `actions` container (Observation 2), `Subject#fetch` traverses up the chain all the way to `Page`. When `Page` does not have the attribute, `Subject#fetch` executes `raise UnknownAttribute.new(attribute, self)` (Observation 2). Because `when .path` executes `subject.path`, this uncaught exception aborts rendering with a fatal error.
5. Furthermore, if an outer page model happens to define `.path` (Observation 3), the unrestricted fallback chain grabs the page model's path and emits an unintended hidden input.
6. Therefore, the implementation in its current state is broken for standalone `action` and for `actions` without both parameters, and leaks attributes across scope boundaries. Changes are required before this work can be approved.

---

## 3. Caveats

- No caveats. All failure modes were reproduced empirically via isolated Ruby scripts and verified against the actual repository codebase. A prototype mitigation was also empirically verified to achieve a 100% pass rate across all edge cases without regressions.

---

## 4. Conclusion

**Verdict: REQUEST_CHANGES**

Worker 1 must update `lib/slim_pickins/partial_word.rb` and/or `lib/vocabulary/action.sp` to:
1. Prevent fatal `UnknownAttribute` crashes when `path:` or `return_to:` is omitted.
2. Support standalone `action` calls cleanly.
3. Scope parameter inheritance strictly to enclosing containers (e.g. `actions`) to prevent leakage to/from outer page models.
4. Eliminate hardcoded `%i[path return_to]` from `PartialWord`.
5. Add unit tests for standalone `action` and partial modifier combinations to `test/vocabulary_partials_test.rb`.

Full reproduction details and tested mitigation code are provided in `/home/dan/dev/alt-slim-pickins/.agents/challenger_1/report.md`.

---

## 5. Verification Method

To reproduce the failures, run:
```bash
# Test Standalone action crash:
ruby -e 'require_relative "lib/slim_pickins"; puts SlimPickins.render("page\n  action \"Go\", to: \"/go\"", path: "t.sp")'

# Test actions without return_to crash:
ruby -e 'require_relative "lib/slim_pickins"; puts SlimPickins.render("page\n  actions path: \"/p\"\n    action \"Go\", to: \"/go\"", path: "t.sp")'

# Test actions without path crash:
ruby -e 'require_relative "lib/slim_pickins"; puts SlimPickins.render("page\n  actions return_to: \"/r\"\n    action \"Go\", to: \"/go\"", path: "t.sp")'

# Test leakage from page model:
ruby -e 'require_relative "lib/slim_pickins"; puts SlimPickins.render("page p\n  actions return_to: \"/r\"\n    action \"Go\", to: \"/go\"", path: "t.sp", locals: { p: { path: "leaked_path" } })'
```
**Expected Failure Signs**:
- Uncaught `SlimPickins::UnknownAttribute: this page has no path`
- Uncaught `SlimPickins::UnknownAttribute: this page has no return_to`
- Value `leaked_path` emitted in hidden input
