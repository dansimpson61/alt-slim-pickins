# Bluesky

**Head work, 2026-09-16.** dan's brief, verbatim where it matters: *"This is
bluesky head work right now, not coding. I want you to use your keen eyes and
your massive brain to brainstorm before planning, to see and smell the roses
before toiling in the dirt."* Nothing here is a plan. The proposed wins W1–W3
are parked in [ROADMAP-0.3.md](ROADMAP-0.3.md) with their consumers named;
this document is the wider ground they were standing on.

The brief, in order: record the wins for later; brainstorm before planning,
with the internet's help; *use your eyes* on the studio; imagine the
playground as a UI/UX IDE; and then two questions — what a **style DSL** could
mean when the language works through HTML and CSS, and what **inference and
convention** — the magic — could mean for sp next.

Every number below was measured on the running studio at 1440×913 on
2026-09-16, by the method in the appendix. Where I first guessed and then
measured, I say so.

---

## Part 1 — What I saw

Six views: the playground, the playground at 900px, the playground with
`pages/specimen` and `dashboard/triage` loaded, the docs page, `/status`, and
a guide. Screenshots and a DOM geometry readout, then the numbers, then the
opinion.

### The first impression was wrong, and correcting it is the finding

My eye said: *a third of this page is dead white space on the right; the
studio is left-clustered in a 1440 viewport.* I measured. The content's right
edge sits at 1416 of 1440 — **2% dead, not 30%.** The layout fills the screen;
the preview images I was reading were scaled and I mistook scale for
emptiness. First lesson of the round: *look, then measure what you think you
saw* — the project's own rule, applied to my own eyes.

### What is actually true of the landscape

`.sidebar_layout` is a grid of `250px 1fr` at `height: calc(100vh - 120px)`.
At 1440×913 that is a **250px sidebar and a 1130px content column, 793px
tall**, split by `.split_pane` into two equal halves of **559px**. Every word
below is in the stylesheet, doing exactly what it says.

| pane | box | content it holds | verdict |
|---|---|---|---|
| sidebar (`.vocabulary`) | 250 × 793 | 2632px of links | scrolls 3.3× |
| palette (`.palette`) | 559 × **256** | 1485px of 18 entries | **83% hidden**; 3 entries visible |
| editor (`.editor_form`) | 559 × **258** | source + data + heading | ~150px of source |
| preview (`.iframe`) | 559 × **252** | a whole rendered page | a letterbox |
| docs article | 559 wide | 1027px | scrolls |
| docs try-it, 2-up | 559 → **274 each** | source pane, raw-HTML pane | markup wraps every ~30 chars |
| `/status` prose | **622** (68ch) in a 1130 section | a fence needing **2124px** | **clipped: the vitals line is cut mid-word** |
| guide prose | 622 × **7734** | PRIMER | a scroll marathon in a 1130 column |

Four things follow, and none of them is "it's ugly".

**1. Vertical is the binding constraint, not horizontal.** The whole studio
lives inside 793px, and every pane that wants more scrolls *independently*:
the sidebar, the palette, the article, the guide, the status output — five
scrollbars, each with its own hidden content. A workbench whose panes cannot
see each other is a filing cabinet.

**2. The layout is column-blind.** `1fr 1fr` is applied to everything, so the
editor (which wants width and height), the palette (a list), the rendered
page (a document), and a raw-HTML pane (unbroken text) all receive the same
fraction. The docs' two-up grid gives 274px to a pane whose content needs
~800; the status page caps its prose at 622 while its section is 1130 wide,
then clips the one fence that is 2124 wide. **The containers are sized by
fractions; the contents are not consulted.**

**3. The work's first impression is failure.** The playground's dominant
visual texture, before you touch anything, is eighteen entries of error prose:
`pages/specimen.sp ● error / this page has no specimen...` — roughly 54 lines
of negative information above the fold of a 256px box. And per the finding
recorded in the roadmap, **most of those badges are lies**: load the entry and
it renders. A visitor's first minute is spent reading refusals for pages that
work.

