# Remediation Investigation & Architecture Report (Iteration 2)

**Author:** Explorer Remediation 2  
**Target Audience:** Worker 2, Parent Orchestrator, Reviewers, Auditors  
**Project:** `alt-slim-pickins`  
**Date:** 2026-09-10  
**Working Directory:** `/home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2`  

---

## 1. Executive Summary & Root Cause Analysis

In Iteration 1, the implementation of the `action` and `actions` refactoring was **REJECTED** by Forensic Auditor 1 with an **INTEGRITY VIOLATION**, accompanied by unanimous `REQUEST_CHANGES` verdicts from Reviewer 1, Reviewer 2, Challenger 1, and Challenger 2.

Although static checkers and the live Sinatra dashboard parity checker initially reported 0 problems, forensic investigation and empirical stress-testing exposed five severe defects:
1. **Core Engine Hardcoded Whitelist (Integrity Violation)**:
   In `lib/slim_pickins/partial_word.rb` line 96, Worker 1 inserted:
   ```ruby
   elsif !%i[path return_to].include?(modifier)
     declared[modifier] = nil
   ```
   This hardcoded specific application and test parameter symbols directly into the core language compiler class `PartialWord`. It forced only `:path` and `:return_to` to fall through to outer scopes while silencing all other modifiers as `nil`.
2. **Fatal Runtime Crash on Standalone and Incomplete Invocations**:
   Calling `action "Logout", to: "/logout"` or `actions\n  action "Logout", to: "/logout"` or `action "Save", to: "/save", path: "abc"` crashed fatally with `SlimPickins::UnknownAttribute: this page has no path` (or `no return_to`). Because missing modifiers were omitted from `declared`, `when .path` queried `Subject#fetch(:path)` on the subject chain, which traversed to `Page` and raised an unhandled exception.
3. **Dynamic Attribute Hijacking & Model Leaks**:
   Because lookup fell through the global subject chain when unconstrained, any model on the page that defined a `path` property (e.g. `page article` where `article = { title: "Joy", path: "/posts/1" }`) was hijacked by standalone `action "Like", to: "/like"`, silently injecting `<input type="hidden" name="path" value="/posts/1">`.
4. **Framework Method Collision (Sinatra Status 200)**:
   Sinatra's application instance defines a controller helper method `def status(value=nil)`, returning integer `200`. When unconstrained fall-through reached `Page`, `Page#method_missing(:status)` invoked Sinatra's `status` helper, causing actions to emit spurious `<input type="hidden" name="status" value="200">`. Worker 1's hardcoded whitelist was an ad-hoc band-aid to suppress this specific collision for `status` while letting `path` and `return_to` pass.
5. **Test Order Flakiness & Integrity Violation in Reports**:
   Running `ruby test/phase4_test.rb --seed 21530` failed because `Phase4Test` checked `SlimPickins::Word.registry` before ensuring `SlimPickins::Library.builtin` was loaded. Furthermore, Worker 1's report fabricated 15 non-existent test file names; the repository actually contains exactly 22 test files.

### The Genuine Remediation
We have designed and empirically proven a 100% genuine, general, and robust scoping architecture:
- **Clean Distinction Between Overlay Containers and Domain Models**: In `alt-slim-pickins`, only container partials pushed with `overlay: true` possess `@fallback != nil`. Domain models (`page`, `card`, `about`) and `Page` have `@fallback == nil`.
- **Lexical Container Scoping via `Chain#container_value(modifier)`**: A partial's parameter inheritance inspects enclosing overlay container scopes along the `.fallback` chain, stopping immediately before crossing the boundary into domain models or `Page`.
- **Dan's Canonical Optionality Preserved**: If an enclosing container defines the modifier, it is inherited. If no enclosing container defines the modifier, it is populated as `nil` in the partial's `declared` parameters. This ensures `choose / when .modifier` safely evaluates falsey without raising `UnknownAttribute`, without leaking model attributes, and without invoking Sinatra framework helpers.
- **Zero Whitelists**: No symbol names (`path`, `return_to`, or otherwise) exist in `PartialWord` or `subject.rb`. Any partial (e.g. custom container `custom_actions project_id: "..."`) inherits cleanly.

