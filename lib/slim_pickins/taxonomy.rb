# frozen_string_literal: true

require 'set'

module SlimPickins
  # The Single Source of Truth for the language's deductive authoring taxonomy
  # and empirical diagnostic instrument.
  #
  # Formulated in DAYTRIP-0.4.0d (Volet 4) to solve Authoring Pain Point 1:
  # moving beyond a flat, alphabetical 64-word list into a structured,
  # deductive authoring hierarchy.
  #
  # Crucially, this taxonomy is an EMPIRICAL DIAGNOSTIC TEST of the language:
  #   1. Porosity: Words in multiple categories appear in all of them; boundaries
  #      are recognized as naturally blurred rather than artificial silos.
  #   2. Cohesion vs. Split: Every multi-category word is assessed for whether
  #      it represents a unified concept or an overloaded candidate for splitting.
  #   3. Missing Primitives: Surfaces missing structural layout axioms (e.g. `stack`).
  #   4. Ad-hoc Anomalies: Pinpoints words that are single-consumer HTML element
  #      leaks (e.g. `figcaption`, `summary`).
  #   5. Visual Tier Idiom: Audits the principle that words describe meaning and
  #      structure, not paint, confirming that visual presentation belongs to
  #      the theme/variant idiom.
  module Taxonomy
    TIERS = {
      structural: {
        name: :structural,
        title: 'Structure & Layout',
        question: 'What is the skeleton, geometry, or layout container?',
        summary: 'Scaffolding, layout geometry, document regions, and composition slots.'
      },
      semantic: {
        name: :semantic,
        title: 'Meaning & Domain',
        question: 'What does this content mean or represent?',
        summary: 'Domain data, typography, quantitative measures, and relational information.'
      },
      interactive: {
        name: :interactive,
        title: 'Controls & Actions',
        question: 'How does the user interact, input data, or trigger an action?',
        summary: 'Affordances, buttons, input controls, query fields, and toggles.'
      },
      behavioral: {
        name: :behavioral,
        title: 'Flow, State & Dispatch',
        question: 'How does the page react, branch, iterate, or submit?',
        summary: 'Collection iteration, conditionals, emptiness presence, and form coordination.'
      },
      visual: {
        name: :visual,
        title: 'Surfaces & Chrome',
        question: 'How is information surfaced, framed, or styled?',
        summary: 'Bounded surfaces, chrome assets, viewport embeds, and status styling.'
      }
    }.freeze

    Entry = Struct.new(
      :word,
      :tiers,
      :primary_tier,
      :role,
      :diagnostic,
      :cohesion,
      :note,
      keyword_init: true
    )

    ENTRIES = {
      # --- Document & Scaffolding ---
      page: Entry.new(
        word: :page,
        tiers: %i[structural behavioral],
        primary_tier: :structural,
        role: 'Document root container and application context host',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Naturally bridges document structure with root application state resolution.'
      ),
      contents: Entry.new(
        word: :contents,
        tiers: %i[structural],
        primary_tier: :structural,
        role: 'Layout hole marker where view template splices into chrome',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Pure single-purpose structural reuse primitive.'
      ),
      children: Entry.new(
        word: :children,
        tiers: %i[structural],
        primary_tier: :structural,
        role: 'Partial composition slot marker for caller block content',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Pure partial composition primitive.'
      ),
      section: Entry.new(
        word: :section,
        tiers: %i[structural semantic],
        primary_tier: :structural,
        role: 'Major document region labelled by heading or subject',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Combines landmark structure with semantic heading inference.'
      ),
      group: Entry.new(
        word: :group,
        tiers: %i[structural interactive],
        primary_tier: :structural,
        role: 'Logical grouping container or form fieldset',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Groups controls or sections together under a shared label.'
      ),
      grid: Entry.new(
        word: :grid,
        tiers: %i[structural],
        primary_tier: :structural,
        role: 'Multi-column 2D grid layout with column specification',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core 2D layout primitive.'
      ),
      box: Entry.new(
        word: :box,
        tiers: %i[structural visual],
        primary_tier: :structural,
        role: 'Generic layout container, surface wrapper, or title host',
        diagnostic: :candidate_for_split,
        cohesion: :overloaded,
        note: 'Overloaded: serves as a div fallback, layout box, and box_title host. Candidate for splitting into stack and surface.'
      ),
      aside: Entry.new(
        word: :aside,
        tiers: %i[structural],
        primary_tier: :structural,
        role: 'Sidebar landmark region for secondary or tangential content',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Semantic HTML5 landmark structure.'
      ),
      nav: Entry.new(
        word: :nav,
        tiers: %i[structural interactive],
        primary_tier: :structural,
        role: 'Navigation landmark region enclosing link affordances',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Landmark structure dedicated to navigation affordances.'
      ),
      footer: Entry.new(
        word: :footer,
        tiers: %i[structural],
        primary_tier: :structural,
        role: 'Footer landmark region for page or container metadata',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Standard document landmark.'
      ),
      list: Entry.new(
        word: :list,
        tiers: %i[structural],
        primary_tier: :structural,
        role: 'Sequential vertical container enclosing items',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Enclosing container for list items.'
      ),
      item: Entry.new(
        word: :item,
        tiers: %i[structural semantic],
        primary_tier: :structural,
        role: 'Individual element wrapper inside a list',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Structural member registering an item within a list.'
      ),
      scroll: Entry.new(
        word: :scroll,
        tiers: %i[structural visual],
        primary_tier: :structural,
        role: 'Overflow-constrained scrollable viewport container',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Constrains layout geometry and enables visual overflow scrolling.'
      ),
      card: Entry.new(
        word: :card,
        tiers: %i[structural visual semantic],
        primary_tier: :structural,
        role: 'Self-contained entity container, subject-scope shifter, and elevated visual surface',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Exemplary multi-category word: shifting subject scope (R3P2) and visual elevation are one cohesive metaphor.'
      ),

      # --- Semantic & Typography ---
      title: Entry.new(
        word: :title,
        tiers: %i[semantic structural],
        primary_tier: :semantic,
        role: 'Document or section heading inferring level from nesting depth',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'High-level title that infers HTML heading depth from tree structure.'
      ),
      heading: Entry.new(
        word: :heading,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Explicit semantic heading block',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Atomic heading primitive under title.'
      ),
      paragraph: Entry.new(
        word: :paragraph,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Paragraph block holding prose or sentences',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Standard atomic prose block.'
      ),
      prose: Entry.new(
        word: :prose,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Rich text block rendering markdown or formatted copy',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Rich text presenter parsing markdown or raw text.'
      ),
      text: Entry.new(
        word: :text,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Plain text line or inline phrasing run',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Leaf text presenter.'
      ),
      span: Entry.new(
        word: :span,
        tiers: %i[semantic visual],
        primary_tier: :semantic,
        role: 'Inline phrasing run with variant styling',
        diagnostic: :candidate_for_split,
        cohesion: :styling_leak,
        note: 'Frequently abused as a styling escape hatch; points toward missing semantic variants.'
      ),
      note: Entry.new(
        word: :note,
        tiers: %i[semantic visual],
        primary_tier: :semantic,
        role: 'Advisory callout or annotation with tone variant (quiet, warning, alert)',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Domain advice with theme-governed visual tone.'
      ),
      metric: Entry.new(
        word: :metric,
        tiers: %i[semantic visual],
        primary_tier: :semantic,
        role: 'Key performance indicator (KPI) pairing label with prominent value',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Domain figure paired with prominent hero typography.'
      ),
      fact: Entry.new(
        word: :fact,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Key-value metadata pair describing an attribute of the subject',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Compact metadata presentation.'
      ),
      table: Entry.new(
        word: :table,
        tiers: %i[semantic structural behavioral],
        primary_tier: :semantic,
        role: 'Relational data table inferring columns, row iteration, and layout',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Richly multi-category: represents relational data, renders 2D grid, and iterates rows implicitly.'
      ),
      column: Entry.new(
        word: :column,
        tiers: %i[semantic structural],
        primary_tier: :semantic,
        role: 'Data dimension specification registering header and formatting',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Registers a named property on the enclosing table.'
      ),
      total: Entry.new(
        word: :total,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Summary row aggregating or summing a table column',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Calculates or displays column aggregation.'
      ),
      money: Entry.new(
        word: :money,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Currency-formatted numeric amount with locale conventions',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Domain presentation word for financial amounts.'
      ),
      percent: Entry.new(
        word: :percent,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Percentage-formatted ratio or fraction',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Domain presentation word for ratios.'
      ),
      number: Entry.new(
        word: :number,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Formatted numeric value with thousands separators and precision',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'General formatted numeric value.'
      ),
      time: Entry.new(
        word: :time,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Formatted timestamp, date, or relative elapsed interval',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Temporal value presenter.'
      ),
      chart: Entry.new(
        word: :chart,
        tiers: %i[semantic visual],
        primary_tier: :semantic,
        role: 'Quantitative data visualization gathering series and thresholds',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Gathers series into an SVG visual representation.'
      ),
      band: Entry.new(
        word: :band,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Data range or confidence area registered within a chart',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Chart layer registering a 2D range.'
      ),
      line: Entry.new(
        word: :line,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Data trend curve registered within a chart',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Chart layer registering a 1D trajectory.'
      ),
      level: Entry.new(
        word: :level,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Reference threshold or tax bracket registered within a chart',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Chart layer registering a benchmark.'
      ),
      snippet: Entry.new(
        word: :snippet,
        tiers: %i[semantic visual],
        primary_tier: :semantic,
        role: 'Formatted code specimen with syntax display',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Technical code display.'
      ),
      figure: Entry.new(
        word: :figure,
        tiers: %i[semantic structural],
        primary_tier: :semantic,
        role: 'Self-contained visual illustration paired with an optional caption',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Structural enclosure for media and caption.'
      ),
      figcaption: Entry.new(
        word: :figcaption,
        tiers: %i[semantic],
        primary_tier: :semantic,
        role: 'Caption text specifically nested under a figure',
        diagnostic: :ad_hoc,
        cohesion: :single_consumer,
        note: 'Ad-hoc anomaly: in-degree 1 (sole consumer is figure.sp). A raw HTML element leak in the kernel.'
      ),

      # --- Interactive Controls & Affordances ---
      button: Entry.new(
        word: :button,
        tiers: %i[interactive behavioral],
        primary_tier: :interactive,
        role: 'Clickable command trigger supporting variants and formaction dispatch',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Primary action trigger with HTML5 submission dispatch capability.'
      ),
      link: Entry.new(
        word: :link,
        tiers: %i[interactive],
        primary_tier: :interactive,
        role: 'Hypertext navigation anchor pointing to destination URI',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Standard navigational affordance.'
      ),
      action: Entry.new(
        word: :action,
        tiers: %i[interactive],
        primary_tier: :interactive,
        role: 'Single action item registered inside an actions toolbar',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Toolbar item affordance.'
      ),
      actions: Entry.new(
        word: :actions,
        tiers: %i[interactive structural behavioral],
        primary_tier: :interactive,
        role: 'Action toolbar clustering buttons and unifying multi-action submissions (R3P3)',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Cohesive multi-category word: cluster layout + action group + single-form dispatch.'
      ),
      field: Entry.new(
        word: :field,
        tiers: %i[interactive semantic],
        primary_tier: :interactive,
        role: 'Intelligent form control inferring input type, label, and value from subject',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Flagship interaction word: infers widget, label, and binding mechanically.'
      ),
      input: Entry.new(
        word: :input,
        tiers: %i[interactive],
        primary_tier: :interactive,
        role: 'Bare unlabelled form input element',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Elemental interactive atom under field.'
      ),
      textarea: Entry.new(
        word: :textarea,
        tiers: %i[interactive semantic],
        primary_tier: :interactive,
        role: 'Multi-line text input control with row height and label inference',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Multi-line text entry control.'
      ),
      checkbox: Entry.new(
        word: :checkbox,
        tiers: %i[interactive semantic],
        primary_tier: :interactive,
        role: 'Boolean toggle input control inferring checked state from subject',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Boolean affordance.'
      ),
      choice: Entry.new(
        word: :choice,
        tiers: %i[interactive semantic],
        primary_tier: :interactive,
        role: 'Dropdown or radio selection control gathering options',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Selection affordance over a discrete set of options.'
      ),
      option: Entry.new(
        word: :option,
        tiers: %i[interactive semantic],
        primary_tier: :interactive,
        role: 'Selectable value item registered within a choice control',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Child item of choice.'
      ),
      search: Entry.new(
        word: :search,
        tiers: %i[interactive structural],
        primary_tier: :interactive,
        role: 'Search query input box with target destination',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Specialized query input control.'
      ),
      tab: Entry.new(
        word: :tab,
        tiers: %i[interactive structural],
        primary_tier: :interactive,
        role: 'Clickable tab selector trigger and associated panel container',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Dual role: button affordance to switch views and structural panel.'
      ),
      disclosure: Entry.new(
        word: :disclosure,
        tiers: %i[interactive behavioral structural],
        primary_tier: :interactive,
        role: 'Collapsible details container with interactive open/close toggle',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Cohesive HTML5 details paradigm: toggle + open state + body container.'
      ),
      summary: Entry.new(
        word: :summary,
        tiers: %i[interactive semantic],
        primary_tier: :interactive,
        role: 'Summary label and toggle trigger specifically inside disclosure',
        diagnostic: :ad_hoc,
        cohesion: :single_consumer,
        note: 'Ad-hoc anomaly: in-degree 1 (sole consumer is disclosure.sp). A raw HTML element leak in the kernel.'
      ),

      # --- Behavioral State & Dispatch ---
      each: Entry.new(
        word: :each,
        tiers: %i[behavioral structural],
        primary_tier: :behavioral,
        role: 'Collection iteration binding each element as the innermost subject',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Grammar control flow: iterates collections and shifts subject scope.'
      ),
      empty: Entry.new(
        word: :empty,
        tiers: %i[behavioral semantic],
        primary_tier: :behavioral,
        role: 'Situation naming: renders only when enclosing collection is empty, suppressing siblings',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Quintessential Slim-Pickins word: names a state situation rather than writing a branch.'
      ),
      choose: Entry.new(
        word: :choose,
        tiers: %i[behavioral],
        primary_tier: :behavioral,
        role: 'Multi-branch conditional container evaluating first truthy branch',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Structured decision tree.'
      ),
      when: Entry.new(
        word: :when,
        tiers: %i[behavioral],
        primary_tier: :behavioral,
        role: 'Conditional branch executing when its predicate holds',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Truth branch in choose.'
      ),
      otherwise: Entry.new(
        word: :otherwise,
        tiers: %i[behavioral],
        primary_tier: :behavioral,
        role: 'Fallback conditional branch executing when no preceding when branch matched',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Default branch in choose.'
      ),
      form: Entry.new(
        word: :form,
        tiers: %i[behavioral interactive structural],
        primary_tier: :behavioral,
        role: 'Form submission coordinator managing action, method, and input scoping',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Submission boundary and dispatch coordinator.'
      ),
      hidden: Entry.new(
        word: :hidden,
        tiers: %i[behavioral interactive],
        primary_tier: :behavioral,
        role: 'Silent state payload input passed through form submission',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Form submission state carrier.'
      ),
      flash: Entry.new(
        word: :flash,
        tiers: %i[behavioral semantic visual],
        primary_tier: :behavioral,
        role: 'Transient feedback state message from previous action',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Session state presentation.'
      ),
      tabs: Entry.new(
        word: :tabs,
        tiers: %i[behavioral structural],
        primary_tier: :behavioral,
        role: 'Tab group coordinator managing active tab switching state',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Coordinates active tab selection across child panels.'
      ),

      # --- Visual Surfaces & Assets ---
      badge: Entry.new(
        word: :badge,
        tiers: %i[visual semantic],
        primary_tier: :visual,
        role: 'Visual status chip or pill with semantic state coloring (ok, warn, bad)',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Visual indicator of domain status; demonstrates how visual dress serves semantic status.'
      ),
      stylesheet: Entry.new(
        word: :stylesheet,
        tiers: %i[visual structural],
        primary_tier: :visual,
        role: 'Theme stylesheet inclusion linking CSS design tokens and rules',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Visual theme infrastructure.'
      ),
      script: Entry.new(
        word: :script,
        tiers: %i[visual interactive],
        primary_tier: :visual,
        role: 'Client-side script inclusion linking behavior controllers',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Client-side script asset.'
      ),
      iframe: Entry.new(
        word: :iframe,
        tiers: %i[visual structural],
        primary_tier: :visual,
        role: 'Isolated foreign viewport frame embedding external HTML document',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Isolated visual viewport embed.'
      )
    }.freeze

    # Missing primitives diagnosed through the taxonomy
    MISSING_PRIMITIVES = [
      {
        name: :stack,
        tier: :structural,
        role: 'Vertical rhythm layout primitive injecting consistent gap between children',
        rationale: 'Every Layout axiom: authors currently abuse box or ad-hoc margins to achieve vertical flow.'
      },
      {
        name: :cluster,
        tier: :structural,
        role: 'Horizontal wrapping flex layout with uniform gap',
        rationale: 'Currently only available for buttons via actions; general inline wrapping lacks a word.'
      },
      {
        name: :sidebar,
        tier: :structural,
        role: 'Two-element layout where one element has intrinsic width and the other fills remaining space',
        rationale: 'Common layout pattern currently hand-rolled in apps (e.g. sidebar_layout in studio).'
      }
    ].freeze

    module_function

    def tiers
      TIERS
    end

    def entries
      ENTRIES
    end

    def entry(word)
      ENTRIES[word.to_sym]
    end

    # All words belonging to a tier (including multi-category words)
    def words_for_tier(tier)
      tier_sym = tier.to_sym
      ENTRIES.values.select { |e| e.tiers.include?(tier_sym) }.map(&:word).sort
    end

    # Words grouped by their primary tier
    def by_primary_tier
      grouped = Hash.new { |h, k| h[k] = [] }
      ENTRIES.each_value do |e|
        grouped[e.primary_tier] << e.word
      end
      grouped.transform_values(&:sort)
    end

    # Words grouped by every tier they belong to (words appear in all applicable tiers)
    def by_tier
      grouped = TIERS.keys.to_h { |k| [k, []] }
      ENTRIES.each_value do |e|
        e.tiers.each do |t|
          grouped[t] << e.word if grouped.key?(t)
        end
      end
      grouped.transform_values(&:sort)
    end

    # Words that belong to multiple categories (porosity)
    def multi_category_words
      ENTRIES.values.select { |e| e.tiers.size > 1 }.map(&:word).sort
    end

    # Assessment of cohesion vs split candidates
    def cohesion_ledger
      ENTRIES.values.group_by(&:cohesion)
    end

    # Ad-hoc anomalies (single-consumer holes in the kernel)
    def ad_hoc_words
      ENTRIES.values.select { |e| e.diagnostic == :ad_hoc }.map(&:word).sort
    end

    # Candidate words for splitting (overloaded or styling leaks)
    def split_candidates
      ENTRIES.values.select { |e| e.diagnostic == :candidate_for_split }.map(&:word).sort
    end

    # Missing primitives diagnosed by this exercise
    def missing_primitives
      MISSING_PRIMITIVES
    end
  end
end
