# Dispatch to Worker 2 (Remediation Implementation)

## Mandatory Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

## Mission
Implement the genuine, clean parameter scoping and context inheritance mechanism in `alt-slim-pickins` designed by Explorer Remediation 2. Completely eliminate the hardcoded whitelist (`%i[path return_to]`) from `PartialWord`, fix standalone `action` crashes, prevent domain model attribute hijacking, and eliminate test order flakiness in `Phase4Test`.

## Mandatory Inputs (Read ALL of these)
- `/home/dan/dev/alt-slim-pickins/.agents/ORIGINAL_REQUEST.md` (Read first!)
- `/home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/handoff.md` (Step-by-step implementation guide)
- `/home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/report.md` (Full architectural investigation)
- `/home/dan/dev/alt-slim-pickins/.agents/auditor_1/report.md` (Forensic audit report on Iteration 1 failure)

## Assigned Files & Write Ownership
You have exclusive write ownership of:
- `lib/slim_pickins/subject.rb`
- `lib/slim_pickins/partial_word.rb`
- `lib/slim_pickins/builder.rb`
- `test/phase4_test.rb`
- `test/vocabulary_partials_test.rb`
- `/home/dan/dev/alt-slim-pickins/.agents/worker_2/`

Do NOT touch any other files without explicit necessity.

## Concrete Implementation Steps
1. **`lib/slim_pickins/subject.rb`**:
   - Expose `attr_reader :fallback` and `def overlay? = !@fallback.nil?` on `Subject`.
   - Add `Chain#container_value(modifier)` to query container values strictly through overlay fallback scopes:
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
   - In `PartialWord#parameters_for`, remove `%i[path return_to]`.
   - Check local `kwargs` first, then query `chain.container_value(modifier)`. Default unsupplied modifiers to `nil`:
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
   - In `Builder#parameters_for` line 447, align with `chain.container_value(modifier)`.
4. **`test/phase4_test.rb`**:
   - Add `def setup; SlimPickins::Library.builtin; end` to ensure all 67 words are registered before assertions run, eliminating seed order flakiness.
5. **`test/vocabulary_partials_test.rb`**:
   - Add comprehensive test methods covering:
     - Standalone `action` (no `path` or `return_to`)
     - `action` with `path:` only
     - `action` with `return_to:` only
     - `actions` block without modifiers
     - Custom modifier inheritance across containers
     - No attribute hijacking from page models
     - No framework method collision (`status: 200`)
6. **Execute Verification Commands & Document Verbatim**:
   - Run: `grep -rn "path return_to" lib/` (must return 0 results)
   - Run: `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb`
   - Run: `for f in test/*_test.rb; do ruby $f; done`
   - Run: `ruby bin/dashboard_parity.rb`
   - Run: `ruby test/phase4_test.rb --seed 21530`
   - Record exact, verbatim output in `worker_2/report.md` (do not summarize or fabricate test counts).

## Output Requirements
Generate:
- `/home/dan/dev/alt-slim-pickins/.agents/worker_2/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/worker_2/handoff.md`

Send completion message to parent when finished.

## 2026-09-10T22:55:00Z

<USER_REQUEST>
You are Worker 2.
Your working directory is /home/dan/dev/alt-slim-pickins/.agents/worker_2.
Project root is /home/dan/dev/alt-slim-pickins.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. An auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Read /home/dan/dev/alt-slim-pickins/.agents/worker_2/DISPATCH.md and all inputs referenced therein, specifically:
- /home/dan/dev/alt-slim-pickins/.agents/ORIGINAL_REQUEST.md
- /home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/handoff.md
- /home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/report.md
- /home/dan/dev/alt-slim-pickins/.agents/auditor_1/report.md

Implement the genuine scoping mechanism in lib/slim_pickins/subject.rb, lib/slim_pickins/partial_word.rb, lib/slim_pickins/builder.rb, fix test/phase4_test.rb, and add the comprehensive tests in test/vocabulary_partials_test.rb.
Run all tests and checkers, record verbatim outputs in /home/dan/dev/alt-slim-pickins/.agents/worker_2/report.md and /home/dan/dev/alt-slim-pickins/.agents/worker_2/handoff.md, and send a completion message to the parent orchestrator via send_message when done.
</USER_REQUEST>
