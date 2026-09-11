# DAYTRIP-0.2.6a: The Action Refactor

This daytrip was initiated during Roadmap 0.2 Phase 6 to address the 5-argument `action` primitive outlier. 
A council of 8 Ruby luminaries convened, assessed the DSL architecture, and successfully refactored `action` to inherit payload parameters from a scoped `actions` container.

During their review (documented in `COMMUNITY_BULLETIN_BOARD.md`), the council identified three deeper architectural constraints and proposed them as future scope items:

## 1. Dynamic Parameter Splatting / Forwarding in Vocabulary Partials
Currently, `lib/slim_pickins/contracts.rb` converts unrecognized keys in `expects` into rigid modifier lists. A partial cannot accept arbitrary HTML hidden inputs or keyword arguments without declaring each one explicitly in `expects`.
**Recommendation:** Support a `payload: :any` or `hidden: :hash` contract slot so actions can forward arbitrary hidden key-values without polluting the core grammar.

## 2. Subject Shifting in `card`
In `queue.sp`, we repeatedly write `first_item.status`, `first_item.purpose`, `first_item.next_line`, etc., because `card` does not shift the subject.
**Recommendation:** Allow `card` to declare `name: :subject`, enabling child sentences to write `.status` and `.purpose` directly. This brings `queue.sp` into harmony with the rest of the DSL and eliminates redundant subject references.

## 3. HTML5 `formaction` Button Consolidation
`lib/slim_pickins/words.rb` already defines `button` with `to:`, and `generator.rb` emits `<button formaction="...">`.
**Recommendation:** Instead of wrapping every button in its own `<form>` block (resulting in 4 separate forms), future versions could express an action group as a single form with multiple buttons using HTML5 `formaction`.
