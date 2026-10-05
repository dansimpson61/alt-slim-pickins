# Daytrip 0.4.0q — Families: One Namespace Per File

**This replaces `DAYTRIP-0.4.0p.md`, which dan rejected.** 0.4.0p is kept as a dated
record; nothing below depends on it.

## Why 0.4.0p was rejected, and the test that replaces it

Dan's reason, in his words: it **"was requiring the author to take care of the
compiler rather than the other way around."**

That is the test every decision here is measured against, and it is not a style
preference. slim-pickins is people-centered or it is nothing: a language whose whole
claim is *one sentence, everything is a word* cannot ask an author to maintain a
sixteen-slot declaration before writing a line that renders.

So each decision below answers one question: **does this move bookkeeping off the
author, or onto them?** Anything that moves it onto the author is rejected even when
it is correct, and said so out loud.

Here is the current state of that ledger, which is the real case for this round. To
add `card`, an author writes this before any markup:

```
expects subject, takes: content, children: any, takes: id, takes: variant,
        subject: shift, shape: encloses, infers: card_id, infers: box_tag,
        infers: box_depth
```

Ten declarations. Measured over all 23 vocabulary partials (0.4.0o):

- `children: any` agrees with *whether the body says `children`* — **23 times out of 23**
- `subject: shift` and a `subject` name slot co-occur — **2 of 2**; each implies the other
- `takes:` matches the body's `.foo` reads — **20 of 23**
- `parents:` is a fact about where the word is *used*, which the file tree can hold

**Most of that line is the author telling the compiler what the compiler could read
for itself.** And the cost is not hypothetical: the one thing in that line nothing
could check — a `takes:` nobody reads — is exactly the defect 0.4.0o found, where
`action` declared `path:` and `return_to:` and silently discarded both.

## The idea

Dan's statement, which is the brief:

> Each `.sp` file creates a namespace and it can contain any number of `def`s.
> Conflicts are not allowed within that intimate family space. Calling a word adds a
> more distant namespace, and so on along the ancestral tree (lexically, not
> dynamically). The app is the top level namespace. Each `.sp` file begins with a
> `def [word], param, param`, then we reduce to two the ways that contracts are
> declared.

Arrived at by asking *what would Matz do?* — and Ruby's own answer is the precedent:
**constant lookup is `Module.nesting`, then ancestors, then top-level.** Lexical
first, explicit reach-out, and no dynamic scoping anywhere. The intimate family, then
more distant, then the app.

## What an author writes

This is the whole proposal, in the form that matters.

**Today** — `card.sp`:

```
expects subject, takes: content, children: any, takes: id, takes: variant, subject: shift, shape: encloses, infers: card_id, infers: box_tag, infers: box_depth

box .name
  ...
```

**After** — `card.sp`:

```
def card, subject, content, id: nil, variant: nil
  box .subject
    ...
```

**Today** — `list.sp` and `item.sp`, two files, with `item` declaring `parents: list`
and the language holding it there by a rule written in a register:

```
expects variant, children: any, shape: encloses, infers: box_tag
expects variant, takes: content, children: any, parents: list, shape: registers, infers: box_tag
```

**After** — one file, `list.sp`, and the containment *is* the rule:

```
def list, variant
  box .variant
    children

def item, variant, content
  box .variant, .content
    children
```

`item` is reachable from inside `list` and nowhere else, because that is where it
lives. **The answer to "why does `list` need `item`" becomes "look at the file."**

That last point is why this round is worth doing now rather than after the pedagogy
discussion: dan lost that exact distinction two days ago. The change that makes the
language safer is the same change that makes it teachable.

## How a word is found

The chain for any sentence, nearest first:

1. **The file it is written in** — its own `def`s.
2. **The families of the words it is nested under**, nearest enclosing word first.
   This is what "calling a word adds a more distant namespace" means: writing
   `table products` opens `table`'s family for everything indented beneath it, which
   is how `column` becomes sayable there and nowhere else.
3. **The app** — the library's own words.
4. **The language** — the 62 canonical words.

**Lexically, not dynamically.** The chain is built from the written indentation, not
the runtime call stack. This matters for one reason above all others, and it is the
project's own principle: *a reader never carries state to parse a sentence.* Under the
lexical reading, everything that decides which `editor` you got is on screen — the
file you are in, and the words above you. Under a dynamic reading it would be the
call stack, which is not.

