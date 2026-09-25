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
  that time was a server running old code, not the code itself. He also
  reports his own measurements as observations to be confirmed: "sample the
  outputs of each word's Try me and observe that some provide useful output
  but many (most?) do not" — his suspicion was right (34/64 useful), and
  confirming it *and fixing it* in one cycle is the expected answer, never
  a defense of the current behavior (observed 2026-09-15).

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
  Same for findings: handed a verified inventory of seven defects and two
  drifted measurements at the top of a session, his ruling was *"record your
  findings where the next session will find them, and then back to Phase 0 to
  scope the playground improvements"* — write them into the demand ledger, do
  not fix them mid-phase (observed 2026-09-16). A finding that arrives without
  a fix is not an unfinished job; it is evidence the phase has not spent yet.
- **Working the RIF loop per round without being reminded**: implement →
  verify → commit → card → lore. He restated this once already
  (`HANDOFF.md`, *How this project works*); a second reminder means the agent
  was not reading.
- **Treating his "explore" work as a preamble to real work.** 2026-09-17, on
  a UI build he had already ruled on: *"Let's build that but manage multiple
  UIs from which we can pick. This is an exploration of what we can do before
  we update guides and turn agents loose to build some new garden apps. We may
  try generating a few different UIs just for the sake of exercising ourselves
  and the language."* The exploration *is* the deliverable; "for the sake of
  exercising ourselves" is a reason, not a hedge. Build for that — several
  UIs, a picker, a seam each can mint its own links through — rather than
  building one end state and calling the alternatives future work.
- **Answering a hint with an argument.** Twice on 2026-09-17 a vague reply
  was the whole correction. "Hint: the answer is in the Ode, and it has to do
  with what we can do in our dsl that we cannot do in html and css" meant *go
  re-read the document you are already bound by*; and "the hint is Ruby 101:
  DRY" meant *your reading of it was backwards*. Both times the right move was
  to re-read the source and restate the correction in the round's record, not
  to defend the analysis. He gives the pointer, not the answer, because the
  pointer is the lesson — and a wrong answer owned in writing lands (see
  *Correcting your own work out loud* above).

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
  **Repeated 2026-09-16, which is why this entry now carries two dates.** An
  outline described two instruments in prose and asked which should land
  first; his answer was *"Why not both? I swear to God I don't remember what
  each one does and how they differ from each other."* The cause was not
  brevity but **one name doing four jobs**: the document used "register" for a
  list of criteria, a map of sources of truth, an instrument, and a work list.
  The repair that worked — and the shape to reach for next time — was a table
  of *four names, four jobs*, each with what it answers and who reads it, plus
  a **worked row** from each instrument so the difference is visible rather
  than described. A document that names four things alike has not been
  misunderstood; it has been written twice. Worth noting for its own sake:
  the outline was arguing that transparency is the criterion for what lands
  when the reader could not tell its own parts apart.
- **Reassurance instead of investigation.** See the first section.
- **Building for imagined futures**, and keeping a rule whose reason died
  (`ROADMAP-0.2.md` constraint 3). He will ask what it buys; have the answer.
- **Absorbing a project convention silently.** Where the house and the Ode
  disagree, name the divergence once, out loud, and let him rule.
- **Optimising the machine's output instead of the language's.** 2026-09-17: an
  argument was built for a word that would hoist a layout relation out of the
  stylesheet so a `box` would not need a class — DRY pointed at the rendered
  HTML. His correction: *"We don't need to repeat ourselves in sp, but the
  rendered html/css will be full of repetition. We don't care because we don't
  need to look at it. The machine needs the repetition. We need space and
  unique names and kindness."* DRY binds the language, never the artifact. The
  tell that you are about to make this mistake: you are proposing vocabulary
  whose only beneficiary is a document nobody reads. The duplication that costs
  is a truth living in two places *in sp* — which is what the round then found,
  five files declaring one stylesheet, and fixed with a seam the language
  already had.
  **Refined 2026-09-25**, for the DSL compilers (`.design`, and any future
  emitting language): his words, *"DRY binds the language (DSLs) and the
  emitted artifact must be excellent. They may not be DRY, but they must be
  excellent."* "Never the artifact" was too strong — repetition in compiled
  CSS/HTML is fine, but the artifact still answers to a bar, just not DRY's.
  A compiled selector that matches nothing real in the actual DOM is not a
  DRY complaint, it's a correctness defect — the artifact failing to be
  excellent — and stays a legitimate finding even though shortening it or
  deduplicating it is not.
