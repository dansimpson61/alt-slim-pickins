# alt-slim-pickins — roadmap 0.6

**An even-numbered roadmap. It leads with the backward eye.**

Status: **open.** Written 2026-10-12, drafted by the steward and confirmed by
dan. It is a roadmap and not a plan: it names the question and what success looks
like, leaving the step-by-step work to daytrips, the same way 0.4 and 0.5 did.

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
>
> *Walk like the chameleon: what lies ahead is watched, what lies behind is
> glanced back at.*

## The question

> **Does the language say what it means, and mean what it says? Can an author
> learn slim-pickins without tripping over compiler jargon, overloaded words,
> or historical sediment?**

It is a backward-eye question, which is what an even roadmap asks for (README,
*How roadmaps go*). It does not ask what new capability the language should
invent next. It asks whether what has been built across five roadmaps deserves to
stand as an honest, coherent craft work — studying the DSL, the documentation,
and the codebase beneath them as objects in their own right, to the standard of
excellent Ruby.

Five roadmaps built a remarkable system: a one-sentence grammar, 62 canonical
words, 23 partials written in the language itself, and lexical containment. But
along the way, terminology accumulated layers of development sediment
(`primitives`, `partials`, `defs`, `contracts`, `tin`, `spiff`), critical concepts
became overloaded across multiple roles (`variant`, `children`, `content`), the core
engine remained intertwined with development harnesses, and author-facing documents
retained the voice of compiler developers explaining compiler internals. 0.6 is
finished when the language, its taxonomy, and its teaching are unified and clean.

## The definition of success

1. **The polysemy and vocabulary taxonomy audit.** Key words in slim-pickins that
   carry multiple meanings across the language syntax, compiler internals, and
   documentation are identified, disentangled, and given distinct names:
   - **`variant` untangled:** The author-chosen presentational styling weight (a
     button marked `primary`, a note marked `quiet`) is conceptually and
     syntactically separated from data-driven status derived automatically from
     domain models (a badge turning red because a record's status reads `danger`).
   - **`children` untangled:** The block-yielding language word (`children`,
     analogous to Ruby's `yield` or a web component's `<slot>`) is distinguished
     from AST child node lists (`Node#children`), family parent/child class
     nesting (`Table::Column`), and DOM element descendants.
   - **`content`, `subject`, and `name` clarified:** Positional sentence parameter
     slots are clearly delineated from the active compiler evaluation receiver
     (`Builder#subject`) and domain record attributes (`account.name`).
   - **The vocabulary taxonomy formalized:** Crisp, unified definitions are
     established for `word`, `primitive`, `partial`, `def`, `contract`, `tin`,
     and `spiff`. No document, error message, or test uses two of these
     interchangeably or uses one to mean two different things.

2. **Pedagogy from first principles.** The documentation is rewritten from the
   author's viewpoint, not the compiler developer's:
   - Primary pedagogical guides ([PRIMER.md](PRIMER.md), [CONVENTIONS.md](CONVENTIONS.md),
     [VOCABULARY.md](VOCABULARY.md)) teach by showing authentic, idiomatic `.sp`:
     short, outline-like pages calling short, focused word `def`s.
   - Historical development narratives, compiler implementation details, and
     defensive justifications from past refactors are stripped out of
     author-facing materials and preserved where they belong (in `history/` and
     `LORE.md`).
   - An author reading the documentation can understand what to write and why it
     works without needing to know how the compiler parses sentences or how the
     registry was refactored.

3. **Clean gemification and architectural boundaries.** `lib/slim_pickins` is
   delineated as a clean, lean, standalone Ruby gem ready for distribution:
   - The core runtime and compiler are strictly decoupled from the repository's
     development harnesses (`check_*.rb`), the development studio (`studio/`), and
     example applications (`examples/`).
   - A host application can depend on `slim_pickins` as a gem without dragging in
     internal studio assets, custom test scripts, or development harnesses.
   - The boundaries between the engine, the canonical vocabulary, and application
     extensions are explicit and enforceable.

4. **Repository hygiene and example app audit.**
   - Historical daytrips (`DAYTRIP-*.md`) and planning scratch files that crowd the
     root directory are stowed into clean archive directories (`history/daytrips/`,
     `history/planning/`), keeping the working tree clean and legible.
   - The eight example applications are audited on their merits: dated applications
     built during early prototypes that no longer carry their weight or showcase
     current conventions ([way_exam](examples/way_exam), [word_graph](examples/word_graph))
     are formally evaluated with dan and either modernized or retired.
   - The remaining example garden reflects distinct aesthetic expressions and
     idiomatic practices, demonstrating the language's versatility.

5. **No author bookkeeping added.** This is carried forward from every prior
   roadmap: no disambiguation, taxonomy fix, or architectural cleanup makes the
   author do the compiler's job. Every fix leaves the author's sentences simpler,
   clearer, and more natural, never requiring new keywords, manual type annotations,
   or boilerplate declarations.

6. **Green, and looked at.** All twelve gate legs and the full test suite remain
   green at each milestone. Every page touched by modernization or refactoring is
   verified live, byte-compared, and shown to dan directly.

**What drift looks like:** inventing new language features before resolving
existing polysemy; rewriting documentation to add more compiler explanations
instead of author-facing clarity; creating complex class hierarchies where simple
Ruby data structures suffice; quietly deleting example apps without dan's ruling;
leaving historical daytrip churn in the root directory.

## How 0.6 arrived at this question

Roadmap 0.5 closed on 2026-10-12, having delivered families and real lexical
containment across seven daytrips (`DAYTRIP-0.5.0a` through `0.5.0g`). The editor
collision was eliminated, the single overwrite line deleted, child words safely
contained in Ruby namespaces and `list.sp`, and the legacy `expects` declaration
line retired across all partials.

During the retrospective intake for `WISHLIST.md` and the framing of the next phase,
dan identified a fundamental question of craft: key terms throughout the language
and its documentation are used in conflicting ways (`variant`, `children`), and the
project has accumulated historical jargon that obscures its essential simplicity.
Consulting `WISHLIST.md` confirmed this alongside several adjacent backward-looking
themes: clean gemification, repository cleanup, and pedagogy from first principles.

Because 0.6 is an even-numbered roadmap, its duty is the backward look: not
racing ahead to add speculative features, but pausing to ensure that what has been
built is honest, clear, and kind — in its code, in its structure, and in the words
it speaks to its authors.

## What this document is not

This document is not a design document, and it is not a phase plan. It holds the
question, the definition of success, and how 0.6 arrived here. The working order
belongs in `PROJECT.md`'s `next_step`. Step-by-step progress belongs in daytrips,
run one at a time and verified before moving to the next.
