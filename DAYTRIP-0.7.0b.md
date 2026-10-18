# Daytrip 0.7.0b — Heal Wall 1: the frame is the shell, the route is the word

**Status: built and verified — the specimen reader serves the new shape.** This
is the first movement of Roadmap 0.7, attacking Wall 1 from the ledger in
[DAYTRIP-0.7.0a.md](DAYTRIP-0.7.0a.md).

## The decision Wall 1 wanted

Wall 1 asked "does `page` live in the frame or the route?" The answer: **neither —
`page` dissolves.** It was one word doing two jobs; the two jobs split cleanly
across the two canvases, and the word has nothing left to do:

- The **`.frame` file** is the shell: `<!DOCTYPE html>`, `<html>`, `<head>`,
  `<body>`, chrome, and the `contents` slot.
- The **route `.sp` file** is a word: its filename is the word name, and its
  leading sentence is the word's arguments.

The conflict existed only because `page` fused the envelope with the
declaration. Split them and the question answers itself.

## What we'd like

A route reads exactly like a `def` word, with the one word the author never has
to type — its name — supplied by the file it already sits in.

**The frame** — chrome and a slot, no envelope keyword; the file *is* the shell:

```frame
nav
  link home, "Reading"
  link shelf
  link timeline
  link search
contents
footer "Every document and every lesson, read as a reader meets them."
```

**`document.sp`** — the word `document`, subject and filename coincide:

```sp
document, .title
  cluster meta
    time .changed_on
    metric .reading_minutes
    badge .audience
  prose markdown, .content
```

**`search.sp`** — the word `search`, about `query` (leading name overrides the
filename):

```sp
query, "Search the documents"
  form to: "/search", method: get
    group "Look for"
      field q
      field include_history
    actions
      button "Search"
  section results
    empty "Nothing matched."
    each result
      document_card
```

**`index.sp`** — the word `index`, title only, no subject:

```sp
"The Publication"
  catalog docs, "Documents"
  reading_pane selected_doc

def catalog documents, title
  section documents, title
    list
      each document
        link .name, .href

def reading_pane document
  card document, .name
    prose markdown, .content
```

**`audiences.sp`** — the word `audiences`, about `shelf`:

```sp
shelf, "Who each document is for"
  section users
    documents_list
  section devs
    documents_list
  section history
    documents_list
```

## Why the grammar doesn't move

Every line above is already one sentence — `word arguments`, indentation nests.
The only thing that changes is *where the leading word comes from*, and `def`
already draws the exact line:

- `def card target, title` — `def` is the word; `card target, title` is the
  signature: name, then subject, then title.
- `document.sp` opening `document, .title` — the filename `document` is the
  name; `document, .title` is the signature: subject, then title.

So a route is a `def` whose `def <name>` line is elided because the filename
already says the name. The opening line is the parameters. That is the same
slot-reading the grammar already gives `section holdings, "What you own"` — a
bare name is the subject, a string or dotted value is the content. No new
punctuation, no new keyword, no new sentence shape.

It is a **convention**, not a syntax change: *when a `.sp` file's first line
isn't `def`, the filename is the word.* The same class of inference as "a name
inflects" or "a collection walks itself" — the language decides what the author
stayed silent about.

| Slot | Inferred from |
| :--- | :--- |
| **word** | the filename (always) |
| **subject** | the leading bare name, when there is one |
| **title** | the leading string or dotted value, or the second positional |
| **kwargs** | the leading `key: value` |

A title-only page is no special case: `"The Publication"` is a word whose
argument is a string — content, no subject — exactly as `section "Where you
stand"` is today. A bare name is a subject; a string is a title. Nothing has to
default to `index`, because nothing has to *be* a subject unless a bare name
says so.

A route `.sp` is a word (a namespace) that may still define its own `def` words
inside it — `index.sp` holds `def catalog` and `def reading_pane`, scoped to
`index`, the same way `list.sp` holds `item`.

## The contract, mechanically

### The title crossing (the crux)

The route's signature runs first: it binds the subject and computes the title.
The title is then available to the frame before it emits `<head>` and `<h1>`.
The route's body is spliced **lazily** at `contents`, under the already-bound
subject — not pre-rendered as today (`stow_contents` stores rendered nodes,
which is why the frame's subject shift arrives too late).

### The `.layout` (the stylesheet)

The frame's `<head>` links the compiled `.layout` CSS beside the base theme.
This also fixes the "declared but not served" state found in 0.7.0a: the
reader's `.layout` is validated by the gate but no page ever compiles or loads
it. The frame's envelope is where that link belongs.

### What changes in the runtime

- `stow_contents` must stow a **lazy body** plus the bound subject and computed
  title, not rendered nodes.
- `Builder#render`'s frame path must evaluate the route's signature first, then
  the frame's envelope, splicing the body at `contents` under the live subject.
- The envelope emission moves out of `Generator#page` into the frame path; the
  `page` word is removed, its subject/title logic absorbed by the route
  signature and its envelope logic by the frame.

## Not in this movement

- Walls 2–4 (self-titling, `cluster`, sayable theme roles) — one wall per daytrip.
- Migrating the eight existing apps off Shape A. That follows once the mechanism
  is proven on the specimen reader, so the byte-diff harness can certify it.

## What landed

- **The transform reads a route's signature.** `Transform.route?(path)` decides a
  `.sp` that is not a partial is a route, and a route's leading sentence is read
  as arguments, not `word arguments` — three shapes only: a quoted title
  (`"The Publication"`), a comma-led subject (`document, .title`), or a bare
  name the vocabulary does not know (`portfolio`). It compiles to `route(...)`
  with content landed lazily under the subject, the way `page`'s did.
- **`Builder#route` runs the signature.** It binds the subject, computes the
  title, links the base stylesheet and the compiled `.layout`, and hands the body
  to the frame. `stow_contents` now stows a lazy Proc (not rendered nodes), so
  `contents` splices the body under the live subject; the envelope stays a
  `page` node, but the route — not the `page` word — owns it.
- **The frame is the shell; `page` dissolves.** The specimen reader's five routes
  dropped `page` for signatures, and `doc_reader.app` now serves both the base
  theme and the compiled `doc_reader.layout` at `/assets/…` — the "declared but
  not served" state 0.7.0a found is fixed.
- **The legacy `page` word stays**, for the eight apps that still write Shape A;
  the guides and the pedagogy checker now teach the new shape, and `page` is
  marked legacy in VOCABULARY.md.
- **Certified by the byte-diff harness**: all five specimen pages render
  byte-identically to the old `page` shape except the one intended addition, the
  `<link>` to the compiled `.layout`. Twelve gate legs green; suite 657 runs /
  7,157 assertions / 0 failures.
