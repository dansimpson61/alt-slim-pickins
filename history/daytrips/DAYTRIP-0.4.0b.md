# DAYTRIP-0.4.0b — Expressive View Composition

**Opened 2026-09-22, on dan's word.** A jaunt off the path, giving orthogonal volume
to the roadmap's linear vector.

> *"The itinerary is just a vector; the daytrips give it volume."*

This daytrip opens and executes Volet 2 of the Roadmap 0.4 progression. With Volet 1
having established the truthful floor (live Census SSOT, F9 settled, and enriched dynamic
conventions), Volet 2 turns to expressive view composition, fulfilling the three
council proposals (R3P1–3) demand-gated from Roadmap 0.3.

---

## The brief

**Observations, guidance, and authoring pain points (2026-09-22):**

1. **Orthogonal Volume**: Daytrips give orthogonal depth to the roadmap's vector. We execute
   one volet at a time with clarity and honesty.
2. **Authoring Pain Points Noted**:
   - *Pain Point 1 (Taxonomy)*: A long, unordered vocabulary list fails to guide top-down
     deductive articulation. Primitives belong in a 5-tier taxonomy: Structural,
     Semantic, Interactive, Behavioral, and Visual. **Assigned to Volet 4 (Studio shelf) and PRIMER.**
   - *Pain Point 2 (Studio Partial Minting & Bite-Sized Domain Words)*: The Studio currently
     lacks a mechanism for creating `.sp` partials, forcing long, unDRY views even outside the
     studio. Authors desire OOP bite-sized, locally scoped domain words. **Reserved for dedicated
     discussion and design as Volet 4b.**
3. **Purity in Partials**: Eradicate machine-language leaks in view templates (redundant forms,
   repeated wire parameter marshalling, rigid compiler lockups on modifiers).
4. **Demand-Gated Victories**: Execute the three winnable composition victories:
   - **R3P2**: Subject-shifting `card` (eliminating repeated dotted subject paths in card blocks).
   - **R3P3**: Single-form `formaction` button groups in `actions` (eliminating 4 separate forms
     and repeated hidden inputs).
   - **R3P1**: Partial payload forwarding (allowing open modifier options through declared partials).

---

## The question

> **How do we eliminate authoring boilerplate and machine-language clutter from view
> composition — enabling `card` to shift subject context naturally (R3P2), `actions` to
> unify multi-action toolbars into a single form with HTML5 `formaction` buttons (R3P3), and
> partials to forward open option payloads (R3P1) — all within the strict discipline of the
> single-sentence grammar?**

---

## Baggage Discarded vs. Living Purpose

| Mechanism | Inherited Clutter | Living Purpose |
|---|---|---|
| `card` subject binding | Repeating `first_item.` 7 times across 12 lines in `queue.sp` because `card` only took variants. | `card first_item` shifts the subject context like `section`, allowing `.path`, `.status`, `.purpose` inside. |
| Action toolbars | Emitting 4 separate `<form>` tags and duplicating hidden inputs (`path`, `return_to`) for every button. | One `<form method="post">` with HTML5 `<button formaction="...">` and `name`/`value` payload attributes. |
| Partial modifiers | Strict compiler refusal for any modifier not explicitly hardcoded in line-1 `expects`. | Declared `open: true` or open forwarding permitting wrapper partials to accept and forward options. |

---

## The Stops

### Stop 1 — Subject-Shifting `card` (R3P2)
1. In `lib/vocabulary/card.sp`, update contract declaration:
   `expects subject, takes: content, children: any, takes: id, takes: variant, subject: shift, shape: encloses, infers: card_id, infers: box_tag, infers: box_depth`
2. In `lib/slim_pickins/partial_word.rb`:
   - Expand `shifts` condition to check `contract.subject == :shift || contract.name == :subject`.
   - When a name is passed, inspect `subject.has?(name)`. If true, shift the subject via `about(name)`. If false, treat the name as a visual variant (e.g. `card compact`).
   - In `parameters_for`, assign `variant: kwargs[:variant] || (subject.has?(name) ? nil : name)`.
3. In `lib/slim_pickins/builder.rb`:
   - Allow `about(name)` to accept subject objects directly as well as attribute symbols (supporting `card .first_item`).
