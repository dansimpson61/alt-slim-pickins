# Dispatch to Worker 1: Refactor `action` Primitive & Call Sites

## Mission
Implement the council's consensus refactoring for `action` and `actions`, update call sites in `examples/dashboard/views/partials/queue.sp`, synchronize vocabulary contracts, adjust test assertions under flexible parity, and ensure the entire test suite passes with 0 problems.

## Mandatory Reading & Warning
- Read `/home/dan/dev/alt-slim-pickins/.agents/ORIGINAL_REQUEST.md` before starting.
- Read `/home/dan/dev/alt-slim-pickins/.agents/COMMUNITY_BULLETIN_BOARD.md` to understand the 8 Ruby luminaries debate, team norms, and final consensus.
- Read `/home/dan/dev/alt-slim-pickins/.agents/orchestrator/SCOPE.md`.

> DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

## Exclusive Write Ownership
You own these files exclusively:
- `lib/vocabulary/actions.sp`
- `lib/vocabulary/action.sp`
- `examples/dashboard/views/partials/queue.sp`
- `examples/dashboard/views/partials/dormant.sp`
- `VOCABULARY.md` (run `ruby bin/generate_vocabulary.rb`)
- `test/dashboard_test.rb`
- `studio/docs_helper.rb`
- `COMMUNITY_BULLETIN_BOARD.md` (copy from `.agents/COMMUNITY_BULLETIN_BOARD.md` to project root)

## Detailed Steps
1. **Refactor `lib/vocabulary/actions.sp`**:
   Update `actions.sp` to take `children: any` (so it can enclose `action`, `button`, `link`, `choose`), and `path: true`, `return_to: true`:
   ```slim
   expects children: any, path: true, return_to: true, shape: encloses

   box
     children
   ```
2. **Refactor `lib/vocabulary/action.sp`**:
   Update `action.sp` to:
   ```slim
   expects content: true, shape: encloses, to: true, path: true, return_to: true, variant: true, status: true

   form method: post, to: .to
     choose
       when .path
         hidden path, .path
     choose
       when .return_to
         hidden return_to, .return_to
     choose
       when .status
         hidden status, .status
     button .variant, .content
   ```
   Notice that when `action` is nested inside `actions path: ..., return_to: ...`, `.path` and `.return_to` are automatically inherited from the subject chain! If passed directly on `action`, they use the direct value.
3. **Update `examples/dashboard/views/partials/queue.sp`**:
   Refactor the call sites:
   ```slim
   choose
     when .first_item
       text .queue_intro
       card first_item.path
         badge first_item.status_variant, first_item.status
         text first_item.purpose
         choose
           when first_item.next_line
             text first_item.next_line
         actions path: first_item.path, return_to: "/triage"
           choose
             when first_item.offer_commit
               action "Commit", to: "/actions/commit", variant: primary
           action "Set dormant", to: "/actions/status", status: "dormant", variant: neutral
           action "Archive", to: "/actions/archive", variant: neutral
           action "Skip 30d", to: "/actions/skip", variant: neutral
     otherwise
       text "All caught up. Nothing needs attention."
   ```
4. **Clean up `dormant.sp`**:
   Remove `dormant.sp` or keep it delegating to `action` if anything else references it (our survey confirmed no other file references `dormant`). If removing, make sure `Word.registry` or check scripts don't complain; or keep `dormant.sp` as a thin wrapper or delete it.
5. **Regenerate `VOCABULARY.md`**:
   Run `ruby bin/generate_vocabulary.rb`.
6. **Update `test/dashboard_test.rb`**:
   Update line 47 of `test/dashboard_test.rb`:
   Change `<form class="form dormant" action="/actions/status" method="post">` to:
   `<form class="form" action="/actions/status" method="post">` (since `dormant` is now an ordinary `action` without the ad-hoc partial class, per flexible parity justification).
7. **Fix Pre-Existing Dangling Guide in `studio/docs_helper.rb`**:
   Remove `'design_conventions'` from `StudioDocs::GUIDES` in `studio/docs_helper.rb:18` (since `design_conventions.md` was deleted in commit `0b054a4`). Report this pre-existing fix clearly.
8. **Copy Bulletin Board to Project Root**:
   Copy `/home/dan/dev/alt-slim-pickins/.agents/COMMUNITY_BULLETIN_BOARD.md` to `/home/dan/dev/alt-slim-pickins/COMMUNITY_BULLETIN_BOARD.md`.
9. **Run and Verify Full Suite**:
   Run the exact acceptance test command:
   ```bash
   ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done
   ```
   Confirm all checkers pass and all test files pass with 0 failures, 0 errors.
   Also run:
   ```bash
   ruby bin/dashboard_parity.rb
   ```
   Confirm 25 affordances compared, 0 missing.

## Deliverables
- Working code in the owned files.
- Full verification results documented in `/home/dan/dev/alt-slim-pickins/.agents/worker_1/report.md` and `handoff.md`.
- Send a completion message when done.

## 2026-09-10T21:39:00Z
You are Worker 1 (Action Refactoring Worker).
Working directory: /home/dan/dev/alt-slim-pickins/.agents/worker_1
Project root: /home/dan/dev/alt-slim-pickins
Read /home/dan/dev/alt-slim-pickins/.agents/ORIGINAL_REQUEST.md, /home/dan/dev/alt-slim-pickins/.agents/COMMUNITY_BULLETIN_BOARD.md, and /home/dan/dev/alt-slim-pickins/.agents/worker_1/DISPATCH.md before beginning.

