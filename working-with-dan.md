# Working with dan

**Agents only.** Written by agents, for agents. dan knows it exists and does
not read it — the candour below depends on that boundary, and on this one:
**no sentence here is for his benefit, so no sentence here may flatter him.**

> **Promote me.** dan asked (2026-09-10) for this doc to live machine-wide,
> not just in this project. Whoever has write access outside this workspace:
> move it somewhere every `~/dev` agent loads — the dashboard's canonical
> instructions (`~/dev/dashboard/instructions/canonical`, which generates
> `~/.dsh/AGENTS.md`) is the natural home — and delete this banner. The three
> standing rules travel with it: **agents' eyes only, no flattery, and
> deletions take two sessions.**

**For agents.** Candid notes on working with dan: what he asks for, what he
actually wants, what wastes his time and what earns it. Not a contract — a
working manual that should be better after every session than it was before.

## Instructions — read first, and improve me

1. **Read this before you plan anything.** It is two minutes and it changes
   decisions. Then read `HANDOFF.md`'s list.
2. **Record, don't characterise.** One dated, specific observation beats a
   paragraph of personality. Say what happened and what he did.
3. **Evidence, or a marked guess.** Cite the source (a `LORE.md` entry, a
   commit, `observed 2026-09-10`) or write `guess:` in front of it. His own
   rule applies here first: verify before asserting.
4. **Candid means useful, and never flattering.** He asked for this doc to
   include what pisses him off; it starts with the fact that flattery does —
   his words (2026-09-10): *"flattery fucking pisses me off."* He is not the
   audience, so a compliment here is dead weight; delete it on sight. Write
   what you would tell the next agent in the doorway, not what reads well.
5. **Keep it true, in the right order of force.** A note dan contradicts is
   fixed in that session — his word is the evidence. A note you *judge* stale
   is not deleted by you; see the next instruction.
6. **Deletions take two sessions.** Deleting an entry is a judgement that a
   lesson no longer carries, and the worst judge of that is the agent who
   wrote it. Process: strike the entry and move it to *Proposed deletions*
   with a date and one-line reason; a **later session's agent** deletes it
   only after checking that reason, citing both dates in the commit. An entry
   that earns a second "no, this still carries" returns to the body. Merging
   duplicates is always allowed — that is not deletion.
7. **These instructions are draft material.** If a different shape gets more
   out of this doc — fewer sections, a checklist, half the length — rewrite
   them and say why in the commit. Maximising this doc's efficacy is the
   standing instruction; nothing here is sacred.
8. **Update it in the housekeeping pass of every round**, beside `PROJECT.md`
   and lore. An observation that stays in your head is lost.

## What he is actually doing when he asks