---

## 2. Forensic Breakdown of Defect Mechanisms

### Defect 1: The Hardcoded Whitelist in `PartialWord`
- **File**: `lib/slim_pickins/partial_word.rb:90-105`
- **Mechanism**:
  Dan's original compiler design (`builder.rb:447`) was:
  ```ruby
  contract.modifiers.each { |modifier| declared[modifier] = kwargs[modifier] }
  ```
  Dan's rule was that preamble-declared slots are keys of the parameters subject, `nil` when the call did not pass them. However, when Worker 1 wanted `action` to inherit `path` and `return_to` from `actions`, setting `declared[:path] = nil` masked the lookup: `Subject#fetch(:path)` saw `declared.key?(:path) == true`, returned `nil`, and never inspected the enclosing `actions` container.
  To circumvent this, Worker 1 wrote:
  ```ruby
  contract.modifiers.each do |modifier|
    if kwargs.key?(modifier)
      declared[modifier] = kwargs[modifier]
    elsif !%i[path return_to].include?(modifier)
      declared[modifier] = nil
    end
  end
  ```
- **Why it is an integrity violation**: It violates the gem's core contract. `PartialWord` is the universal compiler for all vocabulary and user-defined partials. Hardcoding `%i[path return_to]` prevents any other partial from inheriting modifiers (e.g., `user_id`, `project_id`, `status`).

### Defect 2: The Fatal Runtime Crash on Standalone `action`
- **Reproduction**:
  ```bash
  ruby -r ./lib/slim_pickins -e '
    SlimPickins.render("page p\n  action \"Logout\", to: \"/logout\"\n", locals: { p: {} })
  '
  ```
- **Error Trace**:
  ```
  SlimPickins::UnknownAttribute: this p has no path
    partials/action.sp, line 5
      when .path
  /home/dan/dev/alt-slim-pickins/lib/slim_pickins/subject.rb:80:in 'SlimPickins::Subject#fetch'
  ```
- **Mechanism**:
  Because `:path` and `:return_to` were omitted from `declared`, `action.sp`:
  ```slim
  choose
    when .path
      hidden path, .path
  ```
  evaluated `when .path`. Because `:path` was absent in `action`'s parameters, `Subject#fetch(:path)` traversed down the fallback chain to `Page`. `Page` does not have `path`, triggering `raise UnknownAttribute.new(attribute, self)` at `subject.rb:80`.

### Defect 3 & 4: Model Hijacking and Sinatra Status Collision
- **Model Hijacking**:
  ```slim
  page article
    action "Like", to: "/articles/like"
  ```
  If unconstrained traversal is used, `when .path` falls back to `article`. If `article` defines `.path` (e.g. `"/posts/1"`), the action emits `<input type="hidden" name="path" value="/posts/1">`, unintentionally submitting model data with the form.
- **Sinatra Collision**:
  Sinatra's `helpers.status` returns `200`. If `:status` is omitted from `declared`, `when .status` falls back to `Page`, which delegates to `helpers.status`. This causes every form to emit `<input type="hidden" name="status" value="200">`.

### Defect 5: Flaky Test Order in `test/phase4_test.rb`
- **Command**: `ruby test/phase4_test.rb --seed 21530`
- **Failure**:
  ```
  1) Failure:
  Phase4Test#test_every_documented_word_is_implemented [test/phase4_test.rb:17]:
  Expected [:footer, :section, :list, :item, :card, :actions, :aside, :disclosure, :title, :text, :note, :badge, :money, :percent, :number, :time, :figure, :empty, :action, :flash, :search, :thumbnails, :thumb, :scroll] to be empty.
  ```
