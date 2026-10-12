# Daytrip 0.5.0a — Before any migration: the parameter line, and a chain that only reports

**Status: closed 2026-10-11.** Part 1 ruled by dan (Option A + B1). Part 2
confirmed by `bin/probe_lookup_chain.rb` (exactly `editor` differing, 178 family
calls across the 11 contained words, 0 unresolved). Ready for 0.5.0b to enforce
the chain and delete the global write.

**Baseline:** all twelve gate legs green, and the suite at 627 runs, 6,698 assertions,
0 failures, at `e8bb528`.

**This is the design document that the 2026-10-10 rule governs** (no new design
document until the last one has shipped code or been withdrawn). The last one,
`DAYTRIP-0.4.0q.md`, was withdrawn on 2026-10-10, so this one may be written. Nothing
else designs in parallel with it.

## Why these two come first

`ROADMAP-0.5.md` names one kind of drift above the others: *deleting the old
declaration line before the lookup-and-containment mechanism is built and proven.*
So the two things that have to happen before any file is migrated are:

1. **Decide what an author writes in place of `expects`.** This is design, and it is
   dan's to rule.
2. **Prove the nearest-first chain against the real corpus, changing nothing.** This
   is measurement. It either confirms the families idea or stops it.

They do not depend on each other, so they can run side by side.

---

# Part 1 — What replaces `expects`

## What `expects` is today

Every hand-written word file opens with one line telling the compiler facts about the
word. Here is `card`, from `lib/vocabulary/card.sp`:

```
expects subject, takes: content, children: any, takes: id, takes: variant, subject: shift, shape: encloses, infers: card_id, infers: box_tag, infers: box_depth
```

Twenty-eight files carry one: twenty-three in `lib/vocabulary/`, and five in the
studio (`shell`, `detail`, `tree`, `twig`, `why_card`). dan ruled on 2026-10-11 that
the studio's five migrate too. `ROADMAP-0.5.md` (criterion 6) requires the line to go.
dan's preferred replacement is a plain parameter line, `def card, subject, content`,
where the parameter's own name carries the declaration.

## The problem, shown rather than described

