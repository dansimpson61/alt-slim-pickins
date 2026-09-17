# DAYTRIP-0.3.0b — The Accent

**Opened 2026-09-17, on dan's word.** Findings measured the same day, not
quoted. Revision 1 answered his first two observations; revision 2 folded in his
five answers and ran the analysis; revision 3 recorded his five rulings and
repaired a failure of its own naming; this opening turns it into the record the
stops are written into.

The subject his fourth answer named: **transparency, and the managed sources of
truth of sp's conventions and inferences.** The accent audit is the means; the
two instruments are the thing built.

---

## The brief

**His observations (2026-09-16):**

> **1.** Human language and its roots in magic, conventions and inference are
> the central truths that distinguish sp — that *determined the need for sp*,
> because Slim (and all the others) and Tailwind (and all the others) have
> other priorities. I began to identify things we could make real **right
> now** that would be helpful not just for the current roadmap but **essential
> for working with sp forever**.
>
> **2.** We observe — and despise — machine language creeping through tools
> intended for humans to use proficiently and fluently. We see it in HTML and
> CSS, in the Slims and the Tailwinds, **and we see remnants of it persisting
> in sp.** We need to understand well what it is doing in sp, why it persists,
> and how to grow beyond it — or, for the moment, the extent to which we can
> grow beyond it now. Does that include variants and `label_for`, `format_for`?
> Does it include our hashes of attributes? What does that include?

**His answers (2026-09-17), which revision 2 was built on:**

1. On the criterion: *"That sounds correct and should be demonstrable. Is that
   the sole criterion? Maybe! But we should be aware that there may be more or
   more may emerge."*
2. On the three causes: *"Your analysis can answer this, at least for the
   language in its current state."*
3. On the suspects: *"We hypothesize rationally and test empirically, aware
   that our world is not strictly deterministic, rational, or consistent,
   especially when we are working with human beings, perception, intent, and
   preference. Things change, sometimes irrationally. We just want to be alert
   to what we think is important and aware that as things change we may change
   with them."*
4. On what lands: *"What lands are things that make the language
   **transparent**. Some words are better than others and that may be because
   they rely more on conventions and less on hacks and kludges, escape hatches
   and exceptions. Or it may be that better words make better use of escape
   hatches and exceptions. **Transparency is our friend.** Outdated primers and
   grammars, etc., would work against transparency and against us. **The
   sources of truth of our conventions and inferences may have emerged as the
   most important tools we have for shaping the future of sp, so those should
   be apparent, manageable, and managed.** This is how we avoid your three
   failure modes and institute your grades of inference."*
5. On `0.3.0a`: *"Let's hold 0.3.0a to see what's still useful after
   `0.3.0b`."*

**His rulings (2026-09-17), on the five questions revision 2 asked:**

| # | Question | Ruling |
|---|---|---|
| 1 | Is cause D distinct enough from cause B to stand alone? | **Yes.** D stands as its own cause |
| 2 | The 28 claims: taken here, or listed? | **Take the mechanical ones; leave anything arguable** |
| 3 | Which register lands first? | **Both.** — and: *"I swear to God I don't remember what each one does and how they differ from each other."* Which is a finding about revision 2, answered below |
| 4 | Is Stop 5 worth a stop? | **It lands** — *"else we act on the basis of our vague impressions (or most recent impressions)"* |
| 5 | A third criterion? | **Two is enough for now, knowing this is a dynamic process** |

**Ruling 3's second half is the most useful thing in this round.** A document
arguing that transparency is the criterion for what lands was itself
untransparent: it named two instruments in prose and left the reader to tell
them apart. `working-with-dan.md` already records this failure mode — *the fix
is not fewer words but more context: the mechanism, the failure it causes, and a
worked example* — and revision 2 ignored it. The next section exists so that no
reader ever has to remember.

**Answer 4 is the one that moved this document's centre.** An accent audit is
an inventory; the sources-of-truth map is a diagnosis; the two instruments are
the thing built. The audit is the *means*, and the instruments are the *end*.

## The one argument

**sp exists because a page should speak human language about presentation; its
magic is inference and convention; and the truths those conventions rest on are
today the least managed things in the repository — spread across 58 sites in
seven files, enumerated nowhere, checked by nothing, while the grammar, the
contracts, the classes and the theme are each held by a checker in both
directions.** A language that cannot see its own conventions cannot stay
transparent as it grows, and it is about to grow its largest vocabulary ever.

## The question

> **Where does sp still speak machine, and why — and which of its sources of
> truth can be made apparent, manageable and managed now, so that its
> conventions and inferences stay transparent as the language grows?**

## The criterion register — plural, and expected to grow

His answer 1 is taken as written: one criterion is not a claim to be the only
one. So the criteria are held in a register, and adding one is meant to be
cheap.

| # | Criterion | Test | Status |
|---|---|---|---|
| C1 | **Human shape** | Does the page expose the machine's structure where a speaker would point at a thing? | adopted, provisional |
| C2 | **Transparency** | Does it make a truth of the language *apparent* to the person using it? (his answer 4 — the criterion for what *lands*) | adopted |
| C3 | *(expected)* | — | to emerge |

A finding must say which criterion it scores against, and a finding that scores
against none is welcome rather than suppressed — that is how a third criterion
arrives.

---

## Four names, four jobs — the repair for ruling 3

Revision 2 used the word "register" for four different things, which is why its
reader could not tell them apart. That is not a wording problem; it is the
disease this daytrip is about — **one name, four homes.** So the vocabulary is
fixed first, and everything after this section uses these names and no others.

| Name | What it is | What it answers | Who reads it |
|---|---|---|---|
| **The criterion register** | the *tests* a finding or an instrument must pass | "what makes this count as good?" | whoever proposes work |
| **The sources-of-truth map** | the *diagnosis*: every truth the language holds, its home, and its grade (apparent / manageable / managed) | "where is the language's knowledge kept, and is it kept?" | whoever changes the language |
| **The promise ledger** | an *instrument*: every permission, claim and loader, with its reader | **"does it actually do anything?"** | the build, on every commit |
| **The convention register** | an *instrument*: every convention and inference, with its source of truth and its override | **"what will this do when I stay silent, and who decided?"** | a person writing a page |

**The two instruments are the pair that matters, and they catch opposite
failures.**

**The promise ledger** is about what the language *says it can do*. A promise
is a permission the gate grants, a declaration a word makes, or a claim a
document makes, whose effect on a page is **nothing**. The ledger finds the
reader — or records that there is none. It is mechanical, it is a checker, and
it fails the build.

| Named | Where it is permitted | What reads it | Verdict |
|---|---|---|---|
| `if:` | `contracts.rb:242`, universal | nothing | a page renders its guarded sentence anyway |
| `class:` | `contracts.rb:242`, universal | nothing — every word drops it | a page's class silently disappears |
| `PrimitiveShapes` | `contracts.rb:49` | nothing (`PRIMITIVES == {}`) | a loader that has loaded nothing since the day it was written |

**The convention register** is about what the language *decides when you are
silent*. An inference is a decision the page never states. The register names
each one, where its source of truth lives, and the sentence that overrides it.
It is a map a person reads, and a checker holds it against the code so it
cannot rot.

