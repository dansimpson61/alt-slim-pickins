# Scope: action_refactoring

## Architecture
- Module boundaries:
  - `lib/vocabulary/actions.sp`: Enclosing container for buttons, links, actions, supporting scoped parameters (`path:`, `return_to:`).
  - `lib/vocabulary/action.sp`: Single-action form primitive, resolving `.path` and `.return_to` from the subject chain if not passed directly, and supporting `status:`.
  - `examples/dashboard/views/partials/queue.sp`: Refactored triage card call sites using `actions path: first_item.path, return_to: "/triage"`.
  - `examples/dashboard/views/partials/dormant.sp`: Superseded by standard `action "Set dormant", to: "/actions/status", status: "dormant"`.
  - `VOCABULARY.md`: Synchronized via `bin/generate_vocabulary.rb`.
  - `test/dashboard_test.rb`: Synchronized for flexible parity.
  - `studio/docs_helper.rb`: Cleaned up pre-existing dangling guide reference so test suite is 100% green.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Council Assessment & Bulletin Board | Establish community bulletin board with norms & debate | M1 | ORIGINAL_REQUEST R1 |
| 2 | Refactor `actions` container | Support `path:`, `return_to:`, and `children: any` in actions.sp | M2 | Council Consensus |
| 3 | Refactor `action` primitive | Fallback to subject chain for path/return_to, support status | M2 | ORIGINAL_REQUEST R2 |
| 4 | Update call sites in queue.sp | Refactor 5-arg sentences to scoped actions block | M2 | ORIGINAL_REQUEST R2 |
| 5 | Retire dormant.sp | Use standard action with status: "dormant" | M2 | Council Consensus |
| 6 | Vocabulary & Checker Sync | Run bin/generate_vocabulary.rb to update VOCABULARY.md | M2 | Acceptance Criteria |
| 7 | Full Test Suite Verification | Passes check_grammar, check_shape, check_styles, verify_pages, test/*_test.rb | M3 | Acceptance Criteria |
| 8 | Propose Additional Scope | Document proposals for future architectural evolution | M3 | ORIGINAL_REQUEST R3 |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | Community Bulletin Board | Create bulletin board with 8 luminaries debate & consensus | none | DONE |
| 2 | Refactor Implementation | Implement actions/action refactoring, update queue.sp, tests | M1 | IN_PROGRESS |
| 3 | Verification & Auditing | Run full suite, review, challenge, and forensic integrity audit | M2 | PLANNED |
