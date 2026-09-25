# COMMUNITY BULLETIN BOARD
## The Council on `alt-slim-pickins`
### The Workbench Spatial Frontier: Numerical Units, Cascade Traceability, Selector Contracts, and Viewport Containment

---

## 1. Council Charter & Team Norms

### Orientation

`PROJECT.md` (`last_touched` 2026-09-25) is treated as authoritative over
`HANDOFF.md`, which still names "Package C: Lean & Elemental Kernel" as the
active next step — two days stale, the same HANDOFF/PROJECT.md drift
`LORE.md` already named once (2026-09-14). The topic below is `PROJECT.md`'s
actual `next_step`: resolving the four frontiers the 2026-09-25 workbench
spatial investigation identified and left for "a sidetrip in fresh session."
`LORE.md`'s four entries from that date are the starting evidence; this
council re-verified every figure against the live tree rather than
re-quoting them.

### The Council

Cast for this session, chosen because their documented expertise bears
directly on a contract between two compiled languages and the humans on
either side of it — not the full ten-person roster:

- **Sandi Metz** — single responsibility, small interfaces, code smells.
- **Avdi Grimm** — confident collaborators; trust over defensive checking.
- **Jim Weirich** — structural hierarchy; one canonical contract per
  relationship.
- **Katrina Owen** — therapeutic refactoring; small, measurable, verifiable
  steps.
- **Bret Victor** — immediate, visible feedback; tools for thought.
- **Don Norman** — signifiers and mental models; what a declaration *means*
  to the person writing it.

Sitting this one out: **Matz and why the lucky stiff**, because the tension
here is not in the `.sp`/`.design` sentence-level prose (both read fine) but
in the compiled contract underneath it; **DHH**, because his "convention
over configuration" ground is already covered by Weirich's contract argument
and Metz's smell-hunting, and a third voice repeating it would be padding,
not friction; **Sarah Mei**, for the same reason — Metz and Owen already
carry "no magic, small steps" for this specific technical question.

### Team Norms & Operating Principles

Read directly from `ODE_TO_JOY.md` and `working-with-dan.md` this session,
not carried over from the prior charter:

1. **Precedence**: Correctness > The house > Clarity > Idiom > Elegance.
   Cleverness is not on the list (`ODE_TO_JOY.md` Part II).
2. **DRY binds the language, not the artifact — but the artifact must still
   be excellent.** The compiled CSS may repeat itself freely. It may not
   contain a selector that matches nothing real in the actual DOM; that is
   a correctness defect, not a style complaint (`working-with-dan.md`,
   refined 2026-09-25).
3. **Every number here was measured this session.** No figure below is
   re-quoted from `LORE.md`'s memory of the investigation; each was
   re-derived by `grep`/`wc` against the live tree.
4. **Honesty over Perfection**: report what's uncomfortable, including
   where a prior finding turns out to be narrower than first framed.
5. **Winnable victories over grand scope**: this council proposes a design
   spec, not a patch; what ships and when is a separate, later decision.

---

## 2. The Problem: Four Frontiers, One Compiler

`SlimPickins::DesignIdiom` (`lib/slim_pickins/compiler/design_idiom.rb`,
629 lines) compiles `.design` files — `studio/uis/workbench/workbench.design`
(20 lines) and `examples/doc_reader/doc_reader.design` (12 lines) are the
only two that exist. Both surfaces are declared through the same seven
qualitative words: `air`, `posture`, `frame`, `cadence`, `treatment`,
`scroll`, `presence`, `focus` — every one resolved through a named token
table (`AIR_TOKENS`, `POSTURE_TOKENS`, `FRAME_TOKENS`, at
`design_idiom.rb:15-83`). `collapse_at` is the one exception:

```slim
# studio/uis/workbench/workbench.design:6
    collapse_at "56rem"

# examples/doc_reader/doc_reader.design:3
    flank catalog, beside: reading_pane, balance: subordinate, collapse_at: "26rem"
```