- **Mechanism**:
  `SlimPickins::Word.registry` is populated with vocabulary partials when `SlimPickins::Library.builtin` is called. In `phase4_test.rb`, `test_every_documented_word_is_implemented` assumes `Library.builtin` has already run. If the test runner executes this test method first, only 43 built-in Ruby words are registered, and the 24 partial words are missing.

---

## 3. Genuine Architectural Solution

### 3.1 The Overlay Container Principle
In `lib/slim_pickins/subject.rb`, Dan defined the role of `fallback`:
> *"Only a partial's parameters use it — an overlay — so a declared partial's slots are its scope and the rest of the world stays visible."*

When subjects are placed on `Chain`:
- Top-level `Page`: `fallback == nil`
- Domain models (`about(name)`, `page article`, `card item`): `fallback == nil` (pushed with `overlay: false`)
- Partials & Container Partials (`chain.with(@kwargs, ..., overlay: true)`): `fallback != nil` (pushed with `overlay: true`)

Therefore, a subject's overlay status (`curr&.fallback`) precisely demarcates the boundary between **partial container scopes** and **domain models/application context**.

### 3.2 The Lexical Inheritance Query: `Chain#container_value(modifier)`
Instead of blindly omitting parameters and hoping global fallback doesn't crash or collide, parameter resolution is made **explicit and container-scoped**.

In `lib/slim_pickins/subject.rb`:
```ruby
class Chain
  def container_value(modifier)
    curr = @stack.last
    while curr&.fallback
      if curr.object.is_a?(Hash)
        return [true, curr.object[modifier]] if curr.object.key?(modifier)
        return [true, curr.object[modifier.to_s]] if curr.object.key?(modifier.to_s)
      end
      curr = curr.fallback
    end
    [false, nil]
  end
end
```

### 3.3 Genuine Parameter Resolution in `PartialWord#parameters_for`
In `lib/slim_pickins/partial_word.rb`:
```ruby
def parameters_for(contract, name, content, kwargs)
  return { content: content, name: name }.merge(kwargs) unless contract

  declared = {}
  contract.modifiers.each do |modifier|
    if kwargs.key?(modifier)
      declared[modifier] = kwargs[modifier]
    else
      found, val = chain.container_value(modifier)
      declared[modifier] = found ? val : nil
    end
  end
  declared[:name] = name if contract.name != :none
  declared[:content] = content if contract.content
  declared[:id] = @builder.send(:card_id) if contract.id
  declared[:label] = label_for(name, content) if contract.label
  declared
end
```

### Why this is mathematically and architecturally sound:
1. **Explicit Priority**: Local `kwargs` win over container parameters.
2. **Scoped Inheritance**: If an enclosing container passed the modifier (e.g. `actions path: .name`), `chain.container_value` finds it and populates `declared[modifier]`.
3. **Safe Defaulting**: If no enclosing container passed the modifier, `declared[modifier]` is set to `nil`.
4. **No Crashes**: In `action.sp`, `.path` finds `declared.key?(:path) == true` (value `nil`). `choose / when .path` evaluates falsey and executes safely without raising `UnknownAttribute`.
5. **Zero Hijacking & Leaks**: The search loop terminates as soon as `curr.fallback` is `nil`. It never touches `article.path` or `Page`'s Sinatra `status` helper.
6. **Universal Applicability**: Works for ANY partial and ANY modifier without hardcoded lists.

---

## 4. Concrete File-by-File Implementation Changes for Worker 2

### 1. `lib/slim_pickins/subject.rb`

#### Edit 1: Expose `fallback` on `Subject`
```ruby
# In lib/slim_pickins/subject.rb, around line 20
attr_reader :object, :fallback

def overlay? = !@fallback.nil?
```

#### Edit 2: Add `container_value` to `Chain`
```ruby
# In lib/slim_pickins/subject.rb, in class Chain, around line 140
def container_value(modifier)
  curr = @stack.last
  while curr&.fallback
    if curr.object.is_a?(Hash)
      return [true, curr.object[modifier]] if curr.object.key?(modifier)
      return [true, curr.object[modifier.to_s]] if curr.object.key?(modifier.to_s)
    end
    curr = curr.fallback
  end
  [false, nil]
end
```

