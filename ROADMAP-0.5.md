# alt-slim-pickins — roadmap 0.5

**An odd-numbered roadmap. It leads with the forward eye.**

Status: **open.** Written 2026-10-11, drafted by the steward and confirmed by
dan across several rounds of correction. It is a roadmap and not a plan: it
names the question and what success looks like, and leaves the step-by-step
work to daytrips, the same way 0.4 did.

## The question

> Does a word's name have to be global? Can every page file become the
> namespace of the words it defines — found nearby first, the file itself
> checked before the word it's nested inside, before the app, before the
> language — so that two authors, or two studio interfaces, can each write a
> word called "editor" and each get their own, with no accident of load order
> deciding which one wins?

This is the forward-eye question an odd roadmap asks for (README, *How
roadmaps go*). It was first proposed as "families" in `DAYTRIP-0.4.0q.md`,
withdrawn from 0.4 on 2026-10-10 because dan ruled it was new design, not
something 0.4's look back had asked for, and carried forward as 0.5's starting
material rather than its plan.

## The definition of success

1. **The editor collision is actually gone, not papered over.** Today, two
   different studio interfaces — the classic one and the workbench — each
   define their own word called "editor." Which one a page actually gets
   depends on which was loaded most recently into the one shared list the
   whole program uses, and the code currently refuses to cache a certain
   lookup specifically to keep that accident from showing. After this work,
   both editors render correctly no matter the load order, that lookup can be
   cached again, and a test proves it.

2. **The one line of code that lets this happen is deleted, not guarded
   against.** There is a single place in the compiler where any word, loaded
   at any time, can silently overwrite any other word just by sharing its
   name. That line goes. From then on, a word is found by checking nearby
   first — the file it's written in, then the word it's nested inside, then
   the app, then the language — resolved while the page compiles, so a
   misspelled or unreachable word is refused immediately, with its line
   number, in the language's own words, never discovered later when a page
   tries to render. The language is not a protected category in this chain —
   it is simply its outermost ring, reached only because nothing nearer
   defined the word first. `money` is found by the same walk that finds
   `editor`; it just happens, today, that nothing nearer has been written to
   override it.

3. **The eleven words that are only supposed to exist inside something else
   actually only exist inside something else.** Ten built-in words (a
   table's column, a chart's axis line, and others like them) and one
   hand-written word (an item that only makes sense inside a list) currently
   carry a note saying "I belong inside this other word," but nothing
   enforces that note today — it is a comment the code trusts. After this
   work, that containment is real, the way Ruby already lets one class live
   inside another. Whether a list needs its item becomes something you can
   see by opening the file, not something you have to take on faith.

4. **The example apps are allowed to improve, not just permitted to drift —
   and at least one page proves this roadmap bought something real.**
   Nothing in this roadmap requires freezing every page exactly as it
   renders today; the corpus has no sacred cows, and locking it in place
   would trade the chance at real improvement for mere consistency with its
   own, often accidental, past. What is required:
   - Every page a step touches is rendered before and after, and shown to
     dan directly — not described in prose, not left for him to go run
     something and look for himself.
   - At least one of the eight example apps that no longer carries its
     weight is named and either improved or retired during this roadmap,
     rather than left untouched while everything around it changes.
   - **The portfolio app's `account_card` becomes plain `card`, contained
     to that app's own family.** Today, nine different partials across six
     apps and the studio — `account_card`, `document_card`, `lore_card`,
     `milestone_card`, `task_card`, `question_card`, `unreviewed_card`,
     `why_card`, `word_card` — are all some variation of "a card for this
     one record," and none of them can simply be called `card`, because the
     code still raises an error if an app tries to use a name the language
     already uses. dan already ruled on 2026-10-05 that this should be
     allowed — an app may use a language word's name, and the gate merely
     reports it — but that ruling never shipped as code. Renaming
     `account_card` to `card`, safely contained to the portfolio app's own
     family, is the concrete proof that this roadmap lets an author write
     the name they actually mean, not a demonstration invented after the
     fact to justify the work.

5. **No fix makes the author do the compiler's job.** This is carried
   forward unchanged, because it is the whole reason this roadmap exists:
   the design document that came before this one was rejected specifically
   for asking an author to take care of the compiler rather than the other
   way around. Any proposal in this round that adds a new line to write, a
   new label to remember, or a setting whose only reader is a human filling
   it in correctly, is rejected on sight and said so out loud, even where it
   would technically work.

6. **The old declaration line retires — required, not optional.** Today,
   before any markup, an author has to write one long line spelling out
   facts about a word by hand — for `card`, ten separate declarations before
   a single line that actually renders anything. Retiring that line is
   required for this roadmap to succeed, not a nice-to-have.

   dan's preferred shape for what replaces it: name a parameter plainly for
   what it is, as in `def card, subject, content` — the parameter's own name
   carries the declaration, so there is nothing extra to write. The one real
   problem to solve, and it must be solved humanely, without handing the
   author new bookkeeping: a parameter named after one of the language's own
   structural words (like "subject" or "name") can collide with a real field
   the displayed record already has under that exact same word, leaving a
   reader unable to tell whether a bare reference means the slot the
   language just bound or the data the record already owns. Designing that
   solution is part of this roadmap's work and needs dan's ruling before the
   mechanical migration of all 23 hand-written words proceeds. This document
   does not presuppose the solution's shape — only that it must exist, must
   sit easily within the project's own ethos, and must not ask the author to
   declare anything extra to tell the two apart.

