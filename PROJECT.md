---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: active
kind: project
last_touched: '2026-08-31'
next_step: Phases 0-8 complete and green (PHASE8.md) — the language is done as scoped. Next real work is a second port aimed at conditional/bespoke UI, the flank roth never exercised; the `link` routing question is still open for want of a page that navigates
run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: Working language. Grammar settled (DESIGN.md v0.3) — one sentence, one
  resolution rule, no open questions. All 50 words implemented, and the three
  pages drafted on paper before any code existed now render
  (bin/render_pages.rb). App contract is one sentence plus two optional
  methods (CONTRACT.md). Phases 0-8 done — its own stylesheet, a working
  Sinatra integration, roth ported deeply (examples/roth, PHASE7.md), and
  `chart` redrafted against roth's two charts (PHASE8.md): 130 lines of Ruby
  became 13 sentences, roth lost its last app word, and the escape hatch across
  the repo is 1 use in 356 sentences. Scenario owns the input names,
  Projection presents the results. roth's own domain defects are a separate
  project (ROTH_STUDY.md, ROTH_DOMAIN_BACKLOG.md) and ~/dev/roth is untouched.
  Only dan's judgement of the port is outstanding; 8 is chart, deliberately
  last. The routing question `link` raised is still open — roth had no links to
  settle it against. check_grammar.rb and check_styles.rb hold every document,
  page and class rule to the same grammar.
  HANDOFF.md is the prompt that resumes this work in a fresh conversation.
conventions: Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 50 words, its own stylesheet,
and a Sinatra app that speaks it. See [README.md](README.md), then
[ROADMAP.md](ROADMAP.md).