Two raw, unrelated string literals, on the only word in either file that
isn't a symbol. `DEFAULT_COLLAPSE_THRESHOLD = '48rem'` exists
(`design_idiom.rb:85`) and both files override it independently.
`test/design_idiom_test.rb:12,130` carries the same two raw literals in its
fixtures.

`/assets/workbench.css` is not a file on disk — `studio/app.rb:229-233`
recompiles it from `workbench.design` on every request:

```ruby
if name == 'workbench.css'
  design_file = File.expand_path('uis/workbench/workbench.design', __dir__)
  SlimPickins::DesignIdiom.compile(File.read(design_file))
```

That compiled output carries a provenance comment
(`assets/workbench.css:1`, `/* Compiled automatically from
studio/uis/workbench/workbench.design */`) and is `wc -l`-measured at
**459 lines**, of which **99 lines contain `:has(`**. A second, independent
call site compiles the same way with no shared helper and no provenance
comment: `studio/pages.rb:613-630`, the playground's `render_json`, compiles
whatever the user typed into the design textarea and splices it into
`<style id="design-idiom">` before `</head>`. A third stylesheet,
`assets/slim-pickins.css` (753 lines), is the static core language
stylesheet, unrelated to either. Three delivery paths for CSS on one page.

The 99 `:has(` lines come from a defensive selector list
(`design_idiom.rb:274-280`) that targets **six** candidate selectors per
stage rule because the compiler cannot see what the real page actually
renders:

```ruby
targets = [".stage-#{@stage_name}", ".#{@stage_name}", ".surface-#{@surface_name}",
           "body:has(> .sidebar_layout) > .sidebar_layout",
           ".sidebar_layout:has(> .library)",
           "body:not(:has(> .sidebar_layout))"]
```

The ground truth, `studio/uis/workbench/layout.sp:15-17`:

```slim
sidebar_layout
  library
  contents
```

`sidebar_layout`, `library`, `contents`/`panes.sp` are plain `box` partials;
per this project's own promotion convention (`LORE.md`, 2026-09-15), a
single-root `box` partial is promoted with its own app_class, so
`library.sp` renders `class="box library"`, not `class="library"` and
certainly not `class="zone-library"`. Checked directly: `grep -rn
"surface-\|class=\"workbench\|stage-workbench" lib/ studio/` outside
`design_idiom.rb` itself returns **zero matches**. `.stage-workbench`,
`.workbench`, `.surface-workbench`, and the Zone-level guesses
`.zone-library`/`.zone-editor`/`body > .zone-library` match nothing in the
actual DOM — they are dead selectors, kept alive only because the compiler
has no contract telling it which of its six guesses is real. `grep -rn
"data-surface\|data-zone"` across the repo: **zero matches**.
`PROJECT.md`'s frontier (3) names `data-surface`/`data-zone` as the target
contract; it does not exist yet.

The fourth frontier is narrower than `PROJECT.md`'s framing suggested.
`design_idiom.rb:549-551` emits a fixed-viewport `calc(100vh - ...)` block —
but only where a zone declares `presence :steady`
(`design_idiom.rb:544-553`), not on every surface. `workbench.design`'s
`zone output` declares `presence steady`; `doc_reader.design` declares no
`presence` at all, so it never reaches this code path today. The real bug
is narrower and sharper: the one place this fires uses `100vh`, not
`100dvh` — on mobile Safari/Chrome, where the address bar changes the
visible viewport height, `100vh` overshoots and either clips content or
forces a scrollbar the shell was built to avoid. There is no
`surface`-level declaration of "this is a tool shell" vs. "this is a
document" — each zone opts into containment individually.

---

## 3. The Council Debate

### Frontier 1 — the one word that broke the pattern

**Don Norman:**
> "Seven words in this file are signifiers — `air tight` tells the author
> what they're declaring without making them do arithmetic. Then
> `collapse_at "56rem"` asks the same author to reason in a unit they were
> never asked to reason in anywhere else in the file. That's not a small
> inconsistency; it's the one place the mental model breaks. The author has
> to stop, guess what `56rem` means relative to `26rem` two files over, and
> hope. A signifier that only sometimes signifies isn't one."