It has a second consequence worth more than it looks: **the chain is knowable at
compile time.** `Transform#tree` already holds the nesting, and
`Contracts.first_violation` already walks it with ancestry. So a word name can be
resolved to its family when the page is compiled, not when it renders — which means
an unresolvable word is refused at compile time, with its line, in the language's own
words. The runtime stays boring, which is where the cleverness budget is supposed to
go.

### What this cures, mechanically

One line is the whole disease:

```ruby
# compilation.rb, compile_partial
SlimPickins::Word.registry[word] = klass
```

Unconditional, global, last-write-wins. It is why *constructing* a library steals a
name from another, why `editor` resolves by compilation order, and why the live
studio is correct only because `StudioPages.ui_library` is not memoized — a
requirement recorded in a test comment and enforced by nothing.

Families do not mitigate that line. They delete it.

---

# The decisions

**Two of the eight need dan. The other six follow from his brief or from first
principles, and are recorded so they can be overturned, not so they can be debated.**

| | Decision | Status |
|---|---|---|
| **D3** | What happens to `shape:` | **Ruled 2026-10-05: required only when it gathers** |
| **D6** | May an app shadow a *language* word | **Ruled 2026-10-05: yes, allowed, and the gate reports it** |
| D1 | A parameter's name declares its kind (`def card, subject, content`) | Follows from the brief |
| D2 | Modifiers are keyword parameters with defaults | Follows from the brief |
| D4 | Ruby words get families through Ruby's own module nesting | Forced by the dogfood rule |
| D5 | The dot gains nothing; no namespace is ever written in a page | Forced by first principles |
| D7 | The first `def` in a file is named after the file | No cost found |
| D8 | Resolve the chain at compile time, not at render time | Engineering judgement |

Each gives the proposal, the reason, and the cost. Any one can be overturned without
reopening the others, except where noted.

## D1 — A parameter's name declares its kind

**Proposal.** The name slot's kind comes from what the author calls the parameter.

```
def card, subject, content          # the name slot is a subject, so it shifts
def badge, variant, content         # the name slot is a variant
def column, attribute, content      # the name slot is an attribute
def link, destination, content      # the name slot is a destination
```

The kinds are already a closed set of nine — `subject`, `variant`, `attribute`,
`destination`, `topic`, `notation`, `value`, `binding`, `name`. The author was always
going to name the thing they read; naming it the kind means **the declaration and the
reader are the same word**, and `.subject` reads what `subject` took.

**Why this is the keystone.** It is what lets `expects` go. `subject: shift` is
implied (2 of 2, measured). The `name:` kind is implied. And it quietly kills a
defect found in 0.4.0o: today a `name: :variant` partial can read its slot as *either*
`.name` or `.variant` — two spellings for one value, with seven partials saying
`.name` and `paragraph` alone saying `.variant`. Under D1 there is one spelling,
because the parameter has one name.

**Cost.** A parameter name is no longer free — `def card, thing, content` would be
refused, because `thing` is not a kind. That is a real constraint on the author, and
the only one this round adds. It is worth it because it replaces nine.

**Alternative rejected.** `def card, subject: true, content: true` — explicit, and
back to the author annotating for the compiler.

## D2 — Modifiers are keyword parameters with defaults

**Proposal.** `def action, content, to: nil, variant: nil, status: nil`. The modifier
list and its defaults are the Ruby signature. `Builder.bind_parameters` already binds
positionals in order, kwargs by key, and defaults the rest to nil.

**What this buys beyond brevity.** The 0.4.0o defect becomes *unrepresentable*. A
modifier that nothing reads cannot exist, because the signature is the declaration and
the body is the only reader. `path:` and `return_to:` could not have been declared and
discarded.

**Cost.** None found. Defaults are strictly better than today, where an unsaid
modifier is always nil.

## D3 — The judgement slots, measured: `shape:` cannot be inferred, and mostly does not matter

This is the one place the author still serves the compiler, so it got measured rather
than assumed. Two findings, and the second is the interesting one.

**Finding 1 — `shape:` cannot be inferred from the body.** The obvious signal (does
the body say `children`, and what word is at its root) maps one observable to three
different shapes:

