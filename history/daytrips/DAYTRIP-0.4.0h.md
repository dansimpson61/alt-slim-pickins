# Daytrip 0.4.0h — The Backward Eye: What the Gates Cannot See

An audit daytrip. Dan asked for a critique of the project on its own terms, then asked the sharper question behind it: are the ten checkers carrying their weight, or diverting attention from where it belongs? The answer is measured rather than argued, and it inverts the expected finding — the checkers are the cheapest honest part of the project, aimed one layer above where its defects actually live, and the attention they are accused of diverting was taken by the corpus they guard.

---

## The brief

`PROJECT.md`'s `next_step` going in named two things awaiting dan's word (the
workbench word page's proportions, and the unserved `assets/workbench.css`)
and otherwise no active thread. Dan asked instead for the backward eye: read
the Ode, study the codebase, critique it on its own terms. Then, before any
fix list: do the checkers earn their keep?

This daytrip takes no ground the language did not already hold. It leads with
the backward eye, which is an even roadmap's move — recorded here because 0.4
runs as daytrips and the eye still has to be named.

---

## Part 1 — The baseline, and one real defect

All ten gates green. **The suite was already red** and had been before this
session touched anything:

```
CheckSpiffScopeTest#test_an_empty_corpus_is_refused_rather_than_passed:
Errno::EACCES: Permission denied - readdir
    check_spiff_scope.rb:90:in 'Dir.[]'
```

Not a sandbox artifact — it reproduces unsandboxed. `SpiffScope.app_root`
walks up from a `.spiff` looking for an app root and, finding none, returns
the last directory it saw, which for a spiff outside an app is `/`.
`renderable_names("/")` then globs the entire filesystem. Measured:

```
spiff:     /tmp/empty20261002-3156729-845zsq/nothing.spiff
app_root:  "/"
```

`LORE.md` (2026-09-27) already records that this gate's own first run was a
false pass "because `app_root` walked to the filesystem root and compared
nothing to nothing." The false pass was fixed; the walk was not. The real
corpus never reaches it — every `.spiff` lives inside a real app dir — so the
gate stays green and only its own unit test tells the truth.

## Part 2 — Five false claims, none of which any gate can see

- **`examples/way_exam` grades the right answer wrong.** Question 5 asks how
  many words the vocabulary has, offers `53 / 102 / 64`, marks `64` correct,
  and explains "Exactly 64 words (42 Ruby classes + 22 .sp templates), held
  by test." The census says 62 (39 + 23). The true answer is not among the
  options, the breakdown is wrong in both terms, and `test/exam_test.rb:29`
  asserts `'q5' => '64 words'`, so the suite defends the error. An app whose
  purpose is to examine whether you know the Way fails itself.
- **No gate runs the example apps' suites, and one of them was red.** Found
  while fixing the above: five apps carry `test/` directories — dashboard,
  lore_reader, milestone_planner, way_exam, word_graph — and the gate command
  globs `test/**/*_test.rb` from the repo root, which reaches none of them.
  `examples/word_graph` had **2 failures**, asserting 64 words and 59 nouns —
  the same pair `check_shape.rb`'s header carries — and had been failing
  silently since the vocabulary came down to 62. That is 55 runs of real
  coverage outside the gate, and it is why "held by test" in the exam's own
  explanation was false twice over: wrong number, unrun test.
- **A gate contradicts itself in its own header.** `check_shape.rb:7` says
  "the language is a noun language (59 of 64)". Three lines of code later the
  same script prints `words: 62 — 57 nouns`. The 2026-09-26 truth round
  hunted exactly this number through PRIMER, ROADMAP-0.3, two daytrips and
  `conventions.rb`, and missed the top of a file that runs every gate pass.
- **One quantity, three numbers.** `README.md:187` opens "Living vitals are
  computed directly from the repository tree by `SlimPickins::Census`" and
  then states `26 app words`. The census says 24. `check_shape.rb` says 31.
  The sentence names its own source of truth and contradicts it in the same
  breath. `HANDOFF.md` has it right.
- **`KERNEL.md`'s strongest claim is now false in every particular.** It says
  "Measured, and the fit is exact" and pins it to `words.rb 183, 209, 290,
  303, 313, 330; components.rb 201`. Not one of those lines says
  `subject.fetch` today; two are blank. `components.rb` does not exist and
  has not for some time — it is also still named in `builder.rb:13`'s class
  comment as where the gatherers live. Line numbers as evidence is a citation
  style that cannot survive a refactor.
- **`taxonomy.rb:10`** still says "64-word list"; `word_graph` says "all 64
  words"; `milestone_planner` says "frozen 64 words".

## Part 3 — The shape of the Ruby, which nothing watches

- **Thirteen `def`s sit at column 0** while every sibling sits at 4 or 6 —
  `generator.rb` 7 (including `initialize`), `words.rb` 4, `builder.rb` 1,
  `word.rb` 1. They date to 2026-09-04 and 09-05. In the month since, the
  project added five gates, a compiler, a council skill, a naming round and a
  truth round, and never looked at the shape of its own core. There is no
  RuboCop config and no gate that reads the Ruby as text.
- **`def chain = @chain` is defined twice** in `Builder`, at 152 and 290.
  Ruby takes the second silently.
- **The most-travelled datum in the system is anonymous.** The project reaches
  for `Struct` seven times — `Sentence`, the parse `Node`, `Contract`,
  `Violation`, `Promise`, `Convention`, `Entry` — and the *semantic* node,
  which every docstring names as the thing the runtime is built around, is a
  bare three-element Array read positionally in `builder.rb`, `generator.rb`,
  `partial_word.rb` and `studio/inspector.rb`. The Ode's remedy is already
  house idiom everywhere else.

  **Correction, made while sizing the fix (2026-10-02).** This bullet first said
  the anonymous triple "forces most of the 60 `is_a?` tests in `lib/`". That was
  wrong, and wrong in this round's own characteristic way — a number counted at
  the wrong altitude and then spent as an argument, which is the same error the
  truth round made when it counted inline code spans as raw HTML. Measured:
  `is_a?(Array)` in `lib/` is **7**, of which about six are node-vs-string
  guards. The 60 are dominated by `Symbol` (15), `String` (9), `Proc` (6) and
  `Hash` (6) — argument discrimination in the DSL's own calling convention,
  which a node refactor does not touch. Real scope is **20 read sites and 29
  construction sites**; the payoff is one good name plus those six guards. Still
  worth doing under *give traveling data a name*, and no longer the slam dunk
  this bullet claimed.
- **The showcase does not speak the language.** `studio/inspector.rb:17` is a
  255-line method that is mostly one HTML heredoc: 39 raw tags, 37 hardcoded
  hex colours, and `100vh` twice — the unit 0.4.0g retired. `check_styles.rb`
  reads `lib/**/*.rb` but not `studio/*.rb`, so none of it is visible to the
  gate that exists to keep presentation in the theme's roles.

## Part 4 — Do the checkers carry their weight?

**Yes, and almost none should be cut.** The cost case against them does not
survive measurement:

- **2,354 ms for all ten legs.** `bin/verify_pages.rb` is 1,476 of it; the
  other nine average 97 ms. The full suite is 2,791 ms. There is no friction
  tax here.
- **1,460 lines of checker script** against 4,877 lines of runtime `lib/`.
  Their tests are 921 lines, 15% of the suite.
- **No whitelists.** The decay signature — `KNOWN_FAILURES`, skip lists,
  pending markers — is absent. One principled exception exists in the whole
  apparatus: `check_styles.rb:91`, `STRUCTURAL = %w[0 1 2 3 100%]`. These
  gates have not been bargained with.
- **They get verified by mutation**, which most projects never do once.
- **Seven of ten have a recorded catch.** `check_spiff_scope` has none that
  this audit could find; `bin/census.rb` gates nothing.

**But eight of ten compare a declaration to a declaration.** Only
`verify_pages` renders; only `check_styles` partly does. Set that against the
defects that have actually cost sessions — the `.panes` dissolution, container
queries that had never worked since the compiler's first commit, three shell
columns at three heights, a `.footer` rule styling nothing because the element
was a `.foot`, textareas at 384px in a 622px container. `LORE.md` says it
plainly: "no gate renders, so the only instrument that caught this was a
browser measuring rectangles." And for the second class, the 2026-09-26
lesson: "a document that lists a number is not a document that measures it...
all three passed while they were wrong."

Both recurring defect classes live outside what eight of ten gates can
structurally see. The gates are not failing; they are watching the one layer
that stays correct on its own.

**Four of them are a tax on duplicated truth.** The clean case:
`bin/generate_vocabulary.rb` generates five bullets of every `VOCABULARY.md`
entry from `contracts.rb`, and `check_grammar.rb`'s whole `UNGENERATED`
section then verifies the committed artifact still matches its generator.
Same shape in `check_spiff` (the lexicon holds copies of compiler output),
`check_conventions` and `check_promises` (hand-written registers restating
what the code does). The Ode's answer to two copies of one truth is not a
checker; it is one home.

**The diversion is real, and the documents are doing it.** The checkers are
1,460 lines. The corpus they police is 12,605 lines of root prose across 28
files. Over the project's whole history:

```
markdown churned:  40,082 lines
ruby churned:      33,153 lines
```

Top churned files, all history: `ROADMAP-0.2.md` (3,462) and `HANDOFF.md`
(3,227) — a closed roadmap and a resume prompt — both ahead of `builder.rb`
(2,922), the heart of the runtime. Seven of the top ten are markdown. The
gates also arrived in clusters: four in the first four days, then three on
2026-09-17 and two on 2026-09-27 — rounds deciding to add gates, not defect
classes demanding them.

The resume card is the same disease in the instrument built to stop it.
`status` is 11,145 chars / 1,773 words; `notes` another 9,052. Together longer
than `transform.rb`, `builder.rb` and `generator.rb` combined. The card exists
so a session can resume *instead of* reading the repo.
`bin/check_card.rb:90` prints `status 11145 chars` on every green run and has
no opinion about it.

---

## The prioritized list

**Tier 0 — clear the tree.** Commit the finished 2026-09-29 work (seven
files, ten gates green, the suite's only error unrelated). Dan's call.

**Tier 1 — correctness. Landed this session; see *What landed* below.**
1. `app_root` bounded, refusing rather than returning the last directory seen.
2. `way_exam` q5 and `word_graph`'s two red tests: read the census.
3. **New** — an eleventh leg, or a widening of the gate command, so the five
   example suites are run. A test nobody runs is not a net; it is a claim.

**Tier 2 — the gate, before the corrections.** An eleventh leg holding living
prose and code comments to `Census.snapshot`. Built *first*, so its own first
honest run produces the list rather than this audit's five. Scope is the
design question: living documents and `*.rb` comments and the example apps'
answer keys are in; the dated record — `LORE.md`, `history/`, `ROADMAP-*`,
`DAYTRIP-*`, `BLUESKY.md`, `spiff_discussion.md` — is exempt, because an entry
that quoted the number true when written is not lying. Neither
`check_grammar`'s `DOCS` nor the studio's `GUIDES` draws that line yet.

**Tier 3 — what the gate reports.** The five of Part 2, plus `README`'s
"Everything green", which implies a coverage the apparatus does not have.
`KERNEL.md` is fixed by changing the citation *style* to method names — not by
re-measuring line numbers, which buys one round.

**A sixth, found while landing Tier 1 and absent from Part 2**:
`bin/verify_pages.rb`'s `ui_locals` still passes `word_count: 64,
promise_count: 32, measured: '2026-09-17'` as canned locals — a third copy of
the literals the studio removed from its own two homes, sitting inside the gate
itself. It is a Ruby hash rather than prose, so the gate's scope has to decide
explicitly whether it reaches there.

**Tier 4 — the shape of the Ruby. Landed, except its last item.** The thirteen
dedented `def`s; then seven *more* mismatches inside method bodies that a
`def`-line scan cannot see, found by `ruby -w -c`; the duplicate `chain`; two
dead comments; `about`'s guard restructured so nothing needs guarding; three
dead locals. Pointing `check_styles` at `studio/*.rb` is **blocked** — it goes
red on `studio/inspector.rb` and wants Tier 6 item 19 first.

**Tier 5 — retire duplication.** Stop committing a generated `VOCABULARY.md`;
delete or retarget `check_spiff_scope`. Both subtract.

**Tier 6 — two real refactors, resequenced: 19 before 18.** Rewriting the
Inspect surface in the language it inspects *deletes* 3 of the 20 node-read
sites item 18 would otherwise touch, and unblocks Tier 4's last item. Then
`Data.define` for the semantic node, at the corrected scope above.

**Tier 7 — the corpus.** Card surgery, and give `check_card` an opinion.

## Deliberately not doing

- **Not cutting the gates.** They are cheap, unbargained-with, and
  mutation-verified. Removing them leaves the documents unpoliced without
  making them smaller.
- **Not building a pixel gate.** Headless-browser assertions are a dependency
  with opinions and a new corpus. Dan's eye plus a live measurement is the
  right instrument; the fix is for `README` to say so.
- **Not chasing the `is_a?` count.** Most is honest interpreter dispatch, and
  the node refactor removes the rest as a side effect.

## What landed

Two commits' worth, each verified by mutation before being believed.

**`check_spiff_scope.rb` — the walk is bounded.** `app_root` now takes a
required `within:`, walks only inside the tree the run was told to examine,
and returns `nil` rather than a directory when it finds no app; `run` reports
`NO APP` and moves on instead of globbing. Two predicates came out of the
three stacked `return`s (`app?`, `inside?`), and the `loop do` became a
`while inside?` with one boundary plus a termination guard that is reachable
only for `within: '/'` and says so.

Mutation told the truth here and changed the design. The first version kept
the old `return dir if parent == dir` as a second guard, and **restoring the
defect did not fail the tests** — with a ceiling in place that branch is
unreachable, so it was a dead guard dressed as a fix, exactly the smell this
daytrip criticises in `Builder#about`. Making `within:` required and the
boundary singular fixed that: removing the ceiling now fails 1 test, and
returning a directory instead of `nil` fails 3.

`test_an_empty_corpus_is_refused_rather_than_passed` was replaced rather than
repaired. Its assertion was `0 problems` for a Spiff belonging to no app —
the defect's output, recorded as the rule. It also conflated two questions,
which are now two tests, plus two for the walk's boundaries. The helper was
corrected too: every fixture test passed `root: ROOT` for a tree built under
`/tmp`, which was incoherent and only harmless while `root` was used for
nothing but the default glob and a display prefix.

**The vocabulary count is measured where it is graded.** `way_exam`'s q5
computes its correct option and its explanation from `Census` on load, with a
test asserting both that the option tracks the census and that no two options
say the same thing. `word_graph`'s two red tests now read the census for the
total and assert the noun split as the invariant it is — every word is a noun
or one of the control words — rather than re-pinning 57 and 5, which would
rot the same way 59 and 5 did.

Deliberately **not** fixed: `graph.rb`'s two "64 words" comments, and the
other prose claims in Tier 3. They are left standing as the first honest run
of the Tier 2 gate, which is the whole argument for building it before
correcting by hand.

## What landed, round two — Tier 4, on dan's reorder

**The shape of the Ruby, and a better instrument found halfway through.** The
first pass fixed the thirteen `def` lines at column 0. That scan was the wrong
instrument: it could only see dedented *signatures*, and `Generator#emit` turned
out to span four indentation regimes — body at 2, `case` at 6, `else` branch at
4, `ensure` and closing `end` at 0 — under a correctly-indented `def`.

`ruby -w -c` reports exactly that, in the interpreter the project already runs,
with no gem:

```
generator.rb:180: warning: mismatched indentations at 'ensure' with 'def' at 152
```

Seven more mismatches, all now gone: `Generator#emit` and `#token`, and the three
`Words` `evaluate` methods (`Table`, `Chart`, `Choose`) whose bodies sat at 2
under a `def` at 6, with two `private` keywords stranded at column 0. It also
found three dead assignments nothing else had — a `value, empty, body`
destructure using two of three, `check_spiff.rb`'s unread `compiler`, and
`verify_pages.rb`'s unread `studio`. `ruby -w -c` is now clean over `lib/`,
`studio/`, `bin/`, the checkers, the suite and the example apps' domain code.

So the audit's "no gate reads the Ruby as text, and there is no RuboCop config"
is half answerable with no dependency at all. Wiring it as a leg is left for dan,
because it changes the gate command, the README and the status page's leg count —
but the repo is clean against it today, which is the precondition.

**Three real defects came out with the whitespace**: `Builder#chain` defined
twice (152 and 290; Ruby took the second silently), a seven-line tombstone for
`render_partial` deleted in September, and a comment with no code under it. And
`about`'s `ensure @empty_active = was unless was.nil?` was restructured rather
than explained — the guard was protecting the `name.nil?` early return, where
`was` is an unassigned local and therefore nil, while reading as a check against
impossible state. A scoped `begin`/`ensure` means nothing needs guarding.

**The instrument got committed.** Every "byte-identical" claim in this round was
made by a harness built from scratch and thrown away. `bin/byte_diff.rb` keeps
it: all 31 pages the gate proves, reduced to one digest
(`d85aac01f281cb9a15e73e03` as of commit 74842bc — but see the note in that file: the digest moves when `LORE.md` does, so compare snapshots within a session rather than against a number written down). `bin/verify_pages.rb`'s execution now sits behind
`if $PROGRAM_NAME == __FILE__`, the idiom `check_spiff_scope.rb` already uses, so
`PAGES` can be required rather than copied.

**Tier 6 was assessed and declined, which is the honest outcome.** Sizing item 18
disproved the argument this document had made for it (see the correction in Part
3), and three of its twenty read sites live in `studio/inspector.rb`, which item
19 is going to delete — so 19 precedes 18, and Tier 4's last item follows both.
Item 19 is a design job that will surface vocabulary gaps needing dan's rulings;
doing it badly would be worse than not doing it.

## Verification

- **At audit time**: ten gates green; main suite 485 runs, 5,728 assertions, 0
  failures, **1 error** — the `app_root` defect above, pre-existing. Unmeasured
  and unknown at that point: `examples/word_graph`, 2 failures.
- **After Tier 1**: ten gates green; main suite **488 runs, 5,737 assertions, 0
  failures, 0 errors**; and all five example suites green — dashboard 9,
  lore_reader 9, milestone_planner 12, way_exam 10, word_graph 15.
- Each fix was mutation-tested: the defect reintroduced, the suite shown to
  fail, the fix restored. One mutation failed to fail and the design changed
  because of it, recorded above.
- **After Tier 4**: ten gates green; 488 runs, 0 failures; all five example suites
  green; `ruby -w -c` clean repo-wide; and all 31 pages **byte-for-byte identical**
  to the pre-Tier-4 corpus (`d85aac01f281cb9a15e73e03` as of commit 74842bc — but see the note in that file: the digest moves when `LORE.md` does, so compare snapshots within a session rather than against a number written down before and after every
  commit), which is what makes a pure-shape round provable rather than asserted.
- Every number in this document was measured this session, not recalled: gate
  timings by wall clock, churn by `git log --numstat`, card sizes by parsing
  the frontmatter, the dedented `def`s by grep, `app_root` by calling it.
- The language itself was exercised end to end (a `section`/`each`/`card`
  page rendered with two rows and with none) and works as documented —
  heading depth inferred from nesting, `id` from subject noun plus key,
  `empty` promoted or pruned by the situation.
