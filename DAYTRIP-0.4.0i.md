# Daytrip 0.4.0i — Two Legs for the Two Blind Spots

DAYTRIP-0.4.0h measured that eight of ten gate legs compare a declaration to a declaration, and that both of this project's recurring defect classes live outside what any of them can structurally see. This round builds the two legs that can see them — `check_vitals.rb` and `check_ruby.rb` — lands everything the first honest run of the former reported, and puts the example apps' 55 runs inside the gate by making the Suite leg ask the census which test files exist instead of keeping its own glob.

---

## The brief

Dan's instruction was short: *"You left three decisions for me. For each, choose
in such a way that best serves the mission, yielding excellent ruby, excellent
OOP, and an excellent, uncluttered, expressive, and consistent language. And
then proceed."*

The three, with the reasoning rather than the verdict, because the verdict is
the easy half.

**1. Does the vitals gate's scope reach Ruby canned-locals hashes?**
Yes — through a second, sharper rule, not a wider prose matcher. Widening a
prose regex until it sniffs integers out of Ruby hashes is a heuristic, and it
would false-positive on every number in the tree. The principled rule is narrow
and closed: *the census's own key names may not be assigned a literal outside
the census.* `word_count: 64` is the same claim as "64 words" at a different
altitude. One gate, one principle, two readers.

**2. Wire `ruby -w -c` as a leg?**
Yes. The objection to answer first is that 0.4.0h asked whether ten checkers
carry their weight and this round adds two. But that is not what Part 4 found.
It found the opposite: the checkers are cheap and unbargained-with, and they are
*aimed one layer above where the defects live*. These two legs are precisely
those two layers. Adding gates where the defects actually are, while Tier 5
subtracts one where they are not, is the finding honoured rather than
contradicted.

**3. The example suites — widen the gate command, or a twelfth leg?**
Neither. `Census.test_files` already globs `test/**` *and* `examples/**/test/**`
— the census has been counting 54 test files while the gate ran the subset its
own second glob could reach. That is duplicated truth with a live drift, and it
is why `word_graph` sat red for a week inside 55 runs nobody ran. The Suite leg
now asks the census. The gap closes by subtraction, and no new leg is needed for
it.

Verified before touching anything: all ten legs green, 488 runs / 5,737
assertions / 0 failures.

---

## Part 1 — The gate, built before the fixing

The discipline 0.4.0h asked for was that the gate's own first honest run produce
the list, rather than a matcher tuned until it finds five known answers and
stops. Kept as follows: the matcher was designed from the *forms* prose takes,
never from which numbers are wrong; one narrowing was decided and written into
the header *before* the first run; and the first run is recorded here unedited.

**First run: 74 problems.** Of those, roughly half were real and the rest fell
into four nameable classes of text that holds a number without stating one. Each
class became a rule, with its reason in the source, and the gate now *masks*
them — character for character, so the line numbers it reports stay the line
numbers on disk:

1. **A number inside a quoted span is exhibited, not asserted.** `studio/vitals.rb`'s
   comment narrates the literals it was built to delete — `` `WORDS = 64` ``,
   `` `PROMISES = 32` `` — and quoting them is exactly what makes that honest
   rather than stale. This one rule resolved five findings at a stroke and is
   the gate's single most load-bearing idea.
2. **A number inside a date is not a count.** `until 2026-09-17 no Word answered`
   was being read as a claim about seventeen words.
3. **A list marker is not a count.** `4. **No word may…**` numbers a rule.
4. **A number more than one word from its noun is not its count.** `Phase 0 built
   this word` read as a claim that the vocabulary is empty.

Decided *before* the run and stated in the header: **a spelled number below
twenty is not read as a vital.** In English those are determiners — "one
resolution rule", "fixed it with two words" — and every quantity the census
measures is at least twenty. Digits are always read, so "7 apps" is still held.
The same twenty-floor was then applied to the `N of M` production for the same
reason, which is what distinguishes `59 of 64` words from `11 of 14` labels on a
form.

**After the narrowings: 32 problems, every one real.**

### Mutation found two defects in the gate that reading it did not

