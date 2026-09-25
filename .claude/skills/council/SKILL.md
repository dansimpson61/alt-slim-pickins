---
name: council
description: Convene alt-slim-pickins' council of Ruby and UX luminaries (Matz, Sandi Metz, why the lucky stiff, DHH, Jim Weirich, Avdi Grimm, Katrina Owen, Sarah Mei, Bret Victor, Don Norman) as a single grounded, cross-referential debate that reaches a signed consensus and design spec. Use when the user asks to convene the council, wants "the luminaries'" take, is weighing a nontrivial DSL/design-idiom/architecture decision with more than one defensible answer, or is trying to resolve a people-centered UX tension against the language's own grammar. Do not use for mechanical fixes, typos, or questions with one obviously correct answer.
---

# The Council

A structured multi-persona debate for resolving genuine architectural or
design-idiom tension in this project — modeled on
[COMMUNITY_BULLETIN_BOARD.md](../../../COMMUNITY_BULLETIN_BOARD.md), the
council's first session (the `action` primitive refactor), whose
recommendations shipped for real (see `LORE.md`, 2026-09-10 and
2026-09-22). Read that document once before running this skill for the
first time in a session — it is the quality bar and the house style, not
just a template.

## The one rule that matters

**Write the whole transcript yourself, in this context, top to bottom.**
Do not spawn a subagent per persona, and do not spawn a subagent per round.
That was tried and it produced the failure mode this skill exists to fix:
parallel monologues with no memory of each other, each contributing a
thin, disconnected paragraph. A council is one mind speaking in ten
voices, not ten cold agents stapled together. If the topic is too large
for one sitting, checkpoint by writing the partial transcript to the file
and resuming later in the same style — never by fanning out.

## The roster

Not every session needs every voice. Cast the subset whose actual
expertise bears on the question at hand — typically four to six — and say
in one line who is sitting this one out and why. The full ten:

- **Yukihiro Matsumoto (Matz)** — developer happiness, the Principle of
  Least Surprise.
- **Sandi Metz** — single responsibility, small interfaces, parameter
  code smells, data clumps.
- **why the lucky stiff (_why)** — poetic conciseness, playful whimsy,
  living DSLs.
- **David Heinemeier Hansson (DHH)** — convention over configuration,
  conceptual compression.
- **Jim Weirich** — block composability, structural hierarchy, tree
  integrity.
- **Avdi Grimm** — confident collaborators, duck typing, trust over
  defensive checks.
- **Katrina Owen** — therapeutic refactoring: small, measurable,
  verifiable steps.
- **Sarah Mei** — long-term team maintainability, no clever magic traps.
- **Bret Victor** — tools for thought; immediate, visible feedback;
  close the gap between intention and result. The workbench/studio voice.
- **Don Norman** — human-centered design: affordances, signifiers,
  mental models, forgiving error. The app-user voice.

The Ruby eight speak for the code and the developer reading it; Victor and
Norman speak for the people the code ultimately serves — a tool author
using the studio, or an app user reading a rendered page. Don't let a
session become all-Ruby-no-UX or all-UX-no-Ruby when the question actually
touches both.

## When to convene

A real tension, not a foregone conclusion: a design choice with more than
one defensible answer, where the defensible answers actually pull in
different directions. If only one part of the roster's expertise is
relevant and there's no real friction to work through, skip the ceremony —
answer directly, or as that one voice, without staging a debate.

## Protocol

