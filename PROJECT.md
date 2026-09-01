---
schema_version: 1
id: alt-slim-pickins
purpose: Exploring a view DSL whose grammar stays describable all the way down
status: active
kind: project
last_touched: '2026-09-01'
next_step: ROADMAP-0.2.md Phase 2 is CLOSED (2026-09-01) — the four
  gatherers are components sharing one mechanism, eleven pages byte-identical,
  the warts gone (Library.from takes words:), the AST decision recorded
  (parse → validate → generate; the generator stays). Phase 3 is next: the
  payload — a page may not render until the app has been proved able to
  answer it. A validation pass over the tree before emission, report-only
  first, then the gate; the roth test (renaming an attribute fails at boot,
  naming line and attribute); the per-render cost measured.
run: ruby examples/roth/app.rb
docs: README.md
related:
- slim-pickins
- ode-to-joy
notes: Roadmap 0.2 is WRITTEN (ROADMAP-0.2.md, 2026-09-01), the first
  even-numbered, backward-leading roadmap (ataovy dian-tana). Verdict: the
  grammar stands; the vocabulary stands with two renames (check→checkbox,
  select→choice — verbs among nouns, renamed in Phase 1) and a shape checker;
  the Builder does NOT stand — 867 lines, 16 ivars, 25 of 50 words touching
  them, four copies of one gathering mechanism (option unguarded, `when`
  guards after its argument is evaluated). Phases: 0 rewrite the Slim-Pickins Way, 1 the part-of-speech
  checker + renames + doc hygiene, 2 un-god-object the Builder (component
  objects; AST-pipeline decision recorded), 3 the payload — a page may not
  render until the app can answer it, 4 the dashboard exam port (conditional
  UI, routing), 5 dogfood (prose grows fences/tables/ordered lists for this
  repo's own docs), 6 subtraction. check_grammar.rb now holds ROADMAP-0.2.md.
  The deleted 0.2 draft's lesson survives in it: the port is the exam, not
  the syllabus. Escape-hatch number is retired, in writing. Roadmap protocol
  set 2026-08-31: odd leads forward, even leads back; both eyes stay open.
  history/ is roadmap 0.1, consulted not maintained. HANDOFF.md is the prompt
  that resumes this work in a fresh conversation. "Tight Coupling in Ruby
  DSLs.md" (Gemini's critique of the Builder) is untracked in git and is
  cited by the roadmap.
conventions: Views speak the slim-pickins DSL; the best JavaScript is the least
  JavaScript.
---

# alt-slim-pickins

A working view language: one-sentence grammar, 50 words, its own stylesheet,
and two Sinatra apps that speak it. See [README.md](README.md) — its *How
roadmaps go* section governs how roadmaps work, and
[ROADMAP-0.2.md](ROADMAP-0.2.md) is the active one, beginning with the rewrite
of the Slim-Pickins Way.
