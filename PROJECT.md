---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: active
kind: project
last_touched: '2026-08-31'
next_step: ROADMAP-0.2.md Phase 0 — one gathering mechanism in place of four (table/chart/choose/select), guards that fire before their word evaluates its arguments, then name the seven shapes and build check_shape.rb. Roadmap re-sequenced 2026-08-31: foundations first, contract-at-boot second, the dashboard port is now the exam at Phase 5. HANDOFF.md is stale and still describes the old order
run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: A working view language. Grammar settled (DESIGN.md v0.3) and never changed
  across eight phases — one sentence, one resolution rule, no numeric literal.
  Fifty words, all implemented and all exercised. App contract is one sentence
  plus two optional methods (CONTRACT.md). Roadmap 0.1 is CLOSED
  (ROADMAP-0.1.md); ROADMAP-0.2.md is live and nothing in it is started. Two
  Sinatra apps speak the language; examples/roth is a deep port of ~/dev/roth
  that renders its results server-side and uses no Ruby-defined words at all.
  Escape hatch: 1 use in 356 sentences. Three checkers hold docs, styles and
  tests to each other; test/combination_test.rb crosses the words that hold
  state, after two crashes lived behind 133 happy-path tests. 0.2 targets
  ~/dev/dashboard (23 views, 1555 lines, 233 branches) and asks what a language
  can do once it knows what every page means. HANDOFF.md is the prompt that
  resumes this work in a fresh conversation.
conventions: Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 50 words, its own stylesheet,
and two Sinatra apps that speak it. See [README.md](README.md), then
[ROADMAP-0.2.md](ROADMAP-0.2.md) for what happens next.
