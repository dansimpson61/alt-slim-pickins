# A content-heavy page — the vocabulary's second test

Modelled on `dashboard/views/pattern.slim`: a rendered-markdown body, a
sidebar, structured list items, breadcrumbs, and a copy-paste box. The
portfolio page tested money, tables and forms. This one tests the quarter of
the vocabulary that page could not reach.

Six walls were hit, which is twice the portfolio's count. That is the expected
shape — draft 1 was written against a dashboard, so its blind spot was
exactly here.

## The page

```
page pattern, .title
  stylesheet "/css/library.css"

  nav breadcrumb
    link library, "Library"
    link home, "Studio"

  badge .category
  badge .status

  fact origin, .origin_project
  fact source, .origin_file

  section specification, "Conceptual specification and thinking"
    prose .content

  aside
    section applied, "Applied in projects"
      empty "No other projects declare this pattern yet."
      list plain
        each project
          item
            link show, .path
            note quiet, .purpose

    section lore, "Agent lore snippet"
      note quiet, "Feed this to any agent before beginning development."
      snippet .lore

  footer "Patterns are recombinant. Origin is provenance, not ownership."
```

Twenty-three sentences against forty-nine lines of `pattern.slim`.

## The six walls

### 1. No word for rendered prose

`pattern.slim` line 29 is `== MarkdownRenderer.render(@content)` — a whole
document rendered into the page, using Slim's unescaped-output sigil because
the content is trusted HTML.

This is the centre of a content-heavy page and the vocabulary had nothing for
it. **Added `prose`.** It also disposes of escaping as a language feature:
`prose` is the one word that renders markup, it sanitises rather than trusts,
and there is no `==` because there is no sigil for "trust me."

### 2. No word for badges

`ui_badge` is called nine times across those two views. **Added `badge`.**

### 3. No word for a labelled fact

`Origin: roth / controls.slim` is a label and a value, inline and small.
`metric` is the same information as a stat tile, which is the wrong size.
**Added `fact`.** Two words for one *kind of information* is correct here
and not an alias, because the word carries the presentation and these are two
presentations.

### 4. No inline composition — and it stays that way

`pattern.slim` writes `| Origin: ` then a link on the next line, composing a
sentence out of a text fragment and an anchor. The grammar cannot do this: one
line is one node, and there is no way to say *text, then a link, then more
text*.

**Deliberately not fixed.** Inline composition is what prose is for, and
prose is `prose`. Adding an inline-fragment construct would put a second
composition mechanism next to indentation, which is the mistake this whole
language was designed to avoid — it is Slim's `:` all over again. The
labelled-fact case that motivated it is `fact`, and richer inline text is
markdown's job.

This is the first wall answered with "no" rather than a word, and the
reasoning is the load-bearing part.

### 5. `list` was wrong about its children

The entry said each child becomes an item. That breaks the moment an item has
structure — here every item is a link *and* a description, which would have
become two items.

**Corrected: `list` governs `item`, and `item` holds whatever it likes.** The
inference was cute and false. Worth noting it survived the portfolio page only
because `list` never appeared there.

### 6. No way to say "sidebar"

`pattern.slim` does it with `.sp-grid--3` and `grid-column: span 2` — a
three-column grid where the body spans two. That is CSS arithmetic standing in
for an intention.

**Added `aside`.** Everything not in an `aside` is the main column, which is
what `<aside>` already means in HTML, so no `main` word is needed.

Also added **`snippet`** for the readonly copy-paste box, which `pattern.slim`
builds from a `textarea` with four inline styles and a `readonly` attribute.

## What the model showed that the page does not

`library.slim` is ninety-five lines, of which three blocks of exactly
twenty-seven lines are identical except for which category they iterate. In
this language that is one block under `each category`, because the categories
are data. The repetition is not a failing of Slim — it is what happens when a
view has no word for "the same thing, per category," and it is the clearest
argument for the vocabulary that this session has produced.

## Still standing

- **`image` and `icon` are still untested.** The dashboard has no images. This
  is a true fact about the model rather than a failure of the exercise, and it
  means the media quarter of the vocabulary has now survived two pages without
  ever being exercised. A page with figures — a gallery, an illustrated doc —
  is the honest next test, and it is the last obviously-missing kind.
- **The `?` case.** Never reached again. Both real pages phrased every
  condition against the subject, so it has now gone unhit twice.
- **`chart` remains a guess.** Content pages do not chart.
