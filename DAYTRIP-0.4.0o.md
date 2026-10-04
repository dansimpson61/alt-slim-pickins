# Daytrip 0.4.0o — The Regularity Audit, and a Reader That Never Read

Dan invoked the `writing-dsls` skill with no argument, against a project whose
grammar has been written down since v0.3 and whose every sentence is held to it
by `check_grammar.rb`. So the round was not a redesign. It was the skill's
**regularity audit**: enumerate every sentence the language actually accepts,
write down the grammar it implies, and hunt the specific sins — aliases, order
swaps, context-sensitive arguments, asymmetric pairs, modifiers that change
meaning, failures at use time rather than definition time.

The audit's first step turned out to be already built. `bin/word_arguments.rb`
enumerates the whole vocabulary by what each word takes and passes on, read out
of the contracts, so it cannot drift. **The language is more regular than the
audit expected.** Of 31 modifier spellings across 62 words, the shared ones hold
one meaning each — `to:` is the destination on all five words that take it,
`precision:` the same on four, `as:` the format on three, `open:` on two, and
`from:` means *the collection to read instead of the inferred one* on both `each`
and `line`, which was the one most likely to have drifted and had not.

What the audit found instead was concentrated in one place, and it was not a
grammar problem. It was a promise the gate could not check.

---

## Part 1 — `action` declared two modifiers it threw away

`action.sp` declared five modifiers: `to:`, `path:`, `return_to:`, `variant:`,
`status:`. Its body said four of them. It never said `path:` or `return_to:`.

```
expects takes: content, shape: encloses, takes: to, takes: path, takes: return_to, …

choose
  when .status
    button .variant, .content, to: .to, name: status, value: .status
  otherwise
    button .variant, .content, to: .to
```

Measured, rather than read off the file:

```
action "Go", to: "/x", variant: primary
action "Go", to: "/x", variant: primary, path: "/IGNORED", return_to: "/ALSO"
  -> byte-identical output; "IGNORED" appears nowhere
```

So the two values were accepted at definition time and discarded. That is the
exact failure the skill names — a modifier that surfaces as a silent no-op —
and the language's own standard is louder: *unknown attributes raise rather
than resolving to nothing, so a typo fails loudly instead of rendering blank.*

**Three documents said otherwise, and all three were wrong.**

- The promise ledger recorded `path:` and `return_to:` as `verdict: :forwarded`,
  `read_by: ['lib/vocabulary/action.sp']` — naming as the reader a file that
  never says either name.
- `promises.rb`'s own header offered it as the headline example of why the
  ledger must be data and not a grep: "`actions`'s `path:` is read by a
  *descendant*, `action.sp`, through `Chain#container_value`."
- `test_action_inherits_path_and_return_to_from_enclosing_actions_container`
  asserted the two hidden fields appear exactly once each — which `actions.sp`
  does on its own, with `hidden path, .path`. **Every assertion in the test was
  satisfied by the container alone.** The test passed after the declarations were
  removed, which is how its name was shown to be the only part that claimed the
  mechanism.

### Why the gate could not see it

`bin/check_promises.rb` held every recorded reader to one condition: the file
exists.

```ruby
promise.read_by.each do |path|
  next if File.file?(File.join(here, path))
  puts "  LOST READER  …"
end
```

`action.sp` exists. So the ledger could name it as the reader of anything at all
and the gate would agree. The hole is now closed for readers written in the
language, where the stronger check is cheap and exact — the key must appear in
the partial's **body**, with the `expects` preamble dropped first, because
declaring `takes: path` is the promise and not the reading of it:

```
  UNREAD       `path` says it is read by lib/vocabulary/action.sp, whose body never says it
  UNREAD       `return_to` says it is read by lib/vocabulary/action.sp, whose body never says it
```

Those two lines are the whole of it. Every other `.sp` reader in the ledger —
`placeholder`, `q`, `status`, `to` twice, `variant` twice — passes. **The hole
was narrow, and the check that closes it found exactly the two entries already
found by hand.** A Ruby reader is deliberately not held this way: it reads
`attrs[:path]` or a local named anything, and a name search there finds the
wrong thing, which is why the ledger exists.

### What the forwarding mechanism actually does

Worth separating, because the first guess was wrong and the card's standing
caution is to measure the sentence before acting on it. `Chain#container_value`
and the `parameters_for` else-branch are **not** dead code. They work:

