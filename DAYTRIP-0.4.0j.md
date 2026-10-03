# Daytrip 0.4.0j — Tier 5, and Both of Its Premises Were Wrong

DAYTRIP-0.4.0h's Tier 5 read: *"Retire duplication. Stop committing a generated `VOCABULARY.md`; delete or retarget `check_spiff_scope`. Both subtract."* Measured: the document is 72% prose and cannot stop being committed, the gate was worth retargeting rather than deleting, and **neither item subtracted a line**. The duplication was real in both cases and in neither place the audit pointed at.

---

## The brief

Dan's instruction was two words: *please proceed.* The list said Tier 5, so this
round is Tier 5 — and the first thing it did was check the list's own premises
before acting on them, which is the lesson of the round.

Verified before touching anything: twelve legs green, 568 runs / 0 failures.

---

## Part 1 — `VOCABULARY.md` is 72% prose, so it cannot stop being committed

The audit's Part 4 made a correct observation and drew the wrong conclusion from
it. The observation: `bin/generate_vocabulary.rb` writes the checkable bullets of
every entry from `contracts.rb`, and `check_grammar.rb`'s whole `UNGENERATED`
section exists to verify the committed artifact still matches its generator —
"a checker that exists because a truth has two homes is a tax on the
duplication, not a net under the code." The conclusion: stop committing it.

Measured instead of assumed:

```
VOCABULARY.md                1,226 lines
generated bullet lines         349   (28%)
```

The other 72% is per-entry prose, example sentences and the drafting history. No
generator can produce it, `README` names the file as one of five documents to
read, and the generated 28% is precisely the reference table a reader wants in
the document. **There is nothing here to stop committing.**

The duplication is real, and it is one level up: *the question* was asked in two
places. The splitting regex (`/^(### \`[a-z_]+\`)/`), the bullet lookup
(`/^- \*\*#{slot}\*\* —.*$/`) and the conventions comparison each existed once in
the generator and once in the gate, with the gate reporting what the generator
repairs. Two copies of a question answer it differently eventually.

`lib/slim_pickins/vocabulary.rb` is the one home. Its `Drift` struct names the
three cases that used to be implicit in nested conditionals, and that the two
callers handle differently on purpose: a bullet that disagrees, a bullet that is
`missing?` and the generator inserts after `subject`, and a conventions bullet
that is `unwanted?` because the word declares none and the generator deletes.

**The honest accounting, because the audit promised a subtraction:**

```
before   check_grammar 140  +  generate_vocabulary 63                  = 203 lines of code
after    check_grammar 131  +  generate_vocabulary 36  +  vocabulary 46 = 213
```

**It went up by ten.** The generator fell 63 → 36 (-43%), which is where the
clarity actually shows, and the module cost 46 to hold a question that is now
asked once. *DRY is about knowledge, not keystrokes* is the Ode's own phrasing and
is the defence — but "both subtract" was a claim, and this did not.

Verified by A/B against the committed gate rather than by reading: a bullet
hand-edited to a lie produces a byte-identical message from the old
`check_grammar.rb` and the new one. All three drift paths were then exercised in
turn — a bullet replaced, a conventions bullet deleted and reinserted after
`subject`, one invented for a word that declares none and removed — and after
each, `bin/generate_vocabulary.rb` restored `VOCABULARY.md` byte-identical. The
gate reports and the generator repairs the same finding, which is the pair
working as a unit and the only reason the arrangement is worth its ten lines.

## Part 2 — the scope gate was retargeted, and a measurement said where to aim

`check_spiff_scope.rb` was the one leg with no recorded catch, and its own header
said why: it compared a Spiff's *zone names* to the `.sp` sources in its
directory, "without data and without rendering". Declaration against
declaration, which is the shape of eight of the ten.

Two measurements decided delete-versus-retarget:

```
workbench.spiff   zone names the old check read      3   editor, library, output
                  classes the compiled CSS targets  11   + field, form, iframe, panes,
                                                          shell, tab-panel, tabs, tabs-content
```

**Eight of the eleven selectors the compiler emits were never checked at all**,
and `panes` and `shell` are among them — the two classes 0.4.0g's hardest
defects were about (the `.panes` dissolution, and the `sidebar_layout` → `shell`
rename). A gate reading a third of what its compiler emits is not a gate to
delete; it is a gate aimed at the wrong half.

