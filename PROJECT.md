---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: active
kind: project
last_touched: '2026-08-30'
next_step: ROADMAP.md Phase 7 — port roth entirely, then dan judges it against the Slim it replaced
run: ruby examples/portfolio/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: Working language. Grammar settled (DESIGN.md v0.3) — one sentence, one
  resolution rule, no open questions. All 47 words implemented, and the three
  pages drafted on paper before any code existed now render
  (bin/render_pages.rb). App contract is one sentence plus two optional
  methods (CONTRACT.md). Phases 0-6 done — including its own stylesheet and a
  working Sinatra integration. Phase 7 ports roth; 8 is chart, deliberately
  last. check_grammar.rb and check_styles.rb hold every document, page and
  class rule to the same grammar.
  HANDOFF.md is the prompt that resumes this work in a fresh conversation.
conventions: Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 47 words, its own stylesheet,
and a Sinatra app that speaks it. See [README.md](README.md), then
[ROADMAP.md](ROADMAP.md).
