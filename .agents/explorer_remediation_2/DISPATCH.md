# Dispatch to Explorer Remediation 2 (Iteration 2)

## Mission
Analyze the full forensic audit failure (INTEGRITY VIOLATION) and all reviewer and challenger findings from Iteration 1. Investigate the codebase (`lib/slim_pickins/partial_word.rb`, `lib/slim_pickins/subject.rb`, `lib/vocabulary/action.sp`, `lib/vocabulary/actions.sp`, `test/vocabulary_partials_test.rb`, `test/phase4_test.rb`), and formulate a complete, genuine, and elegant remediation implementation plan for Worker 2.

## Mandatory Inputs (Read ALL of these)
- `/home/dan/dev/alt-slim-pickins/.agents/ORIGINAL_REQUEST.md` (Read this first!)
- `/home/dan/dev/alt-slim-pickins/COMMUNITY_BULLETIN_BOARD.md`
- `/home/dan/dev/alt-slim-pickins/.agents/auditor_1/report.md` (FULL FORENSIC AUDIT REPORT — Mandatory!)
- `/home/dan/dev/alt-slim-pickins/.agents/reviewer_1/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/reviewer_2/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/challenger_1/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/challenger_2/report.md`

## Key Problems to Investigate & Solve
1. **INTEGRITY VIOLATION (Hardcoded symbols in core engine)**:
   In `lib/slim_pickins/partial_word.rb:96`:
   `elsif !%i[path return_to].include?(modifier)`
   This hardcoded whitelist must be completely removed. The scoping mechanism must be completely genuine and general for any partial and any modifier.
2. **FATAL RUNTIME CRASH (Standalone and partial-parameter action calls)**:
   Calling `action "Logout", to: "/logout"` or `actions\n  action "Logout", to: "/logout"` or `action "Save", to: "/save", path: "abc"` crashes with `SlimPickins::UnknownAttribute: this page has no path` (or `no return_to`) because missing modifiers raise on `Subject#fetch`.
   Investigate how `PartialWord` can check if the enclosing subject (e.g. `chain.current`) defines the modifier, and if not present anywhere, ensure declared modifiers default to `nil` or are handled safely so `choose / when .path` evaluates to falsey without raising `UnknownAttribute`.
3. **PREVENT LEAKAGE & UNINTENDED HIJACKING**:
   Ensure `action` does not accidentally pluck unrelated model properties (like `article.path`) or Sinatra controller methods (like `status: 200` on `Page`). Parameter inheritance should be scoped to enclosing container partials (`chain.current` or container subjects).
4. **TEST ORDER FLAKINESS**:
   Reviewer 2 found `ruby test/phase4_test.rb --seed 21530` can fail because `Phase4Test` does not ensure `Library.builtin` is loaded before checking `Word.registry`. Verify and specify the exact fix in `test/phase4_test.rb`.
5. **ACCEPTANCE & PARITY PRESERVATION**:
   Ensure all existing checkers (`check_grammar.rb`, `check_shape.rb`, `check_styles.rb`, `bin/verify_pages.rb`, `bin/dashboard_parity.rb`) and all tests pass with 0 problems.

## Output Requirements
Investigate and write your findings and concrete step-by-step fix plan to:
- `/home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/handoff.md`



## 2026-09-10T22:49:15Z

You are Explorer Remediation 2.
Your working directory is /home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2.
Project root is /home/dan/dev/alt-slim-pickins.
Read /home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/DISPATCH.md and all input files listed therein, especially /home/dan/dev/alt-slim-pickins/.agents/ORIGINAL_REQUEST.md and /home/dan/dev/alt-slim-pickins/.agents/auditor_1/report.md.
Investigate the codebase and produce:
1. /home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/report.md
2. /home/dan/dev/alt-slim-pickins/.agents/explorer_remediation_2/handoff.md
Detailing the verified, genuine architecture and code changes for Worker 2 to remediate the Forensic Audit integrity violation and all reviewer/challenger defects.
When finished, send a completion message to the parent orchestrator via send_message.
