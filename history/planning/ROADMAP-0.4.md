# alt-slim-pickins — roadmap 0.4

**An even-numbered roadmap. It leads with the backward eye.**

Status: **closed 2026-10-11, on dan's word.** Written 2026-10-10. 0.4 ran for seventeen daytrips
before it had a written question. This document names the question late, says
what success looks like, and records how the daytrips arrived at it. It is a
roadmap and not a plan. It has no phases, and it must not grow any (see *What
this document is not*).

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
> *Walk like the chameleon: watch what is ahead, glance back at what is behind.*

## The question

> **Do the conventions keep their promises? Does the language do the
> bookkeeping, so that an author only has to name things?**

dan accepted the question as worded on 2026-10-10.

It is a backward-eye question, which is what an even roadmap asks for (README,
*How roadmaps go*). It does not ask what the language should learn next. It
asks whether what the language already decides on an author's behalf is true.
[CONVENTIONS.md](CONVENTIONS.md) sets the standard. Every convention makes three
promises: you can look it up, you can override it by saying it, and it is the
same everywhere. The guide ends with a table of the places where those
promises are weakest. 0.4 is finished when that table is.

## The definition of success

1. **Every override works.** CONVENTIONS.md has twenty *To override* lines.
   Four of them answer "nothing". dan ruled three more inadequate on 2026-10-10:
   `heading_level`'s "nest it differently", `choose`'s "write two `choose`s",
   and `box_body_over_children`'s "give the box children and no content". Those
   three are rows in the weak-spots table. The other thirteen name a way to
   overrule the convention. Each of the thirteen is proved by a test, or by a
   page in the corpus, that fails if the convention wins instead. The guide's second
   pattern asks how many documented overrides no page exercises. That question
   gets a count, and the count is zero.
2. **The weak-spots table is empty.** Each row is either fixed or ruled by dan
   to be a limit, and the guide states that limit plainly. A fix is one commit,
   with a test that fails on the old code. The corpus of 38 pages stays
   byte-identical under `bin/byte_diff.rb`, or every byte that changes is named.
   dan and a session walk the guide's three patterns together, and each ruling
   ships as code.
3. **No fix makes the author do the compiler's job.** No row is closed by
   adding a keyword, a declaration or a qualified name (`word.x`) that the
   author must write. The convention learns, and the author's sentence does not
   get longer.
4. **Code leads paper.** Every design document 0.4 opened has shipped code or
   has been withdrawn in writing. 0.4.0p was rejected, and 0.4.0q is withdrawn
   to 0.5 (see *Families goes to 0.5* below). From 2026-10-10 the house rule
   holds: no new design document until the last one has shipped code or been
   withdrawn.
5. **Green, and looked at.** All twelve legs and the suite are green at close,
   and dan has looked at every page a fix changed. The gate cannot see the
   visual layer, or any input the corpus never uses.

**What drift looks like:** a new design document; a fix whose test also passes
on the old code; a row closed by giving the author something to declare; corpus
bytes that change without an explanation; Markdown growing while `lib/` stands
still.

### Where it stands at writing (2026-10-10)

The four plain defects the review named are fixed. Each was fixed in its own
commit, with a test that fails on the old code, and each left the corpus
byte-identical:

- `money` showed 12.99 as `$12`.
- `card id:` threw away the id the page said.
- `input_step` gave a field holding 2.5 a step that would not let the form
  submit.
- `plural_collection` turned `each address` into a search for `addresss`.

The gate saw none of the four, because no page in the corpus holds those
inputs. That is the same blind spot criterion 5 names. At writing the gate was
green: twelve legs, 612 runs, 0 failures.

The table had fourteen rows at writing, and sixteen once dan's ruling on the two
inadequate overrides added theirs. One of them was found while probing
`input_step`: a `BigDecimal` field reads `0.25e1` and gets no step.
`PROJECT.md`'s `next_step` keeps the working order. This document does not.

### Where it stands at the end of 2026-10-10

| Criterion | State |
|---|---|
| 1. Every override works | **Met.** Each of the thirteen was broken in turn, and the suite went red. Three that nothing caught now have tests. dan ruled three more inadequate, and they became rows. |
| 2. The weak-spots table is empty | **Met.** dan walked the three patterns. Every row was fixed (a test fails on the old code) or ruled a stated limit, with the reason in its entry. |
| 3. No fix makes the author write more | **Met.** Where refusing would have meant the author writing a `box` (`root_class`), the row closed as a stated limit instead. |
| 4. Code leads paper | **Met.** 0.4.0p says on its own page that it was rejected. 0.4.0q is withdrawn to 0.5. No design document was opened since. |
| 5. Green, and looked at | **Met.** Green: twelve legs, 627 runs, 0 failures. On 2026-10-11 dan looked at before-and-after renders of every page the fixes changed, each with its links' live status: portfolio's nav and Details links, and word_graph's no-match message. |

**0.4 closed on 2026-10-11.** Its forward question goes to 0.5: families, from
`DAYTRIP-0.4.0q.md` as starting material.

## How 0.4 arrived at its question

0.3 had closed by 2026-09-22. It had proved the vocabulary across a garden of
apps, with no missing affordances. 0.4 did not open with a question. It opened
as a run of daytrips, on dan's principle that *the itinerary is a vector, and
daytrips give it volume*. The early daytrips built forward, one volet at a
time.

