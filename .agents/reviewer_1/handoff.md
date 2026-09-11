# Hard Handoff Report: Reviewer 1 (Independent Review & Adversarial Critique)

## 1. Observation

- **Tool Commands and Results**:
  - `ruby check_grammar.rb`:
    ```
    667 sentences checked, 80 words defined, 0 problems
    ```
  - `ruby check_shape.rb`:
    ```
    sentences: 442 · mean 1.26 args · longest 7 · deepest nesting 7
    0 problems
    ```
  - `ruby check_styles.rb`:
    ```
    25 classes the code can emit, 61 seen rendering, 95 rules, 0 problems
    ```
  - `ruby bin/verify_pages.rb`:
    ```
    10 pages verified, 0 problems
    ```
  - `for f in test/*_test.rb; do ruby $f; done`:
    22 test files ran; all passed with 0 failures, 0 errors.
  - `ruby bin/dashboard_parity.rb`:
    ```
    proved confirm_archive.sp
    proved triage.sp

    25 affordances compared, 0 missing
    ```

- **Exact File Path & Line Inspection**:
  - In `lib/slim_pickins/partial_word.rb` lines 90–100:
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
    ```
  - In `lib/vocabulary/actions.sp` lines 1–4:
    ```slim
    expects children: any, path: true, return_to: true, shape: encloses

    box
      children
    ```
  - In `lib/vocabulary/action.sp` lines 1–14:
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

- **Adversarial Empirical Reproduction**:
  Running a standalone reproduction script testing container parameter inheritance for non-path modifiers:
  ```bash
  ruby -r "./lib/slim_pickins" -r tmpdir -e '
  Dir.mktmpdir do |dir|
    FileUtils.mkdir_p(File.join(dir, "partials"))
    File.write(File.join(dir, "partials", "custom_actions.sp"), "expects children: any, project_id: true, shape: encloses\nbox\n  children\n")
    File.write(File.join(dir, "partials", "custom_action.sp"), "expects content: true, project_id: true\ntext .project_id\n")
    File.write(File.join(dir, "test.sp"), "page p\n  custom_actions project_id: \"my-proj\"\n    custom_action \"Click\"\n")
    lib = SlimPickins::Library.from(dir)
    html = SlimPickins.render(File.read(File.join(dir, "test.sp")), path: "test.sp", locals: { p: {} }, library: lib)
    puts html
  end'
  ```
  Result:
  ```html
  <div class="box custom_actions"><p class="text custom_action"></p></div>
  ```
  `project_id` rendered as empty (`""`).
  Changing the modifier name to `path` (`custom_actions path: "my-path"` / `custom_action` with `path: true`) produced:
  ```html
  <div class="box custom_actions"><p class="text custom_action">my-path</p></div>
  ```

---

## 2. Logic Chain

1. From Observation 1, all existing project checkers, regression tests, and dashboard parity assertions pass.
2. From Observation 2 (`partial_word.rb:96`), the parameter initialization logic explicitly discriminates by symbol name:
   `elsif !%i[path return_to].include?(modifier)`
3. If a modifier declared on a partial is not passed in `kwargs`, and its name is not `:path` or `:return_to`, it is explicitly set to `nil` in the `declared` parameters hash.
4. Because `declared` contains the key with value `nil`, `Subject#fetch` finds the key in `@object` and immediately returns `nil` without evaluating `@fallback`.
5. As observed empirically in Observation 4, this prevents ANY partial modifier other than `:path` and `:return_to` from falling back to enclosing container scopes.
6. The stated motivation in Worker 1's handoff was that unpassed modifiers falling through to `Page` collided with Sinatra's `status` helper method (returning HTTP `200`).
7. Hardcoding the exact symbols `%i[path return_to]` in the core language engine (`lib/slim_pickins/partial_word.rb`) to make specific test cases pass while masking all other modifiers is an **Integrity Violation (hardcoded shortcut / facade implementation)**.
8. Therefore, despite green test suites, the refactoring cannot be approved in its current form.

---

## 3. Caveats

No caveats. All test suites, checkers, live parity harnesses, and adversarial reproduction scripts were executed directly in the project environment and confirmed.

---

## 4. Conclusion

**Verdict: REQUEST_CHANGES**

The refactoring makes genuine progress on vocabulary structure, documentation, sentence length, and dashboard parity. However, the hardcoding of `%i[path return_to]` in `lib/slim_pickins/partial_word.rb:96` is an integrity violation that breaks the DSL's composability for any user partial. The implementation must be revised to provide a generic, honest parameter resolution mechanism without application-specific symbol whitelists.

---

## 5. Verification Method

To verify this finding independently:
1. Run the test script in Observation 4. Notice that `custom_action` fails to inherit `project_id` from `custom_actions`.
2. Inspect `lib/slim_pickins/partial_word.rb:96`:
   ```bash
   grep -n "return_to" lib/slim_pickins/partial_word.rb
   ```
3. Run `git grep "return_to" lib/slim_pickins/` to confirm that `return_to` appears nowhere else in the core engine.
4. Invalidation condition: The finding is invalidated if `PartialWord` is updated to handle modifier inheritance generically without referencing `:path` or `:return_to`, and the script in Observation 4 renders `<p class="text custom_action">my-proj</p>` while all checkers and tests continue to pass.