**4. The studio has no gutter.** The editor is a bare `textarea`: no line
numbers, no highlight, no error marker — *even though the language knows the
line of every failure it reports*. When the refusal arrives, it arrives as a
rendered page in the output pane, three columns away, with the sentence
quoted inside it. The one instrument a language of this kind should own — the
ability to point at the line — is spent on prose instead.

### What is genuinely good, and worth protecting

- **The studio's own chrome is written in the language.** Nine app partials
  (`sidebar_layout`, `split_pane`, `palette`, `editor`, `preview`,
  `html_preview`, `try_it`, `vocabulary`, `editor_form`), 14 view files, 109
  sentences. The studio is its own app, and the layout words are words. That
  is the strongest dogfood in the repo and it is invisible to a visitor.
- **The refusal page is a page the language drew**, with the complaint in the
  language's own voice. It is the best idea in the studio.
- **The state marks are CSS drawn off the class** (`✓ ok` needs no glyph, no
  sprite, no asset). Small and completely right.
- **The theme is 53 named roles in one `:root`**, and `check_styles.rb` proves
  no presentational value escapes it. Nothing in this document's Part 3 is
  possible without that fact; it is the project's most under-celebrated asset.

---

## Part 2 — The playground as a workbench

### What the field says

Five anchors, chosen because each answers something the measurement above
raised.

