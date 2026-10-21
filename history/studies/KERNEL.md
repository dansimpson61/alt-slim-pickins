# The kernel — a spec

Status: **draft for dan.** Nothing here is built. The measurements are this
session's, taken on the tree at `5d43fe9`; the judgements are argued, not
assumed; the two decisions that are dan's are marked as such.

## The question

Rubinius asked what part of Ruby has to be C. Not "what is fastest in C" —
what *cannot be said in Ruby about Ruby*. Everything else — `String`,
`Array`, `Enumerable`, the whole kernel — was written in Ruby, and the C that
remained was small, sharp, and justifiable one primitive at a time.

This project has already run that experiment once without naming it. The
promotion pass turned twenty-three words into `.sp` partials written over six
atoms, and the byte-diff over thirteen pages showed exactly three changes,
each of them the law applying. The question this spec asks is the one
Rubinius asked next:

> **What is left in Ruby because the language cannot say it, and what is left
> in Ruby because nobody has moved it yet?**

Those are different reasons, and today they are indistinguishable from the
outside. Forty-two words live in `words.rb`. Some of them are the floor.
Some of them are furniture that was never carried out.

## The test

A word stays Ruby if, and only if, it does one of five things the language
has no way to express about itself:

1. **It controls evaluation.** Iteration, branching, splicing. `each`,
   `choose`, `when`, `otherwise`, `children`, `contents`.
2. **It computes.** Arithmetic, geometry, text transformation — the chart's
   SVG paths, markdown, the money/percent/moment formatters.
3. **It acts on the document as a whole.** A side effect on `<head>` or the
   icon sprite, from wherever it is said. `stylesheet`, `meta`, `script`,
   `icon`, `page`.
4. **It reaches the bytes.** Escaping, raw markup, the tag itself.
5. **It is an atom.** The substrate the vocabulary composes over — with the
   discipline that an atom is a *shape*, never a specific HTML element.

Everything else **composes**: it arranges atoms in a fixed structure, and a
fixed structure is a sentence. Composition belongs in `.sp`.

Rule five is the one carrying the weight, and it is the one the current atom
set breaks.

## The census, measured

On the tree at `5d43fe9`:

| | count |
|---|---|
| words in `words.rb` (Ruby) | 42 |
| words in `lib/vocabulary/*.sp` (the language) | 23 |
| **vocabulary total** | **65** |
| node kinds the Generator interprets by name | 31 |
| node kinds handled inline in `emit` (`raw`, `tag`, `each`, `choose`, `contents`) | 5 |

Cost, re-measured this session (`bin/measure_cost.rb`, ruby 4.0.1,
`specimen.sp`, 200 runs): cold **5.83 ms**, warm **3.55 ms**, **0.15 ms**
per row. Everything green at baseline: 222 test runs / 0 failures, 809
sentences / 0 problems, 82 rules / 0 problems, 13 pages verified.

## The keystone: one primitive is missing, and its absence is what pins the rest

Look at what these seven words have in common — `field`, `checkbox`,
`textarea`, `input`, `hidden`, `fact`, `metric`. Every one of them is, in
Ruby:

```ruby
value = subject.fetch(name)   # then compose a fixed structure
```

Fetch the attribute *named by the name I was given*, then arrange it. The
arranging is a sentence. The fetching is not sayable: `.foo` compiles to
`subject.foo` statically, so a partial handed the name `:email` has no way
to ask for the enclosing subject's `email`. **Name-directed data access is
the missing primitive**, and it is the reason all seven of these words are
still Ruby. They are not primitive. They are blocked.

This is Rubinius's reflective primitive — the small, ugly, load-bearing hole
in the floor that lets the kernel be written in the kernel language.

### It is indirection that is missing, not availability

**dan, 2026-09-03:** *"Can our interpreter automatically provide the subject
to any indented line? Am I correct that that is what we need?"*

Half right, and the half that is wrong is worth stating exactly, because it
narrows the fix.

**The subject is already provided to every indented line** — that is the
oldest decision in the language, the ambient outermost subject borrowed from
VBA. Inside a partial that declares a preamble, the parameters are an
*overlay*: they answer the slots they declare and **fall through to the
enclosing subject for everything else**. Measured, with a partial declaring
`name: attribute` whose body hardcodes an attribute the page supplies:

```
probe email          ->  <p class="text">dan</p>
  # body: text .nickname       (nickname is the page's, not the partial's)
```

