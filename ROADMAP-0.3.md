# alt-slim-pickins — roadmap 0.3

**An odd-numbered roadmap. It leads with the forward eye.**

Status: **draft for dan — 2026-09-14, enriched and challenged on his word.**
The question is the load-bearing sentence; the phases are the proposal, and
they move when the work says so.

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
> *Walk like the chameleon: watch what is ahead, glance back at what is behind.*

Both eyes stay open; the number says which one leads. 0.1 asked whether a view
language could keep one sentence all the way down, and answered it — fifty-three
words, two apps, no grammar changes. 0.2 asked whether what was built deserved
to stand, and answered it — the grammar and the vocabulary stand, the Builder
was reshaped, and six phases of subtraction closed. 0.3 asks the next thing the
project cannot yet answer.

## The question

> **Can the language carry real work — a garden of real apps grown in it, the
> studio won iteratively into the workbench that builds them, and the kernel
> lowered only as the work demands?**

Three legs, one question — dan's rulings of 2026-09-14, verbatim where they
matter: *"All three, in one question"*, then *"make the roadmap a bit
richer"*, then the challenges this draft answers: the studio advances by
winnable victories, the dashboard is not canonized, and the kernel's work
waits on the demand ledger.

### Leg 1 — the garden of apps: the evidence

The standing row in 0.2's risk register was: **nobody outside the project has
written a page.** One stranger's page would test the language's guessability
once; dan broadened it (2026-09-14): a variety of real apps, doing interesting
things, spun up in the language. The judge leg is plural: every app is pages
written by hands that must make the language say something real, and the
ledger discipline from Phase 4 survives — every refusal logged with the
sentence that hit it. At least one app is built by hands that did not write
the vocabulary, and the record names which; a garden that shares one brain is
decoration.

The page is where the claim lives:

```
section holdings
  empty "No holdings yet."
  each holding
    money .market_value
```

**One bed in the garden, not a sacred one: the dashboard's markdown.** dan's
audit of this draft (2026-09-14): much of the dashboard is full of kludges,
and its views were deliberately never rewritten in slim-pickins — precisely to
avoid being sidetracked by dashboard maintenance and re-engineering. Verified
against the tree the same day: slim-pickins' entire effect on `~/dev/dashboard`
is two `require`s of its pure-Ruby lib (`examples/dashboard/app.rb`,
`bin/verify_pages.rb`); nothing is ever written, no view has been touched, and
the only planned interaction is rendering its markdown docs **read-only** — a
cheap, valuable dogfood item, not yet built. The boundary is scope, not
sanctity: we do not maintain the dashboard, we do not rewrite its views, we do
not fix its kludges, and we walk normally — no eggshells. Its markdown is one
demand among the garden's many.

### Leg 2 — the studio: the workbench, won iteratively

The studio is the language's own surface, and its in-between state is
measured, not imagined (read 2026-09-14): the playground receives only the
editor's source — its own guide route names the wall: "`/render` receives only
the editor's `source`, so a page saying `prose markdown, .content` arrives with
no content to read" — so a real page with real data cannot be written or
tested there; the playground's errors are hand-built HTML strings with inline
styles, where everywhere else in the language errors speak the language's own
terms; the two Render buttons exist because one form can only target one
iframe natively — the deliberate Stimulus burr, which dan ruled stays until
its recorded resolution arrives; and the default source is a hardcoded "Hello
World". dan's method for fixing it (2026-09-14): an iterative process
accumulating **winnable victories** — each round scopes the next small win,
lands it, and moves on. No grand scoping gate; the scoping *is* the iteration.
The studio is also the first garden app: improving it is dogfood at the
sharpest, because the workbench is built in the thing it builds with.

### Leg 3 — the kernel: the floor, lowered only by demand

[KERNEL.md](KERNEL.md) asked the Rubinius question: what stays Ruby because
the language *cannot* say it, and what stays because nobody has moved it yet?
Its keystone — name-directed data access — pins `field`, `checkbox`, `choice`
and their kin to Ruby, and nothing in it has been built. The spec was
re-measured against the current tree (2026-09-14, recorded in its addendum):
the census is 42 Ruby / 22 `.sp` / 64 total; the claims that hold were
verified one by one; the floor list retires `meta` and `icon` with Phase 6;
the cost has climbed (warm render 3.55 → 4.73 ms, per row 0.15 → 0.22 ms); and
the word-graph tool the spec advertises is broken — its template was never
committed. The kernel's work waits: it grows only what the garden's and the
dashboard's sentences demand, after the studio's victories, against a budget
dan sets before the work begins.

### Why the three bind

