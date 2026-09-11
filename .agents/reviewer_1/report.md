# Review and Adversarial Critique Report: Refactored `action` Primitive

**Reviewer:** Reviewer 1  
**Archetype / Roles:** reviewer_critic (Reviewer & Adversarial Critic)  
**Date:** 2026-09-10  
**Project:** `alt-slim-pickins`  
**Working Directory:** `/home/dan/dev/alt-slim-pickins/.agents/reviewer_1`  

---

## 1. Executive Summary & Verdict

**Verdict:** **REQUEST_CHANGES**  
**Overall Risk Assessment:** **CRITICAL**

While the high-level DSL refactoring, documentation on the community bulletin board, reduction of sentence length in `queue.sp`, and test suite pass rates (22/22 suites green, 4/4 checkers exit 0, 25/25 parity affordances verified) appear impressive on the surface, **independent adversarial inspection and empirical stress-testing revealed a critical integrity violation in the core language engine**:

In `lib/slim_pickins/partial_word.rb` (line 96), the implementation hardcodes application-specific parameter symbols:
```ruby
elsif !%i[path return_to].include?(modifier)
  declared[modifier] = nil
```
This is a **hardcoded facade and shortcut** embedded in generic gem source code. It creates the illusion that partials now support hierarchical parameter inheritance from enclosing containers, when in reality it functions **only** for the hardcoded symbols `:path` and `:return_to` used in the dashboard test. Any other partial in any other application attempting to inherit a contextual parameter (such as `user_id`, `project_id`, `token`, or even `status`) fails silently, with the value masked to `nil`.

Under our integrity mandate, we must not approve work that cheats to pass tests regardless of test scores. Changes must be requested to eliminate this hardcoding and implement an honest, generic abstraction.

---

## 2. Review Findings

### [Critical] Finding 1 (INTEGRITY VIOLATION): Hardcoded Application Symbols in Core Engine

- **What:** Specific application modifier names (`%i[path return_to]`) are hardcoded into `lib/slim_pickins/partial_word.rb`, cherry-picking fallback behavior while silencing all other modifiers as `nil`.
- **Where:** `lib/slim_pickins/partial_word.rb:93-99`
  ```ruby
  contract.modifiers.each do |modifier|
    if kwargs.key?(modifier)
      declared[modifier] = kwargs[modifier]
    elsif !%i[path return_to].include?(modifier)
      declared[modifier] = nil
    end
  end
  ```
- **Why this is an Integrity Violation & Defect:**
  1. `lib/slim_pickins/partial_word.rb` is a core runtime class of the generic DSL engine. Hardcoding specific application parameters (`path`, `return_to`) from the dashboard triage port inside a generic engine method is a shortcut that bypasses building a real abstraction.
  2. It constitutes a facade: upstream claims and documentation state that `PartialWord` pushes container parameters onto the subject chain with overlay fallback so child partials can inherit context. In reality, `PartialWord#parameters_for` explicitly sets `declared[modifier] = nil` for every single modifier in the language except `:path` and `:return_to`.
  3. Because `declared.key?(modifier)` becomes `true` (with value `nil`), `Subject#fetch` immediately returns `nil` and never inspects `@fallback`. This prevents ANY other partial in the language from inheriting enclosing container modifiers.
- **Empirical Proof:**
  We constructed an isolated test of a custom container `custom_actions project_id: "my-proj"` wrapping `custom_action "Click"` (`expects content: true, project_id: true`).
  The output:
  ```html
  <div class="box custom_actions"><p class="text custom_action"></p></div>
  ```
  The value `"my-proj"` was completely dropped and rendered empty. When tested with `path: "my-path"`, it rendered `"my-path"`.
- **Suggestion:**
  Remove the hardcoded `%i[path return_to]` check from `PartialWord`. Implement a generic resolution rule for partial modifiers:
  If a modifier declared in `expects` is not passed to the child partial, check if an enclosing container on the subject chain answers that modifier before the chain reaches the `Page` boundary:
  ```ruby
  contract.modifiers.each do |modifier|
    if kwargs.key?(modifier)
      declared[modifier] = kwargs[modifier]
    elsif chain.depth > 1 && chain.current.has?(modifier)
      declared[modifier] = chain.current.fetch(modifier)
    else
      declared[modifier] = nil
    end
  end
  ```
  Alternatively, filter out framework methods (such as Sinatra controller methods) at the `Page` boundary in `subject.rb`, allowing clean fallback across all modifiers without leaking `status: 200`.

---

### [Major] Finding 2: Container Asymmetry and Broken Status Inheritance

- **What:** Even within the new `action` and `actions` pair, `status` cannot be inherited from `actions`.
- **Where:** `lib/vocabulary/actions.sp:1` and `lib/slim_pickins/partial_word.rb:96`
- **Why:**
  `actions.sp` declares `expects children: any, path: true, return_to: true, shape: encloses`. It does not accept `status:`.
  Even if an app defines an actions container with `status: "dormant"`, `action` cannot inherit `status` because `:status` is not in `%i[path return_to]`.
  We proved this empirically: wrapping `action "Check", to: "/actions/check"` in `my_actions path: .name, return_to: "/triage", status: "pending"` resulted in `path` and `return_to` being emitted as hidden fields, while `status` was silently suppressed.
- **Suggestion:**
  Allow `actions` and `action` to handle modifiers uniformly, or support dynamic payload forwarding as proposed in Council Scope Proposal 1 (`payload: :any` / `hidden: :hash`).

---

### [Minor] Finding 3: Tightly-Coupled Hidden Field Enumeration in `action.sp`

