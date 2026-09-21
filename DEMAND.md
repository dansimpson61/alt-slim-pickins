# Demand Ledger — alt-slim-pickins 0.3

The demand ledger is the spine of Roadmap 0.3 Phases 1, 2, and 3.
During Phase 1 (The Garden, planted) and Phase 2 (Measure the demand), the 64-word vocabulary and runtime are frozen: no mid-write patches, no ad-hoc additions.

Every refusal, layout workaround, missing word, or syntactic friction encountered while authoring demonstration apps or rendering markdown surfaces is logged here verbatim with:
- **Gap ID**: Sequential ($G_1, G_2, \dots$)
- **Context & Consumer**: The app, page, and sentence that encountered it
- **Desired Expression**: What the author wanted to say in sp
- **Refusal or Obstacle**: The compiler/runtime error, contract refusal, or styling wall
- **Workaround Used**: How the app achieved its goal without modifying `lib/slim_pickins/`

These logged gaps form the demand evidence that gates Phase 3's vocabulary and kernel additions.

---

## The Gap Ledger

### G1 — `Library#render` is not an affordance
- **Consumer**: Outside developer authoring and testing `examples/lore_reader`.
- **Desired Expression**: `lib = SlimPickins::Library.from(views_path); lib.render(:index, locals: ...)`
- **Refusal**: `undefined method 'render' for an instance of SlimPickins::Library (NoMethodError)`
- **Obstacle**: Developers naturally expect a loaded template library object to be able to render a named template directly. In alt-slim-pickins, `Library` is only a catalog of partials, layouts, and word registries; rendering requires `SlimPickins.render(File.read(...), ...)` or Tilt templates.
- **Workaround**: Used `SlimPickins.render` directly with `File.read` and passed `library: lib`.

### G2 — `metric` crashes when passed an evaluated expression / integer
- **Consumer**: `examples/lore_reader/views/index.sp`
- **Desired Expression**: `metric stats.total_entries, "Total Entries"` (where `stats` is a hash/struct with integer `total_entries`)
- **Refusal**: `TypeError: nil is not a symbol nor a string` at `subject.rb:75:in 'Kernel#respond_to?'`
- **Obstacle**: `metric`'s contract expects an attribute name symbol on the current subject. When passed an integer value, `arguments` treats it as content and leaves `name` as `nil`, which is passed to `subject.fetch(nil)` causing `respond_to?(nil)` to crash with a TypeError.
- **Workaround**: Established `stats` as the subject via `section stats, "Archive Overview"` and then called `metric total_entries`.

### G3 — `Subject#to_s` emits Ruby inspection instead of data value
- **Consumer**: `examples/lore_reader/views/partials/lore_card.sp` and `views/entry.sp`
- **Desired Expression**: `each word, from: .words` followed by `badge .to_s` (or `badge word`) to display each string item in an array of strings.
- **Refusal**: Rendered `#<SlimPickins::Subject:0x00007f0...>` in the HTML output!
- **Obstacle**: `Subject` wraps data items and relies on `method_missing` to delegate attribute lookups to the wrapped object. Because `Subject` inherits from `Object` and does not override `to_s`, calling `.to_s` resolves to `Object#to_s` rather than delegating to the underlying string's `to_s`. Bare `badge word` also failed because `badge` treats a bare identifier as a variant name, emitting `<span class="badge badge--word">word</span>`.
- **Workaround**: Used `badge .to_str` because `String` defines `to_str` while `Object` does not, which correctly falls through `method_missing` to the underlying String.

### G4 — `article` is not a word
- **Consumer**: `examples/lore_reader/views/entry.sp`
- **Desired Expression**: `article` to enclose the lore entry document.
- **Refusal**: `there is no word 'article' (SlimPickins::Error)`
- **Obstacle**: The developer expected HTML semantic container `<article>` to correspond to an `article` word, analogous to `section`, `nav`, etc.
- **Workaround**: Used `card`, which renders `<article class="card">`.

### G5 — Dotted data syntax cannot be used in Ruby string interpolation
- **Consumer**: `examples/lore_reader/views/partials/lore_card.sp`
- **Desired Expression**: `link entry, "Read entry", to: "/entries/#{ .id }"`
- **Refusal**: `syntax error found (SyntaxError): unexpected '.', ignoring it`
- **Obstacle**: String arguments enclosed in double quotes are evaluated via standard Ruby string interpolation where leading dots without receivers (`#{.id}`) are a Ruby syntax error.
- **Workaround**: Wrote `to: "/entries/#{entry.id}"` referencing the iteration variable directly.

### G6 — `empty` is silently ignored inside a `section` with only a string title
- **Consumer**: `examples/lore_reader/views/entry.sp`
- **Desired Expression**: `section "Words Mentioned"` followed by `empty "No vocabulary words indexed in this entry."` and `each word`
- **Refusal**: `empty` was silently suppressed even when `entry.words` was empty (`[]`).
- **Obstacle**: `empty` checks whether the *enclosing subject* is an empty collection (`Inference.collection?(value)`). A section declared with only a title string (`section "Words Mentioned"`) has a nil subject (`about(nil)`). Since `nil` is not an empty collection, `empty_active?` evaluates to `false`.
- **Workaround**: Explicitly named the subject on the section: `section words, "Words Mentioned"`.

### G7 — Built-in `search` word hardcodes the destination route to `to: "/search"`
- **Consumer**: `examples/lore_reader/views/index.sp`
- **Desired Expression**: Using the built-in `search` word on the index page (`search placeholder: "..."`)
- **Refusal**: Search form submitted to `GET /search` which returned HTTP 404.
- **Obstacle**: `lib/vocabulary/search.sp` hardcodes `form method: get, to: "/search"`. The app handles filtering at `GET /?q=...`. The built-in partial cannot accept an override for its form destination without rewriting or shadowing.
- **Workaround**: Authored the search form using primitive words: `form to: "/", method: get`, `input q, placeholder: ...`, and `button "Search"`.

### G8 — Empty string is truthy in conditionals
- **Consumer**: `examples/lore_reader/views/index.sp`
- **Desired Expression**: Conditionally displaying the active search query or filter chip only when `q` is non-empty.
- **Refusal**: `when .q` evaluated as true when `q == ""`.
- **Obstacle**: In Ruby, empty strings `""` are truthy.
- **Workaround**: Left `input q` to display the search value in the input field without conditional branching.
