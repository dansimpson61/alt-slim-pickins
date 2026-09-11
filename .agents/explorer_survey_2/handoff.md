# Handoff Report — Call Sites & Verification Pipeline

**Agent**: Explorer 2 (Call Site Verification Explorer)  
**Target Path**: `/home/dan/dev/alt-slim-pickins/.agents/explorer_survey_2/handoff.md`  
**Full Report**: `/home/dan/dev/alt-slim-pickins/.agents/explorer_survey_2/report.md`  
**Date**: 2026-09-10  

---

### 1. Observation

1. **Call sites of `action` in templates**:
   - `examples/dashboard/views/triage.sp:9` calls `queue`. It contains zero direct calls to `action`.
   - `examples/dashboard/views/partials/queue.sp` contains the only three calls to `action` in the entire repository:
     - Line 12: `action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary`
     - Line 14: `action "Archive", to: "/actions/archive", path: first_item.path, return_to: "/triage", variant: neutral`
     - Line 15: `action "Skip 30d", to: "/actions/skip", path: first_item.path, return_to: "/triage", variant: neutral`
   - Line 13 in `queue.sp` calls `dormant "Set dormant", path: first_item.path`, which is an ad-hoc partial (`examples/dashboard/views/partials/dormant.sp`) that hardcodes `<input type="hidden" name="status" value="dormant">`.
   - `lib/vocabulary/action.sp:1-8` defines `action`:
     ```slim_pickins
     expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true

     form method: post, to: .to
       hidden path, .path
       hidden return_to, .return_to
       button .variant, .content
     ```

2. **Verification Pipeline Commands and Outputs**:
   - Running `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done`:
     - `check_grammar.rb`: "664 sentences checked, 81 words defined, 0 problems" (Exit code 0).
     - `check_shape.rb`: "words: 67 ... sentences: 439 · mean 1.28 args · longest 6 ... 0 problems" (Exit code 0). Note: longest sentence of 6 is `expects` in `action.sp` and `section.sp`; longest UI template sentence is 5 args, exclusively the three `action` calls in `queue.sp`.
     - `check_styles.rb`: "25 classes the code can emit, 61 seen rendering, 95 rules, 0 problems" (Exit code 0).
     - `bin/verify_pages.rb`: Evaluates 10 pages (`PAGES` array). Outputs "10 pages verified, 0 problems" (Exit code 0). Does not perform HTML snapshot matching. When checking `triage.sp`, it supplies `first_item: nil`, so the lines calling `action` are bypassed at runtime.
     - `test/*_test.rb`: 21 test files pass cleanly. 1 test failure occurs in `test/studio_docs_test.rb:68`:
       ```
       StudioDocsTest#test_every_guide_exists_at_the_root [test/studio_docs_test.rb:68]:
       guide design_conventions has no document
       ```
       Git history reveals commit `0b054a4` ("refactor: remove duplicated document design_conventions.md") removed `design_conventions.md`, leaving `studio/docs_helper.rb:18` with an orphaned reference in `StudioDocs::GUIDES`.

3. **HTML Assertions Pinning `action`**:
   - `test/dashboard_test.rb:44-54` pins:
     ```ruby
     assert_includes html, '<form class="form" action="/actions/commit" method="post">'
     assert_includes html, '<form class="form dormant" action="/actions/status" method="post">'
     assert_includes html, '<form class="form" action="/actions/archive" method="post">'
     assert_includes html, '<form class="form" action="/actions/skip" method="post">'
     assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
     assert_includes html, '<input type="hidden" name="return_to" value="/triage">'
     assert_includes html, '<input type="hidden" name="status" value="dormant">'
     ```
   - `test/vocabulary_partials_test.rb:25-36` pins `action "Commit", to: "/actions/commit", path: .name, return_to: "/triage", variant: primary`.

---

### 2. Logic Chain

1. From Observation 1, `action` is used in only 3 lines in `queue.sp`. It takes 5 arguments because it is attempting to do routing (`to:`), payload binding (`path:`), navigation flow (`return_to:`), view text (`"Commit"`), and styling (`variant:`) all in a single sentence.
2. From Observation 1 (`dormant.sp`), `action`'s rigid 5-parameter contract failed to accommodate an extra field (`status`), forcing the author to invent an ad-hoc partial `dormant.sp` rather than reusing `action`. This proves `action` is a leaky, over-specialized abstraction.
3. From Observation 2, `bin/verify_pages.rb` gates page evaluation rather than exact HTML markup. Consequently, changing the HTML structure of `action` under "flexible parity" will not break `bin/verify_pages.rb`, provided the template evaluates without error.
4. From Observation 2 and 3, the exact HTML structure is pinned by `test/dashboard_test.rb` and `test/vocabulary_partials_test.rb`. Any intentional change under flexible parity requires updating these two test files to reflect the council's approved markup.
5. From Observation 2, the baseline test suite has one pre-existing failure in `test/studio_docs_test.rb:68` due to commit `0b054a4`. Reporting this verbatim respects the Ode to Joy principle of honest accounting.

---

### 3. Caveats

1. **Unexercised in `verify_pages.rb`**: In `bin/verify_pages.rb`, `triage.sp` is evaluated with `first_item: nil`. The `action` sentences in `queue.sp` are statically checked by `check_grammar.rb`, but only dynamically evaluated in `test/dashboard_test.rb`.
2. **Backend Coupling**: While HTML structure is flexible, the backend endpoints in `examples/dashboard/app.rb` (`/actions/commit`, `/actions/status`, `/actions/archive`, `/actions/skip`) depend on `params['path']`, `params['return_to']`, and `params['status']`. Semantic fidelity must be maintained.
3. **No Project Source Modification**: In accordance with the Explorer role, no project code or test files were altered.

---

### 4. Conclusion

The 5-argument `action` primitive is confined to `lib/vocabulary/action.sp` and invoked in only three lines in `examples/dashboard/views/partials/queue.sp`. It is the longest sentence in the entire DSL because it bundles form submission, hidden parameters, styling, and text into one flat sentence. It is structurally defective, as evidenced by `dormant.sp` having to bypass it.

The verification pipeline consists of three zero-problem static checkers (`check_grammar.rb`, `check_shape.rb`, `check_styles.rb`), a runtime evaluation verifier (`bin/verify_pages.rb`), and 22 minitest files. Changing `action`'s syntax and HTML structure under flexible parity will not disrupt `bin/verify_pages.rb`, but will require coordinating updates in `test/dashboard_test.rb` and `test/vocabulary_partials_test.rb`. One pre-existing failure in `test/studio_docs_test.rb:68` was documented.

---

### 5. Verification Method

To independently verify these findings, run:

1. **Verify call sites**:
   ```bash
   rg -n '^\s*action\b' examples/ pages/ lib/
   ```
   Confirms lines 12, 14, 15 of `examples/dashboard/views/partials/queue.sp` are the only call sites in templates.

2. **Verify verification pipeline and pre-existing failure**:
   ```bash
   ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb
   ruby test/studio_docs_test.rb
   ```
   Confirms checkers and `verify_pages.rb` exit with 0 problems, and `studio_docs_test.rb` fails on line 68 due to `design_conventions`.

3. **Verify tests asserting on `action`**:
   ```bash
   ruby test/dashboard_test.rb
   ruby test/vocabulary_partials_test.rb
   ```
   Confirms both pass against the current baseline.
