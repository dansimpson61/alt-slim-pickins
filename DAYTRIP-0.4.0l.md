# Daytrip 0.4.0l — The Most-Travelled Datum Gets a Name

Tier 6 item 18: the semantic node, a bare three-element Array for the project's first month, is now `SlimPickins::Node = Data.define(:word, :attributes, :children)`. 34 construction sites, 53 named reads, and `is_a?(Array)` in `lib/` down from 7 to 1. All 34 proved pages render byte-identically but one, which differs by a single removed line and is explained.

---

## The brief

Dan said *proceed*. `HANDOFF.md` said to re-measure the item's premises before
acting on them, because three rounds running had found them wrong.

Verified before touching anything: twelve legs green, 586 runs / 0 failures, and
a byte-diff snapshot of all 34 pages, which is the only instrument that can prove
a refactor of the runtime's central datum changed nothing.

---

## Part 1 — Re-measuring, which changed the work again

The audit's corrected figure was "20 read sites and 29 construction sites". Both
numbers were close; what they implied was wrong.

**The read side was already centralised.** `Generator#emit` destructured once —
`kind, attrs, children = node` — and dispatched to per-word methods taking
`(attrs, children)`. So there was one real read of the triple in the Generator,
not twenty, and the rest were about a dozen guards and probes in `Builder`,
`PartialWord` and the Generator's list and tab handling. The refactor was never
going to touch most of the runtime.

**Every construction went through `emit_node`.** That made 34 sites a mechanical
change rather than a redesign, because `Data` supports positional construction:
`[:box, attrs, children]` becomes `Node[:box, attrs, children]`, two characters.
Had `Data` only taken keywords, the same change would have made thirty-four call
sites worse to read, and the honest answer would have been not to do it.

**There are three positional triples in this codebase, not one.** The audit named
the semantic node. `Markdown`'s pretty-printer has its own `[:element, open_tag,
name, children]`, read as `node[0]` and `node[1]` *in the same Generator*; and
`Words::Table` built `[:row, {}, cells]`. Nothing but the surrounding method told
any of them apart. That strengthens the case the audit made, and it is the kind of
thing only a sweep finds.

## Part 2 — What the name actually bought

Not legibility alone. Two ambiguities were load-bearing and both are gone:

- **A node and a list of nodes were both Arrays.** `body.size == 1 &&
  body.first.is_a?(Array)` was asking "is this one node, or several?" — a question
  the representation could not answer. It was asked that way in `Builder#promote`
  and again in `PartialWord#evaluate`. It is now `is_a?(Node)`.
  `studio/inspector.rb` had the same problem from the outside and solved it by
  testing `node.first.is_a?(Symbol)`; that guess is deleted.
- **`is_a?(Array)` in `lib/` went from 7 to 1**, and the survivor is correct:
  `Builder` discriminating an *argument* that may be a list of children. Exactly
  the "one good name plus about six guards" the audit predicted once it had
  corrected itself — and worth noting, because the audit's *first* claim was that
  this refactor would remove most of sixty type checks. The corrected claim was
  the right one.

`Data` is frozen, and the runtime has exactly one mutation through a node:
`root.attributes[:app_class] = …` in `Builder#promote`. It writes to the hash the
node holds rather than to the node, so it still works, and it is now impossible
to confuse that with rebuilding the node.

One smaller gain: `children.flatten(1)` for `each` used to risk splicing a node's
own three elements into a list of children, because a node was an Array. It
cannot now.

## Part 3 — Four sites a grep could not find, and a render did

The sweep over `emit_node([:` caught 21 of 34. The four it missed are the
instructive ones, and each was found by the suite rather than by reading:

1. **`Word#call` builds nodes generically** — `emit_node([self.class.word_name,
   …])`. A grep for a literal symbol cannot see a variable word.
2. **`in_head`** takes a node and had its own construction, one method away from
   the one that was converted.
3. **`Words::Table` built `[:row, {}, cells]`** and stored it in the table's
   *attributes* rather than emitting it, so no sweep over `emit_node` could reach
   it. A render found it, and a row is a node now.
4. **`PartialWord` read `Builder.box_root(body)[1]`** — a positional read on a
   method's return value, which matched no pattern looking for `node[1]`.

The lesson is the same one 0.4.0h recorded about a `def`-line grep and indentation
damage: **ask what shape of defect a scan is structurally able to see.** A pattern
over literal constructions is blind to generic ones, and a pattern over named
variables is blind to method returns.

## Part 4 — The one externally visible consequence

`SlimPickins.render` takes an optional `filter:` — "the AST pipeline's middle
stage, exposed" — and its documented example built a node as an array literal. A
filter now receives and returns `Node`s.

This house has no users and no semver, so the change is free to make; it is not
free to leave unsaid. The signature's comment now states it, because that lambda
is the only published extension point the tree has.

---

## What landed

```
lib/slim_pickins/node.rb      new       Node = Data.define(:word, :attributes, :children)
construction sites            34        words.rb 24, generator.rb 4, builder.rb 3, word.rb 3
named reads                   53        .word / .attributes / .children
is_a?(Array) in lib/          7 -> 1    the survivor discriminates an argument, correctly
test/node_test.rb             new       6 tests, one per reason the name was taken
```

- **`studio/inspector.rb`** reads the Node API, and its node-vs-list guess is gone.
- **`head` joined the Inspect surface's nested payloads.** It had always held
  nodes and had always printed as `[[:stylesheet, {…}, []]]`, which nobody could
  read and nothing flagged. Naming the node turned that into `#<data
  SlimPickins::Node …>` and made the inconsistency obvious, so the row is now
  shown as the tree like every other node-valued attribute.
- The two runtime comments that described the node as `[:word, attributes,
  children]` now say `Node[word, attributes, children]`. `ROADMAP-0.2.md` and
  `LORE.md` still carry the old spelling and are left alone: they are the dated
  record, and `check_vitals.rb` exempts them for that reason.

## Deliberately not done

- **`Markdown`'s `[:element, …]` triple is still positional**, and so is the
  tokenizer's. They are a separate AST with a separate job, and naming them is a
  separate round's work — but they are now the only unnamed triples left, which is
  the first time that has been true.
- **The registry's global last-compile-wins order dependence**, still named and
  not fixed, from 0.4.0j.
- **`word_count`/`words_count`** remain two names for one number.

## Verification

- **Twelve legs green.** Suite: **592 runs, 6,482 assertions, 0 failures, 0
  errors, 0 skips**, and each example suite green on its own.
- **33 of 34 proved pages are byte-identical** to the pre-refactor corpus. The
  34th is the Inspect surface, and it differs by exactly one line — the removed
  `head` row described above. For a change touching the runtime's central datum at
  87 sites, that is the whole visible effect, and it is a measurement rather than
  a claim: the baseline was captured before the first edit.
- Every number here was measured this round: the 34 and 53 by counting the
  converted sites, the 7 → 1 by grepping both ends, the one-line diff by `diff -r`
  over two rendered corpora.