That parameter line already exists in the language, as the `def` an author can write
at the top of a page. **Migrating the 28 files onto it would give every word its
behaviour.** So its behaviour was probed, today, with a record shaped like the apps'
records (a Struct with a `name` field, as in `word_graph`'s `ShapePoint`):

```
def framed, name
  box
    children

page "Demo"
  each point
    framed
      paragraph .name
```

The point's name is `"encloses"`. This renders `<p class="paragraph"></p>`, which is
**empty, and no error is raised.**

What happened: `framed` declares a parameter called `name`. The page never gives it
one, so it is bound to nothing. That empty binding is laid over the point *for every
line beneath `framed`*, including the `paragraph .name` the page author wrote. The
page author never wrote `name` on any `def` line and cannot see `framed`'s file from
where they are, yet their `.name` now reads `framed`'s empty parameter instead of
the point's name.

There is a second, smaller case, inside the word's own body:

```
def tagline, name
  paragraph .name
```

Called on the same point with nothing said, it also renders empty. The record's
`name` is hidden by the parameter. The difference is that **here the author of
`tagline` wrote `name` on the line directly above.** They can see the shadow.

**The control:** the `.sp` words that were probed do *not* leak. `list`/`item`,
`card point` and bare `card`, each wrapping a `paragraph .name`, all rendered
`"encloses"` correctly. That is three words of twenty-eight, not a survey. Part 2's
walk over the corpus is the place to confirm it for the rest. On this evidence the
hazard lives in `def`, and the migration would carry it everywhere.

## How common the collision would be

The nine names that 0.4.0q proposed parameters must use (`subject`, `variant`,
`attribute`, `destination`, `topic`, `notation`, `value`, `binding`, `name`) were
counted against the apps' own data. Method: grep the example apps' and the studio's
Ruby for each name as a field or method, and the `.sp` files for `.name`-style reads.

| name | mentions in app/studio Ruby | reads in `.sp` |
|---|---|---|
| `name` | 57 | 29 |
| `variant` | 7 | 6 |
| `value` | 3 | 1 |
| `attribute` | 2 | 1 |
| `subject` | 1 | 0 |
| the other four | 0 | 0 |

`name` is the collision almost by itself. Records that carry a `name` field include
the studio's `Entry`, `UI`, `TierGroup`, `Why` and `Result`, `word_graph`'s
`ShapePoint`, roth's `Field`, and doc_reader's shelf entries. `variant` collides once:
the studio inspector's `Node` has a `variant` field. `subject`, which is the
name that matters most (it marks a word that shifts the subject, which today means
`card` and `section` among the `.sp` words, plus four Ruby words), collides with
nothing in the corpus.

## The test the options are sorted by

From the lore of 2026-10-09, after dan rejected reaching a word's inputs as
`card.content`:

> Shadowing by a name the author chose is nearest-wins working; the hazard is names
> the author did not choose or cannot see.

The first example above is a name the page author **cannot see**. The second is a
name the word's author **chose** and can see. The fix has to remove the first kind
entirely and leave the second as ordinary nearest-wins.

## What is already ruled out, and by whom

- **A qualified spelling such as `card.content`**: dan rejected this (2026-10-06 to
  10-09) as configuration that ignores convention. Conventions act on names, so
  stripping or qualifying names removes what they run on.
- **Anything an author must add to tell the two apart**: `ROADMAP-0.5.md` criterion 5.
- **New punctuation**: extending the language adds vocabulary, never syntax.
- **Refusing the clash when the page renders**: dan's 2026-10-10 ruling that the data
  never breaks the page. The compiler cannot see a record's fields at compile time,
  so a clash can only be found at render time, and there it may not raise.

## The options

### A — A word's parameters are visible only in the body written beneath its `def` line

This fixes the first example. Parameters become lexical: they reach the lines the
word's author wrote, and never the lines a page author nests inside the word. It is
what the `.sp` words already do in practice, made a rule for `def` too.

**Every option below needs A.** Without it, the leak survives whatever the parameter
is called.

**Cost, measured 2026-10-09 (lore):** capturing the caller's lines before binding the
parameters left the corpus byte-identical and the suite green for `def`. For `.sp`
words it broke exactly two tests, both of the convention where *a word missing a value
looks for it on the word that contains it* (`partial_slot_forwarding` in
`CONVENTIONS.md`). **`ROADMAP-0.5.md` criterion 7 holds that convention out of scope
unless dan pulls it in.** So A cannot be done for the `.sp` words without his word on
that convention. It can be done for `def` alone without touching it.

### B — For the word's own body: four ways to tell its parameter from the record's field

**B1 — The parameter's name is free, and its kind is read from where the body sends
it.** (Recommended, subject to the measurement in Step 1.)

```
def badge, status, content
  span .status, .content
```

`status` is passed to `span`'s first slot, and that slot's kind is a variant, so
`status` is a variant. Nobody declared it. The author names the parameter for what it
is, which is dan's stated preference. If the author picks a name their own record also
has, that is a shadow they chose, on the line above, and nearest-wins is working as
intended. `name` stops being forced on anyone.

The one thing data flow cannot show is **whether a word shifts the subject**, because
shifting changes what the caller's lines see rather than what the body reads. For
that, `subject` stays the single parameter name that carries meaning:
`def card, subject, content` shifts. Measured above, `subject` collides with nothing.

*Cost:* reading kinds from data flow has to work for all 28 files, and nobody has
measured that yet. If it fails for some file, that file is a finding to bring back
to dan, not a reason to add a declaration.

**B2 — The nine kind names stay required, and the record's field wins over the
parameter.** The author writes nothing extra. But a word's own parameter silently
loses whenever the record happens to have a field of that name. The parameter becomes
the name the author cannot rely on, which only moves the invisibility.

**B3 — The nine kind names stay, and the clash is refused.** It can only be detected
at render time, which the 2026-10-10 ruling forbids. Listed so the omission is
visible, not because it is viable.

**B4 — A parameter is said bare in the body; a dot always means the record.**

```
def badge, variant, content
  span variant, content
```

This uses an existing distinction: a dot means data, a bare word is language. But a
bare word in argument position already means a name (`box document`, `input q`), so
`box document` inside a word with a `document` parameter would change meaning without
any change on that line. That is a quiet rebinding of a literal, which is the same
problem in a new place.

## Dan's ruling (2026-10-11)

**Ruled:** Option A (strictly lexical scope for parameters) combined with Option B1
(free parameter names, with parameter kinds inferred from where the body passes them,
and `subject` as the single keyword signaling subject-shift).

The decision:
- Parameters of a word are strictly lexical to its definition body and never leak
  into the caller's nested `children` blocks.
- Authors choose expressive, natural parameter names (`def badge, status, label`),
  and the compiler infers kinds from data flow.
- The author writes prose; the compiler does the classification work.

---

# Part 2 — The chain, reporting only

**Needs no ruling.** It builds the nearest-first lookup beside today's lookup, runs
the whole corpus through both, and reports where they differ. It changes no
behaviour.

## What exists today (measured 2026-10-11)

- **The global write:** `lib/slim_pickins/compilation.rb:34`,
  `SlimPickins::Word.registry[word] = klass`. Every compiled `.sp` word lands in one
  shared table, and the last one compiled wins.
- **Ruby words write the same table** when their class is defined
  (`lib/slim_pickins/word.rb:20`).
- **Every builder gets one method per table entry** (`lib/slim_pickins/builder.rb:36`).
  That is how a word becomes callable, and why the table's last writer decides what a
  page gets.
- **Two refusals keep apps off language names:** the duplicate check in
  `Library#initialize` (around `library.rb:97`) and `refuse_shadowing!`
  (`library.rb:271`). These are the protected tier that criterion 4 removes. They stay
  untouched in this daytrip.
- **The eleven contained words:** ten Ruby words declare `parents:` in `words.rb`
  (three under `chart`, two under `choose`, two under `table`, one each under
  `choice`, `form` and `tabs`), plus `item` under `list`. Counted this session.

## Steps

1. **A resolver, as a pure function.** Given a page's parsed tree (`Transform#tree`)
   and its library, answer for every sentence *which definition it would reach*,
   walking nearest first: the file's own `def`s, then the families of the words it
   is written inside (nearest enclosing word first), then the app, then the language.
   A contained word's family is modelled from today's `parents:` declarations. For
   example, `column` sits in `table`'s family. Nothing calls this resolver at render
   time.
2. **Run it over everything that renders.** That means the 35 verified pages, every
   `.sp` and `.tin` in the repo, and both studio UIs, each against the library it is
   actually served with. Per the lore: probe with the libraries the apps really build,
   not with libraries of the right shape.
3. **Report three lists.**
   - *Resolves differently than today:* expected to be exactly `editor`, which means
     the classic UI's and the workbench's each reaching their own.
   - *Resolves only through an enclosing word's family:* expected to be exactly the
     eleven contained words, each at the lines where it is used.
   - *Does not resolve at all:* expected to be empty.
4. **If any list holds more than expected, stop and report.** Do not adjust the chain
   until the list is short. This is the same instruction 0.4.0q carried, and it is
   the reason this step exists.
5. **Prove nothing moved.** Take a `ruby bin/byte_diff.rb` digest before and after,
   within this session, because the digest moves whenever `LORE.md` does. The twelve
   legs stay green.

**The instrument:** a script in `bin/`, with its output pasted into *What it found*
below. Whether it becomes a test or a gate leg later is dan's call, not this
daytrip's.

---

## Found while measuring, recorded and not acted on

- **`studio/app.rb:46–52` says the UI library is "built once per UI per process."
  It is built once per request.** Sinatra's `call` runs `dup.call!(env)`, so
  `@libraries` lives on a fresh copy of the app each time. That is why the `editor`
  collision stays hidden, and it means criterion 1's "cache it again" really means
  caching across requests. The comment is wrong today and should be corrected when
  criterion 1 is worked. That is code this daytrip passes by, so it gets a proposal
  and not a fix.
- **`HANDOFF.md`'s vitals quote Check Grammar as 1359 sentences and 98 words;** the leg
  now says 1310 and 97, probably since `pages/` was cleared. The vitals check cannot
  see it because the figure is quoted as gate output.
- **A correction of my own:** I expected the `.sp` words to leak parameters into
  their callers' lines, as the 2026-10-09 lore described for `def`. The three I
  probed do not. Only `def` leaked. The plan above is built on the measurement, not
  the expectation.

## What this daytrip does not do

- Migrate any file, delete `expects`, remove the global write, or lift either refusal.
- Touch any of criterion 7's four carried-in questions, except where option A names
  one for dan to rule on.
- Change any page's output. Part 2 must leave the corpus byte-identical.

## Done when

- **Part 1:** dan has ruled on A and on B. The ruling is recorded here, and the next
  daytrip measures B's premise across the 28 files (for B1, that every parameter's
  kind can be read from where the body sends it) before any file moves.