**Sandi Metz:**
> "Don's naming the smell; here's the mechanism. `collapse_at "56rem"` and
> `collapse_at: "26rem"` are two magic numbers with no shared vocabulary
> between them, and — this matters — the machinery to fix it already
> exists. `AIR_TOKENS`, `POSTURE_TOKENS`, `FRAME_TOKENS` are the exact same
> shape of problem, solved once, at `design_idiom.rb:15-83`.
> `collapse_at` not going through that table isn't a design decision, it's
> an oversight. This is the cheapest fix on the table tonight because the
> pattern is already written down six times."

**Katrina Owen:**
> "Agreed, and it's a genuinely small, verifiable step: add
> `COLLAPSE_TOKENS`, route `collapse` through
> `@compiler.collapse_tokens.fetch(...)` the same way `posture` already does
> at line 259, update the two real call sites
> (`workbench.design:6`, `doc_reader.design:3`) and the two test fixtures
> (`test/design_idiom_test.rb:12,130`). Four files, one mechanism, and
> `check_grammar.rb`/`check_shape.rb` don't even see `.design` files, so
> there's nothing to regress there — only `test/design_idiom_test.rb` needs
> new assertions."

### Frontier 2 — one compiler, two doors

**Bret Victor:**
> "Here's the failure I care about: open DevTools on the real workbench and
> the interactive playground pane side by side, and you cannot tell which
> compiled that rule. One has a comment naming its source file
> (`assets/workbench.css:1`); the other, `studio/pages.rb`'s inline
> `<style id="design-idiom">`, has none. The whole point of a spatial idiom
> is that the author can see the *causal line* from what they typed to what
> rendered. Right now that line breaks exactly at the boundary that matters
> most — the live-editing pane, where the author is actually iterating."

**Jim Weirich:**
> "And it's not just missing a comment — it's two independent entry points
> calling the same compiler. `studio/app.rb:230-231` and
> `studio/pages.rb:613-630` both call `SlimPickins::DesignIdiom.compile`
> with no shared plumbing between them. A tree language should have one
> place where 'design source becomes CSS' happens, with provenance as a
> parameter, not two call sites that happen to agree today and can drift
> tomorrow. One method — `compiled_stylesheet_for(source, provenance:)` —
> used by both."

**Katrina Owen:**
> "Small step again: extract that method, have both callers pass it a
> provenance string (the file path for the asset route, `'playground
> buffer'` for the studio pane), have it always prepend the comment. No
> behavior changes for a visitor; `test/studio_docs_test.rb` and the
> existing design_idiom tests should still pass unmodified, which is exactly
> the kind of verifiable-and-boring step this project rewards."

### Frontier 3 — six guesses, most of them dead

**Avdi Grimm:**
> "This is the one I actually mind. Six selectors joined per rule, and I
> just heard Jim confirm three of them — `.stage-workbench`, `.workbench`,
> `.surface-workbench` — match nothing in the real DOM, and two more —
> `.zone-library`, `body > .zone-library` — are equally dead. That's not
> defensiveness, that's a compiler that doesn't trust its collaborator and
> covers every possibility it can imagine instead of the one that's real.
> `sidebar_layout`, `library`, `editor` are plain `.sp` partials one file
> away. Nothing stops them from saying who they are."

**Sandi Metz:**
> "Avdi's right, and per tonight's norm — DRY doesn't bind the artifact,
> excellence does — the complaint isn't that this compiles to 459 lines.
> It's that five of those six candidate selectors *are dead code shipped to
> every visitor's browser*, which is a correctness defect wearing a
> performance costume. A six-way `:has()`/`:not()` chain that's 83% fiction
> would fail review in any language."

**Jim Weirich:**
> "The fix is a contract, not a smarter guesser: `sidebar_layout` emits
> `data-surface="workbench"`, each zone partial emits
> `data-zone="library"` / `"editor"` / `"output"`, and the compiler targets
> `[data-surface="workbench"]` / `[data-zone="library"]` — one selector,
> not six. The tree already has the right shape for this; it's missing one
> attribute per level."