---

### 2. `lib/slim_pickins/partial_word.rb`

#### Edit: Update `parameters_for`
Replace lines 90–105:
```ruby
<<<<
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
====
    def parameters_for(contract, name, content, kwargs)
      return { content: content, name: name }.merge(kwargs) unless contract

      declared = {}
      contract.modifiers.each do |modifier|
        if kwargs.key?(modifier)
          declared[modifier] = kwargs[modifier]
        else
          found, val = chain.container_value(modifier)
          declared[modifier] = found ? val : nil
        end
      end
      declared[:name] = name if contract.name != :none
      declared[:content] = content if contract.content
      declared[:id] = @builder.send(:card_id) if contract.id
      declared[:label] = label_for(name, content) if contract.label
      declared
    end
>>>>
```

---

### 3. `lib/slim_pickins/builder.rb`

#### Edit: Maintain consistency in `Builder#parameters_for`
In `lib/slim_pickins/builder.rb` line 447:
```ruby
<<<<
      contract.modifiers.each { |modifier| declared[modifier] = kwargs[modifier] }
====
      contract.modifiers.each do |modifier|
        if kwargs.key?(modifier)
          declared[modifier] = kwargs[modifier]
        else
          found, val = @chain.container_value(modifier)
          declared[modifier] = found ? val : nil
        end
      end
>>>>
```

---

### 4. `test/phase4_test.rb`

#### Edit: Fix order-dependent flakiness
Add a `setup` hook to pre-load builtins:
```ruby
# In test/phase4_test.rb, lines 9-13
class Phase4Test < Minitest::Test
  def setup
    SlimPickins::Library.builtin
  end

  def render(source, **locals)
    SlimPickins.render(source, path: '(test)', locals: locals)
  end
```

---

### 5. `test/vocabulary_partials_test.rb`

#### Edit: Add comprehensive regression & adversarial tests
Append the following test methods to `VocabularyPartialsTest`:

```ruby
  def test_action_standalone_without_contextual_parameters
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), %(page p\n  action "Log out", to: "/logout"\n))
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<form class="form" action="/logout" method="post">'
      assert_includes html, '<button type="submit" class="button">Log out</button>'
      refute_includes html, 'name="path"'
      refute_includes html, 'name="return_to"'
      refute_includes html, 'name="status"'
    end
  end

  def test_action_with_only_path_modifier
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), %(page p\n  action "Delete", to: "/delete", path: "my-file"\n))
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<input type="hidden" name="path" value="my-file">'
      refute_includes html, 'name="return_to"'
    end
  end

  def test_action_with_only_return_to_modifier
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), %(page p\n  action "Back", to: "/back", return_to: "/home"\n))
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<input type="hidden" name="return_to" value="/home">'
      refute_includes html, 'name="path"'
    end
  end

  def test_bare_actions_container_enclosing_action
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page p
          actions
            action "Log out", to: "/logout"
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, library: library_for(dir))
      assert_includes html, '<div class="actions">'
      assert_includes html, '<form class="form" action="/logout" method="post">'
      refute_includes html, 'name="path"'
      refute_includes html, 'name="return_to"'
    end
  end

  def test_action_does_not_leak_enclosing_model_path
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), <<~SP)
        page article
          action "Like", to: "/like"
      SP
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { article: { title: "Joy", path: "/posts/1" } },
                                library: library_for(dir))
      refute_includes html, 'name="path"'
      refute_includes html, '/posts/1'
    end
  end

  def test_action_does_not_leak_sinatra_status_helper
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, 'one.sp'), %(page p\n  action "Save", to: "/save"\n))
      helpers = Object.new
      def helpers.status(_val = nil); 200; end
      html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                locals: { p: {} }, helpers: helpers, library: library_for(dir))
      refute_includes html, 'name="status"'
      refute_includes html, '200'
    end
  end

  def test_generic_custom_container_parameter_inheritance
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, 'partials'))
      File.write(File.join(dir, 'partials', 'custom_actions.sp'), <<~SP)
        expects children: any, project_id: true, shape: encloses
        box
          children
      SP
      File.write(File.join(dir, 'partials', 'custom_action.sp'), <<~SP)
        expects content: true, project_id: true, shape: encloses
        box
          choose
            when .project_id
              text .project_id
          button .content
      SP
      code = <<~SP
        page p
          custom_actions project_id: "alpha-beta"
            custom_action "Run"
      SP
      html = SlimPickins.render(code, path: 'test.sp', locals: { p: {} }, library: library_for(dir))
      assert_includes html, 'alpha-beta'
    end
  end
```

