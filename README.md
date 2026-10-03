# alt-slim-pickins

A view language whose grammar stays describable all the way down. It began as
paper — the first question was what we were building *on* — and it now runs:
one sentence, sixty-two words, its own stylesheet, and a studio plus a
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

- **[DESIGN.md](DESIGN.md)** — the grammar. One sentence, one resolution rule,
  no open questions.
- **[VOCABULARY.md](VOCABULARY.md)** — sixty-two words, seven slots each.
  slim-pickins owns the vocabulary of web presentation; the app's domain model
  arrives through conventions.
- **[ROADMAP-0.1.md](history/ROADMAP-0.1.md)** — closed, and kept as the record
  of what 0.1 set out to do and what it found.
- **[ROADMAP-0.2.md](ROADMAP-0.2.md)** — the even-numbered, backward-leading
  successor. Its phases begin with rewriting the Slim-Pickins Way and end with
  subtraction; see *How roadmaps go* below for what that shape means.
- **[CONTRACT.md](CONTRACT.md)** — what an app must promise to be renderable,
  which is one sentence plus two optional methods.
- **[HANDOFF.md](HANDOFF.md)** — the prompt that resumes this work in a fresh
  conversation.
- **`check_grammar.rb`**, **`check_styles.rb`** — keep every document
  accountable to the code and to each other. Every sentence must obey the
  grammar table; every word used must be defined; every word defined must have
  a sentence; every class emitted must have a rule.
- **`check_vitals.rb`**, **`check_ruby.rb`** — the two legs
  [DAYTRIP-0.4.0h.md](DAYTRIP-0.4.0h.md) added after measuring what the other
  ten could not see. The first holds every number the living prose and the
  `.rb` comments state about this project to `SlimPickins::Census`, and exempts
  the dated record with a written reason per entry. The second runs `ruby -w -c`
  over every Ruby file, because a mismatched indentation and an assignment
  nothing reads are warnings, and nothing was listening.
- **[docs/SPIFF.md](docs/SPIFF.md)** — Spiff, the design idiom: the
  spatial companion language a `.spiff` file is written in, and the lexicon of
  its words. `check_spiff.rb` holds every compiled-CSS example in it to
  the compiler, and `check_spiff_scope.rb` holds every zone it names to the
  pages that must render it — a selector matching nothing real is a defect,
  however short it is.

Two directories hold what is consulted rather than read:
[history/](history/README.md) is roadmap 0.1 — its eight phase records and the
three paper pages that were the vocabulary's evidence before there was code —
and [roth/](roth/README.md) is notes on a different project.

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
[ROADMAP-0.2.md](ROADMAP-0.2.md) is the protocol above, executed.

## Status

**Roadmaps 0.1, 0.2, and 0.3 are completed.**
- [ROADMAP-0.1.md](history/ROADMAP-0.1.md) proved the one-sentence grammar.
- [ROADMAP-0.2.md](ROADMAP-0.2.md) reshaped the Builder into semantic nodes and public words.
- [ROADMAP-0.3.md](ROADMAP-0.3.md) proved the vocabulary across a garden of four applications (`lore_reader`, `way_exam`, `milestone_planner`, `word_graph`), resolving the 26 demand gaps with 0 missing affordances.

**Roadmap 0.4 is underway as a sequence of daytrip victories** rather than a
phase plan — *the itinerary is a vector; daytrips give it volume*. Six volets
have landed, most recently [DAYTRIP-0.4.0g.md](DAYTRIP-0.4.0g.md) (the council
skill, the workbench spatial frontier, and three defects found by eye in the
live studio); there is no active thread, and `PROJECT.md`'s `next_step` names
what was deliberately left open.

Living vitals are computed directly from the repository tree by `SlimPickins::Census` (`ruby bin/census.rb`): 62 canonical words (39 Ruby primitives + 23 `.sp` partials), 7 apps, 24 app words, 31 verified pages, 38 conventions, 35 promises, and 104 style rules.

Run an app: `ruby examples/roth/app.rb` or `ruby examples/portfolio/app.rb` or `ruby examples/lore_reader/app.rb`.

The gate — twelve legs and the suite, run in the order `StudioStatus::LEGS`
names them, which is the one home for that list:

```sh
ruby check_grammar.rb && ruby check_shape.rb && ruby check_styles.rb &&
ruby check_spiff.rb && ruby check_spiff_scope.rb && ruby bin/check_promises.rb &&
ruby bin/check_conventions.rb && ruby bin/check_card.rb &&
ruby bin/verify_pages.rb && ruby check_vitals.rb && ruby check_ruby.rb &&
ruby bin/census.rb &&
ruby -Ilib:test -e 'require "slim_pickins/census"; SlimPickins::Census.test_files.sort.each { |f| require f }'
```

Green here means every claim these legs can read is true, every page the apps
can answer renders, and every test file the census can find passes. It does not
mean the pages *look* right: no leg renders to a browser, and the defects that
have actually cost this project sessions were all found by dan's eye and a live
measurement. That is the instrument for the visual layer, on purpose — a
headless browser is a dependency with opinions and a second corpus to keep.