```
outer_slot slot: "forwarded"      # expects takes: slot
  inner_slot                      # expects takes: slot, says nothing
-> <div class="box outer_slot"><p class="note inner_slot">forwarded</p></div>
```

The mechanism is real, and it fires **nowhere in the 34-page corpus** — proved by
instrumenting `container_value` and rendering every page the gate proves (34/34
rendered, no failures, zero hits). `actions` says its own `path:` directly, so
the lookup is skipped; `disclosure` reads its own `open:` and says it onward to
its `box`, which is ordinary passing and not chain forwarding either.

So the convention stops citing a word and cites a test, which now exists:
`test_a_partial_finds_a_declared_modifier_on_the_enclosing_partial`, the smallest
pair that can show the mechanism.

---

## Part 2 — One error message served three faults and described one

The argument order is one rule — a name, then content or data, then modifiers —
and `Transform#build` enforces it with `ranks != ranks.sort`. All three ways to
break it raised the same sentence:

> a name may not come after content or data — names come first

For `disclosure open: true, "More"` there is no name in the sentence at all. The
writer was told to move something they had not written. The message now names
the kind that arrived late, from a table beside `rank`:

```
badge .status, ok              a name may not come after content or data
note open: true, ok            a name may not come after a modifier
disclosure open: true, "More"  content or data may not come after a modifier
```

each followed by the rule itself — *a name, then content or data, then
modifiers*. **The rule had no test.** Nothing in the repository asserted the old
message, in the suite or the checkers, which is why it could misdescribe two of
its three cases indefinitely. It has one now, in `phase0_test.rb`'s *errors speak
the language* section, covering all three inversions.

---

## Part 3 — The guessability proof, re-run

The skill's acceptance test: sentences written by analogy from the grammar table
alone. Sixteen regular sentences absent from `DESIGN.md`'s own proof were
written mechanically and run. **Fifteen parse.** The sixteenth was ill-formed by
my hand, not the language's — `disclosure open: true, "More"` puts content after
a modifier — and it is the sentence that exposed Part 2.

Six sentences were then written as a fluent speaker's *wrong* guesses, to find
where the grammar invites an error. All six are refused at definition time, in
the language's own words, which is the behaviour the skill asks for:

```
action primary, "Commit"            `action` takes no name — primary
input email, required: true         `input` has no `required:` modifier
field bio, placeholder: "Tell us"   `field` has no `placeholder:` modifier
textarea bio, placeholder: "…"      `textarea` has no `placeholder:` modifier
field email, readonly: true         `field` has no `readonly:` modifier
input email, step: 1                `input` has no `step:` modifier
```

The refusals are good. **What they reveal is that the guesses were reasonable** —
and that is Part 4.

---

## Part 4 — Five irregularities found, named and not performed

Each is a language decision, which by this project's *How roadmaps go* is dan's.
Each has been measured; none has been acted on.

### 1. `link` has a second sentence shape, and the grammar denies having one

`DESIGN.md` says *the order never varies*. `Link#evaluate` carries a branch that
swaps two positional arguments when the first is not a Symbol:

```ruby
if @args.size >= 2 && !@args[0].is_a?(Symbol)
  attrs[:label] ||= @args[0]
  attrs[:to]    ||= @args[1]
end
```

Both shapes work, with the roles reversed:

```
link show, "View"          -> <a href="/show" class="link">View</a>
link "View", "/products"   -> <a href="/products" class="link">View</a>
```

The second is documented nowhere — not in `DESIGN.md`, not in `VOCABULARY.md`'s
`link` entry — and used nowhere: all 55 `link` sentences in the repository that
lead with a string say `to:` explicitly. This is the skill's context-sensitive
positional argument exactly, and it is the one finding that contradicts a
written claim about the grammar. Deleting the branch narrows the language by a
sentence nothing speaks; it is still dan's call, because it is the language.

### 2. `tab` is the one structural child not held to its parent

Ten words declare the parent they belong inside, and `item` is the pattern:

```
item "Stray"   outside list    -> refused: `item` belongs inside `list`
tab "Stray"    outside tabs    -> <div class="tab-panel" role="tabpanel"></div>
```