The turn came with 0.4.0h (2026-10-02). dan asked for the backward eye, and
the audit measured that the gates were aimed one layer above where the
project's defects actually live. Rounds i to m worked through its prioritized
list. Four rounds in a row found that a list item's own premise was wrong.
Measuring the premise before acting on it became the project's standing
caution. Round o audited the language's regularity and found the grammar
sound, but a promise the gate believed and the code did not keep.

Then the eye turned forward again, toward naming and scoping. 0.4.0p
(2026-10-04) put words, names and files on paper, and dan rejected it. In his
words, it "was requiring the author to take care of the compiler rather than
the other way around." 0.4.0q (2026-10-05) replaced it with families, written
to that test. It was also paper.

On 2026-10-09 dan redirected from families to conventions first, and
CONVENTIONS.md was written. Every registered convention was rendered and
measured, and its weak spots were collected in one table. On 2026-10-10 a
review found paper outrunning code. `lib/` had no commit from 2026-10-04 to
2026-10-09, while 0.4.0p, 0.4.0q and CONVENTIONS.md were being written. dan
accepted four corrections:

- commit the guide;
- fix the plain defects, one commit each;
- write this definition of success;
- add the rule against new design documents.

The guide was the first thing 0.4 had written that could hold the language to
account. The question above is that guide's own promise, taken seriously.

### Families goes to 0.5

dan's ruling of 2026-10-10: families is new design, not something 0.4's look
back asked for. 0.4.0q is withdrawn from 0.4 and becomes 0.5's forward
question. DAYTRIP-0.4.0q.md stays where it is as a dated record. When 0.5
opens, 0.4.0q is its starting material, not its plan, and its premises must be
measured again before anything is built. Its Step 0 is already done. Its D1
should be withdrawn, because kind names such as `name` and `subject` shadow the
subject's own fields. No ROADMAP-0.5.md exists yet, on purpose.

## The daytrips, briefly

Seventeen daytrips, grouped where they share a theme. Each file is its own
record, and none of them is updated.

**The volets, 2026-09-22 to 09-24: building forward.**
- [0.4.0a](DAYTRIP-0.4.0a.md) — The truthful floor: `SlimPickins::Census`
  becomes the live source for every vital.
- [0.4.0b](DAYTRIP-0.4.0b.md) — Expressive composition: `card` shifts the
  subject, a group of actions shares one form, and partials forward their
  payload.
- [0.4.0c](DAYTRIP-0.4.0c.md) — Studio wins: the suite becomes a live
  `/status` leg, and the workbench gains an Inspect surface.
- [0.4.0d](DAYTRIP-0.4.0d.md) — A five-tier taxonomy, used to diagnose the
  vocabulary. It found `figcaption` and `summary` to be HTML leaks.
- [0.4.0e](DAYTRIP-0.4.0e.md) — An author can `def` a word inside the `.sp`
  file that uses it, with no declaration.
- [0.4.0f](DAYTRIP-0.4.0f.md) — Package C: a privileged `tag` primitive, the
  two leaks absorbed, and the canonical vocabulary down to 62 words.

**The workbench, 2026-09-25.**
- [0.4.0g](DAYTRIP-0.4.0g.md) — The council skill. The workbench's spatial
  frontier was closed, and three rendering defects were found by eye.

**The backward eye, 2026-10-02 to 10-03: the audit, and its list worked
through.**
- [0.4.0h](DAYTRIP-0.4.0h.md) — What the gates cannot see. The checkers earn
  their keep but are aimed above where the defects live. Its prioritized list
  runs from Tier 0 to Tier 7.
- [0.4.0i](DAYTRIP-0.4.0i.md) — Two legs for the two blind spots:
  `check_vitals.rb` and `check_ruby.rb`.
- [0.4.0j](DAYTRIP-0.4.0j.md) — Tier 5. Both of its premises were wrong, and
  neither of its items took away a line.
- [0.4.0k](DAYTRIP-0.4.0k.md) — The studio's inspector, rewritten in the
  language it inspects.
- [0.4.0l](DAYTRIP-0.4.0l.md) — The semantic node becomes `SlimPickins::Node`,
  a `Data.define`.
- [0.4.0m](DAYTRIP-0.4.0m.md) — Card surgery. The card's history moved to
  `history/CHRONICLE.md`, and none of it was deleted.
- [0.4.0n](DAYTRIP-0.4.0n.md) — How words are actually scoped. There is one
  global registry, so constructing one library changes how every other library
  renders.
- [0.4.0o](DAYTRIP-0.4.0o.md) — The regularity audit. The grammar holds, and a
  recorded reader turned out never to read.

**The forward eye, 2026-10-04 to 10-05: paper, now closed.**
- [0.4.0p](DAYTRIP-0.4.0p.md) — Words, names, and the file that holds them.
  dan rejected it for asking the author to mind the compiler.
- [0.4.0q](DAYTRIP-0.4.0q.md) — Families: one namespace per file. Withdrawn
  from 0.4 and carried to 0.5.

## What this document is not

This document is not a design document, and it is not a phase plan. It holds
the question, the definition of success, and how 0.4 got here. The working
order belongs in `PROJECT.md`'s `next_step`. The open work belongs in
CONVENTIONS.md's weak-spots table. A ruling dan makes while walking the
patterns ships as code, and then shows up as a shorter table. If a section
here starts to propose new mechanism, that is the drift criterion 4 exists to
stop.
