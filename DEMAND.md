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

### G9 — No `radio` or radio group word for multiple-choice selections
- **Consumer**: `examples/way_exam/views/index.sp`
- **Desired Expression**: `radio name: .id, value: option, label: option` or a radio list for multiple choice questions.
- **Refusal**: `there is no word 'radio' (SlimPickins::Error)`
- **Obstacle**: The vocabulary has no `radio` word. While `field` accepts `type: radio`, it emits `<div class="field"><label for="...">Label</label><input type="radio"></div>` tied to the subject's attribute name, without a way to render a group of distinct options sharing one field name where each option has its own label.
- **Workaround**: Used `choice` with child `option` words (rendering `<select>` with `<option>` elements), which is the vocabulary's built-in single-selection form control.

### G10 — `form` refuses `section`
- **Consumer**: `examples/way_exam/views/index.sp`
- **Desired Expression**: `form to: "/grade", method: post` containing `section "Question 1"` for dividing form sections visually and semantically.
- **Refusal**: `form may not hold section (SlimPickins::SyntaxError)`
- **Obstacle**: `Form` contract restricts children strictly to `[:group, :field, :checkbox, :choice, :actions, :disclosure, :button, :hidden, :input, :textarea, :choose]`. Even though HTML `<form>` can contain `<section>`, the slim-pickins morphology enforces form-specific partitioning.
- **Workaround**: Used `group "Question 1"`, which renders `<fieldset class="group"><legend>Question 1</legend>`.

### G11 — `choice` refuses `each` for dynamic option lists
- **Consumer**: `examples/way_exam/views/index.sp`
- **Desired Expression**: `choice .id, .prompt` enclosing `each opt, from: .options` to dynamically render `<option>` tags from a collection.
- **Refusal**: `choice may not hold each (SlimPickins::SyntaxError)`
- **Obstacle**: `Choice` contract restricts its children strictly to `[:option, :choice]`. Dynamic generation of options from data collections via `each` is refused by the compiler. Furthermore, `Option` expects its identifier/value to be a Symbol (via `name_and_content`); passing string values leaves `value: nil`.
- **Workaround**: Statically authored question choices with symbol keys (`option a, "..."`, `option b, "..."`, `option c, "..."`).

### G12 — Predicate methods in `when` fail on Hash/JSON subjects
- **Consumer**: `examples/milestone_planner/views/partials/task_card.sp` and `views/milestone.sp`
- **Desired Expression**: `choose` with `when .done?` or `when .blocked?`
- **Refusal**: `this task has no done? (SlimPickins::UnknownAttribute)`
- **Obstacle**: Ruby domain models idiomatically use question-mark predicate methods (`done?`, `blocked?`). However, when models are serialized to JSON (for persistence or Studio playground data slots) and deserialized into hashes, keys are plain symbols/strings without `?` (`:done => true`). `Subject#fetch` checks exact hash keys and does not strip trailing `?` or map predicates on Hash objects.
- **Workaround**: Defined un-predicated aliases (`done`, `blocked`, `completed`, `at_risk`) on domain structs and hash serializers, authoring template conditions without question marks (`when .done`, `when .blocked`).

### G13 — No `progress` or `meter` word in vocabulary
- **Consumer**: `examples/milestone_planner/views/index.sp` and `views/milestone.sp`
- **Desired Expression**: `progress .progress, max: 100` or `meter .completion_ratio` to render native semantic HTML `<progress>` or `<meter>` elements for milestone completion.
- **Refusal**: `there is no word 'progress' (SlimPickins::Error)`
- **Obstacle**: The 64-word vocabulary has no widget word for visual completion bars (semantic `<progress>` or `<meter>`).
- **Workaround**: Displayed progress numerically using `metric progress, "Progress %"` and categorically using status badges (`badge ok, "Complete"`).