| When the page is silent | The language decides | Its source of truth | The sentence that overrides |
|---|---|---|---|
| `field base_income` | label "Base income", input name `base_income`, its value, and type `number` | `Inference.label`, `Inference.input_type`, `Builder#label_for` | `field base_income, "Base income", type: number` |
| `money .market_value` | money formatting | the word itself (`lib/vocabulary/money.sp`) | nothing to override — the word said it |
| `column market_value` in a table | *nothing* — this is cause A2, the inference that must **ask** | the app's `format_for` | `column market_value, as: money` |

Read the second and third rows together and the whole document is in them: the
page that says the word needs no app answer; the page that infers must ask one,
by name. That is why the convention register and the promise ledger are two
instruments and not one — **the ledger asks whether a permission works, the
register asks who decided** — and it is why ruling 3's "why not both" is right:
they catch different failures, and a language can have a working permission that
decides something nobody can find, or a registered convention behind a
permission that does nothing.

---

## The analysis — his second answer, answered

The causes were a hypothesis (H1). They have now been run against the
inventory, and the analysis finds a fourth. This is the demonstration that the
criterion is demonstrable.

### Cause A — inference took over, and it splits in two

| | What it is | Evidence | Accent? |
|---|---|---|---|
| **A1 — derivable** | the answer is derivable from what the language can already see: the tree, or the value's shape | heading depth from nesting; `card`'s id from its subject; doctype, head, title and layout from `page`; input type and step from the value's class; numeric alignment | **none.** Nothing must be asked, so no channel is needed. These are pure wins |
| **A2 — must be asked** | the answer is *not* derivable, so it must be asked — and the only channel the language has for asking is **a name** | `format_for(attribute)`: `money .market_value` → `$1,284,506` with no app answer; `column market_value` → `$1,284,506` with it, `1,284,506` without. Same shape for `label_for`, and for the `as:`/`type:` overrides that exist only because a word did not say it | **yes — this is where the accent enters** |

> **The rule the split yields:** inference is transparent while it can *derive*
> its answer; it becomes machine language the moment it must *ask* — because
> asking means naming. A1 is invisible and free. A2 is the whole of cause A's
> cost, and it is why an app keeps a dictionary keyed by attribute name.

### Cause B — the abstraction is wrong (a composition wearing a primitive's clothes)

The tell is duplication, exactly as KERNEL.md found in the Generator.

| Site | Count | What it says |
|---|---|---|
| `@kwargs.key?(x) ? @kwargs[x] : nil` in `words.rb` | **23** in 528 lines | every word hand-plucks its own arguments; the abstraction has no declared-argument mechanism |
| `maps content: :body`, written out | **8 identical** | one decision, eight homes — and the eight are KERNEL's non-orthogonal atoms |
| Words that pass an identifier as data | **11 of 64** | each one calls `subject.fetch(name)` by hand; a missing primitive, not a missing word |
| `<div class="field">` in the Generator | **4 copies** | KERNEL's own example of a composition wearing a primitive's clothes |

### Cause C — the host's grammar leaked

`key: value` (a Ruby hash, and the language's only colon); bare `true`/`false`/
`nil` arriving as truthy symbols (so `required: false` means required); `#` as a
comment marker that **eats the author's text** (`note "Total # 1"` is a
`SyntaxError`); the paren machinery in `split_args` with **zero consumers**;
`expects content: true` (33 of its 68 keyword arguments are booleans); the
`@kwargs` idiom; symbol enums (`as: money`, `type: email`).

### Cause D — the source of truth is unmanaged *(found by this analysis)*

His second answer asked whether there was a fourth cause. There is, and his
fourth answer had already named it. **D is a truth with a second home that
nobody maintains** — distinct from B, where two homes exist *by design* because
the abstraction is wrong.

| Site | The truth | Its unmanaged second home |
|---|---|---|
| `PrimitiveShapes` / `PRIMITIVES == {}` | what a primitive word declares | a loader still reading a comment convention that moved to `contract` macros |
| `%i[if class id]` in `contracts.rb:242` | which modifiers are universal | three permissions, zero readers |
| the word census | how many words the language has (**64**) | five documents saying 53 or 50 — **8 mentions** |
| `try_it.sp`'s burr comment | why the editor once had two buttons | a second copy of a decision that `editor_form.sp` already records |
| `markdown.rb:166` | whether alignment colons render | a comment the code beside it contradicts |
| `VOCABULARY.md`'s `infers` slot | what each word infers | **50 bullets for 64 words**, prose, read by no checker |
| the conventions themselves | what the language decides when a page is silent | **58 sites across 7 Ruby files** — enumerated nowhere |

### Provisionality, per his third answer

The four causes are the best rational account this session can produce, and the
map below is a picture of what we currently think is important. The world
this language is for — human intent, perception, preference — is neither
deterministic nor consistent, and preferences change, sometimes irrationally.
So: each cause carries its evidence, each entry carries a date, and the test of
a cause is that it can be *refuted by a case*, not that it feels right. If a
fifth cause emerges, or a cause stops earning its place, the map changes
and we change with it.

---

## Why D is the one that matters

dan's fourth answer, made operational. The three failure modes BLUESKY named:

1. **A convention the reader does not share** is not magic, it is superstition.
2. **A convention that fires invisibly** cannot be corrected, because nobody
   knows it fired.
3. **A convention that cannot be overridden** is a trap.

And the four grades of inference:

| Grade | Source of truth | Managed today |
|---|---|---|
| **structural** — the tree | `Transform`, `Builder`, `Generator` | mostly (check_grammar, check_styles) |
| **shape** — the value's class | `Inference` | yes (tests) |
| **domain** — the app | `CONTRACT.md`, `label_for`/`format_for` | partly (contract_test; *which* words need an answer is not held) |
| **axiomatic** — the design | `:root`, 53 roles | the *source* is managed superbly (no unthemed literal) — and it has **no voice at all** |

All three failure modes are failures of the same thing: **an unmanaged source of
truth.** A convention that lives in one place, is enumerated, is checked, and
shows its override cannot be superstition (it can be looked up), cannot fire
invisibly (it is registered), and cannot be a trap (its override is documented
beside it). That is the whole argument for the two instruments: what is
enumerated and held cannot quietly stop being true.

And the last row carries the surprise that ties this document to BLUESKY's
style question: **the axiomatic grade's source of truth already exists and is
the best-managed thing in the repository — and nothing can speak it.** A style
language, on this reading, is not a new vocabulary bolted onto sp. It is
**giving the axiomatic grade its voice** — and per cause A2, a voice that says
*a name* is exactly the wrong voice, which is why a role vocabulary must be
words the theme owns rather than symbols and numbers a page holds.

---

## The map and the work list

**The sources-of-truth map.** The table above is the start.
The stop completes it for every truth the language holds: grammar, vocabulary,
contracts, presentation, theme, conventions, app contract, and the documents'
claims about the code. Each graded **apparent** (can a person find it?),
**manageable** (is there one place to change it?) and **managed** (does
something hold it true?).

Measured today, the contrast is stark and is the argument:

- **Structural truths: managed, every one.** Grammar — `check_grammar` holds
  every fenced sentence. Contracts — the word's own file, held by
  `check_grammar` and `check_shape`. Presentation — `check_styles`, in both
  directions. Theme — 53 roles, no unthemed literal escapes.