4. Re-author `examples/dashboard/views/partials/queue.sp`:
   - Replace `card first_item.path` with `card first_item`.
   - Inside the block, replace all 7 `first_item.` references with clean dotted queries (`title .path`, `badge .status_variant, .status`, `text .purpose`, `when .next_line`, `actions path: .path`).

### Stop 2 — `formaction` Button Groups in `actions` (R3P3)
1. In `lib/slim_pickins/words.rb`:
   - Update `Button` contract to declare modifiers: `[:to, :target, :type, :size, :name, :value]`.
   - Pass `name` and `value` kwargs into the `:button` node payload.
2. In `lib/slim_pickins/generator.rb`:
   - In `def button`, emit `name:` and `value:` HTML attributes when present.
3. In `lib/vocabulary/actions.sp` and `lib/vocabulary/action.sp`:
   - In `actions.sp`, wrap children in a single `<form method="post">` containing the shared hidden fields when `path:` is supplied.
   - In `action.sp`, replace the nested `<form>` with a single `button .variant, .content, to: .to` passing `name: "status", value: .status` when present.
4. Update `test/dashboard_test.rb` and verifying test suites to validate the clean single-form toolbar with `formaction` buttons.

### Stop 3 — Partial Payload Forwarding (R3P1)
1. In `lib/slim_pickins/contracts.rb`:
   - Add `:open` to `Contract` struct and `VocabularyShapes::FLAGS`.
   - Update `Contracts.call_complaint` to skip unknown modifier complaints if `contract.open`.
2. In `lib/slim_pickins/partial_word.rb`:
   - In `parameters_for`, when `contract.open` is true, preserve and merge all kwargs into the partial's parameters.
3. Add unit and integration tests in `test/vocabulary_partials_test.rb` to verify payload forwarding into declared partials.

### Stop 4 — Verification, Regeneration & Living Census
1. Run `ruby bin/generate_vocabulary.rb` to update `VOCABULARY.md` bullets for `card` and `actions`.
2. Run all gate scripts: `check_grammar`, `check_shape`, `check_styles`, `check_promises`, `check_conventions`, `check_card`, `verify_pages`.
3. Verify all 31 pages pass with 0 problems.
4. Run full test suite across all engines and isolated app runners.
5. Re-run `ruby bin/census.rb` to update repository vitals.

---

## Verification & Done Looks Like

- All 31 verified pages render cleanly without regressions.
- `queue.sp` uses `card first_item` with 0 redundant dotted prefixes.
- Action toolbars emit 1 form instead of 4 forms, using HTML5 `formaction`.
- Partials with open payloads accept arbitrary kwargs without compiler refusal.
- All gates pass, full test suite is green with 0 failures.

---

## Outcome

- **R3P2 (Subject-shifting `card`) Delivered**: `card` shifts subject context like `section` when given an object or symbol identifying a subject. In `examples/dashboard/views/partials/queue.sp`, 7 repeated dotted subject bindings were eliminated.
- **R3P3 (Single-Form `formaction` Button Groups) Delivered**: `actions.sp` encapsulates actions in a single `<form method="post">` holding common hidden payload inputs. `action.sp` renders clean HTML5 buttons with `formaction` and `name`/`value` attributes. 4 forms collapsed into 1 in `queue.sp` and triage views.
- **R3P1 (Partial Payload Forwarding) Delivered**: Declaring `open: true` or `takes: payload` in partial preambles allows undeclared kwargs to pass through cleanly to internal slot bindings without compiler refusal.
- **All Gates Green**:
  - `check_grammar.rb`: 1226 sentences, 94 words, 0 problems.
  - `check_shape.rb`: 978 sentences, 64 canonical words, 0 problems.
  - `check_styles.rb`: 105 rules, 0 problems.
  - `bin/check_promises.rb`: 35 promises, 0 problems.
  - `bin/check_conventions.rb`: 38 conventions, 0 problems.
  - `bin/check_card.rb`: 7 fields, last_touched 2026-09-22, 0 problems.
  - `bin/verify_pages.rb`: 31/31 pages pass, 0 problems.
- **Test Suite**: 373 runs, 4175 assertions, 0 failures, 0 errors, 0 skips.
- **Vitals (Census)**: 64 canonical words (42 Ruby + 22 .sp), 7 apps, 26 app words, 31 verified pages, 38 conventions, 35 promises, 105 styles, 41 test files.
