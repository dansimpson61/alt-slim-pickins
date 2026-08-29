# alt-slim-pickins

An exploration of a view DSL whose grammar stays describable all the way
down. There is no code yet, and that is deliberate — the first question is
what we are building *on*.

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

## The open question

Two paths, and picking one is the next step:

- **On top of Slim** — keep the parser, constrain the surface. Cheap, proven,
  and inherits all four seams wherever a user reaches past the constraint.
- **Independent** — own the grammar, keep the skeleton, redesign the tag
  line. Expensive, and the payoff is that the one-sentence description stays
  true at every level.

Nothing here is decided.