- **Conventional truths: managed not at all.** 58 sites in 7 files; no
  register; no checker reads a convention; 50 of 64 `infers` bullets; the slot
  itself unchecked prose.

**The claim corrections: 28.** His
fourth answer names this as working *against* us: an outdated primer is an
unmanaged source of truth, and it is worse than a missing one because it is
believed. Counted today: 8 stale census mentions (53/50 against a measured 64),
14 `VOCABULARY.md` entries missing their `infers` and `renders` slots, 1
reference to the cut word `icon`, 1 self-contradiction about `heading`, 2 stale
comments (`try_it.sp`, `markdown.rb`), 1 `HANDOFF.md` claim of "six wins" above
a list of ten, and 1 phase heading marked closed everywhere but in itself.

---

## The border, drawn first

**In scope** — evidence, and instruments:

- the audit, the map, and the two instruments, with counts and coverage stated;
- measurements of what a *page author* meets, as distinct from the runtime's
  internals;
- paper alternatives: what a human spelling of a remnant would read like,
  never entered into `lib/vocabulary/`;
- throwaway spikes, deleted or marked;
- **corrections to a claim that lies** — a document or comment asserting
  something the tree contradicts. Answer 4 puts this in scope on purpose:
  transparency is the criterion, and a primer that miscounts the vocabulary is
  a failure of transparency, not a cosmetic drift. The corrections are
  mechanical (re-measure, restate) and decide nothing;
- **landing an instrument** that passes all five tests below.

**The five tests a landable instrument must pass** — answer 4 added the first:

1. it makes a truth **apparent** to a person using the language;
2. it adds no vocabulary and no page-facing spelling;
3. it moves no vital;
4. it is itself held by a test;
5. dan rules it in on the day.

**Out of scope, named so it is not taken by accident:**

- **No new vocabulary or syntax.** Fixing `#` looks small; it is a grammar
  change, and it waits for E4's ruling.
- **No kernel motion.** The 23 interrogations, the 8 `maps`, the 11
  name-directed words are *mapped*, and Phase 3 grows only what a real sentence
  demands. This daytrip does not get to be that sentence.
- **No restyle of the studio**, and no new pane.
- **`~/dev/dashboard` stays read-only.**
- **W1–W3 stay parked**; **`DAYTRIP-0.3.0a` stays held**, per his fifth answer.
- **No rewriting of history.** A record that describes the language as it was
  is not a lie — `history/` and the phase records stay as written. Only
  present-tense claims about the current tree are corrected.

---

## The stops

### Stop 1 — The accent audit  `agent` — evidence only

The centrepiece, now with the analysis above as its spine rather than its
hypothesis. Walk both surfaces — **on the page** (what an author writes) and
**inside** (what the language says to itself) — and classify every
machine-shaped spelling: what it is, what it is doing, its cause (A1, A2, B, C,
D), and the count that makes the claim inarguable. Nominees to interrogate:
the `key: value` form and its four value kinds (134 arguments: 89 bare names,
20 quoted, 17 data, 8 numbers); `.property` and `binding.property`; the 11
identifier-passing words; `expects` and its 68 keyword arguments; `maps`; the
23 `@kwargs` interrogations; symbol enums; the `#` marker; the paren machinery;
silent fallbacks (an unknown variant degrades, an unknown word fails loudly);
the internal node IR; `tag`/`html` as the page's door to raw HTML and CSS.

*Artifact:* the classified table, with the **inside/outside split** answering
"how far can we grow now" — every page-facing remnant either on a grow-now list
with its cost or on a waiting list with its reason.
*Feeds:* every instrument and decision below.

### Stop 2 — The three suspects  `agent` — paper only

dan's explicit questions, each interrogated through cause A1/A2.

- **Variants.** Test: is a variant a *word* — a name a speaker means, which the
  language refuses when it does not know it — or a *property value*, an open
  enum that degrades silently? The evidence is already sharp: `badge banana`
  renders an unstyled chip while a misspelled *word* fails loudly. Verdict plus
  the paper alternatives.
- **`label_for` / `format_for`.** Cause A2's paradigm case. Draft the
  alternatives on paper — **value-shaped** (the app returns something that
  knows it is money, so the language asks the thing and never a table),
  **word-carried** (the page says `money`, which it already can), **domain-noun**
  (the app's own vocabulary names its figures) — each priced in what it costs
  the app, what it buys the page, and what it does to the three-level
  precedence. Note for honesty: dan judged `label_for` *not onerous* on
  2026-08-30, and that ruling stands unless the evidence contradicts it; this
  stop prices alternatives, it does not re-open a decision.
- **The attribute hashes.** Three things wear one name: the **node attrs
  hash** (the IR a second interpreter would walk — a legitimate interface);
  the **kwargs hash** (23 interrogations of what are conceptually the word's
  arguments — plumbing); and the **contract's keyword declaration** (the word's
  own file, 68 keyword arguments, 33 booleans — accent). Verdict per hash.
  A fourth nominee from revision 1, for dan's ruling: **the silent-fallback
  family**, of which `badge banana` is one instance.

*Feeds:* E1, E2, E3.

### Stop 3 — The map, and the two instruments  `agent`, lands both by ruling 3

**The stop answer 4 asked for.** For every truth the language holds, name its
home and grade it **apparent / manageable / managed** — that is the map. Then
land the two instruments, which ruling 3 says are both taken, and work the
claim corrections, which ruling 2 says are taken where they are mechanical.

**Lands — the promise ledger.** A checker: every universally-permitted modifier
read by some word; no word declaring a modifier it ignores; every loader and
documented feature with a consumer. *Retro-catches:* `if:`, `class:`, `id:`, and
the dead `PrimitiveShapes`. **Lands — the convention register.** The conventions
and inferences enumerated in one place, each with its source of truth, its
override, and its grade, held against the code so it cannot rot. *Retro-catches:*
why 50 of 64 `infers` bullets, why 58 convention sites across 7 files with no
register, and the `label_of`/`format_of` asymmetry LORE records.

**Worked, not landed — the claim corrections.** Ruling 2 takes the mechanical
ones (a re-measured number, a comment the code beside it contradicts) and leaves
anything arguable for its own ruling. The arguable ones, named now rather than
quietly fixed: whether `VOCABULARY.md`'s 14 slot-incomplete tail entries get
`infers`/`renders` written for them or are re-homed; whether `HANDOFF.md`'s
"six wins" is corrected or the file is allowed to be a historical prompt; and
whether `heading`'s self-contradiction is resolved by deleting the older
sentence or by dating it.

**Stays a spike — the inference ledger.** Every rendered value attributed to
page, app, theme or inference, with the **residue** named. *Retro-catches:* the
table that read its headers off the wrong subject. It is the studio's fourth
pane and the precondition for any style vocabulary, and it is not ruled in.

*Artifact:* the map complete; both instruments landed with their tests; the
mechanical corrections made and the arguable ones listed.
*Done looks like:* the promise ledger fails the build today on the four known
promises; the convention register enumerates every inference site in the code
and holds; and a second run of the gate is green.

### Stop 4 — The duplication map  `agent` — evidence only

