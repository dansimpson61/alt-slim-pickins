# Daytrip 0.4.0g — The Council Skill, and the Workbench Spatial Frontier Closed

Formalized the multi-persona architecture council as a reusable skill, used it (and its own explicit revision after a rejected proposal) to resolve the four frontiers the 2026-09-25 workbench spatial investigation identified, then chased three further rendering defects dan caught by eye in the studio workbench itself — each measured live before being touched, several correcting the session's own earlier wrong conclusions.

---

## The brief

`PROJECT.md`'s `next_step` going in: resolve four frontiers from the prior
session's workbench spatial investigation (`LORE.md`, 2026-09-25) —
numerical units in `.design` files, stylesheet cascade fragmentation across
three strata, defensive selector explosion from contract ambiguity, and the
app-shell-vs-document-page dualism. Separately, dan asked for a reusable
skill formalizing the "council" pattern already used once in this repo
(`COMMUNITY_BULLETIN_BOARD.md`'s `action`-primitive session) — a
multi-persona architectural debate, fixed to stop wasting a subagent per
persona per round.

---

## Part 1 — The council skill

`.claude/skills/council/SKILL.md`: a ten-voice roster (the eight Ruby
stewards from the precedent session, plus Bret Victor and Don Norman for
the people-centered/UX lens dan named as missing). The operating rule that
fixes the prior waste: the whole transcript is written in one continuous
pass, in-context — never one subagent per persona — and every round after
the first must engage a specific named prior claim rather than opening
fresh. Step 0 orients from `PROJECT.md` as authoritative over a
provably-lagging `HANDOFF.md`, plus `ODE_TO_JOY.md` and
`working-with-dan.md` for the standard the transcript is judged against.

## Part 2 — The four frontiers, revised mid-flight

A first council session proposed fixing the selector explosion (Frontier 3)
with `data-surface`/`data-zone` HTML attributes. Dan rejected it on sight:
*"The name of the zone is machine inferable and therefore does not belong
in the dsl."* Investigating the objection found the redundancy was almost
entirely avoidable, not just relocatable — `workbench.css` is linked by
exactly one UI, so a compiled stylesheet is already scoped by which pages
load it, and this project's own app_class-promotion convention already
makes a zone's bare class real. Net shipped: **zero new HTML attributes,
zero `.sp` file changes** for the zone case; the one genuinely
non-inferable case (the shared `sidebar_layout` wrapper) pulled one symbol
forward from the council's own deferred Scope Proposal 1 — `surface
workbench, kind: shell`.

Landed, three commits:
- **Frontier 1 + 4**: `COLLAPSE_TOKENS` (qualitative `collapse:` tokens
  replacing raw rem strings); the only two `100vh` occurrences in the
  compiler → `100dvh`.
- **Frontier 2**: `DesignIdiom.compiled_stylesheet(source, provenance:)`,
  one pipeline for both the asset route and the playground preview, each
  with its own provenance comment.
- **Frontier 3**: `ZoneBuilder#to_css` targets one real bare class instead
  of a 7-way guess; `StageBuilder#to_css` picks `.sidebar_layout` (`kind:
  shell`) or `body` (default `kind: document`) instead of a 6-way guess.
  `assets/workbench.css`: 459 lines / 99 `:has(` → 162 lines / 0.

## Part 3 — Three real defects, found by eye and measured, not guessed

Dan pushed two screenshots of the actual rendered Workbench. Each report
led with a live DOM measurement before any file changed — twice the first
plausible-looking explanation was wrong, and the record says so rather
than hiding it.

1. **doc_reader's preview looked "uninviting."** Measured: the container
   query *was* correctly collapsing at the embedded preview's real width —
   not a bug. The actual defect was `catalog`/`reading_pane` both declaring
   `frame quiet`, rendering as identical undifferentiated cards. A second,
   tighter council (Metz, Norman, Victor) fixed it with two words:
   `catalog` → `frame flat`, `reading_pane` → `frame lifted`.

2. **"Did no one see the contents of both panels are undersized?"** Two
   separate, real defects:
   - Editor textareas rendered at 384px inside a 622px container — a
     generic `.field textarea { max-width: 24rem }` rule (sized for short
     form fields) leaking into the code editor, which set `width: 100%`
     but never reset `max-width`.
   - **Container queries were never actually working**, for either surface
     kind, since the compiler was first written. Proven with an isolated
     reproduction: `body { container-type: inline-size; } @container name
     (...) { body { grid-template-columns: 100%; } }` never matches, at
     any width — a container cannot reliably restyle the element that
     establishes it. Fixed by splitting `container-type`/`container-name`
     onto the wrapper's real DOM parent (`KIND_CONTAINER_PARENTS`: shell →
     `body`, document → `html`) instead of the wrapper itself. Zero new
     markup. This also corrected two "verified live" claims this same
     session had written into `LORE.md` earlier that night, both wrong.

3. **"And the three columns' three different heights?"** `align-items:
   start` (every stage, since the compiler's first commit) let each zone
   in a row size to its own content instead of a shared row height.
   Switched to `stretch`, verified safe for doc_reader's flank layout in
   isolation first (its `frame: flat` catalog has no border to reveal the
   extra stretched space). Fixed library/editor to match exactly (951px
   each). `output` stays independently sized — `presence: :steady`'s own
   explicit `height: calc(...)` overrides stretch by design — left open,
   the same deferred "surface containment" scope item the first council
   session already named and declined to do as a rider.

---

## Verification

Every fix in Parts 2 and 3 was confirmed against a genuinely restarted
studio server (Puma renames its process title, so `pgrep -f "ruby
studio/app.rb"` silently matches nothing — a real trap hit twice this
session before switching to killing by listening-socket PID) and live DOM
measurement — `getBoundingClientRect`, `getComputedStyle`, isolated
`srcdoc` iframe reproductions for the container-query and stretch
hypotheses — never a screenshot alone.

- **Full suite**: 445 runs, 5,619 assertions, 0 failures, 0 errors, 0
  skips (one process).
- **All 7 gates green**: `check_grammar.rb` (1,254 sentences, 94 words),
  `check_shape.rb` (62 words, 1,006 sentences), `check_styles.rb` (105
  rules), `bin/check_promises.rb` (35 promises), `bin/check_conventions.rb`
  (38 conventions), `bin/check_card.rb`, `bin/verify_pages.rb` (31 pages).
- Nine commits total, one per frontier/defect group, each independently
  green.

## Left open, on purpose

- **`collapse: tight`'s 26rem threshold** — dan's own call: fold into a
  future token ground-truthing daytrip rather than patch piecemeal.
  `balance: subordinate`'s 14rem lead floor is the same deferred question
  (it's what makes the un-collapsed two-column case lopsided at the
  embedded preview's real width).
- **`output`'s independent height** — full three-way row parity needs the
  `presence: :steady` height calculation moved from the zone up to the
  stage/row level. Same deferred "surface containment" item as Scope
  Proposal 1 from the first council session.
- **`--footer-height: 2.8rem`** (bumped from the wrong `2rem` this session)
  is a corrected guess, not a durable fix — still a hardcoded assumption
  about the footer's real rendered size, same fragile character as
  `tight`. Candidate for the same daytrip.
