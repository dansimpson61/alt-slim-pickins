# DAYTRIP-0.3.0b — outline, for discussion

**Status: an outline only. Not opened.** dan's two observations of 2026-09-16,
after reading BLUESKY.md, and the outline they ask for. It becomes a daytrip on
his word, and it moves when he does. Nothing here is taken.

Proposed name: **The Accent** — the machine language a speaker of a human
language still carries. His phrase for the goal is fluency, not purity. Rename
at will; the file follows the house convention (roadmap 0.3, Phase 0, second
jaunt).

---

## The brief, in his terms

> **1.** Human language and its roots in magic, conventions and inference are
> the central truths that distinguish sp — that *determined the need for sp*,
> because Slim (and all the others) and Tailwind (and all the others) have
> other priorities. I began to identify things we could make real **right now**
> that would be helpful not just for the current roadmap but **essential for
> working with sp forever**.
>
> **2.** We observe — and despise — machine language creeping through tools
> intended for humans to use proficiently and fluently. We see it in HTML and
> CSS, in the Slims and the Tailwinds, **and we see remnants of it persisting
> in sp.** We need to understand well what it is doing in sp, why it persists,
> and how to grow beyond it — or, for the moment, the extent to which we can
> grow beyond it now. Does that include variants and `label_for`, `format_for`?
> Does it include our hashes of attributes? What does that include?

---

## What a daytrip is, and what is new here

The genre holds: a number from nobody, both eyes on the ground in front of the
feet, and it does not advance the project's question. Two things differ from
every daytrip so far.

**It audits rather than repairs.** Stop 1 fixes nothing, by design. What this
daytrip produces is a classification with counts behind it, a set of paper
alternatives, and a handful of permanent instruments.

**It is allowed to land instruments — and only instruments.** A daytrip that
restores a broken gate changes what the project can do (DAYTRIP.md, Stop 1, did
exactly that). An *instrument* is the same kind of thing: it makes an existing
claim true or a hidden truth visible, it adds no vocabulary, it does not move a
vital, and it is itself held by a test. That is the whole of what this daytrip
may build. Anything that decides a question — a style word, a new spelling, a
fixed remnant — is out.

## The one argument

**sp exists because a page should speak human language about presentation; the
project is now about to teach it the largest vocabulary it has ever learned —
style — and a language that cannot hear its own accent will learn the machine's
again.** The audit is the precondition for that work, and the instruments it
names are the ones every future session needs whether or not the style language
ever happens.

## The question

> **Where does sp still speak machine, what is each remnant doing there and why
> does it persist — and which instruments, essential to a language of intent
> forever, can be made real now?**

## The hypothesis, so it can be argued with

Two claims, both falsifiable, and the stops exist to test them.

> **H1 — Remnants persist for one of three reasons, and the reasons take
> different work to answer.**
>
> - **Cause A — inference took over.** The page stopped saying a word, so the
>   app had to answer in the word's place, through a channel keyed by the
>   attribute's identifier. The cost moved off the page, where it would have
>   been visible, and onto the app, where it is not.
> - **Cause B — the abstraction is wrong.** A composition is wearing a
>   primitive's clothes. The tell is duplication.
> - **Cause C — the host's grammar leaked.** Ruby, HTML or CSS decided a
>   spelling the language would not have chosen: a hash, a sigil, a boolean
>   flag, a comment marker.
>
> **H2 — the accent is thickest exactly where the abstraction is wrong.** The
> places where machine language is repeated are the same places a word is
> doing two jobs.

If H1 and H2 hold, the audit is not cosmetic: it is an index of the language's
real faults, in the language's own handwriting.

---

## The evidence already in hand

Measured 2026-09-16 against the tree at `2cb0520`, so the outline is not a
guess. Coverage stated: the whole `.sp` corpus (`pages/`, `examples/`,
`lib/vocabulary/`, `studio/`), the 64 registered words, and the runtime's own
source.

