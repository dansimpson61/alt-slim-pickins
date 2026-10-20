# alt-slim-pickins — roadmap 0.8

**An even-numbered roadmap. It leads with the backward eye.**

Status: **active.** Written 2026-10-19, drafted by the steward and confirmed by
dan. It is a roadmap and not a plan: it names the question and what success looks
like, leaving the step-by-step work to daytrips, the same way 0.4, 0.5, 0.6 and
0.7 did.

> **Ataovy dian-tana: jerena ny aloha, todihana ny afara.**
>
> *Walk like the chameleon: what lies ahead is watched, what lies behind is
> glanced back at.*

## The question

> **Does every word in the vocabulary — and every example application we keep —
> speak today's language honestly, without special-case compiler crutches,
> duplicated runtime seams, or pre-0.6 sediment?**

It is a backward-eye question, which is what an even roadmap asks for (README,
*How roadmaps go*). Roadmap 0.7 stretched the language forward with an editorial
prose publication (`examples/publication`), proving route signatures, landing
argument evaluation, `.style` companions, and `cluster` zones. Now the backward
eye turns to harvest what 0.7 taught, audit every word in the vocabulary and
every app in the garden against state-of-the-art `sp`, retire the scaffolds and
early prototypes that have served their purpose, and level the ground for
Roadmap 0.9's full CRUD stretch exam in `examples/portfolio`.

## The definition of success

1. **`metric`, `fact`, and a full vocabulary & composed-word audit.**
   - **`metric` and `fact` healed and unified:** Fix the live rendering defects
     measured at the start of 0.8 — bare `metric <attr>` overwriting its `<h3>`
     label with the metric's numeric value (`builder.rb:209`), two-argument
     `fact <name>, <value>` overwriting its `<dt>` label with the `<dd>` value
     (`builder.rb:198`), dotted `metric .attr` losing its attribute name, and
     `metric.sp` hardcoding `tag h3` instead of using `heading` inside `box`.
     Harmonize both words on a single `attribute, value` signature (with `label:`
     and `as:` modifiers) and delete the hardcoded `if word_name == :fact /
     elsif word_name == :metric / elsif word_name == :snippet` branch in
     `Builder#define_single_local_word`.
   - **Dead runtime duplicates retired:** Remove the unreachable `Generator#fact`,
     `Generator#metric`, and `Generator#snippet` methods, and collapse the
     duplicated contract/parameter engine in `PartialWord` so all `.sp` words
     compile and run through one path (`def` in `Builder`).
   - **Systematic audit of all 63 canonical words and all kept app words:**
     Conduct a word-by-word audit across all 37 Ruby primitives (`words.rb`) and
     26 `.sp` composed words (`lib/vocabulary/*.sp`) plus every kept app word:
     - *Retire `variant` to the extent practical:* 14 canonical words still
       declare `variant` in their contracts or `def` headers (`aside`, `box`,
       `button`, `card`, `choice`, `grid`, `item`, `list`, `nav`, `paragraph`,
       `scroll`, `span`, `tabs`, `time`). Six have zero CSS rules or callers;
       `nav` has zero callers; `card compact` appears only in `specimen.sp`; and
       `span` variants in `studio` (`span word`, `span attribute`) are places
       where the `sp` way is to mint a word (`def`) instead of a variant.
     - *Self-describing `def` signatures & zero compiler exceptions:* Harmonize
       `card.sp`, `section.sp`, and `title.sp` parameter names (`subject`
       instead of `target`) so `VocabularyShapes#infer_from_def` needs no
       hardcoded word-name exceptions; make `action.sp` and `search.sp`
       declare their modifiers in their `def` headers; and bring every kept
       `partials/*.sp` file in `examples/` and `studio/` onto explicit `def`
       headers.

