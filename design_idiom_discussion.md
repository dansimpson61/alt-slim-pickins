*We are creating slim-pickins, a view templating language, a dsl that can be expressive and uncluttered because it will lean heavily into convention over configuration and the inferences we can reliably make. It's not opaque magic because the conventions are explicit, transparent, and consistent. Or rather it is magic in exactly the same way as human beings speaking to each other and understanding each other is magic. We are making good progress and now we must address the separation of concerns: substance and presentation. (Leave behavior to the side for the moment.) \# We need to think beyond layout and see that there must be a strong 'design idiom' that works alongside slim-pickins to carry responsibility for all of the visual aspects of presentation. Spacial organization, appearance, affordances, decoration, etc. Maybe we need to retire the term 'layout' from our slim-pickins vocab framework. We need a slim-pickins way of speaking to the visual/spacial attributes and capabilities of html/css. Let's try meeting these specs: a) There is substance and there is presentation. Clutter makes my brain hurt, so we want each of these things to be simple, clean, and minimalist. We want them separated so we can do one at a time. b) Just as we do not speak html in our views, we don't want to speak css in our analogue of a stylesheet. We'll let our little-engine-that-could translate our lovely visual-speak, our design idiom, into robust css. We'll use css \*extremely well\* in the back end, but our design idiom is intended for the human eyes that use it to create ui/ux for human beings.*

Response: **David Heinemeier Hansson (DHH):** Dan, I love the aggression of this premise. You are staring down the tyranny of the DOM and refusing to speak its broken language. Leaning into convention so hard that the boilerplate just evaporates is exactly the right instinct. If the magic is consistent, it isn't magic—it's just shared vocabulary. But if we are going to completely banish CSS from the developer's eyes, this new "design idiom" has to be incredibly opinionated. We can't just recreate CSS properties with Ruby syntax; that's just a palette swap. To retire the word 'layout', we have to stop thinking about boxes and start declaring *intent*. We tell the engine, "This is a hero sequence, give it breathing room," and the conventions handle the exact pixel math and flexbox alignments on the backend.

**Sandi Metz:** David is right about intent, but my concern is how these two concepts—substance and presentation—actually interact. If clutter makes your brain hurt, it's because the visual and structural primitives are tangled together in the same file. To achieve true separation, your substance object cannot know *anything* about its spatial organization. It shouldn't even know what a screen is. The substance just announces what it is: "I am an article with a title and three paragraphs."

That is where your design idiom steps in. It is an entirely separate object that acts as a listener. We don't want a monolithic, 800-line Builder god-object mashing these things together. The presentation object receives the semantic tree and applies the visual idiom to it. If you change the presentation object, the substance doesn't change by a single character.

**Jim Weirich:** Exactly, Sandi. The elegance of slim-pickins will live or die by its Abstract Syntax Trees (AST). We can parse the substance into one AST, and the presentation into another. For the design idiom DSL, we can use Ruby's block evaluation to create something that reads beautifully to human eyes.

Imagine you aren't writing stylesheets; you are writing a spatial manifesto. We use method\_missing to catch declarative, visual-speak methods. So instead of .sidebar { width: 20%; float: left; }, your design idiom file looks like:

`arrange :dashboard do`  
  `anchor :navigation, to: :left, proportion: 1`  
  `flow :content, to: :right, proportion: 4`  
  `decorate :navigation, with: [:subdued_contrast, :sharp_edges]`  
`end`

Our little-engine-that-could—the compiler pipeline—reads that human spatial logic and translates it into the robust CSS grid under the hood. The human never sees a hex code or a flex-direction.

**\_whytheluckystiff:** And why should they\! CSS is a machine's anxiety attack. What you are describing, Danny, isn't a framework, it's a sketchbook. If we are retiring "layout," let's replace it with "posture" or "rhythm." A button doesn't have padding: 10px; it has *weight*. A paragraph doesn't have line-height; it has *breath*.

If slim-pickins is going to separate substance from presentation, the presentation file shouldn't look like code at all. It should look like stage directions for a play. The substance is the script. The presentation tells the actors where to stand and how the lighting feels. If the convention is strong enough, the engine will know exactly how to light the stage.