| observable | shapes it covers |
|---|---|
| no `children` | `encloses` (action, search), `presents` (9 words), `says` (empty) |
| says `children` | `encloses` (9 words), `presents` (paragraph), `registers` (item) |

So inference is out. **Do not attempt it.**

**Finding 2 — only one of the seven shapes has any behavioural effect.** The sole
reader in the runtime is `Transform#lands?`:

```ruby
contract.subject == :shift && contract.shape != :gathers && ranks.include?(0)
```

Every other reader is `check_shape.rb` (which only requires a shape to be *present*)
and the studio's `by_shape` grouping for display. `document`, `encloses`, `presents`,
`says`, `registers` and `iterates` are a **taxonomy, not behaviour** — nothing renders
differently for being `presents` rather than `says`. (Worth knowing while here:
`shape: :gathers` is *not* the `gathers:` flag. All four gatherers — `table`, `chart`,
`choice`, `choose` — declare `gathers: false`. The flag is the partial-collects-its-
children mechanism, a different thing with a confusingly similar name. That is a
pedagogy finding, and it belongs in the docs discussion.)

**So the decision is not "how do we infer shape" but "who is the shape for".** Two
honest options, and this one is dan's:

- **(a) Keep it required, as a design-review device.** `check_shape.rb`'s stated
  rationale is that "a word with no declared shape has to argue for itself in
  writing." That is deliberate discipline, not bookkeeping — it forces an author to
  say what kind of thing they have made. Cost: one keyword on every `def`, forever,
  for a value that changes nothing but `gathers`.
- **(b) Require only what is behavioural, and derive the rest for display
  (my recommendation).** A word says nothing about shape unless it gathers. The
  taxonomy becomes the studio's and the checker's business — derived from what the
  word does, for grouping and teaching — not the author's declaration. Four Ruby
  words declare `gathers`; the other 58 say nothing.

**My reason for (b):** under the people-centered test, a keyword that changes no
behaviour and is written 62 times is the author serving the compiler. The discipline
argument is real, but a design review that happens because a checker demands a word is
weaker than one that happens because a human reads the `def` line — and the `def` line
is now short enough to read.

> **Ruled 2026-10-05 — (b).** `shape:` is required only where it gathers. Four Ruby
> words say it; the other 58 say nothing. `check_shape.rb` stops demanding a shape of
> every word and the taxonomy becomes derived, for the checker's and the studio's use.

**`speech:` and `infers:` are unaffected either way.** `speech:` is a genuine judgement
on 5 words of 62, and stays a rare keyword. `infers:` names conventions in a register —
a cross-reference, not a fact about the file — and is the remaining bookkeeping this
round does not solve. It should be taken up by the docs-and-pedagogy discussion, which
owns the register.

## D4 — Ruby words get families through Ruby's own nesting

**The dogfood principle forces this.** Built-ins and app words "eat the same food, by
test." A design where `.sp` files have families but the 39 Ruby primitives stay global
creates two kinds of word and breaks that.

And it is not optional for correctness either: **10 of the 11 parent-bound words are
Ruby, not `.sp`** — `column`, `total`, `band`, `line`, `level`, `when`, `otherwise`,
`option`, `hidden`, `tab`. Only `item` is a partial. If containment is the rule, those
ten need somewhere to be contained.

**Proposal.** Module nesting mirrors file containment:

```ruby
module Words
  class Table < Gatherer
    class Column < Registers; end
    class Total  < Registers; end
  end
end
```

`Words::Table::Column` is in `table`'s family for the same reason `item` is in
`list.sp`'s. One rule, both halves of the vocabulary, and it is the most Ruby answer
available — `Module.nesting` is literally the precedent.

**Cost.** A mechanical move of ten classes in `words.rb`, plus `Word.inherited`
learning to read nesting rather than only the last name segment. Note while there:
`inherited` has a latent bug — it uses `gsub(/([A-Z]+)([A-Z][a-z])/, '_')`, dropping
its captures, where `word_name` correctly uses `'\1_\2'`. No current word has
consecutive capitals, so nothing has failed; it should be fixed in passing, not left
for a word like `HTMLPreview` to find.

## D5 — The dot keeps the meaning it has; no *word* gains a dotted spelling

**This heading replaced "the dot gains nothing", which was misleading enough that dan
read it as a reversal of an earlier conclusion. It is not one, and the distinction is
worth stating precisely, because two positions are involved.**

