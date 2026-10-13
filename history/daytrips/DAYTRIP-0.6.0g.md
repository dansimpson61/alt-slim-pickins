# Daytrip 0.6.0g — Repository Hygiene & Historical Archive: Daytrip Stowing & Example App Garden Audit

**Status: closed 2026-10-13.** All movements implemented and verified across all 12 gate legs, 35 pages byte-identical, full test suite passing (651 runs, 7,045 assertions, 0 failures).

Fulfilling the fourth and final movement of Roadmap 0.6:
1. **Repository Hygiene & Historical Archives**:
   - Created `history/daytrips/` and stowed all 34 past daytrips (`DAYTRIP-0.2.6a.md` through `DAYTRIP-0.6.0f.md`, plus prototype `DAYTRIP.md`) out of the root working tree.
   - Created `history/planning/` and stowed past closed roadmaps and planning scratch files (`ROADMAP-0.2.md`, `ROADMAP-0.3.md`, `ROADMAP-0.4.md`, `ROADMAP-0.5.md`, `BLUESKY.md`, `COMMUNITY_BULLETIN_BOARD.md`, `DEMAND.md`, `Tight Coupling in Ruby DSLs.md`, `spiff_discussion.md`).
   - Root directory now retains only 14 active, living files (`CONTRACT.md`, `CONVENTIONS.md`, `DAYTRIP-0.6.0g.md`, `DESIGN.md`, `HANDOFF.md`, `KERNEL.md`, `LORE.md`, `PRIMER.md`, `PROJECT.md`, `README.md`, `ROADMAP-0.6.md`, `VOCABULARY.md`, `WISHLIST.md`, `working-with-dan.md`).
   - Updated `StudioDocs::DOCUMENTS` mapping in `studio/docs_helper.rb` to serve guides from their new paths (`history/daytrips/DAYTRIP.md`, `history/planning/...`), preserving all `/guide/:name` routes without breakages.
   - Updated `test/markdown_test.rb` and `check_grammar.rb` paths.
   - Updated `DocReader::Shelf.of` in `examples/doc_reader/lib/shelf.rb` to discover nested documents under `history/**/*.md`, keeping the document shelf complete and categorized.
2. **Example App Garden Audit**:
   - Formally audited all eight applications across the garden:
     - **`examples/portfolio`** (2 pages: `index.sp`, `account.sp`): Investment portfolio showing accounts, holdings, and transactions. Demonstrates domain-specific app words (`account_card`) alongside canonical vocabulary. **Recommendation: Keep.** High pedagogical value, compact.
     - **`examples/roth`** (2 pages: `controls.sp`, `partials/report.sp`): Flagship retirement projection tool with interactive multi-bracket tax simulations. Showcases quantitative data visualization (`chart`, `band`, `line`, `level`) and dense forms. **Recommendation: Keep.** Crucial visual testbed.
     - **`examples/dashboard`** (5 pages: `triage.sp`, `confirm_archive.sp`, `brief.sp`, `doc.sp`, `pattern.sp`): Ecosystem dashboard interface mirroring developer triage and project briefs. **Recommendation: Keep.** Core dogfood application.
     - **`examples/lore_reader`** (2 pages: `index.sp`, `entry.sp`): Timeline browser for repository lore entries grouped by author. **Recommendation: Keep.** Clean, authentic repository consumer.
     - **`examples/doc_reader`** (5 pages: `index.sp`, `shelf.sp`, `audiences.sp`, `document.sp`, `search.sp`): Markdown document shelf with audience filtering (`users`, `devs`, `history`) and query search. Custom Spiff styling (`doc_reader.spiff`). **Recommendation: Keep.** Flagship reader.
     - **`examples/milestone_planner`** (2 pages: `index.sp`, `milestone.sp`): Milestone and task management app with status pills and progress cards. **Recommendation: Keep.** Modern idiomatic `.sp`.
     - **`examples/way_exam`** (2 pages: `index.sp`, `results.sp`): Interactive 5-question exam testing understanding of the one-sentence grammar and register. Uses radio options and form submission. Lightweight (60 lines in `app.rb`). **Recommendation: Keep and modernize.** Update question text to reflect 0.6 conventions (7 taxonomy terms, universal slot model) rather than retiring.
     - **`examples/word_graph`** (4 pages: `index.sp`, `word.sp`, `shapes.sp`, `matrix.sp`): Deep introspective explorer mapping all 64 canonical words, relationships, peers, shapes, and compatibility matrix. **Recommendation: Keep.** Invaluable architectural verification surface.
3. **Verification**:
   - All 12 Studio gate legs green (`ok`).
   - 35 pages verified byte-identical.
   - `check_ruby.rb` (133 files), `check_vitals.rb` (40 claims), `check_grammar.rb` (1,351 sentences) all pass with 0 problems.
