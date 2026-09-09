---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: IMPLEMENTATION - Phase 5 under way — docs payloads name every partial's true home, the dashboard's tests-fail flag caught it; prose growth is next
kind: project
last_touched: 2026-09-09
next_step: >-
  Resume ROADMAP-0.2.md Phase 5: prose grows fences, tables, ordered lists
  (measured 2026-09-09: 344 fences, 35 tables, 61 ordered-list lines across
  the repo's docs — flat lists, plain separators, 0 alignment colons), then
  the checkers' status page
run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: >-
  Roadmap 0.2 (ROADMAP-0.2.md, 2026-09-01), the first even-numbered,
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
  conversation. DAYTRIP.md (2026-09-06) is a jaunt, not a roadmap — it leads
  with neither eye and took no ground the language did not already hold: the
  gate runs again, the suite tests what ships, the studio's guides work. Its
  findings are all settled; the two it left to Phase 6 are `action` at five
  arguments and vocabulary coverage at 54 of 69. "Tight Coupling in Ruby DSLs.md" (Gemini's critique of the
  Builder) is cited by the roadmap. Phase 4 is closed (2026-09-06), judged
  by dan: the gap ledger G1–G13 is disposed in examples/dashboard/INVENTORY.md,
  flash/action/search stay partials, and the verdict stands in ROADMAP-0.2.md
  Round D. The studio's docs links now render truthful payloads server-side
  (StudioDocs.entries is a plain hash, so word names never dispatch on an
  OpenStruct) with the fence warning note; the playground is unchanged.
  Phase 5 opened 2026-09-09 with a catch the dashboard's single-process test
  runner made: the docs payload assumed every partial is builtin, so the
  portfolio's account_card named a lib/vocabulary file that is not its own.
  A partial now carries its source_path from the Library (one glob, source
  and path together), the docs name the true home, and a partial declared
  inline says so. The prose measurement is recorded in next_step.
conventions: >-
  Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 50 words, its own stylesheet,
and two Sinatra apps that speak it. See [README.md](README.md) — its *How
roadmaps go* section governs how roadmaps work, and
[ROADMAP-0.2.md](ROADMAP-0.2.md) is the active one, beginning with the rewrite
of the Slim-Pickins Way.