So the question moved from *"does a file somewhere define this name?"* to *"does
this selector match anything the browser will be given?"* — which is the question
a compiled stylesheet actually raises. Every class the compiled CSS targets must
appear in the rendered HTML of a page the Spiff governs. **3 classes checked
became 13, and the right-hand side became rendered HTML.**

**The upgrade was proven, not asserted.** A fixture Spiff styling a `ghost` zone,
with `ghost` a real partial on disk that no page reaches:

```
old gate (name-based)    2 spiff(s) held to their pages, 0 problems
new gate (render-based)  compiles a selector for `.ghost`, and none of the 4 page(s)
                         it governs renders that class  —  1 problems
```

That is the `.footer`-rule-that-styled-nothing-because-the-element-was-a-`.foot`
defect, which `LORE.md` records as found by a browser because no gate could see
it. One can now.

`app_root`, its ceiling, `zone_names` and `renderable_names` are gone — about
forty lines and three methods — because scope is now simply the pages rendered at
or below the Spiff's own directory, and a `.spiff` either sits at its app's root
or beside the views it governs. The careful bounded walk 0.4.0h built was
load-bearing for a question this gate no longer asks.

The corpus is `bin/verify_pages.rb`'s `PAGES`, which 0.4.0i made requirable. It
has three consumers now rather than three copies, and a Spiff whose pages are not
in it is **refused rather than passed** — which is how `examples/doc_reader` was
found: an app directory holding a Spiff, a page and a data file, with no
`app.rb`, that nothing in this project had ever rendered. It is page 32 of the
verified corpus now, and the census picked that up without being told.

## Part 3 — the word registry is global, and a rendering gate's test has to know

`test_the_real_corpus_passes` passed alone and failed in the suite, reporting
that `.editor` matched nothing. Bisected to `test/studio_try_test.rb`, which
merges the classic UI's library into the registry and says so in its own comment:
*"in this shared suite, rebuilding the merged library at use time is what makes
the studio's words the studio's words (last compile wins)."*

So rendering results depend on test order, and a gate that renders cannot be held
to the real corpus from inside a shared process. That is a pre-existing property
of the runtime — **named here, not fixed** — and it is why `bin/verify_pages.rb`
has always had a process to itself. The corpus assertion now shells out, as the
leg itself does; the fixture tests stay in-process because an in-buffer `def` is
page-local and owes the registry nothing.

---

## What landed

- **`lib/slim_pickins/vocabulary.rb`** and **`test/vocabulary_test.rb`** (8 tests)
  — one home for the question `check_grammar.rb` and
  `bin/generate_vocabulary.rb` both ask.
- **`check_spiff_scope.rb` rewritten** and **`test/check_spiff_scope_test.rb`
  rewritten with it** (9 tests, two of which are the two defect classes the
  name-based version passed).
- **`examples/doc_reader` joined the verified corpus** — 31 pages became 32.
- Four prose claims corrected as the page count moved, all reported by
  `check_vitals.rb` rather than remembered.

## Deliberately not done

- **The registry's order-dependence is not fixed.** It is a real fragility that
  an existing test depends on by name. Changing it is a runtime change with a
  blast radius, and it is a proposal, not a rider.
- **`VOCABULARY.md` is still committed**, for the reason Part 1 measures. The
  larger question it raises is dan's: the studio already renders a live
  vocabulary reference from the code, so the document's unique content is its
  prose. Whether that earns 1,226 committed lines is a documentation decision,
  not a refactor.
- **Tier 4's last item is now unblocked but not done** — pointing `check_styles`
  at `studio/*.rb` still waits on Tier 6 item 19, which this round did not touch.

## Verification

- **Twelve legs green**, 4.47 s end to end: Grammar (1,239 sentences, 92 words),
  Shape, Styles (104 rules), Spiff (16 entries), Scope (**2 spiffs, 13 compiled
  classes held to the HTML their pages render**), Promises (35), Conventions (38),
  Card, Pages (**32**), Vitals, Ruby (126 files), Census.
- **Suite: 575 runs, 6,401 assertions, 0 failures, 0 errors, 0 skips**, and each
  example suite still green on its own.
- **Both items A/B'd against the code they replaced**, which is the only reason
  this round can claim behaviour was preserved in Part 1 and improved in Part 2.
- Every number here was measured this round: the 28%, the 203 → 213, the 3 → 13,
  and the registry pollution by bisecting 54 test files one at a time.
