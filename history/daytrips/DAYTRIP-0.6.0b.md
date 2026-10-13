# Daytrip 0.6.0b — The Primitives of Association: `dictionary`, `on` & `map`

**Status: closed 2026-10-13, on dan's word.**

Fulfilling the second movement of Roadmap 0.6:
1. Implemented the universal key-value mapping and dispatch primitives:
   - `dictionary`: A gatherer word (`contract name: :topic, content: true, children: [:on, :otherwise], speech: :noun, shape: :gathers`) that collects branch mappings and dispatches on a topic key or stows a reusable table.
   - `on`: A contained prepositional registrar (`contract name: :name, content: true, children: :any, speech: :preposition, shape: :registers`) nested under `Dictionary::On` in lexical family containment; valid only inside `dictionary`. Handles branch blocks, word forwarding targets, and default fallback registration.
   - `otherwise`: Repaired lexical namespace containment to allow words to be defined across multiple parent namespaces. `otherwise` is now polysemic across `choose` (`Choose::Otherwise`) and `dictionary` (`Dictionary::Otherwise`), providing an identical fallback experience across both control gatherers.
   - `map`: An open presenter word (`contract name: :topic, content: true, open: true, speech: :verb, shape: :presents`) supporting inline key-value mapping, word forwarding with extra arguments, fallback values, and reusable dictionary lookup.
2. Repaired Word Registry and Contract Scoping:
   - Converted `Word.parent_registry` from a scalar overwrite to a multi-parent accumulator (`parents_of(child) => [:choose, :dictionary]`).
   - Made AST contract checking in `Contracts.complaints` context-aware: resolving child word contracts against the active lexical family found in `ancestry.reverse`.
3. Undergirded all dispatch and lookup by a single engine primitive: `Dictionary.resolve(builder, key, table, fallback:, forward_args:, &block)`.
   - Dispatches blocks via `builder.capture`.
   - Dispatches registered or builder words via `builder.public_send(target, *forward_args, &block)`.
   - Returns literal values for expression mapping.
   - Handles indifferent key lookup across Symbols, Strings, and Booleans/Nil (`true` / `:true`, `false` / `:false`, `nil` / `:nil`).
4. Added Dan's architectural feature request to `WISHLIST.md` Section II: "App-Specific Ruby Words (`app-words.rb` / Authoring Words in Ruby)".
5. Synchronized contracts, census, and taxonomy:
   - `lib/slim_pickins/taxonomy.rb`: Registered `:dictionary`, `:on`, and `:map` in tier `:behavioral`, and updated `:otherwise` as default branch in `choose` and `dictionary`.
   - Canonical vocabulary expanded from 62 to 65 words (42 primitives, up from 39).
   - Vitals and shape checks verified repo-wide.
6. All twelve gate legs green, 35 pages byte-identical, `ruby -w -c` clean, full test suite passing (649 runs, 7,045 assertions, 0 failures).

**Baseline:** All twelve gate legs green, 35 verified pages byte-identical, test suite at 637 runs, 6,869 assertions, 0 failures, at commit `df60712`.
**Outcome:** All twelve gate legs green, 35 verified pages byte-identical, test suite at 649 runs, 7,045 assertions, 0 failures.

---

## Part 1 — Dan's Architectural Vision Realized

On 2026-10-12, Dan observed:
> "I wonder if 'variant' is just an example of something more primitive: a hash or dictionary, a set of key: value pairs. If we had such a primitive, we could roll our own data-determined badge or author-chosen type."

And regarding `otherwise` in `dictionary`:
> "1. We wrote Dictionary's contract. We could change it.
> 2. We have a flaw in our word registry if it does not allow the same word being defined in two different namespaces (possibly to mean different domain-related things). This is why we created namespaces."

Daytrip 0.6.0b delivers this primitive and repairs the namespace machinery without mutating grammar or adding compiler privileges:
- **No syntax changes:** Every sentence begins with a word (`word arguments`, indentation nests). No colon-initial syntax or non-word lines.
- **Lexical containment & shared names:** `otherwise` lives cleanly as `Choose::Otherwise` inside `choose` and `Dictionary::Otherwise` inside `dictionary`. Outside both, the compiler refuses it with `` `otherwise` belongs inside `choose` or `dictionary` ``.
- **Indifferent key resolution:** Template symbols (like `on true` compiling to `:true`), runtime booleans (`subject.drifted?` returning `true`), strings, and symbols resolve seamlessly against one another.

---

## Part 2 — Forms and Capabilities

### 1. Multi-line Block Dispatch with `otherwise`
```sp
dictionary .status
  on active
    badge "Active Account"
  on dormant
    badge "Dormant Account"
  otherwise
    note "Unrecognized Status"
```

### 2. Word Forwarding with Arguments
```sp
dictionary .status, "Status Notice"
  on active, badge
  on dormant, note
  otherwise, note
```

### 3. Inline Value and Word Mapping via `map`
```sp
# Value translation
label = map .status, active: "Active", dormant: "Inactive"

# Word dispatch with forwarded arguments
map .status, .label, active: badge, dormant: note
```

### 4. Reusable Dictionary Definition & Query
```sp
# In a helper or view
def status_badges
  dictionary
    on active, badge
    on dormant, note
    otherwise, paragraph

# Queried via map
map status_badges, .status, .label
```

---

## Part 3 — Verification Matrix

| Instrument | Measurement | Verdict |
| :--- | :--- | :--- |
| `check_grammar.rb` | 1,352 sentences, 99 defined words | 0 problems (PASS) |
| `check_shape.rb` | 65 canonical words | 0 problems (PASS) |
| `check_styles.rb` | Stylesheet consistency | 0 problems (PASS) |
| `check_spiff.rb` | Companion styles | 0 problems (PASS) |
| `check_spiff_scope.rb` | Companion style scoping | 0 problems (PASS) |
| `bin/check_promises.rb` | Contract declarations | 0 problems (PASS) |
| `bin/check_conventions.rb` | Conventions compliance | 0 problems (PASS) |
| `bin/check_card.rb` | Card alignment | 0 problems (PASS) |
| `bin/verify_pages.rb` | 35 pages across 8 apps and studio | 35 verified, 0 problems (PASS) |
| `check_vitals.rb` | 10 living docs, 131 Ruby files | 0 problems (PASS) |
| `check_ruby.rb` | `ruby -w -c` across 131 Ruby files | 0 problems (PASS) |
| Test Suite (`Census.test_files`) | 649 runs, 7,045 assertions, 0 failures | 0 failures (PASS) |
| `StudioStatus.run` | 12 gate legs live | 12/12 PASS |
