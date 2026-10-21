# alt-slim-pickins

A view language whose grammar stays describable all the way down. It began as
paper — the first question was what we were building *on* — and it now runs:
one sentence, sixty-three words, its own stylesheet, and a studio plus a
garden of demonstration apps that speak it (vitals reported live by `ruby bin/census.rb`).

`slim-pickins` is a helper vocabulary layered on Slim. This is the other
experiment: what a view language looks like if the grammar itself is the
thing being designed.

## The premise

Slim's skeleton is one of the cleanest ideas in templating, and it fits in a
sentence:

> A line is indentation, one leader that classifies the line, then the rest;
> anything indented under a line is its children.

The leaders are a closed set — nothing (tag), `.`/`#` (div shortcut), `=`
(output Ruby), `-` (run Ruby), `|`/`'` (text), `/` (comment), `<` (raw HTML).
Indentation carries Ruby's block structure and HTML's tree structure at once,
so there are no `end`s and no closing tags:

```slim
- items.each do |item|
  .card
    h2 = item.upcase
    p
      | text
```

That rule holds everywhere. The irregularity is all in the **tag line**,
where a second grammar takes over that does not follow the same rules.

## The four seams

Verified against Slim 5.2.1, not recalled from memory.

**1. Attribute values are undelimited Ruby that terminates at whitespace.**
This is the worst one, because it fails silently rather than loudly:

```slim
a href=1+2      →  <a href="3"></a>
a href=1 + 2    →  <a href="1">+ 2</a>
```

One space apart. The second is not an error — `1` becomes the value and
`+ 2` becomes the tag's text content. Any expression containing a space needs
`("…")` or `[…]` wrapping, and nothing warns you.

**2. `:` is a second nesting mechanism, competing with indentation** — and it
collides with the embedded-engine syntax:

```slim
li: a href="/" Home   →  <li><a href="/">Home</a></li>
li:
  a Home              →  SyntaxError: Expected tag
```

So `name:` means "inline child" or "switch languages" depending on whether
the name is a registered engine (`ruby:`, `javascript:`, `markdown:`) and on
what follows it.

**3. Whitespace control is a suffix sublanguage** on the leader: `p<`, `p>`,
`p<>`, stacking onto `=` as well (`=<`, `==<>`). Roughly six spellings of one
leader.

**4. Escaping is encoded by doubling.** `=` escapes, `==` does not. Doubling
a character to mean "and trust me" is memorised, not derived.

## Where it went

The question was settled by answering it differently. Constraining Slim's tag
line turned out to be the wrong frame: once we stopped defending inherited
syntax, every sigil we were carrying — `=`, `-`, `|`, required parens — proved
to exist only to disambiguate Ruby we had left undelimited. Remove that and
the whole punctuation layer evaporates.

What is left is one sentence:

> **`word arguments`. Indentation nests it. Everything — elements, components,
> control flow, text — is a word. Extending the language adds vocabulary,
> never syntax.**

```
section holdings
  empty "No holdings yet."
  each holding
    card
      title .name
      money .market_value
```

A dot means data; a bare word is language. The word carries the presentation
and the argument carries the domain, so `money .market_value` means *present
this as money* and the formatting belongs to the word.

## The documents

The author-facing guides live in `docs/`; the working documents — the roadmap,
the handoff — live at the root.

- **[PRIMER.md](docs/PRIMER.md)** — The Way. The comprehensive tour of the language:
  the three canvases (`.frame`, `.sp`, `.layout`), the one-sentence grammar, the
  universal slot model, composed words, and the five vocabulary categories.
- **[CONVENTIONS.md](docs/CONVENTIONS.md)** — what the language decides when you say nothing:
  principles, defaults, and overrides.
- **[VOCABULARY.md](docs/VOCABULARY.md)** — sixty-three words, seven slots each.
  slim-pickins owns the vocabulary of web presentation; the app's domain model
  arrives through conventions.
- **[DESIGN.md](docs/DESIGN.md)** — the grammar. One sentence, one resolution rule,
  no open questions.
- **[CONTRACT.md](docs/CONTRACT.md)** — what an app must promise to be renderable,
  which is one sentence plus two optional methods.
- **[LAYOUT.md](docs/LAYOUT.md)** — the `.layout` spatial companion: the postures,
  zones, and rhythm a page's presentation is written in.
- **[ONTOLOGY.md](docs/ONTOLOGY.md)** — the Tri-Plane ontology a steward holds: the
  linguistic, spatial, and mechanical planes.
