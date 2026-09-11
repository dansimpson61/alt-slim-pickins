# Dispatch to Challenger 3 (Iteration 2 Empirical & Stress Verifier)

## Mission
Conduct an adversarial empirical stress test of Worker 2's implementation of `action`, `actions`, and the new overlay parameter scoping engine. Write test scripts and probes to challenge assumptions and attack potential edge cases.

## Mandatory Inputs (Read ALL of these)
- `/home/dan/dev/alt-slim-pickins/.agents/ORIGINAL_REQUEST.md` (Read first!)
- `/home/dan/dev/alt-slim-pickins/COMMUNITY_BULLETIN_BOARD.md`
- `/home/dan/dev/alt-slim-pickins/.agents/auditor_1/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/challenger_1/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/worker_2/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/worker_2/handoff.md`

## Specific Challenges to Execute
1. Standalone `action "Logout", to: "/logout"` on subjects with/without attributes.
2. `actions` with no parameters, with only `path:`, with only `return_to:`, and with both.
3. Nested `actions` blocks with parameter overrides.
4. Model attribute leakage attack: enclosing subject defines `path`, verify child `action` without `path:` does NOT emit model's path.
5. Framework method collision attack: verify `status` does not leak `200` from Sinatra/Page.
6. Acceptance suites: `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done` and `ruby bin/dashboard_parity.rb`.

## Output Requirements
Generate:
- `/home/dan/dev/alt-slim-pickins/.agents/challenger_3/report.md`
- `/home/dan/dev/alt-slim-pickins/.agents/challenger_3/handoff.md`

State your explicit verdict (**APPROVE** or **REQUEST_CHANGES**) in both artifacts, and send a message when done.

## 2026-09-10T22:57:44Z
You are Challenger 3.
Your working directory is /home/dan/dev/alt-slim-pickins/.agents/challenger_3.
Project root is /home/dan/dev/alt-slim-pickins.

Read /home/dan/dev/alt-slim-pickins/.agents/challenger_3/DISPATCH.md and all input files referenced therein.
Conduct empirical adversarial stress tests on Worker 2's implementation.
Test standalone action, partial parameters, nested actions, attribute hijacking attacks, and framework collision attacks.
Run all acceptance suites and tests.
Write your report to /home/dan/dev/alt-slim-pickins/.agents/challenger_3/report.md and /home/dan/dev/alt-slim-pickins/.agents/challenger_3/handoff.md.
State your verdict (APPROVE or REQUEST_CHANGES) and send a message when done.