| What | Count | Why it matters |
|---|---|---|
| Words taking `name: :attribute` (an identifier passed as *data*) | **11 of 64** | the single largest machine-ism in the vocabulary; each is `subject.fetch(name)` in Ruby, unsayable in the language — KERNEL.md's keystone |
| `@kwargs.key?(x) ? @kwargs[x] : nil` in `words.rb` | **23** | a hash interrogated by key, 23 times in 528 lines; the Ode's "boilerplate that buries the one line that differs" |
| `maps content: :body` declarations | **8 identical** | one decision with eight homes — and the eight are exactly KERNEL.md's non-orthogonal atoms |
| `expects` keyword arguments across the 22 vocabulary partials | **68**, of which **33 booleans** | the language's own declaration files half-speak flags: `content: true` |
| Modifier arguments a page writes, by kind | **134** — 89 bare names, 20 quoted, 17 data, **8 numbers** | the page surface is mostly linguistic; numbers are rare but real (`columns: 3`, `step: 0.01`, `rows: 4`) |
| Parenthesised argument handling in `Transform#split_args` | **0 consumers** (the 4 corpus `(`s are inside strings) | machine machinery in the lexer carried for nobody |
| Node kinds the Generator special-cases | **9**, plus ~30 named methods | the internal IR — machine language a page never says |
| `label_for` / `format_for` needed | **only where the word is not said** | `money .market_value` → `$1,284,506` with no app answer; `column market_value` → `$1,284,506` with `format_for`, `1,284,506` without |
| An unknown *variant* | **silently accepted and unstyled** | `badge banana` renders `class="badge badge--banana"`; an unknown *word* fails loudly — the asymmetry is the finding |
| `#` inside a quoted string | **destroys the sentence** | `note "Total # 1"` is a `SyntaxError`; the comment stripper eats the author's text |

Two of those rows are the daytrip in miniature. `format_for` exists *because*
inference replaced the word — the page stopped saying `money`, so the app had to
answer by name. And `#` is the machine's comment marker destroying what a human
wrote.

---

## The border, drawn first

**In scope:**

- the audit: inventories, classifications, counts, with coverage stated;
- measurements of where a page's writing is affected rather than the runtime's
  internals;
- paper alternatives: what a human spelling of a remnant would read like, never
  entered into `lib/vocabulary/`;
- throwaway spikes for the instruments, deleted or marked;
- **landing an instrument** that (a) makes an existing claim true or checkable,
  (b) adds no vocabulary, (c) moves no vital, (d) is itself tested, and (e) is
  ruled in by dan on the day.

**Out of scope, named so it is not taken by accident:**

- **No new vocabulary or spelling.** A style word, a `false` literal, a new
  modifier form — each is a decision, and decisions are what this daytrip
  leaves open. Fixing `#` in the lexer looks small; it is a grammar change and
  it waits for its ruling.
- **No kernel motion.** The 11 name-directed words, the 23 hash
  interrogations, the eight `maps` — the audit *maps* them; Phase 3 grows only
  what a real sentence demands, and this daytrip does not get to be that
  sentence.
- **No restyle of the studio**, no shipping layout change, no new pane.
- **`~/dev/dashboard` stays read-only**, as 0.3's risk register requires.
- **W1–W3 stay parked**, and `DAYTRIP-0.3.0a` is not taken up by a side door.

---

## The stops

Five. Each names what it feeds; none names an answer.

### Stop 1 — The accent audit  `agent` — evidence only

*The centrepiece, and the answer to "what is it doing in sp".*

