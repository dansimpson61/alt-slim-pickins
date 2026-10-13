# Daytrip 0.6.0a — Polysemy Census & The Great Disambiguation

**Status: closed 2026-10-12, on dan's word.**

Fulfilling the opening movement of Roadmap 0.6:
1. Conducted an exhaustive, repository-wide census of overloaded terms across all 130 files (`variant`, `children`, `content`, `subject`, `name`, `body`, `parent`, `tin`, `spiff`), codified in a permanent, clean instrument (`bin/census_polysemy.rb`).
2. Sized and analyzed the quadruple duty of `variant` (presentational style vs. semantic status vs. formatting mode vs. contract slot) and ruled its architectural resolution with dan: retiring `variant` as a privileged compiler slot in favor of a universal key-value mapping primitive where `dictionary` is the noun (the table of meanings) and `map` is the verb (the lookup, query, and dispatch).
3. Sized and analyzed the quadruple duty of `children` across four distinct trees (Outline, Lexical Family, DOM, and Data) and ruled its resolution with dan: unifying the splice pronoun on `contents` across both `.tin` files and `.sp` partials, retiring `children` as a template keyword, and speaking of family containment as "members" and collections as "items".
4. Clarified parameter naming in partial definitions (`title`, `label`, `text`), keeping `content` as the text argument and `.content` as a domain attribute on documents.
5. All twelve gate legs green, 35 pages byte-identical, `ruby -w -c` clean, full test suite passing (637 runs, 6,869 assertions, 0 failures).

**Baseline:** All twelve gate legs green, 35 verified pages byte-identical, test suite at 637 runs, 6,869 assertions, 0 failures, at commit `df60712`.
**Outcome:** All twelve gate legs green, 35 verified pages byte-identical, test suite at 637 runs, 6,869 assertions, 0 failures.

---

## Part 1 — The Polysemy Census

Over five roadmaps, vocabulary words and structural concepts accumulated development sediment. While the grammar remained one sentence, terms were pressed into multiple conflicting roles.

The new instrument `bin/census_polysemy.rb` surveyed the entire repository:

| Term | Ruby (`.rb`) | Templates (`.sp`) | Living Docs (`.md`) | Core Collision |
| :--- | :--- | :--- | :--- | :--- |
| **`variant`** | 104 in 23 files | 23 in 10 files | 335 in 55 files | Style weight vs. data status vs. format mode vs. contract slot |
| **`children`** | 221 in 39 files | 24 in 18 files | 346 in 56 files | Template yield word vs. AST node list vs. family containment vs. DOM elements |
| **`content`** | 250 in 46 files | 21 in 14 files | 442 in 67 files | Partial parameter slot vs. contract boolean vs. domain text (`document.content`) vs. CSS |
| **`subject`** | 196 in 43 files | 6 in 6 files | 629 in 98 files | Domain record being framed vs. active evaluation receiver (`Builder#subject`) |
| **`name`** | 1,074 in 94 files | 27 in 20 files | 968 in 77 files | Parameter slot vs. word registry symbol vs. HTML input name vs. record `#name` |
| **`body`** | 380 in 53 files | 1 in 1 file | 151 in 34 files | Block AST nodes vs. HTML `<body>` vs. model text vs. convention `box_body_over_children` |
| **`parent`** | 30 in 9 files | 2 in 1 file | 120 in 64 files | Family class namespace (`Table`) vs. container-value walk vs. DOM parent node |
| **`tin`** | 123 in 32 files | 0 files | 78 in 17 files | 9 `[app].tin` outer document chrome files |
| **`spiff`** | 140 in 19 files | 4 in 3 files | 121 in 16 files | `[app].spiff` spatial companion stylesheet language |

Across the 62 canonical words in contracts:
- 14 words take `:variant` as their name slot (`aside`, `badge`, `box`, `button`, `grid`, `item`, `list`, `nav`, `note`, `paragraph`, `scroll`, `span`, `tabs`, `time`).
- 20 words take `children: :any`, 36 take `children: :none`, and 6 take specific member lists (`chart`, `choice`, `choose`, `form`, `nav`, `table`).
- 48 words take `content: true`, 14 take `content: false`.

---

## Part 2 — Disentangling `variant`: `dictionary` & `map`

