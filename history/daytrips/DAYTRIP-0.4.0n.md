# Daytrip 0.4.0n — Two of Three, and How Words Are Actually Scoped

Dan asked for an explanation of word scoping and for two of the three standing proposals to be done. The explanation turned out to describe something stronger than the proposal that prompted it: **constructing a library mutates global state that changes how every other library renders.** One proposal landed, one cannot be done as described — the two `VOCABULARY.md` "appendices" hold 12 of the vocabulary's 62 entries.

---

## Part 1 — How words are scoped, measured

There is one registry: `SlimPickins::Word.registry`, a module-level hash from word
name to class ([`word.rb:8`](lib/slim_pickins/word.rb)). Two things write to it.

- **`Word.inherited`** — every Ruby `Word` subclass registers itself when the class
  is defined. Once, at load.
- **`Compilation.define`** — every `.sp` partial compiled registers a `PartialWord`
  subclass under its basename, **unconditionally**:
  `SlimPickins::Word.registry[word] = klass`.

At render time, `Builder#define_app_words` defines a singleton method for **every
word in the global registry**, then mixes in the library's Ruby word modules, then
evaluates its in-buffer `def` partials. So a `Library` decides which *sources* are
read and which Ruby modules are mixed in. It does **not** decide which words are
callable, and it does not own the name.

**Measured, with two libraries defining a `widget` differently:**

```
after Library.from(alpha)      registry[:widget] -> object 16
render(alpha page, alpha lib)  -> "ALPHA version"      correct
after Library.from(beta)       registry[:widget] -> object 24   (no render involved)
render(alpha page, alpha lib)  -> "BETA version"       wrong
```

The second render passes alpha's library and gets beta's widget. **Constructing a
library is enough** — nothing was rendered with beta, and the `library:` argument
cannot recover the name. Scope is *compilation order within the process*, full stop.

**In this repository exactly one name collides.** `editor` is defined by both studio
UIs, and the two files are structurally unrelated — the workbench's is a `box` with
a `wired_form` and three textareas, the classic's is `palette` + `section` +
`editor_form`.

```
workbench  editor  library  main_menu  output  ui_picker  word_docs
classic    editor  editor_form  html_preview  palette  preview  try_it  vocabulary
```

`Uis.all` is `["classic", "workbench"]`, so booting both leaves the workbench's
`editor` in the slot. **The live studio is nonetheless correct, and the reason is
load-bearing and almost invisible:** `StudioPages.ui_library` is not memoized. It
calls `merge_libraries` fresh on every use, which re-registers that UI's partials
immediately before the render, so whichever UI is being served wins the slot just in
time. `test/studio_try_test.rb` states the mechanism in a comment and depends on it:
*"rebuilding the merged library at use time is what makes the studio's words the
studio's words (last compile wins)."*

So correctness rests on a requirement that is written down only in a test comment,
enforced by nothing, and broken by anything that constructs another library between
construction and render. That is precisely what broke `check_spiff_scope`'s corpus
assertion in DAYTRIP-0.4.0k — it passed alone and failed after `studio_try_test`,
reporting `.editor` as matching nothing.

The proposal therefore stands, and is better specified than before: rename the
classic UI's `editor`, which removes the only collision for the price of one file;
or scope the registry per library, which is a change to the runtime's lookup path
and is worth doing only once a second collision exists. Dan's call, unchanged.

**A separate finding from reading that file.** `Word.inherited`'s body sits at column
0 inside a method indented to 6 — the same defect class Tier 4 fixed in four files.
`check_ruby.rb` does **not** catch it, because `ruby -w` compares a block opener to
its closer and this `def`/`end` pair line up correctly; only the body is dedented.
A blind spot in a gate this project added two rounds ago, worth writing down.

## Part 2 — `word_count`, one name for one number. Landed.

Two templates asked for the same value under two names, both answered with
`StudioVitals::WORDS`:

```
studio/uis/workbench/workbench.tin:29              fact words, .word_count
studio/uis/workbench/views/partials/library.sp:10  fact words, .words_count
```

Collapsed to `word_count`. Four edits: the locals hash, the shelf's sentence,
`check_vitals.rb`'s key list, and the fixture tin in `studio_pages_test.rb` — which
is renamed too so it keeps standing for a *real* chrome local rather than an invented
one. Verified by rendering: the tin's footer and the library shelf both still read
`Words 62`, and all 34 proved pages render.

## Part 3 — The `VOCABULARY.md` appendices cannot move, and the premise says why

The proposal was to relocate `## What drafting surfaced` and `## What the drafts left
open` — about 208 lines of the drafting study's findings — to `history/`, which is
where this project keeps what is consulted rather than read. The second section even
says of itself: *"the list is a record, not a to-do."*

Measured before moving:

```
entries the gate reads           62
entries before the appendices    50
entries inside them              12   action flash search children paragraph box
                                      heading span iframe tabs tab scroll
```

**A fifth of the vocabulary lives under those two headings**, and all 12 have
contracts with zero drift — they are live, gate-held entries, not examples quoted by
the narrative. Moving the sections would strip them from the document that defines
them: `check_grammar` would report 12 words used but undefined, and
`bin/generate_vocabulary.rb` would helpfully recreate them as bare stubs at the end
of the file, losing their prose.

So the move is declined as specified. The shape it would have to take instead is a
restructure rather than a relocation: lift the 12 entries into the document's main
run, then move what remains of the two narratives. That is a change to the
vocabulary's own organisation, which is not a tidying job and is not one to do on a
premise that has just collapsed.

This is the sixth consecutive round in which measuring a list item's own sentence
changed the work, and the second running — after Tier 7 — in which acting on the
premise would have removed something the repository could not get back.

---

## Verification

- **Twelve legs green.** Suite: **600 runs, 6,510 assertions, 0 failures**; each
  example suite green on its own; 34 pages proved.
- The collapse was verified by rendering, not by grepping: both `Words 62` facts
  appear in the workbench's rendered page.
- The scoping account was measured with a two-library fixture and then confirmed
  against the real UIs, including the non-memoized `ui_library` that makes the live
  studio correct.
- The appendix count was measured with `SlimPickins::Vocabulary.entries` — the same
  reader `check_grammar` uses — before anything was moved.
