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
