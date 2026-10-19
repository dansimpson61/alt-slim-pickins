# frozen_string_literal: true

require 'set'

module SlimPickins
  # The Single Source of Truth for the language's deductive authoring taxonomy,
  # ontological meta-architecture, and empirical diagnostic instrument.
  #
  # Refined in DAYTRIP-0.6.0j to replace the preliminary 5-tier presentation filing
  # cabinet with a multi-axial taxonomy governed by filter theory:
  #   1. The Three Ontological Planes: Linguistic & Execution, Composition & Spatial,
  #      and Mechanical Invariants.
  #   2. The Refined Categories & Sub-Categories: Substance, Skeleton, Affordances,
  #      Flow & Logic, and Environment.
  #   3. Bandpass Filter Diagnostics: Passband width, boundary selectivity, and
  #      polyhierarchical resonance across the 63 canonical words.
  module Taxonomy
    # The Three Ontological Planes of alt-slim-pickins
    PLANES = {
      linguistic: {
        name: :linguistic,
        title: 'Linguistic & Execution Plane',
        summary: 'The lexicon, grammar, and execution tokens of the template language.',
        terms: %i[word primitive composed_word def]
      },
      spatial: {
        name: :spatial,
        title: 'Composition & Spatial Plane',
        summary: 'The spatial canvases, outer chrome envelopes, stylesheets, and route substance.',
        terms: %i[frame layout style substance]
      },
      invariant: {
        name: :invariant,
        title: 'Mechanical Invariant Plane',
        summary: 'The three instruments of truth governing grammar, runtime inference, and feature verification.',
        terms: %i[contract convention promise]
      }
    }.freeze

    # Refined Deductive Vocabulary Categories
    CATEGORIES = {
      substance: {
        name: :substance,
        title: 'Substance (Domain Content & Phrasing)',
        question: 'What domain content, quantitative data, or phrasing does this express?',
        summary: 'Domain data, typography, quantitative measures, and phrasing.',
        sub_categories: {
          typography: 'Typography, phrasing, and text annotations (heading, paragraph, text, note, flash, prose, snippet, title, span)',
          data: 'Data, metrics, numbers, and value badges (metric, fact, number, money, percent, time, badge, dictionary, total)'
        }
      },
      skeleton: {
        name: :skeleton,
        title: 'Skeleton (Structure & Framing)',
        question: 'What structural skeleton, container boundary, or collection orders the canvas?',
        summary: 'Landmark regions, containers, surfaces, collections, and tabular grids.',
        sub_categories: {
          landmarks: 'Document landmark regions (section, aside, nav, footer)',
          containers: 'Surface boundaries, entity wrappers, and viewports (box, card, figure, group, scroll)',
          collections: 'Sequential collections, tables, and relational grids (list, item, table, column, grid, chart, band, line, level)'
        }
      },
      affordances: {
        name: :affordances,
        title: 'Affordances (Controls & Interactions)',
        question: 'How does the user interact, input data, or navigate the application?',
        summary: 'Interactive affordances, action triggers, navigation links, and input fields.',
        sub_categories: {
          actions: 'Action triggers, buttons, and navigation links (link, button, actions, action, tabs, tab)',
          inputs: 'Form controls, user inputs, and transport fields (form, field, input, choice, option, search, checkbox, hidden, textarea, on)'
        }
      },
      flow: {
        name: :flow,
        title: 'Flow & Logic (State & Behavior)',
        question: 'How does the template iterate, branch, or disclose state?',
        summary: 'Collection iteration, conditionals, emptiness fallback, and disclosure state.',
        sub_categories: {
          iteration: 'Collection loops and empty state handling (each, empty)',
          branching: 'Condition evaluation and choice branches (choose, when, otherwise)',
          disclosure: 'Interactive disclosure and collapsible state (disclosure)'
        }
      },
      environment: {
        name: :environment,
        title: 'Environment (Document & Splicing)',
        question: 'How is the document framed, resourced, and spliced into the outer context?',
        summary: 'Document root, outer chrome, resource links, raw elements, and slot splicing.',
        sub_categories: {
          resources: 'Document assets, external scripts, and styles (stylesheet, script, iframe)',
          splicing: 'Slot splicing and collection mapping (contents, map)'
        }
      }
    }.freeze

    # Legacy alias for Studio shelf navigation
    TIERS = CATEGORIES

    # Single Source of Truth for System Taxonomy Terms across the 3 planes
    SystemTerm = Struct.new(:name, :plane, :summary, :definition, keyword_init: true)

    SYSTEM = {
      word: SystemTerm.new(
        name: :word,
        plane: :linguistic,
        summary: 'Fundamental syntax token',
        definition: 'The fundamental syntax unit of slim-pickins (word arguments, indentation nests). Everything on a page is a word (63 canonical + app words).'
      ),
      primitive: SystemTerm.new(
        name: :primitive,
        plane: :linguistic,
        summary: 'Ruby-implemented leaf word',
        definition: 'An atomic leaf word implemented directly in Ruby as a subclass of SlimPickins::Word (37 canonical primitives).'
      ),
      composed_word: SystemTerm.new(
        name: :composed_word,
        plane: :linguistic,
        summary: 'Template-defined first-class word',
        definition: 'A first-class word defined in .sp syntax using def in lib/vocabulary/ (26 canonical composed words, formerly called partials).'
      ),
      def: SystemTerm.new(
        name: :def,
        plane: :linguistic,
        summary: 'Word definition keyword',
        definition: "The language keyword that defines a composed word and its parameter list: `def word_name subject, kwargs`."
      ),
      frame: SystemTerm.new(
        name: :frame,
        plane: :spatial,
        summary: 'Document envelope chrome',
        definition: 'The outer HTML document chrome (.frame, formerly .tin), defining <head>, shell, navigation, and asset envelopes with contents marking the body hole.'
      ),
      layout: SystemTerm.new(
        name: :layout,
        plane: :spatial,
        summary: 'Spatial stylesheet companion',
        definition: 'The spatial companion stylesheet language (.layout, formerly .spiff), compiling spatial declarations (horizon, flank, stack, grid) to CSS.'
      ),
      style: SystemTerm.new(
        name: :style,
        plane: :spatial,
        summary: 'Theme-role companion',
        definition: 'The theme-role companion (.style), compiling sayable theme roles (measure, gap, density) to :root custom properties.'
      ),
      substance: SystemTerm.new(
        name: :substance,
        plane: :spatial,
        summary: 'Route body template',
        definition: 'The route-level body template (.sp) answering a request and filling contents inside the frame.'
      ),
      contract: SystemTerm.new(
        name: :contract,
        plane: :invariant,
        summary: 'Compile-time syntactic grammar',
        definition: 'The compile-time syntactic grammar (takes, holds, modifiers, shape), enforced by the gate before render.'
      ),
      convention: SystemTerm.new(
        name: :convention,
        plane: :invariant,
        summary: 'Runtime inference engine',
        definition: 'The runtime inference engine (38 conventions) governing defaults when an author stays silent.'
      ),
      promise: SystemTerm.new(
        name: :promise,
        plane: :invariant,
        summary: 'Feature verification ledger',
        definition: 'The feature verification ledger (32 promises) proving declared modifiers have active readers in code.'
      )
    }.freeze

    Entry = Struct.new(
      :word,
      :categories,
      :primary_category,
      :sub_category,
      :role,
      :diagnostic,
      :cohesion,
      :note,
      keyword_init: true
    ) do
      def tiers = categories
      def primary_tier = primary_category
    end

    FilterAnalysis = Struct.new(
      :passband_widths,
      :boundary_selectivity,
      :polyhierarchical_resonance,
      :crossover_matrix,
      keyword_init: true
    )

    ENTRIES = {
      # --- Substance: Typography ---
      heading: Entry.new(
        word: :heading,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Direct heading element at specific or inferred level',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core typography primitive.'
      ),
      paragraph: Entry.new(
        word: :paragraph,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Body prose paragraph',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core typography primitive.'
      ),
      text: Entry.new(
        word: :text,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Leaf text run without surrounding block element',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Raw text phrasing atom.'
      ),
      note: Entry.new(
        word: :note,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Callout note or annotation with quiet or warning tone',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Typography phrasing atom.'
      ),
      flash: Entry.new(
        word: :flash,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Notification and alert banner message',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Status message phrasing.'
      ),
      prose: Entry.new(
        word: :prose,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Rich prose or markdown formatted text block',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Typography block presenter.'
      ),
      snippet: Entry.new(
        word: :snippet,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Formatted code snippet block with language notation',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Typography block with code notation.'
      ),
      title: Entry.new(
        word: :title,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Document or section heading inferring level from nesting depth',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'High-level title inferring heading level from tree structure.'
      ),
      span: Entry.new(
        word: :span,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :typography,
        role: 'Generic inline text or data span wrapper',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Inline typography leaf.'
      ),

      # --- Substance: Data & Metrics ---
      metric: Entry.new(
        word: :metric,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :data,
        role: 'High-visibility quantitative KPI and value presentation',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Quantitative data substance atom.'
      ),
      fact: Entry.new(
        word: :fact,
        categories: %i[substance skeleton],
        primary_category: :substance,
        sub_category: :data,
        role: 'Single key-value definition atom',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Data presentation atom mapped to definition list structure.'
      ),
      number: Entry.new(
        word: :number,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :data,
        role: 'Delimited numeric value with scale formatting',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Domain data presentation atom.'
      ),
      money: Entry.new(
        word: :money,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :data,
        role: 'Currency-formatted value with symbol and precision',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Domain data presentation atom.'
      ),
      percent: Entry.new(
        word: :percent,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :data,
        role: 'Percentage-formatted numeric value with scale sign',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Domain data presentation atom.'
      ),
      time: Entry.new(
        word: :time,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :data,
        role: 'Timestamp or relative date formatted value in time tag',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Domain data presentation atom.'
      ),
      badge: Entry.new(
        word: :badge,
        categories: %i[substance affordances],
        primary_category: :substance,
        sub_category: :data,
        role: 'Visual status indicator and quantitative badge',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Data presentation atom that may double as interactive pill.'
      ),
      dictionary: Entry.new(
        word: :dictionary,
        categories: %i[substance skeleton],
        primary_category: :substance,
        sub_category: :data,
        role: 'Key-value data presentation container',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Pairs structured data with definition layout.'
      ),
      total: Entry.new(
        word: :total,
        categories: %i[substance],
        primary_category: :substance,
        sub_category: :data,
        role: 'Aggregate total summary row or cell',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Data aggregation atom.'
      ),

      # --- Skeleton: Landmarks ---
      section: Entry.new(
        word: :section,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :landmarks,
        role: 'Major document region labelled by heading or subject',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Combines landmark structure with semantic heading inference.'
      ),
      aside: Entry.new(
        word: :aside,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :landmarks,
        role: 'Sidebar landmark region for secondary content',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Semantic landmark structure.'
      ),
      nav: Entry.new(
        word: :nav,
        categories: %i[skeleton affordances],
        primary_category: :skeleton,
        sub_category: :landmarks,
        role: 'Navigation landmark region enclosing link affordances',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Landmark structure dedicated to navigation affordances.'
      ),
      footer: Entry.new(
        word: :footer,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :landmarks,
        role: 'Footer landmark region for page or container metadata',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Standard document landmark.'
      ),

      # --- Skeleton: Containers ---
      box: Entry.new(
        word: :box,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :containers,
        role: 'Essential generic container, surface wrapper, or title host',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core structural boundary primitive.'
      ),
      card: Entry.new(
        word: :card,
        categories: %i[skeleton substance],
        primary_category: :skeleton,
        sub_category: :containers,
        role: 'Self-contained entity container and elevated visual surface',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Exemplary multi-category word: shifting subject scope and visual elevation.'
      ),
      figure: Entry.new(
        word: :figure,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :containers,
        role: 'Figure element container enclosing media and caption',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Self-contained semantic container.'
      ),
      group: Entry.new(
        word: :group,
        categories: %i[skeleton affordances],
        primary_category: :skeleton,
        sub_category: :containers,
        role: 'Logical grouping container or form fieldset',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Groups controls or sections together under a shared label.'
      ),
      scroll: Entry.new(
        word: :scroll,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :containers,
        role: 'Overflow-constrained scrollable viewport container',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Constrains layout geometry and enables overflow scrolling.'
      ),

      # --- Skeleton: Collections & Tabular ---
      list: Entry.new(
        word: :list,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Sequential vertical container enclosing items',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Enclosing container for list items.'
      ),
      item: Entry.new(
        word: :item,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Individual element wrapper inside a list',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Structural member registering an item within a list.'
      ),
      table: Entry.new(
        word: :table,
        categories: %i[skeleton substance],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Structured tabular data collection with columns and rows',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Tabular structure holding data substance.'
      ),
      column: Entry.new(
        word: :column,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Table column specification and alignment declaration',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Tabular structure member.'
      ),
      grid: Entry.new(
        word: :grid,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Multi-column 2D grid layout with column specification',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core 2D layout primitive.'
      ),
      chart: Entry.new(
        word: :chart,
        categories: %i[skeleton substance],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Visual data chart gathering quantitative bands and lines',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Combines structural gathering with quantitative data substance.'
      ),
      band: Entry.new(
        word: :band,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Horizontal reference band within a chart',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Tabular / chart sub-primitive.'
      ),
      line: Entry.new(
        word: :line,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Plotted line series inside a chart',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Chart sub-primitive.'
      ),
      level: Entry.new(
        word: :level,
        categories: %i[skeleton],
        primary_category: :skeleton,
        sub_category: :collections,
        role: 'Horizontal reference level inside a chart',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Chart sub-primitive.'
      ),

      # --- Affordances: Actions & Navigation ---
      link: Entry.new(
        word: :link,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :actions,
        role: 'Hyperlink navigation affordance',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core navigation affordance.'
      ),
      button: Entry.new(
        word: :button,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :actions,
        role: 'Clickable action affordance triggering command or form submission',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Direct interaction affordance.'
      ),
      actions: Entry.new(
        word: :actions,
        categories: %i[affordances skeleton],
        primary_category: :affordances,
        sub_category: :actions,
        role: 'Action toolbar container grouping buttons and links',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Bridges affordance grouping with container framing.'
      ),
      action: Entry.new(
        word: :action,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :actions,
        role: 'Inline action link or button invocation',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Affordance token for user-triggered interaction.'
      ),
      tabs: Entry.new(
        word: :tabs,
        categories: %i[affordances skeleton],
        primary_category: :affordances,
        sub_category: :actions,
        role: 'Tab navigation container and switcher',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Tab container grouping tab affordances.'
      ),
      tab: Entry.new(
        word: :tab,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :actions,
        role: 'Individual tab control inside a tabs bar',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Tab navigation affordance.'
      ),

      # --- Affordances: Inputs & Transport ---
      form: Entry.new(
        word: :form,
        categories: %i[affordances skeleton],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Interactive form submission boundary and parameter collector',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Bridges input affordance orchestration with container boundary.'
      ),
      field: Entry.new(
        word: :field,
        categories: %i[affordances skeleton],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Labelled form field wrapper with validation and inference',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Combines input affordance with label/container framing.'
      ),
      input: Entry.new(
        word: :input,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Raw input field affordance',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core input control.'
      ),
      choice: Entry.new(
        word: :choice,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Radio or select input option picker',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Input selection affordance.'
      ),
      option: Entry.new(
        word: :option,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Option element inside a choice picker',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Option member of a choice control.'
      ),
      search: Entry.new(
        word: :search,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Specialized search query field affordance',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Dedicated search input affordance.'
      ),
      checkbox: Entry.new(
        word: :checkbox,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Boolean toggle input affordance',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Form input control.'
      ),
      hidden: Entry.new(
        word: :hidden,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Hidden form input transporting state',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'State transport affordance.'
      ),
      textarea: Entry.new(
        word: :textarea,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Multi-line text input affordance',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Multi-line form input control.'
      ),
      on: Entry.new(
        word: :on,
        categories: %i[affordances],
        primary_category: :affordances,
        sub_category: :inputs,
        role: 'Event listener binding on an affordance',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Event binding affordance.'
      ),

      # --- Flow & Logic: Iteration, Branching, Disclosure ---
      each: Entry.new(
        word: :each,
        categories: %i[flow],
        primary_category: :flow,
        sub_category: :iteration,
        role: 'Collection iteration loop binding each member to subject scope',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core collection iteration primitive.'
      ),
      empty: Entry.new(
        word: :empty,
        categories: %i[flow substance],
        primary_category: :flow,
        sub_category: :iteration,
        role: 'Empty collection fallback state presenter',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Emptiness flow gate that speaks phrasing substance.'
      ),
      choose: Entry.new(
        word: :choose,
        categories: %i[flow],
        primary_category: :flow,
        sub_category: :branching,
        role: 'Conditional branching control selecting first truthy branch',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Core branching flow primitive.'
      ),
      when: Entry.new(
        word: :when,
        categories: %i[flow],
        primary_category: :flow,
        sub_category: :branching,
        role: 'Conditional branch inside a choose block',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Conditional branch primitive.'
      ),
      otherwise: Entry.new(
        word: :otherwise,
        categories: %i[flow],
        primary_category: :flow,
        sub_category: :branching,
        role: 'Fallback branch in a choose block',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Conditional fallback primitive.'
      ),
      disclosure: Entry.new(
        word: :disclosure,
        categories: %i[flow skeleton],
        primary_category: :flow,
        sub_category: :disclosure,
        role: 'Collapsible disclosure details container',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Bridges container framing with open/close state flow.'
      ),

      # --- Environment: Document, Resources, Splicing ---
      stylesheet: Entry.new(
        word: :stylesheet,
        categories: %i[environment],
        primary_category: :environment,
        sub_category: :resources,
        role: 'Stylesheet link resource tag in document head',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Document head environment resource.'
      ),
      script: Entry.new(
        word: :script,
        categories: %i[environment],
        primary_category: :environment,
        sub_category: :resources,
        role: 'External or inline script resource tag',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Document resource environment atom.'
      ),
      iframe: Entry.new(
        word: :iframe,
        categories: %i[environment],
        primary_category: :environment,
        sub_category: :resources,
        role: 'Embedded browsing context iframe viewport',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'External viewport embedding environment resource.'
      ),
      contents: Entry.new(
        word: :contents,
        categories: %i[environment],
        primary_category: :environment,
        sub_category: :splicing,
        role: 'Universal layout and composed word slot marker for stowed body',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Composition and splicing primitive across frames and composed words.'
      ),
      map: Entry.new(
        word: :map,
        categories: %i[environment],
        primary_category: :environment,
        sub_category: :splicing,
        role: 'Visual map embed or coordinate container',
        diagnostic: :sits_well,
        cohesion: :cohesive,
        note: 'Geographic and coordinate embedding resource.'
      )
    }.freeze

    # Layout and styling capabilities surfaced through the taxonomy diagnostics.
    MISSING_PRIMITIVES = [
      {
        name: :stack,
        category: :skeleton,
        role: 'Vertical rhythm layout capability injecting consistent gap between elements',
        rationale: 'Geometry/scaffolding belongs outside substance templates; consideration for .layout or styling layer.'
      },
      {
        name: :sidebar,
        category: :skeleton,
        role: 'Two-element arrangement where one element has intrinsic width and the other fills remaining space',
        rationale: 'Macro-layout pattern; belongs in .layout spatial zoning (horizon/flank) rather than template primitives.'
      }
    ].freeze

    module_function

    def planes
      PLANES
    end

    def categories
      CATEGORIES
    end
    def tiers = categories

    def entries
      ENTRIES
    end

    def entry(word)
      ENTRIES[word.to_sym]
    end

    # Words belonging to a category (including polyhierarchical members)
    def words_for_category(category)
      cat_sym = category.to_sym
      ENTRIES.values.select { |e| e.categories.include?(cat_sym) }.map(&:word).sort
    end
    def words_for_tier(category) = words_for_category(category)

    # Words grouped by their primary category
    def by_primary_category
      grouped = Hash.new { |h, k| h[k] = [] }
      ENTRIES.each_value do |e|
        grouped[e.primary_category] << e.word
      end
      grouped.transform_values(&:sort)
    end
    def by_primary_tier = by_primary_category

    # Words grouped by every category they belong to
    def by_category
      grouped = CATEGORIES.keys.to_h { |k| [k, []] }
      ENTRIES.each_value do |e|
        e.categories.each do |c|
          grouped[c] << e.word if grouped.key?(c)
        end
      end
      grouped.transform_values(&:sort)
    end
    def by_tier = by_category

    # Words that belong to multiple categories (polyhierarchical resonance)
    def multi_category_words
      ENTRIES.values.select { |e| e.categories.size > 1 }.map(&:word).sort
    end

    # Filter Theory Diagnostic Analysis
    def filter_analysis
      total_words = ENTRIES.size
      widths = CATEGORIES.keys.to_h do |cat|
        words = words_for_category(cat)
        [cat, { count: words.size, percentage: (words.size.to_f / total_words * 100).round(1), words: words }]
      end

      selectivity = CATEGORIES.keys.to_h do |cat|
        words = words_for_category(cat)
        exclusive = words.select { |w| entry(w).categories == [cat] }
        ratio = words.empty? ? 1.0 : (exclusive.size.to_f / words.size).round(2)
        [cat, { exclusive_count: exclusive.size, shared_count: words.size - exclusive.size, selectivity: ratio }]
      end

      resonance = multi_category_words.map do |w|
        e = entry(w)
        { word: w, categories: e.categories, primary: e.primary_category, cohesion: e.cohesion, note: e.note }
      end

      crossovers = {}
      cats = CATEGORIES.keys
      cats.combination(2) do |a, b|
        common = words_for_category(a) & words_for_category(b)
        crossovers[[a, b]] = common unless common.empty?
      end

      FilterAnalysis.new(
        passband_widths: widths,
        boundary_selectivity: selectivity,
        polyhierarchical_resonance: resonance,
        crossover_matrix: crossovers
      )
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

    def system_terms
      SYSTEM
    end

    def system_term(name)
      SYSTEM[name.to_sym]
    end
  end
end
