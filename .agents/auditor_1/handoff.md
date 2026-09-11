# Hard Handoff Report: Forensic Auditor 1

## 1. Observation
- **Hardcoded Parameters in Core Engine**:
  In `lib/slim_pickins/partial_word.rb` lines 93–99:
  ```ruby
  contract.modifiers.each do |modifier|
    if kwargs.key?(modifier)
      declared[modifier] = kwargs[modifier]
    elsif !%i[path return_to].include?(modifier)
      declared[modifier] = nil
    end
  end
  ```
  `%i[path return_to]` is hardcoded in the generic `PartialWord` engine.
- **Standalone `action` Failure**:
  Executing:
  ```bash
  ruby -r tmpdir -r "./lib/slim_pickins" -e '
  Dir.mktmpdir do |dir|
    File.write(File.join(dir, "test.sp"), "page p\n  action \"Log out\", to: \"/logout\"\n")
    SlimPickins.render(File.read(File.join(dir, "test.sp")), path: "test.sp", locals: { p: {} }, library: SlimPickins::Library.from(dir))
  end'
  ```
  Produces verbatim runtime failure:
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
- **Single-Parameter `action` Failure**:
  Executing:
  ```bash
  ruby -r tmpdir -r "./lib/slim_pickins" -e '
  Dir.mktmpdir do |dir|
    File.write(File.join(dir, "test.sp"), "page p\n  action \"Commit\", to: \"/actions/commit\", path: \"abc\"\n")
    SlimPickins.render(File.read(File.join(dir, "test.sp")), path: "test.sp", locals: { p: {} }, library: SlimPickins::Library.from(dir))
  end'
  ```
  Produces verbatim runtime failure:
  ```
  SlimPickins::UnknownAttribute: this p has no return_to
    partials/action.sp, line 8
      when .return_to
  ```
- **Test Suite Blind Spot**:
  `test/dashboard_test.rb:44` and `test/vocabulary_partials_test.rb:25,38,57` only ever call `action` when **both** `path` and `return_to` are explicitly supplied. Zero tests exist in the test suite for `action` with 0 or 1 payload parameters.
- **Suite and Checker Runs**:
  `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done` exited with code 0.
  `ruby bin/dashboard_parity.rb` reported `25 affordances compared, 0 missing`.

## 2. Logic Chain
1. From Observation 1, `PartialWord#parameters_for` special-cases `%i[path return_to]`, preventing them from being initialized to `nil` in `declared`.
2. From Observation 2 and 3, because `path` and `return_to` are not in `declared`, `lib/vocabulary/action.sp`'s lines `when .path` and `when .return_to` attempt to fetch them from the subject chain. When neither is defined on the page or an enclosing container, `Subject#fetch` raises `SlimPickins::UnknownAttribute`.
3. From Observation 4 and 5, the existing test suite and parity checker pass solely because the test cases always pass both `path` and `return_to`.
4. From DISPATCH.md, the auditor must verify that "Code logic is genuine and general, not hardcoded specifically for test cases" and "`PartialWord` parameter passing uses genuine scoping logic".
5. Therefore, the implementation in `PartialWord` is a test-tailored shortcut and facade that violates the integrity requirements.

## 3. Caveats
- No caveats. The issue was empirically reproduced with raw tool outputs and backtraces.

## 4. Conclusion
The refactoring contains an **INTEGRITY VIOLATION** due to hardcoded parameter symbols in `PartialWord` and broken generality of the `action` primitive. The work product must be **REJECTED**.

## 5. Verification Method
1. Inspect `lib/slim_pickins/partial_word.rb:96`:
   Notice the hardcoded `%i[path return_to]`.
2. Run the empirical failure commands:
   ```bash
   ruby -r tmpdir -r "./lib/slim_pickins" -e '
   Dir.mktmpdir do |dir|
     File.write(File.join(dir, "test.sp"), "page p\n  action \"Log out\", to: \"/logout\"\n")
     SlimPickins.render(File.read(File.join(dir, "test.sp")), path: "test.sp", locals: { p: {} }, library: SlimPickins::Library.from(dir))
   end'
   ```
   Confirm that it crashes with `SlimPickins::UnknownAttribute: this p has no path`.
3. Read the complete audit report in `/home/dan/dev/alt-slim-pickins/.agents/auditor_1/report.md`.
