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

---

## Phase 2 Additions — Markdown Surfaces & Ecosystem Inventory

### G20 — Indented code fences are unparsed as code blocks
- **Consumer**: `foresight/README.md`, `rmd/README.md`, `foresight/docs/AI_Agent_Onboarding.md`.
- **Desired Expression**: Indented code fences (e.g. `   ```bash` or `    ``` `) inside list item continuations or indented sections.
- **Refusal**: Silently unparsed as code blocks. Emitted as standard paragraphs with inner code quotes: `<p>``<code>bash bundle install </code>``</p>`.
- **Obstacle**: `SlimPickins::Markdown::FENCE = %r{\A```[^\n`]*\z}` strictly requires backticks to begin at column 0. Any indented fence is treated as prose text, mangling the code block completely.
- **Workaround**: Authors must de-indent all code blocks to column 0.

### G21 — YAML frontmatter leaks into prose as horizontal rule and paragraphs
- **Consumer**: 22 ecosystem files with frontmatter (`PROJECT.md`).
- **Desired Expression**: Clean document reader rendering of `PROJECT.md` or markdown files with metadata headers.
- **Refusal**: `---` is rendered as `<hr>`, and the raw YAML keys (`schema_version: 1`, `status: >-`) are rendered as plain-text paragraphs at the top of the article.
- **Obstacle**: `SlimPickins::Markdown` has no frontmatter detection; it parses `---` unconditionally as an `<hr>`.
- **Workaround**: Outer applications must strip YAML frontmatter before passing strings to `prose markdown`.

### G22 — Markdown image syntax renders as broken link
- **Consumer**: Ecosystem documentation with diagrams (`![Architecture](/assets/arch.png)`).
- **Desired Expression**: `![Alt text](url)` rendering as `<img src="url" alt="Alt text">`.
- **Refusal**: Rendered as literal exclamation mark followed by a link: `!<a href="url">Alt text</a>`.
- **Obstacle**: `spans` matches `\[([^\]]+)\]\(([^)\s]+)\)` without checking for a leading `!`.
- **Workaround**: None within markdown prose; must use raw image words outside markdown if supported.

### G23 — Multi-line blockquotes collapse into a single run-on sentence
- **Consumer**: Dashboard `/brief` surface (`brief_text(p)`).
- **Desired Expression**: Adjacent blockquote lines (`> **Purpose:** ...\n> **Next Horizon:** ...`) rendering as separate lines or paragraphs.
- **Refusal**: `<blockquote><strong>Purpose:</strong> View DSL <strong>Next Horizon:</strong> Phase 2...</blockquote>`.
- **Obstacle**: `spans` replaces `\n` with a space `' '`, collapsing adjacent quote lines into a single sentence unless an empty line separates them.
- **Workaround**: Required inserting explicit blank lines between blockquote lines in the markdown source.

### G24 — `grid` lacks column spanning or asymmetric ratios for sidebar layouts
- **Consumer**: `examples/dashboard/views/pattern.sp`.
- **Desired Expression**: Asymmetric split layouts (e.g. 2:1 column ratio for specification body vs sidebar, or `span: 2`).
- **Refusal**: `grid` divides tracks evenly across `columns: N` (`calc((100% - (N - 1) * var(--gap)) / N)`). There is no word or modifier to span multiple tracks or configure fractional ratios.
- **Workaround**: Used equal 50/50 2-column grid (`grid cards, columns: 2`), placing the spec in column 1 and stacking the sidebar cards in column 2.

### G25 — `textarea` cannot be marked readonly and always requires form/attribute context
- **Consumer**: `examples/dashboard/views/pattern.sp` (Agent Lore Snippet).
- **Desired Expression**: Readonly copyable text area for prompt/lore snippets (`textarea lore, readonly: true`).
- **Refusal**: `Textarea` always emits `<div class="field"><label>...</label><textarea>` tied to form inputs, and refuses `readonly`.
- **Workaround**: Used `snippet .lore`, rendering `<pre class="snippet"><code>...`.

### G26 — Layout chrome requires explicit stylesheet declaration
- **Consumer**: `examples/dashboard/views/layout.sp` and `examples/word_graph/views/`.
- **Desired Expression**: Automatic stylesheet inclusion by `page`.
- **Refusal**: `page` generates `<!DOCTYPE html>`, `<head>`, and `<title>`, but omits `<link rel="stylesheet">` unless `stylesheet "/assets/slim-pickins.css"` is explicitly written in `layout.sp`.
- **Workaround**: Explicitly declared `stylesheet "/assets/slim-pickins.css"` in layout.

---

## The Merged Demand Ledger (Phases 1 & 2 Synthesis)

Across 4 garden applications and 3 dashboard markdown surfaces, 26 distinct gaps were cataloged. They partition into three clear categories for Phase 3:

| Category | Gaps | Nature of Demand | Phase 3 Candidacy |
|---|---|---|---|
| **Markdown Engine Gaps** | G20, G21, G22, G23 | Defects in `SlimPickins::Markdown` when consuming real ecosystem documents | **High**. Pure parser fixes in `lib/slim_pickins/markdown.rb` (indented fences, frontmatter stripping, image syntax, blockquote linebreaks). Zero vocabulary additions required. |
| **Ergonomics & Bindings** | G1, G2, G3, G5, G6, G8, G12, G14, G15, G16, G17 | Friction in Ruby data resolution (dotted vs bare, collection inference, `Subject#to_s`, method predicate mapping) | **High**. Corroborated across both Garden apps and Dashboard surfaces. Candidate for kernel refinement (e.g. name-directed access, predicate handling on hashes). |
| **Vocabulary & Morphology** | G4 (`article`), G7 (`search` route), G9 (`radio`), G10 (`form` sections), G11 (`choice` each), G13 (`progress`), G18 (`badge` variants), G19/G24 (`grid` variants & spanning), G25 (`textarea` readonly), G26 (`stylesheet` inference) | New words or structural power additions | **Selective / Demand-Gated**. Must be judged against the Ode: solve via app words/composition where possible, admit to the 64-word kernel only where an inexpressible structural floor exists. |

