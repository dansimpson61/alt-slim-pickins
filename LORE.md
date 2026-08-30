# alt-slim-pickins — lore

What working sessions *learned* here — not what they did. Appended by
agents and humans; read back by the project card and `/brief`.

## 2026-08-29 — Claude Opus 5

Slim's grammar splits cleanly in two, and the split is the design opportunity. The line skeleton is genuinely one sentence (indentation + one leader from a closed set + the rest; indented lines are children) and holds everywhere. All the irregularity lives in the tag line. Verified against Slim 5.2.1: (1) attribute values are undelimited Ruby terminating at whitespace, so `a href=1+2` yields href=3 but `a href=1 + 2` silently yields href=1 with `+ 2` as text content — no error; (2) `:` is a second nesting mechanism competing with indentation and colliding with embedded-engine syntax — `li: a Home` works, `li:` with an indented block is a SyntaxError; (3) whitespace control is a suffix sublanguage (`p<`, `p>`, `p<>`, `=<`, `==<>`); (4) escaping is encoded by character doubling (`=` escapes, `==` does not). Keep the skeleton; the tag line is what needs redesigning.

## 2026-08-29 — Claude Opus 5

The design collapsed once we stopped defending inherited syntax. Every sigil we had been carrying (= - | and required parens) existed only to disambiguate Ruby that we ourselves had left undelimited — Ruby already tells "Products" from product.name. Remove the original mistake and the whole punctuation layer evaporates. What survived is one sentence, `word arguments`, indentation for nesting, six argument kinds. The load-bearing move is that HTML elements, components, control flow and text are all *words*: extending the language adds vocabulary, never syntax. The word carries presentation, the argument carries domain — `price .price` means present the subject's price as a price, and the formatting belongs to the word. Two of dan's conventions did more than any syntax we invented: `each product` (iterate products, bind the subject, so `.name` just reads) and letting conditionals dissolve into vocabulary (`empty "Nothing here yet."` names the situation rather than writing the branch). Consequence worth remembering: since `.foo` is not valid Ruby, the Slim-parser-subclassing question we spent the session investigating became moot — we own the grammar. And the risk moved with it. The grammar is one sentence and can barely be wrong now; the vocabulary can be incomplete, and in a language where words are the only construct, every missing word is a wall.

## 2026-08-29 — Claude Opus 5

Cutting the qualifier colon bought more than it cost, and the lesson
generalises: when two constructs fill the same grammatical role, spelling one
of them with punctuation is not a distinction, it is an inconsistency. `each
product` was already bare while `section :products` was not — same role, two
spellings. Dropping the colon left a morphology rule stronger than the thing
removed: **a dot means data, a bare word is language.** Every value carries a
dot (`.name`, `order.number`); every name does not (`products`, `primary`).
One visual cue doing one job, and no Ruby-ism the reader needs prior exposure
to.

Rejected the other half of the proposal — attributes as child lines (`id .id`)
alongside `alt:` modifiers — because it makes attributes sayable two ways,
which is the alias problem. But the deeper answer was that the line should not
exist at all: a card whose subject is a product can infer its own id. That is
now a rule in DESIGN.md — *a line which states the inferable should not
exist* — and it is the same cut as dropping `as product` earlier.

Also learned to keep the grammar checker in the repo. It caught four lines of
prose annotation masquerading as grammar inside fenced blocks. A design doc
drifts exactly where its examples stop being checkable.

## 2026-08-30 — Claude Opus 5

The vocabulary entry format is not a matter of taste — it falls out of the
rule of government. Because a name is interpreted by the word to its left and
a word by the word it is nested under, every word needs *two* definitions, one
per axis. Miss either and a sentence using that word cannot be read in
isolation, which is the property the whole grammar exists to protect.

A convention for the docs, learned the practical way: untagged fences hold
sentences and are checked by `check_grammar.rb`; tagging a fence (```` ```html ````)
excludes it. That is how a document shows *output* without the checker
mistaking it for grammar — and it means every example in every doc is either
verified or explicitly marked as not-a-sentence. There is no third category,
which is what stops examples from rotting.

## 2026-08-30 — Claude Opus 5

Drafting the vocabulary against a real page (roth/views/controls.slim) rather than invented examples paid for itself three times, and the argument generalises: invented examples are the exact condition under which a vocabulary looks more complete than it is, because you only invent examples for words you already have. (1) Three words the estimate missed entirely — metric, chart, disclosure — each of them hand-built in that file out of markup, classes and JavaScript; the disclosure toggle alone costs a button, an id, a data attribute, a CSS class and a handler. (2) `price` was exposed as a domain noun masquerading as a presentation word. Our own rule says the word carries presentation and the argument carries domain, so it had to become `money`; a portfolio has balances, and `price .balance` is a category error that a products example would never have revealed. (3) Of two predicted collapses, heading/title held but grid/list did not — they govern their children differently (grid lays out blocks, list makes children into items), and government is the test, not superficial similarity. Also: doctype turned out not to be an exception at all, just something `page` knows, which closed the last hole in the grammar. Most valuable mechanical lesson: make the documents accountable to each other. check_grammar.rb now requires every word used in a sentence to be defined and every defined word to have a sentence, and it caught real drift on its first run.

## 2026-08-30 — Claude Opus 5

Writing a whole real page is a different instrument from drafting a vocabulary, and it found what drafting could not. Three walls, and the most important one was invisible until collections nested: `table holdings` inside `each account` resolved to a page-level holdings rather than that account's, because the rule said a name is a local else a helper. Silently wrong, and in the ordinary shape of every page rather than an edge case. The rule is now subject-first: a name resolves against the subject, then locals, then helpers. It costs nothing at the top level and it retroactively explains `metric balance`, which had only ever worked on instinct. Second wall: no word for navigation — predicted as under-tested in draft 1, bit on the first real page. Third wall taught the better lesson: flash messages had nowhere to live, and adding a `flash` word was the obvious move and the wrong one. If every page would carry an identical line, that is the signature of an *inference*, not a word — so `page` infers it. That is a reusable test for whether something belongs in the vocabulary at all. Also worth remembering: two quantitative claims written into the draft (sentence count, comparison line count) were both wrong when measured. Counts asserted from memory while writing prose are unreliable even about files you just read — measure them, and the honest ratio (66 sentences against 91 lines) is less flattering and more useful than the one imagined. This language does not win by being terser line-for-line; it wins where the old page pays in kind.