- **In argument position, the dot is already Ruby's dot, and nothing here changes it.**
  `account.name` sends `name` to the thing `page account` named. That is a message
  send to a named ancestor, and after `feat(scope)` the rule is settled: a bare dot
  means "it", reaching further out is by name. "A dot reaches inside the thing named
  to its left" is a fair reading of what it already does.
- **In head position — where a *word* goes — a dot is currently impossible**, and this
  round does not make it possible. `workbench.editor` as the first token of a sentence
  fails `WORD`.

Earlier I argued that extending the dot to families would be *the same rule rather
than a second one*, and I stand by that: it would be consistent. D5 says only that it
should not be **built**, which is a separate question from whether it would be
coherent.

**Proposal.** No namespace is ever written in a page. There is no qualified spelling,
and `WORD` stays `/\A[a-z][a-z0-9_]*\z/`.

**Why.** Measured: every candidate separator is already taken or refused —
`workbench.editor` is a binding's data, `workbench: editor` is a modifier, and at the
head of a sentence all of `.` `:` `/` `-` are refused outright. Adding one means
changing the lexer, and **"extending the language adds vocabulary, never syntax"**
forbids it.

So the namespace is inferred from where the file lives and never spoken. *"A line that
states the inferable should not exist"* says the same thing from the other side.

**Two reasons not to build it, and the second is the stronger one.**

1. *Design for the present.* Nothing in the corpus needs it.
2. **It would re-admit exactly what families exist to prevent.** The only word a page
   could want and not have on its chain is another family's private helper — `item`
   from outside `list`. A qualified spelling would make that sayable again, undoing
   the containment that is the whole point. The absence of the spelling is not a gap;
   it is the mechanism.

The one genuine need for reaching outward is D6a, and `super` answers it without
punctuation.

## D6 — Shadowing across families is allowed; within a family it is refused

**Proposal.**

- **Within one file: refused.** Dan's "conflicts are not allowed within that intimate
  family space." Two `def`s of one name in a file is a compile-time error.
- **Across families: allowed, nearest wins.** This is the entire point — the
  workbench's `editor` and the classic UI's `editor` coexist.
- **Shadowing a language word: allowed, and reported.** An app may `def section`, and
  inside that app it wins.

**This third one is a change, and it needs dan's word.** Today it is refused outright
— `` `section` is already a slim-pickins word — an app cannot redefine it`` — in two
places (`Library#initialize`, `refuse_shadowing!`). Under families the refusal is no
longer *necessary*, because the names cannot collide. The question is whether it is
still *wanted*.

**Recommendation: allow it, and have the gate report it.** "Nearest wins" is the rule
everywhere else in the language now, and a special case for language words is an
irregularity the author has to remember. Reporting keeps it honest without forbidding
it.

**Counter-argument, which is real:** a page that says `section` and gets something
other than `section` is the most confusing thing this language could do, and a user
reading that page cannot see the shadow without opening the app's files. If dan
weights that higher, keep the refusal — it costs one rule and buys predictability.

> **Ruled 2026-10-05 — allow it, and have the gate report it.** The refusals in
> `Library#initialize` and `refuse_shadowing!` go; the gate gains a line that names
> every shadowed language word.

### D6a — and therefore: `super`

The ruling creates one problem that has to be answered with it. An app that writes
`def section, subject, content` and calls `section` inside the body **calls itself**,
because nearest wins and the nearest is the definition being written. Infinite
recursion, and the author's intent — *wrap the language's section* — is the obvious
reason to shadow in the first place.

**This is the one place a word needs to reach outward along the chain, and it is the
exact case Ruby already answers.** The chain is an ancestor chain, so the answer is
`super`:

```
def section, subject, content
  box framed
    super
```

**Why `super` and not `language.section`:** it needs no punctuation, so `WORD` stays
as it is and D5 holds; it is one word of vocabulary rather than a syntax change; and
it means *the next one out along the chain*, which is exactly what the family rule
already defines. A qualified spelling would also have to answer "which family?" —
`super` does not, because the chain already knows.

**Cost.** One reserved word. `super` is already in `Transform::RESERVED`, so it is
already impossible as a word name; this gives it a meaning.