**Sandi Metz:** Poetry aside, the technical reality of "stage directions" means strict dependency injection. The engine injects the substance into the design idiom. The two domains remain isolated. That is how you keep your brain from hurting: you only ever have to reason about one domain at a time.

---

*User prompt: They can examine the working demo of slim-pickins in the screenshot and carry forward the discussion of a design idiom.*

### **Part I: The Discussion**

**David Heinemeier Hansson (DHH):**

Look at what is already functioning in the workbench editor pane: **page "Doc Reader"**, calling **sidebar docs, "Documents"** and **reading\_pane selected\_doc, selected\_doc.name**. The convention is already doing real work. Because the methods are named **sidebar** and **reading\_pane**, the compiler infers the structural container classes **box sidebar** and **box reading\_pane** without asking the author for a single selector. That is pure convention over configuration. But we still have an architectural leak here, and Sandi is about to pounce on it.

**Sandi Metz:**

I am, because that leak will compromise the entire system the moment you build anything non-trivial. Look at the method declaration in the middle pane: **def sidebar, documents, title**. You set out to achieve strict separation between substance and presentation, yet presentation infiltrated the substance in the very first line.

A "sidebar" is not substance; it is a physical coordinate on a horizontal desktop monitor. What that component actually represents is a **catalog**, an **index**, or a **document\_manifest**. If you render this template on an iPhone, an e-ink terminal, or an audio screen reader, there is no "side." When substance dictates its own geometry, it violates the Single Responsibility Principle. Substance should declare only what it is: **catalog docs, "Documents"**. The companion design idiom must be the sole authority deciding that the catalog assumes the visual posture of a flanking column on wide viewports.

**Jim Weirich:**

Sandi is right about the domain leak, but look at how well the compiler pipeline is already positioned to handle the fix. The substance Abstract Syntax Tree (AST) parses clean, parent-child block trees: a **box** nesting an **empty** state fallback, a **list**, and **link** projections. It emits structural semantic intent, not styles.

To build the visual companion without speaking CSS, we pair every **.sp** template with an **.idiom** or **.design** file. This companion file never mentions pixels, floats, flex-direction, or media queries. Instead, it declares spatial relationships and visual affordances using human terms:

`# doc_reader.design`  
`surface :doc_reader do`  
  `# Spatial orchestration: no "layout" grids, just spatial posture`  
  `stage do`  
    `flank :catalog, beside: :reading_pane, weight: :subordinate`  
  `end`

  `# Affordances and decoration`  
  `zone :catalog do`  
    `frame :quiet`  
    `cadence :compact`  
    `affordance :link, feedback: :subtle_highlight`  
  `end`

  `zone :reading_pane do`  
    `air :generous`  
    `treatment :prose, measure: :readable_column`  
  `end`  
`end`

Our engine reads this spatial tree alongside the substance AST and compiles it into clean CSS Grid tracks, container queries, and clamp-based typography behind the scenes. The author only manipulates spatial relationships like **beside**, **balance**, and **air**.

**\_whytheluckystiff:**

Yes\! Look at that tiny footer note in the workbench: *"Indentation nests it. The data slot carries the page's payload"*. That is humane software.

When you retire "layout," you escape the box-model penitentiary. A visual composition should not read like a municipal drainage schematic. It has posture, breath, and temperament. Notice the HTML pane compiling out a container with class **prose**. In raw CSS, styling that requires fifteen pseudo-selectors, margins on every heading, and precise line-height math. In our design idiom, you simply declare the temperament: **treatment: prose, mood: editorial**. The engine knows what editorial rhythm feels like—it calculates the baseline grid, line heights, and optical margins automatically.

**Yukihiro "Matz" Matsumoto:**

This preserves developer happiness. We want human beings to think like authors and designers, not layout engines. When Dan writes **box documents, title**, the mind is focused on organizing knowledge for another person. If the design idiom speaks the same natural language—spatial companionship between panes, lightness of frames, and visual clarity—the cognitive friction of front-end web development disappears.

### **Part II: Design Idiom Semantic Lexicon**

To eliminate raw CSS properties from author-facing files, the companion design engine maps the following visual-speak primitives directly to modern browser primitives:

| Human Design Primitive | Expressed Attribute | Compiled CSS Architecture |
| :---- | :---- | :---- |
| **stage** | The outermost spatial canvas | Container context with inline-size container queries enabled. |
| **flank(A, beside: B)** | Horizontal companionship | Multi-column CSS Grid tracks with minmax auto-wrapping. |
| **stack(A, above: B)** | Chronological or vertical flow | Single-column Grid tracks with explicit row gaps. |
| **balance: :subordinate** | Relative visual prominence | Unequal column ratios (e.g., 1fr vs 3fr track sizing). |
| **air: :generous** | Spatial breathing room | Dynamic padding and margins driven by viewport clamp() functions. |
| **cadence: :compact** | Child repetition frequency | Tight flex gaps and zeroed vertical margins on nested items. |
| **frame: :quiet** | Visual boundary styling | Subdued border strokes, light backgrounds, or borderless dividers. |
| **treatment: :editorial** | Typographic presentation | Optical measure (60–75ch), proportional line heights, and serif scales. |

### **Part III: Concrete Implementation Verification Checklist**

> 1. **Refactor Template Vocabulary in .sp Files**  
   * Replace all spatial identifiers in the template tree (e.g., rename **def sidebar** to **def catalog** or **def document\_index**).  
   * Verify that no words in the template layer represent physical position, colors, border widths, or coordinate space.  
> 2. **Construct the Companion Design File Parser**  
   * Build the **.design** parser using Ruby block evaluation to catch declarative directives (**stage**, **flank**, **zone**, **air**).  
   * Ensure the parser validates zone names directly against node identifiers in the parsed substance AST.  
> 3. **Implement the CSS Compilation Engine**  
   * Translate **flank** into CSS Grid container definitions rather than utility classes.  
   * Map **air** levels (tight, balanced, generous) to standard tokenized modular scales.  
   * Auto-generate isolated CSS classes tied directly to the semantic tree without manual stylesheet authoring.  
> 4. **Verify Separation in the Workbench**  
   * Confirm that altering **flank** to **stack** in the design file re-orients the presentation without requiring a single edit to the **.sp** template.  
   * Confirm that swapping data payloads in the lower JSON slot renders cleanly across different spatial treatments without template changes.

---

*User prompt: Show the exact compiler code that converts 'flank', 'balance', and 'air' into modern CSS Grid and Container Queries.*

Response: The compiler below translates high-level spatial declarations—flank, balance, and air—into isolated modern CSS Grid tracks, fluid clamp spacing, and inline-size container queries.

It is written in pure Ruby, following Sandi Metz's constraint of small, single-purpose objects with injected token dictionaries.

