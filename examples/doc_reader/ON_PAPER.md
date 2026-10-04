# On paper — doc_reader under three scoping rules

Written 2026-10-04 on the `conventions-as-principles` branch. Nothing here runs
yet: this is the paper half of "paper, then reality". Each page is shown as it
reads today and as it would read under the rules, with what changed and why.

## The rules

dan's rule was *everything available to a parent is available to its
descendants*, with dots ruled to mean "it". Written for an author:

1. **A dot means "it":** the nearest subject. When "it" has no such thing,
   the dot fails honestly; it never borrows from an ancestor.
2. **A name reaches any ancestor that was named, and the nearest wins.**
   Every word that changes what "it" is also names it: `page document` names
   `document`, and `section chapters` names `chapters`. `each` already does this.
3. **Nothing flows upward unless a word says so.** The sanctioned upward flow
   is a registering word handing something to its gatherer (`column` to
   `table`).

**Measured, not assumed:** "descendants" means descendants in the tree the
author sees, with partials and `def`s expanded where they are placed. A partial
under `each account` already sees `account` today. That already matches the
rule, so it needs no change.

**One provisional ruling the paper had to make.** When a word shifts "it", its
own arguments read *the subject it lands on*. `page document, .title` means
"the document, titled by its title". This is rule 1 applied to the sentence
itself, but it is a ruling and it is dan's. What it costs: to read the old
"it" on that same line, you use its name.

## Today: why names stop reaching

Probed 2026-10-04:

- `page portfolio`, then `portfolio.owner` inside a section: *there is no word
  `portfolio`*.
- `section account`, then `account.name` from its child: *there is no word
  `account`*.
- `each account`, then `account.name` at any depth: works.

Only `each` names what it shifts to. The page's locals are reachable only while
the page is "it", so the first shift makes them unreachable.

---

## document.sp

Today:

```
page document, document.title
  card
    …
  section chapters
    empty "No chapters."
    list
      each chapter
        item .text
  prose markdown, .content
```

On paper:

```
page document, .title
  card
    …
  section chapters
    empty "No chapters."
    list
      each chapter
        item
          link .text, to: "#{document.href}##{chapter.anchor}"
  prose markdown, .content
```

- **Removed:** `document.title`, a Ruby workaround that worked only because the
  app happened to pass a local of the same name. Under the provisional ruling,
  `.title` is the document's own title.
- **Made sayable:** a chapter can link into its document. Two shifts down, under
  `section chapters` and then `each chapter`, `document` is still reachable
  because `page document` named it (rule 2). Today this sentence fails. (The
  domain would add `Heading#anchor`.)

## search.sp

Today:

```
page query, "Search the documents"
  form to: "/search", method: get
    …
  section results
    empty "Nothing matched."
    each result
      document_card
```

On paper:

```
page query, "Search the documents"
  form to: "/search", method: get
    …
  section results, "Results for “#{query.q}”"
    empty "Nothing matched “#{query.q}”."
    each result
      document_card
```

- **Made sayable:** the results can say what was searched for. It has to be
  `query.q`, not `.q`: under the provisional ruling the section's own arguments
  read "it" = the results, and the results have no `q`. **That is the rules
  working, not a wart**, because the dot keeps meaning one thing. The name says
  which ancestor.
- And `document_card`, a partial, could say `query.q` too (to highlight the
  match), because a partial sees its call site's names.

## index.sp

Today:

```
page "Doc Reader"
  catalog docs, "Documents"
  reading_pane selected_doc

def catalog, documents, title
  box documents, title
    empty "No markdown documents in ~/dev/alt-slim-pickins."
    list
      each document
        link .name, .href
```

On paper, with only the scoping rules, nothing *has* to change. But one thing
becomes sayable inside `catalog`: the reading pane's document is reachable as
`selected_doc`, so the catalog could mark the open document as active.

**Honest limit:** writing it needs a comparison
(`active: document == selected_doc`). Whether the language takes expressions in
modifier position is a separate question, and the paper doesn't assume it. So
scoping makes the *name* reachable; the comparison is a grammar question.

## shelf.sp and audiences.sp

**No change.** Neither page reaches above "it": every metric, column and section
talks about the subject in front of it.

That is evidence the rules are conservative. A page that only says "its" is
untouched, and only pages that wanted to reach up and couldn't get anything new.

---

## What the rules cost

