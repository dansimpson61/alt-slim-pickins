# alt-slim-pickins

A view language whose grammar stays describable all the way down. It began as
paper — the first question was what we were building *on* — and it now runs:
one sentence, fifty words, its own stylesheet, and two Sinatra apps that
speak it.

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
- **[VOCABULARY.md](VOCABULARY.md)** — fifty words, seven slots each.
  slim-pickins owns the vocabulary of web presentation; the app's domain model
  arrives through conventions.
- **[ROADMAP-0.2.md](ROADMAP-0.2.md)** — the live roadmap: the question, the
  proscription, the risk register. Start here to know what happens next.
  [ROADMAP-0.1.md](ROADMAP-0.1.md) is closed, and kept as the record of what
  0.1 set out to do and what it found.
- **[PORTFOLIO.md](PORTFOLIO.md)**, **[CONTENT.md](CONTENT.md)**,
  **[FIGURES.md](FIGURES.md)** — three real pages written in the language,
  each modelled on a view that already exists in this workspace. They are the
  tests: wall counts across them went 3, 6, 1.
- **`check_grammar.rb`** — keeps every document accountable to the others.
  Every sentence must obey the grammar table; every word used must be defined;
  every word defined must have a sentence.

## Status

**Roadmap 0.1 is finished** — all eight phases, closed in
[ROADMAP-0.1.md](ROADMAP-0.1.md). [ROADMAP-0.2.md](ROADMAP-0.2.md) is the live
one, argued for in [BLUESKY-0.2.md](BLUESKY-0.2.md).

The bet the paper could not settle was **inference** — whether `field
base_income` can really derive a label, an input name, a value and an input
type from one word. Phase 0 measured it and it holds: on roth's form of
fourteen labelled controls, humanising alone got eleven labels right, and with
`label_for` on the app the page states none of them.

Phases 7 and 8 ported a real app — `~/dev/roth` — including its results, which
render on the server. Its 88-line page and 249-line script became 71 sentences
and 25 lines, and it uses **no Ruby-defined words at all**. Across every `.sp`
file here the escape hatch stands at **1 use in 356 sentences**.

- [PHASE7.md](PHASE7.md) — the port, and its architecture
- [PHASE8.md](PHASE8.md) — `chart`, redrafted as the same shape as `table`
- [ROTH_STUDY.md](ROTH_STUDY.md) — what reading a real app closely found

Run one: `ruby examples/roth/app.rb` or `ruby examples/portfolio/app.rb`.
Everything green: `ruby check_grammar.rb && ruby check_styles.rb &&
for f in test/*_test.rb; do ruby $f; done`
