---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: active
kind: project
last_touched: '2026-09-01'
next_step: ROADMAP-0.2.md Phase 3, the payload — the lineno seam is landed
  (round 5): the transform wraps every compiled sentence in `with_line`, the
  Builder keeps the sentence's line on a stack, and runtime errors are
  located at raise time — path, line, and the sentence itself, in the same
  voice as a syntax error; test/lineno_test.rb pins it, eleven pages
  byte-identical. Next: the report-only verifier — evaluate every repo page
  and both apps against their defaults/fixtures and report (bin/verify_pages.rb
  shape): every subject resolvable, every attribute answered, the contract
  satisfied. Then the gate (an app boots by proving its pages, loudly), the
  roth boot-error test, and the per-render cost, measured.
  Both parked decisions are closed (dan, 2026-09-01): favicon is a page
  modifier, landed and tested; the when-deferral asymmetry stays as
  documented in dogfood_test — an app word that wants guard-before-read uses
  a bare name, which the grammar never evaluates.
run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: Roadmap 0.2 (ROADMAP-0.2.md, 2026-09-01), the first even-numbered,
  backward-leading roadmap (ataovy dian-tana), is past its backward look:
  Phases 0-2 closed — the Way rewritten (PRIMER.md), the vocabulary reviewed
  as contracts with check→checkbox and select→choice, the Builder
  un-god-objected (867 lines/16 ivars → 298/9, four gathering copies → one
  stack, byte-identical throughout). Phase 3's first half landed the
  semantic-node runtime, the open surface (built-ins and app words eat the
  same food, enforced by test), the filter: seam in render, and dan's
  principle recorded as constraint 3: a rule must outlive its reason. The
  payload — the boot gate — is next. The escape-hatch number is retired, in
  writing. Roadmap protocol set 2026-08-31: odd leads forward, even leads
  back; both eyes stay open. history/ is roadmap 0.1, consulted not
  maintained. HANDOFF.md is the prompt that resumes this work in a fresh
  conversation. "Tight Coupling in Ruby DSLs.md" (Gemini's critique of the
  Builder) is cited by the roadmap.
conventions: Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 50 words, its own stylesheet,
and two Sinatra apps that speak it. See [README.md](README.md) — its *How
roadmaps go* section governs how roadmaps work, and
[ROADMAP-0.2.md](ROADMAP-0.2.md) is the active one, beginning with the rewrite
of the Slim-Pickins Way.