H2's test: *is the accent thickest exactly where the abstraction is wrong?*
Map every duplication site — the 23 interrogations, the 8 identical `maps`,
the 11 name-directed words, the four-copy field wrapper, the dead
`PrimitiveShapes` — and say what each is evidence *of*. KERNEL.md's rule
generalises: duplication in the Generator is the reliable signal that a word is
a composition wearing a primitive's clothes; this stop asks whether duplication
anywhere is the reliable signal that a spelling is a mechanism wearing a word's
clothes.

*Artifact:* the map, with H2 declared supported, refuted, or partly — and the
cause-B findings handed to Phase 3's demand ledger.
*Done looks like:* H2 has a verdict backed by counts.

### Stop 5 — Transparency, measured  `agent` — evidence only

The daytrip's second criterion, given its own instrument, because answer 4 made
it the criterion for what lands and it should not be allowed to remain a
feeling. For a sample of the language's words — the best and the worst by
inspection — measure the three things transparency seems to mean in practice:
how much of the word's behaviour is **convention** (derived), how much is
**declared** in its own file, and how much is **escaped** to Ruby, a modifier,
or the app. dan's own hedge is the point: a word may be *better* because it
leans on convention, or because it uses its escape hatch well. The measurement
is what tells us which.

*Artifact:* the sample's three-way split per word, and a first answer to "some
words are better than others".
*Done looks like:* the claim has numbers, and the counter-examples (a
convention-heavy word that is *worse*) are named rather than smoothed over.

---

## Round record (2026-09-17)

**All five stops taken**, in two sittings on the same day: the instruments and
the audit first, then the three suspects, the transparency measure, the `if:`
decision aid, and one ruled subtraction. The gate is green before and after and
no vital moved.

### What landed — the two instruments, as ruled

**The promise ledger** (`lib/slim_pickins/promises.rb`, `bin/check_promises.rb`).
**33 promises**: 27 modifiers declared by words, the 3 the gate permits
universally, 2 loaders, and 1 helper. Every one names its reader — except
**three that have none**, recorded rather than hidden:

| No reader | What it is | Disposed by |
|---|---|---|
| `if:` | the gate permits it on every sentence, no code consults it; the page renders anyway | E4 |
| `PrimitiveShapes` | a loader still reading a comment convention that moved to the `contract` macro; `PRIMITIVES` is `{}` | E7's territory |
| `boolean?` | `Inference.boolean?` is defined and called nowhere in the repo | new — needs a ruling |

It is green in the gate and `--strict` names the three, which is the difference
between an instrument and a decoration. It caught two things in its first hour:
that `id:` is *both* gate-universal *and* declared by `box` (a modelling error
in my own ledger), and the dead helper above. And it documents what nothing
documented: `actions path:` reaches a descendant `action` through
`Chain#container_value`, while `tab active:` is read by its *parent*,
`Generator#tabs` — the two readers a name-search would have got wrong.

**The convention register** (`lib/slim_pickins/conventions.rb`,
`bin/check_conventions.rb`). **37 conventions**, each with the situation, the
decision, its home (file + marker), the sentence that overrides it, and its
grade:

| Grade | Count | Examples |
|---|---|---|
| structural | 26 | the document, the layout, heading depth, the plural, `empty`, the box's element |
| shape | 7 | input type, step, numeric alignment, the format family |
| domain | 3 | the label, the format, the table header — each asking page, then app, then English |
| **axiomatic** | **1** | **the theme's 53 roles — an entry that records an absence** |

It holds in both directions: every entry's home must still exist, `Inference`'s
15 public functions must be exactly partitioned between the register and a named
internal list, and every word whose contract declares an inference (`card`,
`section`) must be registered. It caught `Inference.number` and
`Inference.percent` unclaimed on its first run.

Both are pinned by `test/instruments_test.rb` (11 runs, 225 assertions), both
are gate legs in `HANDOFF.md` and `README.md`, and both are legs 4 and 5 of the
studio's status page — which now runs **six** legs, so the page that claims the
gate is green claims the whole gate.

Two smaller repairs fell out of the wiring, both instances of the daytrip's own
subject: the universal modifier list moved out of a method body into
`Contracts::UNIVERSAL_MODIFIERS` so a checker can read it, and the canned status
shape became `StudioStatus.canned_locals` — it had been written out twice, once
in `bin/verify_pages.rb` and once in `studio_docs_test`, and both copies would
have gone stale the moment two legs were added.

**The mechanical claim corrections: 12 taken.** The census in `README.md` (×2),
`DESIGN.md` (×2), `PRIMER.md` (×3), `VOCABULARY.md` (×1) and `check_shape.rb`'s
own header — 53 and 50 and 45-of-50 against a measured **64 words, 59 of them
carrying the noun register**; the `icon` reference in `VOCABULARY.md`, a word cut
in 0.2 Phase 6; and the two stale comments (`try_it.sp`'s burr, `markdown.rb`'s
alignment colons, where the code beside the comment was right). Each corrected
line says in place what it used to claim and why that was wrong — a correction
that hides itself teaches nothing.

**The arguable ones are named and left**, per ruling 2: `VOCABULARY.md`'s 14
entries still missing `infers` and `renders`; `HANDOFF.md`'s "six wins" above a
list of ten; `VOCABULARY.md`'s `heading` self-contradiction; `ROADMAP-0.2.md`'s
Phase 6 heading unmarked as closed.

### Stop 1 — the accent audit

The inventory, classified by cause and counted. The split that mattered is
**on the page** (what an author writes) against **inside** (what the language
says to itself), and it produced the day's most useful number.

| Where | What | Count | Cause |
|---|---|---|---|
| page | dot-paths — `.market_value`, `binding.property` | the morphology itself | — (linguistic: possession) |
| page | `key: value` modifiers | **134**, of which 89 bare names, 20 quoted, 17 data, **8 numbers** | C (a Ruby hash), and the 8 are the machine's share |
| page | quotes | — | — (linguistic: quotation) |
| page | `#` starts a comment | 1 rule | **C — and it eats the text**: `note "Total # 1"` is a `SyntaxError` |
| page | a variant is an open enum | any string accepted | A2/D — `badge banana` renders unstyled where an unknown *word* fails loudly |
| inside | `expects` keyword arguments | **68** across 22 declarations, **33 booleans** | C |
| inside | `@kwargs.key?(x) ? @kwargs[x] : nil` | **23** in 528 lines | B |
| inside | `maps content: :body`, identical | **8** | B |
| inside | words passing an identifier as data | **11 of 64** | B |
| inside | `<div class="field">` in the Generator | 4 copies | B |
| inside | node kinds the Generator special-cases | 9, plus ~30 named methods | — (the internal IR; a page never says one) |
| inside | parenthesised arguments in `split_args` | 0 consumers | C |
| inside | symbol enums (`as: money`, `type: email`) | — | C |
| gate | universal modifiers with no reader | `if:` of 3 | **D** |

**How far the language can grow beyond the accent now**, which is what dan
asked: the page surface is **mostly already fluent**. 89 of its 134 modifier
arguments are bare names and 37 are data or quoted text; only **8 numbers** and
one comment rule are machine-shaped, and the vocabulary itself is clean — every
declared modifier has a located reader. The accent is concentrated *inside*: 23
hash interrogations, 8 duplicated slot-renamings, 11 name-directed words. That
is a much better position than the essay assumed, and it is the opposite of what
I expected to find.