- **Method.** Walk both surfaces — **on the page** (what an author writes) and
  **inside** (what the language says to itself) — and list every spelling that
  is machine-shaped rather than human-shaped. For each: what it is, what it is
  doing (configuration, dispatch, identity, declaration, interface), **the
  cause** (A / B / C from H1), and the count that makes the claim inarguable.
  Nominees to interrogate, not to assume: the `key: value` modifier form and
  its four value kinds; `.property` and `binding.property` (are these
  morphology or a path into a data structure?); identifiers passed as data
  (11 words); the `expects` keyword hash (68 arguments, 33 booleans); `maps`;
  the `@kwargs` idiom (23); symbol enums (`as: money`, `type: email`); the
  `#` comment marker; the paren machinery with no consumer; silent fallbacks
  (unknown variant, dropped `class:`/`id:`); the internal node IR; `tag` and
  `html` as the page's door to raw HTML/CSS.
- **Artifact.** The table, with a cause column and a count column, in this
  document.
- **Feeds.** Everything below; E1–E8.
- **Done looks like.** Every nominee appears with a cause and a count, the
  causes are argued rather than asserted, and anything that could not be
  classified is listed as unclassified rather than forced.

### Stop 2 — The three suspects  `agent` — paper only

*dan's explicit questions, interrogated one at a time.*