- **A machine-inferable name authored as a literal.** 2026-09-25: a plan
  proposed fixing the design-idiom selector-explosion defect by having
  `.sp` authors write `data_zone: "library"` inside `library.sp` — the
  partial's own name, typed again, in quotes. He rejected it immediately:
  *"I object to making a human being copy the name of the zone, put it in
  quotes and add it as an data_zone parameter. The name of the zone is
  machine inferable and therefore does not belong in the dsl."* This is the
  Ode's "a line that states the inferable should not exist" applied to a
  case that didn't look like restatement at first glance — the literal
  didn't look redundant because it was buried inside an HTML attribute
  value, not sitting next to its own duplicate. The fix was not to relocate
  the redundancy (e.g. thread it from a caller instead) but to ask whether
  it was needed *at all* — it mostly wasn't: the zone's real class was
  already real and already safely scoped by which stylesheet loaded it, so
  the entire attribute mechanism turned out unnecessary. Tell for next
  time: before adding a parameter whose value names something the code
  already names elsewhere, ask what already knows this fact, not just
  whether repeating it is tolerable.

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
  boundary wearing a halo. He also separates the two modes explicitly when he
  wants to: handed a recommended pick he answered "record these very worthy
  proposed wins **for later**; and then let's do some creative scoping — this
  is bluesky head work right now, **not coding**" (observed 2026-09-16). So
  "park the wins and dream" is a legitimate answer to a proposal, and a
  brainstorming turn is a deliverable in its own right — but it is *not* a
  licence to implement: he expects a plan-shaped thing to stay a plan.