- **Shadowing hides the outer name.** Suppose a document page listed related
  documents with `each document`, from: `.related`. Inside, `document` is the
  related one (nearest wins), and the page's document can no longer be reached
  by name. The author has to pick a different binding (`each related, from:
  .related`, or a domain method `related_documents`). Ruby makes the same
  trade, and it is an honest one: the nearest name always wins, so there is no
  ambiguity to guess about.
- **More names in scope means more chances to collide with a word.** Names and
  words share one namespace (a bare `portfolio` is looked up as a binding, then
  as an attribute of "it", then as a word). A section named `table` would put a
  binding called `table` in scope beside the word `table`. Not yet probed: this
  is where the word-scoping discussion (built-ins, then the app's words, then the
  page's `def`s, nearest wins) has to meet this one.

## What the rules do not touch

Scoping answers *where a name resolves*. It does not answer *what a name is*: a
reference, a label or a variant. These earlier findings need the second rule
("the contract decides what a bare name means; the subject is never asked to
break the tie"), not this one:

- `section users` losing its `section--users` class
- `search`'s `q:` coupling
- the id that follows the binding (`result-primer`)

Also unrelated to scoping: `actions` nesting a form, heading levels that skip,
and an empty page subject pruning unrelated sections.

## What reality should test

1. **Make `page` and `section` name their subjects**, the minimum of rule 2.
   Then count what breaks in the corpus, and which existing workarounds (Ruby
   expressions reaching locals) can be deleted.
2. **The provisional ruling:** make a shifting word's own dots read where it
   lands. Then count the pages whose first line changes meaning.
3. **Probe the name/word collisions** before trusting rule 2 at scale.

---

# Reality — what happened when it was built

Built the same day, on the same branch. **The rendered corpus is byte-identical
before and after** (digest `c1d40c8a…`, `diff -r` clean): the rules add reach
and change no page that already worked.

## Step 1: every shift names its subject

- **One change, in one place.** `Builder#about` is where every word that moves
  "it" goes through (`page`, and the partials `section` and `card`). It now
  names the subject it moves to.
- **A defect found on the way.** Bindings were a flat hash (`bind`/`unbind`), so
  an inner `each account` under an outer one *deleted* the outer binding on its
  way out instead of restoring it. They are now scoped (`Builder#naming`): the
  nearest wins, and the shadowed name returns. `each` uses the same helper, and
  `bind`/`unbind` are gone.
- **Workarounds deleted: none.** Nothing in the corpus reached past a shift,
  because nothing could. Step 1 adds reach; it removes nothing.

## Step 2: a sentence that names where it lands reads its dots there

- **One rule in the transform** (`Transform#lands?`). A shifting word with a
  bare name receives its content unevaluated, through the `lazy:` mechanism
  `when` and `box` already used, and reads it after landing.
- **Gatherers are left out.** `table` and `chart` declare `subject: :shift`, but
  nothing beneath them sees the collection as "it", so there is nowhere for
  their content to land. That contract slot is imprecise for them, which is a
  small finding of its own.
- **Workarounds deleted: three**, each now a plain dot:
  - `page entry, entry.title` (lore_reader)
  - `page document, document.title` (doc_reader)
  - `card first_item, first_item.path` (dashboard's queue)

  The queue line is outside the byte-diff corpus (triage renders with no item),
  so it was proved separately. The old and new lines render identical HTML
  against a real item.
- **PRIMER's "Where the language stops" listed this limitation** ("`page
  pattern, .title` reads perfectly and cannot work"). It is removed, and "One
  rule of resolution" now states both rules, with an example run on this branch
  and refused by the old runtime.

## Step 3: names that collide with words

- **When a binding is named like a word, the word wins, silently.** Under
  `section title`, a bare `title` calls the vocabulary's `title` and renders
  nothing useful. (`.to_s`, the dot, still works.) `each` refuses such names;
  `page` and `section` now create bindings without that guard. Words are Ruby
  methods, so they are found before any binding is asked. **Not fixed: this is
  the namespace question.** If words are the outermost scope, the nearer binding
  should win.

## Found along the way, not fixed

- **An interpolated string with a space before `#{…}` is refused by the
  argument splitter**: `"in #{account.name}"` fails while
  `"#{account.name} in"` works. This predates the branch, and it matters more
  now, because interpolation is where names are most needed.

## Tests

Four tests in `test/phase0_test.rb`, beside the existing dot rule:
- every shift names its subject
- the nearest name wins and the shadowed one returns
- a dot never borrows from further out
- a sentence that names where it lands reads its dots there

Three fail on the old runtime. The fourth guards behaviour the rules
deliberately keep.