### G14 — Irregular English plural inference in `each`
- **Consumer**: `examples/word_graph/views/word.sp`
- **Desired Expression**: `each child` expecting to infer and iterate over `children` on the subject.
- **Refusal**: `this page has no childs to go through (SlimPickins::Error)`
- **Obstacle**: `Inference.plural(name)` applies simple regular inflection (`"#{s}s"` or `y -> ies`). Irregular English plurals like `child` -> `children` fail inference and look for `childs`.
- **Workaround**: Explicitly specified the source collection using the `from:` modifier with dotted data: `each child, from: .children`.

### G15 — Bare modifier value in `from:` evaluates to Symbol instead of subject data
- **Consumer**: `examples/word_graph/views/word.sp`
- **Desired Expression**: `each child, from: children` expecting `children` to resolve the `children` collection on the subject.
- **Refusal**: `undefined method 'to_a' for an instance of Symbol (NoMethodError)`
- **Obstacle**: In modifier argument position, a bare identifier `from: children` is parsed as a Symbol literal (`:children`). In the language's morphology, access to data on the enclosing subject requires a leading dot (`.children`). Passing a bare symbol causes `items.to_a` to crash on the Symbol.
- **Workaround**: Wrote `from: .children` with the leading dot to resolve data from the subject.

### G16 — Dotted data in `metric` and `fact` attribute position crashes with TypeError
- **Consumer**: `examples/word_graph/views/partials/word_card.sp` and `views/word.sp`
- **Desired Expression**: `metric .connections_count, "Connections"`
- **Refusal**: `TypeError: nil is not a symbol nor a string` at `subject.rb:75:in 'Kernel#respond_to?'`
- **Obstacle**: `Metric` and `Fact` declare `name: :attribute`. When passed a dotted identifier `.connections_count`, `arguments(@args)` treats dotted values as content/value, leaving `name` as `nil`. `subject.fetch(nil)` then attempts `respond_to?(nil)` which raises a Ruby TypeError rather than a language syntax complaint.
- **Workaround**: Wrote bare attribute names (`metric connections_count, "Connections"`, `fact speech_name`).

### G17 — `title` refuses bare identifier as content
- **Consumer**: `examples/word_graph/views/word.sp`
- **Desired Expression**: `title word_name`
- **Refusal**: `title takes no name — word_name (SlimPickins::SyntaxError)`
- **Obstacle**: `title` declares `name: :none, content: true`. A bare identifier is interpreted as a name argument rather than content, causing the contract check to reject it.
- **Workaround**: Wrote dotted data `title .word_name` or string content `title "Title"`.

### G18 — `badge` has no `info` or `accent` status variant
- **Consumer**: `examples/word_graph/views/partials/word_card.sp`, `views/word.sp`, and `views/shapes.sp`
- **Desired Expression**: `badge info, "Register"` or `badge accent, "Iterates"` for non-binary or neutral informative states.
- **Refusal**: `UNSTYLED VARIANT: badge--info is said and no rule defines it — a variant nothing can style is refused (check_styles.rb)`
- **Obstacle**: The theme stylesheet defines only seven badge states: `ok`, `pending`, `warning`, `polish`, `error`, `blocker`, and `neutral`. There is no dedicated `info` or `accent` role.
- **Workaround**: Mapped informative tags to `badge neutral` and highlighted control flow states with `badge ok` and `badge warning`.

### G19 — `grid` variant names are constrained to declared theme classes
- **Consumer**: `examples/word_graph/views/index.sp`, `views/word.sp`, and `views/shapes.sp`
- **Desired Expression**: Semantic grid naming such as `grid words, columns: 2` or `grid shapes, columns: 2`.
- **Refusal**: `UNSTYLED VARIANT: grid--words is said and no rule defines it — a variant nothing can style is refused (check_styles.rb)`
- **Obstacle**: `grid` treats its first identifier as a CSS modifier variant (`.grid--#{name}`). Unlike generic layout containers, `check_styles.rb` audits all emitted classes against CSS rules, and the stylesheet only declares `.grid--cards` and `.grid--metrics`.
- **Workaround**: Used `grid cards, columns: 2` or `grid cards, columns: 3`.
