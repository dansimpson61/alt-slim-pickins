# Draft grammar — v0

Status: **first draft.** Nothing is implemented. This document is the wish
and the grammar it implies, written down so that every later extension can be
reviewed against it.

## The idea

> **One sentence: `word arguments`. Indentation nests it. Everything —
> elements, components, control flow, text — is a word. Extending the
> language adds vocabulary, never syntax.**

slim-pickins owns the vocabulary of web presentation. Each app's domain model
arrives through conventions rather than being wired up by hand.

The division of labour that makes this work: **the word carries the
presentation, the argument carries the domain.** `price .price` means
*present the subject's price as a price* — the currency formatting is the
word's business, not the template's.

## The sentence

```
word :qualifiers, content, modifiers:
  children
```

Every part is optional. The order never varies.

| Argument | Means | Example |
|---|---|---|
| `:symbol` | qualifier — what kind, or what it is about | `button :primary` |
| `"string"` | literal text | `note "Saved."` |
| `.property` | the current subject's property | `title .name` |
| `name`, `name.prop` | a local or a helper | `greeting current_user.name` |
| `key: value` | modifier | `image .url, alt: .name` |
| *indented block* | children | |

### Resolution — two lookups, one rule each

- `.foo` → the **innermost subject's** `foo`.
- `foo` → a **local**, else a **helper**.

Nothing else is consulted, and nothing is ambiguous between them.

### The subject

- `each product` iterates `products`, binds `product`, and makes each element
  the subject.
- `section :products` makes `products` the subject.
- `.foo` always means the innermost subject.

Because `each product` also binds the name `product`, an inner loop reaches
back out by name. The escape hatch is already in the grammar; it needs no
syntax of its own.

### Qualifiers

`:symbol` always occupies the same grammatical role — it qualifies the word.
What a qualifier *does* belongs to the word: `:products` on a `section` says
what the section is about; `:primary` on a `button` says which kind of button.
The meaning is always set by the word immediately to its left, so a reader
never carries state to parse a sentence.

### Conventions carry the common case

A qualifier is expected to supply what can be inferred. The heading of
`section :products` is conventional; content overrides it:

```
section :products                  # heading: "Products"
section :products, "Merchandise"   # heading: "Merchandise"
```

This is the shape of every convention in the language: **the common case
costs zero words, and every convention is overridable by saying the thing.**

## Wishes

### 1. An index — the core characteristics

```
page :products
  section :products
    empty "Nothing here yet."

    grid :cards
      each product
        card
          image .image_url, alt: .name
          title .name
          price .price
          actions
            link :show, "View"
            button :primary, "Add to cart", if: .in_stock?
```

Note `empty`. It is not `if products.empty?` — it is a word meaning *what
this section says when it has nothing*. **Conditionals dissolve into
vocabulary:** do not write the branch, name the situation.

### 2. A form — conventions doing the work

```
page :account
  form :account
    field :name
    field :email, type: :email
    field :bio, :long
    check :newsletter, "Send me updates"
    actions
      button :primary, "Save"
      link :cancel, "Never mind"
```

`field :name` derives its label ("Name"), its input name, and its value from
`.name` — three inferences from one word. `:long` is a qualifier, so it means
what a `field` decides it means: a textarea.

### 3. A table — floating above the interpreter

```
table :products
  column :name
  column :price
  column :stock, "In stock"
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
    link :account, "Your account"
  otherwise
    link :sign_in, "Sign in"
```

`when` and `otherwise` are ordinary words that are valid inside `choose`.
`else` is never a bare keyword, so nothing needs special parsing. Most
branching should not reach for this — prefer `empty`, or the `if:` modifier.

## Guessability proof

The acceptance test for the language: sentences derived from the grammar
table alone, appearing in none of the wishes above. A fluent speaker should
be able to write these having only read the table.

```
section :orders, "Recent orders"
  empty "No orders yet."
  each order
    card :compact
      title .number
      price .total, if: .paid?

table :invoices
  column :number
  column :due_on, "Due"

form :password
  field :current, type: :password
  field :replacement, :long, type: :password
  actions
    button :primary, "Change it"
```

If a sentence here needs the implementation to explain it, the grammar has an
irregularity and the grammar is what gets fixed.

## Open questions

- **The vocabulary itself.** The grammar is one sentence and cannot really be
  wrong now; the vocabulary can be *incomplete*, and in a language where words
  are the only construct, every gap is a wall. Enumerating the words of web
  presentation is the next real work. First estimate is roughly forty.
- **`doctype`.** One keyword that fits no rule. Unsolved rather than faked.
- **Backend.** `.foo` is not valid Ruby, so we own the grammar — this is not
  Slim with a different tag line. The transform stays thin (indentation to
  blocks, `.foo` to `subject.foo`, every line a Ruby method call). Whether we
  keep Temple for escaping and generation is a separate and later question.
