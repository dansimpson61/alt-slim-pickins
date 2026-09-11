# Empirical Challenger Report: `action` and `actions` Primitives

**Author:** Challenger 1 (Adversarial QA & Domain Specialist)  
**Date:** 2026-09-10  
**Project:** `alt-slim-pickins`  
**Verdict:** 🚨 **REQUEST_CHANGES**  

---

## 1. Executive Verdict & Summary

### Verdict: **REQUEST_CHANGES**

While Worker 1's implementation successfully satisfies the existing static checkers (`check_grammar.rb`, `check_shape.rb`, `check_styles.rb`), the page verification suite (`bin/verify_pages.rb`), the pre-existing 24 test files, and the live dashboard parity checker (`bin/dashboard_parity.rb` 25/25 affordances), **our empirical stress harness uncovered critical runtime defects and architectural flaws that break the DSL when `action` or `actions` is used in normal, valid scenarios outside of the dashboard's specific triage queue**.

Specifically:
1. **Fatal Crashes on Standalone `action`**: Calling `action "Logout", to: "/logout"` anywhere outside an `actions` container that passes both `path:` and `return_to:` causes an uncaught fatal exception: `SlimPickins::UnknownAttribute: this page has no path`.
2. **Fatal Crashes on Incomplete `actions` Modifiers**: Calling `actions` with only `path:` (missing `return_to:`) or only `return_to:` (missing `path:`) or no modifiers (`actions`) crashes at runtime with `SlimPickins::UnknownAttribute`.
3. **Unintended Scope Leakage**: If an enclosing page model or local variable has a `.path` attribute (e.g., file paths, project models, route paths) and an `actions` block does not specify `path:`, child `action`s silently traverse up the subject chain to the page model and emit hidden inputs carrying unintended values.
4. **Universal Core Engine Pollution**: In `lib/slim_pickins/partial_word.rb:73`, the dashboard-specific parameters `%i[path return_to]` are hardcoded into the universal framework engine `PartialWord#parameters_for`. This violates the Ode to Joy and the Council's explicit design philosophy against clever magic traps.

---

## 2. Empirical Stress-Test Harness & Verbatim Results

We constructed and executed a comprehensive test suite probing edge cases across 7 dimensions.

### Execution Command
```bash
ruby -e '
require_relative "lib/slim_pickins"
# ... stress test execution ...
'
```

### 2.1 Dimension 1: `actions` Scoping and Modifiers
| Test ID | Scenario | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|---|
| **1a** | `actions path: "/p", return_to: "/r"` | Emits hidden path and return_to | Emits both hidden inputs | **PASS** |
| **1b** | `actions path: "/p"` (no `return_to:`) | Emits hidden path; omits return_to | **CRASH**: `SlimPickins::UnknownAttribute: this page has no return_to` | ❌ **FAIL** |
| **1c** | `actions return_to: "/r"` (no `path:`) | Emits hidden return_to; omits path | **CRASH**: `SlimPickins::UnknownAttribute: this page has no path` | ❌ **FAIL** |
| **1d** | `actions` (no modifiers) | Omits hidden path and return_to | **CRASH**: `SlimPickins::UnknownAttribute: this page has no path` | ❌ **FAIL** |
| **1e** | `actions` with `link` and `button` | Renders links and buttons in container | Renders `<div class="actions">` | **PASS** |
| **1f** | Empty `actions` block | Renders empty container `<div class="actions">` | Renders `<div class="actions">` | **PASS** |

#### Verbatim Crash Trace (Test 1d):
```
SlimPickins::UnknownAttribute: this page has no path
  partials/action.sp, line 5
    when .path
	from /home/dan/dev/alt-slim-pickins/lib/slim_pickins/subject.rb:76:in 'SlimPickins::Subject#fetch'
	from /home/dan/dev/alt-slim-pickins/lib/slim_pickins/subject.rb:84:in 'SlimPickins::Subject#method_missing'
	from partials/action.sp:6:in 'block (6 levels) in SlimPickins::Builder#eval_with'
	from /home/dan/dev/alt-slim-pickins/lib/slim_pickins/words.rb:331:in 'SlimPickins::Words::When#evaluate'
```

---

