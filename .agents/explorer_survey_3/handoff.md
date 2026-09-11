# Handoff Report — Explorer 3 (DSL Philosophy Explorer)

## 1. Observation

- **The `action` Call Sites in `queue.sp`**:
  `/home/dan/dev/alt-slim-pickins/examples/dashboard/views/partials/queue.sp`:
  - Line 12: `action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary`
  - Line 14: `action "Archive", to: "/actions/archive", path: first_item.path, return_to: "/triage", variant: neutral`
  - Line 15: `action "Skip 30d", to: "/actions/skip", path: first_item.path, return_to: "/triage", variant: neutral`
- **The Definition in `lib/vocabulary/action.sp`**:
  `/home/dan/dev/alt-slim-pickins/lib/vocabulary/action.sp`:
  - Line 1: `expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true`
  - Lines 4–7:
    ```sp
    form method: post, to: .to
      hidden path, .path
      hidden return_to, .return_to
      button .variant, .content
    ```
- **Language Sentence Vitals**:
  Ran `ruby check_shape.rb`:
  ```
  sentences: 439 · mean 1.28 args · longest 6 · deepest nesting 7
  ```
  Aside from the `expects` declaration in `action.sp` (which has 6 parameters), `action` is the single longest sentence across the entire corpus at 5 arguments.
- **Historical Evidence from `ROADMAP-0.2.md` & `LORE.md`**:
  - `ROADMAP-0.2.md` line 382:
    `"action at five arguments is the strongest candidate in the language for a word doing more than one job"`
  - `LORE.md` line 266:
    `"and a partial cannot ask whether a modifier was said (optionality has no spelling), so the first vocabulary partials take every parameter unconditionally — a gap to watch when action needs a size."`
  - `ROADMAP-0.2.md` line 983:
    `"flash, action and search stay partials — measured, all three are used by exactly one app (the port)..."`
- **Baseline Verification Run**:
  Command: `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done`
  - `check_grammar.rb`: 664 sentences checked, 81 words defined, 0 problems.
  - `check_shape.rb`: 0 problems.
  - `check_styles.rb`: 0 problems.
  - `bin/verify_pages.rb`: 10 pages verified, 0 problems.
  - Pre-existing unit test failures:
    1. `test/phase4_test.rb:17` (`Phase4Test#test_every_documented_word_is_implemented`: Expected `[:footer, :section, :list, :item, :card, :actions, :aside, :disclosure, :title, :text, :note, :badge, :money, :percent, :number, :time, :figure, :empty, :action, :flash, :search, :thumbnails, :thumb, :scroll]` to be empty; these words became vocabulary partials).
    2. `test/studio_docs_test.rb:68` (`test_every_guide_exists_at_the_root`: `guide design_conventions has no document`).

---

## 2. Logic Chain

1. **Premise**: In `alt-slim-pickins` (`PRIMER.md`, `DESIGN.md`), sentences follow `word arguments`, averaging 1.28 arguments per sentence. A foundational rule is: *"A line that states the inferable should not exist."*
2. **Observation**: `action` takes 5 arguments (`content`, `to:`, `path:`, `return_to:`, `variant:`). In `queue.sp`, `path: first_item.path` and `return_to: "/triage"` are repeated verbatim on lines 12, 14, and 15.
3. **Inference**: In `queue.sp`, lines 4–15 are already nested inside `card first_item.path` on the `/triage` page. Stating `path: first_item.path` and `return_to: "/triage"` three times violates the rule against stating the inferable and the DRY principle in `ODE_TO_JOY.md` Part III (*"Give every truth one home"*).
4. **Observation**: `lib/vocabulary/action.sp` is in the core vocabulary, yet it has hardcoded hidden inputs for `path` and `return_to`.
5. **Inference**: `action.sp` is not a generic UI primitive; it is an ad-hoc dashboard port partial that was promoted to `lib/vocabulary` in Phase 4 without generalizing its parameters or extracting its missing abstraction.
6. **Synthesis**: The 8 Ruby luminaries (Matz, Sandi Metz, _why, DHH, Jim Weirich, Avdi Grimm, Katrina Owen, Sarah Mei) unanimously diagnose this 5-argument sentence as a failure of abstraction and composability. The two strongest refactoring directions are:
   - **Option 1 (Scoped Container)**: Let `actions` enclose child `action` buttons and supply the shared `path:` and `return_to:` scope (favored by Jim Weirich, Sandi Metz, Katrina Owen, Sarah Mei).
   - **Option 2 (Subject & Context Inference)**: Let `card` shift the subject to `first_item`, allowing `action` to infer `.path` from the current subject and `return_to` from page context (favored by DHH, Avdi Grimm, Matz).

---

## 3. Caveats

1. **Read-Only Scope**: In accordance with the explorer role, no implementation code in `lib/` or `examples/` was modified.
2. **Flexible Parity**: As stated in `ORIGINAL_REQUEST.md`, the team has flexibility to alter the emitted HTML slightly if it leads to a significantly cleaner DSL, provided visual and semantic function remain intact. If Option 1 or Option 2 is chosen, any slight adjustment to form wrapping or attributes should be verified with `test/dashboard_test.rb`.
3. **Pre-Existing Test Failures**: Two unit tests (`test/phase4_test.rb` and `test/studio_docs_test.rb`) were already failing before this investigation began and must be reported honestly.

---

## 4. Conclusion

The 5-argument `action` primitive is an architectural defect resulting from leaking application-specific parameters (`path`, `return_to`) into a core vocabulary partial. It violates single responsibility, language conciseness, and the inference principle.

The 8 Ruby luminaries council analysis is fully articulated in `/home/dan/dev/alt-slim-pickins/.agents/explorer_survey_3/report.md`. The council's emerging consensus points toward **scoping the common parameters via `actions`** (Option 1) or **inferring them from the subject chain** (Option 2), reducing `action` from 5 arguments down to 2 (`action "Archive", to: "/actions/archive"`).

---

## 5. Verification Method

To independently verify the observations, vitals, and findings:
1. **Check sentence vitals**:
   ```bash
   ruby check_shape.rb
   ```
   Verify that sentence argument mean is 1.28 and max is 5 (for `action`).
2. **Inspect `action.sp` contract**:
   ```bash
   cat lib/vocabulary/action.sp
   ```
   Verify line 1 declares `to: true, path: true, return_to: true, variant: true`.
3. **Inspect call sites**:
   ```bash
   grep -n "action " examples/dashboard/views/partials/queue.sp
   ```
   Verify 5 arguments on lines 12, 14, 15.
4. **Run full baseline test suite**:
   ```bash
   ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done
   ```
   Verify checkers pass and observe the two pre-existing test failures named above.
5. **Read full report**:
   View `/home/dan/dev/alt-slim-pickins/.agents/explorer_survey_3/report.md`.