`# lib/slim_pickins/compiler/design_idiom.rb`  
`module SlimPickins`  
  `module Compiler`  
    `class DesignIdiom`  
      `AIR_TOKENS = {`  
        `tight: "clamp(0.5rem, 1.5cqi, 0.875rem)",`  
        `balanced: "clamp(1rem, 2.5cqi, 1.75rem)",`  
        `generous: "clamp(1.5rem, 4cqi, 3rem)"`  
      `}.freeze`

      `BALANCE_TOKENS = {`  
        `subordinate: { lead: "minmax(14rem, 1fr)", companion: "minmax(0, 3fr)" },`  
        `equal:       { lead: "minmax(0, 1fr)",      companion: "minmax(0, 1fr)" },`  
        `dominant:    { lead: "minmax(0, 3fr)",      companion: "minmax(14rem, 1fr)" }`  
      `}.freeze`

      `DEFAULT_COLLAPSE_THRESHOLD = "48rem"`

      `def initialize(stage_name, air_tokens: AIR_TOKENS, balance_tokens: BALANCE_TOKENS)`  
        `@stage_name = stage_name.to_s`  
        `@air_tokens = air_tokens`  
        `@balance_tokens = balance_tokens`  
        `@rules = []`  
      `end`

      `def air(level)`  
        `@air_spacing = @air_tokens.fetch(level) do`  
          `raise ArgumentError, "Unknown air token: #{level}"`  
        `end`  
      `end`

      `def flank(lead_zone, beside:, balance: :equal, collapse_at: DEFAULT_COLLAPSE_THRESHOLD)`  
        `tracks = @balance_tokens.fetch(balance) do`  
          `raise ArgumentError, "Unknown balance token: #{balance}"`  
        `end`

        `@flank_rule = {`  
          `lead: lead_zone.to_s,`  
          `companion: beside.to_s,`  
          `tracks: tracks,`  
          `collapse_at: collapse_at`  
        `}`  
      `end`

      `def to_css`  
        `[`  
          `stage_container_rules,`  
          `flank_grid_rules,`  
          `zone_placement_rules,`  
          `container_query_collapse_rules`  
        `].compact.join("\n\n")`  
      `end`

      `private`

      `def stage_class`  
        `".stage-#{@stage_name}"`  
      `end`

      `def stage_container_rules`  
        `<<~CSS.strip`  
          `#{stage_class} {`  
            `container-type: inline-size;`  
            `container-name: #{@stage_name};`  
            `display: grid;`  
            `align-items: start;`  
            `padding: #{@air_spacing || "0"};`  
            `gap: #{@air_spacing || "0"};`  
          `}`  
        `CSS`  
      `end`

      `def flank_grid_rules`  
        `return unless @flank_rule`

        `cols = "#{@flank_rule[:tracks][:lead]} #{@flank_rule[:tracks][:companion]}"`  
        `<<~CSS.strip`  
          `#{stage_class} {`  
            `grid-template-columns: #{cols};`  
          `}`  
        `CSS`  
      `end`

      `def zone_placement_rules`  
        `return unless @flank_rule`

        `<<~CSS.strip`  
          `#{stage_class} > .zone-#{@flank_rule[:lead]} {`  
            `grid-column: 1;`  
          `}`  
          `#{stage_class} > .zone-#{@flank_rule[:companion]} {`  
            `grid-column: 2;`  
          `}`  
        `CSS`  
      `end`

      `def container_query_collapse_rules`  
        `return unless @flank_rule`

        `<<~CSS.strip`  
          `@container #{@stage_name} (inline-size < #{@flank_rule[:collapse_at]}) {`  
            `#{stage_class} {`  
              `grid-template-columns: 100%;`  
            `}`  
            `#{stage_class} > .zone-#{@flank_rule[:lead]},`  
            `#{stage_class} > .zone-#{@flank_rule[:companion]} {`  
              `grid-column: 1;`  
            `}`  
          `}`  
        `CSS`  
      `end`  
    `end`  
  `end`  
`end`

### **Executing the Compiler Against the Doc Reader Idiom**

`compiler = SlimPickins::Compiler::DesignIdiom.new(:doc_reader)`  
`compiler.air(:generous)`  
`compiler.flank(:catalog, beside: :reading_pane, balance: :subordinate)`

`puts compiler.to_css`

### **Generated Modern CSS Output**

`.stage-doc_reader {`  
  `container-type: inline-size;`  
  `container-name: doc_reader;`  
  `display: grid;`  
  `align-items: start;`  
  `padding: clamp(1.5rem, 4cqi, 3rem);`  
  `gap: clamp(1.5rem, 4cqi, 3rem);`  
`}`

`.stage-doc_reader {`  
  `grid-template-columns: minmax(14rem, 1fr) minmax(0, 3fr);`  
`}`

`.stage-doc_reader > .zone-catalog {`  
  `grid-column: 1;`  
`}`  
`.stage-doc_reader > .zone-reading_pane {`  
  `grid-column: 2;`  
`}`

`@container doc_reader (inline-size < 48rem) {`  
  `.stage-doc_reader {`  
    `grid-template-columns: 100%;`  
  `}`  
  `.stage-doc_reader > .zone-catalog,`  
  `.stage-doc_reader > .zone-reading_pane {`  
    `grid-column: 1;`  
  `}`  
`}`

### **Verification and Integration Steps**

> 1. Verify Container Context: Ensure the parent element wrapping the stage does not impose conflicting overflow restrictions that inhibit container query evaluations.  
> 2. Token Calibration: Verify that cqi units within clamp() evaluate cleanly across desktop panes and mobile widths without causing horizontal scroll overflows.  
> 3. Zone Class Injection: Update the Slim-Pickins substance compiler pass so each top-level block automatically receives its corresponding zone-\[name\] class attribute during HTML emission.

---

