# Daytrip 0.6.0e — Pedagogy from First Principles: Guides Cleanse, Authentic Idiom & Taxonomy Alignment

**Status: closed 2026-10-13.** All movements implemented and verified across all 12 gate legs, 35 pages byte-identical, full test suite passing.

Fulfilling the second movement of Roadmap 0.6:
1. **Pedagogy from First Principles**:
   - Rewrite and refine primary pedagogical guides (`PRIMER.md`, `CONVENTIONS.md`, `VOCABULARY.md`) from the author's viewpoint, not the compiler developer's.
   - Strip out historical development narratives, compiler implementation details, and defensive justifications from past refactors (e.g. references to the old helper layer, Phase 1 renames, Phase 8 chart cut stories, draft numbers, and obsolete counts).
   - Preserve historical knowledge in `history/` and `LORE.md` where it belongs.
2. **Taxonomy & Keyword Alignment**:
   - Align all guide terminology with the 7 formal system taxonomy terms codified in `SlimPickins::Taxonomy::SYSTEM`: `word`, `primitive`, `partial`, `def`, `contract`, `tin`, `spiff`.
   - Purge retired keywords like `children` from template tier descriptions (replaced by `contents` in 0.6.0c).
3. **Authentic Idiomatic Authoring**:
   - Teach slim-pickins through clean, authentic, outline-like `.sp` pages and short, focused word `def`s.
   - Consistently demonstrate the universal convention model: `word [target], [override], [kwargs]`.
4. **Tool & Gate Synchronization**:
   - Run `bin/generate_vocabulary.rb`, `check_grammar.rb`, `check_vitals.rb`, and `check_shape.rb`.
   - Verify all 12 Studio gate legs, 35 proved pages, and `ruby -w -c` syntax.

---

## Part 1 — Audit of Historical Sediment in Primary Guides

### 1. `PRIMER.md`
- **Lines 7–10**: Starts with a defensive justification ("This document replaces the Slim-Pickins Way that described the old helper layer..."). An author coming to slim-pickins wants to know what the language *is*, not an argument against an obsolete library they never used.
- **Line 172–175**: "Two words broke the register — check and select were verbs... Phase 1 renamed them checkbox and choice...". Historical recounting of Phase 1 refactors belongs in the chronicle. The primer should simply state that `checkbox` and `choice` carry the noun register.
- **Lines 312–314**: "(The older ratio-of-uses figure was retired in writing — it measured where rendering happened, never the vocabulary's coverage.)". Defensive commentary on historical metrics.
- **Line 345**: Lists `children` under Structure tier alongside `contents`. `children` was retired as a template keyword in Daytrip 0.6.0c in favor of `contents`.
- **General**: Ensure the 7 formal taxonomy terms (`word`, `primitive`, `partial`, `def`, `contract`, `tin`, `spiff`) are introduced with clarity and consistency.

### 2. `VOCABULARY.md`
- **Line 1**: "Vocabulary — draft 3". The language is in Roadmap 0.6, well past initial draft numbering.
- **Lines 6–13**: Long paragraph recounting historical changes ("It said fifty for a fortnight... it said 64, in 42 and 22, after figcaption and summary were absorbed... Both drifts are why the promise ledger and the census exist.").
- **Lines 14–18**: Narrative about `chart` being the last holdout and Phase 8 cutting `pie`, `bar`, `area`.
- **Lines 24–27**: Justification about roth/views/controls.slim conversion.
- All of these belong in `history/CHRONICLE.md` and `LORE.md`. `VOCABULARY.md` should crisply define the 64 canonical words (41 primitives, 23 partials) and the universal convention model.

### 3. `CONVENTIONS.md`
- Review all convention entries to ensure they read as an author's guide to what the language decides when you say nothing, reinforcing target resolution, inferred labels, explicit overrides, and kwargs.

---

## Part 2 — Ordered Implementation Steps

### Step 1: Cleanse `PRIMER.md`
- Replace defensive opening with a direct, confident introduction to the language.
- Cleanse historical phase narratives from the register and escape hatch sections.
- Update Tier 1 (Structure) to remove `children` and establish `contents` as the splice pronoun.
- Integrate the 7 formal system taxonomy terms naturally.
- Ensure all code examples remain compliant with `check_grammar.rb`.

### Step 2: Cleanse `VOCABULARY.md`
- Replace draft numbers and historical drift stories in the header with a clean, confident introduction to the canonical vocabulary (64 words: 41 primitives, 23 partials).
- Verify that `bin/generate_vocabulary.rb` runs cleanly and reports 0 drift.

### Step 3: Align `CONVENTIONS.md`
- Audit and refine author-facing explanations across the convention principles.
- Ensure universal convention slots (`word [target], [override], [kwargs]`) are taught consistently.

### Step 4: Synchronize & Verify Gate Checks
- Run `check_vitals.rb` to ensure vitals claims match `Census`.
- Run `check_grammar.rb` to verify all sentences and word definitions.
- Run `bin/verify_pages.rb` to confirm all 35 pages remain verified.
- Run `check_ruby.rb` to ensure syntax is clean.
- Run `StudioStatus.run` to confirm all 12 legs are `ok`.