So a partial can already reach the subject. What it cannot do is say *which*
attribute, because the attribute's name arrives as **data** (`.name` is
`:email`) and the language has no spelling for "apply this name to the
subject." The gap is indirection.

**dan's version, taken seriously.** A word declaring `name: attribute` could
shift the subject to the *named value* for its children — then `field email`
would make the email's value the subject inside `field.sp`. That is the more
sweeping design, and it fails on a spelling: every value in this language
carries a dot **and** a name, and there is no bare `.` for "the subject
itself." Adding one is new syntax, and the founding claim is that extending
the language adds vocabulary, never syntax. `# value: true` gets the same
power for one more declaration of a kind that already exists twice, and
`.value` is an ordinary `.foo`. **Same instinct — automate it in the
interpreter, driven by the declaration — at a lower price.**

### The trap this spike found: a name passed as data is still a name

`.name` holds a Symbol, and `name_and_content` sorts a word's arguments **by
Ruby type** — a Symbol is a name, anything else is content. So a slot holding
a name, handed to another word, is re-consumed as *that word's* name:

```
badge .name          ->  <span class="badge badge--email">email</span>
                                            ^^^^^^^^^^^^ consumed as a variant
```

The page said "present this name as a badge" and got a badge *variant*
instead. Nothing raises; the class is simply wrong.

This matters for every round after the keystone, because promoted partials
pass their slots to other words constantly — that is what composition is.
**A `name` slot cannot currently be passed to any word that takes a name.**
The grammar's "one visual cue, one job" holds in the page, where `.name`
carries its dot; the cue is lost the moment the name becomes a value, and
what remains is a type check that cannot tell the two apart.

Round 3 must settle this before promoting anything whose body passes a name
onward. The cheapest honest fix is probably to stop discriminating by Ruby
type — have the transform mark which arguments were written as names, rather
than letting the runtime infer it from `Symbol` — but that is a change to how
every word receives its arguments, and it is not costed here.

The good news is that the mechanism already exists and this is a three-line
change. `parameters_for` already derives two slots from the situation:

```ruby
declared[:id]    = card_id                 if contract.id
declared[:label] = label_for(name, content) if contract.label
```

`# id: true` gives `card` its DOM id; `# label: true` gives `section` its
heading. The first draft of this spec proposed one more of the same kind,
`# value: true`. **dan improved it, 2026-09-03** — *"why not add the subject
to every list of arguments and have the interpreter attach it
automatically?"* — and the improvement is that **no new declaration is
needed at all**:

```ruby
declared[:value] = subject.fetch(name) if contract.name == :attribute &&
                                          contract.shape != :registers
```

`name: attribute` *already means* "this name is an attribute of the
subject." That is the declaration; adding `# value: true` beside it would
have been saying the same thing twice, which is the defect this project
calls a line that states the inferable.

**Why it cannot be unconditional**, which is the other half of dan's
question. The name slot carries **ten** different meanings, and only
`attribute` means "look me up on the subject." For the rest, an eager fetch
*raises*:

```
button primary    ->  subject.fetch(:primary)  ->  UnknownAttribute
link show         ->  subject.fetch(:show)     ->  UnknownAttribute
each holding      ->  subject.fetch(:holding)  ->  UnknownAttribute
```

Thirteen words take `variant` alone. So the subject cannot be attached to
every argument list blindly — but it needs no opt-in either, because the
`name:` slot already says which of the ten meanings applies. The
discriminator was there all along, exactly as `tag` was.

**Measured, and the fit is exact.** The seven words that declare
`name: attribute` without being registrars are `fact`, `metric`, `field`,
`textarea`, `input`, `checkbox` and `choice` — and **all seven call
`subject.fetch(name)` in Ruby today** (words.rb 183, 209, 290, 303, 313,
330; components.rb 201). The rule does not approximate their behaviour; it
*is* their behaviour, lifted into the interpreter.

**Two exceptions, named before the round starts.**

1. **Registrars must not resolve eagerly.** `column`, `total`, `band` and
   `line` declare `name: attribute` too, but a column registers *before any
   row exists* — words.rb already says so in a comment, and the table
   resolves the header once the first row is in hand. Hence
   `shape != :registers` in the rule above.
