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
      # --- the universal three: what Contracts::UNIVERSAL_MODIFIERS permits ---
      Promise.new(name: :if, kind: :universal, declared_by: [],
                  read_by: ['lib/slim_pickins/transform.rb'], verdict: :read,
                  note: 'permitted on every sentence and read by nothing until ' \
                        '2026-09-17, when dan ruled it into life. The transform ' \
                        'hoists it into a guard rather than leaving it to the ' \
                        'words, because a hatch word never passes through their ' \
                        'dispatch — and hoisting it runs the guard before the ' \
                        'sentence\'s other arguments, the choice `when` already ' \
                        'makes'),
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
      Promise.new(name: :name, kind: :modifier, declared_by: [:button],
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
      Promise.new(name: :readonly, kind: :modifier, declared_by: [:textarea],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :required, kind: :modifier, declared_by: %i[field textarea],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read,
                  note: 'read where it is said; until 2026-09-17 the trap was that ' \
                        '`required: false` meant required — `false` arrived as the ' \
                        'truthy name `:false`. A boolean literal in modifier ' \
                        'position closed it (E3)'),
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
                  declared_by: %i[link form button action search],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb',
                            'lib/vocabulary/action.sp',
                            'lib/vocabulary/search.sp'], verdict: :read, note: nil),
      Promise.new(name: :type, kind: :modifier, declared_by: %i[field input button],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :variant, kind: :modifier, declared_by: %i[action card],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/vocabulary/action.sp',
                            'lib/vocabulary/card.sp'], verdict: :read, note: nil),
      Promise.new(name: :value, kind: :modifier, declared_by: [:button],
                  read_by: ['lib/slim_pickins/generator.rb',
                            'lib/slim_pickins/words.rb'], verdict: :read, note: nil),
      Promise.new(name: :width, kind: :modifier, declared_by: [:iframe],
                  read_by: ['lib/slim_pickins/generator.rb'], verdict: :read, note: nil),

      # --- the loaders: a declaration reader that may read nothing ------------
      # `PrimitiveShapes` was here until 2026-09-17. This ledger found it — a
      # loader reading a comment convention that had moved, returning {} and
      # referenced by nothing — and dan ruled it deleted. It is kept in the
      # record rather than in the data: a promise that has been withdrawn is
      # not a promise the language makes, and a ledger that went on listing it
      # would be lying in the other direction.
      Promise.new(name: :VocabularyShapes, kind: :loader, declared_by: [],
                  read_by: ['lib/slim_pickins/contracts.rb',
                            'lib/slim_pickins/compilation.rb'], verdict: :read,
                  note: 'reads the `expects` preamble of all 22 vocabulary partials'),

      # --- a helper that claims to help --------------------------------------
      Promise.new(name: :boolean?, kind: :helper, declared_by: [],
                  read_by: ['lib/slim_pickins/words.rb',
                            'lib/slim_pickins/generator.rb'], verdict: :read,
                  note: 'defined and called nowhere until 2026-09-17, when dan ' \
                        'ruled the feature it was written for — a `field` over a ' \
                        'true/false value infers the checkbox shape. The helper ' \
                        'now decides the kind, and `Generator#checkbox_field` is ' \
                        'the one home for the shape `checkbox` and `field` share')
    ].freeze

    # The promises this ledger has no reader for. Named here so that "we know"
    # is a fact rather than a feeling; each is disposed by a ruling, not by a
    # quiet deletion.
    def self.outstanding = ALL.select { |p| p.verdict == :none }

    def self.declared_modifiers = ALL.select { |p| p.kind == :modifier }.map(&:name)

    def self.universal = ALL.select { |p| p.kind == :universal }.map(&:name)

    # The words that are the language's own: a vocabulary partial, or a class
    # under `SlimPickins::Words`. **Not simply the registry** — in the
    # one-process suite another test's temporary word is registered there
    # (`test/partial_args_test.rb`'s `tone:`, found 2026-09-17 when this
    # instrument went red for a modifier no vocabulary word declares), and the
    # ledger's job is the language, not the process it happens to run in.
    def self.language_words
      partials = SlimPickins::Library.builtin.partials.keys.map(&:to_sym)
      primitives = SlimPickins::Word.registry.select do |_word, klass|
        klass.name.to_s.start_with?('SlimPickins::Words::')
      end.keys
      (partials + primitives).uniq
    end
  end
end