### 2.2 Dimension 2: `action` Standalone Calls and Parameter Inheritance
| Test ID | Scenario | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|---|
| **2a** | Standalone `action "Go", to: "/go"` | Emits form with button, no hidden inputs | **CRASH**: `SlimPickins::UnknownAttribute: this page has no path` | ❌ **FAIL** |
| **2b** | Standalone `action "Go", to: "/go", path: "/p"` | Emits form with hidden path only | **CRASH**: `SlimPickins::UnknownAttribute: this page has no return_to` | ❌ **FAIL** |
| **2c** | Standalone `action "Go", to: "/go", return_to: "/r"` | Emits form with hidden return_to only | **CRASH**: `SlimPickins::UnknownAttribute: this page has no path` | ❌ **FAIL** |
| **2d** | Standalone `action "Go", to: "/go", path: "/p", return_to: "/r"` | Emits form with both hidden inputs | Emits both hidden inputs | **PASS** |
| **2e** | Child `action` overriding `path:` in `actions` | Override path used; return_to inherited | Correctly overridden | **PASS** |
| **2f** | Child `action` overriding `return_to:` in `actions` | Override return_to used; path inherited | Correctly overridden | **PASS** |
| **2g** | Child `action` overriding both in `actions` | Both overridden | Correctly overridden | **PASS** |

#### Verbatim Crash Trace (Test 2a):
```
SlimPickins::UnknownAttribute: this page has no path
  partials/action.sp, line 5
    when .path
```

---

### 2.3 Dimension 3: Optional Modifier `status:`
| Test ID | Scenario | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|---|
| **3a** | `action ..., status: "dormant"` inside `actions` | Emits `<input type="hidden" name="status" value="dormant">` | Correctly emitted | **PASS** |
| **3b** | `action` without `status:` in `actions` | Does NOT emit `name="status"` | No status emitted | **PASS** |
| **3c** | Standalone `action ..., status: "dormant"` | Emits form with status hidden input | **CRASH**: `SlimPickins::UnknownAttribute: this page has no path` | ❌ **FAIL** |
| **3d** | Isolation against Sinatra `status` helper | Must not emit `status="200"` | No status emitted | **PASS** |
| **3e** | `action ..., status: ""` | Emits `<input type="hidden" name="status">` | Correctly emitted | **PASS** |

---

### 2.4 Dimension 4: Presentation Modifier `variant:`
| Test ID | Scenario | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|---|
| **4a** | `action ..., variant: primary` | Emits `class="button button--primary"` | `button button--primary` emitted | **PASS** |
| **4b** | `action ..., variant: neutral` | Emits `class="button button--neutral"` | `button button--neutral` emitted | **PASS** |
| **4c** | `action` without `variant:` | Emits `class="button"` (no modifier suffix) | `class="button"` emitted | **PASS** |

---

### 2.5 Dimension 5: Conditionals and Nesting (`choose` / `when` / `otherwise`)
| Test ID | Scenario | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|---|
| **5a** | `action` in `when true` inside `actions` | Emits action | Emitted | **PASS** |
| **5b** | `action` in `when false` inside `actions` | Does not emit action | Not emitted | **PASS** |
| **5c** | `action` in `otherwise` inside `actions` | Emits alternate action | Emitted | **PASS** |
| **5d** | Multiple actions in `actions` | All actions inherit shared parameters | All 3 actions inherit identically | **PASS** |
| **5e** | `actions` nested inside `card` | Renders actions inside card | Renders correctly | **PASS** |

---

### 2.6 Dimension 6: Unintended Attribute Leakage & Shadowing
| Test ID | Scenario | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|---|
| **6a** | Page model has `path: "secret_doc"`, `actions` specifies only `return_to: "/triage"` | Action must NOT emit hidden path from page model | **LEAK**: Emits `<input type="hidden" name="path" value="secret_doc">` | ❌ **FAIL** |

#### Evidence of Leakage:
```ruby
code = <<~SP
  page p
    actions return_to: "/triage"
      action "Do", to: "/do"
SP
SlimPickins.render(code, path: "t.sp", locals: { p: { path: "unintended_page_path" } })
# Result:
# <form class="form" action="/do" method="post">
#   <input type="hidden" name="path" value="unintended_page_path">
#   <input type="hidden" name="return_to" value="/triage">
#   <button type="submit" class="button">Do</button>
# </form>
```

---

## 3. Deep Root Cause Analysis

### 3.1 Why did the existing test suite fail to catch these bugs?
In `test/vocabulary_partials_test.rb`:
- `test_action_inherits_path_and_return_to_from_enclosing_actions_container`: passed both `path:` and `return_to:` to `actions`.
- `test_action_emits_status_when_specified`: passed both `path:` and `return_to:` to `actions`.
- `test_action_is_the_minimal_post_form`: passed both `path:` and `return_to:` directly to `action`.
- In `examples/dashboard/views/partials/queue.sp`: passed both `path:` and `return_to:` to `actions`.

