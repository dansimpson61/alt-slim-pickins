---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: active
kind: project
last_touched: '2026-08-31'
next_step: Write ROADMAP-0.2.md. It is an even-numbered roadmap, so by the protocol in README.md "How roadmaps go" it leads with the backward eye — review the progress made, re-read history/ and LORE.md, and study the DSL and the code beneath it as objects, to the standard of excellent Ruby. The forward eye stays open: reshape the runtime around what it must next carry, and build nothing the backward look did not ask for. Argue it from the measured findings in the last LORE.md entry; do not start from a blank page
run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: A working view language. Grammar settled (DESIGN.md v0.3) and never changed
  across eight phases — one sentence, one resolution rule, no numeric literal.
  Fifty words, all implemented and all exercised. App contract is one sentence
  plus two optional methods (CONTRACT.md). Roadmap 0.1 is CLOSED
  (history/ROADMAP-0.1.md); ROADMAP-0.2.md is NOT YET WRITTEN. Two Sinatra apps
  speak the language; examples/roth is a deep port of ~/dev/roth that renders
  its results server-side and uses no Ruby-defined words at all. Two checkers
  hold docs and styles to the code; test/combination_test.rb crosses the words
  that hold state, after two crashes lived behind 133 happy-path tests.
  Roadmap protocol, set 2026-08-31: ataovy dian-tana — walk like the chameleon,
  watching ahead and behind at once. Both eyes stay open; the roadmap number
  says which leads. Odd leads forward, even leads back, so 0.2 is a
  retrospective on the DSL and the objects beneath it, and is the first of
  its kind. A draft 0.2 aimed at porting ~/dev/dashboard was
  written and deleted the same day; it is in commit 8542111 if wanted.
  HANDOFF.md is the prompt that resumes this work in a fresh conversation.
conventions: Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 50 words, its own stylesheet,
and two Sinatra apps that speak it. See [README.md](README.md) — its *How
roadmaps go* section governs what 0.2 has to be, and 0.2 is not written yet.