7. **Four open questions stay out of this roadmap's scope, unless dan
   chooses to pull one in:**
   - The word `link` currently has two different valid spellings for the
     same job, and at least one app uses both inside itself with nothing
     having settled which should survive.
   - The idea of a "variant" is currently doing two unrelated jobs under one
     name: sometimes an author is hand-picking a presentational style (a
     button marked "primary"), and sometimes a display form is chosen
     automatically from the data itself (a status badge turning red because
     the record's own status reads "danger"). These probably deserve two
     different names and mechanisms, but untangling them is its own piece of
     work.
   - Two small sentence-parsing fixes — one about how a bare name gets
     looked up, one about what is allowed inside a quoted interpolation —
     were argued for and marked "decided" in the design document rejected
     before this one, but because that whole document was rejected for other
     reasons, dan has not separately confirmed either survives on its own.
   - A convention already written down, where a word missing a value looks
     for it on whatever word contains it rather than making every level
     repeat itself. Once nearby-first containment becomes the formal rule for
     finding words, this convention's relationship to it deserves a fresh
     look — but that is a review for later, not an assumption this document
     makes now.

8. **Green, and looked at.** Every gate check and the full test suite pass
   at each point this roadmap is paused or finished, and dan has personally
   looked at the pages this work actually changes — the two editors above
   all, since that is the one thing he can see with his own eyes that this
   roadmap exists to fix.

**What drift looks like:** reviving the withdrawn parameter-naming collision
without a fresh, humane answer; a page's output changing without being shown
to dan and named; the old declaration line being deleted before the
lookup-and-containment mechanism is built and proven; a capability
demonstration dressed up after the fact rather than genuinely needing the
mechanism; an app quietly dropped or left to rot without being named; any of
the four open questions in criterion 7 folded in without dan saying so.

## How 0.5 arrived at this question

0.4 closed on 2026-10-11, asking whether the language's documented
conventions keep their promises. Its forward question — families — had
already been written once, as `DAYTRIP-0.4.0q.md`, and withdrawn from 0.4 on
dan's ruling that it was new design. Before 0.5 could be written, its
starting material had to be re-measured rather than trusted: the one real
collision the daytrip predicted (the two studio interfaces' "editor") was
confirmed still live and still the only one of its kind in the corpus; the
eleven words that are only supposed to live inside something else were
confirmed unchanged; and the gate and the full test suite were confirmed
green before any of this began.

The definition of success above went through several rounds of correction
from dan, each one recorded here so the reasoning isn't lost:

- An early draft treated the old declaration line's retirement as optional —
  acceptable to leave standing if nothing yet replaced the mechanism that was
  going to remove it. dan corrected this: retiring it is required, and he
  also corrected a misreading further upstream — he was never opposed to
  naming a parameter plainly for what it is; what he rejected was narrower,
  the specific collision between a structural kind-name and a record's own
  field under that same name.
- An early draft would have kept the example-app corpus frozen, rendering
  byte-for-byte as it does today, as proof that nothing broke. dan rejected
  this directly: the corpus was assembled haphazardly as the language grew
  and has no sacred cows, and freezing it in place would trade real
  improvement for mere consistency with its own accidents. Criterion 4 above
  is the replacement — rendering correctness and a named, shown reason for
  every change, instead of a frozen snapshot.
- A draft proposed tying the word-lookup mechanism to an existing principle
  in `CONVENTIONS.md` ("what is said nearest wins") as a formal
  reconciliation the guide itself should state. Tried out concretely, that
  connection didn't hold: the existing principle governs default behavior
  (what a convention decides when an author says nothing, like a number
  always formatting as money the same way everywhere), while which "editor"
  a word resolves to is a different kind of question entirely — two authors
  happening to choose the same name, not a convention changing its mind.
  The criterion was dropped rather than kept in a softer form. A later
  question from dan tested this from another angle — whether "the
  language's own words" are a privileged category at all, or just the
  outermost ring of one tree that any nearer word can shadow. He is right
  that they are not privileged; criterion 2 above now says so directly. That
  does not revive criterion 7: the mechanisms are still different code
  (nesting walked live during a render, versus a word resolved once at
  compile time), and the drop stands on that distinction alone, without
  leaning on any protected tier for either `money` or the language's other
  61 words.

## What this document is not

This is not a design document, and it is not a phase plan. It holds the
question and what success looks like. The step-by-step work — how the
lookup chain gets built, what replaces the old declaration line, which app
gets revisited — belongs to the daytrips that follow, the same way 0.4's
seventeen daytrips carried out a question this document only states.