`tab` declares no `parents:`, so an orphan renders — **and silently drops its
content**, because `tab` maps content to `:label` and the label is rendered by
the enclosing `tabs`, which is not there. `parents: [:tabs]` is the one-line fix
and makes it refuse like its ten siblings. It is a defect rather than a
preference; it is listed here because it narrows what the language accepts.

### 3. The field family's modifier sets are arbitrary

| | `type:` | `placeholder:` | `required:` | `readonly:` | `step:` | `rows:` |
|---|---|---|---|---|---|---|
| `field` | ✓ | | ✓ | | ✓ | |
| `input` | ✓ | ✓ | | | | |
| `textarea` | | | ✓ | ✓ | | ✓ |

No rule predicts this table, so a fluent speaker guesses wrong four times out of
six (Part 3). Some of it is principled — `field` infers its label, so a
placeholder would restate it — but the principle is written nowhere, and
`required:` on `field` and `textarea` but not `input` does not follow from it.

### 4. `variant` has two spellings, and one word did not need the second

Fourteen words take a variant as a bare name (`badge ok`, `button primary`,
`paragraph compact`). Two take it as `variant:`. For `card` the name slot is
already the subject, so the modifier is forced. **`action`'s name slot is
empty** — `name: :none` — so `action primary, "Commit"` was available and
`action "Commit", variant: primary` was chosen instead. `item.sp` proves a
partial can take a variant in the name slot (`expects variant`, read as `.name`),
so this is a one-line change to the preamble, not a mechanism.

### 5. `search`'s `q:` carries a value under a parameter's name

`q:` reads as the query parameter's name; it holds the current query's *value*
(`input q, .q`). The only modifier in the language whose spelling is an
abbreviation, against the rule that conciseness is never bought with obscurity.

### And one in the project's own tooling, not the language

`HANDOFF.md`'s gate command runs `Dir["test/**/*_test.rb"]` — **547 runs**. The
gate's own Suite leg asks `Census.test_files`, which adds the example apps'
suites — **602 runs**. Both green, but the documented command is the narrower
one, which is two spellings of "the suite" in a project that holds every truth to
one home.

---

## What landed

- `bin/check_promises.rb` — a `.sp` reader must say the key in its body, not
  merely exist. The preamble is dropped before looking.
- `lib/vocabulary/action.sp` — `takes: path` and `takes: return_to` removed; the
  two values are refused at definition time now instead of being discarded.
- `lib/slim_pickins/promises.rb` — both entries corrected to
  `declared_by: [:actions]`, `read_by: ['lib/vocabulary/actions.sp']`,
  `verdict: :read`; the header's false example replaced with two true ones and
  the account of why a named reader is not enough on its own.
- `lib/slim_pickins/conventions.rb` — `partial_slot_forwarding` describes the
  lookup truthfully and points at a test rather than at a word.
- `lib/slim_pickins/transform.rb` — the order error names the kind that came
  late, from a `KINDS` table beside `rank`.
- `test/vocabulary_partials_test.rb` — the forwarding mechanism gets the test
  the convention now promises; the misnamed test renamed to what it verifies.
- `test/phase0_test.rb` — all three order inversions asserted.
- `VOCABULARY.md` — regenerated: `action` now lists three modifiers, not five.

## Verification

- **Ten checker legs**: 0 problems each. Grammar `1,289 sentences, 96 words
  defined, 0 problems`; promises `35 promises · read: 34 · forwarded: 1 · no
  reader: 0`; conventions 38; pages 34.
- **Suite as the gate runs it** (`Census.test_files`): **602 runs, 6,527
  assertions, 0 failures, 0 errors, 0 skips**. The two new tests are the
  difference from 600.
- **`ruby -w -c`** clean over every changed file.
- **The corpus is byte-identical.** `bin/byte_diff.rb` run against a worktree at
  `HEAD` and against the working tree gave the same digest, `f80c66e134b3ccc925de7893`,
  and `diff -r` over all 34 written pages reports no difference. Nothing any page
  renders changed; what changed is what the language refuses and what the ledger
  says.

## What the round taught

Written in `LORE.md`. The short of it: **the promise ledger was built because a
name search finds the wrong reader, and it inherited the same weakness one level
up** — it recorded a reader by name, and the gate checked the name's file
existed. The example it offered as proof of its own necessity was the one entry
that was false, and it stood from the ledger's first day (2026-09-17, daytrip
0.3.0b) to today because three documents, one test name and one gate all agreed
with each other rather than with the code.