Evidence without a workbench is friction: every garden app is built through
the studio, or the studio phase was wrong. A workbench without work is a toy:
the studio's victories are judged by the garden using them. Kernel work
without a demand is the 0.2 disease — building what nothing asked for: the
kernel moves only when a real sentence from the garden or the dashboard names
what it cannot say. Each leg keeps the other two honest.

## What the re-read taught

The protocol: an odd roadmap still re-reads the history and the lore before it
chooses a direction. The pass, and what it yielded:

- **The durable asset is not the HTML** (0.1's close-out). A `.sp` file is a
  parsed, checkable description of what a page means, and 0.1 spent it entirely
  on emitting HTML. The description is what a read-only dashboard renderer
  would consume.
- **The grammar and the vocabulary stand** (0.2's verdict), and so does the
  discipline: every word has seven slots, every truth one home, nothing
  verified by a checker alone.
- **Real pages find real gaps** (Phase 4). The exam's ledger G1–G13 was found
  by porting one real page, and every gap was settled as a word or a power,
  never guessed.
- **Everything must have a consumer or go** (Phase 6). Subtraction is the same
  discipline the kernel leg needs, pointed forward instead of back.
- **The kernel's spec holds up under re-measurement** (KERNEL.md's addendum,
  2026-09-14). Its warnings hold too: the cost is compounding, and the budget
  is a decision, not a surprise.
- **The council's proposals wait for consumers** (the bulletin board,
  2026-09-10). Payload forwarding in partials, subject-shifting `card`, one
  form with `formaction` buttons. Each is carried in here, and each lands only
  when a real sentence demands it. The council's fourth proposal — the
  dangling `design_conventions` guide — is already resolved (verified
  2026-09-14) and is recorded here so it is not re-proposed.
- **Untracked files rot into broken tools** (lore, twice). The word-graph
  tool's template was never committed and is gone; a repair embeds the
  template in the tool, and it earns its round only when a consumer asks for
  the picture.

## What dan asked to carry in

| Asked | Lands in |
|---|---|
| "All three, in one question" (2026-09-14) | the shape of this document |
| "Make the roadmap a bit richer" — a studio phase, a garden of apps in place of one stranger, the council's recommendations on the route (2026-09-14) | Legs 1–3; the phases |
| "Scoping and implementing changes to the studio as an iterative process accumulating winnable victories" (2026-09-14) | Leg 2; Phase 0 |
| "Do not canonize the dashboard — much of it is full of kludges; sp's only effect is reading its lib and the planned read-only markdown" (2026-09-14) | Leg 1; Phase 2 |
| "KERNEL.md may be dated — refresh it, and recommend whether kernel work precedes or follows the studio" (2026-09-14) | KERNEL.md's addendum; Phase 3's ordering — the recommendation is **studio first** |
| "Both the dashboard's md docs and the studio's md docs" (2026-09-09) | Leg 1's one bed; Phase 2 |
| The council's R3 proposals, demand-gated | Phase 3 |
| The Stimulus burr's resolution, when it comes | Phase 0 |

## The phases

The shape of a phase here is the one 0.2 proved: a goal, a ledger of what was
found, and a *done looks like* that can be verified. Every phase ends green,
committed, and recorded — the RIF loop, no exceptions.

### Phase 0 — The studio, won iteratively

No grand scoping gate; the iteration is the scoping. Each round picks the
next **winnable victory** from the measured menu — the playground learning to
serve real pages with real data, errors speaking the language's own terms
instead of hand-built strings, the editor growing a palette of the repo's own
pages (landed 2026-09-15, with its census — the wins below), the Stimulus resolution that obviates the second Render button (with
its *why* preserved beside the fix), the word-graph repair if a consumer asks
for the picture — scopes it to the size one round can land, dan rules the
pick, and the round lands it. Roughness that stays is named as deliberate.

*Done looks like:* a sequence of landed wins, each committed and judged, and
a studio that can be *used* — the workbench the garden phase leans on.

**Wins landed, 2026-09-15:**

- **1 — The palette, with its census** (dan's pick, same day, while the
  identities stay "strategically in flux"): the editor now offers the repo's
  own pages as starting points — thirteen of them, across portfolio,
  dashboard, roth and the studio itself — each a plain link that fills the
  editor (zero JavaScript; the load is a GET), the loaded page marked
  `aria-current` and named in the editor's heading. The palette carries the
  census as it loads: every entry wears the verdict of the same render the
  playground will give it, run live at page build, the refusal recorded in
  the language's own words with path and line. Completeness is held by test
  — a census that skips pages understates the demand. The first census:
  **13 of 13 pages refuse, and every refusal is the data wall** — no
  portfolio, no notice, no scenario, no title — because every real page
  reads its data before it reads its partials, so the missing-app-partials
  wall stays masked behind the first missing local. **W1 (2026-09-17) closed
  the gap between this census and the load:** it measured the empty-data
  render while the palette pre-filled each page's payload, so all 18 entries
  wore `error` and all 18 rendered once clicked. The census now runs the
  load's own path and reads 18 of 18 `ok`; this paragraph stands as the first
  measurement, which was right about the data wall and wrong about what a
  visitor would see. The next pick's ledger,
  in what the census named, in order: the data wall (the one wall all
  thirteen share), the partial wall (masked behind it), errors in the
  language's own terms (the `/render` route's refusals still display as
  hand-built strings), and one found gap carried in — `bin/verify_pages.rb`
  proves the example apps but never the studio's own views, the only corpus
  pages the gate does not render.

