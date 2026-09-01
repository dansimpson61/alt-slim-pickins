# Phase 6 — integration, and the escape hatch

**Result: a `.sp` file renders the way a `.slim` one does, and the escape
hatch is a word rather than a construct.**

Run it: `ruby test/phase6_test.rb` · `ruby examples/portfolio/app.rb`

## A Sinatra app whose views are this language

[examples/portfolio/app.rb](examples/portfolio/app.rb) is a real Sinatra app.
Its views are `.sp` files, rendered through Tilt:

```ruby
class Portfolio < Sinatra::Base
  helpers SlimPickins::Helpers
  set :views, File.join(__dir__, 'views')

  get('/') { sp :index, locals: { portfolio: portfolio } }
end
```

Three routes, exercised in-process by `test/phase6_test.rb`:

```text
/              -> 200, 2607 bytes
/accounts/2    -> 200, 1124 bytes
/accounts/99   -> 404
```

Two things are deliberately taken away from Sinatra.

**The layout is ours.** A layout says `contents`, not `yield`, so Sinatra's
own layout machinery is bypassed (`layout: false`) and `Library` finds
`layout.sp` beside the views. The page still says nothing about it — the
test asserts `index.sp` contains no mention of a layout and the output
contains the nav and the footer anyway.

**The scope becomes the page's helpers.** A Sinatra helper method is reachable
as `.foo` at the top level, because the page is the outermost subject and
helpers are its attributes. That is the VBA-implied-`Application` rule paying
off at the integration boundary rather than needing a second mechanism.

Partials are found the same way: any `views/partials/*.sp` becomes a word.

## The escape hatch

The language has no `div`. That is deliberate, so the hatch cannot be "reach
for markup" — and it cannot be "add a word to slim-pickins" either, because
then every app's peculiarities end up in a shared vocabulary.

**An app adds a word of its own, in Ruby.**

```ruby
module AppWords
  def video(*args, poster: nil)
    _, source = arguments(args)
    html(%(<video class="#{token(:video)}" src="#{escape(source)}" controls></video>))
  end
end
```

The page then says:

```
video .tour_url
```

which reads exactly like `image .url`, and a reader cannot tell that one is
built in and the other is not. The founding claim survives its hardest test:
**extending the language adds vocabulary, never syntax.** Even the escape
hatch is a word.

### The surface is five methods

`token`, `html`, `children`, `escape`, `arguments`. Everything else on the
builder stays private, and a test asserts it — `emit`, `nest`, `about`,
`label_for`, `present` and `collection_for` are all unreachable. A hatch that
exposes the whole runtime is not a hatch, it is an API, and it would be the
thing every future irregularity leaks through.

### Shadowing, both ways

```text
`table` is already a slim-pickins word — an app cannot redefine it
`account_card` is defined twice — as a partial and in Ruby
```

Refused at load. The second is new: an app can now define words two ways, so
it can also define one twice.

## Evidence it is rarely needed

Across everything written in this language so far — the drafted pages, the
roth form, the specimen, and this app's two views, **284 sentences** — the
escape hatch is used **once**, for the video. Every other thing any page
needed was already a word.

That is the number the roadmap asked for, and it is worth stating what it does
not prove: these pages were written by the same person who wrote the
vocabulary. A page written by someone else would be the real test, and Phase 7
is that.

## Honest limits

- **`check_styles.rb` does not cover an app's own words.** `video` emits
  `class="video"` and slim-pickins' stylesheet has no rule for it, correctly —
  an app that adds a word owns its styling. But that means the guarantee
  "every class emitted has a rule" holds for the vocabulary, not for an app.
- **`check_grammar.rb` finds Ruby-defined words by convention**: it scans for
  modules named `*Words`. That is a convention rather than a contract, and an
  app naming its module something else would trip the checker.
- **The library is cached per views directory**, so a partial added while the
  server runs is not picked up. Fine for production, irritating in
  development, and unaddressed.
- **`link` still derives `/name`.** The app's `link show, "Details"` produces
  `/show`, not `/accounts/2`. Real routing wants a helper and the language has
  no opinion yet — the largest remaining gap before a real port.

## Done-conditions

| From ROADMAP-0.1.md | Status |
|---|---|
| A Sinatra app renders a page from a file on disk | done — three routes |
| A documented way through when the vocabulary has no word | done — a Ruby word, five-method surface |
| Evidence it is rarely needed | done — once in 284 sentences |

Suite: 82 tests, 280 assertions, 0 failures. 555 sentences, 0 problems.
58 rules, 0 problems.
