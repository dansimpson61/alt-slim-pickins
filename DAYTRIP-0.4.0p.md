# Daytrip 0.4.0p — Words, Names, and the File That Holds Them

Written 2026-10-04 on `conventions-as-principles`. **Nothing here is built.** This
is the paper half of "paper first, then reality": the intent, the rules a user
would hold, the new `.sp` format, and the plan to get there one step at a time.

It began as one defect: a binding named like a word silently loses to the word.
Following that defect led through three larger questions, and dan ruled on each.
How should names and words be kept apart? Where does a word come from? And how
does an `.sp` file say what its word takes? Together, the answers replace three
ways of declaring a word with two, and they replace a global registry with a
tree.

---

## Where this stands

| | Question | Status |
|---|---|---|
| N1 | Are words and names one namespace or two? | **Ruled:** two, split by position |
| N2 | What may an interpolation `#{…}` hold? | **Ruled:** the same rule as N1, fixed together with the `"in #{x}"` bug |
| N3 | Where does a word come from? | **Ruled in direction:** each `.sp` file is a family, and families nest along the tree |
| N3a | How does an `.sp` file declare its word? | **Ruled in direction:** every word file begins with `def` |
| C1–C12 | The questions the rulings left open | **Proposed below, for dan to confirm** |

The C-questions are where this document makes choices. Each one gives the
proposal, the reason for it, and its cost, so any of them can be overturned
without reopening the rest. **C1 and C2 touch rulings made earlier today**, and
they say so.

---

## The rules a user holds

When this lands, this is the whole of it, as a user meets it:

1. **A word starts a sentence. A name is an argument.** They are never confused,
   whatever they are called. A section can be called `title` and a local can be
   called `table`.
2. **A dot means "it".** Inside a word, "it" is the call: the word's own parameters
   first, then what the word was called on.
3. **A name reaches what was named above it, and the nearest wins.** That means
   `each`, `page`, `section` and a word's parameters. It never reaches into the
   word that called you.
4. **A word comes from the nearest family above it.** That means the words that
   came with the word you are nested under, then your own file, then your app,
   then the language. `column` exists only under `table`, and `item` only under
   `list`.
5. **A word never takes a name that is already visible where it is defined.**
   Words do not shadow each other. Names may shadow, and the nearest wins.
6. **A word is written as `def`, followed by what it takes, in the order a
   sentence says it:** a name, content, and then modifiers with their defaults.
   The body follows, indented. If the body says `children`, the word takes
   children.

Rule 1 is N1. Rules 2 and 3 are the scoping rules already built, with C1 and C2
settled. Rules 4 and 5 are N3. Rule 6 is N3a.

---

## N1 — Names by position

**The defect, measured** (all probed 2026-10-04):

| Written | Today |
|---|---|
| `section title`, then `text title.to_s` | A stray empty `<h3 class="title">` is added. Nothing is reported. |
| `page note`, then `text note.name` | Ruby's `NoMethodError`, not an error in the language's own terms |
| `page table`, then `text table.name` | `undefined method 'name' for SlimPickins::Node` |

