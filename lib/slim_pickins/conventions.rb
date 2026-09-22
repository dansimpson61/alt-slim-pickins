# frozen_string_literal: true

module SlimPickins
  # The convention register — instrument two of DAYTRIP-0.3.0b.
  #
  # A **convention** is what the language decides when a page stays silent: the
  # inference, the default, the shape a word takes because of where it sits.
  # The register's question is the one the accent audit could not answer:
  #
  #   **what will this do when I say nothing, and who decided?**
  #
  # Every entry names the sentence that *overrides* it — a convention a reader
  # cannot override is a trap, and one they cannot look up is superstition.
  #
  # The register is data; `bin/check_conventions.rb` holds it against the code
  # in three directions: every entry's home must still exist, every function in
  # `Inference` must be claimed here or named as internal, and every word whose
  # contract declares an inference (`id:`, `label:`) must have an entry.
  #
  # Grades are BLUESKY's four: :structural (the tree decides), :shape (the
  # value's class decides), :domain (the app must be asked) and :axiomatic (the
  # design's own standing decisions). The fourth grade has **one entry, and it
  # records an absence** — the theme owns 53 roles and no page can say one.
  # That absence is the reason a style language is the next thing this project
  # needs, and it is registered here so it cannot be forgotten.
  module Conventions
    # name, when the page is silent, what is decided, where that lives (file +
    # a marker string in it), which Inference functions it owns (one entry may
    # own several — `money`, `percent` and `number` are three forms of one
    # convention), the sentence that overrides it, its grade, and who triggers
    # it: a word declares `infers: <name>`, so `owned_by` is only set for a
    # convention no word can declare — one the page or the runtime decides.
    Convention = Struct.new(:name, :when_silent, :decides, :file, :marker,
                            :inference, :override, :grade, :owned_by,
                            keyword_init: true)

    ALL = [
      # --- structural: the tree decides -------------------------------------
      Convention.new(name: :document, when_silent: 'any page at all',
                     decides: 'the doctype, html/head/body, the charset and the viewport',
                     file: 'lib/slim_pickins/generator.rb', marker: 'def page',
                     inference: nil, override: 'nothing — it is what a page is',
                     grade: :structural),
      Convention.new(name: :title, when_silent: '`page portfolio`',
                     decides: 'the `<title>` and the top heading, humanised from the name',
                     file: 'lib/slim_pickins/words.rb', marker: 'heading = title || Inference.label(name)',
                     inference: nil, override: '`page portfolio, "Your retirement"`',
                     grade: :structural),
      Convention.new(name: :layout, when_silent: 'a `layout.sp` sits beside the views',
                     decides: 'the chrome every page wears, with `contents` marking the hole',
                     file: 'lib/slim_pickins/builder.rb', marker: 'def wrapped_in_layout',
                     inference: nil, override: 'delete the layout, or move the page',
                     grade: :structural),
      Convention.new(name: :heading_level, when_silent: 'a heading is nested',
                     decides: 'its level, from how deep it sits',
                     file: 'lib/slim_pickins/generator.rb', marker: 'def heading',
                     inference: nil, override: 'nest it differently; no page says a level',
                     grade: :structural),
      Convention.new(name: :box_title, when_silent: 'a heading inside a box',
                     decides: 'that it is the box\'s title, at the box\'s own level',
                     file: 'lib/slim_pickins/generator.rb', marker: '@box_base',
                     inference: nil, override: 'use `title` or `text` instead',
                     grade: :structural),
      Convention.new(name: :box_tag, when_silent: 'a promoted word\'s box',
                     decides: 'which element it becomes — `section`, `article`, `footer`, `li`…',
                     file: 'lib/slim_pickins/generator.rb', marker: 'BOX_TAGS',
                     inference: nil, override: 'nothing; the word owns its element',
                     grade: :structural),
      Convention.new(name: :box_depth, when_silent: '`card`, `section`',
                     decides: 'the depth their children\'s headings start at',
                     file: 'lib/slim_pickins/generator.rb', marker: 'BOX_DEPTH',
                     inference: nil, override: 'nothing',
                     grade: :structural),
      Convention.new(name: :card_id, when_silent: '`card` over a subject that has an id',
                     decides: 'the DOM id, as `word-id`',
                     file: 'lib/slim_pickins/builder.rb', marker: 'def card_id',
                     inference: nil, override: 'say `id:` yourself',
                     grade: :structural),
      Convention.new(name: :singular_binding, when_silent: '`each holding`',
                     decides: 'that the bound name is `holding`, reachable from inside',
                     file: 'lib/slim_pickins/words.rb', marker: 'collection_for(name)',
                     inference: nil, override: 'name it something else and say `from:`',
                     grade: :structural),
      Convention.new(name: :plural_collection, when_silent: '`each holding`, `table holdings`',
                     decides: 'which collection to read — `y`→`ies`, otherwise `+s`',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def plural',
                     inference: :plural, override: '`from:` on the collection word',
                     grade: :structural),
      Convention.new(name: :subject_or_collection,
                     when_silent: '`each account` under `section accounts`',
                     decides: 'that the subject *is* the collection, so it iterates itself',
                     file: 'lib/slim_pickins/builder.rb', marker: 'def collection_for',
                     inference: nil, override: 'nothing — it is what `empty` depends on',
                     grade: :structural),
      Convention.new(name: :table_rows, when_silent: '`table holdings`',
                     decides: 'the rows, so no page writes a loop',
                     file: 'lib/slim_pickins/words.rb', marker: '@rows = name',
                     inference: nil, override: 'nothing',
                     grade: :structural),
      Convention.new(name: :column_registration, when_silent: '`column x` inside a table',
                     decides: 'that it registers rather than renders, so the header exists before a row',
                     file: 'lib/slim_pickins/builder.rb', marker: 'def register!',
                     inference: nil, override: 'nothing',
                     grade: :structural),
      Convention.new(name: :chart_axis, when_silent: '`chart years`',
                     decides: 'the axis labels, from each row\'s singular',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def singular',
                     inference: :singular, override: '`over:` names the attribute',
                     grade: :structural),
      Convention.new(name: :first_truthy_branch, when_silent: '`choose` with several `when`s',
                     decides: 'that exactly one branch renders — the first that holds',
                     file: 'lib/slim_pickins/words.rb', marker: '@collected.find',
                     inference: nil, override: 'two sequential `choose`s for two independent rows',
                     grade: :structural),
      Convention.new(name: :empty_situation, when_silent: 'the named collection is empty',
                     decides: 'that `empty` renders and its siblings do not',
                     file: 'lib/slim_pickins/builder.rb', marker: 'def prune',
                     inference: nil, override: 'nothing; `empty` is the word for it',
                     grade: :structural),
      Convention.new(name: :collection_detection, when_silent: 'a value that answers `each`',
                     decides: 'that it is a collection and not a hash',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def collection?',
                     inference: :collection?, override: 'nothing',
                     grade: :structural, owned_by: :runtime),
      Convention.new(name: :nothing_detection, when_silent: 'a collection with nothing in it',
                     decides: 'that "nothing" is the situation, not a false value',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def nothing_in?',
                     inference: :nothing_in?, override: 'nothing',
                     grade: :structural, owned_by: :runtime),
      Convention.new(name: :root_class, when_silent: 'a promoted word with a single root',
                     decides: 'that the root node carries the word\'s own class',
                     file: 'lib/slim_pickins/builder.rb', marker: 'class_base',
                     inference: nil, override: 'nothing',
                     grade: :structural, owned_by: :runtime),
      Convention.new(name: :link_href, when_silent: '`link show`',
                     decides: '`href="/show"`',
                     file: 'lib/slim_pickins/generator.rb', marker: 'def link',
                     inference: nil, override: '`to:`',
                     grade: :structural),
      Convention.new(name: :option_selected, when_silent: '`choice` over a value',
                     decides: 'which option is selected, by comparing value to value',
                     file: 'lib/slim_pickins/generator.rb', marker: 'def option',
                     inference: nil, override: 'nothing',
                     grade: :structural),
      Convention.new(name: :button_type, when_silent: 'a button inside a form',
                     decides: '`type="submit"`; outside one, `type="button"`',
                     file: 'lib/slim_pickins/generator.rb', marker: 'def button',
                     inference: nil, override: '`type:`',
                     grade: :structural),
      Convention.new(name: :group_shape, when_silent: '`group` inside a form',
                     decides: 'fieldset and legend; outside one, a div and an h2',
                     file: 'lib/slim_pickins/generator.rb', marker: 'def group',
                     inference: nil, override: 'nothing',
                     grade: :structural),
      Convention.new(name: :box_body_over_children,
                     when_silent: 'a box that was given content',
                     decides: 'that the body renders *instead of* the children',
                     file: 'lib/slim_pickins/generator.rb', marker: 'def box',
                     inference: nil, override: 'give the box children and no content',
                     grade: :structural),
      Convention.new(name: :badge_status, when_silent: '`badge .status`',
                     decides: 'the variant class, when the body names a known status',
                     file: 'lib/slim_pickins/generator.rb', marker: 'KNOWN_STATUSES',
                     inference: nil, override: 'name the variant: `badge ok`',
                     grade: :structural),
      Convention.new(name: :partial_slot_forwarding,
                     when_silent: 'a partial declares a modifier the call did not say',
                     decides: 'that the value is sought up the chain — how `actions path:` reaches `action`',
                     file: 'lib/slim_pickins/subject.rb', marker: 'def container_value',
                     inference: nil, override: 'say it on the child instead',
                     grade: :structural),

      # --- shape: the value's class decides ---------------------------------
      Convention.new(name: :input_type, when_silent: '`field x` over a value',
                     decides: 'the input type, from the value\'s class',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def input_type',
                     inference: :input_type, override: '`type:`',
                     grade: :shape),
      Convention.new(name: :input_step, when_silent: 'a float below one',
                     decides: '`step="0.01"`',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def step_for',
                     inference: :step_for, override: '`step:`',
                     grade: :shape),
      Convention.new(name: :numeric_alignment, when_silent: 'a column or cell holding a number',
                     decides: 'right alignment',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def presentation',
                     inference: :presentation, override: 'nothing — it follows from being a number',
                     grade: :shape),
      Convention.new(name: :format_family, when_silent: 'a cell or a chart point',
                     decides: 'number, percent or money, from the value',
                     file: 'lib/slim_pickins/generator.rb', marker: 'def self.format',
                     inference: nil, override: '`as:`',
                     grade: :shape),
      Convention.new(name: :number_text, when_silent: 'a formatted value',
                     decides: 'grouped digits, the currency sign, the percent scale',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def money',
                     inference: %i[money percent number],
                     override: 'nothing a page should say',
                     grade: :shape),
      Convention.new(name: :time_text, when_silent: '`time .stamp`',
                     decides: 'the rendered date, and the machine `datetime` attribute',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def moment',
                     inference: :moment, override: '`time relative, .stamp`',
                     grade: :shape),
      Convention.new(name: :boolean_field, when_silent: '`field x` over a true/false value',
                     decides: 'that the field is a checkbox, because a value that is already true or false knows the shape it wants',
                     file: 'lib/slim_pickins/inference.rb', marker: 'def boolean?',
                     inference: :boolean?, override: '`type: text`',
                     grade: :shape),
      Convention.new(name: :leaf_tag, when_silent: '`money`, `percent`, `badge`, `time`',
                     decides: 'the element — a span, or a time',
                     file: 'lib/slim_pickins/generator.rb', marker: 'SPAN_TAGS',
                     inference: nil, override: 'nothing',
                     grade: :shape),

      # --- domain: the app must be asked ------------------------------------
      Convention.new(name: :label, when_silent: '`field x`, `column x`, `metric x`',
                     decides: 'the human label — the page, then the app, then English',
                     file: 'lib/slim_pickins/builder.rb', marker: 'def label_for',
                     inference: :label, override: 'say the label in the page',
                     grade: :domain),
      Convention.new(name: :format, when_silent: '`column x`, `metric x`',
                     decides: 'the presentation — `as:`, then the app, then the value\'s shape',
                     file: 'lib/slim_pickins/builder.rb', marker: 'def format_of',
                     inference: nil, override: '`as:`',
                     grade: :domain),
      Convention.new(name: :table_header, when_silent: 'a table\'s header row',
                     decides: 'the header — the row, then the enclosing subject, then English',
                     file: 'lib/slim_pickins/builder.rb', marker: 'def label_of',
                     inference: nil, override: 'say the header on the column',
                     grade: :domain),

      # --- axiomatic: the design's own standing decisions --------------------
      Convention.new(name: :theme_roles,
                     when_silent: 'a page wants a different measure, density or emphasis',
                     decides: 'NOTHING — the theme owns 53 roles and no page can say one. ' \
                              'This is the absent grade, registered so it cannot be forgotten',
                     file: 'assets/slim-pickins.css', marker: '--measure',
                     inference: nil,
                     override: 'none exists — a word must carry it, or an app word through the hatch',
                     grade: :axiomatic, owned_by: :page)
    ].freeze

    # `Inference`'s public functions that no page meets directly: live inside
    # the runtime (`relative` is reached by `moment`, `separated` by `money`
    # and `number`). `boolean?` was here until 2026-09-17, when dan ruled the
    # feature it was written for and it became `boolean_field` above — the
    # partition check is what noticed it had been claimed twice.
    INTERNAL = {
      relative: 'reached only by `moment`, through the `relative` variant',
      separated: 'the digit grouping `money` and `number` share',
      truthy?: 'internal truthiness check used by sentence guards and when conditions'
    }.freeze

    def self.by_grade(grade) = ALL.select { |c| c.grade == grade }

    # The `conventions` bullet of a word's vocabulary entry, generated from the
    # word's own declaration (2026-09-17). This is the reference shape's payoff:
    # the prose below lives once, in the register, and a word's entry *shows* the
    # conventions it triggers instead of restating them. A word that declares
    # none gets no bullet, which is a fact worth being able to see.
    def self.bullet(contract)
      names = Array(contract.infers)
      return nil if names.empty?

      entries = names.filter_map { |name| ALL.find { |c| c.name == name } }
      text = entries.map do |convention|
        clause = "`#{convention.name}` — #{convention.decides}"
        override = convention.override.to_s
        clause += " (override: #{override})" unless override.start_with?('nothing') || override.empty?
        clause
      end.join('; ')
      "- **conventions** — #{text}"
    end
  end
end