- **2 — The word docs grow teeth** (dan's pick, 2026-09-15; the identity
  instrument's harmony row, landing): every vocabulary entry now carries an
  *"In the wild"* section — up to three real sentences from the repo's own
  corpus, each in the language's fence with its `path:line` — and a **try-it
  pane** beside the reading: the same editor, form and outputs the
  playground uses, Visual and HTML side by side, seeded by a Try-it link on
  each example (a GET, zero JavaScript). All sixty-four words have real
  examples — held by test against VOCABULARY.md. Seeded pages carry no data:
  content sentences render live, data sentences refuse — `money .total_value`
  answers "this page has no total_value" — so the docs page now *displays*
  the data wall at the exact place the word is documented. That refusal,
  rendered through the `/render` route's hand-built error string, is the
  next pick's demand, with a consumer standing on the page.

- **3 — The data wall, with refusals in the language's own voice** (dan's
  pick, 2026-09-15, the pairing the win-2 record named): the editor gained a
  **data slot** — JSON, parsed and bound as the page's locals, plain hashes
  and arrays, app-level seam, no kernel motion — and the playground's
  refusals now render as a page the language itself drew: a *"Refusal"*
  page whose complaint is the error's own first line, with the location and
  the offending sentence in the language's fence when the error knows them.
  The money seed renders live with `{"total_value": 120}`; without data it
  refuses in the one voice every other refusal uses. One hand-built string
  survives, and only for the refusal page failing — which must not be able
  to break the studio. The `each holding` teaching survives the wall: the
  refusal ("this page has no holdings to go through") now names the plural
  key the JSON must carry. The census is unchanged and still honest — its
  verdicts are "renders with no data", and the palette keeps saying so.
  **Overtaken by W1 (2026-09-17):** the verdicts were honest about a render no
  visitor ever saw. The census now measures the load's own render — payload and
  all — and reads 18 of 18 `ok`; the record above stands as what was true on
  the day it was measured.
  Next in the ledger: the partial wall (a loaded page's own partials are
  not in the playground's library), the Stimulus burr's resolution, the
  found verify_pages gap, and the `snippet` word's dead Copy button.

- **4 — The partial wall** (dan's pick, 2026-09-15): the playground's
  library now merges the studio's furniture with every example app's
  partials — a loaded page and its data render end-to-end; the dashboard's
  `triage` renders inside the playground from a JSON payload, card, badge
  and action forms included. A partial name shared by two apps refuses
  loudly at the merge, by test, rather than rendering one app's word in
  another's place; `pages/partials` stays out (its one file is the cost
  instrument's fixture). The census was re-run against the merged library
  and its verdicts did not move — measured proof that the partial wall was
  fully masked behind the data wall, exactly as the win-1 census said.
  Registering the app partials globally exposed a real leak: the docs
  sidebar read the live registry, so app words would have appeared as
  vocabulary — the sidebar and the docs payloads now read the language's
  one home (VOCABULARY.md, the same scan check_grammar uses), which makes
  them pollution-proof for every future garden app, by test. A found gap
  carried in: `pages/*.sp` (the repo's own demo pages) are not in the
  palette — the palette promised examples + studio, and the test pins that
  promise, but the garden's census would want them.

- **5 — The docs deepen: context and the apps' own payloads** (dan's
  request, 2026-09-15, "so far, so good, but a bit shallow"): each *"In the
  wild"* example now shows the word in its real home — the page's own
  opening, the load-bearing page line (the subject's home) and the path
  down to the sentence, indented as sourced — and the Try-it seeds the
  **same block verbatim**, so the try-it always shows the word working in
  its surroundings. The data slot arrives pre-filled from a **data
  ledger**: one provider per corpus page, serving the same locals the
  page's own app proves it with — `Fixtures.for` for the repo's pages,
  `Fixtures.portfolio` for portfolio, roth's scenario values and its
  projection serialized field-by-field (its JSON-endpoint `to_h` is not
  the page's shape — the fields are named and held by a render test), and
  a stable sample first_item for the dashboard (dan's ruling: the docs
  teach a stable shape, so the sandbox answers stable rather than live).
  A recursive plainify (Struct → hash, Date → iso8601) turns payloads into
  the slot's JSON; the ledger's render test round-trips every payload
  through the slot and renders its page — it caught three wrong provider
  shapes on the day it landed. Partial-internal examples (`heading` inside
  `card`) stay honest: context shown, payload empty, the refusal teaches.
  The sandbox is the apps themselves, required not copied — their boot
  gates prove the pages with these very locals. Carried in: the registry
  is last-compile-wins, so in a shared process another library's poisoned
  `test_account_card` can shadow the real file — the studio's own boot
  owns its registry; the test rebuilds the library at use time to mirror
  that, and the language-level answer (per-library word resolution) waits
  for a phase that can size it.

- **6 — The try-it yield, measured and fixed** (dan's audit, 2026-09-15:
  "sample the outputs of each word's Try me and observe that some provide
  useful output but many (most?) do not"): the audit measured all
  sixty-four seeds — **34 useful / 16 rendered-empty / 14 refused**. The
  causes were structural, and each was fixed: the context now includes the
  word's own *body* (an enclosing word's demonstration is its body) and,
  for registering words, up to three sibling co-registrations (a `total`
  is nothing without its columns); examples rank page-rooted,
  payload-backed homes first, and seed and data share one ranking so they
  can never come from different examples; ledger-less examples get
  **synthesized payloads** — the chain refs their context reads, answered
  with plain defaults, `name` nil by construction (a truthy name turns an
  enclosing `box` into a leaf — the generator's body-over-children rule);
  the dashboard base and the studio pages joined the ledger; and the two
  words whose whole meaning is machinery — `contents`, `children` — now
  say so honestly with no dead link. Two words that show themselves only
  under data the pre-fill does not carry (`empty`, `otherwise`) keep their
  links beside a note that says how to see them. The audit is now the
  acceptance test (`test/studio_try_test.rb`), pinning every word's
  verdict and needle: **62 useful / 2 structural / 2 noted / 0 refusals**,
  and the suite re-measures it every round.

- **7 — The Stimulus burr, resolved live** (dan's rulings, 2026-09-15: the
  hatch word; Stimulus vendored and pinned; **live, debounced** — the
  bolder trigger). The two Render buttons are one; the editor renders as
  you type (300 ms debounce) and once on load, so a seeded page appears
  the moment its page does. The architecture: a vendored
  `@hotwired/stimulus@3.2.2` UMD (no build step — the repo has none and
  keeps having none), one `render` controller, and a studio app word
  `wired_form` — written in Ruby through the escape hatch, because the
  language's contracts cannot say `data-*` attributes; the fields it
  encloses stay pure language, and the iframes are reached by the names
  the language already emits. One fetch to the new `/render.json` —
  `{ visual, source }`, refusals included — writes both panes; the form's
  native action stays `/render`, so without JavaScript the visual pane
  still renders, the old behavior, honestly. The burr's *why* is recorded
  beside the fix in `editor_form.sp`, as the risk register demands. The
  contract is the studio's first client API — a future pane joins as a
  key, not a change — and the trigger is one `data-action` away from any
  future shape. Two founds along the way: the generator's `:tag` merge
  read the symbol `:class` while raw-tag authors were documented with it,
  and double-counted `app_class` and the wrapper's copy of it — fixed with
  a one-token dedupe, named in the commit; and `->` in `data-action`
  escapes in raw markup but the DOM decodes it, so the wiring is correct
  by construction. Two dan-ruled completions, same day: the raw-HTML
  pane's tidy monospace wrapper moved *into the contract* (the `source`
  value is the pane's whole page — a pane's presentation is part of its
  payload, or the first pane to stop using the shared route loses it);
  and the Render button was cut — live rendering made it redundant, and
  what a change makes redundant gets cut. Rendering now requires
  JavaScript, and the studio says so rather than hides it.

- **8 — The verify_pages gap, closed** (dan's pick, 2026-09-15): the
  studio's own four pages joined the gate with the shapes their routes
  serve — `index` with the live palette census, `docs` with a canned
  word, `guide` with a document, and `status` against **canned results**:
  its route shells this very gate, so proving it with live results would
  recurse — the hazard is named in the script, and the shape is the same
  one `studio_docs_test` pins. The gate that claims green now sees every
  corpus page: 14 pages verified, 0 problems — and the studio's own
  status page says so live, in under a second. The refusal template stays
  out, as the palette's completeness test names it: a template, not a
  page.

- **9 — The snippet word's dead Copy button, subtracted** (dan's ruling,
  2026-09-15, "subtract it"): the button went everywhere at once — the
  generator stopped emitting it and the `.snippet-copy` rule went with it
  (check_styles counts the removal: 95 rules → 94, no orphan). The scoping
  named why wiring was never the answer: the button's two homes are the
  docs page's own fences (wireable) and the try-it's rendered iframes
  (their documents carry no scripts by design) — the word cannot know
  which context it renders into, so "wired" could only mean half-wired or
  output contaminated with studio chrome, and the try-it's whole point is
  the language's pure output. A fence's text is natively selectable,
  which is the affordance the button pretended to be; the vocabulary is
  one button simpler.

- **10 — The repo's own pages joined the palette** (dan's ruling,
  2026-09-15): `pages/*.sp` — specimen, portfolio_table, account_detail,
  roth_form and the test_account_card partial — entered the palette, 13
  entries becoming 18, with specimen leading (it is the whole vocabulary
  on one page). The census's completeness test widened to `pages/`, and
  the pages already had ledger providers from the deepening, so loading
  one pre-fills its data — the found gap from win 4 is closed, and the
  palette's census now covers every page in the repo, layouts excepted.

**Standing state (2026-09-15):** the ledger is empty — ten wins landed,
committed and green, the housekeeping at end-of-phase standard. dan's
judgment on the phase is pending: before ruling it, he scopes the
studio's next change — its *playground identity and functionality* (his
words) — so the phase stays open and the wins list keeps growing.

### The session-start record (2026-09-16) — findings, no code motion

An orientation round: a fresh session read the project, re-measured it, and
wrote down what it found. **Nothing was fixed** — dan's ruling on receipt of
this list was "record your findings where the next session will find them, and
then back to Phase 0 to scope the playground improvements" — so every item
below is ledger evidence, not a work order. The gate is green at `095609b`:
705 sentences, 64 words (all 64 used), 94 rules, 14 pages, 295 runs / 0
failures one-process, 25 affordances / 0 missing.

**The cost moved again** (`bin/measure_cost.rb`, ruby 4.0.1, `specimen.sp`,
200 runs): cold **7.71 ms**, warm **5.65 ms**, **0.26 ms/row** — against
KERNEL.md's 2026-09-14 addendum of 6.38 / 4.73 / 0.22. The composition tax is
compounding faster than the feature work pauses, and Phase 3's budget decision
has no current number under it.

**The findings, worst first.** Three of them are the same failure in different
clothes: *a name and its consumer parted company, and nothing noticed* — a
permission without a mechanism, a claim without the path it claims, a loader
with nothing to load.

- **F1 — `if:` is documented and unimplemented.** `lib/slim_pickins/contracts.rb:16`
  is the only mention of it in `lib/`; no code consults it. Live: `note
  "MARKER", if: .show` renders the marker identically with `show` false and
  true. The gate *permits* it (`contracts.rb:242` whitelists `%i[if class id]`),
  so `check_grammar` is silent, and the one test that names it
  (`test/contracts_test.rb:98`) asserts only that the gate permits it. It is
  documented as working in DESIGN.md:200,265,283, VOCABULARY.md:52-55 and
  PRIMER.md:209, and LORE.md's 81%-of-branches measurement leans on it. A page
  saying `button primary, "Add to cart", if: .in_stock?` gets an unconditional
  button and no complaint. **Consumer named:** DESIGN.md's own guessability
  fences. A contract that says "allowed" is not a mechanism that says "works".
- **F2 — the palette's census measures a render the playground never gives.**
  All 18 entries wear `error`; all 18 render once loaded, because the load
  pre-fills the ledger payload the census omits (`StudioPages.entries` calls
  `playground_locals` with no data; the `/?load=` path calls
  `data_json_for`). Measured entry by entry: 18 of 18 render with their own
  payload, and `pages/specimen`'s badge says "this page has no specimen" while
  loading it renders. Win 1's recorded claim — "the verdict of the same render
  the playground will give it" — was never true. **This is scoping candidate
  W1 below, and it was landed 2026-09-17** — the census now measures the load's
  render and reads 18 of 18 `ok`.
- **F3 — there is no boolean literal, so `false` means true.** `Transform`'s
  `NAME` pattern matches bare `true`/`false`/`nil`, so they arrive as the
  symbols `:true`/`:false`, both truthy. Live: `field name, required: false`
  emits `required="required"`; `tab "A", active: false` marks the tab active.
  **Resolved 2026-09-17 (E3)** — a boolean literal in modifier position; the
  finding stays as the record of what was true on the day it was measured.
  The corpus survives by luck — it writes only `active: true` and
  `required: true` (studio/views/index.sp:10, editor_form.sp:10,
  confirm_archive.sp:7), and data-driven modifiers use real booleans
  (`.here`, `.open`). Flagged by the 2026-09-10 swarm (`auditor_2`,
  `challenger_3/4`, `worker_2`, `explorer_remediation_2`) and never recorded
  here. Same root as F1: `if: false` could not be spoken even if the guard
  existed.
- **F4 — the word census in the prose is stale.** The measured count is 64
  (42 Ruby classes + 22 `.sp`). README.md:5,103, DESIGN.md:6,302 and
  PRIMER.md:21,125,367 say *fifty-three*; VOCABULARY.md:3 says *"Fifty words"*;
  check_shape.rb:7 says *"(45 of 50)"*. README.md:5 also says "two Sinatra
  apps" (three example apps plus the studio). HANDOFF.md:45 says "six wins have
  landed" and then enumerates ten. No checker holds prose numbers — they hold
  fenced sentences and generated bullets — so these rot in place.
- **F5 — dead machinery and committed cruft.** `lib/slim_pickins/contracts.rb:49-80`
  (`PrimitiveShapes` / `PRIMITIVES`) is dead and **provably empty**
  (`SlimPickins::PRIMITIVES == {}`), superseded when `words.rb` moved from
  `# key: value` comment preambles to the `contract` macro — yet its comment
  still calls itself "the primitives' home", and nothing else references it.
  **Disposed 2026-09-17:** the promise ledger found it and dan ruled it deleted;
  the finding below is the record, not the state. The rest of F5 — the leftover
  probe in `builder.rb:62-65` that `puts`es instead
  of raising for `tabs`; three `def ___dummy` stubs (`words.rb:156,278,489`);
  and unindented method bodies across `words.rb`, `word.rb:13-21`,
  `compilation.rb:22-46`, `partial_word.rb`, `library.rb`, `generator.rb`, all
  from the 2026-09-05 unification — stands. The project's own constraint 2 says
  it must stay lovely to read, and no checker reads formatting.
- **F6 — comments describing superseded states.** `studio/views/partials/try_it.sp:1-5`
  still says the two Render buttons are deliberate and that the burr's
  resolution "when it lands" will obviate them; win 7 landed it and cut them,
  and editor_form.sp was updated while this file was not. `markdown.rb:166-167`
  says table alignment colons are "recognised but not rendered" while
  lines 178-189 render `align="…"`, and Phase 6 records the native support as
  landed.
- **F7 — records that contradict themselves.** `VOCABULARY.md` breaks its own
  rule 1 ("No blank slots") in 14 tail entries — `action`, `flash`, `search`,
  `children`, `paragraph`, `box`, `heading`, `span`, `figcaption`, `summary`,
  `iframe`, `tabs`, `tab`, `scroll` omit `infers` and `renders`. `:501` still
  says "and `icon` draws each" (`icon` was cut in Phase 6 and exists nowhere);
  `:420` says `heading` "has been cut" while `:1117` documents it as live;
  `:1051`'s "What the drafts left open" self-answers, flagged in 0.2 Phase 0.
  `bin/word_graph.rb` is broken (`LoadError: bin/word_graph_template`, never
  committed — KERNEL.md names it). `.agents/worker_1/report.md` still carries
  the fabricated evidence a swarm auditor vetoed: a record that lies, kept.
  ROADMAP-0.2's Phase 6 heading carries no closure mark though Round E and
  PROJECT.md both treat it as closed.

### The scoping (2026-09-16) — three wins parked, and the bluesky brief

Phase 0's original roughness list is fully retired: the playground serves real
pages with real data, its refusals speak the language, the partial wall is
gone, the Stimulus burr is resolved, and the default source is no longer a
hardcoded greeting. So the next scope cannot be read off the original audit; it
comes from what the work now shows.

**dan's ruling on receipt (2026-09-16):** *"Record these very worthy proposed
wins for later; and then let's do some creative scoping."* The three wins are
therefore **parked, not picked** — each keeps its consumer, its size and its
done-looks-like, and any of them may be taken up when a round wants it. The
scoping that follows them is the bluesky brief, recorded below and worked out
in [BLUESKY.md](BLUESKY.md).

**W1 — the census tells the truth about the render you get.** *Landed
2026-09-17.* Run the census
through the same path the load takes, payload and all:
`StudioPages.entries` measures `playground_locals(StudioPages.data_json_for(rel))`
instead of the empty-data locals. Eighteen `error` badges become their true
verdicts, and the badge's promise changes with them — from "renders with no
data" to "renders when you load it", which is the render the writer actually
meets. *Consumer:* every writer who reads the palette, and win 1's own recorded
claim. *Sized:* one line of the census, the completeness test's promise
restated, and the win-1 record corrected in place. *Done looks like:* the
palette's verdicts equal the load-time renders, pinned by a test that re-runs
both paths; the refusal record shrinks to the pages that genuinely refuse with
their own payload, and any that do are named as the demand.

**W2 — `/status` runs the gate HANDOFF names.** The page's whole claim is that
it cannot report a green the repo does not have, but its four legs are the four
checkers: the test suite — 295 runs, the leg HANDOFF's standing command
includes — is not among them, so the page can say "All 4 legs green" over a red
suite. *Consumer:* the page's own claim, and every reader who trusts it.
*Sized:* one leg added (`ruby -Ilib:test -e …`, measured 1.37 s, taking the
page from 0.89 s to ~2.3 s); parity (5.0 s, needs :4000) and the cost
instrument (3.4 s) stay out and are named as instruments rather than gate legs,
with the reason. *Done looks like:* the status page's leg list equals the gate
the project quotes, and the omission of the two instruments is stated on the
page.

**W3 — the studio shows what a page *means*, not only what it emits** *(the
bold one)*. ROADMAP-0.3's first re-read finding is that the durable asset is
not the HTML: "a `.sp` file is a parsed, checkable description of what a page
means, and 0.1 spent it entirely on emitting HTML." `SlimPickins.evaluate`
already returns that description — measured on `pages/specimen.sp`: one `page`
node, 9.4 KB of tree — but nothing in the studio can show it. `/render.json`
gains a `tree` key and the playground a third pane beside Visual and HTML,
which is the join LORE's win-7 record already predicted ("a future pane joins
as a key, not a change"). *Consumer:* the roadmap's own thesis, and the reader
who wants to know what a page means rather than what it printed. *Sized:* the
largest of the three — a readable tree formatter (JSON is not a readout), a
third pane, a contract key, and a test; the presentation question (a word, or
an app word through the hatch) is the round's own design work. *Done looks
like:* the same page, the same data, three panes, and the tree pane's claim
held by a test that re-evaluates what it shows.

**Recommendation: W1, then W2, then W3.** W1 first because it is a lie in the
surface and it re-orders the ledger for free — until the census measures the
load's render, every other verdict it prints is unreadable. W2 second because
it is the cheapest honesty in the repo. W3 third because it is the boldest and
the only one that needs a design decision of its own. A fourth candidate was
considered and refused for want of a consumer: no permalink for hand-written
source, since nothing yet demands that a scratch page be shareable.

#### The bluesky brief (2026-09-16)

dan then opened the wider ground himself, in seven instructions, recorded
because the *brief* is the scoping artifact this phase has been waiting for:
record the wins for later; brainstorm before planning, with the internet's help
("use your eyes to see how other people on the internet approach the creative
and technical issues that we face"); **use your eyes** for a thorough visual
and aesthetic inventory of the studio and the playground; think of the
playground as a UI/UX IDE — "layout, landscape, and real estate that is
conducive to fruitful creative work"; and two questions to think with, keeping
simplicity and elegance foremost —

- **the style language:** "sp works preferentially through html and css. We
  need to bring to visual design a dsl of style, a language for human beings
  to fluently describe the styling of the ui/ux they create with sp without
  having to speak the machine code of css. What might this mean and what might
  this look like?"
- **the magic:** "In sp, we lean into inference and convention because these
  are what enable language to be magical. Language achieves intent because of
  convention and that is magical. What might this mean for sp?"

**Worked out in [BLUESKY.md](BLUESKY.md)** — the measured landscape, the
workbench reading, four candidate shapes for a style language with the one to
refuse, the four grades of inference and the missing fourth, and what the
studio would have to be able to show. It is head work: nothing in it is
scheduled, and its own limits are named in its Part 5. Its two load-bearing
observations, for a reader who reads nothing else: the language has **64 words
for *what* and 53 theme roles for *how it looks*, and no way to say one in
terms of the other**; and the local-styling gap is already filled — by an
undesigned escape, `tag span, style: "color: red"`, which a page can say today
and no checker refuses.

### Phase 1 — The garden, planted

A variety of small real apps, each doing an interesting thing, each exercising
a different region of the vocabulary, each with a consumer named. dan rules
which apps; the seeds already in the repo are the candidates: the word graph
drawn in the language (KERNEL.md's spec, after the kernel rounds it names), a
lore reader over LORE.md, an exam on the Way itself, a planner with the
conditional vocabulary a real page still owes. Every author works through the
studio — the workbench pays for itself here or it was the wrong phase — and
every refusal, crash and workaround is logged as a gap with the sentence that
hit it. Nothing is fixed mid-write; the fixes wait for Phase 3, where they
earn their place against the other legs' demand. At least one app is built by
hands that did not write the vocabulary, and the record names which.

*Done looks like:* the garden renders — N apps, each named with its consumer
and its region — and the ledger names every gap with its sentence.

### Phase 2 — Measure the demand

The garden's ledger is the spine. Beside it, one inventory item, kept at its
true size: the dashboard's markdown surfaces (`brief`, `doc`, `pattern`) are
read the way Phase 4 read `triage.slim` — what prose must render, what
navigation they assume — and a read-only rendering experiment, in this
repository, consuming the dashboard's real files, proves which of the
garden's gaps the ecosystem actually demands. The dashboard stays untouched
because maintaining it is not this project's work — not because it is holy.

*Done looks like:* the merged demand, named sentence by sentence — garden
gaps and dashboard gaps side by side, each with its consumer.

### Phase 3 — Grow only what the demand named

Each gap is settled as a word or a power — the standing question — and each
landing names its consumer from Phase 1 or Phase 2. The kernel leg moves only
what a real sentence demanded: name-directed access if the ledgers say so,
payload forwarding if a real form needs keys it cannot declare, and nothing
that they did not. **The council's recommendations lie here, demand-gated**:
R3P1 (payload forwarding) if a real form demands it; R3P2 (subject-shifting
`card`) if a real page writes the same binding five times; R3P3 (`formaction`
groups) if a real action group wants one form instead of four. KERNEL.md's
cost budget is dan's, set here before the work begins — the baseline is the
**latest** re-measurement, not this draft's: 2026-09-14 read 4.73 ms warm and
0.22 ms per row, and 2026-09-16 reads **5.65 ms warm and 0.26 ms per row**
(`bin/measure_cost.rb`, recorded in Phase 0's session-start section). Re-run
the instrument on the day the budget is set; a baseline quoted from this
document will be older than the tree — and the byte-diff harness is the
acceptance test for anything that touches rendering.

*Done looks like:* the merged ledger closed or explicitly kept open, cost
re-measured against the budget, suite and byte-diffs green.

### Phase 4 — Serve, and be judged

The garden renders with 0 missing affordances; the dashboard's markdown, if
the demand was real, renders read-only through the language; dan judges all
of it. The record names what the language still cannot say — the honest
limits a forward eye exists to find.

*Done looks like:* the question answered — yes, with the gaps logged; or no,
with the walls named. Either is a result.

## The risk register

| Risk | Severity | Retired by |
|---|---|---|
| The dashboard becomes a maintenance sidetrack | high | the scope boundary, stated once: sp reads its lib and may render its markdown read-only; it never edits, never rewrites views, never fixes kludges — and no phase may add one |
| The garden shares one brain | high | at least one app by hands that did not write the vocabulary, named in the record — a fleet of self-portraits is decoration |
| The studio's victories become unbounded polish | high | each win names its consumer and its size before it starts; dan rules each pick |
| The Stimulus burr is smoothed over silently | medium | its *why* is recorded beside the fix when it goes |
| Kernel work no demand named (the 0.2 disease) | high | Phase 3 lands nothing the merged ledger did not name |
| The cost budget discovered after the work (KERNEL.md's warning) | high | dan sets it before Phase 3's work begins, against the re-measured baseline |
| A checker-only pass (eleven defects passed every checker in 0.1) | standing | look, per round: load the garden's pages and the rendered surfaces |
| The privilege leak, if `tag` becomes a kernel word | high, conditional | KERNEL.md's Round 1 discipline: refused in app pages, by test, before any word depends on it |

## How this stays accountable

The machine 0.2 ran on, unchanged: `PROJECT.md`'s `next_step` always points at
the current phase; every item has a *done looks like*; verify before asserting
— counts measured, coverage stated; look, don't only check; RIF per round —
implement, verify, commit, card, lore. The caveats stand: the escape-hatch
number stays retired, and roth's defects are roth's backlog.

## Honest limits, named now

- **The garden's apps are still chosen by the people who chose the words.**
  Every coverage claim carries that until the garden includes its outside
  author — and the record says which app that was.
- **The studio's in-between state is partly deliberate.** The burr is a
  burr; a victory that cannot tell roughness from defect has failed before
  the work begins.
- **Static validation cannot prove the app's values are right** — carried
  from 0.2: it removes silent drift, it does not bless numbers.
- **The dashboard's markdown may demand nothing new.** If Phase 2 finds the
  language already says everything the surfaces need, that is a finding, not
  a failure — the answer is "the language already could", and the roadmap
  records it and stops asking.
- **This document is a draft.** The question is the load-bearing sentence; the
  phases are the proposal, and they move when the work says so.