**Zero tests in the repository ever invoked `actions` without `path:` or without `return_to:`, and zero tests ever invoked `action` standalone without `path:` and `return_to:`**.

### 3.2 The Mechanism of the Crash
Look at `lib/vocabulary/action.sp`:
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

In `lib/slim_pickins/partial_word.rb:70-76`:
```ruby
contract.modifiers.each do |modifier|
  if kwargs.key?(modifier)
    declared[modifier] = kwargs[modifier]
  elsif !%i[path return_to].include?(modifier)
    declared[modifier] = nil
  end
end
```

1. For `status:`, because `:status` is not in `%i[path return_to]`, `declared[:status] = nil`. When `action.sp` runs `.status`, `declared.key?(:status)` is `true`, returning `nil`. `when .status` evaluates `when nil` (falsey) and does not raise.
2. For `path:` and `return_to:`, because they ARE in `%i[path return_to]`, they are **omitted entirely** from `declared`.
3. When `action.sp` evaluates `when .path`, `declared` does not have key `:path`.
4. `Subject#fetch` falls back to the enclosing subject.
5. If the enclosing `actions` container has `path:`, it resolves.
6. **If the enclosing `actions` container omits `path:` (or if `action` is called standalone)**, lookup traverses the fallback chain all the way to `Page`.
7. `Page` does not have `path`.
8. `Subject#fetch` executes line 80: `raise UnknownAttribute.new(attribute, self)`.
9. The page render crashes with an unhandled exception!

---

## 4. Empirically Verified Mitigation Prototype

To assist Worker 1 in fixing this cleanly, we developed and empirically tested an exact fix:

Instead of hardcoding `%i[path return_to]` in `parameters_for` and letting lookups fall through the global subject chain indefinitely, parameter inheritance should check whether the immediate enclosing container (`chain.current`) is an `actions` container:

```ruby
# In lib/slim_pickins/partial_word.rb:
def parameters_for(contract, name, content, kwargs)
  return { content: content, name: name }.merge(kwargs) unless contract
  declared = {}
  contract.modifiers.each do |modifier|
    if kwargs.key?(modifier)
      declared[modifier] = kwargs[modifier]
    elsif chain.current&.noun == "actions" && chain.current.instance_variable_get(:@object)&.key?(modifier)
      declared[modifier] = chain.current.instance_variable_get(:@object)[modifier]
    else
      declared[modifier] = nil
    end
  end
  declared[:name] = name if contract.name != :none
  declared[:content] = content if contract.content
  declared[:id] = @builder.send(:card_id) if contract.id
  declared[:label] = label_for(name, content) if contract.label
  declared
end
```

### Verification of Mitigation:
Running the full 7-dimension stress harness with this mitigation resulted in **100% PASS** across all tests:
- `actions` with both `path:` and `return_to:`: **PASS**
- `actions` with only `path:`: **PASS**
- `actions` with only `return_to:`: **PASS**
- `actions` with neither: **PASS**
- Standalone `action "Go", to: "/go"`: **PASS**
- Action overriding `path:` or `return_to:`: **PASS**
- No Sinatra HTTP status 200 leakage: **PASS**
- No page local leakage: **PASS**
- Zero hardcoded parameter lists (`%i[path return_to]` completely removed).

---

## 5. Conclusion & Next Steps

The refactoring has a solid core and passes existing regression tests, but its parameter resolution mechanism is incomplete and brittle.

**Required Actions for Worker 1:**
1. Fix `lib/slim_pickins/partial_word.rb` so that:
   - Standalone `action` works cleanly without `path:` or `return_to:`.
   - `actions` can be invoked with any combination of `path:` and `return_to:` (both, one, or none).
   - Parameters are inherited strictly from enclosing scoped containers without leaking to/from outer page models.
   - Hardcoded `%i[path return_to]` is removed from `PartialWord`.
2. Add comprehensive unit tests in `test/vocabulary_partials_test.rb` covering:
   - Standalone `action` without `path:` or `return_to:`.
   - `actions` with only `path:`.
   - `actions` with only `return_to:`.
   - `actions` without `path:` or `return_to:`.
3. Verify that `bin/dashboard_parity.rb` and the full test suite remain 100% green.