- **[STRETCH_PROTOCOL.md](docs/STRETCH_PROTOCOL.md)** — the Stretch Exam: how an odd
  roadmap opens on paper, and what closes it.
- **[ROADMAP-0.8.md](ROADMAP-0.8.md)** — the active even-numbered roadmap (closed
  roadmaps are preserved in `history/planning/`).
- **[HANDOFF.md](HANDOFF.md)** — the prompt that resumes this work in a fresh
  conversation.
- **`checkers/check_grammar.rb`**, **`checkers/check_styles.rb`** — keep every document
  accountable to the code and to each other. Every sentence must obey the
  grammar table; every word used must be defined; every word defined must have
  a sentence; every class emitted must have a rule.
- **`checkers/check_vitals.rb`**, **`checkers/check_ruby.rb`** — the two legs that
  hold the prose to the census and Ruby to the interpreter's warnings. The first
  holds every number the living prose and the `.rb` comments state about this
  project to `SlimPickins::Census`, and exempts the dated record with a written
  reason per entry. The second runs `ruby -w -c` over every Ruby file, because
  a mismatched indentation and an assignment nothing reads are warnings, and
  nothing was listening.
- **`checkers/check_layout.rb`**, **`checkers/check_layout_scope.rb`** — hold every
  compiled-`.layout` example to the compiler, and every zone it names to the
  pages that must render it — a selector matching nothing real is a defect,
  however short it is.

Two directories hold what is consulted rather than read:
[history/](history/README.md) is the kept record — roadmap 0.1's eight phase
records, the three paper pages that were the vocabulary's evidence before there
was code, and [CHRONICLE.md](history/CHRONICLE.md), the round-by-round account
that `PROJECT.md` used to carry in its frontmatter — and
[roth/](roth/README.md) is notes on a different project.

## How roadmaps go

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
>
> *Walk like the chameleon: what lies ahead is watched, what lies behind is
> glanced back at.*

The chameleon's eyes move independently, so it does both at once. It does not
take turns, and neither does this project. **Both eyes stay open; the roadmap's
number says which one leads.**

An **odd** roadmap leads with the forward eye. It asks something the project
cannot yet answer and spends itself finding out — 0.1 asked whether a view
language could keep one sentence all the way down, and answered it: yes, across
two apps, with no grammar changes. It still re-reads the history and the lore
**before** it chooses a direction.

An **even** roadmap leads with the backward eye. It asks whether what was built
deserves to stand. Three movements:

1. **Look back at the progress made** — what was claimed, what was measured,
   and which of the two the documents actually record.
2. **Read the history and the lore.** [history/](history/README.md) and
   [LORE.md](LORE.md) are eight phases of findings that were written down and
   then rarely re-read.
3. **Study the DSL and the code beneath it as objects in their own right**, to
   the standard of excellent Ruby — not as a means to the next feature.

**The Stretch Exam.** An odd roadmap does not invent examples to flatter the words we already have; it opens with a **Stretch Exam** ([docs/STRETCH_PROTOCOL.md](docs/STRETCH_PROTOCOL.md)). We draft a compelling reference application—or the next authentic tier of one—on paper first, in the cleanest `.sp`, `.frame`, and `.layout` we can imagine, before the language can run it. Where the paper page hits a wall (a grammar refusal, a compiler leak, a missing micro-layout, or a visual ceiling), those walls become the odd roadmap's daytrips. When the paper page renders live and looks exceptional without app-space workarounds, the odd roadmap closes—and the even roadmap that follows harvests the lessons and retires whatever older demo the new benchmark just made obsolete.

It still has to know where the project is going, or the study is decoration.
The constraint is not *build nothing*; it is **build nothing the backward look
did not ask for.**

Both halves are earned. 0.1 ran eight phases with both eyes forward, and a
single afternoon of looking back found four copies of one mechanism, two guards
that fire at the wrong moment, and two words that are the wrong part of speech —
none of it reachable by building the next thing. The opposite failure is just as
cheap to fall into: a runtime reshaped without knowing what it must next carry
is a beautifully organised runtime for the wrong language.

**0.2 is the first even-numbered roadmap**, and it is written —
[ROADMAP-0.2.md](history/planning/ROADMAP-0.2.md) is the protocol above, executed.

## Status