- **Variants** (`note warning`, `card compact`, `field bio, long`). Test: is a
  variant a *word* — a name the speaker means, which the language refuses when
  it does not know — or a *property value*, an open enum that degrades
  silently? The evidence is already ugly: `badge banana` renders an unstyled
  chip while `badge` (typo'd word) would fail loudly. Deliver a verdict and the
  paper alternative.
- **`label_for` / `format_for`.** Test H1's cause A directly. The measurement
  above shows they are needed *only* where a word stopped being said. Draft the
  three alternatives on paper: **value-shaped** (the app returns a `Money`), so
  the language asks the thing and never a table; **word-carried** (the page
  says `money`, which it already can); **domain-noun** (the app's own
  vocabulary names its figures). For each: what it costs the app, what it buys
  the page, and what it does to the three-level precedence.
- **The attribute hashes.** Separate the three that are called by one name:
  the **node attrs hash** (the IR a second interpreter would walk — a
  legitimate interface, and the LORE already argues a word must not carry what
  the tree can show); the **kwargs hash** (runtime plumbing: 23 interrogations
  that conceptually are "the word's arguments"); and the **contract's keyword
  declaration** (the word's own file declaring itself in 68 keyword arguments,
  33 of them booleans). Verdict per hash: interface, plumbing, or accent.
- **Artifact.** Three verdicts, each with its evidence and its paper
  alternatives. No decisions.
- **Feeds.** E1, E2, E3.

### Stop 3 — Inside, or on the page?  `agent` — measurement

*"The extent to which we can grow beyond it now."*

- **Method.** Split Stop 1's findings by whether a page author ever meets them.
  Count the page-facing residue and weigh it: of the page surface's 134
  modifier arguments, how many are machine-shaped? Which remnants *damage what
  a human writes today* rather than merely looking machine-ish? The `#` case is
  the exemplar — a lexer convention that eats the author's text — and the
  audit should find its siblings or report that it has none. Then name the
  page-facing items that could be grown beyond **now**, independently of any
  roadmap decision, and those that cannot.
- **Artifact.** The inside/outside split, the "grow now" list with its costs,
  and the residue that must wait.
- **Feeds.** E4, E5; and the honest answer to dan's "how far can we grow now".
- **Done looks like.** Every page-facing remnant is either on the grow-now list
  with a cost or on the waiting list with a reason.

### Stop 4 — The instruments a language of intent must own forever  `agent`, dan rules the landings

*Observation 1, made concrete.*

Four candidates, each to be written as *what it would assert*, *what it would
have caught retroactively*, and *what it costs*:

1. **The promise ledger, as a checker.** Every universally-permitted modifier
   must be read by some word; no word may declare a modifier it ignores; every
   documented feature must have a consumer. *Retroactively catches:* `if:`,
   `class:`, `id:`, and the dead `PrimitiveShapes` loader — the project's
   characteristic failure, made impossible to leave behind. Mechanical, cheap,
   permanent.
2. **The inference ledger.** Every rendered value attributed to page, app,
   theme, or inference, with the **residue** named. *Retroactively catches:*
   the `label_of`/`format_of` asymmetry LORE records, where a table read its
   headers off the Projection that merely held them. This is the studio's
   natural fourth pane, and the precondition for any style vocabulary — and it
   stays a **spike** here, landed only if dan wants it.
3. **The convention's home.** Every inference documented *with its override
   beside it*, because a convention a reader cannot look up is superstition.
   *Retroactively catches:* `page pattern, .title`, which reads perfectly and
   cannot work. Documentation-shaped, cheap, permanent.
4. **The accent register** *(the speculative one)*. A written rule — or a
   checker — that no new member of the page surface may be a hash, an enum, a
   number or a sigil without an argued reason. Honest note: this may be a
   constitution rather than an instrument, and the daytrip should say which it
   turned out to be.
- **Artifact.** The instrument table: assertion, retro-catch, cost, and whether
  it can exist today.
- **Feeds.** E5, and the "essential forever" set.
- **Done looks like.** Each candidate is either demonstrably landable today
  (with its test) or explicitly named as waiting, and dan has ruled which two
  (if any) land.

### Stop 5 — The duplication map  `agent` — evidence only

*H2's test: is the accent thickest where the abstraction is wrong?*

- **Method.** Map every duplication site the audit found — the 23 hash
  interrogations, the 8 identical `maps`, the 11 name-directed words, the
  four-copy `<div class="field">` in the Generator, the dead `PrimitiveShapes`
  — and say what each is evidence *of*. KERNEL.md's own rule generalises here:
  duplication in the Generator is the reliable signal that a word is a
  composition wearing a primitive's clothes; this stop asks whether duplication
  anywhere is the reliable signal that a *spelling* is a mechanism wearing a
  word's clothes.
- **Artifact.** The map, with each site's verdict, and H2 declared supported,
  refuted, or partly.
- **Feeds.** E6; and Phase 3's demand ledger, which is where any repair waits.
- **Done looks like.** H2 has a verdict backed by counts.

---

## The space this leaves for decisions

Each with its options intact. The daytrip makes the choice cheap; it does not
make it.

| # | Decision | Options on the table | What would settle it | Who |
|---|---|---|---|---|
| E1 | What *is* a variant? | a word (closed; unknown refused) · an open enum (accepted, unstyled) · a word with a styled fallback | Stop 2's verdict; the `badge banana` behaviour | dan |
| E2 | Where the app answers by name | keep `label_for`/`format_for` and design the channel · value-shaped (`Money`) · word-carried · domain-noun | Stop 2's alternatives, priced | dan |
| E3 | Is `key: value` the right human form for configuration? | keep · a different form · numbers to the theme | Stop 1's modifier census (8 numbers of 134) and Stop 3's page-facing split | dan |
| E4 | `#` as a comment marker | fix the stripper to respect quotes · a different comment rule · no page comments | Stop 3's damage list | dan |
| E5 | Which permanent instruments land | promise checker · inference ledger · convention's home · accent register · none yet | Stop 4's table | dan |
| E6 | **When inference takes a decision from the page, who owns it and where do they speak?** | the app answers by name (today) · the value answers (typed) · the theme owns it (axiom) · the page must say the word | Stop 2 and Stop 4 together; this is cause A's real question | dan |
| E7 | Does `tag` close, and in what order | close first · design first · together · leave it and stop calling it a leak | the blast radius, absorbed from `DAYTRIP-0.3.0a` Stop 5 | dan |
| E8 | Would a style vocabulary be more machine language, or the first fluent design language? | it would be more (refuse it) · it can be fluent if scoped to roles · undecidable until a page tries | the style round's own drafting — **not this daytrip** | dan |

**E6 and E8 are the deep ones.** E6 is the mechanism behind dan's first
observation: inference is the magic, and *every inference relocates a decision*
— the question is whether the new owner has a human channel or only a table
keyed by an identifier. E8 is the test of the whole enterprise: the style
language is the largest vocabulary sp will ever learn, and if it arrives as
symbols and numbers it is Tailwind with better manners.

## Relationship to `DAYTRIP-0.3.0a`

This outline **supersedes `0.3.0a` as the leading proposal** — his two
observations set a deeper subject than the eight decisions did — and two of its
stops are absorbed: `0.3.0a` Stop 5 (the `tag` blast radius) becomes E7 here,
and its Stop 4 (the ownership spike) becomes instrument 2 of Stop 4.

**Not absorbed: `0.3.0a` Stop 3, drafting the theme's sayability.** That is
decision-shaped work — it *is* the style round's opening — and folding it into
an audit would break this daytrip's border. It stays available, and it is the
natural first round after E8 is ruled.

Whether `0.3.0a` is withdrawn, kept as a fallback, or folded in is dan's call;
its file is untouched.

## What this would deliberately not answer

- **Whether a stranger hears the same accent.** No one outside the project has
  written a page. Every accent judgement here is made by a speaker of the
  language, and the garden (Phase 1) is the only honest test.
- **Whether "human language" is the right frame at all.** The daytrip adopts
  one criterion — *does the page expose the machine's structure where a
  speaker would point at a thing?* — and should say plainly that this is a
  chosen criterion, not a law of linguistics, so it can be argued with.
- **Whether any of it is affordable.** The cost instrument last read 7.71 /
  5.65 ms / 0.26 per row on 2026-09-16 and drops nothing.
- **Where the repairs go.** Every cause-B finding belongs to Phase 3 and waits
  for a real sentence to demand it.

## Risk register

| Unknown | Risk | Retired by |
|---|---|---|
| "Machine language" becomes an aesthetic complaint with no test | **High** | the criterion stated in the question and repeated in the limits; every finding carries a count, and the judgement parts are marked as judgement |
| The audit becomes a refactor | **High** | the border: nothing is fixed; cause-B findings are *mapped* and handed to Phase 3 |
| An instrument lands that decides a question | **High** | the five-part test for a landable instrument, ruled on by dan on the day |
| The audit is done by the same brain that wrote the accent | Medium | stated as a limit; the dashboard and the corpus at least differ from the audit's author |
| Stop 2 relitigates `label_for`, which dan already judged not onerous | Low | the stop prices *alternatives*, it does not re-open a ruling; the 2026-08-30 judgement stands unless the evidence contradicts it |
| The daytrip grows into the style round | Medium | E8 is explicitly not this daytrip's to answer |

## How this stays accountable

The gate, unchanged, in its stronger form: it must be exactly as green at the
end as at the start, and `git status` must show documents and instruments, never
vocabulary.

```bash
ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb && ruby bin/verify_pages.rb && for f in test/*_test.rb; do ruby "$f"; done
```

Today: 705 sentences, 64 words, 94 rules, 14 pages, 295 runs / 0 failures, 25
affordances / 0 missing. A daytrip that closes with a moved vital has decided
something.

## Questions for dan — the discussion

1. **Is the criterion right?** *Does the page expose the machine's structure
   where a speaker would point at a thing?* If the test is wrong, every
   finding inherits the error.
2. **Does H1's three-way cause hold?** A (inference took over), B (the
   abstraction is wrong), C (the host leaked). If there is a fourth cause, the
   audit should hunt it rather than file everything under three.
3. **Are the three suspects the right three** — variants, `label_for`/
   `format_for`, the attribute hashes — or is there a fourth you can already
   name? (My nominee for a fourth: the **silent fallbacks** family, of which
   `badge banana` is one instance.)
4. **Which instruments land, if any?** My recommendation, for the record: the
   **promise ledger as a checker** and the **convention's home**, because both
   are permanent, mechanical, and provable today; the inference ledger stays a
   spike.
5. **Is `0.3.0a` withdrawn, or kept beside this one?**
6. **The name** — *The Accent* is mine; the goal is yours: fluency.