**Katrina Owen:**
> "I want to flag scope honestly before we all nod. I checked whether
> Volet 2's open-payload-forwarding (R3P1, `contracts.rb:115-136`) already
> gives partials a free way to emit an arbitrary `data-*` attribute — it
> doesn't. What it forwards is kwargs onto the subject chain for a *child*
> to read (how `action` reads `.path` from `actions`), not a literal HTML
> attribute on the partial's own wrapping tag. The real precedent is
> narrower and more recent: Volet 2 also gave `button` new `:name` and
> `:value` modifiers that do emit literal HTML attributes
> (`words.rb`, `formaction`). `sidebar_layout` and the zone partials need
> the same treatment — a `data_surface:`/`data_zone:` modifier wired to
> `attrs_html` (`generator.rb:188`) — which is real, small, precedented
> work, not zero work. I don't want this council's excitement about the
> contract to quietly promise a mechanism that isn't built yet."

**Avdi Grimm:**
> "Fair, and it doesn't change the recommendation — it changes the
> estimate, not the direction. Confident code is still the goal; I'm just
> agreeing with Katrina that 'confident' isn't free."

### Frontier 4 — shell and document are not the same shape

**Jim Weirich:**
> "`presence :steady` only fires for `workbench.design`'s output zone today
> — `doc_reader.design` never touches this code. So this isn't a universal
> bug, it's a narrow one: one `100vh` that should be `100dvh`, at
> `design_idiom.rb:549-550`. That part is a one-line, fully-scoped fix with
> no design question attached to it — ship it with Frontier 1, it's the
> same size of change."

**Bret Victor:**
> "The one-line fix should happen regardless. But I don't want the council
> to stop there and call the frontier closed, because the actual authoring
> experience is still wrong: `workbench.design` has to know, zone by zone,
> which ones need `presence: :steady` and `scroll: :internal` to behave
> like a tool shell. A person opening this file for the first time can't
> see, from the top, 'this whole surface is a shell' — they have to infer
> it from which zones happen to carry which properties. Immediate
> understanding means the *surface* should say what kind of thing it is."

**Don Norman:**
> "Agreed with Bret's shape, and I'd put it as: `surface workbench` and
> `surface doc_reader` are answering different questions — 'how do I stay
> put' versus 'how do I flow' — and right now nothing at the top of either
> file signifies which question it's answering. That's a real finding, but
> it's a new declarative concept, not a bugfix, and it deserves its own
> design pass rather than being decided as a rider on tonight's discussion."

**Katrina Owen:**
> "Then it's scope, not tonight's work — Proposed Additional Scope, not the
> consensus. The `dvh` swap ships now because it's measurable and total;
> `kind: :shell` / `kind: :document` needs its own design pass because it
> touches every existing `.design` file's authoring model, and this project
> doesn't decide that shape by rider."

*(No dissent recorded past this point — every objection raised above was
either answered on its own terms, as with Katrina's scope correction on
Frontier 3, or explicitly deferred by agreement, as on Frontier 4.)*

---

## 4. The Council Consensus & Design Specification

### Frontier 1 — Qualitative collapse tokens

Add, beside the existing token tables (`design_idiom.rb:15-83`):

```ruby
COLLAPSE_TOKENS = {
  tight: '32rem',
  cozy:  '40rem',
  roomy: '48rem',    # == current DEFAULT_COLLAPSE_THRESHOLD
  wide:  '64rem'
}.freeze
```

`flank`/`horizon`'s `collapse_at` parameter becomes `collapse:`, resolved
via `@compiler.collapse_tokens.fetch(level_sym) { raise ArgumentError,
"Unknown collapse token: `#{level}`" }`, mirroring `posture` at
`design_idiom.rb:259`. Update the two real call sites and the two test
fixtures named in §2. No grammar change, no checker exposure — a `.design`
compiler concern only.

