# Handoff

Paste this into a new conversation to resume the work.

---

Resume work on `~/dev/alt-slim-pickins`.

**Start by reading**, in this order:

1. `curl http://127.0.0.1:4000/brief/alt-slim-pickins` (or `PROJECT.md` if the dashboard is down)
2. `README.md` — what the project is, and **How roadmaps go**, which governs how roadmaps transition
3. `ROADMAP-*.md` — the active roadmap: 0.2 is closed; 0.3 (the forward eye,
   three legs in one question) is in Phase 0 — the studio, won iteratively;
   ten wins landed 2026-09-15; `PROJECT.md` `next_step` points at the pick
4. `DAYTRIP-0.3.0b.md` — *The Accent*, opened and closed 2026-09-17: the two
   instruments, the mechanical claim corrections, and the register's reference
   shape (a word declares the conventions it triggers). Its closing section
   names what it leaves behind, including F8 (five claims no code kept —
   recorded, on dan's ruling nothing built) and F9. `DAYTRIP-0.3.0a.md` is
   held, not withdrawn, and is due the re-reading dan's fifth answer promised.
5. `PRIMER.md` — the Way, as it stands now (the tour replaces the old Slim-Pickins primer)
6. `DESIGN.md`, `CONTRACT.md` — the grammar and the app promise; `VOCABULARY.md`'s five checkable bullets per entry are generated (`bin/generate_vocabulary.rb`), and so are the `conventions` bullets of the 39 words that declare one
7. `LORE.md` — what previous sessions *learned*; the last entries are this session's
8. `working-with-dan.md` — candid notes on working with him: what his
   questions mean, what lands, what does not. It is short, it is honest, and
   **it is yours to keep true** — updating it is part of the round. Its top
   note says dan asked for it to be promoted machine-wide; whoever can write
   outside this workspace carries it there.

Root holds what you read. `history/` is roadmap 0.1, consulted, not maintained;
`roth/` is notes on a different project. Don't re-derive any of the above in
conversation; it is all written down.

## Where things stand

**Roadmap 0.2 is fully closed.** The backward eye's discipline (ataovy dian-tana) has run its course through all six phases:
- The Way was rewritten (`PRIMER.md`).
- The Builder was un-god-objected into semantic nodes.
- The exam was passed (the vocabulary successfully ported `roth` with 0 missing affordances).
- The ecosystem now eats its own dogfood (the dashboard and studio docs are served by `prose`, `link`, and the gate).
- Subtraction is complete (`meta`, `icon`, `thumb` are gone, and `action` is refactored).

The detailed phase-by-phase record of Roadmap 0.2 remains in `ROADMAP-0.2.md`.

## What is next — Roadmap 0.3

**Phase 6 (Subtraction) is complete, officially closing Roadmap 0.2.**
The vocabulary is clean (`meta`, `icon`, `thumb`, `thumbnails` removed), the `action` primitive is refactored, and Phase 5's prose named-limits (`---`, heading boundaries, table alignment colons, and deeply nested lists) are fully natively supported by `prose` (because we discovered they were genuinely needed for structural clarity, validating that we shouldn't strip them).

