# Phase 0 — the vertical slice

**Result: inference works, with one qualification that changes what we claim.**

Ten words built end to end — transform, subject chain, runtime and inference —
rendering [pages/roth_form.sp](pages/roth_form.sp) against
`Engine::Inputs`, the real `Struct` behind `roth`. Verified by diffing the
output against the hand-written `roth/views/controls.slim` it replaces.

Run it: `ruby bin/diff_roth.rb` · `ruby test/phase0_test.rb`

## What the diff says

Nine fields appear in both pages. **All nine agree exactly on type and value**,
every one derived rather than stated:

```text
  ok   age_primary        ours=number 60       theirs=number 60
  ok   trad_balance       ours=number 750000   theirs=number 750000
  ok   growth_rate        ours=number 0.05     theirs=number 0.05
  ok   horizon_years      ours=number 30       theirs=number 30
  … 9 of 9
```

The page is 24 sentences against 56 lines of Slim for the same form, and it
names no `label`, no `input`, no `type`, no `value` and no `for` attribute.

## The qualification

`field` claims four derivations from one word. It reliably delivers **three**.

The input name, the current value and the input type are mechanical, and they
were right every time. **The label is a judgement call that humanising
approximates**, and on this page it got roughly three of ten right:

| attribute | inferred | the human wrote |
|---|---|---|
| `base_income` | Base income | Base Income |
| `growth_rate` | Growth rate | Growth Rate |
| `trad_balance` | Trad balance | Traditional Balance |
| `ss_primary_start_year` | Ss primary start year | SS Start (yrs from now) |

Acronyms, abbreviations and domain phrasing are not derivable from an
attribute name, and no cleverer humaniser fixes that — the information is not
in the input.

This is not fatal, because the convention is overridable by saying the thing,
exactly as VOCABULARY.md rule 3 requires:

```
field ss_primary_start_year, "SS start (years from now)"
```

With eight labels overridden, our labels match the hand-written page's modulo
its Title Case. But the honest claim changes from *four derivations from one
word* to **three derivations always, and a fourth when the attribute name
already reads as English**. `field base_income` is genuinely free;
`field ss_primary_amount` costs a label.

**Carried to Phase 1:** the app contract should let an app answer for its own
labels. `ss_primary_amount` means something specific to roth, and roth is the
only thing that knows it. That is a contract question, not a humanising one.

## What the type inference proves about the contract

The input type comes from the **value's class**, never from a schema:

```text
60      → number        0.05  → number, step 0.01
"fixed" → text          Date  → date
```

So a plain `Struct`, a `Hash` or an ordinary PORO satisfies the contract
without declaring anything. `Engine::Inputs` is a bare `Struct.new(...,
keyword_init: true)` and needed no changes at all. That is the strongest
result of this phase — the contract is close to free.

## A bug this found in roth

The hand-written page and the model have drifted apart:

- The page posts `social_security_start_year` and `social_security_amount`.
- `Engine::Inputs` has `ss_primary_start_year`, `ss_primary_amount`,
  `ss_spouse_start_year`, `ss_spouse_amount`.

So two fields on that form post names the model does not read, and the two
spouse fields have no inputs at all. Our version cannot drift this way,
because the fields are read from the model rather than typed alongside it.

Reported as a finding, not fixed — `roth` is dormant and not in this project's
scope.

## Two design results

**Names are Symbols, content is Strings**, because that is what the transform
emits. So a word tells a name from content by *type* rather than by counting
positions, and `button primary, "Run"`, `button primary` and `button "Run"`
all mean the obvious thing. That was not designed; it fell out, and it is
worth keeping.

**`page scenario` followed by a bare `form` is the right shape.** Writing
`form scenario` under `page scenario` names the same subject twice, which is
the "line which states the inferable" smell. A word that names no subject
leaves the chain alone.
[VOCABULARY.md](../VOCABULARY.md)'s `form` entry is corrected accordingly.

## Done-conditions

| From ROADMAP-0.1.md | Status |
|---|---|
| Page parses into a Ruby call tree | done |
| Malformed line names word, line and expectation | done — `test_a_bad_argument_names_the_line` |
| `.foo` resolves at three levels of nesting | done — `test_a_dot_means_the_innermost_subject_at_three_levels` |
| A typo raises naming attribute and subject | done — "this account has no nmae" |
| Ten words render HTML | done |
| Field derives label, name, value, type | **three of four** — see above |
| Diffed against the real page, differences named | done |

**Exit criterion met.** We know what `field` can do, and the vocabulary entry
has been corrected to say it. No word is built on a false premise.

## Honest limits

- The three-level subject test exercises `Chain` directly. Phase 0's ten words
  cannot nest subjects three deep — `each` and `section` arrive in Phase 2 —
  so the mechanism is tested but not yet reached through the language.
- `bin/diff_roth.rb` compares the facts a form is made of, not bytes. A byte
  diff would be dominated by markup choices that are deliberately different.
- Nothing here is styled. The words emit `class="field"`, `class="button
  button--primary"` and so on; whether those become `sp-` classes is Phase 5.