0. **Orient before gathering evidence** — four sources, not uniformly:
   - `PROJECT.md`'s `next_step` (or
     `curl http://127.0.0.1:4000/brief/alt-slim-pickins` if the dashboard is
     up) is the **authoritative** resume point — freshest by construction,
     since housekeeping touches it every round.
   - `HANDOFF.md` gives narrative and itinerary, but it lags `PROJECT.md`
     by design (it's only rewritten at round boundaries) — read it for
     texture, and defer to `PROJECT.md` wherever the two disagree. Don't
     copy a claim from HANDOFF.md's "active next step" without checking
     it against PROJECT.md's `last_touched`.
   - `LORE.md`, grepped for the topic — this project writes its findings
     down, so if the tension was already investigated, the council's job
     is to resolve it with what's known, not rediscover it. Cite prior
     lore entries the same way you'd cite a checker result.
   - `ODE_TO_JOY.md` and `working-with-dan.md` aren't project state, they're
     the standard the transcript is judged against — read (or re-read) them
     before writing a single persona line, because they set two hard
     constraints on the output itself: **every number in the transcript
     must come from a command run this session, never re-quoted from
     memory or from an earlier lore entry**, and **DRY binds the
     `.design`/`.sp` language; the compiled CSS/HTML need not be DRY, but
     it must still be excellent** — correct, minimal in a way that's
     earned, not merely short. A finding that the compiled output repeats
     itself is not, by itself, a finding. A finding that a compiled
     selector matches nothing real in the actual DOM is one regardless of
     line count — that's the artifact failing to be excellent, not failing
     to be DRY.

1. **State the problem with evidence, before anyone speaks.** Run the
   real checker or grep the real code — `check_grammar.rb`, `check_shape.rb`,
   `check_styles.rb`, `bin/census.rb`, or a direct `grep`/line count — and
   quote actual output. Never invent a metric. The precedent document's
   opening move ("439 sentences, mean 1.28 args") is measured, not
   asserted; match that discipline.

2. **Cast the relevant subset** from the roster above, and name who's not
   sitting in and why.

3. **First round: each cast voice reacts to the evidence**, from their own
   documented philosophy, citing something checkable — a line number, a
   real code snippet, an existing convention in `DESIGN.md`,
   `VOCABULARY.md`, `docs/DESIGN_IDIOM.md`, or a `LORE.md` precedent. No
   adjectives without a citation behind them.

4. **Every round after the first must engage a specific, named prior
   claim.** A turn is not a fresh monologue — it agrees with, refines, or
   contests something a specific other voice just said, by name (see how
   Sandi Metz opens by answering Matz, and Sarah Mei closes by naming
   Katrina, DHH, and _why directly, in the precedent document). This is
   what makes it a discussion instead of eight independent opinions.

5. **Friction is procedural, not assigned.** No voice is cast as the
   permanent skeptic. Let tension emerge honestly from two real value
   systems colliding on the same evidence — Victor's visible-state against
   Metz's encapsulation, DHH's convention against Norman's discoverability,
   Weirich's tree structure against _why's economy. When a voice has
   nothing to object to, let them agree plainly; manufactured dissent is
   the theater this skill exists to avoid.

6. **Consensus is earned, not declared.** Close the debate only once every
   objection raised has been either answered on its own terms or
   explicitly and durably conceded, in writing, by the voice who raised
   it. If real disagreement survives, say so — a signed minority note
   beats a fake unanimous close. (Honesty over Perfection is a Council
   norm already, per the charter in the precedent document.)

7. **Write the consensus as a design spec**, mirroring the precedent
   document's shape: proposed architecture with real code/diffs, a
   "flexible parity" section justifying any HTML or behavior change
   against the checkers that would catch a regression, and — if the
   session surfaced things bigger than the immediate question — a
   "Proposed Additional Scope" section for a future roadmap, not acted on
   now. Sign it with only the voices that actually participated.

## Where it lives, and what happens after

Write the transcript to `COMMUNITY_BULLETIN_BOARD.md` at the repo root.
If that file currently holds a *closed* topic, retitle it for the new
question (its resolved content belongs in `LORE.md`, not in two places at
once). Once the council's recommendation actually ships — this skill
produces a design spec, not code; implementing it is separate work — leave
the finding in `LORE.md` and update `PROJECT.md`'s `next_step`, per this
workspace's dashboard convention. The council's transcript is a session's
work; the reason it mattered is the ecosystem's memory.