**Scope note.** Build this in Step 4, with D6, not before. Until shadowing is allowed
nothing can need it.

## D7 — The first `def` in a file is named after the file

**Proposal.** `list.sp` must begin `def list, …`. Later `def`s in the file are the
family's own.

**Why.** It makes the file name meaningful — the public word — and makes the rest
visibly private. Without it, a reader cannot tell which of five `def`s is the one the
world may call.

**Cost.** None to the corpus: every partial today is one word in a file of its name.

## D8 — Resolve at compile time, not at render time

**Proposal.** The transform resolves each word to a family while compiling, and emits
a call that cannot be ambiguous. An unresolvable word is refused with its line and its
own name.

**Why.** It keeps *"every word is a real method — never `method_missing` — so a typo
is loud, on the line, in the language's own terms."* It also keeps the runtime boring,
and it means the namespace rules are enforced by the gate rather than discovered in
production.

**Cost.** A compilation-order dependency: the language's families must be built before
an app's pages compile. That is already true in practice (`Library.builtin` runs
first), but it becomes load-bearing and needs a test that says so.

---

# Dan's proposal: remove variants (2026-10-05)

> "Variants are just an ugly way of creating a new word. We already have simpler ways
> of creating different variants of a thing: we simply create a new word. Creating the
> `variant:` mechanism didn't extend the language, it changed the syntax, and not in a
> nice way. Let's remove variants from the language."

**Measured before answering.** The diagnosis is right in three places, one of which
hides a defect — and there is one case that resists, which turns out not to be a
variant at all.

### Where the proposal is simply right

| Finding | Measurement |
|---|---|
| **Half the capability is never used** | 7 of the 14 variant-taking words receive no variant anywhere in the corpus: `nav`, `tabs`, `aside`, `item`, `paragraph`, `scroll`, `time` |
| **Two spellings for one idea** | 12 words take it as a bare name; `action` and `card` take `variant:` as a modifier — 5 usages in total |
| **Two spellings for one slot** | In a `name: :variant` partial, `.name` and `.variant` are interchangeable; 7 partials say `.name`, `paragraph` alone says `.variant` (D1 already kills this) |

Those 7 unused capabilities are the standing principle *word, or power?* answered
honestly in the negative: surface with no payoff. **Deleting them costs nothing and
needs no new word.**

### A latent hazard, and a false alarm I raised — corrected 2026-10-05

`name_and_content` takes the first Symbol as the name and the first non-Symbol as the
content:

```ruby
[args.find { |a| a.is_a?(Symbol) }, args.find { |a| !a.nil? && !a.is_a?(Symbol) }]
```

So a slot handed **two values** keeps the first and silently drops the second. That is
real, and it is a trap worth knowing about.

**It is not, however, a live defect, and I claimed it was.** I reported
`examples/dashboard/views/partials/queue.sp:5` — `badge .status_variant, .status` — as
showing the variant name where the status text belongs. It does not. The app's
`status_variant` returns a **Symbol** (`:ok`, `:danger`, `:pending`, `:neutral`,
`app.rb:79`), so it binds to the name slot exactly as the author intended:

```
badge .status_variant, .status    (status_variant: :ok, status: "active")
  -> <span class="badge badge--ok">active</span>        correct
```

My probe passed a String for the variant, which the application never produces. The
premise was mine and it did not survive measurement — the eighth time in this
project's record, and the first time the bad list item was written by the reviewer.
**Two further things I said about it were also wrong**: the branch is not unrendered —
`test/dashboard_test.rb` covers it with a real `first_item`, 11 runs green — it is
merely outside the *page* corpus that `verify_pages` and `byte_diff` walk.

**What remains true, and what it costs.** Every one of the 19 dropped-value calls in
the corpus is a `link` sentence, and `Link#evaluate` recovers the argument by reading
`@args[1]` behind `unpack_arguments`' back. So nothing is lost today, and the drop is
only reachable through a sentence shape that one word compensates for privately.

Making the drop refuse would therefore break those 19 calls unless `link`'s
positional alias goes with it — which is an unruled language decision (0.4.0o, finding
1), not a bug fix. **They are one change, and it is dan's.** Evidence that arrived
with `doc_reader` and is worth weighing: that app uses *both* spellings for the same
job — `link .name, .href` in `index.sp:10` and `link .title, to: .href` in
`documents_list.sp:5` and `document_card.sp:2`. An alias two days old has already
produced two ways to say one thing inside one app.