**Phase 0 is open — the studio, won iteratively — and eleven wins have
landed.** Ten on 2026-09-15, and **Win 11 on 2026-09-17: the multi-UI trunk,
and the workbench.** Win 1, the palette: the playground offers the repo's
own pages as starting points, thirteen of them, each wearing the census
verdict of the render the playground will give it — 13 of 13 refuse, every
one of them the data wall. Win 2, the word docs grow teeth: every
vocabulary entry carries an *"In the wild"* section — real sentences from
the repo's corpus, cited, each with a Try-it link — and a try-it pane
beside the reading (the playground's editor and outputs, Visual and HTML
side by side, zero JavaScript). Win 3, the data wall with refusals in the
language's own voice: a JSON data slot bound as locals, and playground
errors render as a "Refusal" page the language itself drew. Win 4, the
partial wall: the playground's library merges the example apps' partials,
so a loaded page and its data render end-to-end, and the docs sidebar now
reads the language's one home (VOCABULARY.md) instead of the live registry.
Win 5, the deepening: examples show the word in its real home (the page
line — the subject's home — and the path down to the sentence), and the
data slot arrives pre-filled from a data ledger that serves each page the
locals its own app proves it with. Win 6, the try-it yield: dan's audit
found 34 useful / 16 empty / 14 refused; the context now carries the
word's body and its co-registrations, ledger-less examples get synthesized
payloads, structural words are labeled honestly, and the audit is the
acceptance test — 62 useful / 2 structural / 2 noted / 0 refusals, pinned
every round (`test/studio_try_test.rb`). Win 7, the Stimulus burr resolved
live: no Render button remains (dan's ruling — live rendering made it
redundant), debounced rendering as you type, a vendored
@hotwired/stimulus@3.2.2 UMD, one `render` controller, and the studio's
`wired_form` app word through the escape hatch; the `/render.json`
contract `{ visual, source }` writes both panes from one fetch — the
raw-HTML pane's tidy monospace wrapper lives in the contract, because a
pane's presentation is part of its payload. Rendering requires
JavaScript, which the studio says rather than hides. Win 8, the
verify_pages gap closed: the studio's own four pages joined the gate with
the shapes their routes serve — status against canned results, because
its route shells the gate and live results would recurse (named in the
script). The gate now proves every corpus page: 14 pages verified, 0
problems. Win 9, the snippet word's dead Copy button subtracted —
everywhere at once (the generator stopped emitting it, the CSS rule went
with it: 95 rules → 94); wiring was never the answer, because the
button's two homes are the docs fences and the try-it's script-less
iframes, and a fence's text is natively selectable. Win 10, the repo's
own pages joined the palette — 13 entries became 18, specimen leading,
census completeness widened to pages/, and their ledger providers (from
the deepening) pre-fill the data on load.

**Win 11 (2026-09-17) — the studio holds several UIs, and picking one is a
word.** dan rewrote the identity ruling into "manage multiple UIs from which we
can pick… an exploration before we update guides and turn agents loose to build
some new garden apps." So:

- **A UI is a directory** under `studio/uis/`: `layout.sp` (the frame `page`
  infers), `views/` (+ `views/partials/`), `words.rb` (a module that
  `include`s — never `extend`s — the shared interface kata `StudioUI`), and
  `about.rb` (`TITLE`, `DESIGN`, and `paths`).
- **`?ui=` selects, a cookie remembers, `/ui/:name` switches**, and the picker
  is a partial each UI draws. `studio/uis.rb` is the registry; it asks a UI
  directory for its API rather than listing them anywhere.
- **The seam is `paths`.** A UI declares the templates it mints URLs from;
  `StudioUI#link_to` substitutes `:ui` for the UI that is *speaking*, so no view
  holds a route and one UI cannot link into another. A word one UI needs is that
  UI's business; a word two UIs need is evidence for the language — that is the
  exploration's point, and neither UI has asked for anything yet.
- **The workbench** is `main_menu` / `library` / `panes` / `foot`; its
  `layout.sp` carries the assets, the menu, the frame and the footer, and its
  shelf holds the words, the repo's pages with their census, and the guides.
  `/docs/:word` is a **state of the shelf**, not a page — so there is one editor
  and `try_it.sp` is gone.
- **The classic UI is kept whole as the control.** Both read **18 of 18 `ok`**
  in their own shelves, verified in Chromium as well as by the gate.
- **A loaded page is not a page of this UI**: it renders with the sandbox
  library (no UI's layout), which is why `StudioPages.load_locals` is one home
  and `entries` takes both a `library` and a `pages_library`.

Eight previously invisible defects were fixed in the landing; the honest list is
in `ROADMAP-0.3.md` under Win 11 (the largest: `page` read its head before the
layout ran, so a layout's assets never reached `<head>`).

**Phase 0 is fully closed.** Win 11 landed 2026-09-17, followed by Phase 0 mop-up
on 2026-09-21 (resolved the `split_pane` try-it test regression, removed the
`builder.rb` puts probe and `words.rb` dummy stubs, updated `PRIMER.md` with
explicit styling discipline and workbench guide, aligned word counts to 64). The
gate is 100% green across all 7 legs and 29 test files (339 runs, 3,753 assertions,
0 failures, 0 unread promises). Resume from `PROJECT.md` `next_step`: **Phase 1 —
The garden, planted**. Roadmap 0.2 was an even-numbered roadmap (the backward eye);
0.3 is the forward eye. Its question, chosen and challenged by dan (2026-09-14): can
the language carry real work — a garden of real apps, the studio won iteratively
into the workbench, the kernel lowered only as the work demands. The dashboard is
one bed in the garden, not a canon: sp's entire effect on it is two requires of its
lib plus the planned read-only markdown rendering. The draft (ROADMAP-0.3.md) is held
by the checker and served by the studio; KERNEL.md carries its re-measured addendum.

**The studio (`studio/`, port 4580, `STUDIO_PORT` to override) is
agent-managed** — dan's ruling, 2026-09-15: he stopped his own process and
handed start/stop to the agents. It serves whatever code it booted with,
so **after every round, restart it so it runs the latest committed code,
and leave it running** — dan's browser should always see current work.

**The routine, corrected 2026-09-17 from measurement.** Check the port
(`curl -s -m 2 http://127.0.0.1:4580/`). If it is down, start it as a
**managed background job** — in this harness that means `run_in_background`
with `exec` so the server replaces the shell and owns the PID:

```bash
cd ~/dev/alt-slim-pickins && exec ruby studio/app.rb
```

**`nohup … & disown` does not survive this sandbox, and this file used to
recommend it.** Measured on 2026-09-17: a detached process is reaped when
the tool call's scope is torn down, so it served within its own call and was
gone by the next one — `curl` returned 000 one call later, twice. The managed
job has now been confirmed alive across separate calls. What the old note said
about session-tracked jobs being SIGTERMed is true of *its* machinery and not
of this one; the file is the authority, so it says what was measured.

**To restart it, kill the old one first — it runs as `ruby`, and the port is
the handle** (`ss -ltnp | grep :4580`, then kill that pid). A stale studio
serving moved files is the failure mode to expect: on 2026-09-17 a process
booted before `studio/views` moved into `studio/uis/classic/views` answered
every route with `Errno::ENOENT … studio/views/index.sp`, which is exactly
what "serves whatever code it booted with" looks like from the outside.

**One wall worth knowing before you spend a round on it:** a process started
in an *earlier* session lives in a different sandbox, and **no signal from
this session reaches it** — `kill`, `pkill` and `ss -p` all come up empty
because the process is not in this namespace, though its socket still
answers. Verify it by the cgroup on the socket
(`ss -ltnep | grep :4580`): a scope other than this call's own is not
yours to kill. That is dan's to clear, and asking him costs one message
while hunting it costs a round. It happened once, on 2026-09-17.

During a round, verify on a spare port (`STUDIO_PORT=4597 ruby studio/app.rb`),
then kill the spare before the round closes. A new session that finds the
port down boots it again — the standing state in this file is the
authority, not whatever the last process left behind. The checkers'
status page at `/status` re-runs the gate live on every visit.

## Comprehensive Housekeeping Protocol (The RIF Loop)

This protocol is fragmented across several system rules. **You must execute every step of this loop per round, not at the end of the session.** Unnamed git state is invisible to dan; if you do not do this, he cannot see your work.

1. **Implement & Verify**: Make your changes and ensure the suite is 100% green (see below).
2. **Commit**: Leave the tree clean. Commit with an intention-revealing message. (Push only when dan says so).
3. **Update `PROJECT.md`**: Update `status`, `last_touched`, and advance the `next_step` to the current phase.
4. **Validate `PROJECT.md` YAML**: The dashboard fails silently if the YAML is invalid (like unquoted colon-spaces). You MUST verify the frontmatter parses:
   `ruby -ryaml -e 'YAML.safe_load(File.read("PROJECT.md")[/\A---\n(.*?)\n---/m, 1], permitted_classes: [Date])'`
5. **Update the Roadmap**: Record your findings, decisions, and any phase completions in the active `ROADMAP-*.md` document.
6. **Update `working-with-dan.md`**: If the round taught you *anything* about working with dan (his preferences, tells, strictures), update the agent manual.
7. **Record Lore**: POST what you *learned* (not just what you did) to the ecosystem's memory: 
   `curl -X POST http://127.0.0.1:4000/api/lore/alt-slim-pickins -H 'Content-Type: application/json' -d '{"message":"...", "who":"Antigravity"}'`
8. **Report to Journal**: POST a brief status update to the machine API:
   `curl -X POST http://127.0.0.1:4000/api/journal -H 'Content-Type: application/json' -d '{"message":"..."}'`

## How this project works

- **Verify before asserting.** Never state a count without measuring it and
  saying what it covered.
- **Checkers are not enough — look.** Eleven 0.1 defects passed every checker.
  `ruby bin/demo.rb specimen` builds a standalone page; `ruby examples/roth/app.rb`
  serves the port on 4577.
- **Nor are happy-path tests.** `test/combination_test.rb` crosses words that
  hold state; extend it for anything that gathers, binds, or shifts.
- **The byte-diff harness is the acceptance test for refactors.** Snapshot all
  eleven pages (repo pages + both apps' views), `git stash` the refactor,
  render before and after, `diff -r` — byte-identical is the whole argument.
  The snapshot script's shape is recreated per session; the pages are
  `pages/*.sp` (via `Fixtures.for`), `examples/portfolio/views/*` (with the
  `video` AppWord), `examples/roth/views/*` (via `Scenario.defaults` +
  `Projection.of`).
- **Everything green before committing:**
  `ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/check_promises.rb && ruby bin/check_conventions.rb && ruby bin/check_card.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby $f; done`
  (re-measured 2026-09-17, at the close of DAYTRIP-0.3.0b, again after the
  register's reference shape, and again at Win 11: **339 runs / 3,753
  assertions / 0 failures across 29 test files**, per-file exit codes all 0 —
  the dashboard's harness over the same files is the stronger run and worth
  doing too: `ruby
  -Ilib:test -e 'Dir["test/**/*_test.rb"].each { |f| require "./#{f}" }'`
  — plus 807 sentences / 0 problems, 96 rules / 0 problems, 64 words and
  all 64 used in real pages / 0 problems, **18 pages verified** (every UI's
  pages now, not only the classic UI's), 25
  affordances / 0 missing, 32 promises and **none without a reader**, 38
  conventions / 0 problems, 39 words declaring the conventions they trigger;
  the 13-page count retired with the paper
  pages, the 69-word count with Phase 6's cuts)
  **The three instruments DAYTRIP-0.3.0b landed:** `check_promises.rb` (the
  promise ledger — does a permission actually do anything?), `check_conventions.rb`
  (the convention register — what will this do when I stay silent, and who
  decided?) and `check_card.rb` (this file's sibling `PROJECT.md`, whose
  frontmatter a colon-space broke four times while the checker was a human
  remembering — and a fifth time on the day it landed, when the agent
  committed after reading a piped summary instead of the exit code). All are
  green in the gate; `bin/check_promises.rb --strict`
  fails on a promise with no reader, and today there is none.
  **Read the exit codes, not a summary of them.** `cmd | tail -2` prints the
  *pipeline's* status — the last command's — so a red leg reads as green, and
  this has bitten twice in one session. Run the legs as a conjunction
  (`a && b && c`), or check each one's status, and look at the whole output
  before committing: an instrument that reports into a pipe nobody reads is a
  decoration.
  **Set no environment variable to make this pass.** It used to need
  `RACK_ENV=test`, which switched the prettifier off and made every rendering
  test assert HTML production never emitted. If the suite only passes with
  something exported, that is the bug, not the workaround.
- **The cost, re-measured**: `ruby bin/measure_cost.rb` — the instrument;
  the numbers live in ROADMAP-0.2.md Phase 3's record.
- Report honestly: failures verbatim, limits named, no claim of green that isn't.

## Standing principles — do not break without saying so

- One sentence: `word arguments`, indentation nests it. Extending the language
  adds vocabulary, never syntax. A dot means data; a bare word is language.
  There is no numeric literal. A name is a subject and must exist. Mechanical
  facts are free; judgements belong to the app. A line that states the
  inferable should not exist. This is a noun language — 45 of 50.
- **Every truth has one home** (the grammar in Transform, the vocabulary in
  contracts, the checkers consuming, never mirroring).
- **A rule must outlive its reason** — when a proscription blocks empowerment
  *and* better code, examine its foundation; it survives only if the
  foundation is worth more than what it blocks.
- **Word, or power?** — for every candidate surface, the language grows by
  words; the surface grows only when the answer is honestly "power."
- **The dogfood is enforced**: built-ins and app words eat the same food, by
  test, and the gatherers are re-provable as app words, byte for byte.

## Three caveats to carry

**The escape-hatch number is retired.** It measured where rendering happened,
never the vocabulary's coverage. Stop quoting it.

**`~/dev/dashboard` must keep working, untouched.** It is the tool that runs
everything else in `~/dev`, and nothing this project does is worth breaking it.

**`~/dev/roth` is a separate, dormant project and has not been touched.** Its
working tree has been mid-rename since 2025-09-11; `examples/roth` pins the
new spelling and raises if it is reverted. roth's defects are catalogued in
`ROTH_STUDY.md` and `ROTH_DOMAIN_BACKLOG.md` — deliberately not this project's
work.