- **For design work he prescribes a method, not an answer**: look at the real
  thing with your own eyes, look at how others have solved it, and brainstorm
  *before* planning — "use your eyes… to see and smell the roses before
  toiling in the dirt" (observed 2026-09-16). The prescribed order is
  observation → outside inspiration → design, and skipping to a plan is the
  failure. Handed six screenshots and a DOM geometry readout he can act on; a
  prose opinion about whitespace he cannot.
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
  argument (observed 2026-09-15). He also judges the *service's depth* by
  using it: after five landed wins came "So far, so good, but a bit
  shallow" and two deepening demands (broader context, pre-filled data)
  with mechanism freedom — "be creative… I am open to other possibilities."
  He rules the what; the how is invited, and when he offers a mechanism
  (a sandbox), treat it as one candidate to beat, not the spec.
  And given a conservative option beside a bolder one, he takes the bold
  one when the architecture makes it cheap: offered button-click vs live
  debounced rendering, he picked live. Then he cuts what the change made
  redundant — the Render button was gone by his next message ("The Render
  button is no longer necessary"), the 0.2 subtraction instinct again:
  after landing a bolder mechanism, expect the superseded affordance to
  be removed by his word, and cut it before it is asked twice
  (observed 2026-09-15). And when a phase's ledger empties, he asks for
  boundary hygiene before opening the next scoping — "complete
  housekeeping as though we were at end of phase, and ensure continuity
  for handoff to a new session" — treat handoff continuity as part of the
  deliverable, not the afterthought. His empty-option answers are
  directives, not indecision: four times now he has skipped the offered
  options and written his own next step — and the fourth was a *composite* of
  two of them, in order: offered "record only, then scope" and "back to Phase
  0" as separate picks, he answered "option 1 ... and then option 4". Read his
  sentence as a sequence of rounds, not a single pick (observed 2026-09-16).
  And he delegates operational
  ownership explicitly when the machinery is ready: "I will stop the
  server now and let you and subsequent agent manage starting and
  stopping in the future" — once he hands an operation over, own it
  fully: keep the running state current with the commits, and leave the
  service up for his browser at round end (observed 2026-09-15).
- **He wants loose ends as executable options, not prose.** Handed a
  "one thing that is yours" paragraph about an untracked file, his answer
  was a standing instruction: "In the future, when you have things like
  that, provide it as a clickable option that you can execute." Surface
  pending decisions as options he can pick with one word — and have the
  action ready to run on the pick (observed 2026-09-15).
- **He likes the lore format** — a lesson, not a status report. What you did
  goes in the commit; what you learned goes in the lore.

- **"Take it" takes the shape, not the internals.** He answers a poll by
  naming an option — "The name is good. Open it.", "take it." — and that is a
  ruling on the *shape* on offer, not a promise that the shape survives being
  built. When building the register's reference shape showed its own
  acceptance test could not hold (per-word byte-identity) and that its central
  move over-reached (one slot replacing prose that held word-local facts too),
  the right response was to build the corrected shape and bring the correction
  back in the record — not to widen scope, not to quietly force the proposal
  through. He rules on shapes; the internals are the round's to get right,
  and a proposal that turns out wrong in a detail is a finding for the record
  (observed 2026-09-17).

- **He uses roadmap reviews to test orientation, drift, and sequencing before opening a phase.** (observed 2026-09-21).
  Asked to audit status across roadmap/daytrips/bluesky, whether intent drifted or evolved, and whether to commission apps before or after rectifying pedagogical materials, his goal was to test whether the agent distinguishes incomplete preconditions (fixing test regressions, aligning guides) from the forward march of the roadmap. Handed the four-step sequence, he confirmed: *"Am i correct that 1 and 2 are incomplete items from previous work that need to be taken care of before we procede, and the rest in a resumtion of the roadmap03?"* A review tests your mental model, your honesty about what is broken, and your sequencing discipline.

- **End-of-phase housekeeping is the complete cycle**: `working-with-dan.md`, commit, and push. His reminder (2026-09-21):
  *"End-of-Phase housekeeping also includes working_with_dan, commiting, and pushing."* Closing a phase is not just code green and card updated; it is the full clean exit — lore, manual, clean tree, and remote updated.

- **He approves sequentially when the trajectory is aligned.** (observed 2026-09-21):
  Prompt: *"6. Excellent. procede"* and *"7. So far, so good. Procede."* after ruling on app candidates, sequencing, and locations. When the sequence and constraints are settled, he steps back to let the loop run. Deliver the complete round — domain model, views, tests, demand gaps, studio integration, verification, housekeeping, commit, and push — cleanly without creating artificial pause points or asking trivial questions.

- **He distinguishes the itinerary from its volume: Daytrips give orthogonal depth to the roadmap's vector.** (observed 2026-09-22).
  A roadmap is an itinerary (a 1D vector); daytrips step orthogonally off that vector to explore, measure ground truth, discard phantom baggage, and give the journey volume. He expects us not to become rigid or dogmatic about historical path dependency (*Ataovy dian-tana* is wisdom, not dogma), to audit proposed work ruthlessly against *current and future purpose*, and to apply DRY, SSOT, and dynamic self-documentation instead of manual bookkeeping.

- **Authoring pain points guide workbench and language scoping (Pain Point 2 as Volet 4b)**: (observed 2026-09-22).
  dan identified two fundamental authoring pain points: (1) flat, unordered vocabulary lacks deductive authoring structure (remedied via 5-tier taxonomy: Structural, Semantic, Interactive, Behavioral, Visual on the Studio shelf and in PRIMER); and (2) Studio editor lacks partial minting, forcing long, unDRY views even outside the studio. His direction: record Pain Point 2 for dedicated discussion as Volet 4b (locally scoped, bite-sized domain words / Studio partial creation) rather than burying it in unrelated volets.

- **Housekeeping is a full-cycle protocol, attended to after each daytrip/round**: (observed 2026-09-22).
  Prompt: *"Very good. Have you been attending to all of the housekeeping after each?"*
  Housekeeping is not an afterthought deferred to the end of a roadmap; it is attended to after *every single daytrip and round*. The full cycle comprises:
  1. `DAYTRIP-*.md` brief closed, question answered, outcomes recorded.
  2. `PROJECT.md` updated (`status`, `last_touched`, `next_step`).
  3. `LORE.md` updated with durable lessons learned.
  4. Dashboard API updated via `/api/lore` and `/api/journal`.
  5. Vocabulary regenerated (`bin/generate_vocabulary.rb`).
  6. All 7 gates verified green (`check_grammar`, `check_shape`, `check_styles`, `check_promises`, `check_conventions`, `check_card`, `verify_pages`).
  7. Full test suite verified green in single-process and isolated runs.
  8. Living Census SSOT (`bin/census.rb`) matched and checked.
  9. `working-with-dan.md` updated with operational observations.
  10. Context window status reported: (instructed 2026-09-23) Whenever doing housekeeping, report the state of the context window (truncation/compaction status, step count, transcript volume, headroom).
  11. Named git state, finished work distinguished from in-flight work, commit and push executed or offered.

- **Combined inspection surface over modal tab proliferation**: (observed 2026-09-22).
  When considering inspecting the evaluated semantic AST alongside inference provenance, dan preferred a single unified 'Inspect' surface over proliferating disconnected tabs (Visual | HTML | Tree | Why). Uniting the Tree (the physical scaffolding of What) and the Why Pane (the provenance of Why) into a master-detail inspection surface eliminates mode-switching, aligns with Raskin's modelessness, and lets the structure and its causal receipts explain each other.

- **Taxonomy as an empirical diagnostic instrument over a rigid filing cabinet**: (observed 2026-09-22).
  dan reframed the 5-tier vocabulary taxonomy from an organizational filing cabinet into an empirical diagnostic test of the language. Boundaries between categories are naturally blurred or porous (multi-category words appear under all relevant categories rather than being artificially siloed); the taxonomy tests what is missing (e.g. layout primitives like `stack`), what is cohesive vs. what should be split (e.g. overloaded `box`), what is weirdly ad-hoc (e.g. `figcaption` and `summary` as single-consumer HTML element leaks), and validates the standard that words are meaning and structure, not decorative paint.

- **Context window status in housekeeping**: (observed 2026-09-23).
  Prompt: *"I would also like to add one more thing to the hpousekeeping. I would like you to tell me the status of your context window whenever you do the housekeeping."*
  Housekeeping is not only repo hygiene; it is session awareness. An agent must monitor and explicitly state its context window status (truncation boundaries, trajectory length, transcript footprint, headroom) at every housekeeping pass so both human and agent know how much continuity remains before compaction occurs.

- **In-buffer prototyping as a proving ground for language-wide kernel reforms (Volet 4b -> Package C)**: (observed 2026-09-23).
  dan's approach to language evolution is empirical and grounded in immediate authoring pain points. Rather than redesigning the entire 64-word runtime abstractly in one monolithic refactor, he defined a simple concrete specimen (Doc Reader) to test in-buffer `def <word>, *params` authoring, flexible argument binding, and declaration-free words in a single view buffer. Once proven end-to-end with tests and Studio partial minting, this local mechanism serves as the proven template to generalize across the entire language in Package C (Lean & Elemental Kernel).

- **Privileged tag primitive resolves the Rubinius question while protecting DSL boundaries (Volet 5 / Package C)**: (observed 2026-09-23).
  Eliminating single-consumer kernel leaks (`figcaption` in `figure`, `summary` in `disclosure`) and re-atomizing `paragraph` was achieved by introducing a strictly privileged `tag` primitive permitted only in `lib/vocabulary/*.sp` and strictly refused in app templates. Partitioning the compilation cache on `[source, privileged]` guarantees zero cache pollution. dan's crisp scope boundary—keeping Volet 5 focused on kernel lowering and single-consumer absorption while explicitly deferring vocabulary restructuring (splitting `box`, `span`, adding `stack`/`cluster`) to Volet 6—prevented scope bloat and kept all 31 verified pages provably byte-identical.

- **Screenshot error reports: trace the entire causal chain before assuming an isolated frontend or browser bug**: (observed 2026-09-23).
  When dan shared a screenshot of Workbench displaying 'Error: undefined method 'map' for nil' noting that 'some browsers show this error though some may not', the root cause was not a browser incompatibility—it was an intricate dual causal failure: (1) `playground_locals` injecting an `OpenStruct` (`StudioDocs.build`) that shadowed the template's `docs` identifier, coupled with `OpenStruct#to_a` returning `nil` and leaking a raw Ruby `NoMethodError` through `each`; and (2) Workbench UI chrome (`workbench/layout.sp`) leaking into sandbox `/render.json` execution, causing `refusal.sp` to fail on missing `.words_count` and fall back to raw unstyled HTML error text. The browser variation was simply due to cookie-based UI selection (`sp_ui=classic` vs `workbench`) and form input state. Lesson: treat multi-browser discrepancies as symptoms of stateful server-side routing/chrome interaction, and fortify language collection boundaries so raw Ruby errors never escape.

- **In-buffer `def` words must eat the exact same food as disk partials**: (observed 2026-09-24).
  Screenshot prompt: *"Before we move on, i note that our inline-defined words did not wrap classes around their contents. Please see the screenshot"*.
  When dan noted that in-buffer defined words rendered bare `<div class="box">` instead of `<div class="box sidebar">` and `<div class="box reading_pane">`, it revealed an asymmetry: `PartialWord` for disk partials inspected single-root bodies and tagged them with `box[:app_class] = partial_name`, but `define_local_word` emitted directly without capturing or tagging. In slim-pickins, in-memory local words and disk partials are the same concept in different stages of life. Any behavioral discrepancy between the two is a defect.

- **The Design Idiom: 100% Shared Syntax, Dedicated Spatial Vocabulary**: (observed 2026-09-24).
  Prompt: *"To the extent we can, lets let our design idiom look like sp but with its own vocabulary. How much of sp's grammar and syntax can we use as-is?"*
  The answer is 100%. Reusing `SlimPickins::Transform` translates `.design` files directly into standard Ruby blocks: one sentence per line, bare words becoming symbols, indentation nesting blocks, and line-numbered errors. Substance templates (.sp) declare domain intent without spatial coordinates or colors (`catalog`, not `sidebar`); companion design manifests (.design) declare spatial postures (`surface`, `stage`, `flank`, `stack`, `zone`, `air`, `balance`, `frame`, `cadence`, `treatment`), which the compiler lowers into modern CSS Grid, `@container` queries, and fluid `clamp()` tokens. Furthermore, docs indexers (`StudioDocs.examples`) must recognize that child nodes inside `def` blocks are unexecuted macro definitions rather than top-level executable page examples, ensuring Try-it seeds remain working demonstrations.



- **Inference beats ceremony & rejection of compound class convolutions**: (observed 2026-09-24).
  Prompts: *"can't we infer that items nested under 'list' are list items?"* and *"i assume we are keeping layout.sp temporarily while we test the workshop page, right? Because .surface-studio_workbench.stage-studio_workbench seems a horrible convolution."*
  Two core architectural rulings:
  (1) If a container's semantic contract is that it makes its children into items (`VOCABULARY.md:1021`), forcing authors to manually type boilerplate `item` lines is an unnecessary ceremony leak. Pushing automatic item inference into the compiler (`Generator#box` wrapping child nodes or iterations in `<li class="item">`) honors the contract and keeps specimen views unceremonious and clean.
  (2) Never tolerate compound class soup (`.surface-workbench.stage-workbench`) to bridge templates and styling. Ugliness is a defect even when it works. Use clean, honest semantic handles (`library`, `panes`, `editor`, `output`), and let the design compiler and CSS theme target natural structural tokens.

- **Screenshot audits uncover architectural frontiers; housekeeping must close the loop with commit and push**: (observed 2026-09-25).
  Prompts: *"Look again at the screenshot that you shared in the walkthrough. What do you see? ... Quantity, density, unDRY ... We need our css to be excellent, DRY, efficient so that it is manageable and themable."* followed by *"Did you commit and push?"*
  Two vital operational lessons:
  (1) A screenshot is an audit of the whole system's integrity, not just visual layout. Visible defects (outer scrollbars, overflowing stacked textareas, premature container query collapse in split panes) revealed four architectural frontiers: numerical units invading DSLs, stylesheet fragmentation across three strata, 459 lines of defensive selector explosion caused by contract ambiguity between generator and compiler, and failure to distinguish an application shell (`100dvh` viewport containment) from a document page.
  (2) Housekeeping before leaving for a fresh session or sidetrip is not complete without executing the commit and push. Dan asking *"Did you commit and push?"* is the signal that when all quality gates are green and work is packaged, do not leave the tree dirty in triage—commit and push cleanly.

## Proposed deletions — nothing here yet



Entries judged stale by one session wait here, struck through, dated, with a
one-line reason. A second session deletes them (citing both dates in the
commit) or returns them to the body. See instruction 6.

## Open questions — watch these, do not guess

- None currently open. (What he wants from a roadmap review tested and answered 2026-09-21).