### The case that resists — and it is not a variant

Of the 24 distinct variant values in the corpus, **14 belong to `badge` (11) and
`note` (3)**, and those are not chosen by the author. They are inferred from the
content by the `badge_status` convention:

```
badge .status      (status="warning")  ->  <span class="badge badge--warning">warning</span>
```

The app supplies a status; the language maps it to a form. Turn each into a word and
the page has to choose:

```
choose
  when .is_ok
    badge_ok .status
  when .is_warning
    badge_warning .status
  ...                                  # eleven branches
```

That breaks three principles at once — *a condition is named, not written*, *a line
that states the inferable should not exist*, and *judgements belong to the app* — to
replace one line that already reads correctly.

**So this half is not a variant of a word. It is a value choosing its form** — which
is already the largest principle in the conventions register (10 entries). It has been
sitting under the wrong name.

### Recommendation: split the proposal, and do not bundle it with families

Dan is right that "variant" is one name over two unrelated jobs, which is why it feels
ugly. The fix is to separate them, not to delete the pair.

- **(i) Author-chosen presentational variants** — `button primary`, `grid cards`,
  `box document`, `span word`, `list plain`. **10 values across 5 words.** These are
  genuine new-word candidates and dan's argument applies cleanly. The work is naming,
  not mechanism, and naming ten words well is a round of its own.
- **(ii) Data-chosen forms** — `badge`'s 11 and `note`'s 3. **Keep the mechanism,
  rename the concept** to what the register already calls it. No page changes.
- **(iii) The 7 unused capabilities** — delete now. Free.
- **(iv) The `variant:` modifier on `action` and `card`** — 5 usages. Dies naturally
  under D1/D2, since the modifier becomes an ordinary keyword parameter.

**Sequencing.** (iii) and (iv) ride along with this plan at no cost — (iv) is already
implied by D1 and D2, and (iii) is a deletion that touches no page. **(i) and (ii)
should be their own round, after families lands.** Families is already seven steps and
reaches the registry, the transform, the checkers and 23 partials; adding a vocabulary
redesign to it would make both harder to verify and neither easy to revert.

---

# The plan

Seven steps. **Every step ends with the twelve gate legs green and the 38-page corpus
byte-identical**, except where a step says otherwise. Any step can be the end of a
session.

**Step 0 — clear the baseline.** The suite is red before any of this starts: 1 failure
of 606. It is not a code defect — `check_vitals` reads prose claims from every
non-exempt document, and the untracked `three-rulings-dan-owes.md` says "37
conventions" where the census measures 38. Fold that file into `HANDOFF.md` (as its
author offered) or exempt it. **Do not start Step 1 on a red suite.**

**Step 1 — `def` learns the kinds and the defaults (D1, D2).** Add the nine kind
names and keyword defaults to the `def` form, with `expects` untouched beside it.
Prove it by converting exactly one partial — `badge`, the simplest — and showing its
render byte-identical. *Nothing is removed in this step.*

**Step 2 — infer what is inferable (D3).** `children` from whether the body says
`children`; the subject shift from a `subject` parameter. **`shape:` is not inferable —
measured, do not try.** What happens to it is D3's open ruling, and this step does
whichever dan chooses. The gate gains a leg that holds every declared
`children:`/`subject:` against what would be inferred, which must report zero
disagreements across all 23 partials before any declaration is deleted.

**Step 3 — families, measured but not enforced (D8).** Build the lexical chain in the
transform. Resolve every word in the corpus through it and **report** every word that
would resolve differently, or not at all, than it does today. Expect exactly one real
finding (`editor`) and a list of the eleven parent-bound words. *This is the step that
either confirms or kills the design, and it changes no behaviour.*

**Step 4 — enforce, and delete the global write (D6, D7).** Remove
`Word.registry[word] = klass` from `compile_partial`. Lookup is the chain. `editor`
stops being order-dependent, and `StudioPages.ui_library` may be memoized again — add
a test that memoizes it and still serves both UIs correctly, because that trap is what
started this.

**Step 5 — migrate the 23 vocabulary partials to `def`.** Mechanical, one file per
commit or in small batches, corpus byte-identical throughout. `item` moves into
`list.sp`; `column`-like children follow in Step 6.

