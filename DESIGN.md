# Draft grammar — v0.2

Status: **draft.** Nothing is implemented. This document is the wish and the
grammar it implies, written down so that every later extension can be reviewed
against it.

## The idea

> **One sentence: `word arguments`. Indentation nests it. Everything —
> elements, components, control flow, text — is a word. Extending the
> language adds vocabulary, never syntax.**

slim-pickins owns the vocabulary of web presentation. Each app's domain model
arrives through conventions rather than being wired up by hand, and reaches
the page through **locals and helpers**.

The division of labour that makes this work: **the word carries the
presentation, the argument carries the domain.** `price .price` means
*present the subject's price as a price* — the currency formatting is the
word's business, not the template's.

## The sentence

```
word names, content, modifiers:
  children
```

Every part is optional. The order never varies.

| Argument | Means | Example |
|---|---|---|
| `word` | a name — interpreted by the word to its left, never evaluated | `section products`, `button primary` |
| `"string"` | literal text | `note "Saved."` |
| `.property` | the current subject's data | `title .name` |
| `binding.property` | a local's or helper's data | `note order.number` |
| `key: value` | modifier | `image .url, alt: .name` |
| *indented block* | children | |

### Morphology: a dot means data, a bare word is language

This is the rule that makes the grammar guessable without a phrasebook.

```
section products      # no dot — a name the language interprets
button primary        # no dot — a name
title .name           # dot — the subject's data
note order.number     # dot — a binding's data
```

Every value carries a dot. Every word that is not a value does not. One
visual cue, one job. Note that names are not decorated — `each product` and
`section products` look alike because they *are* alike: both name a domain
thing and let the language work out what to do with it.

The only colon in the language is the trailing one in a modifier (`alt:`),
and it never appears at the head of a word, so the two can never be confused.

### Resolution — two lookups, one rule each

- `.foo` → the **innermost subject's** `foo`.
- `foo` → a **local**, else a **helper**.

### The subject

- `each product` iterates `products`, binds `product`, and makes each element
  the subject.
- `section products` makes `products` the subject.
- `.foo` always means the innermost subject.

Because `each product` also binds the name `product`, an inner loop reaches
back out by name. The escape hatch is already in the grammar; it needs no
syntax of its own.

### What a name means is the word's business

The grammar says only one thing about a bare word: **it is a name, so it is
never evaluated.** That is the whole grammatical rule, and it is the exact
complement of the dot — a dot fetches data, a bare word does not.

What the name is *for* belongs to the vocabulary, and differs by word:

```
section products    # the subject — what this section presents
button primary      # the variant — which kind of button
link show           # the destination — where this link goes
field email         # the attribute — which property of the subject
```

This delegation is the design bet, not a gap in it: the grammar stays one
sentence precisely because the vocabulary carries the meaning. It costs a
reader nothing, because the meaning is always fixed by the word immediately
to the left — visible on the same line, never state carried from earlier.

The practical rule for reading an unfamiliar sentence: **the leading word
tells you how to read the rest of it.**

### Conventions carry the common case

A name is expected to supply what can be inferred. The heading of
`section products` is conventional; content overrides it:

```
section products                  # heading: "Products"
section products, "Merchandise"   # heading: "Merchandise"
```

This is the shape of every convention in the language: **the common case
costs zero words, and every convention is overridable by saying the thing.**

The corollary is that a line which states the inferable should not exist.
A `card` whose subject is a product already knows the product has an id, so
`id .id` is the template doing the machine's job.

## Wishes

### 1. An index — the core characteristics

```
page products
  section products
    empty "Nothing here yet."

    grid cards
      each product
        card
          image .image_url, alt: .name
          title .name
          price .price
          actions
            link show, "View"
            button primary, "Add to cart", if: .in_stock?
```

Note `empty`. It is not `if products.empty?` — it is a word meaning *what
this section says when it has nothing*. **Conditionals dissolve into
vocabulary:** do not write the branch, name the situation.

### 2. A form — conventions doing the work

```
page account
  form account
    field name
    field email, type: email
    field bio, long
    check newsletter, "Send me updates"
    actions
      button primary, "Save"
      link cancel, "Never mind"
```

`field name` derives its label ("Name"), its input name, and its value from
`.name` — three inferences from one word. `long` is a name, so it means what
a `field` decides it means: a textarea.

### 3. A table — floating above the interpreter

```
table products
  column name
  column price
  column stock, "In stock"
```

No `each`, no `row`, no `cell`. A table declares its columns; the rows come
from the subject. The loop is not written because it was never the point.

### 4. Nesting — reaching out by name

```
each order
  card
    title .number
    each line_item
      line
        text .description
        price .amount
        note order.number
```

Inside the inner loop, `.amount` is the line item's and `order.number` is the
order's. Two scopes, no new syntax.

### 5. Branching — the escape hatch

```
choose
  when signed_in?
    link account, "Your account"
  otherwise
    link sign_in, "Sign in"
```

`when` and `otherwise` are ordinary words that are valid inside `choose`.
`else` is never a bare keyword, so nothing needs special parsing. Most
branching should not reach for this — prefer `empty`, or the `if:` modifier.

`signed_in?` is the unresolved case described under Open questions: a helper
used as a value, with no dot to mark it as data.

## Guessability proof

The acceptance test for the language: sentences derived from the grammar
table alone, appearing in none of the wishes above. A fluent speaker should
be able to write these having only read the table.

```
section orders, "Recent orders"
  empty "No orders yet."
  each order
    card compact
      title .number
      price .total, if: .paid?

table invoices
  column number
  column due_on, "Due"

form password
  field current, type: password
  field replacement, long, type: password
  actions
    button primary, "Change it"
```

If a sentence here needs the implementation to explain it, the grammar has an
irregularity and the grammar is what gets fixed.

## Open questions

- **A bare local used as a value.** The dot rule does not close. `greeting
  current_user` reads as the *name* `current_user`, not its value; dotted
  paths (`current_user.name`) are fine, and so are subject properties, but a
  bare binding passed as data has nowhere to live. It shows up in wish 5 as
  `when signed_in?`. Either locals are always reached through a dot, or `?`
  earns a meaning of its own — undecided, and deliberately not papered over.
- **The vocabulary itself.** The grammar is one sentence and cannot really be
  wrong now; the vocabulary can be *incomplete*, and in a language where words
  are the only construct, every gap is a wall. Enumerating the words of web
  presentation is the next real work. First estimate is roughly forty.
- **`doctype`.** One keyword that fits no rule. Unsolved rather than faked.
- **Backend.** `.foo` is not valid Ruby, so we own the grammar — this is not
  Slim with a different tag line. The transform stays thin (indentation to
  blocks, `.foo` to `subject.foo`, every line a Ruby method call). Whether we
  keep Temple for escaping and generation is a separate and later question.
