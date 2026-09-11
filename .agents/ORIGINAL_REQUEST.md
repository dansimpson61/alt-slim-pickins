# Original User Request

## 2026-09-10T21:32:22Z

# Teamwork Project Prompt — Draft

> Status: Launched
> Goal: Delegate to teamwork_preview
> Requested team: A council of 8 specific Ruby luminary personas

A council of 8 Ruby luminaries (Matz, Sandi Metz, _why, DHH, Jim Weirich, Avdi Grimm, Katrina Owen, Sarah Mei) will assess and refactor the `action` primitive in the `alt-slim-pickins` DSL. The `action` primitive currently takes 5 arguments, making it the longest sentence in the language, and the team must determine if this is a symptom of a missing abstraction and implement a cleaner solution.

Working directory: /home/dan/dev/alt-slim-pickins

## Requirements

### R1. Persona-Driven Assessment & Community Bulletin Board
The team must establish a shared markdown document to act as a "community bulletin board". Use this document to establish team norms and debate the 5-argument `action` problem from the perspectives of the 8 Ruby luminaries (Matz, Sandi Metz, _why, DHH, Jim Weirich, Avdi Grimm, Katrina Owen, Sarah Mei). The router should use this board to manage the council's collaboration.

### R2. Refactor `action`
Based on the council's consensus, implement a refactored solution for `action` (and its call sites in `examples/dashboard/views/triage.sp`) that aligns with the DSL's core principles. You have the flexibility to alter the resulting HTML structure slightly if it leads to a significantly cleaner DSL, provided the visual and semantic function remains intact.

### R3. Propose Additional Scope
If the council discovers that refactoring `action` is hindered by deeper architectural constraints, propose additional scope or refactoring targets that would facilitate development aligned with the project's core intent.

## Acceptance Criteria

### Verification & Testing
- [ ] The full test suite passes with 0 problems (`ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done`).
- [ ] Any intentional changes to the HTML output (flexible parity) are explicitly documented and justified by the council.
- [ ] The community bulletin board document is populated with the council's norms, debate, and final consensus.
- [ ] Any proposed additional scope (if required to facilitate R2) is clearly documented with justifications rooted in the project's design philosophy.