2. **`hidden` is misdeclared.** It calls `subject.fetch(name)` (words.rb
   324) but its contract says `name: :name`, not `:attribute`. Its
   declaration under-describes its runtime — the same defect class as the
   gate's first catch, when `choice`'s contract said it held only `option`
   while nested `choice` was tested and supported. Settle it before the rule
   lands, or `hidden` stays in Ruby for no principled reason.

Then `fact` is a sentence:

```
# name: attribute
# content: true
# shape: presents

pair .label, .value
```

`.value` arrives because `name: attribute` was declared — nothing else is
said, and nothing else needs to be.

No new grammar. No new spelling in any page. One more declaration in a
preamble, which is where this language has already decided that a word's
declaration lives. It obeys *word, or power?* honestly: this is power, and
it is the smallest power that unblocks seven words.

## The atom set is not orthogonal

Six atoms: `box`, `paragraph`, `heading`, `span`, `figcaption`,
`summary`. They factor into three shapes, not six:

- **a box that holds children** — `box`
- **a block that holds text** — `paragraph`, `heading`, `figcaption`, `summary`
- **an inline run of text** — `span`

`figcaption` and `summary` are not atoms. They are two specific HTML
elements punched into the kernel because `figure` and `disclosure` needed
them, and the proof is in the partials themselves:

```
# figure.sp                    # disclosure.sp              # section.sp
box                         box open: .open           box .name
  children                       summary .content             heading .label
  figcaption .content            children                     children
```

All three do the same thing — **title the box** — and one of them gets to
use the general rule while two need their own primitive. The general rule is
already written and already conditional on the box:

```ruby
# generator.rb — a heading inside a box is the box's title
elsif @box_base
  full_tag(:"h#{@box_level + 1}", attrs[:body], class: "#{@box_base}-title")
```

It hardcodes `h{n}`. Give it the same word→element map `box` already has
for tags, and both primitives disappear:

```ruby
BOX_TITLE_TAGS = { figure: 'figcaption', disclosure: 'summary' }.freeze
```

The rule gets *more* general, not more special: **a heading inside a box is
that box's title, in whatever element that box titles with.** `figure.sp`
and `disclosure.sp` then say `heading .content` like every other box, and
`figure` picks up the `choose`/`when` guard that `card.sp` already uses for
an absent title.

**Measured, this session** — the box-title branch already fires inside a
`figure`, so Round 1 is a substitution and not a mechanism:

```
figure                →  <figure class="figure">
  heading "A caption"       <h2 class="figure-title">A caption</h2>
                          </figure>
```

The box resolves to `:figure` today; only the element is hardcoded.

This is the whole thesis in one example. The atom set grew by element, not
by shape, and every element-shaped atom is a word that could not be written.

## The floor is lower than the atoms — `tag` was there all along

**dan, 2026-09-02:** *"If the current implementation of `tag` were not built
on `span`, but rather `span` was built on `tag`, would your refactoring be
liberated? I think you may be being held back by unnecessary legacy code."*

The premise runs the other way in the details, and the diagnosis is right
anyway — more sharply than the version of this spec that preceded it.

`span` is not built on `tag`, and `tag` is not built on `span`. **They are
strangers.** Measured:

- `tag` is not a word in the language at all. It is a Ruby-only method on
  the Builder's escape-hatch surface, for app words. `CONTRACTS` has no
  `:tag`.
- The Generator has a **generic element path** — the `:tag` node kind,
  three lines, handling attributes, children and voids.
- It also has **31 named methods making 61 direct `full_tag`/`open_tag`/
  `void_tag` calls.**
- **No vocabulary word emits a `:tag` node.** Not one.

So the general element primitive has existed the whole time, and the
vocabulary has never once used it. Every atom added during the promotion
pass was added as *another special-cased Generator method* beside a general
mechanism that already worked. That is the unnecessary legacy: not that the
atoms are wrong, but that they were built parallel to the primitive instead
of on top of it.

**Measured — `tag` reproduces an atom byte for byte:**

```
note  today : <p class="note note--warn">Careful.</p>
note via tag: <p class="note note--warn">Careful.</p>
```

And where it does *not* reproduce, it names the true kernel exactly:

```
money today : <span class="money">$1,234</span>      (Inference.money, precision 0)
money via tag: <span class="money">$1,234.50</span>   (the literal I handed it)
```

The element is reproducible. **The formatting is not** — and that is
computation, which rule two already keeps in Ruby.

