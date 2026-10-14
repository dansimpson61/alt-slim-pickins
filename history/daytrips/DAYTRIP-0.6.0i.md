# Daytrip 0.6.0i — Example App Modernization: Dynamic Loop & 0.6 Curriculum for WayExam

**Status: closed 2026-10-14.** All movements implemented and verified across all 12 gate legs, 35 pages verified OK, full test suite passing (652 runs, 7,055 assertions, 0 failures).

## Context & Motivation

During the Example App Garden Audit (`DAYTRIP-0.6.0g.md`), `examples/way_exam` was recommended for retention and modernization. It was the only example app in the repository with hardcoded template question iterations: `index.sp` duplicated each question's title and prompt manually across five hard-coded `group` blocks rather than looping over `.questions`. Furthermore, Question 5's option strings were hardcoded in the template, diverging from `Exam`'s dynamic Census measurements. Finally, the question set had not been updated since Phase 3, missing the 0.6 architectural milestones (the 7 system taxonomy terms and the universal slot model).

## Movements Completed

1. **Form Iterator Capability**:
   - Added `:each` to `Form`'s `children:` list in `lib/slim_pickins/words.rb`. Forms naturally enclose iterations of questions, line items, and control groups.
   - Regenerated `docs/VOCABULARY.md` via `bin/generate_vocabulary.rb`.

2. **Data-Driven Dynamic Loop in `examples/way_exam/views/index.sp`**:
   - Replaced 35 lines of repetitive hardcoded question blocks with a concise, idiomatic `each question` loop:
     ```sp
     form to: "/grade", method: post
       each question
         group .title
           text .prompt
           choice radio, .id
             option a, .option_a
             option b, .option_b
             option c, .option_c
       actions
         button "Submit Exam for Grading"
     ```
   - Enabled `Question#title` in `examples/way_exam/lib/exam.rb` (`"Question #{number} — #{topic}"`) and `Question#id = self[:id].to_sym`.

3. **0.6 Curriculum Expansion (7 Questions)**:
   - Expanded `WayExam::Exam::QUESTIONS` from 5 to 7 questions:
     - **Q1 (Morphology)**: A dot means data, a bare word is language.
     - **Q2 (Conditionals)**: Conditionals dissolve into vocabulary describing situations.
     - **Q3 (Subject Shifting)**: `each account` shifts subject for child lines.
     - **Q4 (Design Discipline)**: Styles belong to theme roles and word variants.
     - **Q5 (The Vocabulary)**: Dynamically measured from `SlimPickins::Census` (primitives + partials).
     - **Q6 (Taxonomy Terms)**: The 7 formal system taxonomy terms (`word`, `primitive`, `partial`, `def`, `contract`, `tin`, `spiff`).
     - **Q7 (Slots & Containment)**: Modern composition slots (`contents` and `group` replacing legacy `children`).

4. **App, Studio & Verification Alignment**:
   - Updated `app.rb` (`prove!`, `get '/'`, and `post '/grade'`) to dynamically bind and grade `Exam.questions`.
   - Updated `bin/verify_pages.rb` and `studio/pages.rb` (`data_for`) to supply the full dynamic questions array to `index.sp`.
   - Updated `examples/way_exam/test/exam_test.rb` and `app_test.rb` for 7 questions and dynamic grading.

5. **Gate Verification**:
   - All 12 Studio gate legs green: Grammar, Shape, Styles, Spiff, Scope, Promises, Conventions, Card, Pages, Vitals, Ruby, Suite.
   - 35 pages verified OK with `verify_pages.rb`.
