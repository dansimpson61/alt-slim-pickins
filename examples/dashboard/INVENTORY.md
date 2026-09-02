# The triage port — inventory and gaps

Phase 4, the exam. The chosen view: `~/dev/dashboard/views/triage.slim`.
What the original could *do*, not what it said — the parity-plus checklist
from the Phase 7 lesson (a checkbox vanished unlogged once; nothing here may
vanish).

## What /triage can do

1. **Masthead** — `h1 Triage`, muted tagline "One project at a time, hardest
   first." inside `.sp-page.sp-page--wide` (the view's own wrapper).
2. **Notice flash** — a dismissible `.sp-flash--notice` (Stimulus
   `data-controller`), only when `notice=` is present.
3. **Unreviewed card** — when `@unreviewed > 0`: "N instruction file(s)
   awaiting judgment — hand-kept rules nobody has ruled canonical or
   legacy." + a `Review on Dispatch` button-link to `/dispatch`
   (`.sp-btn--sm.sp-btn--ghost`). Plural-aware. Absent entirely at 0.
4. **The queue** — first item only:
   - intro line `"N item(s) need attention — this is the first:"`
   - project card (`article.sp-card`): `h3.sp-card__title` = path;
     status badge (variant map: active/repaired→ok, abandoned→danger,
     dormant→pending, else neutral); stale text (`stale Nd` or
     `never committed`); purpose; `Next: …` (strong) unless `next_step == "-"`.
   - actions row (a `sp-cluster` of button-forms), each POSTing with hidden
     `path` + `return_to=/triage`:
     - **Commit** (primary) iff `dirty || zero_commits` → `/actions/commit`
     - **Set dormant** (neutral) always → `/actions/status` + hidden `status=dormant`
     - **Archive** (neutral) always → `/actions/archive` (goes to a confirm page)
     - **Skip 30d** (neutral) always → `/actions/skip`
5. **Empty state** — queue empty: `All caught up. Nothing needs attention.`
6. **Archive confirm** (reached from button 4) — h1 `Archive "<path>"?`,
   muted explanation, hidden `path`/`confirmed=1`/`reference?`/`return_to?`,
   a required labelled `textarea` for the reason, Confirm (primary submit)
   and Cancel (button-link back to `return_to`).
7. **Chrome** (the layout) — brand link; Studio/Library/Reconcile/Dispatch
   links with active-state logic (`@nav`, `@view`, `request.path_info` — for
   `/triage` *no* link is active); Ports; search form (GET `/search`, `q`
   value round-trips); an error-log card when `Workspace.recent_error` has a
   log (`details open` + `pre` + two links); fixed head title
   "~/dev — Studio & Lore".

## Gaps the port has already exposed

Numbered as found; each is either resolved in the port or left for the
vocabulary decisions to come. The port's rule: use the vocabulary where it
serves, the hatch where it doesn't, and name every hatch use here.

- **G1 — hidden inputs have no word.** The dashboard's dominant idiom is the
  minimal POST form (`form` + hidden `path`/`return_to` + button). The
  vocabulary has no `hidden` word. Port: `post_form`/`hidden` app words.
- **G2 — `form` forbids `button`.** `form`'s children are
  group/field/checkbox/choice/actions/disclosure; a bare submit button is
  inexpressible, and `actions` (its only button-shaped child) may not live in
  a form. The vocabulary's form model is declarative-fields-only; the
  dashboard's is action-buttons-only. These are two form theories and the
  language knows one.
- **G3 — the class scheme is the Generator's, not the description's.** Every
  presenting word emits alt's own classes (`button button--primary`); the
  dashboard's design system (`sp-btn sp-btn--primary`) cannot be said by any
  word. A second design system forces the hatch for *every* presenting word.
- **G4 — `card` has no title slot.** The dashboard's card is title-first
  (`h3.sp-card__title` = the project path); alt's `card` derives only an id
  from its subject and has no heading.
- **G5 — no size modifier.** `sp-btn--sm` / `sp-text-sm` / `sp-text-lg`
  variants have no word-level home.
- **G6 — no flash word.** `.sp-flash--notice` with `role="alert"` (and the
  original's Stimulus dismissal) has no word; the port builds it and drops
  the JS (dismissal is a dashboard behaviour, not this port's).
- **G7 — `page` owns the `h1` and the head title.** The head `<title>` is the
  page's heading (the original has a fixed site title), and the h1 renders
  before the layout, outside `.sp-page` — the dashboard's document order
  (nav → masthead) is inexpressible. The port accepts the order and the
  title drift; `page .archive_heading` (a dot is data) proves computed
  headings *are* expressible.
- **G8 — no bare input.** The nav search (`placeholder`, `value` round-trip,
  no label) is not a `field`; the port builds it with the hatch.
- **G9 — `link` has no active state or classes.** The nav's `--here` logic
  and muted/strong link classes have no word; the port computes state in the
  app and builds links with the hatch.
- **G10 — `textarea` has no word.** The confirm page's required reason field
  has no word (alt's `field` is an input); the port builds it with the hatch.
- **G11 — the hatch's emit-vs-value contract is a silent trap.** `tag` emits
  and returns; `element` only returns. The port's first bug used `tag` for
  nested children, and the whole nav rendered three times — every nested
  `tag` had already emitted into the page's buffer before being composed as
  a child. Nothing refuses the misuse; it renders, doubled. The vocabulary
  itself was bitten by this once (the lore records the round-4 fix); an app
  author meets it the same way, silently.

## What the port proved possible

- The public surface sufficed: the entire page is built with
  `subject`, `tag`, `element`, `emit_node`, `capture` — no `send`, no ivars.
- The grammar's dot-is-data solved a computed h1 (`page .archive_heading`).
- The layout machinery (layout + `contents`) carried the chrome and the
  `.sp-page` shell (`shell` wrapping `contents`).

~/dev/dashboard stays untouched; this port only reads its lib/ and stylesheet.

## Round C — the port, re-authored

The port is now an authored slim-pickins page: `DashboardWords` is deleted;
the queue, the unreviewed card and the dormant action are partials in
`views/partials`; `flash`, `action` and `search` live in `lib/vocabulary`;
the chrome is core words (`nav`, `link active:`, `input`, `disclosure`,
`snippet`). The parity instrument compares behaviour only — 25 affordances,
0 missing. Resolved: G1, G2, G4, G5, G8, G9, G10 (vocabulary and partials);
G3 and G7 dissolved with the re-frame (the port wears our look; our `page`
owns its own document). Remaining and named:

- **G12 — a partial cannot ask whether a modifier was said.** Every
  parameter is unconditional; `action` requires its variant at every call
  site. Optionality has no spelling yet.
- **G14 — a bare name that is also a word can never name data.** The queue
  partial's first draft said `when queue.first` — and recursed into itself,
  because `queue` was the partial's own name: a word is a real method, so
  the word answers instead. The lesson is `each item`'s, at vocabulary
  scale: data names must stay out of the word namespace. The port passes
  flat, word-free locals (`first_item`), and conditions say `.first_item`
  or the bare chain `first_item.next_line` — a bare single name compiles to
  a symbol, so it is a name, not data.
