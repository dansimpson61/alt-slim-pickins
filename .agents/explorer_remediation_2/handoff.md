# Handoff Report — Explorer Remediation 2 to Worker 2

**Handoff Type:** Hard (Remediation Investigation & Architecture Complete)  
**Sender:** Explorer Remediation 2  
**Recipient:** Worker 2  
**Project:** `alt-slim-pickins`  
**Date:** 2026-09-10  
**Working Directory:** `/home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2`  

---

## 1. Observation

1. **Hardcoded Whitelist in Core Engine**:
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
   `%i[path return_to]` is hardcoded in the universal gem runtime class `PartialWord`.

2. **Fatal Runtime Crash on Standalone Invocations**:
   Command:
   ```bash
   ruby -r ./lib/slim_pickins -e '
     SlimPickins.render("page p\n  action \"Logout\", to: \"/logout\"\n", locals: { p: {} })
   '
   ```
   Verbatim error:
   ```
   /home/dan/dev/alt-slim-pickins/lib/slim_pickins/subject.rb:80:in 'SlimPickins::Subject#fetch': this p has no path (SlimPickins::UnknownAttribute)
     partials/action.sp, line 5
       when .path
   ```

3. **Dynamic Model Hijacking**:
   Command:
   ```bash
   ruby -r ./lib/slim_pickins -e '
     puts SlimPickins.render("page article\n  action \"Like\", to: \"/like\"\n", locals: { article: { title: "Joy", path: "/posts/1" } })
   '
   ```
   Verbatim output:
   ```html
   <form class="form" action="/like" method="post"><input type="hidden" name="path" value="/posts/1"><button type="submit" class="button">Like</button></form>
   ```

4. **Sinatra Controller Method Collision**:
   Sinatra defines `helpers.status` returning integer `200`. When unconstrained fall-through reaches `Page`, `when .status` resolves to `200`, emitting `<input type="hidden" name="status" value="200">`.

5. **Test Order Flakiness**:
   Command:
   ```bash
   ruby test/phase4_test.rb --seed 21530
   ```
   Verbatim error:
   ```
     1) Failure:
   Phase4Test#test_every_documented_word_is_implemented [test/phase4_test.rb:17]:
   Expected [:footer, :section, :list, :item, :card, :actions, :aside, :disclosure, :title, :text, :note, :badge, :money, :percent, :number, :time, :figure, :empty, :action, :flash, :search, :thumbnails, :thumb, :scroll] to be empty.
   ```
   Root cause: `Phase4Test` tests `Word.registry` before `Library.builtin` is initialized.

6. **True Test Suite Count**:
   `ls test/*_test.rb` yields exactly 22 test files (not 24, and not the 22 fabricated filenames reported by Worker 1).

7. **Dan's Canonical Optionality Principle**:
   In `lib/slim_pickins/builder.rb:432-447`:
   Dan designed declared slots to default to `nil` so that `choose / when .slot` evaluates falsey without raising `UnknownAttribute`.
   In `lib/slim_pickins/subject.rb:10-18`, Dan noted that only partials pushed with `overlay: true` possess a non-nil `@fallback`. Domain models (`about(name)`) and `Page` have `@fallback == nil`.

---

## 2. Logic Chain