- **Part 2:** the three lists are in hand. Either they match the expectation, and the
  chain is confirmed for the next daytrip to enforce, or they do not, and the finding
  goes to dan.

## What it found

Part 2 ran on 2026-10-11 (`ruby bin/probe_lookup_chain.rb`), resolving all 1,056
sentences across all 97 `.sp` and `.tin` files in the repository nearest-first:

1. **Resolves differently than today's global registry:**
   Exactly `editor` (3 calls across 3 files):
   - `studio/uis/classic/views/index.sp:5` -> resolves nearest to `studio/uis/classic/views/partials/editor.sp`
   - `studio/uis/workbench/views/docs.sp:26` -> resolves nearest to `studio/uis/workbench/views/partials/editor.sp`
   - `studio/uis/workbench/views/index.sp:3` -> resolves nearest to `studio/uis/workbench/views/partials/editor.sp`
   Under the old global registry, both UIs wrote to the same shared hash key
   (`Word.registry['editor'] = klass`), so the last UI compiled clobbered the other.
   Under the nearest-first resolver, each UI cleanly reaches its own `editor.sp`.

2. **Resolves only through an enclosing word's family (178 calls across 11 words):**
   - Inside `choose`: 69 calls (`when`, `otherwise`)
   - Inside `table`: 35 calls (`column`, `total`)
   - Inside `list`: 25 calls (`item`)
   - Inside `choice`: 22 calls (`option`)
   - Inside `chart`: 13 calls (`band`, `level`, `line`)
   - Inside `tabs`: 9 calls (`tab`)
   - Inside `form`: 5 calls (`hidden`)
   Every single call to any of the 11 contained words occurred strictly within its
   parent family. Zero calls occurred outside a parent.

3. **Does not resolve at all:**
   **Zero.** (0 problems across 1,056 sentences).

The chain confirmed its predictions completely. No surprises, no unexplained
collisions. Nearest-first resolution is ready for the next daytrip to enforce.
