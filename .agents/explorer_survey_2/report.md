# Call Site & Verification Pipeline Investigation Report

**Explorer**: Explorer 2 (Call Site Verification Explorer)  
**Date**: 2026-09-10  
**Project**: `alt-slim-pickins` (`/home/dan/dev/alt-slim-pickins`)  
**Scope**: Call sites of `action`, `bin/verify_pages.rb`, `check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, and `test/*_test.rb`.

---

## Executive Summary

1. **Call Sites of `action`**:
   - `examples/dashboard/views/triage.sp` does **not** call `action` directly; on line 9 it invokes the `queue` partial (`examples/dashboard/views/partials/queue.sp`).
   - In `queue.sp`, `action` is called exactly **three times** (lines 12, 14, 15).
   - Across the **entire repository** (all `.sp` files in `pages/`, `examples/`, `studio/`), these three lines in `queue.sp` are the **only** call sites of `action`.
   - In `lib/vocabulary/action.sp`, `action` is defined as a vocabulary partial taking 5 parameters: `content` (positional), `to:`, `path:`, `return_to:`, and `variant:`.
   - Because `action` hardcodes `path` and `return_to` and cannot accept arbitrary hidden fields, the companion button in `queue.sp` ("Set dormant") had to be written as a separate ad-hoc partial (`examples/dashboard/views/partials/dormant.sp`) to inject `status="dormant"`.

2. **The Verification Pipeline**:
   - `bin/verify_pages.rb`: Evaluates 10 pages across the core repo and demo apps against realistic data fixtures. It verifies that evaluation completes **without raising runtime language errors or Ruby exceptions**. It does **not** do HTML snapshot or gold-master comparison. When verifying `triage.sp`, it passes `first_item: nil`, meaning the lines calling `action` are not executed during `verify_pages.rb`.
   - `check_grammar.rb`: Statically parses all fenced markdown blocks and all `.sp` files. It enforces AST grammar and word contracts (`SlimPickins::Contracts.complaints`), checks that all words are defined in `VOCABULARY.md` or app partials/words, ensures words have example sentences, and verifies generated documentation bullets. Currently passes with **0 problems**.
   - `check_shape.rb`: Enforces that every vocabulary word declares a contract and a shape. Computes language vitals across all `.sp` files. It explicitly reports sentence length: the longest non-declaration sentence in the entire language is **5 arguments**, and **all three instances are `action` in `queue.sp`**. Currently passes with **0 problems**.
   - `check_styles.rb`: Enforces CSS hygiene in `assets/slim-pickins.css`. Ensures no unthemed literal values outside `:root`, all emittable classes have CSS rules, class names follow the four canonical shapes, and no orphaned rules exist. Currently passes with **0 problems**.
   - `test/*_test.rb`: Consists of 22 test files.
     - 21 test files pass cleanly.
     - **Pre-existing failure**: `StudioDocsTest#test_every_guide_exists_at_the_root` (`test/studio_docs_test.rb:68`) fails with `guide design_conventions has no document`. Git log confirms that commit `0b054a4` ("refactor: remove duplicated document design_conventions.md") deleted `design_conventions.md`, but `studio/docs_helper.rb:18` still lists `design_conventions` in `GUIDES`.

3. **Flexible Parity**:
   - "Flexible parity" gives the council freedom to adjust the rendered HTML structure (e.g., how the form, button, and hidden inputs are grouped or styled) as long as visual presentation and semantic functionality (form action URLs, HTTP POST method, and required payload fields `path`, `return_to`, `status`) remain intact.
   - The test assertions pinning exact HTML strings for `action` reside in `test/dashboard_test.rb` (lines 44–54) and `test/vocabulary_partials_test.rb` (lines 25–36). If HTML structure is updated with council consensus, these test assertions can be updated to match.

---

## 1. Call Sites of `action`

### 1.1 `examples/dashboard/views/triage.sp`
`triage.sp` contains:
```slim_pickins
page "Triage"
  text "One project at a time, hardest first."
  choose
    when .notice
      flash .notice
  choose
    when .unreviewed
      unreviewed_card
  queue
```
Line 9 calls `queue`. `triage.sp` has no direct calls to `action`.

### 1.2 `examples/dashboard/views/partials/queue.sp`
`queue.sp` contains the only call sites of `action` in the entire repository:
```slim_pickins
choose
  when .first_item
    text .queue_intro
    card first_item.path
      badge first_item.status_variant, first_item.status
      text first_item.purpose
      choose
        when first_item.next_line
          text first_item.next_line
      choose
        when first_item.offer_commit
          action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
      dormant "Set dormant", path: first_item.path
      action "Archive", to: "/actions/archive", path: first_item.path, return_to: "/triage", variant: neutral
      action "Skip 30d", to: "/actions/skip", path: first_item.path, return_to: "/triage", variant: neutral
  otherwise
    text "All caught up. Nothing needs attention."
```

#### Detailed Breakdown of Call Sites
1. **Line 12**:
   ```slim_pickins
   action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
   ```
   - Invoked conditionally when `first_item.offer_commit` is true.
   - Content: `"Commit"` (string literal, button text).
   - `to:` `"/actions/commit"` (URL endpoint).
   - `path:` `first_item.path` (data payload, e.g. `"ode-to-joy"`).
   - `return_to:` `"/triage"` (redirect target).
   - `variant:` `primary` (button style variant token `button--primary`).

2. **Line 14**:
   ```slim_pickins
   action "Archive", to: "/actions/archive", path: first_item.path, return_to: "/triage", variant: neutral
   ```
   - Always rendered if `first_item` is present.
   - Content: `"Archive"`.
   - `to:` `"/actions/archive"`.
   - `path:` `first_item.path`.
   - `return_to:` `"/triage"`.
   - `variant:` `neutral` (button style variant token `button--neutral` or standard button).

3. **Line 15**:
   ```slim_pickins
   action "Skip 30d", to: "/actions/skip", path: first_item.path, return_to: "/triage", variant: neutral
   ```
   - Always rendered if `first_item` is present.
   - Content: `"Skip 30d"`.
   - `to:` `"/actions/skip"`.
   - `path:` `first_item.path`.
   - `return_to:` `"/triage"`.
   - `variant:` `neutral`.

### 1.3 The Companion Hack: `dormant.sp`
On line 13 of `queue.sp`:
```slim_pickins
dormant "Set dormant", path: first_item.path
```
Inspect `examples/dashboard/views/partials/dormant.sp`:
```slim_pickins
form method: post, to: "/actions/status"
  hidden path, .path
  hidden return_to, "/triage"
  hidden status, "dormant"
  button neutral, .content
```
**Why does `dormant.sp` exist?**
Because `action` in `lib/vocabulary/action.sp` is hardcoded:
```slim_pickins
expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true

form method: post, to: .to
  hidden path, .path
  hidden return_to, .return_to
  button .variant, .content
```
`action` only knows about `path` and `return_to`. It cannot accept an extra `status` hidden field!
Because the DSL provided no way to pass additional hidden inputs or compose a form body, the dashboard author was forced to break away from `action` and hand-author `dormant.sp` using low-level primitives (`form`, `hidden`, `button`).

### 1.4 Other Uses of `action` / `actions`
- **Singular `action`**: No other template in the repository calls `action`.
- **Plural `actions`**: Defined in `lib/vocabulary/actions.sp`:
  ```slim_pickins
  expects children: "link button", shape: encloses

  box
    children
  ```
  Used in:
  - `examples/portfolio/views/index.sp:12`
  - `examples/roth/views/controls.sp:24`
  `actions` is a box container designed to hold `link` or `button` children. Notably, the four triage buttons in `queue.sp` are **not** enclosed in `actions`!

---

## 2. Investigation of `bin/verify_pages.rb`

### 2.1 How it Works
`bin/verify_pages.rb` evaluates 10 pages to ensure they evaluate without error:
```ruby
PAGES = [
  *%w[portfolio_table account_detail roth_form specimen].map do |name|
    ["pages/#{name}.sp", repo, Fixtures.for(name)]
  end,
  ['examples/portfolio/views/index.sp', portfolio, { portfolio: Fixtures.portfolio }],
  ['examples/portfolio/views/account.sp', portfolio, { account: Fixtures.portfolio.accounts.last }],
  ['examples/roth/views/controls.sp', roth, { scenario: scenario, projection: projection }],
  ['examples/roth/views/partials/report.sp', roth, { scenario: scenario, projection: projection }],
  ['examples/dashboard/views/triage.sp', dashboard,
   dashboard_base.merge(first_item: nil, queue_intro: '', unreviewed: nil)],
  ['examples/dashboard/views/confirm_archive.sp', dashboard,
   dashboard_base.merge(archive_heading: 'Archive "example"?', archive_path: 'example',
                        archive_return_to: '/triage', reason: '')]
].freeze
```
For each page, it calls:
```ruby
SlimPickins.render(File.read(File.expand_path("../#{label}", __dir__)),
                   path: label, locals: locals, library: library)
```
If an exception occurs:
- `SlimPickins::Error`: outputs `BAD ANSWER #{label}` + message
- `StandardError`: outputs `RUBY ERROR #{label}` + message
If no exception occurs:
- outputs `OK #{label}`

### 2.2 What it Verifies
- **Static resolution & runtime evaluation**: Verifies that every subject dot-lookup (`.foo`) resolves against the provided locals/fixtures, and that contracts are not violated at runtime.
- **No snapshot testing**: It does **not** compare the generated HTML against an expected string, golden file, or snapshot. As long as `render` returns an HTML string without error, the page passes.
- **Coverage of `action`**: In `verify_pages.rb`, `triage.sp` is rendered with `first_item: nil`. In `queue.sp`, when `first_item` is nil, it renders:
  ```slim_pickins
  otherwise
    text "All caught up. Nothing needs attention."
  ```
  Therefore, **`action` is not evaluated during `verify_pages.rb`**. However, `queue.sp` and `triage.sp` are still parsed and checked statically by `check_grammar.rb`.

---

## 3. Investigation of `check_grammar.rb`, `check_shape.rb`, and `check_styles.rb`

### 3.1 `check_grammar.rb`
- **Scope**: Parses every markdown document in `DOCS` (`DESIGN.md`, `VOCABULARY.md`, `README.md`, `PRIMER.md`, `ROADMAP-0.2.md`, `history/*.md`) and every `.sp` file in `pages/`, `examples/`, `lib/vocabulary/`, `studio/`.
- **Parsing**: Compiles blocks via `SlimPickins::Transform.tree(source, path: where)`. Reports `BAD SENTENCE` if syntax fails.
- **Contracts**: Runs `SlimPickins::Contracts.complaints(node, ancestry)`. Ensures:
  - Positional arguments match word's declared name/content slot.
  - Modifiers match word's declared modifiers.
  - Parent/child relationships match `parents:` and `children:`.
  - Reports `BAD CONTRACT` on violations.
- **Vocabulary completeness**:
  - `UNDEFINED`: Flags words used in templates that are neither in `VOCABULARY.md` nor in `app_words` (`lib/vocabulary/*.sp`, app partials, or `*Words` modules).
  - `UNEXEMPLIFIED`: Flags words defined in `VOCABULARY.md` that have no example sentence in documentation.
  - `UNGENERATED`: Compares documentation bullets in `VOCABULARY.md` against programmatic contracts generated by `SlimPickins::Contracts.bullets`.
- **Current Baseline**: 664 sentences checked, 81 words defined, **0 problems**.

### 3.2 `check_shape.rb`
- **Scope**:
  1. Inspects every word registered in `SlimPickins::Word.registry`.
  2. Ensures each word has a contract (`NO CONTRACT`) and a declared shape (`NO SHAPE`).
  3. Audits parts of speech: nouns vs non-nouns.
  4. Parses all `.sp` files and gathers empirical vitals:
     - Sentence count
     - Mean argument count
     - Longest sentence (`max_args`)
     - Deepest nesting
     - Modifier distribution
- **Vitals Output**:
  ```
  vitals
    words: 67 — 62 nouns, 5 non-nouns (adjective, adverb, conjunction, determiner, verb)
    shapes: document 5 · encloses 20 · gathers 5 · iterates 1 · presents 19 · registers 8 · says 9
    sentences: 439 · mean 1.28 args · longest 6 · deepest nesting 7
    distinct modifiers: 28 — active children columns content empty from gathers id inside label method open over parents path placeholder precision q required return_to rows shape speech subject target to type variant
    words used in real pages: 65 of 67 (plus 15 app words: account_card, dormant, editor, editor_form, expects, html_preview, preview, queue, report, sidebar_layout, split_pane, test_account_card, unreviewed_card, video, vocabulary)
    0 problems
  ```
- **Crucial Finding**:
  - The printed `longest 6` corresponds to the declaration line `expects ...` in `lib/vocabulary/action.sp:1` and `section.sp:1`.
  - Among actual UI sentences, the maximum argument count is **5**, and **all three instances are `action` in `queue.sp`**.
  - `check_shape.rb` only fails if a word has no contract or no shape. Vitals changes do not fail the script, but are logged as metrics.

### 3.3 `check_styles.rb`
- **Scope**: Verifies `assets/slim-pickins.css` against the runtime:
  1. `UNTHEMED`: Flags hardcoded values (units like px, rem, ch) outside `:root` unless structural (`0, 1, 2, 3, 100%`).
  2. `UNSTYLED`: Flags classes that Ruby or templates can emit (`token(:word, ...)`, `CONTRACTS`, etc.) that have no CSS rule.
  3. `SHAPE`: Ensures all emitted and defined classes follow the 4 shapes:
     - `.word`
     - `.word--variant`
     - `.word-part`
     - `.word-part--n`
  4. `ORPHAN`: Flags CSS selectors that do not correspond to any registered word or app partial.
- **Current Baseline**: 25 classes code can emit, 61 seen rendering, 95 rules, **0 problems**.

---

## 4. Test Suite Structure & Baseline Status

### 4.1 Running the Verification Command
We executed:
```bash
ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done
```

### 4.2 Test Suite Breakdown
| Test File | Runs | Assertions | Failures | Status | Notes |
|---|---|---|---|---|---|
| `test/boot_test.rb` | 3 | 12 | 0 | PASS | App boot & routing |
| `test/checker_golden_test.rb` | 2 | 30 | 0 | PASS | Golden grammar refusals & sentences |
| `test/combination_test.rb` | 12 | 41 | 0 | PASS | Word combinations |
| `test/compilation_test.rb` | 5 | 15 | 0 | PASS | Compilation AST |
| `test/contract_test.rb` | 15 | 20 | 0 | PASS | Contract satisfaction |
| `test/contracts_test.rb` | 11 | 21 | 0 | PASS | Structural contracts |
| `test/dashboard_test.rb` | 11 | 73 | 0 | PASS | **Directly tests dashboard actions & HTML** |
| `test/gate_test.rb` | 7 | 18 | 0 | PASS | Contract gate |
| `test/lineno_test.rb` | 6 | 18 | 0 | PASS | Error line reporting |
| `test/markdown_test.rb` | 22 | 30 | 0 | PASS | Markdown parsing |
| `test/partial_args_test.rb` | 9 | 36 | 0 | PASS | Partial argument handling |
| `test/phase0_test.rb` | 10 | 40 | 0 | PASS | Phase 0 regression |
| `test/phase2_test.rb` | 22 | 76 | 0 | PASS | Phase 2 regression |
| `test/phase3_test.rb` | 12 | 42 | 0 | PASS | Phase 3 regression |
| `test/phase4_test.rb` | 13 | 53 | 0 | PASS | Phase 4 regression |
| `test/phase6_test.rb` | 14 | 65 | 0 | PASS | Phase 6 subtraction |
| `test/phase7_test.rb` | 30 | 173 | 0 | PASS | Phase 7 regression |
| `test/phase8_test.rb` | 23 | 89 | 0 | PASS | Phase 8 regression |
| `test/prettify_test.rb` | 11 | 11 | 0 | PASS | HTML prettifier |
| `test/studio_docs_test.rb` | 6 | 494 | **1** | **FAIL** | **Pre-existing failure** (see below) |
| `test/ui_words_test.rb` | 8 | 29 | 0 | PASS | UI words (`form`, `button`, etc.) |
| `test/vocabulary_partials_test.rb` | 8 | 43 | 0 | PASS | **Directly tests `action` partial** |

### 4.3 The Pre-Existing Failure in `test/studio_docs_test.rb`
`StudioDocsTest#test_every_guide_exists_at_the_root` fails:
```
  1) Failure:
StudioDocsTest#test_every_guide_exists_at_the_root [test/studio_docs_test.rb:68]:
guide design_conventions has no document
```
- **Root Cause**: At 15:57:23 on 2026-09-10, commit `0b054a4679f4cce76559c68c83fd35427b3361f8` removed `design_conventions.md` from the repo root ("refactor: remove duplicated document design_conventions.md").
- However, `studio/docs_helper.rb` line 18 still lists `design_conventions` in `StudioDocs::GUIDES`:
  ```ruby
  GUIDES = %w[README PRIMER VOCABULARY CONTRACT DESIGN KERNEL LORE
              ROADMAP-0.2 HANDOFF DAYTRIP design_conventions].freeze
  ```
- Line 68 of `test/studio_docs_test.rb` asserts that every guide in `GUIDES` exists as `<name>.md`.
- **Honest reporting**: As governed by Ode to Joy rules ("Report a suite that was already red; never silently fix or ignore it"), this failure was present prior to our investigation and is documented verbatim.

### 4.4 Tests Pinning `action`
1. **`test/dashboard_test.rb` (lines 44–54)**:
   ```ruby
   def test_the_four_actions_post_the_original_payloads
     html = render_triage(first_item: item, queue_intro: '1 item(s) need attention — this is the first:')
     assert_includes html, '<form class="form" action="/actions/commit" method="post">'
     assert_includes html, '<form class="form dormant" action="/actions/status" method="post">'
     assert_includes html, '<form class="form" action="/actions/archive" method="post">'
     assert_includes html, '<form class="form" action="/actions/skip" method="post">'
     assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
     assert_includes html, '<input type="hidden" name="return_to" value="/triage">'
     assert_includes html, '<input type="hidden" name="status" value="dormant">'
     ['Commit', 'Set dormant', 'Archive', 'Skip 30d'].each { |l| assert_includes html, l }
   end
   ```
2. **`test/dashboard_test.rb` (lines 56–61)**:
   ```ruby
   def test_commit_is_offered_only_when_the_app_offers_it
     quiet = render_triage(first_item: item(offer_commit: false), queue_intro: '')
     refute_includes quiet, 'action="/actions/commit"'
     assert_includes render_triage(first_item: item(offer_commit: true), queue_intro: ''),
                     'action="/actions/commit"'
   end
   ```
3. **`test/vocabulary_partials_test.rb` (lines 25–36)**:
   ```ruby
   def test_action_is_the_minimal_post_form
     Dir.mktmpdir do |dir|
       File.write(File.join(dir, 'one.sp'),
                  %(page p\n  action "Commit", to: "/actions/commit", path: .name, return_to: "/triage", variant: primary\n))
       html = SlimPickins.render(File.read(File.join(dir, 'one.sp')), path: 'one.sp',
                                 locals: { p: { name: 'ode-to-joy' } }, library: library_for(dir))
       assert_includes html, '<form class="form" action="/actions/commit" method="post">'
       assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
       assert_includes html, '<input type="hidden" name="return_to" value="/triage">'
       assert_includes html, '<button type="submit" class="button button--primary">Commit</button>'
     end
   end
   ```

---

## 5. Flexible Parity & Architectural Analysis

### 5.1 What "Flexible Parity" Means
The user request explicitly states:
> "You have the flexibility to alter the resulting HTML structure slightly if it leads to a significantly cleaner DSL, provided the visual and semantic function remains intact."
> "Any intentional changes to the HTML output (flexible parity) are explicitly documented and justified by the council."

In practical terms:
- **Semantic Function**:
  - The browser must submit HTTP POST requests to `/actions/commit`, `/actions/status`, `/actions/archive`, and `/actions/skip`.
  - The POST payload must include `path` and `return_to` (and `status=dormant` for status change), matching what `examples/dashboard/app.rb` expects in `params['path']`, `params['return_to']`, and `params['status']`.
- **Visual Function**:
  - Buttons must be rendered with their respective text labels ("Commit", "Set dormant", "Archive", "Skip 30d") and variant styles (`primary`, `neutral`).
- **HTML Structure Flexibility**:
  - Currently, each action renders as an independent `<form class="form" action="..." method="post">` wrapping hidden inputs and a `<button type="submit">`.
  - Alternatively:
    - Multiple action buttons could be enclosed in an `actions` or `form` block.
    - Or HTML5 `<button formaction="...">` can be used (which `lib/slim_pickins/generator.rb:533` already supports: `formaction: attrs[:to]&.to_s`).
    - Or `action` can be refactored into a block-accepting primitive or a cleaner parameter abstraction.

### 5.2 Why `action` Has 5 Arguments: Root Cause Analysis
The 5 arguments in `action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary` are:
1. `"Commit"` — UI label
2. `to: "/actions/commit"` — routing / HTTP target
3. `path: first_item.path` — domain entity identifier
4. `return_to: "/triage"` — workflow redirect URL
5. `variant: primary` — visual styling

This violates Single Responsibility: `action` combines **view presentation**, **routing**, **domain payload binding**, and **workflow control** into a single sentence.
Furthermore:
- `path:` and `return_to:` are hardcoded in `lib/vocabulary/action.sp`, polluting the core vocabulary with dashboard-specific payload concerns.
- In `queue.sp`, the subject is already within `card first_item.path` or can easily be made `first_item`. The repetitiveness of `path: first_item.path` on every action call is redundant.
- `dormant.sp` had to be invented because `action` lacked flexibility for additional payload fields.

### 5.3 Candidate Solutions for the Council
1. **Decomposition via Existing Primitives**:
   Allow `action` or `form` to enclose children (`hidden`, `button`), or promote a clean action abstraction where hidden inputs are either inferred from the enclosing subject or nested as children.
2. **Subject Overlay / Context**:
   Since `PartialWord` supports `overlay: true` falling through to the current subject, if `first_item` is the current subject, `path` can be read implicitly from `.path` rather than passed explicitly on every button.
3. **Container `actions` with `button to: ...`**:
   Use HTML5 `formaction` on buttons inside a shared form enclosing `path` and `return_to`:
   ```slim_pickins
   form method: post
     hidden path, .path
     hidden return_to, "/triage"
     actions
       button primary, "Commit", to: "/actions/commit"
       button neutral, "Set dormant", to: "/actions/status", name: status, value: "dormant"
       button neutral, "Archive", to: "/actions/archive"
       button neutral, "Skip 30d", to: "/actions/skip"
   ```
   Notice that `button` in `lib/slim_pickins/words.rb:465` already declares `modifiers: [:to, :target, :type, :size]`, and `lib/slim_pickins/generator.rb:533` already emits `formaction: attrs[:to]&.to_s`!

---

## 6. Recommendations for the Council & Orchestrator

1. **Focus on `queue.sp` and `lib/vocabulary/action.sp`**: These are the only places in the DSL templates where `action` is used and defined.
2. **Unify `dormant` and `action`**: Any refactored solution should eliminate the need for the ad-hoc `dormant.sp` partial by providing a coherent pattern for actions with parameters.
3. **Update Test Assertions Transparently**: If the HTML structure is refactored under flexible parity, update `test/dashboard_test.rb` and `test/vocabulary_partials_test.rb` in lockstep, documenting the rationale.
4. **Address Pre-existing Test Failure**: Note that `test/studio_docs_test.rb` has a 1-line mismatch with `studio/docs_helper.rb` (orphaned `design_conventions` guide) from commit `0b054a4`.