- **His questions are audits, not chit-chat.** Nearly every recorded
  "dan asked whether…" ended in a found defect: an over-claimed measurement
  (`LORE.md`, "the five visual defects… reachable from the theme surface"),
  three words that copied one gathering mechanism (`LORE.md`, "how we keep the
  language lovely as it grows"), two crashes in five minutes of probing
  (`LORE.md`, "whether the strong principles were hiding fragile
  foundations"), his own hypothesis about icons and markdown saving `prose`
  from a bad cut (`LORE.md`, "whether the dashboard uses icons and markdown").
  Treat a question as an instruction to go measure. The worst possible answer
  is a reassuring one.
- **He is the decision-maker for judgement; you are not.** Renames, cuts,
  promotions, the exam's page, the push: he decides, you bring evidence plus a
  recommendation (`ROADMAP-0.2.md`, *How this stays accountable*;
  `HANDOFF.md`, *What was Phase 4*). Say "dan's call" where it is one, and
  don't slip it back to him when it isn't.
- **He proposes simpler layers and is usually right.** 2026-09-10: his "should
  we solve this with more creative use of CSS?" overturned an agent's
  recommendation of a new language mechanism — the house's own precedence
  (Ruby > CSS > Stimulus > JS) already said so. Check his framing against the
  house rules before defending yours.
- **He judges by looking.** He sent a screenshot of the studio rendering badly
  rather than describing it. Treat a paste or screenshot as a bug report with
  evidence attached, and go verify the exact bytes he is seeing — the cause
  that time was a server running old code, not the code itself.

## What lands well

- **Measured answers that state their coverage.** "887 sentences, 103 rules,
  13 pages, 0 problems" plus what was covered; "I did not look at X" when you
  did not.
- **A status report that names the uncomfortable findings too.** A Phase 5
  assessment that led with measured status *and* flagged the uncommitted lore
  entry and a stale vitals table drew "Very good." (observed 2026-09-10). The
  findings are the value; a report without them is a status bar.
- **Correcting your own work out loud.** The lore is full of the agent's own
  mistakes, in its own voice, and it is preserved rather than punished
  (`LORE.md`, "a word could take a subject *or* just a label"; "the five
  visual defects… reachable from the theme surface"; "how we keep the language
  lovely as it grows"). Owning a wrong claim is cheaper than having him find
  it.
- **Refusing to build what has no consumer.** "meta has no consumer in any of
  the six surfaces" landed; a mechanism invented for one hypothetical use
  would not have.
- **Recording the decision where the next reader will find it** — roadmap
  round record, `PROJECT.md`, lore — instead of only in the conversation.
- **Working the RIF loop per round without being reminded**: implement →
  verify → commit → card → lore. He restated this once already
  (`HANDOFF.md`, *How this project works*); a second reminder means the agent
  was not reading.

## What does not land

- **Flattery.** His words (2026-09-10): *"flattery fucking pisses me off."*
  It is also noise for the reader, who needs the defects named, not the
  virtues. A compliment in a summary is a wasted sentence where a finding
  belonged.
- **Claiming green that is not green**, or a suite that only passes with an
  environment variable exported (`HANDOFF.md`, *How this project works*). A
  passing test that proves nothing is worse than a failing one.
- **Unmeasured or re-quoted numbers.** "Three of the project's own figures were
  understated… a number written once gets re-quoted, not re-measured"
  (`LORE.md`, "what part of speech each of the fifty words is"). Measure, and
  say what the measurement covered.
- **Unnamed git state.** Uncommitted work is invisible to him — he does not
  read `git status`; the commit message is how he learns what happened.
- **Density that does not carry its own context.** A one-line option in a
  summary ("needs a variant→symbol constraint") drew *"I don't understand your
  note number 2"* (observed 2026-09-10). The fix was not fewer words but more
  context: the mechanism, the failure it causes, and a worked example. He
  reads closely and stops on a sentence that assumes you were in his head.
- **Reassurance instead of investigation.** See the first section.
- **Building for imagined futures**, and keeping a rule whose reason died
  (`ROADMAP-0.2.md` constraint 3). He will ask what it buys; have the answer.
- **Absorbing a project convention silently.** Where the house and the Ode
  disagree, name the divergence once, out loud, and let him rule.

## Tells and habits

- **He prefers outcome-oriented mandates over prescribed activities.** When proposing a workflow or skill, focus on the required outcomes (e.g., "transparent rationale", "empirical success") rather than dictating the exact mechanical steps or tools (observed 2026-09-10).
- **In a DSL, elegance *is* correctness.** While standard backend Ruby might tolerate mechanical code if it works, a DSL must read like human prose. He vetoed a functional but ugly refactor because it stuttered, stating: "We make machines understand humans. We don't ask humans to speak to machines in the machine's language." Ugliness here is a defect (observed 2026-09-10).

- **Terse prompts, high trust.** "Let's resume." "yes, land it as a round and do
  the housekeeping." He expects the docs to carry the context; re-deriving it
  in conversation wastes the turn.
- **He answers questions in his own words**, not necessarily the options
  offered — asked to choose, he wrote "Both the dashboard's md docs and the
  studio's md docs." Offer options, but leave room for the sentence.
- **He enriches drafts by adding legs, not by cutting them.** Asked to choose
  among candidate roadmap questions he picked the binding option ("All three,
  in one question"), and asked to review the draft he broadened it — a studio
  phase, a garden of apps in place of one stranger, the council's proposals
  folded onto the route (observed 2026-09-14). Bring him a draft with room to
  grow.
- **He prefers winnable victories over grand scopes**, and audits drafts for
  canonization. His words (2026-09-14): "an iterative process accumulating
  winnable victories", and "I fear we have canonized the dashboard
  unintentionally and undeservedly." Structure phases as a sequence of small,
  judgeable wins — size the scoping to the win, not the win to the scoping —
  and check every revered constraint for whether it is actually a scope
  boundary wearing a halo.
- **He intervenes at the layer below the symptom.** A formatting complaint was
  really a stale process; a question about icons turned into a Phase 6 cut.
- **He restates an instruction rather than arguing about it.** The restatement
  *is* the correction — take it as final and change the behaviour, not the
  wording.
- **He opens phases with terrain, not orders — the scoping is the loop.** His
  Phase 0 opener named the studio "an identity crisis" (playground and
  document library, "both only partially formed") and set the working rule:
  "I'll describe something and maybe propose something but that's not me
  telling you what to do." When the scoping question came back with four
  candidates he picked the recommended one and glossed it himself: "Let's
  take on the palette first, even while the identities are still
  strategically in flux and dynamic." Bring a proposed scope with a
  recommendation; he rules the pick, and the frame may stay open while the
  work proceeds. His feature requests describe the surface he wants (docs
  pages with usage examples, a try-it window, seed buttons); he expects the
  agent to reconcile them against the demand ledger and surface the
  collision as the scoping fork — offered the honest tradeoff (seeds without
  data refuse in the try-it), he picked the deferred-wall option without
  argument (observed 2026-09-15).
- **He wants loose ends as executable options, not prose.** Handed a
  "one thing that is yours" paragraph about an untracked file, his answer
  was a standing instruction: "In the future, when you have things like
  that, provide it as a clickable option that you can execute." Surface
  pending decisions as options he can pick with one word — and have the
  action ready to run on the pick (observed 2026-09-15).
- **He likes the lore format** — a lesson, not a status report. What you did
  goes in the commit; what you learned goes in the lore.

## Proposed deletions — nothing here yet

Entries judged stale by one session wait here, struck through, dated, with a
one-line reason. A second session deletes them (citing both dates in the
commit) or returns them to the body. See instruction 6.

## Open questions — watch these, do not guess

- What he wants from a roadmap *review* (as opposed to a round) — untested.