2. **`KeyValue` spine, native `kwargs`, `box` in `def`s, and the `.style` / `.layout` handoff.**
   - **`SlimPickins::KeyValue` as the single runtime spine for `(key, label, value, format)`:**
     Every attribute-bearing word in the language asks the same four questions
     (`key`, `label`, `value`, `format`). Introduce `SlimPickins::KeyValue` to
     own those four questions and their three-tier precedence rules in one place,
     routing `metric`, `fact`, `table` (`column` / `total`), `chart` (`band` /
     `line`), and `form` controls (`field`, `input`, `textarea`, `checkbox`,
     `choice`, `option`, `hidden`) through `KeyValue`, and retiring
     `Builder#label_of`, `Builder#format_of`, `Builder#alignment_of`, and the
     ad-hoc hash surgery in `Builder#evaluate_word_definition`.
   - **Native `Hash` iteration as `KeyValue`s in `each` & shared indifferent key lookup:**
     Allow `each` to iterate a native Ruby `Hash` by yielding each `[k, v]` pair
     as a `KeyValue` (while keeping `Hash` a keyed subject when shifted into),
     and unify the duplicated `Symbol`/`String`/`boolean`/`nil` key-matching
     loops in `Subject` and `Dictionary`.
   - **Native `kwargs` in `.sp` `def` headers and `Words`:**
     Let `def` headers in `.sp` declare keyword modifiers natively (`def metric
     attribute, value, as: nil, label: nil`, `def action label, to: nil, ...`) so
     `VocabularyShapes#infer_from_def` reads modifiers directly from the `def`
     header and `CANONICAL_MODIFIERS` in `contracts.rb` vanishes; replace the 24
     `@kwargs.key?(:x) ? @kwargs[:x] : nil` ternary lines in `words.rb` with
     direct `@kwargs[:x]`.
   - **Minting words is the `sp` way — and `box` in a `def` splices `contents`:**
     In `sp`, we do not pass arbitrary variants to `box` (`box meta` would carve
     out a generator exception and retreat into variants); we mint a word
     (`def meta`, `def chips`, or a shared word in `lib/vocabulary/`), which the
     universal `root_class` convention already maps to `.meta` / `.chips` for
     `.layout` zones. When `box` is used inside a `def` with no block and no
     text body (`def meta / box`, `def actions / box`), let `Box#evaluate`
     splice `contents` by default so minting a container word does not require
     repeating `contents` underneath `box`.
   - **`.style` and `.layout` token handoff:** Update `Compiler::Layout::TREATMENT_TOKENS`
     to reference `var(--measure, 65ch)` and `var(--lead, 1.7)` so a surface's
     `.style` companion (`measure`, `lead`) governs `:editorial` and `:prose`
     zones instead of being overridden by hardcoded literals in `.layout`.
     Update `conventions.rb` and `bin/check_conventions.rb` so the axiomatic
     grade records the `.style` resolution rather than a stale absence.

3. **Triage and SOTA modernization of the example garden & documentation.**
   - **Explicit keep / retire / stow criteria applied:**
     - *Retire* `examples/milestone_planner` and `examples/way_exam`, along with
       the stray root `word_graph.html` dump and the broken root `roth/` links
       in `README.md` and `HANDOFF.md`.
     - *Stow* dated planning and study documents (`KERNEL.md`,
       `examples/publication/ON_PAPER.md`, `examples/publication/WHAT_IF.md`,
       `examples/dashboard/INVENTORY.md`, `examples/roth/ROTH_DOMAIN_BACKLOG.md`,
       `examples/roth/ROTH_STUDY.md`) into `history/`.
     - *Keep and modernize* `publication`, `portfolio`, `roth`, `dashboard`, and
       `word_graph` to state-of-the-art `sp`: replace multi-branch `choose/when`
       status-badge ladders with `dictionary`/`on`/`map`, replace variant hacks
       with minted words or `dictionary`/`map`, retire `Fixtures.labelled`
       singleton monkeypatching, and fix live two-argument `fact` calls across
       `examples/` and `studio/`. Kept apps are updated to be exemplary `.sp`,
       not constrained to byte-identical legacy HTML.

4. **Preparing the path for Roadmap 0.9 (`portfolio` as the full CRUD app).**
   - **`portfolio` chosen as the 0.9 target:** `examples/portfolio` will carry
     Roadmap 0.9's authentic SQLite-backed CRUD & state-mutation stretch exam
     (accounts, holdings, contributions, quantitative table totals and metrics
     recalculated under mutation, validation failures, and flash lifecycle).
   - **Form and emptiness seams cleared in advance:**
     - Widen `Form`'s child contract so a `<form>` can enclose `note`, `flash`,
       `section`, `box`, and composed words needed for validation feedback and
       multi-part forms.
     - Harmonize `Field` and `Input` modifiers (`placeholder:`, `required:`).
     - Scope `empty` pruning to the empty collection's own container so an
       empty collection does not prune sibling creation forms or toolbars on the
       same page.

5. **No author bookkeeping added.** Every change makes `.sp` views shorter, more
   regular, and truer to the one-sentence grammar.

6. **Green, and looked at.** All twelve gate legs and the full test suite remain
   green at the close of every daytrip, and every modified surface is verified
   live.

**What drift looks like:** preserving broken or inconsistent word behavior out of
fear of changing rendered bytes; adding new compiler special cases instead of
expressing words in `.sp`; keeping redundant prototype apps that duplicate
coverage; or jumping into 0.9's SQLite CRUD implementation before the 0.8
harvest is complete.

## How 0.8 arrived at this question

Roadmap 0.7 closed on 2026-10-19 after shipping `examples/publication` across six
daytrips (`DAYTRIP-0.7.0a` through `0.7.0f`). During the 0.7 visual sign-off and
the 0.8 scoping review, dan and the steward examined `metric`, `fact`, the
repeated `def meta / box / contents` pattern, the 63 canonical words, and the
eight example apps:

- `metric` and `fact` were found to rely on bespoke `if word_name ==` branches
  in `Builder#define_single_local_word` that actively corrupt labels on bare
  `metric <attr>` and two-argument `fact <name>, <value>` calls across 8 files,
  while seven different word classes in `Words` and `Builder` re-derived
  `(key, label, value, format)` by hand instead of asking one `KeyValue` object.
- Fourteen canonical words still carry `variant` in their contracts or `def`
  signatures (six with zero CSS rules or callers, others where minting a word
  with `def` or using `dictionary`/`on`/`map` is the `sp` way), and a blockless
  `box` inside a `def` (`def meta / box`) currently drops `contents` unless an
  explicit `contents` line is added.
- Reviewing the example garden showed that `portfolio` — with its relational
  `Account` → `Holding` hierarchy and quantitative `table` / `metric` / `money` /
  `percent` vocabulary — is the natural home for Roadmap 0.9's full CRUD app,
  allowing `milestone_planner` and `way_exam` to retire cleanly in 0.8.

## Proposed daytrip sequence

1. **0.8.0a — `metric`, `fact`, `snippet`, and the single word-compilation path (complete, [DAYTRIP-0.8.0a.md](history/daytrips/DAYTRIP-0.8.0a.md)):**
   Fixed `metric` and `fact` signatures (`def <word> attribute, value`, `label:`
   and `as:` modifiers, `heading .label` inside `metric.sp`), healed bare
   `metric <attr>`, dotted `metric .attr` / `fact .attr`, and 2-arg
   `fact <name>, <value>`, removed all hardcoded `word_name` branches in `Builder`,
   retired dead `Generator#fact` / `#metric` / `#snippet`, collapsed `PartialWord`
   onto `Builder#evaluate_word_definition`, and repaired callers.
2. **0.8.0b — `KeyValue` spine (`key`, `label`, `value`, `format`), `Hash` iteration in `each`, and native `kwargs` in `.sp` `def` headers & `Words` (complete, [DAYTRIP-0.8.0b.md](history/daytrips/DAYTRIP-0.8.0b.md)):**
   Introduced `SlimPickins::KeyValue` (`lib/slim_pickins/key_value.rb`) to unify
   `(key, label, value, format)` resolution across `metric`/`fact`, `table`
   (`column`/`total`), `chart` (`band`/`line`), and `form` controls (`field`,
   `input`, `textarea`, `checkbox`, `choice`, `option`, `hidden`); retired
   `Builder#label_of` and `Builder#alignment_of`; allowed `each` to iterate a
   `Hash` as `KeyValue` items and unified indifferent key lookup between
   `Subject` and `Dictionary`; enabled keyword modifiers in `.sp` `def` headers
   (retiring `CANONICAL_MODIFIERS` in `contracts.rb`); and replaced the
   `@kwargs.key?(:x)` ternary lines in `words.rb`.
3. **0.8.0c — `box` default `contents` splice & the `.style` / `.layout` handoff:**
   Let a blockless `box` inside a `def` splice `contents` automatically (so
   minting a container word is simply `def <word> / box` with zero generator
   exceptions and zero variants); connect `.style`'s `--measure` and `--lead` to
   `.layout`'s `TREATMENT_TOKENS`; update `conventions.rb` and
   `check_conventions.rb`.
4. **0.8.0d — Systematic audit of all 63 canonical words & all kept app words:**
   Audit every primitive in `words.rb`, every composed word in
   `lib/vocabulary/*.sp`, and every kept app word against a shared SOTA rubric:
   retire `variant` wherever practical (removing dead `variant` slots on
   `aside`, `box`, `item`, `paragraph`, `scroll`, `tabs`, `nav`, `card`, and
   replacing `span <variant>` in `studio` with minted words); harmonize
   `card.sp`, `section.sp`, `title.sp`, `action.sp`, and `search.sp`; remove
   word-name exceptions from `contracts.rb`; add explicit `def` headers to all
   kept partials.
5. **0.8.0e — Garden triage & SOTA app modernization:**
   Retire `milestone_planner` and `way_exam` (plus root `word_graph.html` and
   stale links); stow dated planning/study docs in `history/`; modernize
   `publication`, `portfolio`, `roth`, `dashboard`, and `word_graph` to use
   `dictionary`/`on`/`map`, `KeyValue`, and SOTA `.sp`.
6. **0.8.0f — Leveling the path for 0.9 CRUD & roadmap close:**
   Harmonize `form` / `field` / `input` contracts and collection-scoped `empty`
   pruning; run the full visual and gate verification across the five kept apps
   and Studio; close Roadmap 0.8.

## What this document is not

This document is not a design specification. It holds the question, the
definition of success, and how 0.8 arrived here. The working order belongs in
`PROJECT.md`'s `next_step`. Step-by-step progress belongs in daytrips, run one
at a time and verified before moving to the next.
