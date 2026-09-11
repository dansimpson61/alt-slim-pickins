# Challenger 2 Empirical Audit & Stress Test Report

**Date:** 2026-09-10  
**Agent:** Challenger 2 (Empirical Challenger)  
**Roles:** critic, specialist  
**Project:** alt-slim-pickins  
**Working Directory:** `/home/dan/dev/alt-slim-pickins/.agents/challenger_2`  
**Verdict:** **REQUEST_CHANGES**

---

## 1. Executive Summary & Verdict

We have completed an empirical audit and adversarial stress-testing of the refactored `action` and `actions` primitives implemented in response to the Ruby Luminaries Council charter.

### The Good:
- **Language vitals improved**: Mean sentence length dropped from **1.28** to **1.26** arguments.
- **5-argument sentence eliminated from real pages**: On real pages (`pages/`, `examples/`, `studio/`), the maximum sentence length is now **4** arguments (down from 5). The 5-argument outliers in `examples/dashboard/views/partials/queue.sp` were successfully refactored into a nested `actions` block.
- **Checkers pass cleanly**: `check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, and `bin/verify_pages.rb` all report 0 problems.
- **Live dashboard parity preserved**: `bin/dashboard_parity.rb` confirms all **25/25** affordances match the canonical dashboard.
- **Pre-existing test failure resolved**: The broken reference to `design_conventions` in `studio/docs_helper.rb` was removed, bringing `test/*_test.rb` to 0 failures and 0 errors.

### The Critical Flaw:
- **`action` is broken for general use**: Whenever `action` is called standalone without `path:` or `return_to:` (e.g. `action "Logout", to: "/logout"`), or inside an `actions` container that does not specify `path:` and `return_to:`, it **crashes with an unhandled fatal runtime error**:
  ```
  SlimPickins::UnknownAttribute: this page has no path
    partials/action.sp, line 5
      when .path
  ```
- **Architectural domain leak**: `lib/slim_pickins/partial_word.rb` hardcodes `%i[path return_to]` into the generic runtime method `parameters_for`. This violates the separation of concerns between generic language primitives and application-specific parameters.

Because `action` is a core vocabulary word defined in `VOCABULARY.md`, breaking its standalone and partial-parameter usage violates the Ode to Joy principle of **Correctness > The House > Clarity > Idiom > Elegance**.

Therefore, the explicit verdict is **REQUEST_CHANGES**.

---

## 2. Empirical Verification of Project Checkers & Tests

All tests and checkers were executed directly in `/home/dan/dev/alt-slim-pickins`.

### 2.1 Language Vitals (`check_shape.rb`)
**Command:** `ruby check_shape.rb`  
**Output:**
```
vitals
  words: 67 — 62 nouns, 5 non-nouns (adjective, adverb, conjunction, determiner, verb)
  shapes: document 5 · encloses 20 · gathers 5 · iterates 1 · presents 19 · registers 8 · says 9
  sentences: 442 · mean 1.26 args · longest 7 · deepest nesting 7
  distinct modifiers: 29 — active children columns content empty from gathers id inside label method open over parents path placeholder precision q required return_to rows shape speech status subject target to type variant
  words used in real pages: 65 of 67 (plus 14 app words: account_card, editor, editor_form, expects, html_preview, preview, queue, report, sidebar_layout, split_pane, test_account_card, unreviewed_card, video, vocabulary)
  0 problems
```

#### Detailed Answers to Dispatch Inquiries:
1. **What is the current longest sentence in the entire language?**
   - In the full corpus scanned by `check_shape.rb` (which includes `lib/vocabulary/*.sp`), the longest sentence has **7 arguments**:
     `lib/vocabulary/action.sp:1`: `expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true, status: true`.
     (Note: `expects` declarations are parsed as sentences by `Transform.tree`.)
   - In **real user-facing pages** (`pages/`, `examples/`, `studio/`), the longest sentence is now **4 arguments**:
     - `examples/dashboard/views/confirm_archive.sp`: `textarea reason, "Why archive this copy?", rows: 2, required: true` (4 args)
     - `examples/dashboard/views/partials/queue.sp`: `action "Set dormant", to: "/actions/status", status: "dormant", variant: neutral` (4 args)
     - `studio/views/partials/editor_form.sp`: `button "Render HTML", type: "submit", to: "/render_html", target: "html_preview"` (4 args)
2. **What is the mean argument count across all sentences?**
   - **1.26 arguments** (reduced from 1.28 arguments prior to refactoring).
3. **Did the 5-argument sentence disappear from real pages?**
   - **YES**. Across all real pages (`pages/`, `examples/`, `studio/`), there are **zero** 5-argument sentences remaining.

### 2.2 Grammar & Word Contracts (`check_grammar.rb`)
**Command:** `ruby check_grammar.rb`  
**Output:**
```
667 sentences checked, 80 words defined, 0 problems
```
- Every word contract validates.
- 0 undefined words.
- 0 unexemplified words.
- 0 ungenerated bullets.

### 2.3 Style Hygiene (`check_styles.rb`)
**Command:** `ruby check_styles.rb`  
**Output:**
```
25 classes the code can emit, 61 seen rendering, 95 rules, 0 problems
```
- 0 unstyled classes.
- 0 orphaned classes.
- 0 unthemed CSS literal values outside `:root`.

### 2.4 Page Verifier (`bin/verify_pages.rb`)
**Command:** `ruby bin/verify_pages.rb`  
**Output:**
```
  proved account.sp
  proved index.sp
  proved controls.sp
  OK            pages/portfolio_table.sp
  OK            pages/account_detail.sp
  OK            pages/roth_form.sp
  OK            pages/specimen.sp
  OK            examples/portfolio/views/index.sp
  OK            examples/portfolio/views/account.sp
  OK            examples/roth/views/controls.sp
  OK            examples/roth/views/partials/report.sp
  OK            examples/dashboard/views/triage.sp
  OK            examples/dashboard/views/confirm_archive.sp

10 pages verified, 0 problems
```

### 2.5 Unit Test Suite (`test/*_test.rb`)
**Command:** `for f in test/*_test.rb; do ruby $f; done`  
**Output:** 22 test files ran; **all passed with 0 failures, 0 errors, 0 skips**.

### 2.6 Live Dashboard Parity (`bin/dashboard_parity.rb`)
**Command:** `ruby bin/dashboard_parity.rb`  
**Output:**
```
  proved confirm_archive.sp
  proved triage.sp

25 affordances compared, 0 missing
```
All 25 semantic affordances (POST routes, hidden inputs for `path`, `return_to`, and `status`, button labels, and navigation links) match the live server at `127.0.0.1:4000`.

---

## 3. Adversarial Stress-Tests & Failure Analysis

### 🚨 Challenge 1 (CRITICAL): Standalone and Partial-Parameter `action` Runtime Crash

#### Observation:
When testing `action` in standard usage patterns that do not provide both `path:` and `return_to:`, the renderer crashes with `SlimPickins::UnknownAttribute`:

```ruby
# Test Harness
require_relative "lib/slim_pickins"

cases = {
  "standalone bare action"      => %(action "Logout", to: "/logout"),
  "action with path only"       => %(action "Delete", to: "/delete", path: "abc"),
  "action with return_to only"  => %(action "Back", to: "/back", return_to: "/home"),
  "actions without params"      => %(actions\n  action "Logout", to: "/logout"),
  "actions with path only"      => %(actions path: "abc"\n  action "Logout", to: "/logout"),
  "actions with return_to only" => %(actions return_to: "/home"\n  action "Logout", to: "/logout"),
}

cases.each do |desc, code|
  begin
    SlimPickins.render(code)
    puts "PASS: #{desc}"
  rescue StandardError, ScriptError => e
    puts "FAIL: #{desc} -> #{e.class}: #{e.message}"
  end
end
```

**Empirical Result:**
```
FAIL: standalone bare action -> SlimPickins::UnknownAttribute: this page has no path
  partials/action.sp, line 5
    when .path
FAIL: action with path only -> SlimPickins::UnknownAttribute: this page has no return_to
  partials/action.sp, line 8
    when .return_to
FAIL: action with return_to only -> SlimPickins::UnknownAttribute: this page has no path
  partials/action.sp, line 5
    when .path
FAIL: actions without params -> SlimPickins::UnknownAttribute: this page has no path
  partials/action.sp, line 5
    when .path
FAIL: actions with path only -> SlimPickins::UnknownAttribute: this page has no return_to
  partials/action.sp, line 8
    when .return_to
FAIL: actions with return_to only -> SlimPickins::UnknownAttribute: this page has no path
  partials/action.sp, line 5
    when .path
```

#### Root Cause Analysis:
1. In `lib/vocabulary/action.sp`:
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
2. In `lib/slim_pickins/partial_word.rb` lines 93–99:
   ```ruby
   contract.modifiers.each do |modifier|
     if kwargs.key?(modifier)
       declared[modifier] = kwargs[modifier]
     elsif !%i[path return_to].include?(modifier)
       declared[modifier] = nil
     end
   end
   ```
3. Worker 1 omitted `path` and `return_to` from `declared` so that attribute lookups inside `action.sp` could fall back to an enclosing `actions` scope on the subject chain.
4. However, in `SlimPickins::Subject#fetch`, looking up an attribute that is absent across the entire chain does not return `nil` or `false`:
   ```ruby
   raise UnknownAttribute.new(attribute, self)
   ```
5. When `action` is rendered without `path:` (or without `return_to:`), `when .path` queries `.path` on the subject chain. Because `:path` is neither in `declared` nor in any enclosing scope, `Subject#fetch` raises `UnknownAttribute: this page has no path`.
6. Why wasn't this caught by existing tests?
   Because `test/vocabulary_partials_test.rb` and `examples/dashboard/views/partials/queue.sp` **only** tested cases where both `path:` and `return_to:` were explicitly passed!

#### Architectural Smells:
- `lib/slim_pickins/partial_word.rb` is the general-purpose runtime engine for *all* vocabulary partials. Hardcoding `%i[path return_to]` directly into `PartialWord#parameters_for` pollutes the engine with application-specific vocabulary concepts.

#### Verified Mitigation:
Instead of hardcoding `%i[path return_to]`, `PartialWord#parameters_for` should check dynamically whether the enclosing subject chain responds to the modifier (`chain.current.has?(modifier)`). If an enclosing scope has the modifier, omit it from `declared` so it falls back; otherwise, populate it with `nil` so `choose / when` evaluates falsy without raising `UnknownAttribute`.

```ruby
def parameters_for(contract, name, content, kwargs)
  return { content: content, name: name }.merge(kwargs) unless contract
  declared = {}
  curr_chain = @builder.send(:chain).current
  contract.modifiers.each do |modifier|
    if kwargs.key?(modifier)
      declared[modifier] = kwargs[modifier]
    elsif curr_chain && curr_chain.has?(modifier)
      # Omit so lookup falls back to the enclosing scope
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
**Empirical Verification of Mitigation:**  
When tested with this implementation, all 6 failing cases **passed instantly**, full test suite passed, and dashboard parity remained 100%.

---

### Challenge 2 (PASS): `actions` Containing Other Words
We verified whether `actions` can enclose `link`, `button`, `choose`, and nested `actions`:

```ruby
sp = <<~SP
actions
  link "Edit", to: "/edit"
  button "Submit"
SP
SlimPickins.render(sp)
```
**Result:** `<div class="actions"><a href="/edit" class="link">Edit</a><button type="button" class="button">Submit</button></div>` (PASS).

Nested `actions`:
```ruby
actions path: "outer", return_to: "/outer"
  actions path: "inner"
    action "Go", to: "/go"
```
**Result:** Correctly emitted nested `<div class="actions">` with `path="inner"` and `return_to="/outer"` (PASS).

---

### Challenge 3 (PASS with Syntax Note): Special Characters & Escaping
We stress-tested special characters in action titles, targets, and parameters:

```ruby
actions path: "path/with spaces/and & special/chars", return_to: "/triage?sort=asc&page=2"
  action "Save & Exit", to: "/actions/save?foo=1&bar=2", variant: primary
  action "Tom <dan@example.com>", to: "/actions/email", variant: neutral
```
**Result:**
- Output correctly HTML-escaped:
  `<form class="form" action="/actions/save?foo=1&amp;bar=2" method="post"><input type="hidden" name="path" value="path/with spaces/and &amp; special/chars"><input type="hidden" name="return_to" value="/triage?sort=asc&amp;page=2"><button type="submit" class="button button--primary">Save &amp; Exit</button></form>`
- All HTML entities (`&amp;`, `&lt;`, `&gt;`) and URL query parameters were safely preserved (PASS).
- *Note:* Internal escaped quotes (`"Commit \"now\""`) fail in `Transform.tree` due to an existing lexer limitation across the entire `alt-slim-pickins` grammar.

---

### Challenge 4 (PASS): Sibling Action Parameter Isolation
We verified that modifiers like `status:` on one action do not leak to sibling actions:

```ruby
actions path: "p", return_to: "/triage"
  action "One", to: "/one", status: "dormant"
  action "Two", to: "/two"
```
**Result:**
- `One` emitted `<input type="hidden" name="status" value="dormant">`.
- `Two` emitted **no** `status` input.
- Isolation is verified (PASS).

---

## 4. Stress Test Results Summary

| Scenario | Input / Expression | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|:---:|
| Standalone `action` | `action "Logout", to: "/logout"` | Render form with submit button | `UnknownAttribute: this page has no path` | **FAIL** |
| `action` with path only | `action "Delete", to: "/delete", path: "abc"` | Render form with path input | `UnknownAttribute: this page has no return_to` | **FAIL** |
| `actions` without params | `actions` enclosing `action "Logout", to: "/logout"` | Render actions div + action form | `UnknownAttribute: this page has no path` | **FAIL** |
| `actions` with mixed children | `actions` enclosing `link` and `button` | Render actions div with link & button | Clean render | **PASS** |
| `actions` with `choose` | `actions` enclosing `choose` with `action` | Conditional action inside actions | Clean render | **PASS** |
| Action parameter override | Child `action` overriding container `path:` | Child `path` takes precedence | Child `path` wins cleanly | **PASS** |
| Sibling parameter isolation | One action with `status:`, sibling without | Only first action emits `status` | Clean isolation | **PASS** |
| HTML entity escaping | `&`, `<`, `>` in label and parameters | Escaped to `&amp;`, `&lt;`, `&gt;` | Properly escaped | **PASS** |
| Query string targets | `to: "/actions/save?tab=all&sort=desc"` | Rendered with escaped `&amp;` | Properly escaped | **PASS** |
| Live dashboard parity | 25 affordances on `/triage` | 0 missing, 0 extra | 25/25 match | **PASS** |

---

## 5. Required Actions for Approval

To achieve approval, Worker 1 must:

1. **Fix `PartialWord#parameters_for` in `lib/slim_pickins/partial_word.rb`**:
   Replace the hardcoded `!%i[path return_to].include?(modifier)` check with generic subject chain fallback detection using `@builder.send(:chain).current.has?(modifier)`.
2. **Add Unit Tests in `test/vocabulary_partials_test.rb`**:
   Add test cases covering:
   - Standalone `action "Logout", to: "/logout"` (no `path` or `return_to` in scope).
   - `action` with `path:` only (no `return_to`).
   - `actions` block without modifiers enclosing `action`.
3. **Re-run Full Test Suite and Checkers**:
   Ensure `check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, `verify_pages.rb`, and `dashboard_parity.rb` all continue to pass.
