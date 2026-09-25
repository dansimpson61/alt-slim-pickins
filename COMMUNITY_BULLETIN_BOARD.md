# COMMUNITY BULLETIN BOARD
## The Council on `alt-slim-pickins`
### Doc Reader in the Workbench Preview: An Uninviting Narrow Pane

---

## 1. Council Charter & Team Norms

### Orientation

Prompted by dan's screenshot of the Workbench editing `examples/doc_reader/views/index.sp`
with its `.design` companion: the Visual preview shows two same-weight gray
boxes ("Documents" catalog, then the `DESIGN_IDIOM.md` reading pane)
stacked vertically, plain and undifferentiated — not what "flank catalog,
beside: reading_pane" promises. Also missed earlier in this session:
`design_idiom_discussion.md`, an earlier council transcript that is the
actual origin of the `.stage-X > .zone-Y` selector shape this project's
last round of work replaced — read in full before this session; it
explains lineage, it doesn't change the finding below.

### The Council

- **Bret Victor** — immediate, visible feedback; the workbench preview
  pane is exactly his subject matter.
- **Don Norman** — signifiers and mental models; whether a viewer can tell
  "this is a list to click" from "this is what I'm reading" at a glance.
- **Sandi Metz** — smells in the underlying mechanics (`minmax` floors
  fighting a fluid ratio).

Sitting out: the rest of the roster — this is a narrow, contained visual
question, not an architecture debate; three voices with real friction beat
a full quorum restating agreement.

---

## 2. The Problem, Measured

Not a bug. Rendering `examples/doc_reader` live in the Workbench at
1567×1017 (matching dan's screenshot) and measuring the actual DOM,
not guessing:

- The Visual tab's iframe body — the thing `doc_reader.design`'s `stage`
  targets — is **412.8px** wide.
- `doc_reader.design:4` sets `collapse: tight`, and `tight` resolves to
  **26rem = 416px** (`COLLAPSE_TOKENS`). 412.8 < 416 — the container query
  correctly collapses to one column. This is the mechanism working
  exactly as built, not a defect in this session's earlier work.
- Forcing the un-collapsed two-column grid at this same width (a live
  probe, not arithmetic on paper) gives `catalog: 224px`,
  `reading_pane: 116.8px`. `balance: subordinate`'s lead floor
  (`minmax(14rem, 1fr)` — 224px) doesn't shrink, so at this width the
  "minor" catalog column would end up **wider** than the reading pane it's
  supposed to be subordinate to. Widening the collapse threshold would
  trade one bad layout for a worse one, not fix anything.
- `doc_reader.design`'s two zones currently both declare `frame quiet` —
  identical `background`, `border`, `border-radius`, and `padding`
  (`FRAME_TOKENS[:quiet]`, `design_idiom.rb:28-33`). `reading_pane` also
  carries `treatment editorial` (65ch max-width, 1.7 line-height), but at
  224-412px that treatment barely reads — the shared frame dominates the
  visual impression, so both zones look like equal-weight cards.

---

## 3. The Council Debate

**Sandi Metz:**
> "The tempting fix is 'lower the collapse threshold so two columns show
> up more often.' I measured that and it's a trap: `subordinate`'s lead
> floor is a fixed 14rem, so any container under roughly 900px produces a
> lopsided or outright inverted ratio — the 'subordinate' column stops
> being subordinate. Chasing the threshold treats the symptom. The zones
> being visually identical is the actual smell, and it's not even a
> mechanism problem — `doc_reader.design` just asked for the same frame
> twice."

**Don Norman:**
> "Right, and that's the whole story from where I sit. Two boxes with the
> same background, same border, same padding give the viewer no signifier
> for which one is navigation and which one is the document. It doesn't
> matter whether they're side by side or stacked — stacked is often the
> *correct* choice at 400px, plenty of real reading apps do exactly that.
> What's missing is hierarchy: the catalog should look like a list you
> scan, the reading pane should look like the thing you're reading. Right
> now they look like two widgets of equal importance."

**Bret Victor:**
> "And the tool already has the vocabulary for this — it's just unused.
> `FRAME_TOKENS` has `flat` sitting right next to `quiet`
> (`design_idiom.rb:45-49`): transparent, no border, zero padding. Nobody
> is asking for new machinery. `zone catalog` says `frame quiet` when it
> could say `frame flat`, and the moment it does, the catalog stops
> competing with the document for visual weight — in the collapsed layout
> *and* in any future two-column one, for free, without touching the
> compiler or the threshold at all."

**Sandi Metz:**
> "Agreed, and it's the cheapest possible test of Don's diagnosis: change
> two words in one `.design` file, look at it again. If the hierarchy
> problem is what we think it is, that's most of the fix. If it isn't,
> we've learned something for a dollar, not a redesign."

**Don Norman:**
> "One more signifier while we're there: `reading_pane` staying `frame
> quiet` reads as 'also secondary.' Give the thing being read the more
> confident treatment — `lifted` (`design_idiom.rb:34-39`, a real surface
> and a shadow) — so it visibly outranks the list pointing at it."

---

## 4. Consensus

`examples/doc_reader/doc_reader.design` — two zone declarations change,
nothing else:

```
zone catalog
  frame flat
  cadence compact

zone reading_pane
  frame lifted
  treatment editorial
```

Explicitly **not** touching: the `collapse: tight` threshold (confirmed
above that adjusting it doesn't fix the real problem and risks the
lopsided two-column case), `BALANCE_TOKENS[:subordinate]`'s floor (a
separate, bigger question about whether 14rem is the right minimum for
*any* subordinate column, not scoped to this session), and the compiler
(no mechanism gap — `flat` and `lifted` already exist and already work).

Verification: recompile, re-render the Workbench preview at the same
1567×1017 size, confirm the catalog reads as an unboxed list and the
reading pane as a raised surface, both in the current collapsed state and
narrower.

---

Signed by the Council:
*Sandi Metz · Don Norman · Bret Victor*