### What this liberates

If `tag` becomes the one element primitive and the atoms are written over
it, then the kernel is not "the six atoms". It is four things that survive
the split, because none of them is element emission:

1. **Formatting** — `Inference.money/percent/number/moment`. The `$1,234`
   above. Computation.
2. **Walk context** — `@depth` (a heading's level), `@box_base`/`@box_level`
   (the box-title rule), `@in_form` (`group`'s fieldset-or-div). These are
   computed *during the tree walk*; no partial can know them, which is why
   `group` was already on the floor.
3. **Class derivation** — `token(word, variant)` and root-classing, keyed on
   `class_base`. Mechanical, and it must stay the Generator's, for the
   reason below.
4. **Evaluation control and document side effects** — unchanged: `each`,
   `choose`, `children`, `contents`, the `<head>` words, the sprite.

`box`, `paragraph`, `figcaption`, `summary`, and the *element half* of
`heading` and `span` all fall out of the kernel. So, plausibly, do `nav`,
`grid`, `image`, `link`, `hidden`, `input`, `snippet` and the form
wrappers — every Generator method whose body is "open a tag, put things in
it, close it."

### The gate this needs, and why it is the Rubinius answer

**`tag` must not become an ordinary word.** If a page can say `tag`, a page
can hand-author elements and hand-author classes, and the language's central
promise — *nothing styleable by hand comes back*, the promise G3 in the
dashboard port is a complaint about — dies in one sentence. That risk is the
reason to be careful here, not a reason to stop.

Rubinius answers this precisely, and it is the part of the inspiration this
spec had not yet spent: **Rubinius's kernel may call primitives that user
Ruby may not.** `Rubinius.primitive` is not a public API; it is a privilege
the kernel holds because the kernel is what implements the safe surface.

So: **`tag` becomes a privileged kernel word** — sayable in
`lib/vocabulary/*.sp`, refused in app pages and app partials. The vocabulary
gets the power precisely because its job is to spend that power building the
safe words everyone else uses.

Both halves of the mechanism exist:

- `Compilation.of(source, path)` threads the path, so the gate knows which
  file it is walking.
- `Library.builtin_partials` already distinguishes `lib/vocabulary/*.sp`
  from an app's own.

**One wrinkle, named honestly:** the compilation cache is keyed by *source*
and its verdict deliberately carries no path, because the same source may
render under several names. A privilege check keyed on path therefore cannot
live inside the cached verdict — it belongs either where `refuse!` already
composes the render's own path, or in a cache key widened to
`[source, privileged?]`. Both work; neither is free; the round picks one and
says why.

## The cut list

Tiered by what each promotion needs, with an honest confidence. Nothing here
is a promise; each is a round, and each round measures.

### Tier 1 — the mechanism exists, nothing new is needed

| word | becomes | needs | confidence |
|---|---|---|---|
| `figcaption` | `heading` in a `figure` | `BOX_TITLE_TAGS` | high |
| `summary` | `heading` in a `disclosure` | `BOX_TITLE_TAGS` | high |

Two primitives, zero new mechanism, and one rule made more general.

### Tier 2 — unblocked by `# value: true`

| word | becomes | also needs | confidence |
|---|---|---|---|
| `fact` | a labelled pair | a `pair` atom (`dl`/`dt`/`dd`) | high |
| `metric` | a labelled pair | the same atom, different tags | high |
| `field` | `label` + `input` | a `label` atom | high |
| `checkbox` | `label` wrapping `input` | the same atom | medium‑high |
| `textarea` | `label` + a bare textarea | a bare `textarea` control | medium‑high |
| `choice` | `label` + a bare select | a bare `select` control | medium |

Note what Tier 2 buys beyond the count. The wrapper `<div class="field">
<label for=…>` is **written four times** in `generator.rb` today — lines
343, 365, 378, 388 — because `field`, `textarea`, `checkbox` and `choice`
each build it by hand. Promoted, it is written once, in a sentence. Six
words leave the kernel; two or three atoms enter. The net count is a modest
−3, and the duplication goes from four copies to one, which is the better
half of the trade.

### Tier 3 — argue it, then decide

| word | the question |
|---|---|
| `nav` | `box` + an aria-label. Widen `box`, or is nav a shape? |
| `grid` | `box` + a `--track` style var. Same question, same answer either way. |
| `snippet` | `pre` + `code` + a copy button. Needs a code atom; low value. |
| `link` | needs an `anchor` atom. Is that an atom or an element? Rule five bites here. |
| `table` | the gatherer mechanism is proven (`dogfood_test.rb`), but per-cell formatting and alignment inference are computation. The hardest, and the last. |

### Tier 0 — `tag` first, which reorders everything above

Given the section above, this is now the *first* round rather than a late
one, because it changes what every later round has to do. Promoting an atom
over `tag` is a different job from promoting it over another atom, and doing
Tiers 1–3 first would mean doing several of them twice.

### The floor — these never move

Revised down by dan's correction. The kernel is no longer "the atoms"; it is
what survives when element emission is subtracted:

- **Evaluation control** — `each`, `choose`, `when`, `otherwise`,
  `children`, `contents`.
- **Document side effects** — `page`, `stylesheet`, `meta`, `script`,
  `icon`.
- **Computation** — `prose` (markdown), `chart`/`band`/`line`/`level`
  (geometry), and the formatters behind `span` (`$1,234`).
- **Walk context** — whatever computes `@depth`, `@box_base`, `@in_form`.
  This is why `group` stays: its fieldset-or-div branch asks *am I inside a
  form*, and the language cannot ask that.
- **The element primitive itself** — `tag`, privileged.

**No count is offered.** The previous draft projected 28–30 words and that
projection is now void: it was arithmetic over a floor that dan's question
moved. Producing an honest number is Round 1's output, not this document's
claim.

## Acceptance

**The byte-diff harness is the argument**, exactly as it was for the
promotion pass: snapshot all thirteen pages, `git stash` the change, render
before and after, `diff -r`. Byte-identical is the whole case. Any
difference is either a defect or a change dan has ratified in writing before
it lands — the promotion pass ended with exactly three, each of them a
hook-only class the law required.

Plus the standing gate. **It is not copied here any more** (2026-09-17): this
document, `DAYTRIP.md`, `ROADMAP-0.2.md` and `DAYTRIP-0.3.0a.md` each carried
their own copy of the command, and copies drift — the one home is `HANDOFF.md`'s
*Everything green before committing*, and the live form is the studio's
`/status`, which lists the same legs from `StudioStatus::LEGS` and runs them on
every visit. The copies that remain are closed records: correct on the day they
were written, and left as the records they are.

## The one real risk, named

**Rubinius was slower than MRI for years.** That is not a footnote to the
inspiration; it is the central fact of it, and this project has already paid
the same toll once. The promotion pass moved warm render from **1.37 ms to
3.55 ms** — 2.6×, because every promoted word became a composition that
evaluates at runtime instead of a Ruby method that emits.

Tier 2 promotes the words that appear most often *inside loops* — `field` in
a form, `fact` and `metric` in a card, all of them repeated per row. The
per-row figure (0.15 ms) is the one to watch, and it is the one most likely
to move.

**Decision for dan, wanted before Tier 2 starts:** what is the budget? A
number now — "warm render may reach N ms, per row may reach M" — turns a
later surprise into a decision that was already made. The Ode's precedence
puts correctness above elegance and says nothing about milliseconds, so this
is genuinely dan's to set, and the rounds should not guess it.

**Second decision for dan:** does this become Phase 5 of roadmap 0.2, or a
document of its own that Phase 6 (Subtraction) consumes? It is thematically
Subtraction's sibling — Subtraction removes what has no consumer; this
re-expresses what has one — but it is a larger piece of work than that phase
was scoped for.

## The rounds

RIF per round — implement → verify → commit → update `PROJECT.md`
`next_step` → post lore.

Reordered by dan's correction: `tag` leads, because every other round is a
different job once it exists.

- **Round 1 — the privileged primitive.** `tag` becomes a kernel word:
  sayable in `lib/vocabulary/*.sp`, refused in app pages and app partials,
  with the cache wrinkle above settled and stated. No word promoted yet —
  the privilege lands alone, with a test that an app page saying `tag` is
  refused in the gate's voice. This is the round that can go wrong quietly,
  so it goes first and alone.
- **Round 2 — the atoms over the primitive.** `figcaption` and `summary`
  leave outright; `box` and `paragraph` are rewritten over `tag`.
  Note what Round 1 saves here: **`BOX_TITLE_TAGS` is no longer needed at
  all.** `figcaption` carries no class today, so `figure.sp` can simply say
  `tag figcaption` — the special-case mechanism the previous draft proposed
  was an artifact of not having the primitive. That is the reordering
  paying for itself in the first round it touches.
- **Round 3 — the keystone.** `.value` derived from `name: attribute`, with
  a test pinning name-directed access through a partial, and the two
  exceptions settled first: registrars excluded, `hidden`'s declaration
  reconciled with its behaviour. Lands alone so its cost and correctness are
  measured by themselves. The Symbol trap below is this round's gate: a
  promoted word whose body passes a name onward cannot land until a name and
  a value are distinguishable by something other than their Ruby class.
- **Round 4 — the compositions.** `fact` and `metric`; then `field`,
  `checkbox`, `textarea`, `choice` over `label` and the bare controls. The
  four-copy `<div class="field">` duplication becomes one sentence. Cost
  re-measured here against dan's budget.
- **Round 5 — the rest, argued word by word**, and `table` last or never.
- **Throughout — the count.** Each round reports the kernel's size after
  it, replacing the projection this document no longer makes.

## The picture — `bin/word_graph.rb`

```bash
ruby bin/word_graph.rb   # writes word_graph.html
```

Every word is a node; an edge means *this word's definition says that word*.
Size is consequence — how many words are written in terms of this one. The
partials are parsed with the project's own `Transform` and the primitives are
read out of `words.rb`, so **the picture cannot drift from the code**. Hover
any word to read its definition, Ruby or `.sp`. Two states: `Now`, measured,
and `Proposed`, which is this document's rounds applied — each mode carries
its own counts, because a legend that did not change with the picture would
be a lie the picture tells.

The generated HTML is gitignored: the generator is the truth, and
regenerating is one command.

What it shows that the tables above do not:

- **`figcaption` and `summary` have in-degree 1.** They sit on the floor at
  the size of a speck, next to `box` at 9 and `children` at 10. *An atom
  with one consumer is not an atom* — the picture makes that argument
  without a sentence of prose.
- **The unreached band.** Eight Ruby words that no partial composes over at
  all. They are not the floor; nothing stands on them. Whether that makes
  them primitives or merely un-promoted is exactly this spec's question, and
  the band is where to look for Phase 6's cut list too.
- **The kernel inverts.** `Now` is 42 Ruby / 23 in the language. `Proposed`
  is 33 / 31, and the graph gains a layer — composition gets deeper as the
  floor gets smaller, which is the Rubinius shape drawn.

There is no JavaScript in it: the layout is computed in Ruby, the edges are
static SVG, and the interaction is `:hover` and `:checked`.

### The optional spec — draw it *in* the language (dan's suggestion)

This pays dividends, and not the obvious one. Phase 5 ("Eat it yourself")
already wants this repo's own surfaces served through the language; the word
graph is the best candidate it has, because **the language drawing itself is
the dogfood at its sharpest.**

The dividend is diagnostic. Written honestly as a `.sp` page, the graph asks
for things the vocabulary does not have, and each refusal is information:

- **Positioned nodes.** No word places anything at an x and a y. Nor should
  one — but `chart` already proves the shape of the answer: a word that takes
  a *declaration* of what to draw and computes the geometry in Ruby.
  `Charting` is the precedent and probably the host.
- **Edges.** Curves between computed points; the same answer as above.
- **The hover panel.** `disclosure` is close, and its promotion means the
  page could carry sixty-five of them without a single hand-written class.
- **The mode switch.** Two states toggled with no script. The language has
  no word for a control that changes what is shown — and finding out whether
  that *should* be a word is worth more than the page is.

So the recommendation is to build it **after** Round 3, not before. Attempted
now, it would report gaps that the kernel rounds are about to close, and the
port would be re-authored twice — the same double work that made `tag` go
first. Attempted after, it is a clean read on what the vocabulary still
cannot say, taken with the kernel in its final shape.

## Honest limits

- **The kernel's final size is not projected here**, deliberately. The
  earlier draft said 28–30; dan's `tag` question moved the floor and voided
  it. Each round reports the count it actually leaves behind.
- **`tag` as a privileged word is the one change that could quietly ruin the
  language.** If the privilege leaks — an app partial that can say `tag`, a
  test fixture that gets an exemption, a "just this once" in an example app —
  then hand-authored HTML and hand-authored classes are back, and the thing
  G3 complains about becomes the thing the language *is*. Round 1 exists to
  make that leak impossible before any word depends on it, and Round 1 is
  the round to be paranoid in.
- **A smaller kernel is not automatically a better one.** The test is rule
  five: an atom must be a shape. If `pair` turns out to be `dl` and `div`
  wearing a shared name, it is a worse primitive than the two words it
  replaced, and the round should be reverted rather than argued into place.
- **This spec does not touch `~/dev/dashboard`**, and no round may.
- **Nothing here has been built.** Of the two mechanism claims, one is now
  measured — the box-title branch does fire inside a `figure`, so Round 1 is
  a substitution. The other — that `parameters_for` takes a third derivation
  cleanly — is read from the source and stays unproven until Round 2 lands.

---

## Changes since this spec — re-measured 2026-09-14

The spec above was drafted against the tree at `5d43fe9` (2026-09-03). None
of its rounds have been built; the codebase has moved under it. Every number
here is re-measured, not re-quoted.

**The census.** 42 Ruby words / 22 `.sp` partials / **64 total** (the spec
said 42/23/65). The membership changed and the coincidence of 42 hides both
moves: `meta`, `icon`, `thumb`, `thumbnails` and `image` were cut in
Phase 6 (2026-09-10) — the floor list above names `meta` and `icon`, and
retires with them — and the council's refactor (2026-09-10) added the
`actions` container beside `action`.

**Claims that hold, verified today.**

- `hidden` is still misdeclared — `name: :name`, and it still calls
  `subject.fetch`. The spec's exception 2 stands.
- `parameters_for` still derives only `id` and `label` (builder.rb 441–456);
  the `value` derivation — the keystone — is still unbuilt.
- The cache wrinkle holds verbatim: compilation.rb keys by source, carries
  no path, and composes the refusal at render.
- `tag` is not a word — now twice over: CONTRACTS refuses `:tag` by name
  (contracts.rb 238), and still no vocabulary word emits a `:tag` node. The
  generator's `:tag` path is live and unused by the vocabulary, exactly as
  measured.
- The four-copy `<div class=field>` wrapper is still four copies — `field`,
  `textarea`, `checkbox`, `choice`, generator.rb 465–517. The spec's line
  numbers have drifted; the duplication has not. `figcaption` and `summary`
  still sit in words.rb — Tier 1 is intact.

**Claims that dated.**

- "31 node kinds the Generator interprets by name" — the generator has moved
  past that shape: `emit` special-cases ten kinds (`raw`, `tag`, `each`,
  `choose`, `contents`, `badge`, `money`, `number`, `percent`, `time`) and
  dispatches every other kind to its own named method. The tag helpers are
  still called 76 times (31 `full_tag`, 37 `open_tag`, 8 `void_tag`). The
  thesis survives: the general `:tag` path exists, and the vocabulary never
  uses it.
- The census instrument is vestigial: `PrimitiveShapes.load` scans comment
  blocks over `def`, but words.rb declares contracts with the `contract`
  macro — PRIMITIVES is empty, and CONTRACTS reads the registry lazily. The
  count's one home is now the registry. **Resolved 2026-09-17:** the promise
  ledger found it — a loader with no reader, and no way to have one — and dan
  ruled it deleted; `PrimitiveShapes` and `PRIMITIVES` are gone, and this line
  is the record. See `DAYTRIP-0.3.0b`.
- The graph is broken: `bin/word_graph.rb` requires `bin/word_graph_template`,
  which was never committed and is gone (LoadError). A picture that cannot
  be generated cannot drift-proof anything. The repair is to embed the
  template in the tool; otherwise the section retires.
- The cost has moved, all upward: cold **6.38 ms** (5.83), warm **4.73 ms**
  (3.55), per row **0.22 ms** (0.15) — ruby 4.0.1, specimen.sp, 200 runs.
  The composition tax the spec warned about is compounding; the budget
  decision is more urgent, not less.

**What this changes for the rounds.** The floor list and the tier tables want
the Phase 6 removals applied; the keystone and the rounds remain the unbuilt
proposal. Round 1's privilege discipline is half-anticipated in code (`:tag`
refused by name) but nothing enforces a path-based privilege yet. The
ordering question dan put to this pass is answered in ROADMAP-0.3.md: the
kernel rounds **follow** the studio's winnable victories, demand-gated — and
the budget decision still precedes any Tier 2 work.