**Step 5a — the two free parts of the variants proposal.** Delete the variant name
slot from the 7 words that never receive one (`nav`, `tabs`, `aside`, `item`,
`paragraph`, `scroll`, `time`); the `variant:` modifier on `action` and `card` is
already gone by D2. Corpus byte-identical — no page says either. Parts (i) and (ii)
are **not** in this plan.

**Step 5b — `name_and_content`, if and when dan rules on `link`'s alias.** There is
nothing to fix here on its own: the silent drop is latent, and the only sentences that
reach it are `link`'s, which recover the argument privately. Making the drop refuse is
the *same change* as removing the positional alias, so it waits on that ruling. If the
alias goes, this is the shape: `name_and_content` refuses a second value naming the
line, `link .name, .href` in `doc_reader/views/index.sp:10` becomes
`link .name, to: .href`, and `test_flexible_link_with_positional_arguments` is
rewritten to the regular spelling — its assertions do not change, because the HTML
does not.

**Worth doing regardless, and cheap:** add the `when .first_item` branch of
`queue.sp` to the *page* corpus. `test/dashboard_test.rb` already renders it with a
real item, but `verify_pages` and `byte_diff` do not, which is why `feat(scope)` had
to prove that partial "separately against a real item." A fixture with a `first_item`
would put it inside the instrument every refactor is measured with.

**Step 6 — Ruby words get nested families (D4).** Move the ten parent-bound classes
into their parents. Fix the `inherited` capture bug in passing.

**Step 7 — delete the scaffolding.** `expects`, `parents:`, `children:`, `subject:`
and `VocabularyShapes` go. `check_grammar`'s contract walk reads containment instead
of declarations. `Contract` shrinks from 16 slots to what is left. **This is the step
that pays the author back**, and it must be last, because until Step 6 something still
depends on each of them.

## What this closes

- The `editor` collision, and the mechanism behind it rather than the instance.
- The `ui_library` memoization trap — correctness that rested on a test comment.
- The declared-but-unread modifier, made unrepresentable (D2).
- The `.name`/`.variant` alias on variant partials (D1).
- `parents:` as a declaration, and with it the question dan could not answer about
  `list` and `item`.
- Three ways to declare a contract, down to two.
- `shape:` on 58 of 62 words (D3), and the refusal of app shadowing (D6).
- The variant name slot on 7 words that never used it, and the `variant:` modifier on
  the 2 that spelled it differently (Step 5a).
- Nothing about the dropped second value (Step 5b) — that is latent, not live, and it
  rides with dan's ruling on `link`'s alias.

## What this does not touch

- **`.spiff` and the design idiom.** Presentation is a separate layer and no decision
  here reaches it.
- **The grammar a page speaks.** `word arguments`, indentation nests, a dot means
  "it". No page changes, ever, except where a word was genuinely ambiguous.
- **`~/dev/dashboard`.**
- **The 0.4.0p rulings on names-by-position (N1) and interpolation (N2).** Those stand
  or fall on their own merits; this document neither needs nor contradicts them.
  Someone should rule on them separately rather than let them die with 0.4.0p.

## Risks

1. **Step 3 is the real gate on this design.** If resolving the corpus through the
   chain produces findings beyond `editor` and the eleven, the design has met
   something it did not predict — stop and report rather than adjusting the chain
   until the list is short. This project's record is five, six, then seven consecutive
   rounds where a list item's premise did not survive measurement.
2. **`shape:` is settled by measurement, not by hope** — it cannot be inferred, and six
   of its seven values change nothing but display. The risk that remains is a ruling
   risk, not a technical one: if D3(a) is chosen, every `def` carries a keyword for a
   value that only four words use behaviourally, and that cost is permanent.
3. **Compile-time resolution adds an ordering requirement** (D8) that is currently
   true by accident. It needs its own test or it becomes the next `ui_library`.
4. **Step 7 is a large deletion.** It should be its own session, on green, with the
   corpus diffed before and after — not tacked onto Step 6.
5. **This is a big change for a collision of size one**, against *design for the
   present*. The honest defence is that it is not bought for the collision: it is
   bought for the author, and the pedagogy win (D7, `item` in `list.sp`) is the
   larger half of the return.
