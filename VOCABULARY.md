# Vocabulary — the spec for drafting it

Status: **spec only.** Four entries are worked below to prove the format.
The rest of the words are not written yet.

The grammar is settled and is one sentence ([DESIGN.md](DESIGN.md)). It cannot
really be wrong any more. The vocabulary *can* be incomplete, and in a language
where words are the only construct, every gap is a wall. So the vocabulary is
the risk, and this is the discipline for writing it.

## What an entry must declare

The rule of government from DESIGN.md runs along both axes of the tree:

> A name is interpreted by the word to its left. A word is interpreted by the
> word it is nested under.

So every word needs **two** definitions, not one — what it governs in its
arguments, and what it governs in its children. Seven slots, each answered or
explicitly `none`:

| Slot | Answers |
|---|---|
| **name** | what a bare name means to this word — *one* job, not a disjunction |
| **content** | what a `"string"` or `.data` argument means |
| **modifiers** | which `key:` options are accepted |
| **children** | which words are valid inside, and what this word means by them |
| **subject** | what the subject is inside this word, if it changes |
| **infers** | what it works out when not told, and how to override |
| **renders** | the HTML |

## Rules for entries

1. **No blank slots.** An unanswered slot is a gap in the language, not a
   default. Write `none`.
2. **A name slot names one job** — the subject, a variant, a destination, an
   attribute. If it takes two, the word is doing two things and wants
   splitting. ("What it is about, or which kind" was this mistake in the
   grammar itself.)
3. **Every inference is overridable by saying the thing**, and the entry says
   how. A convention you cannot override is a trap.
4. **No word accepts the same information two ways.** Not as a name and a
   modifier, not as a child and a modifier. This is the alias problem, and it
   is what makes grammars rot.
5. **A word governs only its own children.** No word reaches past its parent
   or into a grandchild.
6. **Every word appears in at least one sentence that passes
   `check_grammar.rb`.** An entry with no exemplary sentence is untested.

## Worked entries

### `section`

| Slot | |
|---|---|
| **name** | the subject — the collection or record this section presents |
| **content** | the heading text |
| **modifiers** | `if:` |
| **children** | any presentation word; `empty` is governed here |
| **subject** | the named thing |
| **infers** | the heading from the name (`products` → "Products"); the class from the name. Override the heading by giving content |
| **renders** | `<section class="products"><h2>…</h2>…</section>` |

```
section products
section products, "Merchandise"
```

### `each`

| Slot | |
|---|---|
| **name** | the singular of the collection to iterate; also binds that name |
| **content** | none |
| **modifiers** | `from:` — an explicit collection when pluralising is wrong |
| **children** | repeated once per element |
| **subject** | each element in turn |
| **infers** | the collection by pluralising the name (`product` → `products`). Override with `from:` |
| **renders** | nothing of its own; the children repeat |

```
each product
each product, from: .featured
```

### `column`

Governed by `table`. Demonstrates a word whose meaning comes from its parent,
and which renders in two places.

| Slot | |
|---|---|
| **name** | the attribute of each row to show |
| **content** | the header text |
| **modifiers** | `if:` |
| **children** | none |
| **subject** | unchanged — `table` supplies each row in turn |
| **infers** | the header from the name (`due_on` → "Due on"); each cell's value from that attribute of the row. Override the header by giving content |
| **renders** | one `<th>` in the head, and one `<td>` per row |

```
column name
column due_on, "Due"
```

### `button`

| Slot | |
|---|---|
| **name** | the variant |
| **content** | the label |
| **modifiers** | `to:`, `type:`, `if:` |
| **children** | none |
| **subject** | unchanged |
| **infers** | `type="submit"` when inside a `form`. Override with `type:` |
| **renders** | `<button class="button button--primary">…</button>` |

```
button primary, "Save"
button primary, "Add to cart", if: .in_stock?
```

## The shape of the vocabulary

Five groups. The counts are estimates and the point of drafting is to find out
where they are wrong.

| Group | Words |
|---|---|
| **Document** | `page`, `layout`, `head`, `meta` |
| **Structure** | `section`, `group`, `grid`, `list`, `table`, `column`, `card`, `actions` |
| **Content** | `heading`, `title`, `text`, `note`, `price`, `time`, `image`, `icon` |
| **Interaction** | `link`, `button`, `form`, `field`, `check`, `select`, `option` |
| **Situation** | `each`, `empty`, `choose`, `when`, `otherwise` |

Roughly thirty named so far against an estimate of forty, which is the first
thing the drafting will test.

## What drafting will surface

These are predictions, recorded now so they can be checked later rather than
rationalised.

- **Words that are really one word with a variant.** `heading` and `title`
  probably collapse. So might `grid` and `list`.
- **The `?` case.** `when signed_in?` — a helper used as a value with no dot
  to mark it as data. Still open in DESIGN.md, and `choose` is where it bites.
- **`doctype`.** Still fits no rule. `page` may absorb it, which would be the
  cheapest honest answer.
- **Where inference gets its knowledge.** `field name` deriving a label, an
  input name and a value from one word assumes something about the subject's
  shape. `section products` inferring a heading assumes a humanising rule.
  These are conventions the *app* must satisfy, and the vocabulary is where
  that contract becomes visible.
