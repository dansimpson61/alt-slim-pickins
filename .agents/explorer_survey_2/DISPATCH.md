# Dispatch to Explorer Survey 2

## Mission
Investigate the call sites of `action` in `examples/dashboard/views/triage.sp` and other template files, and explore the test suite / verification pipeline.

## Context & Inputs
- Project root: `/home/dan/dev/alt-slim-pickins`
- Original user request: `/home/dan/dev/alt-slim-pickins/.agents/ORIGINAL_REQUEST.md` (Read this first!)
- Working directory: `/home/dan/dev/alt-slim-pickins/.agents/explorer_survey_2`

## Specific Questions to Investigate
1. Where is `action` called in `examples/dashboard/views/triage.sp` and anywhere else in `examples/` or other templates? Examine the exact lines and patterns.
2. How does `ruby bin/verify_pages.rb` work? What does it verify? Does it check exact HTML output, snapshots, or semantics?
3. How do `check_grammar.rb`, `check_shape.rb`, and `check_styles.rb` work? What do they check?
4. How do `test/*_test.rb` work? Run/inspect the test suite to see the baseline status and how tests are structured.
5. What does "flexible parity" mean in the context of `verify_pages.rb` and the resulting HTML structure? Can expected outputs or fixtures be updated if justified?

## Output Requirements
Write a detailed report to `/home/dan/dev/alt-slim-pickins/.agents/explorer_survey_2/report.md` and a summary `handoff.md`.
Send a completion message when done.
