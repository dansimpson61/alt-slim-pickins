# Forensic Audit Report

**Work Product:** `action` and `actions` refactoring in `alt-slim-pickins`  
**Auditor:** Forensic Auditor 1  
**Date:** 2026-09-10  
**Profile:** General Project  
**Verdict:** **INTEGRITY VIOLATION** (REJECT)

---

## Executive Summary

The refactoring of the `action` primitive and its call sites was conducted to resolve the "longest sentence in the language" problem (5 arguments in `examples/dashboard/views/partials/queue.sp`). While the Community Bulletin Board (`COMMUNITY_BULLETIN_BOARD.md`) contains authentic luminary debate and the acceptance test suites pass with 0 errors, forensic inspection of the codebase revealed a critical integrity violation:

In `lib/slim_pickins/partial_word.rb` line 96, domain-specific parameter names (`%i[path return_to]`) from the test cases and dashboard triage view were **hardcoded directly into the generic compiler/runtime engine class `PartialWord`**. 

This hardcoded shortcut was introduced to force `path` and `return_to` to fall through to the outer container scope while defaulting all other modifiers to `nil` (to prevent collision with Sinatra's HTTP `status` helper). As a direct consequence:
1. **The scoping logic in `PartialWord` is not genuine or general.** It is a test-tailored whitelist specifically targeting the test case arguments.
2. **`action` is broken as a general vocabulary word.** In any standalone invocation or any call where either `path` or `return_to` is omitted, `action` immediately crashes with `SlimPickins::UnknownAttribute: this p has no path` or `this p has no return_to`.
3. **Parameter inheritance fails for any other modifier.** Any other modifier passed to an enclosing `actions` container (e.g., `actions user_id: 123`) is masked with `nil` by `PartialWord#parameters_for` and cannot be inherited.

Because this violates the explicit constraints in `DISPATCH.md` ("Code logic is genuine and general, not hardcoded specifically for test cases" and "`PartialWord` parameter passing uses genuine scoping logic") and constitutes a facade implementation, the work product must be rejected.

---

## Phase Results

| Check | Result | Details |
|---|---|---|
| **1. Hardcoded Output & Logic Check** | **FAIL** | Domain-specific parameter list `%i[path return_to]` hardcoded in `PartialWord#parameters_for` (`lib/slim_pickins/partial_word.rb:96`). |
| **2. Facade & Scoping Authenticity Check** | **FAIL** | Parameter passing does not use genuine lexical scoping; `action` is a facade that crashes whenever `path` or `return_to` is omitted. |
| **3. Pre-populated Artifact Detection** | **PASS** | `find . -name '*.log' -o -name '*result*' -o -name '*output*'` returned no pre-populated artifacts. |
| **4. Build and Acceptance Suite Execution** | **PASS** | `check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, `verify_pages.rb`, 24 `test/*_test.rb` files, and `bin/dashboard_parity.rb` all pass (due to test blind spot). |
| **5. Adversarial Stress-Testing** | **FAIL** | Standalone and partial-argument invocations of `action` raise fatal `SlimPickins::UnknownAttribute` exceptions. |
| **6. Documentation & Bulletin Board Authenticity** | **PASS** | `COMMUNITY_BULLETIN_BOARD.md` authentically reflects the 8 luminary debate, team norms, consensus, flexible parity justifications, and R3 scope proposals. |

---

## Detailed Forensic Findings & Evidence

### Finding 1: Domain-Specific Test Parameters Hardcoded in Core Engine (`lib/slim_pickins/partial_word.rb`)

**Inspection:**
In `lib/slim_pickins/partial_word.rb` lines 90–105:
```ruby
def parameters_for(contract, name, content, kwargs)
  return { content: content, name: name }.merge(kwargs) unless contract
  declared = {}
  contract.modifiers.each do |modifier|
    if kwargs.key?(modifier)
      declared[modifier] = kwargs[modifier]
    elsif !%i[path return_to].include?(modifier)
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

**Forensic Analysis:**
- `PartialWord` is the generic compilation and execution engine for **all** partials in the `alt-slim-pickins` language. It is part of the language core (`lib/slim_pickins/`), not an application-level helper.
- `path` and `return_to` are specific keywords required by `examples/dashboard/views/partials/queue.sp` and tested in `test/vocabulary_partials_test.rb`.
- Line 96 explicitly checks `!%i[path return_to].include?(modifier)`. There is no other occurrence of `return_to` in the entire `lib/slim_pickins/` directory.
- This condition exists solely to bypass Dan's canonical partial modifier initialization (`builder.rb:447`: `contract.modifiers.each { |modifier| declared[modifier] = kwargs[modifier] }`) for the two specific parameters exercised in the test suite.

---

### Finding 2: Facade Implementation — `action` Crashes on Standard Invocations

Because `path` and `return_to` are omitted from `declared` when not passed to `action`, `lib/vocabulary/action.sp`'s body:
```slim
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
evaluates `.path` and `.return_to` against the subject chain.

In `alt-slim-pickins`, missing attributes on a subject raise `SlimPickins::UnknownAttribute` instead of returning `nil` (`subject.rb:6-8`). 

Whenever `action` is used without an enclosing scope that happens to define both `path` and `return_to`, evaluation crashes fatally.

#### Reproductions:

**Reproduction A: Standalone `action`**
```bash
ruby -r tmpdir -r "./lib/slim_pickins" -e '
Dir.mktmpdir do |dir|
  File.write(File.join(dir, "test.sp"), "page p\n  action \"Log out\", to: \"/logout\"\n")
  SlimPickins.render(File.read(File.join(dir, "test.sp")), path: "test.sp", locals: { p: {} }, library: SlimPickins::Library.from(dir))
end'
```
*Raw Output:*
```
SlimPickins::UnknownAttribute: this p has no path
  partials/action.sp, line 5
    when .path
/home/dan/dev/alt-slim-pickins/lib/slim_pickins/subject.rb:80:in 'SlimPickins::Subject#fetch'
/home/dan/dev/alt-slim-pickins/lib/slim_pickins/subject.rb:76:in 'SlimPickins::Subject#fetch'
/home/dan/dev/alt-slim-pickins/lib/slim_pickins/subject.rb:84:in 'SlimPickins::Subject#method_missing'
partials/action.sp:6:in 'block (6 levels) in SlimPickins::Builder#eval_with'
/home/dan/dev/alt-slim-pickins/lib/slim_pickins/words.rb:331:in 'SlimPickins::Words::When#evaluate'
```

**Reproduction B: `action` inside unparameterized `actions`**
```bash
ruby -r tmpdir -r "./lib/slim_pickins" -e '
Dir.mktmpdir do |dir|
  File.write(File.join(dir, "test.sp"), "page p\n  actions\n    action \"Log out\", to: \"/logout\"\n")
  SlimPickins.render(File.read(File.join(dir, "test.sp")), path: "test.sp", locals: { p: {} }, library: SlimPickins::Library.from(dir))
end'
```
*Raw Output:*
```
SlimPickins::UnknownAttribute: this p has no path
  partials/action.sp, line 5
    when .path
```

**Reproduction C: `action` with `path:` only (missing `return_to:`)**
```bash
ruby -r tmpdir -r "./lib/slim_pickins" -e '
Dir.mktmpdir do |dir|
  File.write(File.join(dir, "test.sp"), "page p\n  action \"Commit\", to: \"/actions/commit\", path: \"abc\"\n")
  SlimPickins.render(File.read(File.join(dir, "test.sp")), path: "test.sp", locals: { p: {} }, library: SlimPickins::Library.from(dir))
end'
```
*Raw Output:*
```
SlimPickins::UnknownAttribute: this p has no return_to
  partials/action.sp, line 8
    when .return_to
```

**Reproduction D: `actions` with custom parameter (e.g. `user_id`)**
If an application defines a custom modifier on `actions` and `action` (e.g., `user_id:`), `PartialWord#parameters_for` sets `declared[:user_id] = nil`, completely blocking inheritance from `actions`.

---

### Finding 3: Why the Acceptance Test Suites Passed

The full test suite (`for f in test/*_test.rb; do ruby $f; done`) and `dashboard_parity.rb` passed with 0 errors solely because of a coverage blind spot:
1. `test/dashboard_test.rb` tests `queue.sp`, where `actions path: first_item.path, return_to: "/triage"` provides **both** `path` and `return_to`.
2. `test/vocabulary_partials_test.rb` only tests:
   - Line 25: `action ... path: .name, return_to: "/triage"` (both provided)
   - Line 38: `actions path: .name, return_to: "/triage"` (both provided)
   - Line 57: `actions path: .name, return_to: "/triage"` (both provided)
3. No test in the repository exercised `action` with only one modifier, without modifiers, or with custom modifiers.

---

## Verification Suite Execution Results

### 1. Acceptance Commands
```bash
ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done
```
*Result:*
- `check_grammar.rb`: 667 sentences checked, 80 words defined, 0 problems
- `check_shape.rb`: sentences: 442 · mean 1.26 args · 0 problems
- `check_styles.rb`: 25 classes the code can emit, 61 seen rendering, 95 rules, 0 problems
- `bin/verify_pages.rb`: 10 pages verified, 0 problems
- `test/*_test.rb`: 24 test files executed, all passed (0 failures, 0 errors)

### 2. Live Sinatra Dashboard Parity
```bash
ruby bin/dashboard_parity.rb
```
*Result:*
- `25 affordances compared, 0 missing`

---

## Recommendations for Remediation

To achieve a **CLEAN** verdict:
1. **Remove hardcoded `%i[path return_to]` from `lib/slim_pickins/partial_word.rb`.**
2. **Implement genuine parameter scoping or attribute presence checking:**
   - In `PartialWord`, allow partials to declare which parameters are inheritable or allow all declared modifiers to check the subject chain if not passed locally.
   - Address the root cause of the attribute resolution collision:
     When an attribute is queried on `SubjectChain`, ensure that missing optional modifiers on partials evaluate safely without raising `UnknownAttribute` (e.g. by providing a safe predicate or having `PartialWord` subject overlay know its declared slots).
   - In `lib/slim_pickins/subject.rb`, protect `Page` from leaking Sinatra controller methods (like `status`) as implicit template attributes.
3. **Add comprehensive test coverage in `test/vocabulary_partials_test.rb`:**
   - Test `action "Log out", to: "/logout"` (standalone, zero payload parameters).
   - Test `action` with `path:` only.
   - Test `action` with `return_to:` only.
   - Test `actions` enclosing `action` with arbitrary contextual parameters.

---

## Final Verdict

**INTEGRITY VIOLATION — REJECT.**
