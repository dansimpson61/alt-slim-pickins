# frozen_string_literal: true

module SlimPickins
  # The promise ledger — instrument one of DAYTRIP-0.3.0b.
  #
  # A **promise** is a thing the language says it can do whose effect on a page
  # may be nothing: a modifier a word declares, a modifier the gate permits
  # universally, or a loader that claims to read declarations. The ledger's
  # question is the one no other checker asks:
  #
  #   **does it actually do anything?**
  #
  # This file is the register — data, not behaviour. `bin/check_promises.rb`
  # holds it against the living vocabulary in both directions: every declared
  # modifier must be in the ledger, and every ledger entry must name a reader
  # that still exists. A promise with no reader is recorded as `:none` rather
  # than deleted, because a promise with no reader is a *finding*, and findings
  # get their own ruling (`DAYTRIP-0.3.0b`, E4 and E7).
  #
  # Why the ledger has to be data and not a grep: a declaration's reader is not
  # always the word that declares it. `tab`'s `active:` is read by its *parent*,
  # `Generator#tabs`, from the child's node attributes; `actions`'s `path:` is
  # read by a *descendant*, `action.sp`, through `Chain#container_value`. Both
  # were found by reasoning about the runtime, not by searching for the name —
  # and a search for the name would have found the wrong reader, because
  # `Generator#stylesheet` also has an `attrs[:path]`.
  module Promises
    # kind    — :modifier (declared by words) | :universal (permitted on every
    #           word by the gate) | :loader (claims to read declarations) |
    #           :helper (a runtime function that claims to help)
    # verdict — :read | :forwarded (read by another word through the chain) |
    #           :none (a promise with no reader — recorded, not hidden)
    Promise = Struct.new(:name, :kind, :declared_by, :read_by, :verdict, :note,
                         keyword_init: true)

    ALL = [
      # --- the universal three: what contracts.rb:242 permits on every word ---
      Promise.new(name: :if, kind: :universal, declared_by: [],
                  read_by: [], verdict: :none,
                  note: 'the gate permits `if:` on every sentence and no code ' \
                        'consults it; `note "x", if: .show` renders with show ' \
                        'false — the finding recorded as E4'),
      Promise.new(name: :class, kind: :universal, declared_by: [],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read,
                  note: 'read only by the raw-tag path (`:tag`), so an app word ' \
                        'through the hatch honours it and no vocabulary word does'),
      Promise.new(name: :id, kind: :universal, declared_by: [:box],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read,
                  note: '`box` declares and reads it; the universal permission is ' \
                        'honoured there and dropped everywhere else'),

      # --- every declared modifier, and where it is actually read ------------
      Promise.new(name: :active, kind: :modifier, declared_by: %i[link tab],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read,
                  note: '`Generator#tabs` reads it off the *child* tab\'s attributes'),
      Promise.new(name: :as, kind: :modifier, declared_by: %i[column metric],
                  read_by: ['lib/slim_pickins/words.rb'], verdict: :read,
                  note: 'the page overriding an inference — cause A2'),
      Promise.new(name: :columns, kind: :modifier, declared_by: [:grid],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :defer, kind: :modifier, declared_by: [:script],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read, note: nil),
      Promise.new(name: :favicon, kind: :modifier, declared_by: [:page],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :from, kind: :modifier, declared_by: %i[each line],
                  read_by: ['lib/slim_pickins/words.rb'], verdict: :read,
                  note: 'the escape from the two pluralisation rules'),
      Promise.new(name: :height, kind: :modifier, declared_by: [:iframe],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read, note: nil),
      Promise.new(name: :method, kind: :modifier, declared_by: [:form],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :open, kind: :modifier, declared_by: %i[box disclosure],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :forwarded,
                  note: '`disclosure.sp` declares `open:` and passes the page\'s ' \
                        'value down to its box'),
      Promise.new(name: :over, kind: :modifier, declared_by: [:chart],
                  read_by: ['lib/slim_pickins/words.rb'], verdict: :read,
                  note: 'names the axis when the plural is not the row\'s name'),
      Promise.new(name: :path, kind: :modifier, declared_by: %i[action actions],
                  read_by: ['lib/vocabulary/action.sp'], verdict: :forwarded,
                  note: '`actions path:` reaches a descendant `action` through ' \
                        '`Chain#container_value`; `Generator#stylesheet` has an ' \
                        '`attrs[:path]` too, and it is a different key'),
      Promise.new(name: :placeholder, kind: :modifier,
                  declared_by: %i[input search],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/vocabulary/search.sp'], verdict: :read, note: nil),
      Promise.new(name: :precision, kind: :modifier,
                  declared_by: %i[span money number percent],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read, note: nil),
      Promise.new(name: :q, kind: :modifier, declared_by: [:search],
                  read_by: ['lib/vocabulary/search.sp'], verdict: :read,
                  note: 'read inside its own partial, so a name search finds it'),
      Promise.new(name: :required, kind: :modifier, declared_by: %i[field textarea],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read,
                  note: '`required: false` means required — no boolean literal, so ' \
                        '`false` arrives as the truthy symbol `:false`'),
      Promise.new(name: :return_to, kind: :modifier, declared_by: %i[action actions],
                  read_by: ['lib/vocabulary/action.sp'], verdict: :forwarded,
                  note: 'as `path:` — the forwarding mechanism, found by reading ' \
                        '`Chain#container_value`, invisible to a name search'),
      Promise.new(name: :rows, kind: :modifier, declared_by: [:textarea],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :size, kind: :modifier, declared_by: [:button],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :src, kind: :modifier, declared_by: [:iframe],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read, note: nil),
      Promise.new(name: :srcdoc, kind: :modifier, declared_by: [:iframe],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read, note: nil),
      Promise.new(name: :status, kind: :modifier, declared_by: [:action],
                  read_by: ['lib/vocabulary/action.sp'], verdict: :read,
                  note: 'read by its own partial; the studio page says ' \
                        '`badge .state`, which is a different word'),
      Promise.new(name: :step, kind: :modifier, declared_by: [:field],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :target, kind: :modifier, declared_by: %i[form button],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :to, kind: :modifier,
                  declared_by: %i[link form button action],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb',
                            'lib/vocabulary/action.sp'], verdict: :read, note: nil),
      Promise.new(name: :type, kind: :modifier, declared_by: %i[field input button],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :variant, kind: :modifier, declared_by: [:action],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/vocabulary/action.sp'], verdict: :read, note: nil),
      Promise.new(name: :width, kind: :modifier, declared_by: [:iframe],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read, note: nil),

      # --- the loaders: a declaration reader that may read nothing ------------
      Promise.new(name: :PrimitiveShapes, kind: :loader, declared_by: [],
                  read_by: [], verdict: :none,
                  note: 'superseded when words.rb moved from `# key: value` ' \
                        'comment preambles to the `contract` macro; the loader ' \
                        'still reads the old convention and returns {} — ' \
                        'PRIMITIVES is empty and nothing referenced it'),
      Promise.new(name: :VocabularyShapes, kind: :loader, declared_by: [],
                  read_by: ['lib/slim_pickins/contracts.rb',
                            'lib/slim_pickins/compilation.rb'], verdict: :read,
                  note: 'reads the `expects` preamble of all 22 vocabulary partials'),

      # --- a helper that claims to help --------------------------------------
      Promise.new(name: :boolean?, kind: :helper, declared_by: [],
                  read_by: [], verdict: :none,
                  note: '`Inference.boolean?` is defined and called nowhere in the ' \
                        'repo — found while partitioning `Inference` for the ' \
                        'convention register, and recorded here rather than ' \
                        'deleted, because a helper with no caller is a finding ' \
                        'and the daytrip does not get to fix findings')
    ].freeze

    # The promises this ledger has no reader for. Named here so that "we know"
    # is a fact rather than a feeling; each is disposed by a ruling, not by a
    # quiet deletion.
    def self.outstanding = ALL.select { |p| p.verdict == :none }

    def self.declared_modifiers = ALL.select { |p| p.kind == :modifier }.map(&:name)

    def self.universal = ALL.select { |p| p.kind == :universal }.map(&:name)
  end
end