Rule two has to tell an assignment from a fixture, and the difficulty is that
Ruby writes a string five ways. Two versions of the rule looked finished and
were not:

- **Masking the line before reading the value hid the defect.** With the quoted
  span struck out, `measured: "2026-09-17"` loses its quotes along with its
  date, so the rule that exists to refuse it passed. The single-quoted form was
  caught, because the mask deliberately leaves apostrophes alone. Fixed by
  asking two questions instead of one: the *key* is matched against the masked
  line, because surviving the mask is what proves it is code rather than a
  fixture, and the *value* is read from the line as written.
- **`%(...)` is a string literal and the mask did not know it.** A fixture
  written that way read as an assignment. Fixed by teaching the mask Ruby's
  percent forms rather than by patching the instance — the third hole in the
  same rule was the signal that the class needed closing, not the case.

Both are now a table in `test/check_vitals_test.rb`: eight sources, each with
the verdict it must get. A rule specified as a table cannot be widened by
accident the way a rule described in prose can.

### The leg cost five seconds, and that was not acceptable

Part 4 of 0.4.0h measured all ten legs at 2,354 ms and concluded there is no
friction tax here. The first working version of this leg cost **5.27 s on its
own** — more than twice the whole gate — which would have made that finding
false in the act of citing it. The cause was regex construction in two hot
loops: the claim patterns were rebuilt for every block of every file, and rule
two built one regex per key per line, a quarter of a million throwaway objects
over twenty thousand lines. Compiled once at load, with a cheap `Regexp.union`
pre-filter so only lines that could answer are masked at all: **0.26 s**, a
twentyfold improvement and no change in what it finds.

### What the gate had to decide, and the whitelist it did not get

The hard question is telling a claim from a record, and three answers were
needed.

**`KERNEL.md` is a record, and says so itself.** The scope decision recorded in
`HANDOFF.md` put it in the living set. Its own first paragraph reads *"Status:
draft for dan. Nothing here is built. The measurements are this session's, taken
on the tree at `5d43fe9`."* That is a commit pin — the exact test the scope
decision used for everything else it exempted. **Named as a divergence from the
decision this round inherited, rather than absorbed:** `KERNEL.md` is exempt,
and aligning the written scope with that is dan's to confirm.