**The cause:** the transform emits `binding.property` as bare Ruby
([transform.rb:218](lib/slim_pickins/transform.rb#L218)). Words are methods on
the Builder, so Ruby finds the word before `method_missing` is reached
([builder.rb:130](lib/slim_pickins/builder.rb#L130)), and `method_missing` is the
only place names are looked up.

**The ruling:** the grammar already keeps the two apart. A word only starts a
line, and a name only appears as an argument. So a `name.property` argument
compiles to a name lookup (`reach(:name).property`): bindings and parameters
first, nearest wins, then "it", then a refusal in the language's own terms. It
never finds a word. `each`'s refusal of word-named bindings
([words.rb:163](lib/slim_pickins/words.rb#L163)) is no longer needed, so it goes.

## N2 — Interpolation holds one argument

**Measured:** every `#{…}` in the corpus holds exactly one `binding.property`.
There are 10, and none holds anything else.

**The ruling, made precise:** an interpolation holds **one value argument**,
either `.property` or `name.property`, compiled through the same path as any
other argument. Raw Ruby is no longer allowed inside a string. Spelling
`#{.id}` becomes legal, because a dot means "it" everywhere a value can stand.
The splitter bug that refuses `"in #{x}"` and accepts `"#{x} in"` is fixed in
the same change, because both live in the same code.

**Cost:** none to the corpus. The four sites C2 moves become dots (`#{.id}`,
`#{.word_name}`).

## N3 — Families

An `.sp` file is a family: one **head** word, named like the file, plus any
number of **members**. There are three parts:

- **No conflicts within a family.** Two defs with one name in one file is an
  error when the file loads.
- **A family's members are in scope beneath its head**, in the children an
  author writes under the head, at any depth (`each` and `choose` may stand
  between), and inside the family's own bodies. Elsewhere they do not exist.
- **The app is the top-level family**, holding every head in the app, and the
  language sits above it.

**Why this beats a flat namespace** (options a, b and c in the earlier
discussion):

- **It turns PRIMER's rule of government into scope.** "A word is interpreted
  by the word it is nested under." Today that is a check (`parents:`). Under
  families it is simply what exists.
- **The families already exist, held together by checks.** 11 words declare
  `parents:`, and they form seven families: table {column, total}, chart {band,
  line, level}, choose {when, otherwise}, tabs {tab}, list {item}, choice
  {option}, form {hidden}. The language's top-level vocabulary shrinks from 62
  words to 51, and the 11 stop competing for names.
- **Collisions stay local.** An app's `steps` family can have a `step` without
  touching anything else, and two families may each have an `item`.
- **The file is the unit you share.** Copy one file and the whole family comes
  with it.
- **The global registry defect goes away.** Each UI is its own app, so the
  `editor` collision cannot happen, and the `ui_library` memoization trap goes
  with it.
- **Resolution happens at compile time.** The tree and every file's defs are
  known before rendering, so "there is no word `column` here" becomes a compile
  error, in the same walk that checks contracts today.

A family, written:

```
def steps
  list numbered
    children

def step, content
  item .content
```

```
steps
  step "Write the def line"
  step "Write the body beneath it"
```

## N3a — The `def` line

Every word file begins with `def`. Pages still begin with `page`, and may hold
defs, which become the page's own family. Tins are untouched.

**The `def` line has the shape of the sentence it declares:**

```
def <word>, [name], [content], [modifier: default, …]
```

| Spelled | Means |
|---|---|
| `subject` | The word takes a name, and moves "it" to the named thing (`card`, `section`) |
| `variant` | The word takes a name that is a variant: a class, never looked up (`badge ok`) |
| `attribute` | The word takes a name of an attribute of "it", and its content defaults to that attribute's value (`title`) |
| Any other name | A reference: the named thing is looked up (nearest name, then "it") and bound under the parameter's name |
| `content` | The word takes content: text or data |
| `key: default` | A modifier, always optional, with its default (`precision: nil`) |
| `id: nil` | A modifier the language infers from the subject when it is not said (the `card_id` convention) |
| `label: nil` | A modifier the language infers from the app's `label_for` (the `label` convention) |

In the body, the name as it was said is `.name`, whatever its kind. Every other
parameter is a dot under its own name (`.content`, `.precision`).

**This removes the guessing.** Today the runtime decides what a bare name means
by asking whether "it" happens to answer it: `subject.has?`, 17 sites across
`builder.rb`, `partial_word.rb` and `words.rb`. That is the family behind
`section users` losing its class, `search`'s `q:`, and the page-`def` binding
in `Builder.bind_parameters`. HANDOFF lists it as an unscheduled item: "the
contract decides what a bare name means, not `subject.has?`". For every `.sp`
word, the `def` line now *is* that contract.

### Where each old slot goes

The `expects` line carries up to 16 slots. Each one either moves into the `def`
line, is inferred, or turns out to have no reader:

| Slot | Goes to | Evidence |
|---|---|---|
| `name` | The first parameter's spelling | — |
| `content` (`takes: content`) | The `content` parameter | — |
| `modifiers` (`takes: x`) | `x: default` parameters | — |
| `children` | Inferred: the body says `children` | Matches 23 of 23 vocabulary files |
| `subject: shift` | The `subject` spelling | `card` and `section`, the only two, are both `subject` |
| `parents` | Family membership (N3) | — |
| `id`, `label` | Reserved modifier names | `card` and `section`, the only two |
| `shape` | Inferred: a family member *registers*, a body with `children` *encloses*, anything else *presents* | Matches 19 of 23; the four differences are C8 |
| `speech` | Disappears from `.sp` | Only `empty` sets it, and `empty` moves to Ruby (C6) |
| `empty` (flag) | Disappears from `.sp` | Only `empty` sets it (C6) |
| `infers` | The conventions register names its words (C7) | — |
| `gathers`, `inside` | Deleted | No word sets either; measured 0 of 62 |
| `open`, `lazy` | Ruby only | No `.sp` word sets either |

Two declarations remain: Ruby's `contract` macro for the 39 primitives, and the
`def` line for everything written in the language.

### Before and after

`lib/vocabulary/card.sp`:

```
expects subject, takes: content, children: any, takes: id, takes: variant, subject: shift, shape: encloses, infers: card_id, infers: box_tag, infers: box_depth

box .variant, id: .id
  …
```

```
def card, subject, content, id: nil, variant: nil
  box .variant, id: .id
    …
```

`lib/vocabulary/list.sp` takes in `item.sp`, and `parents: list` disappears:

```
def list, variant
  box .name
    children

def item, variant, content
  box .name, .content
    children
```

`lib/vocabulary/money.sp`:

```
def money, content, precision: nil
  span .content, precision: .precision
```

`examples/lore_reader/views/partials/lore_card.sp`. **None of the 12 app partials
has an `expects` line today**, so none is checked, and a misspelled modifier is
accepted and ignored. Each gains a `def` line, and with it checking:

```
def lore_card
  card
    title .title
    …
    actions
      link entry, "Read entry", to: "/entries/#{.id}"
```

---

## The questions the rulings left open

Each is proposed, for dan to confirm or overturn.

**C1. Inside a word, a dot reads the word's parameters first, then what it was
called on.** *This touches the ruling "dots mean it; they never borrow from
further out".* The proposal reads "it", inside a word, as *this call*: its
parameters laid over the thing it was called on. That is the layering Ruby gives
a method (locals over `self`). The `def` line shows which names are parameters,
so a reader always knows which one shadows the other. The ruling still holds
for subjects: a dot never reaches an *outer* subject. **Why:** every one of the
23 vocabulary bodies already reads its parameters by dot (`.content`,
`.variant`), and every app partial reads "it" by dot (`.title`). The grammar has
no other spelling for a whole value: a bare name is a name, not a value. **Cost:**
none, because this is today's behaviour, now stated as a rule. The alternative,
reading parameters by name, needs a new argument rank.

**C2. Word bodies are lexical: they never see the caller's names.** *This
reverses a measured claim in [ON_PAPER.md](examples/doc_reader/ON_PAPER.md), "a
partial under `each account` already sees `account`".* A body sees its
parameters, "it", its own bindings, its family, the app and the language.
Children written under a word are a closure over the *caller's* scope, because
the author wrote them there. That is a Ruby block, exactly. Your rule,
"everything available to a parent is available to its descendants", still
holds in the text the author sees: a word's body is in a different file, so it
is not a descendant in that text. **Why:** a word that reaches a caller's
`entry` works only under callers that happen to bind `entry`. That is a hidden
parameter, and the `def` line exists to make parameters visible. Shareability
depends on it. **Cost:** four sites (`lore_card`, `milestone_card`, `task_card`,
`word_card`). Each reaches the caller's name for "it", and each becomes a dot:
`#{entry.id}` becomes `#{.id}`. Two
dynamic mechanisms go as well: `partial_slot_forwarding` (an omitted modifier
walks enclosing partials, which fired nowhere when 0.4.0o measured it), and,
*if it measures the same*, the overlay that shows a word's modifiers to the
caller's children (`partial_word.rb`, `chain.with(@kwargs, … overlay: true)`).

**C3. Heads never shadow; members follow the nearest governor.** A head may not
take a name already visible where it is defined: a built-in, or another head in
the app. That is the refusal apps get today, extended to page `def`s. **Today a
page's `def card` silently replaces the built-in `card`**; under C3 it is
refused. Members are introduced only beneath their head, so under nested
families the nearest enclosing head's member wins. That is the rule of
government again. **Why:** a reader who knows the language reads `card` and must
get `card`. PRIMER: "a reader cannot tell from the call site which vocabulary a
word came from", which is true only if a word cannot be redefined. **Cost:** no
corpus site redefines a built-in.

**C4. A family offers all its members beneath its head.** There are no private
helpers. **Why:** families are small and cohesive by design. A helper that should
not be offered can live in its own file. The capture risk, a member named
`text` taking over the `text` an author writes beneath the head, is already
closed by C3: `text` is visible everywhere, so no member may be called `text`.
**Cost:** none now. Revisit if a real family needs privacy.

**C5. The `def` line's spelling is the table above.** It is an ordinary sentence:
`def` is the word, the new word's name is its name, the parameters follow,
separated by commas as every sentence's are. Nothing new is added to the
grammar. The reserved spellings are `subject`, `variant`, `attribute`,
`content`, `id:` and `label:`. **Why:** the `def` line reads like a call to the
word it declares, so declaring a word teaches how to call it. **Cost:** the
page-`def` style in `doc_reader/views/index.sp`, the corpus's only page `def`,
changes from `def catalog, documents, title` to `def catalog, documents,
content`.

**C6. `empty` becomes a Ruby primitive.** It is control flow, and one of the five
non-nouns. The other four (`each`, `choose`, `when`, `otherwise`) are already
Ruby. It is the only `.sp` word that sets `speech:` or the `empty` flag. **Cost:**
one word moves. Its behaviour is unchanged.

**C7. The conventions register names its words.** Today, each word lists the
conventions it triggers (`infers:`). The register is the home of convention
prose, so it should also name which words trigger each convention, for Ruby
words as well as `.sp` words, leaving one direction instead of two. The
Inspect panel's "why" is a reverse lookup. `check_conventions.rb` holds the join
from the register's side. **Cost:** the register gains a `words:` field for each
entry. `infers:` leaves all 62 contracts.

**C8. Shape is inferred, and the four differences are corrections.**
`action` and `search` declare *encloses*, but neither takes children, so both
*present*. `paragraph` declares *presents*, but takes children (an inline link
inside a paragraph), so it *encloses*. `empty` leaves `.sp` (C6). **Why:** these
are the same kind of mislabel as R2's mis-grades, found because inference had
nothing to defer to. **Cost:** three words change class in the shape
classification. `check_shape.rb` and the studio shelf follow.

**C9. A word file is named for its head.** `list.sp` begins `def list`, and a
mismatch is refused when the file loads. **Why:** a reader looking for `chart`
opens `chart.sp`, and the docs and studio link to paths.

**C10. `gathers` and `inside` are deleted** from `Contract`, along with
`PartialWord`'s branches for them. No word sets either.

**C11. Ruby words join families through `parents:`, which now means
membership.** Ruby keeps its own spelling, but the scope rule reads membership
from either source, so `table`'s `column` and `list`'s `item` work the same way.
**Cost:** `parents:` stops being a check and becomes the declaration. Its
ancestry walk moves into resolution.

**C12. Studio minting writes the new format.** `/mint` promotes a playground
`def` to a file, and since the file now begins with that same `def`, minting
copies it verbatim.

---

## The plan

One phase at a time, paper first, and **the rendered corpus byte-identical
wherever a phase is meant to change no page** (`bin/byte_diff.rb`). Each phase
ends with the gate green and HANDOFF updated.

| Phase | Builds | Done when |
|---|---|---|
| **1. Names by position** (N1) | `name.property` arguments compile to a name lookup; `each`'s refusal goes | The three N1 probes render correctly or refuse in the language's voice; corpus byte-identical |
| **2. Interpolation** (N2) | `#{…}` holds one value argument, compiled like any other; `#{.id}` is legal; the `"in #{x}"` bug is fixed | A raw-Ruby interpolation is refused; both spellings accepted; corpus byte-identical |
| **3. Lexical bodies** (C2) | Bodies stop seeing caller names; the four sites become dots; `partial_slot_forwarding` goes; the children overlay is measured, then removed if it fires nowhere | Corpus byte-identical; a test shows a body cannot reach a caller's binding |
| **4. The `def` line** (N3a, C1, C5–C10) | A reader builds `Contract` from the `def` line plus inference; 23 vocabulary files and 12 app partials rewritten; `expects` removed; `empty` to Ruby; `infers:` to the register; `gathers` and `inside` deleted | Every word file begins with `def`; every app partial is checked; `bin/generate_vocabulary.rb` output differs only by C8's three shapes; corpus byte-identical |
| **5. Families** (N3, C3, C4, C9, C11) | Multi-def files; a scope tree per library replacing the global registry and the global `CONTRACTS`; resolution at compile time, cached per library; `list` takes in `item` | "No word `column` here" is a compile error; the `editor` collision cannot be constructed; corpus byte-identical |
| **6. The documents** | PRIMER's "Reuse" and "Where the language stops"; CONTRACT.md; the conventions register gains "a parameter's name is its contract"; minting (C12) | `check_vitals`, `check_promises` and `check_conventions` green; PRIMER teaches making a word in one `def` line |

Phases 1–3 are independent of 4–5 and small. Phase 5 is the largest: today's
Transform emits plain method calls, and resolution through a scope tree means
the compilation cache must be keyed by library as well as by source.

## What this closes

- The namespace defect (N1), and the stray element it adds
- The `"in #{x}"` splitter bug (N2)
- Raw Ruby inside strings (N2)
- `subject.has?` deciding what a bare name means, for every `.sp` word (C5)
- The `section users` class defect from [WHAT_IF.md](examples/doc_reader/WHAT_IF.md)
- The 12 unchecked app partials (N3a)
- The global registry: the `editor` collision and the memoization trap (N3)
- `parents:` as a separate check (N3, C11)
- Three ways to mint a word becoming two (dan's impression 3)
- Two contract slots no word sets (C10), and one forwarding mechanism that fires
  nowhere (C2)

## What this does not touch

- **R1–R3** (principle grouping, mis-grades, the format overlap), held in
  `three-rulings-dan-owes.md`. C7 changes where `infers` lives, not how the
  register is grouped.
- **The field family**, which still needs its rule before its table.
- **`children`'s three meanings**, and `contents` as the tin's version of one.
- **Tins**, and the Ruby escape hatch (`words:` modules). Their methods become
  app-level heads, and nothing else changes.
- **Elevating the example apps**, scheduled for a session of its own. Phases 3
  and 4 rewrite their partials only as far as this plan requires.

## Risks

- **Phase 5 changes how every word is dispatched.** Words stop being methods
  found by Ruby and become entries resolved through a tree. The "an unknown word
  fails with its own name" promise has to survive, and should improve, since the
  failure moves to compile time.
- **The compilation cache** is keyed by source today. Keyed by library as well,
  it must not recompile the vocabulary per render.
- **C1 is the subtlest rule here.** If a parameter shadowing a subject attribute
  surprises anyone in practice, the fallback is a refusal when a parameter and
  "it" both answer a name the body reads. That is checkable at compile time for
  declared parameters.