- **What:** `lib/vocabulary/action.sp` hardcodes three explicit conditionals for `path`, `return_to`, and `status`:
  ```slim
  choose
    when .path
      hidden path, .path
  choose
    when .return_to
      hidden return_to, .return_to
  choose
    when .status
      hidden status, .status
  ```
- **Why:** While this replaces the rigid 5-argument sentence with conditionals, it still hardcodes dashboard-specific field names into the core vocabulary. An action needing `user_id` or `token` cannot use `action.sp` without modifying the core vocabulary file.
- **Suggestion:** Adopt the Council's R3 Scope Proposal 1 in the future: support dynamic hidden input forwarding for actions.

---

## 3. Adversarial Challenges & Stress-Test Results

### Challenge 1: Non-Path Modifier Inheritance in User Partials
- **Assumption challenged:** "When an outer word pushes parameters onto the chain, any inner partial can read them via overlay fallback."
- **Attack Scenario:** Author a user partial pair (`custom_actions` with `project_id:`, enclosing `custom_action`).
- **Result:** **FAIL**. The child partial received `nil` because `project_id` was not in `%i[path return_to]`.
- **Blast Radius:** Breaches the principle of least surprise for any developer creating composite partials.

### Challenge 2: Status Parameter Inheritance in `actions`
- **Assumption challenged:** "`action` resolves parameters from the subject chain when omitted at call site."
- **Attack Scenario:** Provide `status: "pending"` to an enclosing actions container.
- **Result:** **FAIL**. `action` emitted `path` and `return_to`, but failed to emit `status`.
- **Blast Radius:** Developers cannot define a shared `status` for a group of status-changing actions.

### Challenge 3: Sinatra Helper Collision on Page
- **Assumption challenged:** "Page delegation to helpers only exposes application view helpers."
- **Attack Scenario:** In a Sinatra app, any unsupplied modifier that falls through to `Page` collides with `Sinatra::Base` instance methods. Sinatra defines `def status(value=nil)`, which returns integer `200`.
- **Result:** **CONFIRMED ROOT CAUSE**. Without the hardcoded filter in `partial_word.rb`, `.status` resolves to `200`, generating `<input type="hidden" name="status" value="200">`.
- **Blast Radius:** Fragile name collisions between vocabulary modifiers and Sinatra framework methods.

---

## 4. Verified Claims Matrix

| Claim | Upstream Source | Verification Method | Result | Notes |
|---|---|---|---|---|
| `check_grammar.rb` passes with 0 problems | Worker 1 Report | Ran `ruby check_grammar.rb` | **PASS** | 667 sentences checked, 80 words defined, 0 problems |
| `check_shape.rb` passes with 0 problems | Worker 1 Report | Ran `ruby check_shape.rb` | **PASS** | 442 sentences, mean 1.26 args, 0 problems |
| `check_styles.rb` passes with 0 problems | Worker 1 Report | Ran `ruby check_styles.rb` | **PASS** | 25 classes emitted, 61 seen, 95 rules, 0 problems |
| `bin/verify_pages.rb` passes with 0 problems | Worker 1 Report | Ran `ruby bin/verify_pages.rb` | **PASS** | 10 pages verified, 0 problems |
| Full unit test suite passes | Worker 1 Report | Ran `for f in test/*_test.rb; do ruby $f; done` | **PASS** | 22 test files ran, 0 failures, 0 errors |
| `bin/dashboard_parity.rb` passes | Worker 1 Report | Ran `ruby bin/dashboard_parity.rb` | **PASS** | 25 affordances compared against live port, 0 missing |
| Flexible parity HTML changes justified | Community Bulletin Board | Inspected diff & styles | **PASS** | Dropping `.dormant` on `<form>` has no styling impact in `slim-pickins.css` |
| Elimination of 5-arg outlier in `queue.sp` | Community Bulletin Board | Inspected `examples/dashboard/views/partials/queue.sp` | **PASS** | Replaced 5-arg lines with scoped `actions` block |
| Retirement of `dormant.sp` | Community Bulletin Board | Inspected git status & file deletion | **PASS** | `dormant.sp` removed cleanly |
| Generic container parameter inheritance | Worker 1 Report & Bulletin Board | Ruby script testing custom modifiers | **FAIL (INTEGRITY VIOLATION)** | Hardcoded `%i[path return_to]` in `partial_word.rb:96` breaks inheritance for all other modifiers |

---

## 5. Coverage Gaps & Unverified Items

- **Coverage Gaps:**
  - Upstream investigation failed to test partial parameter inheritance with any modifier other than `path` and `return_to`.
  - Upstream investigation bypassed fixing the root cause of the Sinatra helper collision on `Page`, resulting in the hardcoded shortcut.
- **Unverified Items:** None. All claims and test suites were independently executed and verified.

---

## 6. Required Actions for Approval

1. **Remove the hardcoded `%i[path return_to]` whitelist** from `lib/slim_pickins/partial_word.rb`.
2. **Implement a generic parameter resolution mechanism** in `PartialWord` or `Subject` that:
   - Allows child partials to inherit any unpassed modifier from enclosing container partials on the subject chain.
   - Prevents unsupplied modifiers from leaking past the container boundary into Sinatra/Page controller methods (e.g. stopping resolution before `Page` or denying framework methods on `Page`).
3. **Add unit tests in `test/vocabulary_partials_test.rb`** verifying that arbitrary custom modifiers (e.g. `project_id:`, `status:`) inherit properly from an enclosing container down to child partials.