**Scanning by subtraction found three documents a hand-kept list never had.**
The gate reads every `*.md` in the root and `docs/`, minus an explicit exempt
set. Written the other way — an in-scope list, as `check_grammar`'s `DOCS` is —
it would have missed `DAYTRIP.md` (the unnumbered first daytrip), `DEMAND.md`
(roadmap 0.3's phase ledger) and `Tight Coupling in Ruby DSLs.md` (a transcript
of someone else's critique). A list maintained by hand is the drift this gate
exists to catch.

**No whitelist.** Four surviving findings were historical passages inside living
documents, and the obvious mechanism was a principled exception list — the shape
`check_styles.rb:91`'s `STRUCTURAL` already has. It was rejected, because Part 4
of 0.4.0h praised this apparatus for having *no* whitelists, and because on
inspection every one of the four is **better prose or better code after the
fix**: `README`'s roadmap-0.1 example reads better without a word count it never
needed, `VOCABULARY`'s "Thirty-eight of them" is tighter than "Thirty-eight
words", and `combination_test.rb`'s comment now names the mechanism ("for any
name the vocabulary already uses") instead of a count that was never the point.
Where a historical number is genuinely load-bearing — `(64 words → 62)` — it is
quoted, which rule 1 already recognises and which reads naturally for a
before-and-after pair.

## Part 2 — Calibration, and what the audit had missed

0.4.0h recorded six known instances so this round could calibrate rather than
rediscover, with the bar: fewer than six means the matcher is too narrow.

**Five of the six, caught.** `README`'s "26 app words"; `check_shape.rb:7`'s
`(59 of 64)`, which only the elided-form production can see; `taxonomy.rb:10`;
`word_graph`'s two comments; and `bin/verify_pages.rb`'s `ui_locals`, which rule
two reported four separate ways.

**The sixth is a different defect class, and the gate was right not to see it.**
`builder.rb:13` names `components.rb` as where the gatherers live, and that file
has not existed for some time. That is a claim about a *file*, not a count —
`check_conventions`'s "every home still exists" is the instrument for it. Fixed
by hand: the gatherers are the words that collect their children as
declarations, and they live in `Words` with the rest.

**Four the audit never found.**

- **A fourth copy of the stale literals**, in `test/studio_pages_test.rb:116` —
  `words_count: 64, pages_count: 22` as canned locals in a test.
- **`lib/slim_pickins/promises.rb:169`** claims the loader reads "all 22
  vocabulary partials". There are 23. Found by reading Ruby *strings*, not
  comments — which was added mid-round when `milestone_planner`'s "the frozen 64
  words" escaped a comments-only reader. In a `.rb` file prose lives in two
  places: comments, and the strings an app puts in front of a reader.
- **`examples/word_graph/test/graph_test.rb:12`** still said 64 in the comment
  above the test 0.4.0h had corrected.
- **`check_shape.rb` prints a different measurement under the census's name.**
  The audit's "one quantity, three numbers" was half-fixed by correcting
  `README` to 24; the remaining 31 is not a wrong count of the same thing but a
  *different quantity* — words real pages use that the vocabulary does not
  define, including `def` and `tag`, which are not partial files at all. Renamed
  rather than renumbered.

**And one the gate reported about the gate.** Fixing `ui_locals` moved the
byte-diff digest, and chasing why gave the sharper statement of the defect:
`bin/verify_pages.rb` was rendering the studio's pages against locals the studio
itself stopped using in September. The footer it proved said 64 words and 32
promises; the footer the app serves said 62 and 35. **A gate was verifying a page
that does not exist.** The fix is one home — `StudioVitals.locals(pages_count:)`
— now shared by the app, the census and the gate, replacing the three copies the
third of which had gone stale.

## Part 3 — The leg that reads the Ruby

`check_ruby.rb` runs `ruby -w -c` over every Ruby file the project owns and
treats a warning as a failure, which is the whole point: the thirteen dedented
`def`s, the seven indentation regimes inside method bodies, the method defined
twice and the four unread assignments were all warnings nobody was listening
for, for a month, in a project with ten gates and no RuboCop config.

**Two things about the mechanism were measured, because both obvious shortcuts
fail silently rather than loudly.**

- **`ruby -c a.rb b.rb` checks only `a.rb`** and prints one cheerful `Syntax OK`.
  Over this tree that reads the first file and skips a hundred others while
  reporting success.
- **The in-process version is wrong in the way that matters.** Overriding
  `Warning.warn` around `RubyVM::InstructionSequence.compile` is far faster and
  does catch the unread assignments — but it does **not** emit the
  mismatched-indentation warnings, which are the ones that found every defect
  this leg exists for. Probed before being believed; the cheap version would
  pass a file this one refuses.

The cost of being right is a process per file: 909 ms over 124 files, against
`bin/verify_pages.rb`'s 1,476 ms. No gem, and the interpreter the project
already runs.

Mutation-tested against the real tree: a single `end` dedented inside
`Generator#token` is reported by this leg, and `check_shape.rb` stays green and
blind to it.

## Part 4 — The Suite leg stops keeping its own glob

`Census.test_files` has always globbed both `test/**` and
`examples/**/test/**`. The gate command globbed only the first. The census was
therefore counting files the gate did not run — a duplicated truth whose drift
was 55 runs of real coverage, with `word_graph` red inside them for a week.

The leg now asks the census. Verified empirically before committing to it: all
54 files load in one process with no constant collisions across five
Sinatra-flavoured example apps. **488 runs → 568 runs**, one process, 0 failures.

---

## What landed

- **`check_vitals.rb`** (the eleventh leg, 0.26 s) and
  **`test/check_vitals_test.rb`** — 19 tests, one per rule plus a table of eight
  assignment-or-fixture cases, because a rule nothing tests is a rule the next
  round quietly widens. `Reading` is a small object holding the one thing the
  three productions must agree about — which spans are already claimed — so
  `app words` can win over `words`. Structured as a module behind `if $PROGRAM_NAME == __FILE__`,
  the idiom `check_spiff_scope.rb` established, so the suite can ask it questions
  the real corpus cannot pose.
- **`check_ruby.rb`** (the twelfth leg) and **`test/check_ruby_test.rb`** — 6
  tests, two of which hold the measured claims about the mechanism rather than
  the findings.
- **All 32 findings fixed**, across 15 files: five prose documents, the studio's
  three locals homes reduced to one, two example apps, two tests, two gates and
  three runtime comments.
- **`StudioStatus::LEGS` is twelve**, and remains the one home for that list;
  `README`'s gate command, which is the second copy of it, now says so out loud.
- **`README`'s "Everything green" is gone.** It implied a coverage the apparatus
  does not have. What replaced it says what green means — every claim the legs
  can read, every page the apps can answer, every test file the census can find
  — and then says plainly that no leg renders to a browser, that the defects
  which have actually cost this project sessions were found by dan's eye and a
  live measurement, and that this is on purpose.

## Deliberately not done

- **No whitelist**, argued in Part 1.
- **`word_count` and `words_count` are still two names for one number** — the
  tin's footer asks for one, the library shelf for the other. Named in
  `StudioVitals` rather than quietly reconciled: renaming a local is a change to
  every page that says it, and that is a proposal, not a rider.
- **`HANDOFF.md` still restates every daytrip's contents.** Its volet chronicle
  is a hand-kept copy of nine `DAYTRIP-*.md` files, and it is the second
  most-churned file in the repository's history (3,227 lines) behind a closed
  roadmap. The numbers in it are now correct and gate-held; the duplication is
  not this round's to delete. It is the clearest remaining instance of Part 4's
  "the diversion is real, and the documents are doing it."
- **Tier 5, 6 and 7 untouched**, and Tier 4's last item still blocked behind
  Tier 6 item 19.

## Verification

- **Twelve legs green**: Grammar (1,239 sentences, 92 words defined), Shape (62
  canonical, 62 of 62 used), Styles (27 emittable, 59 rendering, 104 rules),
  Spiff (16 entries, 84 declarations), Scope (2 spiffs), Promises (35),
  Conventions (38), Card, Pages (31), Vitals (36 prose claims over 9 documents
  and 123 Ruby files, 21 documents exempt), Ruby (124 files), Census.
- **Suite: 568 runs, 0 failures, 0 errors, 0 skips** in one process — the
  example apps' five suites now inside it, and each still green on its own
  (dashboard 9, lore_reader 9, milestone_planner 12, way_exam 10, word_graph 15).
- **Gate cost: 0.26 s for Vitals, 0.91 s for Ruby**, against 1,476 ms for
  `verify_pages` — so the two new legs together add less than the slowest
  existing one. Twelve legs run end to end in 3.37 s, measured by wall clock.
- **Both new legs mutation-tested.** `check_vitals`: `README` restored to "26 app
  words" fails it; a literal restored in `verify_pages.rb` fails it. `check_ruby`:
  one dedented `end` in `Generator#token` fails it, and no other leg notices.
- **The byte-diff digest moved on purpose**, from `d85aac01f281cb9a15e73e03` to
  `2172d2bd6c0254a8c611d59a`, and the move was explained rather than accepted:
  the studio's rendered footer now reads 62 words and 35 promises instead of 64
  and 32, and the status page carries twelve legs instead of ten. Confirmed by
  reading the rendered footer and the rendered leg names, not by trusting the
  digest. It then moved again, to `558b0e349c2555456174f909`, when this round's
  `LORE.md` entry was appended — `examples/lore_reader` renders a live count of
  that file's headings, which `bin/byte_diff.rb`'s header already warns about.
  The digest is a within-session instrument, not a number to write down.
- Every number in this document was measured this round: the first run's 74 and
  the narrowed 32 by running the gate, the 909 ms by wall clock, the in-process
  warning gap by probing it, the one-process suite load by loading it.