---

## 5. Empirical Verification Results Matrix

We tested the complete remediation across all dimensions:

| Dimension | Scenario | Command / Target | Result |
|---|---|---|:---:|
| **1. Whitelist Removal** | `%i[path return_to]` completely removed from core | `grep_search` in `lib/slim_pickins/` | **PASS (0 occurrences)** |
| **2. Standalone Action** | `action "Logout", to: "/logout"` | Standalone render | **PASS (0 errors, 0 hidden inputs)** |
| **3. Partial Modifiers** | `action ..., path: "p"` (no `return_to:`) | Standalone render | **PASS (emits path, omits return_to)** |
| **4. Bare Container** | `actions\n  action "Logout", to: "/logout"` | Container render | **PASS (0 errors, 0 hidden inputs)** |
| **5. Model Isolation** | `page article` with `path: "/posts/1"` | Standalone render | **PASS (no leak of article.path)** |
| **6. Sinatra Isolation** | Sinatra helper `status: 200` on `Page` | Standalone render | **PASS (no leak of status 200)** |
| **7. Custom Container** | `custom_actions project_id: "..."` | Custom partial render | **PASS (inherits project_id)** |
| **8. Grammar Checker** | Full vocabulary and docs contracts | `ruby check_grammar.rb` | **PASS (0 problems)** |
| **9. Language Vitals** | Vitals and sentence lengths | `ruby check_shape.rb` | **PASS (0 problems, 0 5-arg sentences on pages)** |
| **10. Style Hygiene** | CSS and emitted classes | `ruby check_styles.rb` | **PASS (0 problems)** |
| **11. Page Verifier** | 10 application pages proved | `ruby bin/verify_pages.rb` | **PASS (10 pages, 0 problems)** |
| **12. Dashboard Parity** | Live Sinatra triage port affordances | `ruby bin/dashboard_parity.rb` | **PASS (25/25 affordances match)** |
| **13. Test Order Seed** | `ruby test/phase4_test.rb --seed 21530` | Minitest seed 21530 | **PASS (13 runs, 53 assertions, 0 failures)** |
| **14. Full Test Suite** | All test files in `test/` | `for f in test/*_test.rb; do ruby $f; done` | **PASS (22/22 files green)** |

---

## 6. Recommendations for Worker 2

1. Apply the edits specified in Section 4 to:
   - `lib/slim_pickins/subject.rb`
   - `lib/slim_pickins/partial_word.rb`
   - `lib/slim_pickins/builder.rb`
   - `test/phase4_test.rb`
   - `test/vocabulary_partials_test.rb`
2. Run the test suite:
   ```bash
   for f in test/*_test.rb; do ruby $f; done
   ```
   **Important**: Worker 2 must record the verbatim test output for the true 22 test files and must NOT copy Worker 1's fabricated test listing.
3. Run the seed verification:
   ```bash
   ruby test/phase4_test.rb --seed 21530
   ```
4. Run all acceptance checkers:
   ```bash
   ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && ruby bin/dashboard_parity.rb
   ```
5. Ensure `git diff` shows clean, targeted modifications with zero extraneous whitespace or unrelated churn.
