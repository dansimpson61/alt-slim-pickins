# What if — doc_reader as a playground for the principles

Written 2026-10-04 on the `conventions-as-principles` branch. dan asked: take
`doc_reader`, see what each convention lets us do, add code freely, and don't be
held to the current vocabulary. This is the record of what happened when we did.

The app now reads this repository's own documents through a small domain
(`lib/shelf.rb`: `Shelf`, `Document`, `Query`). It has five pages: `index`, `shelf`,
`document`, `audiences` and `search`. Every page tries to say as little as it can,
so that we can see what the principles decide on its behalf.

## The first thing the domain said

Of the 177,472 words in this repository's documents, **74% are history**:
132,115 words in 33 documents (daytrips, roadmaps, lore, the chronicle). The three
documents written for someone learning the language hold 10,988, and the developers'
documents hold 34,369. For every word a learner is meant to read, the repository
keeps twelve words of history. That is the over-built
question measured in the documents, not only in the code.

## Principle by principle

Each section gives the sentence that did the work, what it decided, and where it
pinched.

### A name is its own text
- `link shelf` became `<a href="/shelf">Shelf</a>`: one word gave both the address
  and the text.
- `metric total_words` became "Words on the shelf", because the domain declared the
  label once (`labels total_words: …`). The page never wrote a label.
- `section chapters` became the heading "Chapters".
- **Pinch:** `page document, .title` fails with *this page has no title*. A page
  reads its own arguments *before* it moves to its subject, so `.title` asks the
  outer page. lore_reader works around this with `page entry, entry.title`, a
  Ruby expression inside the language, and `document.sp` has to do the same.

### A name inflects
- `each chapter` inside `section chapters`, and `each document` inside a shelf,
  needed no `from:`.

### A collection walks itself, and having nothing is a situation
- `section results` with `empty "Nothing matched."`: the empty case is one line.
- **Pinch (surprising):** when the *page's* subject is an empty collection,
  everything under the page is pruned, including sections about *other*
  attributes. `page holder` over an empty enumerable renders only the `<h1>`.
  An empty shelf would silently blank the audiences page.
- **Pinch:** `Shelf` is both a collection and an object with attributes
  (`total_words`, `users`). The language decides "collection" by `each`, so an
  object that is both is read through whichever rule fires first. That's worth a
  rule of its own.

### How deep a heading sits decides its level
- `prose markdown, .content` moved the document's own `# The Way` down to an
  `<h2>`. It sat under the page's `<h1>`, and depth decided.
- **Pinch:** metric labels render as `<h3>` with no `<h2>` before them, on every
  page here. Depth decides, but nothing stops it skipping a level.
- **Pinch:** the page's `<h1>` renders *above* the tin's `<nav>`.
- **Pinch:** the title appears twice, once as the page's `<h1>` and once as the
  prose's demoted heading.

### A word owns its element, its class and its id
- `card` over a document became `<article id="document-primer">`, and app words
  carry their own class (`<ul class="list documents_list">`). Nothing on the page
  asked for either.
- **Pinch:** the same document is `document-primer` on its own page and
  `result-primer` in the search results. The id follows the name it was *bound*
  under, not what it *is*.
- **Pinch (a real defect):** `section users` loses its `section--users` class
  whenever the new subject also answers `users`, which a `Shelf` always does.
  `PartialWord#parameters_for` sets the class only when `!subject.has?(name)`.
  This is the same family as `search`'s `q:` (the eighth lore entry): a name slot
  that doubles as an attribute lookup. A class should come from what the page
  *said*, not from what the subject happens to answer.

### A value chooses its form
- Word counts were grouped (`177,472`) and aligned right; the history share became
  `74.4%`; and `changed_on`, a `Date`, became "16 September 2026" in a table cell
  and in a metric. None of it was asked for.
- `field include_history`, over `false`, became a checkbox, and `field q` became a
  text input holding what was typed.
- **Pinch (register):** dates in cells are formatted by `Generator.format`'s
  fallback to `Inference.moment`. The `format_family` entry claims only "number,
  percent or money", so the register understates what the language does.

### Where a word sits chooses its form
- `button "Search"` inside a form became `type="submit"`. This is the principle
  working.
- **Pinch (a real defect, already on `main`):** `actions` *always* opens its own
  `<form method="post">` (`lib/vocabulary/actions.sp`). Inside a form, that makes
  a nested form, so the button submits the inner one: a POST to the current URL.
  `milestone_planner`'s "Add Task" button does exactly this today: it posts to
  `/milestones/m1`, not `/milestones/m1/tasks`. `actions` means "a row of buttons"
  in one place and "a self-posting form" in another.

### A gatherer collects before anything renders
- `table documents` with five `column`s and a `total` gave a header, 47 rows and a
  footer from seven sentences. The total's label came from the domain ("Words").
- `choose` / `when .history?` / `when .for_users?` / `otherwise` picked exactly one
  badge.

### What is said nearest wins
- The domain's labels beat English everywhere, and nothing on any page overrode
  them. That is the chain doing its job silently.

### The theme owns the look, and the page frame
- These two weren't exercised beyond the tin.

## What if — ideas the play suggests, unconstrained by the current vocabulary

Each idea is one of the principles applied where it isn't yet. **None is built.**

1. **What if `actions` followed "where a word sits chooses its form"?**
   - Inside a form, it is a row of buttons.
   - Outside a form, it is its own form.
   This is the same rule `button` and `group` already follow, and it would fix
   milestone_planner. It is dan's "different behaviour, same convention", found in
   the wild.
2. **What if a page read its arguments in its new subject?** Then
   `page document, .title` would just work, and so would `section accounts, .name`.
   The rule would be "a sentence's dots read where the sentence lands".
3. **What if a class always came from the name the page said?** `section users`
   would always be `section--users`, whatever the subject answers. That would end
   the name-slot coupling family (`q:`, `section`), not just this instance of it.
4. **What if identity came from the object, not the binding?** A `Document` would
   be `document-primer` wherever it appears. Ruby already knows its class name.
5. **What if a document titled itself?** `page document` over something whose
   content begins with a heading would take that heading, and the prose would not
   repeat it. This would be "a name is its own text" extended to content.
6. **What if depth never skipped a level?** A metric label is either not a
   heading, or its level follows the nearest real heading.
7. **What if "empty" belonged to the collection, not the page?** Emptiness would
   prune what is *about* the empty thing, and nothing else.

## The DRY and OOP shape of the domain

- The app contract is declared on the class (`labels`, `formats`), not hung on
  each object as `Fixtures.labelled` does. One method declares and reads, so the
  reader and writer cannot drift. Worth considering as the house way.
- `Shelf` is `Enumerable` and returns `Shelf`s from its filters (`users`,
  `matching`, `without_history`), so every slice is itself a subject with totals.
  This is what found the class defect.
- `App.locals_for` is the single home for each page's locals: the routes and the
  boot proof both ask it, so what is proved is what is served.

## Left honestly unfinished

- The gate's page census and the vitals don't know about the new app, so on this
  branch `check_vitals.rb` and two tests are red: 8 apps and 30 app words, where
  the prose says 7 and 28. Wiring them in is part of deciding to keep this app.
- `document.sp` uses the `document.title` Ruby workaround (what-if 2).
- The pages have not been looked at in a browser. Run
  `ruby examples/doc_reader/app.rb` (port 4590).