### Stop 4 — the duplication map, and H2

| Duplication | Count | What it is evidence of |
|---|---|---|
| `@kwargs.key?(x) ? …` | 23 | the word abstraction has no declared-argument mechanism |
| `maps content: :body` | 8 | KERNEL's non-orthogonal atoms: eight words that are one shape |
| `subject.fetch(name)` written by hand | 11 | a missing primitive (name-directed access), not a missing word |
| `<div class="field">` | 4 | KERNEL's own case: a composition wearing a primitive's clothes |
| the canned status shape | 2 | found *today*, in this round's own wiring |

**H2 is partly supported, and the counterexample is the more interesting half.**
It holds where a *name* repeats: every duplication site is a place a word is
doing two jobs. It fails where a *permission* repeats: `if:`/`class:`/`id:` sit
in a whitelist with no reader at all, and no abstraction is wrong there — the
fault is an unmanaged list. So repetition is a reliable sign of a wrong
abstraction, and *silence* is the sign of cause D. Two different tells for two
different causes; the map found both.

### Stop 2 — the three suspects, interrogated

**Variant: it is a word, and the language should refuse one it cannot style.**
The concept is linguistic — a specifier, an adjective on a noun ("a *warning*
note"). What is machine-shaped is not the variant but its **openness**: the
contract declares that a name slot exists (`name: :variant`) and never which
names are legal, so `badge banana` renders `class="badge badge--banana"` — an
element with no rule, silently unstyled — while a misspelled *word* fails
loudly on its line. The stylesheet already knows which variants exist
(`check_styles` computes every class a rule defines), so the honest rule is
available and cheap: **a variant a page says must be one the stylesheet can
style.** That keeps the set open to apps — an app that adds a variant adds its
rule in the same breath — and closes the silent case. Verdict: cause D, not
cause C; a source of truth (which variants exist) that nothing manages.

**`label_for` / `format_for`: keep them, and let the register say when they are
needed.** The mechanism is sound — three levels of precedence, each owned by
whoever knows most — and the measurement explains rather than condemns it: the
app's dictionary exists *only* where a word stopped being said (`money
.market_value` needs no answer; `column market_value` needs one). Four
alternatives, priced on paper:

| Alternative | Costs the app | Buys the page | Removes cause A2? |
|---|---|---|---|
| keep the name-keyed table (today) | a parallel dictionary keyed by attribute name | nothing to learn; a plain Struct still works | no |
| **value-shaped** — the value knows it is money | a type per concept, wrapping at the boundary | the language asks the *thing*, never a table | **yes** |
| **word-carried** — the page says `money` | nothing | already works (`as: money` is this) | partly — it moves the choice to a symbol enum (cause C) |
| **domain-noun** — the app's own noun presents itself | a presenter per domain noun | the app's vocabulary does the talking | yes, at a higher price |

The evidence does not contradict dan's 2026-08-30 ruling that `label_for` is
*not onerous*; it explains why the seam exists at all. The register now records
which words need an answer, which is the visibility fix available today. The
value-shaped path is the only one that removes cause A2 rather than managing it,
and it is priced here rather than recommended.

**The three attribute hashes, separated:**

| Hash | What it is | Verdict |
|---|---|---|
| the **node attrs hash** (`[:metric, {name:, label:, …}, []]`) | the IR a second interpreter would walk | **legitimate interface** — LORE already argues a word must not carry what the tree can show. Undeclared keys, but a schema per node kind would be a second home for the contract |
| the **kwargs hash** (23 × `@kwargs.key?(x) ? @kwargs[x] : nil`) | the word's own arguments, delivered as a hash | **plumbing** — 23 copies of one mechanism is cause B, not a language question; the fix is a helper in `words.rb`, not a page-facing feature |
| the **contract's keyword declaration** (68 arguments, 33 booleans) | the word declaring itself | **accent** — a flag language (`content: true`) for what means "this word takes content". Real, and *not* worth rewriting now: it is read by word authors, not pages, and the register's better home touches the same files for more |

### Stop 5 — transparency measured

The design, chosen so that the numbers mean something: every word is classified
by **how it is written**, which is the one thing about transparency that can be
counted without taste.

| How it is written | Words | Declared modifiers | Corpus uses |
|---|---|---|---|
| **composed** — written in the language (`.sp`) | 22 (34%) | 13 — **0.59 each** | 134 — 6.09 each |
| **shaped** — Ruby, but only declarative inheritance (`Encloses`, `Says`, …) | 15 (23%) | 9 — **0.60 each** | 84 — 5.60 each |
| **bespoke** — Ruby with its own `evaluate` doing real work | 27 (42%) | 23 — **0.85 each** | 211 — **7.81 each** |

Two readings, and the second is the one the evidence supports.

**The hypothesis holds on flags:** the words written in the language declare
**42% fewer modifiers each** than the bespoke ones (0.59 against 0.85). A word
that leans on convention asks less of the page. That is dan's first reading,
measured.

**But the corpus leans hardest on the bespoke words.** Of the twelve most-used
words, seven carry Ruby (`field` 28 uses, `column` 25, `when` 15, `choose` 15,
`page` 14, `box` 14, `metric` 13) and four are composed (`section`, `text`,
`note`, `item`). So the escapes are not hacks sitting where a convention should
be — they are load-bearing, and the most-used word in the whole language is
`field`, whose four inferences and three modifiers are exactly where the Ruby
is. dan's hedge — *"or it may be that better words make better use of escape
hatches and exceptions"* — is the better reading of this measurement, and the
naive conclusion ("promote everything to `.sp`") is refuted by the same table.

Honest limits: this counts *structure* — origin, declared flags, uses — not
quality. It cannot say a word is well named, well shaped or pleasant, and it
does not try.

### The `if:` decision aid — precisely how `if:` and `when` differ

dan asked to see the difference before ruling. Here it is, with a prototype
rather than an opinion.

**What each is for.** They are not two spellings of one thing; they answer
different questions.

| | `if:` | `choose` / `when` / `otherwise` |
|---|---|---|
| the question | *should this one sentence exist?* | *which of these alternative contents is the true one?* |
| shape | a modifier on a sentence | a word whose children are branches |
| the silent case | nothing — the sentence simply is not there | `otherwise`, which has its own children |
| cost in the page | none; it rides the existing line | a block and a level of indentation |
| picks | one sentence | exactly one branch — the first truthy `when`, else `otherwise` |
| renders | the sentence, or nothing | the chosen branch's children, in the choose's place |

**The rule for choosing:** *does the case where it is false have something to
say?* If no, `if:`. If yes, `choose`. And `empty` is the third: when the
situation is "the collection I name has nothing in it", neither is written at
all — the situation is named.

```text
section accounts
  empty "No accounts linked yet."          # the situation, named
  each account
    button primary, "Archive", if: .idle?  # one sentence, no alternative
    choose                                 # the false case has content
      when .archived?
        note quiet, "Archived."
      otherwise
        note quiet, "Active."
```

**The prototype, measured in a throwaway process** (a single guard in the word
dispatch; nothing on disk): `if: .show` renders with `show` true and suppresses
with `show` false; a guarded word with children suppresses the **whole subtree**
and the children never run; inside `each` the guard is **per row**, which is
exactly the shape `choose` cannot express — LORE's win-3 record shows two
independent rows needing two sequential `choose`s today.

**What it would cost, and the trap it inherits.** Cost: one guard where words
are dispatched. Trap: there is **no boolean literal**, so `if: false` is not a
sentence a page can write — `false` arrives as the truthy symbol `:false` and
the guard is skipped. `if:` therefore takes data (`.paid?`) or an app helper,
never a literal. That is consistent with the language's morphology (a bare word
is language, a dot is data) and it is still a trap worth naming.

**The state today:** `when` works; `if:` does not, so every `if:` in
`DESIGN.md`'s guessability fences renders its sentence unconditionally. The
ruling (E4) is dan's and is still open.

### The helper and the loader

**The loader is deleted** (dan's ruling, 2026-09-17): `PrimitiveShapes` and
`PRIMITIVES` are gone, the ledger is 32 promises rather than 33, and the record
of what it was keeps its place in the code comment, this document, KERNEL.md's
addendum and the ledger's own comment. What replaces it is what had already
replaced it — the `contract` macro and the `expects` preamble, read by
`CONTRACTS`.

**`boolean?` — where it would be helpful, asked and answered.** It asks
"is this value true or false?". The only place that question is live is
`Inference.input_type`, which maps `true`/`false`/`nil` to `:text` — **inline,
without calling the helper** — so `field done` over a boolean renders
`<input type="text" value="true">`. The one use that would earn the helper its
keep is a feature, not a fix: *a `field` over a boolean could infer a checkbox*
— and that is not a call to the helper, it is a decision that `field` should
render checkbox-shaped markup, which the `checkbox` word already owns. My honest
answer to "where would it be helpful": **nowhere today.** It is recorded and
waiting on its ruling rather than deleted.

### The round's own defect: a date measured once and re-quoted

Every date in this document said **2026-09-16** for work committed on
**2026-09-17**. I read the clock once at the session's start and re-used the
answer for three rounds — in a daytrip about unmanaged sources of truth, whose
own first rule is *verify before asserting*, and whose lore already says *a
number written once gets re-quoted, not re-measured*. The correction is in
place, and the timeline is in git for anyone who wants it. It is the cheapest
possible demonstration of the thesis: a truth with one home and no checker
rots in place, and a date is such a truth.

### The second sitting — the rulings that closed it

**dan's question: why not make `if:` work *and* give the language a `not`?**
Asked as a question, answered as one, and the answer is no — with the reason
that decides it.

- **`not` is syntax, not vocabulary.** Verified: `if: not .paid?` is refused
  today with *"not .paid?" is not an argument*, because the language has no
  expression grammar — an argument is a name, text, data or a modifier, and
  nothing composes. Admitting `not` means teaching the grammar a unary operator,
  which is the one thing the founding sentence forbids (*extending the language
  adds vocabulary, never syntax*).
- **It is the top of a slippery and well-known slope.** A language with `not`
  has a reader asking for `and`, `or`, `==`, `>` — the expression language CSS
  and Tailwind are made of, and the thing dan's second observation despises.
- **The doctrine already assigns negation to the app.** *Facts encoding a human
  judgement about the domain belong to the app* — and "is this paid?" and "is
  this unpaid?" are the same judgement. `if: .unpaid?` compiles **today** and
  costs the app one method; `choose / when .paid? / otherwise` covers the case
  where the false branch has content of its own.
- **`unless:` is not a middle way.** It would compile as a modifier and alias
  `if: not` — two spellings for one meaning, which rule 4 exists to refuse.

**So `if:` landed and `not` did not.** What remains of the gap is the missing
boolean *literal* — `if: false` is not a sentence a page can write — and that is
E3's question about `key: value` values, not a reason to add an operator.

**`if:` landed, honoured by the transform.** The guard is hoisted out of the
arguments at compile time rather than left for the words, for two reasons: a
hatch word is `extend`ed onto the builder and never passes through the dispatch,
so the words cannot be the place; and hoisting runs the guard *before* the
sentence's other arguments and before a word's children, which is the same
choice `when` already makes for its condition. The modifier no longer reaches
the word, so a predicate is evaluated once. Nine tests in
`test/guard_test.rb` — true, false, children taken along, per-row inside
`each`, guard-before-arguments, a hatch word, the hoist in the compiled Ruby,
the gate still permitting it, and `style:` still refused. One consequence is
closed with it: `StudioPages.refs_of` now reads the guard, or the studio's
synthesized payload would stop carrying a guarded sentence's predicate.

**The checkbox landed** (dan's ruling), and `Inference.boolean?` — dead since it
was written — is the helper that decides it. A `field` over a true/false value
now renders the shape the `checkbox` word draws; `type:` overrides, as every
inference is overridable by saying the thing; a bare `input` is unchanged. The
shape itself got one home (`Generator#checkbox_field`), because two words now
draw it. Registered as the `boolean_field` convention, shape grade, with its
override.

**And the ledger is empty.** 32 promises, **none without a reader**, and
`bin/check_promises.rb --strict` green for the first time since it was written —
which is what "a promise with no reader is a finding" was for.

**`bin/check_card.rb` landed** (dan's ruling): the resume card's frontmatter
held by the gate, naming the field and the line when it breaks. It reproduces
the historical failure on demand — reintroduce the colon-space and it says
*"a colon followed by a space inside an unquoted value is the usual cause"*.
The gate is seven legs now, and the status page shows all seven.

**The teardown landed — and my earlier proposal about it was wrong.** I had
written that `compilation_test`, `phase3_test` and `phase6_test` leak the same
way and wanted the same fix. Measured after the whole suite: the registry holds
78 words, and the ones that are not the language are 14 **app words**
(`account_card`, `editor`, `queue`, …) registered by `Library` because the
registry is global by design — **not one declares a novel modifier**, which was
the only thing that ever hurt. The `tone:` leak in `partial_args_test` is fixed
and was the only instance that mattered; the general property is already
recorded in ROADMAP-0.3 as a Phase-3-sized change awaited. A proposal withdrawn
is worth as much as one made.

### Honest limits

- The classification is **judgement wherever it is not a count**. The counts in
  the table are measured; the assignment of a cause is argued, and a reader
  should be able to refute one case at a time.
- **The register is a second home, and it knows it.** Its 37 entries are
  hand-authored prose held to the code by a checker that verifies the *homes*,
  not the prose. The better home is the word's own declaration — an `infers:`
  slot in the contract, generating the document as the five checkable bullets
  already are. That is a vocabulary-file change and it is named here as the
  next step, not taken.
- The ledger's discovery is a scan for *declared* modifiers. It catches what a
  word declares; it would not catch a promise expressed inline somewhere else.
- Two sample sets are small: the transparency split is 134 arguments and the
  H2 map is five sites.
- The studio on :4580 is running a boot from before this round — its status page
  shows the old leg list — because the process is outside this session's sandbox
  and cannot be signalled. The new code was verified on a spare port and the
  spare killed. `/guides/DAYTRIP-0.3.0b` and `/guides/BLUESKY` are live either
  way, since guides are read from disk.

---

## The space this leaves for decisions

| # | Decision | Options on the table | What would settle it | Who |
|---|---|---|---|---|
| E1 | What *is* a variant? | a word (closed; unknown refused) · an open enum (as today) · **a word the stylesheet can style — a variant with no rule is refused** | Stop 2's verdict: the defect is the silent fallback, not the variant | dan |
| E2 | Where the app answers by name | **keep the channel, and let the register say when it is needed** · value-shaped (the only path that removes cause A2, priced in Stop 2) · word-carried · domain-noun | Stop 2's priced alternatives | dan |
| E3 | Is `key: value` the right human form for configuration? | keep · a different form · numbers to the theme | Stop 1's modifier census and Stop 5's transparency split | dan |
| E4 | `#` as a comment marker | respect quotes · a different comment rule · no page comments | the damage list | dan |
| E5 | **Which sources of truth get registered and managed** | ~~the convention register · the promise ledger · …~~ **RULED (3): both instruments land, and both are held by a test** | — | ruled |
| E6 | **When inference takes a decision from the page, who owns it and where do they speak?** | the app answers by name (today) · the value answers · the theme owns it · the page says the word | Stop 2 + Stop 3; cause A2's whole cost | dan |
| E7 | Does `tag` close, and in what order | close first · design first · together · leave it and stop calling it a leak | its blast radius, absorbed from `0.3.0a` Stop 5 | dan |
| E8 | Would a style vocabulary be more machine language, or the axiomatic grade's voice? | it would be more (refuse it) · it can be fluent if scoped to roles the theme owns · undecidable until a page tries | the style round's own drafting — **not this daytrip** | dan |
| E9 | Is there a third criterion? | **RULED (5): two is enough for now, and the process is dynamic** — a third may emerge or be added | — | ruled |

**E6 and E8 remain the deep two**, and the analysis has now connected them: an
inference that must ask speaks in names (A2), and the axiomatic grade is the one
grade whose source of truth is already managed and has no voice. If sp learns
to speak the theme as *words*, the accent retreats; if it learns to speak it as
*symbols and numbers*, the style language becomes the accent's biggest
beachhead.

## Relationship to `DAYTRIP-0.3.0a` — held

His fifth answer: held, to see what is still useful after this one. It is not
superseded and not withdrawn. Two of its stops are absorbed here (the `tag`
blast radius as E7; the ownership spike as instrument 4). Its style drafting —
Stop 3, *can the theme be said?* — is deliberately **not** absorbed: that is
decision-shaped work and belongs to the style round this daytrip is meant to
prepare. Its file is untouched, and after this daytrip closes we read it again
against what we learned.

## What this would deliberately not answer

- **Whether a stranger hears the same accent.** No one outside the project has
  written a page; every judgement here is made by a speaker of the language.
- **Whether C1 and C2 are the right criteria** — only whether they are
  demonstrable, which is what his first answer asked for.
- **Whether any of it is affordable.** The cost instrument last read 7.71 /
  5.65 ms / 0.26 ms per row, and the budget Phase 3 waits on is still unset.
- **Where the repairs go.** Every cause-B finding belongs to Phase 3 and waits
  for a real sentence.

## Risk register

| Unknown | Risk | Retired by |
|---|---|---|
| "Machine language" becomes an aesthetic complaint | **High** | the criterion register; every finding carries a count, and judgement is marked as judgement |
| The audit becomes a refactor | **High** | the border: nothing is fixed except a claim that lies |
| The instruments become another unmanaged source of truth | **High** | they are graded *managed* or they are not finished: the promise ledger is a checker that fails the build, and the convention register is held against the code |
| An instrument lands that decides a question | **High** | the five tests, ruled on by dan the day it lands |
| Correcting 28 claims becomes a documentation project | Medium | the corrections are mechanical and each is a re-measurement, not a rewrite |
| The analysis is believed because it is tidy | Medium | each cause carries a refuting case; a cause that cannot be refuted is a cause we cannot test |
| The daytrip grows into the style round | Medium | E8 is explicitly not this daytrip's to answer |

## How this stays accountable

The gate, in its stronger form: as green at the end as at the start, with the
day's artifacts showing as documents and instruments, never vocabulary.

**The command is not the one this section first carried, and that is the
daytrip's own doing.** It opened with four legs and closes with seven: the three
instruments it landed are legs of the gate they are held by — an instrument
nothing runs is not an instrument. So "unchanged" was the wrong word to freeze,
and the honest form is the command plus the two rules that came out of the round:

```bash
ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/check_promises.rb && ruby bin/check_conventions.rb && ruby bin/check_card.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby "$f"; done
```

**Read the exit codes, not a summary of them.** Running a leg as `… | tail -2`
reports the *pipeline's* status — the last command's — so a red leg reads as
green. That bit twice in this round, once fatally: `check_card.rb` printed
`1 problems` on the day it landed and the commit went in anyway, because the
check had been piped. Run the legs as a conjunction, or check each status, and
read the whole output before committing.

Closed: 705 sentences (the checker's, which never counted declarations), 64
words, 94 rules, 14 pages, 326 runs / 0 failures across three seeds, 25
affordances / 0 missing, **32 promises and none without a reader**, 38
conventions. And the shape checker's own vitals moved — 479 → 457 sentences,
25 → 17 distinct modifiers — because it had been counting declarations as
sentences; that is a conversation, and it is recorded above.

## Where the daytrip closes

All five stops are taken, and everything it named as landable has landed: the
promise ledger and the convention register (ruled in), the mechanical claim
corrections, the loader deleted, `if:` honoured, `field` inferring a checkbox,
`bin/check_card.rb`, and the test teardown. **The ledger holds 32 promises and
none without a reader**; the register holds 38 conventions, every one with its
home and its override; the gate is seven legs and the studio's status page shows
all seven.

### E1 — a variant nothing can style is refused *(landed)*

The refusal lives in `check_styles.rb`, which already owns the class-to-rule
question, and it walks the whole corpus rather than only what one script
renders. **It is a gate refusal and not a runtime one, and that is not a
compromise**: the rule that decides it lives in the stylesheet, and the runtime
never reads the stylesheet. A page's variant is therefore refused at the gate
and not as you type — named here as the limit it is, with the follow-up it
implies: the studio *does* serve the stylesheet, so the playground could refuse
one live, and that is a round's work rather than this day's.

It found two on its first run, both real and both recorded rather than fixed,
because styling them is a design decision and dropping them is a page change:
**`grid--cards`** (said in `pages/specimen.sp`) and **`grid--metrics`** (said in
`specimen.sp`, portfolio's `index.sp` and roth's `report.sp`) are variants the
stylesheet cannot style — so three real pages say a word that means nothing
visual. They are printed on every gate run until ruled; a third one, injected to
prove the check, fails the gate.

### E2 — the app's answers stay *(ruled, no code)*

`label_for` and `format_for` keep their place, with the register as the
visibility fix: it now names which words need an answer and the sentence that
overrides it. The value-shaped path — the only one that removes cause A2 rather
than managing it — stays priced in Stop 2 and unbuilt.

### E3 — literals in a modifier's value *(landed)*

`true`, `false` and `nil` are literals where a modifier's value goes, and names
everywhere else. The justification is the project's own recorded division and
not a new one: **a modifier's value is configuration, a positional argument is
content, and content belongs to the app** — which is exactly why a bare number
was already legal there and illegal as content. It closed two silent
wrongnesses: `required: false` meant *required*, and `open: false` rendered
`open="open"`. It also gave the `if:` guard its false. Seven tests in
`test/literal_test.rb`, one of them pinning that `note true, "x"` still compiles
to the *name* `:true`.

### The register's real home — why my option 1 was an un-DRY mess

dan asked, and he is right as I stated it. Putting `infers:` prose in each
word's own file would copy *one* convention into every word that triggers it:
`plural` is one rule that `each`, `table` and `chart` all use, `presentation`
is one rule that `table`, `chart` and `metric` all use. Four copies of *a
number is right-aligned* is the disease this daytrip is about, wearing the cure's
clothes. **Withdrawn as proposed.**

The DRY shape is a reference, not a copy: the convention is declared **once
where it is implemented** — the register is already that — and a word's file
declares **which conventions it uses, by name**. `VOCABULARY.md`'s `infers`
bullets are then generated by joining each word's names to the register's prose.
One home, N references, and the checker already proves the names resolve. The
cheaper alternative is to derive the links from the code — the partition check
already does this for `Inference`'s functions — but a word can trigger a
convention inline in its own `evaluate`, which is most of the 58 sites, so the
derivation would be partial and the partiality would have to be declared
anyway. **Recommendation on record: the reference shape.** It is a round's work
and it is not next.

#### The reference shape, proposed concretely *(dan asked to hear it)*

1. **The register stays the one home of convention prose** — one entry per
   convention, keyed by name, as it is today.
2. **A word's own declaration names the conventions it uses.** A new contract
   slot, spelled like the one this round landed: `infers: label`, `infers:
   plural`, repeatable, in the preamble and in `words.rb`'s `contract` calls.
   It is a reference — a name, never prose.
3. **`VOCABULARY.md`'s `infers` bullets are generated** from those names plus
   the register, exactly as the five checkable bullets are generated today by
   `bin/generate_vocabulary.rb` and held by `check_grammar.rb`. The 14 entries
   that are missing the slot today become impossible, because the generator
   demands them.
4. **The checker holds it in both directions** — every name a word declares
   exists in the register; every register entry is used by at least one word (a
   convention with no user is the promise ledger's question asked of prose);
   and the document matches what the generator produces.

**The subtlety that makes this a round rather than an hour:** not every
convention is triggered by a word. `document`, `layout`, `theme_roles`,
`first_truthy_branch` and `partial_slot_forwarding` are page-level or
runtime-level decisions — no single word owns them. So the register needs a
`trigger` that is a word, a set of words, or `page`/`runtime`, and the
per-word reference exists only where a word is the trigger. That is precisely
why the per-word-prose model dan challenged fails and a reference model does
not: the truth is sometimes shared, and a shared truth wants one home and many
pointers, not many homes.

**The acceptance test is the one this round used for the spelling change** —
the generated entries must be byte-identical to the prose that is already
written, so the move is provably a relocation of meaning rather than a rewrite
of it, and the gate green.

### Option 3 — the declarations' accent *(landed)*

A preamble said what a word takes in a flag language: `expects variant, content:
true, precision: true, children: any, shape: presents`, where the `true` was a
placeholder carrying no information, and where the same spelling meant two
different things depending on the key (a flag for `content`, a *modifier
declaration* for `precision`). The spelling is now one form for one meaning:

```text
expects variant, takes: content, takes: precision, children: any, shape: presents
```

Nineteen preambles changed, and the acceptance test was the refactor's own:
**every one of the 22 parses to a Contract identical to HEAD's** — checked
per file in one process before writing, and again against `git show HEAD:` after.
No behavior moved, no vital should have, and `words.rb` was not touched.

**Step 1 had nothing to do, and that is a finding.** I had predicted the flags
repeat the shapes — `gathers: true` restating `shape: gathers`. Measured across
all 64 words: `gathers:` is declared by **nobody**, and no shape is restated by
a flag. The hypothesis was wrong, so the step is empty rather than deferred.
(`gathers:` and `inside:` are now *unused parser keys* — a mechanism with no
user, which belongs on the promise ledger's kind of list and is not touched
here.)

**Step 2's spelling is not what I proposed.** `takes content` cannot be said:
a preamble argument is one comma-separated token and may not contain a space.
The grammar-clean form is `takes: content` — one argument, no placeholder, and
the key lists decide whether the name is a flag or a modifier. What I proposed
was unspellable; what landed is what the lexer allows. The old form still
parses, deliberately: a stale file should be read correctly rather than
silently misread. **The corpus speaks one spelling and `check_grammar.rb` now
holds it** — a preamble saying `x: true` fails the gate.

**Step 3 turned out to be a finding, not a cleanup.** The two remaining uses of
the dead `# key: value` form are `studio/views/partials/sidebar_layout.sp` and
`split_pane.sp`, where nothing parses them. Making them live is not a
formality: **measured, it changes the render** — a declared partial with
`name: :none` does not shift the subject, while an undeclared one does, so the
comment is not an inert placeholder but a *mis-declaration* whose live form
would alter subject flow through the studio's own chrome. It is recorded here
and waits on a ruling rather than being fixed under this daytrip's border.

**And the round corrected a checker that had been measuring declarations as
sentences.** `check_shape.rb` walked the `expects` line as though it were a
sentence, while `check_grammar.rb` has always recorded the opposite — *"it is
not a sentence and is not counted as one"*. So its vitals were inflated by every
declaration key: **sentences 479 → 457, distinct modifiers 25 → 17, app words
17 → 16** (`expects` itself was being counted as an app word, and `content`,
`empty`, `label`, `precision` and kin as page modifiers no page writes). No live
document quoted the inflated figures — they survive only in the `.agents/`
swarm's dated reports — and the correction is the day's second instance of the
daytrip's own subject: an instrument measuring something other than what it says
it measures.

**What is *not* changed, and why.** The 42 Ruby words keep `contract content:
true, …`. That is Ruby's own keyword syntax rather than a bespoke mini-language,
and the reader there is a Ruby author; the two files speak two languages and
each speaks its own. Named here because it is a divergence from "one declaration
spelling", and because it is the obvious next step if the accent is to leave the
Ruby side too — `has: [:content]`, or a `takes` helper, at the cost of inventing
a spelling Ruby already has.

### Next round, chosen: the studio's badges *(landed too)*

**W1** — the palette marks all 18 real pages `error` while all 18 render once
loaded, because the census measures the empty-data render and the load
pre-fills the payload. One line, the most visible lie in the surface dan
actually uses.

**One unresolved operational fact, now resolved:** the studio on :4580 was
running an old boot and could not be reached from this session's sandbox. With
dan's approval of a wider sandbox it was found by port (it runs as **`puma`**,
not `ruby studio/app.rb` — which is why name-based discovery missed it), killed,
and rebooted detached per `HANDOFF.md`. Its status page now shows all seven
legs.

And **the name.** *The Accent* was mine; the work became about transparency and
managed sources of truth, which the name only half carries.
