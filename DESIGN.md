# The grammar — v0.3

Status: **settled and implemented.** This was written as a wish, before any
code existed, so that every later extension could be reviewed against it. It
has not needed to change: the grammar below is the grammar the transform
implements, and the phases added sixty-four words without adding a rule.

Everything here is exercised — `check_grammar.rb` holds every sentence in this
document and every `.sp` file in the repo to the table in it.

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

```text
word names, content, modifiers:
  children
```

Every part is optional. The order never varies.

| Argument | Means | Example |
|---|---|---|
| `name` | a name — interpreted by the word to its left, never evaluated | `section products`, `button primary` |
| `"string"` | literal text | `note "Saved."` |
| `.property` | the current subject's data | `title .name` |
| `binding.property` | a local's or helper's data | `note order.number` |
| `key: value` | modifier | `badge .state, shape: .type` |
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

### Resolution — one rule

- `.foo` → the **innermost subject's** `foo`.

**There is always a subject.** The outermost one is the page itself, whose
attributes are the locals and helpers the app provides. So `.signed_in?` at
the top level asks the page, and `.balance` inside `each account` asks the
account, by the same rule rather than two.

A bare `foo` is a name and is never evaluated. The words that take a subject
— `section`, `table`, `each`, `form` — resolve the name against this same
chain, which is what makes a collection nested inside another mean the
obvious thing: inside `each account`, both `each holding` and `table
holdings` find *that account's* holdings rather than a page-level collection
of the same name.

The ambient outermost object is borrowed from VBA, where `Application` sits
implied at the top of every scope. It is never written, so it costs no syntax
and needs no word — it exists only to keep the chain from running out.

The cost, stated plainly: at the top level `.foo` has an invisible referent,
and a reader has to know the page is there. That is the price of not having a
second lookup rule, and it is paid once, in this paragraph. Unknown
attributes raise rather than resolving to nothing, so a typo fails loudly
instead of rendering blank.

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
sentence precisely because the vocabulary carries the meaning.

### A name is a subject; content is a label

Several words can either present something or merely head something. A
`section` may be *about the accounts*, or it may just be titled *"Where you
stand"*. The grammar already tells these apart, so nothing new is needed:

```
section accounts          # a name — the subject shifts to the accounts
section "Where you stand" # content — a heading, and nothing shifts
```

**Which job a word is doing is therefore visible in the page**, never decided
by what the data happens to hold. That distinction is load-bearing. An earlier
draft let `section` shift the subject *if* the subject happened to have that
attribute, and the cost was hidden: adding an `allocation` attribute to a
model would silently make `section allocation` start shifting, so every `.foo`
beneath it would resolve somewhere new, in a page nobody had edited.

So the rule is fixed per word and never runtime-dependent:

> **A word's name slot either takes a subject or it does not. When it does,
> the named thing must be there, and its absence fails on the line that named
> it.**

`page`, `section`, `form`, `table` and `each` take subjects. Words like
`button` and `badge` take variants instead, and words like `title` and `note`
take no name at all. Each entry in [VOCABULARY.md](VOCABULARY.md) says which.

### What governs the leading word

A name is governed by the word to its left — but the leading word has nothing
to its left. It is governed by **the word it is nested under**: `column` means
what it means inside `table`, `when` inside `choose`, `field` inside `form`.
A word at the top level is governed by the document.

So there is one rule of government, running along both axes of the tree:

> **A name is interpreted by the word to its left. A word is interpreted by
> the word it is nested under.**

Nothing is ever interpreted by anything further away than that. Both governors
are visible without scrolling — one on the same line, one on the line above —
so a reader never carries state to parse a sentence.

The practical rule for reading an unfamiliar sentence: **the enclosing word
tells you how to read the leading word, and the leading word tells you how to
read the rest of the line.**

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
          text .sku
          title .name
          money .price
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
    checkbox newsletter, "Send me updates"
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
      card compact
        text .description
        money .amount
        note order.number
```

Inside the inner loop, `.amount` is the line item's and `order.number` is the
order's. Two scopes, no new syntax.

### 5. Branching — the escape hatch

```
choose
  when .signed_in?
    link account, "Your account"
  otherwise
    link sign_in, "Sign in"
```

`when` and `otherwise` are ordinary words that are valid inside `choose`.
`else` is never a bare keyword, so nothing needs special parsing. Most
branching should not reach for this — prefer `empty`, or the `if:` modifier.

`.signed_in?` asks the page, which is the outermost subject. Nothing here is
a special case: the same dot that reads an account's balance reads the page's
session.

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
      money .total, if: .paid?

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

## What the open questions turned out to be

- **The vocabulary itself.** The estimate was "roughly forty". It settled at
  **sixty-four**, across the phases, and every entry was drafted against a real
  page — `chart` last and most reluctantly, in Phase 8. The bet held: the
  grammar never changed to accommodate a word.
- **`doctype`.** Solved by absorption rather than by a keyword: it is something
  `page` knows. See its entry in [VOCABULARY.md](VOCABULARY.md).
- **Backend.** Settled as drafted. The transform is thin — indentation to
  blocks, `.foo` to `subject.foo`, every line a Ruby method call — and Temple
  was never needed. `Builder` escapes and generates directly, and every word is
  a real method, so an unknown word fails with its own name.

### And one rule nobody had written down

**There is no numeric literal.** Content is a quoted string or a dotted value;
a bare number is neither, so `level 1000000.0` is not a sentence. It was found
in Phase 8 by trying to write one, and the checker refused it before any code
did. A figure in a page has nowhere to stand — it belongs to the app, which is
the same division of labour as everywhere else: the word carries the
presentation, the argument carries the domain.