**Every Layout** ([composition](https://every-layout.dev/rudiments/composition/),
[axioms](https://every-layout.dev/rudiments/axioms/)) argues that layout
should be built from *primitives* — Stack, Box, Center, Cluster, Switcher,
Sidebar — each with "a simple responsibility: space elements vertically, pad
elements evenly", each **intrinsically responsive**: it reconfigures itself
from its own container, and breakpoints are "manual overrides" the primitives
do not need. The Switcher is the one to steal: it flips between a row and a
column when the container is narrower than a threshold that *defaults to the
measure*. Held next to the table above, this is not a style opinion but a
diagnosis: sp's studio splits `1fr 1fr` at every width and stacks at none.

**Jef Raskin's** *The Humane Interface*
([summary](https://wwwencyclopedia.thefreedictionary.com/The+Humane+Interface))
supplies the two tests I would actually apply. *Modelessness*: the same
gesture should always do the same thing, and a mode is a place where the user
must remember which world they are in. *Monotony*: the interface should look
and behave the same everywhere, because predictability is kindness. The studio
has two pages that both contain an editor and both render output — `/` and
`/docs/:word` — and they behave differently. That is a mode, whether or not
it is called one, and it is the identity crisis dan named, stated
mechanically.

**Bret Victor's** principle work
([analysis](https://warwick.ac.uk/fac/sci/dcs/research/em/publications/web-em/09/assignment_213_1264707_submission_13448_paper.pdf))
is about immediate feedback and *seeing the state*: the gap between doing and
seeing is where understanding dies. The studio already renders live as you
type (win 7) — the loop is short. What is still invisible is what the language
*did*: the inference.

**Moldable development** (Tudor Gîrba,
[discussion](https://podscan.fm/podcasts/scrum-master-toolbox-podcast-agile-storytelling-from-the-trenches/episodes/beyond-ai-code-assistants-how-moldable-development-answers-questions-ai-cant-tudor-girba))
says the environment should be shaped around the questions a developer asks of
a system, and that a custom view is cheap and disposable. An IDE for a
language of intent should be able to answer "what did this line mean?" — not
just "what did it print".

**Live playgrounds** ([LiveCodes' display modes](https://unpkg.com/livecodes@0.14.1/skills/livecodes/display-modes/SKILL.md))
converge on the same vocabulary — *editor, result, console, side-by-side,
stacked* — and on the same affordance set: resizable splitters, a full-screen
result, and a mobile stack. The studio has none of the three.

### What I would do with the real estate

Bluesky, so: the shape, not the ticket.

**Lead with the work, not the ledger.** The palette should open on what
*works* — the pages that render, the sentences you can steal — and the census
should be a quiet column or a filter, not the first thing a stranger reads.
The honest refusals stay, and stay honest (W1); they simply stop being the
greeting.

**Size pans by intent, not by fraction.** Three intents, three treatments:
*the writing* (source and data) wants height and a gutter; *the artifact*
wants area and a frame; *the ground* (palette, docs, vocabulary, guides) wants
a narrow column that never competes. Today all three get 559px and a
scrollbar.

**One workbench, not two pages.** Fold the docs page's try-it into the
workbench rather than duplicating the editor beside an article: the word's
docs become a *ground* pane, the example you pick fills the writing pane, the
artifact shows it. Raskin's monotony test then passes — one gesture, one
effect, wherever you are — and `editor_form` stops serving two masters. This
is the identity answer I would argue for: **the studio is not a playground
and a library; it is one workbench with a movable library shelf.**

**Make the artifact look like an artifact.** The preview is currently a
borderless iframe whose rendered `<h1>` is the same size as the studio's own
`<h1>`, so tool and artifact compete for the eye. A frame, a label, a
width control, and a quieter studio voice would fix it without a line of
JavaScript.

**Put errors in the gutter.** The refusal page is a lovely artifact — keep it
for the artifact pane — but the *writer's* channel for an error is the line it
happened on. The language already carries `path`, `lineno` and the sentence on
every located `Error`; the editor is the only surface in the repo not using
them.

**Show the settled state.** A word or two of orientation — which page is
loaded, whether it renders, what data it reads, when it last rendered — would
turn a space you look at into a space you are in.

**And the pane nobody has built: the why.** Part 4 argues it is the studio's
deepest job.

---

## Part 3 — A language for style

### The honest starting fact

sp has no way for a page to say style *locally*. Not "a poor way" — none:

- **Globally**, style is the theme: 53 roles in one `:root`, and every value
  below it is a `var()`. A theme can miss nothing. A theme also cannot be
  asked for a favour.
- **Per word**, style is the word's own business (`.card`, `.note--warning`).
  The page says `note warning`; the stylesheet decides what warning looks
  like.
- **Locally** — *this one section is wider, this one list is denser* — there
  is nothing. The two doors are both wrong: change the theme (a global answer
  to a local question), or add a Ruby app word (a word for a one-off, and the
  vocabulary's own rule says *if a word can only ever appear on one page, it is
  not a word, it is that page*).

Meanwhile the gate whitelists `class:` and `id:` on **every** word, and no
word reads them: `note "x", class: "boom"` is permitted by the checker,
silently dropped by the generator, and invisible to everyone. `if:` is the
same story. `style:` is correctly refused on a word.

And the hole under all of it: **`tag` is a public Builder method with no
contract.** `Contracts.complaints` returns early for it
(`contracts.rb:238`), which means a *page* can say this today, and it works:

```text
page "P"
  tag span, style: "color: red"
  tag div, class: "hand-written"
```

I verified both. Arbitrary inline style, arbitrary class name, no contract, no
complaint, no checker. KERNEL.md calls a page-reachable `tag` "the one change
that could ruin the language" and demand-gates it as Tier 0 — but it is not a
proposal, it is already true, and it is the current answer to "how does a page
say style?" The answer is: *by writing machine code.* So the real question is
not *should sp have a style language*; it is whether **the undesigned one it
already has** is the one we want.

### What CSS is, and what a language for humans would be

CSS is a language of **properties and values addressed to a rendering engine
about a document tree**. It is admirably honest about that, and it is exactly
the wrong shape for a page in this language: it names the machine's knobs
(`padding-inline-start`), not the author's intent, and it makes the author
hold a number (`1.5rem`) where they hold a meaning (*a little more room*).

A style language for human beings, in this house, would be a language of
**roles and relations**: names for intent, resolved to values in one place
that the checker can see. The reader of `note quiet` should not know that
quiet is `--ink-soft`; the reader of `grid columns: 3, gap: loose` should not
know that loose is three steps. Both should be able to look, and both should
be unable to write a value.

The field has two relevant answers and one useful dissenter:

- **Utility-first** ([Tailwind's case](https://stevekinney.com/courses/tailwind/utility-first))
  solves the bloat by making the *page* the vocabulary (`text-sm text-muted`)
  — at the cost of exactly what this project protects: the page now speaks a
  machine-adjacent dialect, and no rule can say a `text-sm` was the wrong
  choice.
- **CUBE CSS** ([CSS-Tricks](https://css-tricks.com/videos/191-learn-by-doing-cube-css/))
  is Composition, Utility, Block, Exception: compositional layout, a small
  utility layer, blocks, and — the good idea — **Exception**, where a variant
  is a deviation applied in context rather than a new component. That maps
  onto sp's variants (`note warning`) more cleanly than utilities do.
- **Design tokens** ([two-tier token architecture](https://github.com/sujeet-pro/sujeet.pro/blob/main/content/articles/design-tokens-and-theming/README.md))
  are the industry's settled answer to "name the intent, hold the value": a
  primitive tier (`blue-600`) and a semantic tier (`--ink`, `--surface`,
  `--positive`). sp's `:root` **is already the semantic tier** — 53 roles,
  every one of them a name for an intent, none of them a value in the page.

### The sentence I would build the whole thing on

**The language has 64 words for *what* and 53 names for *how it looks*, and
the two vocabularies cannot speak to each other.**

That is the gap, and it is smaller than it looks: the style language is not a
new invention, it is *letting a page say the roles the theme already owns*.
Not "add a `css` language"; **make the theme sayable**.

### Four shapes it could take, honestly weighed

Each is a sketch in sp's idiom, not a proposal with a consumer. All four are
fenced as `text` because none of this syntax exists.

**(a) Variants — the cheapest, and the most sp.** Style becomes more
vocabulary, said exactly where the language already says names:

```text
section holdings, wide
prose narrow
grid cards, columns: 3, gap: loose
note quiet
list dense
```

No new syntax; the name slot and the modifier seam already exist; the
checkers already hold both (`loose` must be a variant the word declares, and
a declared variant with no rule fails `check_styles`). The cost is real
though: every word accumulates style names, and `wide` on a `section` may mean
something different from `wide` on a `grid` — which rule 2 ("a name slot names
one job") should refuse. Probably the winner for the first round precisely
because it is boring.

**(b) A style modifier family — one axis, named once.** A page states a
*relation* on a universal modifier, resolved against the theme:

```text
section holdings, measure: wide
grid cards, columns: 3, gap: loose
prose, emphasis: quiet
```

Advantage: the axes are few and shared, so a reader learns three names instead
of thirty, and `check_styles` gains something it has never had — a way to
prove **every role the pages use exists in the theme, and every theme role is
reachable**. Disadvantage: it puts a modifier on every word, which is close to
"CSS properties with nicer names" if the axes are not chosen with discipline.

**(c) Axioms and exceptions — the boldest, and the most in keeping.** Borrow
Every Layout's best idea and pair it with the project's own: the design states
**axioms** once ("the measure never exceeds 68ch"; "vertical rhythm is one
step"), the language applies them everywhere unasked, and a page may only say
an **exception**:

```text
section holdings, bleed
grid cards, columns: 3
prose
```

The page says nothing about measure, gap or rhythm — they are inferred from
the axiom — and `bleed` is the rare, nameable deviation. This is the shape
that honours *a line that states the inferable should not exist* most
strictly, and the shape that would make the studio's inference-pane (Part 4)
worth building. Its risk is the opposite of (a): when everything is inferred,
a wrong inference is hard to see, which is an argument for visibility rather
than against the idea.

**(d) The shape to refuse: CSS names as modifiers.** `section padding: 2rem`
or `card display: flex`. This is the machine's language wearing the
language's clothes. It breaks the one thing that makes the current stylesheet
provable — a page would hold values, and the theme would stop being the one
home of every value — and it lets a page reach past its vocabulary, which is
the exact door the project's CSS comment says does not exist. Refused.

### What makes this worth doing *here* and not in CSS

One argument, and I think it is decisive. A style vocabulary is **checkable in
both directions** in a way CSS never is. `check_styles.rb` already proves the
stylesheet and the runtime cannot drift; extend the same trick and you get:

- every role a page says must exist in the theme — a typo is a refusal on the
  line, in the language's voice;
- every role the theme offers must be **reachable and used** — an orphan role
  is a dead word, and the project already fails on those;
- a variant with no rule, and a rule with no word, both fail today.

No CSS architecture on earth can promise that, because in CSS the page is
unbounded. Here the page's style vocabulary is a closed set with one home,
and the project's entire discipline — *every truth has one home*, *nothing
verified by a checker alone*, *a rule must outlive its reason* — is already
aimed at exactly this.

### The risks, named now

- **A style vocabulary is how a vocabulary becomes a utility layer.** If
  `loose` and `roomy` and `spacious` all arrive, we have rebuilt Tailwind with
  friendlier spelling. The rule that should hold: a role earns its name when
  the theme owns a value for it, and never before.
- **A role without a scale is a value in disguise.** `wide` is only honest if
  there are two or three widths in the theme and `wide` picks one. Otherwise
  it is `640px` with a nicer face.
- **Precedence now has a fourth claimant.** Today: the page, the app, the
  language. Style adds the theme. The doctrine already covers it — the page
  may *say* it, the theme *owns* it, the language *infers* it — but it must be
  written down before the first role lands, or the fourth claimant will win
  arguments by being new.
- **And `tag` must close first**, or the designed language will be undercut by
  the undesigned one that already ships. That work is KERNEL.md's Tier 0 and
  it was already demand-gated; this document does not change its order, it
  only gives it a reason that a page can feel.

---

## Part 4 — Inference and convention, the magic

### Why it feels like magic, stated properly

A page in this language under-specifies and is nonetheless right. `page
portfolio` infers the doctype, the head, the title, the flash, the layout, and
a top heading. `field base_income` infers the label, the input name, the
value, and the input type. `each holding` infers the plural, binds the
singular, and shifts the subject. `money .market_value` infers the format.
None of this is guesswork; it is *convention*, and convention is what makes
language work at all — a speaker says less than they mean, and the hearer
recovers the rest because they share the conventions. That is the whole
mechanism, and it is why dan's phrasing is exact: **language achieves intent
because of convention, and that is magical.**

Which also means the magic has failure modes, and they are the familiar ones:

1. **Conventions the reader does not share** are not magic, they are
   superstition. (`page pattern, .title` reads perfectly and cannot work —
   already documented, and already the kind of thing that costs an hour.)
2. **Conventions that fire invisibly** cannot be corrected, because nobody
   knows they fired. This is the `if:` finding and the census finding wearing
   the same coat: *a rule that is permitted but not read, and a promise made
   but not taken.*
3. **Conventions that cannot be overridden** are traps, and the project
   already states the cure: *the common case costs zero words, and every
   convention is overridable by saying the thing.*

### The four grades of inference — and the missing one

sp's inference today sorts into three grades, and the fourth is the one Part 3
is about:

| grade | what it knows | example | who owns it |
|---|---|---|---|
| **structural** | the tree | heading depth from nesting, id from the subject, plural from the name, layout from the library | the language |
| **shape** | the value's class | input type, step, numeric alignment, date form | the language |
| **domain** | the app | `label_for`, `format_for` | the app |
| **axiomatic** | *(nothing — this grade does not exist)* | the measure, vertical rhythm, the gap between siblings, density | the theme |

The first three are already governed by the recorded rule — *mechanical facts
derivable from a value's shape are free; facts that encode a human judgement
about the domain belong to the app* — and the fourth is the same idea pointed
at design instead of data: **facts derivable from the design's own axioms are
free; judgements about emphasis belong to the page.** That sentence, if it
holds, is what a style DSL is *for*, and it makes Part 3 a question about
inference rather than about CSS.

### What magic demands of the studio

If inference is the language's best trick, the tool for the language should be
built around it. Three consequences, and the third is the one I would most
like to see.

**Conventions need a home a reader can look up.** The docs' "In the wild"
already shows real sentences; what is missing is the *rule* — `section
accounts` renders the heading "Accounts", and where does a writer learn that?
A convention deserves an entry as much as a word does, and the vocabulary
document is the natural place: a word's conventions are part of what the word
is.

**Override must be as discoverable as the default.** The docs show the common
case; they should show the escape beside it. Every entry already says
"infers"; the useful version says *infers, and here is the sentence that
overrides it.*

**And the studio should show the inference firing.** This is the pane nobody
has built, and I think it is the real answer to "the playground as an IDE".
The language already knows, for every value it renders, **who decided it** —
the page said it, the app answered, or the language inferred it. That is not a
guess; it is the recorded precedence rule, and it is already implemented in
`Builder#label_for`, `#format_of` and friends as a three-level chain. The
studio could surface it:

```text
page portfolio
  metric lifetime_taxes
```
```text
  metric lifetime_taxes
    label   "Lifetime taxes"     app  (label_for)
    value   1,284,506            data (projection)
    kind    money                page (as: money)   <- stated
    measure 68ch                 theme (--measure)  <- axiom
    gap     0.75rem              inferred (stack)   <- convention
```

Every line of a page, annotated with the owner of every decision it produced.
That is "see the state" (Victor) and "the environment answers questions"
(Gîrba) at once, and it does something more: **it turns the language's magic
into its teaching.** Magic that can be inspected is craft; magic that cannot
is folklore. The project's own standard — *make incorrect states speak* —
applied to the language's best property.

It is also, quietly, the cheapest possible test of Part 3: if a style DSL
cannot say who owns a role, it is not a language yet.

---

## Part 5 — What would have to be true

Open questions, kept open.

- **Does a page ever need to say style?** The strongest version of this
  project says *rarely*, and that the escape being rare is the proof that the
  vocabulary and the axioms are right. Part 3's shape (c) is the test of that
  claim; shape (a) assumes the answer is "sometimes".
- **Is `tag` the real blocker?** If the undesigned escape is closed before the
  designed one exists, a page loses its local style story entirely for a
  while. That may be the honest order — it makes the demand visible — or it
  may be intolerable. dan's call, and worth making explicitly.
- **Is the studio one surface or two?** Everything in Part 2 assumes one. The
  ten wins built two that both work; the measurement says they duplicate the
  editor and differ in behaviour.
- **What is the target screen?** The measurement says vertical is binding at
  1440×913. An intrinsically responsive workbench (Every Layout's no-breakpoint
  stance) would answer this without deciding it — but "responsive" and "an
  IDE" pull in different directions, and I have not resolved that here.
- **Does the ledger belong on the front page at all?** W1 makes the census
  honest; it does not make it a good greeting.

And the limits of this document, named:

- I looked at six views on one machine at one size. I did not use it with a
  keyboard only, with a screen reader, on a laptop at 1280, or on a phone.
- I read the layout rules of the stylesheet, not all 575 lines.
- I did not measure the studio's render cost, so every proposal in Part 2 is
  unsized against the budget KERNEL.md is still waiting for dan to set.
- The style sketches in Part 3 are sketches. None has a consumer, and by the
  project's own rule none should be built until one arrives.
- I am a machine that just met this codebase. The roses I smelled may not be
  the ones dan planted.

---

## Appendix — the measurement, reproducible

Screenshots:

```text
chromium --headless=new --no-sandbox --user-data-dir=/tmp/chrome-profile \
  --window-size=1440,1200 --screenshot=/tmp/view.png http://127.0.0.1:4580/
```

Geometry, with the Ferrum already installed on this machine:

```ruby
require 'ferrum'
b = Ferrum::Browser.new(browser_path: '/usr/bin/chromium', window_size: [1440, 1000],
                        browser_options: { 'no-sandbox': nil, 'disable-gpu': nil })
b.goto('http://127.0.0.1:4580/')
puts b.evaluate(<<~JS)
  (() => [...document.querySelectorAll('.palette, .editor_form, .iframe, .prose, pre')].map(e => {
    const r = e.getBoundingClientRect();
    return { sel: e.className || e.tagName, w: Math.round(r.width), h: Math.round(r.height),
             needs: e.scrollHeight, clipsX: e.scrollWidth > e.clientWidth + 1 };
  }))()
JS
b.quit
```

The numbers in Part 1 came from that, on 2026-09-16, against the studio
running on `:4580` at commit `735e944`.