1. From Observation 1, Worker 1 hardcoded `%i[path return_to]` to allow `action` to fall back to an enclosing `actions` container while silencing all other modifiers as `nil`.
2. From Observation 2, because `:path` and `:return_to` were omitted from `declared` when not supplied to `action`, `when .path` in `action.sp` queried `Subject#fetch(:path)`. Because the attribute was not found on `action` or `actions`, lookup traversed all the way to `Page`, where `Subject#fetch` raised `UnknownAttribute: this p has no path`.
3. From Observation 3 and 4, allowing unconstrained traversal down the global subject chain causes `action` to pluck properties from unrelated domain models (e.g. `article.path`) or Sinatra framework controller methods (`status: 200`).
4. From Observation 7, only partial container scopes are pushed onto `Chain` with `overlay: true` (`fallback != nil`). Domain models and `Page` have `fallback == nil`.
5. Therefore, parameter inheritance can be scoped strictly to enclosing overlay container scopes by traversing `.fallback` in `Chain#container_value(modifier)` and terminating the search before reaching domain models or `Page`.
6. From Observation 7 and step 5, if an enclosing container passed modifier `M`, `container_value(M)` returns the value and populates `declared[M]`. If no enclosing container passed `M`, `declared[M]` is populated with `nil`.
7. Because `declared` holds all contract modifiers (with value `nil` when absent), `when .modifier` in `action.sp` evaluates `nil` (falsey). This eliminates `UnknownAttribute` crashes (Observation 2), prevents model attribute hijacking (Observation 3), prevents Sinatra status leaks (Observation 4), and eliminates the hardcoded whitelist (Observation 1) for any modifier across all partials.
8. From Observation 5, pre-loading `SlimPickins::Library.builtin` in `Phase4Test#setup` ensures `Word.registry` is populated before `test_every_documented_word_is_implemented` executes, resolving test order flakiness across all seeds.

---

## 3. Caveats

- **Grammar Contract Invariance**: `lib/vocabulary/actions.sp` continues to declare `path: true, return_to: true`. Adding new modifiers to `actions.sp` requires updating `VOCABULARY.md` via `bin/generate_vocabulary.rb`; keeping `path: true, return_to: true` retains exact parity with `VOCABULARY.md` while our generic engine supports any modifier declared on any partial.
- **Lexer Quote Limitation**: Bare unquoted words (e.g. `flag: false`) are transformed to symbols (`:false`) by `Transform.tree`. This is an inherent property of the slim-pickins lexer grammar and not a bug in `PartialWord`.

---

## 4. Conclusion

The Forensic Audit integrity violation and all reviewer/challenger findings are completely remediable with a clean, 4-file code change that respects the Ode to Joy and the core principles of the language.

### Concrete Implementation Tasks for Worker 2:

1. **`lib/slim_pickins/subject.rb`**:
   - Expose `attr_reader :fallback` and `def overlay? = !@fallback.nil?` on `Subject`.
   - Add `container_value(modifier)` to `Chain`:
     ```ruby
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

2. **`lib/slim_pickins/partial_word.rb`**:
   - Replace `parameters_for`:
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

3. **`lib/slim_pickins/builder.rb`**:
   - Align `Builder#parameters_for` line 447 to use `@chain.container_value(modifier)`.

4. **`test/phase4_test.rb`**:
   - Add `def setup; SlimPickins::Library.builtin; end`.

5. **`test/vocabulary_partials_test.rb`**:
   - Add the 7 new regression & adversarial test methods detailed in Section 4 of `report.md`.

6. **Accurate Reporting**:
   - Execute the 22 test files and record honest, verbatim test execution logs in `worker_2/report.md`.

---

## 5. Verification Method

To independently verify the changes, execute the following commands in `/home/dan/dev/alt-slim-pickins`:

1. **Core Whitelist Check**:
   ```bash
   grep -rn "path return_to" lib/
   ```
   *Expected*: Zero occurrences.

2. **Full Unit Test Suite (22 files)**:
   ```bash
   for f in test/*_test.rb; do ruby $f; done
   ```
   *Expected*: 22 test files ran, 0 failures, 0 errors.

3. **Order Flakiness Check**:
   ```bash
   ruby test/phase4_test.rb --seed 21530
   ```
   *Expected*: 13 runs, 53 assertions, 0 failures, 0 errors.

4. **Acceptance Suite Execution**:
   ```bash
   ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb
   ```
   *Expected*: All 4 checkers exit 0 with 0 problems.

5. **Live Dashboard Parity**:
   ```bash
   ruby bin/dashboard_parity.rb
   ```
   *Expected*: `25 affordances compared, 0 missing`.

6. **Adversarial Standalone & Leakage Check**:
   ```bash
   ruby -r tmpdir -r "./lib/slim_pickins" -e '
     puts SlimPickins.render("page p\n  action \"Logout\", to: \"/logout\"\n", locals: { p: {} })
   '
   ```
   *Expected*: Valid HTML output containing `<form class="form" action="/logout" method="post"><button type="submit" class="button">Logout</button></form>` without errors and without hidden inputs.