### The Problem
`variant` was originally invented as a CSS class suffix generator (`class="button button--primary"`). It grew to become:
1. A hardcoded status case statement (`conventions.rb` hardcoding `:ok`, `:blocker`, `:warning`, `:pending` for `badge`).
2. A format switch (`time` checking `:relative`, `choice` checking `:radio`).
3. A compiler collision hazard (`Builder#define_single_local_word` pooling `bound[:subject] || bound[:variant] || bound[:name]` and guessing whether a bare symbol is an attribute or a CSS class, causing `section users` to drop `--users` if the subject responds to `#users`).

### Dan's Ruling: The Primitives of Association
Dan observed (2026-10-12):
> "I wonder if 'variant' is just an example of something more primitive: a hash or dictionary, a set of key: value pairs. If we had such a primitive, we could roll our own data-determined badge or author-chosen type."

### The Architectural Resolution
1. **Retire `variant` as a privileged compiler slot.** The compiler no longer guesses whether symbols are attributes or variants.
2. **`dictionary` is the noun (the table of meanings):**
   - Can be defined as a named table:
     ```sp
     def status_badges
       dictionary
         active: active_badge
         dormant: dormant_badge
         archived: archived_badge
     ```
   - Or as a multi-line outline dispatch in a partial:
     ```sp
     def my_buttons, kind, label
       dictionary kind
         primary: primary_button
         secondary: secondary_button
     ```
3. **`map` is the verb (the lookup, query, and dispatch):**
   - Queries a reusable dictionary:
     ```sp
     map status_badges, .status, .name
     ```
   - Or performs an inline ad-hoc value translation:
     ```sp
     badge (map .status, active: ok, dormant: neutral), .name
     ```
4. **Under the hood:** A single resolution primitive (`Dictionary.resolve(key, table, *args, &block)`) handles both:
   - If the target is a Word, it invokes the word with forwarded arguments and block.
   - If the target is a Value (string, symbol), it returns/emits that value.

---

## Part 3 — Disentangling `children`: The Splice Pronoun & The Four Trees

### The Problem
"Children" was used simultaneously across four unrelated trees:
1. **The Outline Tree (Syntax / AST):** Indented lines under a parent sentence.
2. **The Lexical Family (Lookup Scope):** Component classes nested in parent classes (`Table::Column`, `list.sp/item`).
3. **The DOM Tree (Output):** Nested HTML tags.
4. **The Domain Object Graph (Data):** Records in a collection (`account.transactions`).

Furthermore, in templates, partials said `children` to splice their block, while `.tin` files said `contents` to splice the page, even though both words in `words.rb` (`Children` and `Contents`) were identical twins (`speech: :pronoun, shape: :splices`).

### Dan's Ruling: The Universal `contents` Splice
In English, a human has children and a tree has branches, but **a box, a tin, a card, and a section hold `contents`**.

1. **Unify on `contents` as the one universal splice pronoun:**
   - In `.tin`: `contents` marks where the page goes.
   - In partials (`card.sp`, `section.sp`, `aside.sp`, `list.sp`): `contents` marks where the caller's block goes.
   - `children` as a template word is retired.
2. **Untangle the Four Trees in Vocabulary & Pedagogy:**
   - **Outline:** *nested block* or *details* (indentation denotes subordination).
   - **Family:** *members* or *components* (`column` is a member of `table`, not a "child word").
   - **Data:** *items* or *records* (a list holds `items`, not "children").
   - **DOM:** *elements*.
3. **Clarify `content` vs. `contents`:**
   - `content` (singular) = the text/data payload argument (`tag p, .content`, `document.content`).
   - `contents` (plural) = the container's nested block splice (`contents`).
   - Partial parameters are encouraged to use descriptive names (`title`, `label`, `text`) rather than the generic word `content`.

---

## Deliverables & Verification

- **New Instrument:** [`bin/census_polysemy.rb`](bin/census_polysemy.rb) — automated codebase census measuring all polysemic terms and contract distributions. `ruby -w -c` clean, vitals clean.
- **Rulings Documented:** Architecture for `dictionary` / `map` and `contents` fully designed and recorded.
- **Gate Checks:**
  - `check_ruby.rb`: 0 problems across 131 files (`ruby -w -c` clean).
  - `check_vitals.rb`: 0 problems.
  - `bin/check_card.rb`: 0 problems.
  - `bin/verify_pages.rb`: 35 pages verified byte-identical.
  - Full test suite: 637 runs, 6,869 assertions, 0 failures.
  - All 12 gate legs green on `/status`.
