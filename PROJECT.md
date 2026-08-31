---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: active
kind: project
last_touched: '2026-08-31'
next_step: Phase 7 port is done and green (PHASE7.md) — dan judges it against the Slim it replaced, then Phase 8 chart
run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: Working language. Grammar settled (DESIGN.md v0.3) — one sentence, one
  resolution rule, no open questions. All 47 words implemented, and the three
  pages drafted on paper before any code existed now render
  (bin/render_pages.rb). App contract is one sentence plus two optional
  methods (CONTRACT.md). Phases 0-7 done — its own stylesheet, a working
  Sinatra integration, and roth ported (examples/roth, PHASE7.md): 88 lines of
  Slim became 40 sentences and 35 lines of script went with them. Only dan's
  judgement of that port is outstanding; 8 is chart, deliberately last.
  The routing question `link` raised is still open — roth had no links to
  settle it against. check_grammar.rb and check_styles.rb hold every document,
  page and class rule to the same grammar.
  HANDOFF.md is the prompt that resumes this work in a fresh conversation.
conventions: Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 47 words, its own stylesheet,
and a Sinatra app that speaks it. See [README.md](README.md), then
[ROADMAP.md](ROADMAP.md).