### Frontier 2 — One compiled-CSS pipeline

Extract `SlimPickins::DesignIdiom.compiled_stylesheet(source, provenance:)`
(or a thin wrapper in `studio/`) that both `studio/app.rb`'s asset route
and `studio/pages.rb`'s `render_json` call, always prefixing the provenance
comment `workbench.css` already carries. The playground's `<style
id="design-idiom">` block gains `/* Compiled from playground buffer */`.
No behavior change for a page visitor; the fix is entirely in traceability.

### Frontier 3 — `data-surface` / `data-zone`

1. Add `data_surface:`/`data_zone:` modifiers to `sidebar_layout` and the
   zone partials (`library.sp`, the `contents`/`panes.sp` chain), wired to
   HTML attribute emission the way `button`'s `:name`/`:value` already are
   (`words.rb`, Volet 2 R3P3 precedent) — new, small, precedented work, not
   free forwarding.
2. `Stage#to_css` and `Zone#to_css` (`design_idiom.rb:274-280`, `~495-503`)
   target exactly `[data-surface="#{name}"]` / `[data-zone="#{name}"]`.
   Delete the six-way and four-way guess lists entirely, including every
   selector confirmed dead in §2/§3.
3. `assets/workbench.css` should shrink and lose all 99 `:has(` lines; the
   council did not compute the exact resulting line count — that's a
   post-implementation measurement, not a promise made here.

### Frontier 4 — the narrow fix now, the real one later

Ship immediately, bundled with Frontier 1 as a matching one-line-per-file
change: `design_idiom.rb:549,550`, `calc(100vh - ...)` → `calc(100dvh -
...)`. This is total — it is the only place `100vh` appears in the
compiler — and requires no new design vocabulary.

---

## 5. Flexible Parity & Evidence Justification

- **No grammar or vocabulary change.** `check_grammar.rb`, `check_shape.rb`
  do not read `.design` files (confirmed: neither script's `DOCS`/corpus
  list includes them). Nothing here touches the 64-word `.sp` vocabulary.
- **`check_styles.rb` scope.** That checker holds `assets/slim-pickins.css`
  to the `.sp` runtime's emitted classes; `workbench.css` is compiled
  separately by `DesignIdiom` and is out of its corpus. Shrinking
  `workbench.css`'s selector list does not change what `check_styles.rb`
  gates.
- **Test surface.** `test/design_idiom_test.rb` needs new assertions for
  `collapse:` tokens (Frontier 1) and for `data-surface`/`data-zone`
  selector output replacing the guess list (Frontier 3); Frontiers 2 and 4
  should be invisible to existing tests — one is a refactor of *how* CSS is
  delivered, the other a value swap in an existing formula.
- **Nothing here is committed or implemented.** This document is a design
  spec the council reached consensus on, per its own operating rule
  (`.claude/skills/council/SKILL.md`) — landing it is separate, later work,
  and `dan`'s call.

---

## 6. Proposed Additional Scope

### Scope Proposal 1: `surface kind: :shell | :document`

Frontier 4's deeper finding (Weirich, Victor, Norman, §3): a `surface`
declaration should be able to name what kind of thing it is — a tool shell
that owns the viewport, or a document that flows in the page — so that
containment properties (`presence: :steady`-like behavior, `100dvh`
bounding) apply once at the surface level instead of being assembled zone
by zone. This changes the authoring model for every `.design` file that
will ever exist and deserves its own design pass, not a rider on this
consensus.

### Scope Proposal 2: measure the real selector-count reduction

Once Frontier 3 lands, re-run `wc -l assets/workbench.css` and `grep -c
":has(" assets/workbench.css` and record the before/after in `LORE.md` —
the council named the current numbers (459 lines, 99 `:has(` lines) but
deliberately did not promise a resulting count, per Katrina Owen's caution
in §3.

---

Signed by the Council:
*Sandi Metz · Avdi Grimm · Jim Weirich · Katrina Owen · Bret Victor · Don Norman*