**Roadmaps 0.1 to 0.7 are completed.**
- [ROADMAP-0.1.md](history/ROADMAP-0.1.md) proved the one-sentence grammar.
- [ROADMAP-0.2.md](history/planning/ROADMAP-0.2.md) reshaped the Builder into semantic nodes and public words.
- [ROADMAP-0.3.md](history/planning/ROADMAP-0.3.md) proved the vocabulary across a garden of four applications (`lore_reader`, `way_exam`, `milestone_planner`, `word_graph`), resolving the 26 demand gaps with 0 missing affordances.
- [ROADMAP-0.4.md](history/planning/ROADMAP-0.4.md) asked whether the conventions keep their promises, so that an author only has to name things. Every documented override is proved by a test, and the weak-spots table in [CONVENTIONS.md](docs/CONVENTIONS.md) is empty. It ran first as seventeen daytrips (`DAYTRIP-0.4.0a` to `0.4.0q`), and the roadmap tells how its question emerged from them. It closed on 2026-10-11.
- [ROADMAP-0.5.md](history/planning/ROADMAP-0.5.md) answered whether words can nest in namespaces and files rather than a single global registry: nearest-first compiler walk, editor collision eliminated, the eleven contained words scoped lexically in Ruby and `list.sp`, the legacy declaration line retired across all composed words, and language words open to app shadowing. It ran as seven daytrips (`DAYTRIP-0.5.0a` to `0.5.0g`) and closed on 2026-10-12.
- [ROADMAP-0.6.md](history/planning/ROADMAP-0.6.md) asked whether the language says what it means and means what it says: the polysemy audit, pedagogy from first principles, clean gemification, and repository hygiene. It ran as eleven daytrips (`DAYTRIP-0.6.0a` to `0.6.0k`) and closed on 2026-10-16.
- [ROADMAP-0.7.md](history/planning/ROADMAP-0.7.md) asked whether the language can carry a publication-grade reader with zero `tag` escapes, bespoke CSS, or domain contortions. It healed four walls (`page` dissolved, self-titling documents, `cluster`, sayable theme roles), assembled the unified `publication` reader, and retired `lore_reader`. It ran as six daytrips (`DAYTRIP-0.7.0a` to `0.7.0f`), passed the Editorial Prose sign-off, and closed on 2026-10-19.

**Roadmap 0.8 is completed ([ROADMAP-0.8.md](history/planning/ROADMAP-0.8.md)).** It led with the backward eye: the harvest. It healed metric and fact, introduced the KeyValue runtime spine, audited all 63 words and kept apps, retired redundant prototypes, and leveled form containment for CRUD.

**Roadmap 0.9 is completed ([ROADMAP-0.9.md](ROADMAP-0.9.md)).** It led with the forward eye: the Authentic CRUD & State-Mutation Stretch Exam in `examples/portfolio`. It elevated portfolio into a living SQLite-backed Wealth Management & Asset Allocation workbench exercising full relational CRUD, method override, server validation diagnostics with 422 re-rendering, flash lifecycle, and spatial `.layout` & `.style` companions. It ran as six daytrips (`DAYTRIP-0.9.0a` to `0.9.0f`) and closed on 2026-10-21.

Living vitals are computed directly from the repository tree by `SlimPickins::Census` (`ruby bin/census.rb`): 63 canonical words (37 Ruby primitives + 26 `.sp` composed words), 5 apps, 26 app words, 33 verified pages, 39 conventions, 34 promises, and 115 style rules.

Run an app: `ruby examples/roth/app.rb` or `ruby examples/portfolio/app.rb` or `ruby examples/publication/app.rb`.

The gate — twelve legs and the suite, run in the order `StudioStatus::LEGS`
names them, which is the one home for that list:

```sh
ruby checkers/check_grammar.rb && ruby checkers/check_shape.rb && ruby checkers/check_styles.rb &&
ruby checkers/check_layout.rb && ruby checkers/check_layout_scope.rb && ruby bin/check_promises.rb &&
ruby bin/check_conventions.rb && ruby bin/check_card.rb &&
ruby bin/verify_pages.rb && ruby checkers/check_vitals.rb && ruby checkers/check_ruby.rb &&
ruby -Ilib:test -e 'require "slim_pickins/census"; SlimPickins::Census.test_files.sort.each { |f| require f }'
```

Green here means every claim these legs can read is true, every page the apps
can answer renders, and every test file the census can find passes. It does not
mean the pages *look* right: no leg renders to a browser, and the defects that
have actually cost this project sessions were all found by dan's eye and a live
measurement. That is the instrument for the visual layer, on purpose — a
headless browser is a dependency with opinions and a second corpus to keep.
