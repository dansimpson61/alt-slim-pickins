# **Tight Coupling in Ruby DSLs**

[https://gemini.google.com/app/a52c477f03d5b4d1](https://gemini.google.com/app/a52c477f03d5b4d1)

*User prompt: If I'm writing a DSL in Ruby, a templating language to replace erb, slim, haml, etc., would I say that my codebase and the emerging DSL are tightly coupled?*

Response: Whether your templating DSL and its underlying Ruby codebase are tightly coupled depends entirely on whether you are building an **internal** or **external** DSL, and how you architect the parsing pipeline.

**Internal DSLs (Pure Ruby Syntax)** If your DSL utilizes pure Ruby syntax (e.g., div { h1 "Hello" }, similar to Markaby or Arbre), it is an internal DSL.

> * **High Coupling:** The DSL and the codebase are intrinsically linked. The DSL is effectively just a set of Ruby methods and object scopes.  
> * **Context Reliance:** Because it relies on Ruby's metaprogramming—heavy use of instance\_eval, method\_missing, and block yields—the engine and the DSL cannot exist without each other. The host language limits and defines the DSL.

**External DSLs (Custom Syntax)** If your DSL uses a custom syntax that Ruby does not natively understand (like HAML's %div or Slim's div), it is an external DSL.

> * **Conceptual Decoupling:** The DSL is just a grammar. It exists independently of Ruby. You could theoretically write a parser for it in Rust or Go.  
> * **Implementation Coupling:** While your parser is tightly coupled to the specific grammar of your DSL, the rest of your codebase does not have to be.

**Architecting for Loose Coupling** Many developers building their first templating engine write a script that reads the DSL line-by-line and immediately concatenates HTML strings. This creates massive, rigid coupling.

Modern Ruby templating engines avoid this by treating the process as a compiler pipeline (often using the **Temple** framework, which powers Slim and HAML). This architecture creates loose coupling by breaking the process into isolated steps:

> * **Parser:** Reads your custom DSL and converts it into an Abstract Syntax Tree (AST) representing the structure.  
> * **Filters:** Traverse the AST to optimize it, apply HTML escaping, or handle logic, completely unaware of the original syntax.  
> * **Generator:** Compiles the final AST into a raw string of executable Ruby code.

By using an AST as a middle layer, the code generating the final output never needs to know what your original DSL syntax looked like.

---

*User prompt: yes*

Response: A robust templating engine breaks the compilation process into distinct, decoupled stages. Instead of parsing and writing HTML simultaneously, you parse the template into an Abstract Syntax Tree (AST), manipulate that tree, and then generate executable Ruby code.

The standard way to represent an AST in Ruby templating (popularized by Temple) is using S-expressions: simple nested arrays where the first element is a symbol representing the node type, like \[:tag, "h1", \[:static, "Hello"\]\].

Here is how to build a rudimentary pipeline for a DSL where \# creates an \<h1\> and . creates a \<p\>.

## **1\. The Parser (String → AST)**

The parser’s only job is to read your custom syntax and convert it into a structured tree of nodes. It knows nothing about HTML or Ruby execution.

`class Parser`  
  `def call(template_string)`  
    `ast = [:multi] # Root node holding multiple child nodes`  
      
    `template_string.each_line do |line|`  
      `case line`  
      `when /^#\s+(.*)/`  
        `ast << [:tag, "h1", [:static, $1.strip]]`  
      `when /^\.\s+(.*)/`  
        `ast << [:tag, "p", [:static, $1.strip]]`  
      `end`  
    `end`  
      
    `ast`  
  `end`  
`end`

## **2\. The Generator (AST → Ruby Code)**

The generator walks the AST and converts it into a string of pure Ruby code. Notice that it does not output HTML directly; it outputs Ruby instructions to append strings to a buffer variable (\_buf).

`class Generator`  
  `def call(ast)`  
    `compile_node(ast)`  
  `end`

  `private`

  `def compile_node(node)`  
    `type, *args = node`  
    `# Dynamically call a method based on the node type (e.g., :tag -> on_tag)`  
    `send(:"on_#{type}", *args)`  
  `end`

  `# Initializes the buffer and compiles all child nodes`  
  `def on_multi(*nodes)`  
    `code = "_buf = String.new;\n"`  
    `nodes.each { |n| code << compile_node(n) << "\n" }`  
    `code << "_buf" # Return the buffer at the end`  
  `end`

  `def on_tag(name, content_node)`  
    `"_buf << '<#{name}>';\n" +`  
    `compile_node(content_node) + "\n" +`  
    `"_buf << '</#{name}>';"`  
  `end`

  `def on_static(text)`  
    `# Escape quotes to prevent syntax errors in the generated Ruby`  
    `"_buf << '#{text.gsub("'", "\\\\'")}';"`  
  `end`  
`end`

## **3\. The Execution (The Pipeline)**

To render a template, you pass the raw string through the parser, pass the resulting AST to the generator, and evaluate the generated Ruby code in your desired context.

`template = <<~DSL`  
  `# Welcome to my DSL`  
  `. This is heavily decoupled!`  
`DSL`

`# Step 1: Parse`  
`ast = Parser.new.call(template)`  
`# => [:multi, [:tag, "h1", [:static, "Welcome to my DSL"]], ...]`

`# Step 2: Generate Ruby string`  
`ruby_code = Generator.new.call(ast)`

`# Step 3: Execute the generated Ruby code`  
`final_html = eval(ruby_code)`  
`puts final_html`

By decoupling these steps, you can inject a **Filter** step between the parser and generator. A filter is just a class that takes an AST, alters it (e.g., escaping malicious \<script\> tags inside :static nodes), and returns a new AST—without you ever needing to rewrite the parser or generator logic.

---

*User prompt: Is 'grammar introspection' a thing?*

Response: Yes, though you'll more commonly hear it discussed as a concept rather than a strict academic term.

In compiler design and DSL architecture, **grammar introspection** refers to a system's ability to examine its own syntactic rules and language definitions dynamically at runtime, rather than treating the parser as a black box that only consumes strings and outputs data.

If you are designing an object-oriented DSL in Ruby—especially if you are leaning toward component-driven architectures like Phlex—grammar introspection manifests in a few distinct ways.

**1\. Parser Combinators (The Grammar as Objects)** If you build an external DSL using a parser combinator library (like Ruby's Parslet), your grammar isn't a static text file (like Yacc or Bison). It is constructed entirely out of Ruby objects. Because the rules are just objects, your code can introspect the grammar itself. You can ask the parser, "What are the allowed child nodes for this rule?" or dynamically combine rules at runtime based on the environment.

**2\. Internal DSL Introspection (Ruby Metaprogramming)** If you are building an internal DSL (pure Ruby syntax), grammar introspection is simply Ruby's native reflection applied to your domain language. The "grammar" is defined by the methods and scopes available to the block.

> * You can use respond\_to? to check if a specific tag or component is valid in the current scope.  
> * You can use Method\#parameters to inspect exactly what attributes a specific DSL keyword accepts, allowing you to dynamically validate user input before rendering.

**3\. Why You Would Build Introspection Into a DSL** Exposing your grammar to the runtime environment unlocks powerful tooling:

> * **Editor Support:** You can write a script that introspects your DSL's rules to automatically generate a Language Server Protocol (LSP) file or syntax highlighting definitions for editors.  
> * **Self-Documenting Code:** You can iterate through your rule objects to auto-generate markdown documentation of every valid tag, block, and attribute your DSL supports.  
> * **Context-Aware Validation:** The system can introspect the grammar to provide highly specific error messages. Instead of "Syntax Error," it can say: "The table rule requires tr children, but you provided div."

When your grammar is represented as a traversable data structure (like objects or an AST of the rules themselves), your engine stops being just a translator and becomes a platform you can build tooling around.

---

*User prompt: Show me an example of how to write an introspectable parser grammar in Ruby using objects.*

Response: By modeling your grammar rules as Ruby classes, you create a tree of objects that can be queried at runtime. Instead of hiding the rules inside a black-box method, the grammar becomes a traversable data structure.

Here is an object-oriented approach using parser combinators. We define base classes for different types of grammatical rules, giving each the ability to describe its own structure.

`# Base node for our grammar tree`  
`class Rule`  
  `attr_reader :name`

  `def initialize(name)`  
    `@name = name`  
  `end`

  `# Every rule must be able to report what it expects`  
  `def expected_patterns`  
    `raise NotImplementedError`  
  `end`  
`end`

`# A Terminal rule expects an exact string or regex (e.g., "<", "=", or a word)`  
`class Terminal < Rule`  
  `attr_reader :pattern`

  `def initialize(name, pattern)`  
    `super(name)`  
    `@pattern = pattern`  
  `end`

  `def expected_patterns`  
    `[pattern]`  
  `end`

  `def describe`  
    `"Token(#{name})"`  
  `end`  
`end`

`# A Sequence expects multiple rules in an exact order (e.g., Tag = "<" + Name + ">")`  
`class Sequence < Rule`  
  `attr_reader :children`

  `def initialize(name, *children)`  
    `super(name)`  
    `@children = children`  
  `end`

  `# Introspection: The sequence asks its children what they expect`  
  `def expected_patterns`  
    `children.map(&:expected_patterns).flatten`  
  `end`

  `# Introspection: The sequence describes its exact composition`  
  `def describe`  
    `"Sequence(#{name}): [ #{children.map(&:describe).join(', ')} ]"`  
  `end`  
`end`

## **Introspecting the Grammar**

With these classes, you construct the grammar of your DSL by composing objects. Because the grammar is just an object graph, you can write scripts that traverse it to generate documentation, syntax highlighters, or highly specific error messages.

`# 1. Define the terminal tokens`  
`open_bracket  = Terminal.new(:open_bracket, "<")`  
`close_bracket = Terminal.new(:close_bracket, ">")`  
`equals_sign   = Terminal.new(:equals, "=")`  
`identifier    = Terminal.new(:identifier, /[a-z]+/)`  
`string_val    = Terminal.new(:string, /"[^"]*"/)`

`# 2. Compose them into higher-level rules`  
`attribute = Sequence.new(:attribute, identifier, equals_sign, string_val)`  
`html_tag  = Sequence.new(:html_tag, open_bracket, identifier, attribute, close_bracket)`

`# 3. Introspect the rules!`

`# Ask the rule to describe its structural composition:`  
`puts html_tag.describe`  
`# => Sequence(html_tag): [ Token(open_bracket), Token(identifier), Sequence(attribute): [ Token(identifier), Token(equals), Token(string) ], Token(close_bracket) ]`

`# Ask the rule for the exact sequence of patterns it expects:`  
`puts html_tag.expected_patterns.inspect`  
`# => ["<", /[a-z]+/, /[a-z]+/, "=", /"[^"]*"/, ">"]`

If a user writes \<div class\>, a parser built on these objects fails at the attribute sequence. Instead of a generic Syntax Error, the engine can introspect the failed attribute node, check what was expected next, and raise a contextual error: Expected Token(equals) "=" after identifier in attribute sequence.

---

*User prompt: Here's a 'Builder' class definition. Your critique is welcome.*

Response: This implementation is a classic example of an internal DSL that embraces tight coupling to enforce a strict, highly semantic domain language.

**Domain Restraint Over HTML**

> * By completely omitting a generic div method and forcing developers to register new vocabulary through a module extension (@library.words), the engine strictly enforces domain constraints over arbitrary HTML.  
> * Defining explicit methods for every domain word (such as page, table, card) instead of routing tags through method\_missing ensures that typos immediately fail with a clear Ruby error.  
> * Defining all valid terms in the WORDS array and as real methods keeps the entire vocabulary easily greppable for maintainability.  
> * Relying on type checking to separate names (Symbols) from content (Strings) via the name\_and\_content helper allows for a highly ergonomic syntax where argument position doesn't dictate parsing.  
> * method\_missing is cleverly restricted solely to resolving data bindings (like each loops) and the subject chain, preventing it from swallowing syntax errors.

**The Cost of Immediate Execution**

> * Unlike the AST pipelines we discussed, this engine executes Ruby (instance\_eval) and immediately appends raw HTML strings to an @out buffer.  
> * Because it lacks an intermediate syntax tree, the execution environment becomes a complex state machine requiring instance variables (like @in\_form, @columns, @suppressed, @branches, and @levels) to track structural context on the fly.  
> * Complex nested structures are forced to intercept execution: table and chart temporarily clear, capture, and restore state arrays (@columns and @series) to register their inner definitions before they can safely render.  
> * The @suppressed flag acts as a blunt instrument to stop output generation during empty collections, rather than conditionally pruning an AST.

This architecture strongly aligns with the philosophy of Phlex, favoring pure, object-oriented Ruby environments over string-interpolated templates. However, managing all contextual state within a single monolithic Builder class creates a fragile state machine. Migrating the heavier domain concepts (chart, table, form) into distinct object components that encapsulate their own state and lifecycle would drastically reduce the cognitive load of the core builder.

---

*User prompt: I note that the class def has over 800 lines. Is this a simple structure managing complexity or a small structure supporting a large mass?*

Response: It is unequivocally a small structure supporting a massive, entangled mass.

The foundational structure is remarkably small: it uses instance\_eval to execute a block and appends strings to a central @out buffer. But because the engine lacks an intermediate syntax tree or object composition to delegate responsibilities, every domain concept must be bolted directly onto this single class, creating a classic "God Object."

**Why it behaves as a large mass:**

> * **Vocabulary as Core Logic:** Every semantic tag (grid, badge, table, metric) is implemented as a hardcoded method on the Builder itself. This guarantees the class will endlessly swell as the DSL's vocabulary expands.  
> * **State Machine Entanglement:** Because it evaluates code and concatenates strings simultaneously, it cannot rely on isolated component lifecycles. It uses a web of instance variables (@in\_form, @columns, @series, @suppressed) to track global context. If a choose conditional sits inside a table that sits inside a form, all those independent states are precariously juggling inside the exact same execution context.  
> * **Procedural Disguise:** The engine forces you to write procedural state-tracking scripts disguised as elegant Ruby blocks. Methods like table and chart have to cache and restore global variables just to prevent nested calls from overwriting each other's data.

In strict object-oriented architecture—particularly when designing component-driven systems like Phlex—responsibilities are divided into isolated objects. This Builder does the exact opposite. It acts as the parser, the state manager, the HTML formatter (CGI.escapeHTML), the presentation inference engine, and the entire component library all at once.

It achieves a beautiful, strict syntactic elegance at the call site, but pays for it with extreme architectural rigidity behind the scenes.

---

*User prompt: How would you approach breaking the heavy components like 'table' and 'chart' out of this Builder into their own isolated Ruby objects?*

Response: Shifting heavy structural elements into their own isolated objects transforms your engine from a procedural script into a clean, composable object tree—much like the architecture powering tools like Phlex. Here is how to encapsulate the state and logic of components like table or chart to keep the main builder lightweight.

**1\. Establish a Component Protocol** Every component should share a single, predictable interface. Instead of returning raw strings immediately, a component initializes with its required arguments and block, then exposes a \#render method that the main builder can call.

**2\. Isolate State and Vocabulary** Right now, column and total are defined globally on the Builder, even though they are only valid inside a table. By moving them to a TableComponent, they become completely inaccessible outside of their proper context, inherently enforcing your DSL's grammar.

`class TableComponent`  
  `def initialize(builder, subject, name, caption, &block)`  
    `@builder = builder`  
    `@subject = subject`  
    `@name = name`  
    `@caption = caption`  
    `@columns = [] # State is now isolated here`  
    `@block = block`  
  `end`

  `# Only available inside a TableComponent block`  
  `def column(name, as: nil, header: nil)`  
    `@columns << { name: name, header: header, as: as }`  
  `end`

  `def total(name, label: nil)`  
    `@columns << { name: name, header: label, as: nil, total: true }`  
  `end`

  `def render`  
    `# 1. Evaluate the block against THIS component to populate @columns`  
    `instance_eval(&@block) if @block`  
      
    `# 2. Build and return the HTML string internally`  
    `build_html_string`  
  `end`  
    
  `private`  
    
  `def build_html_string`  
    `# The complex table-building logic goes here,`   
    `# relying on the isolated @columns array.`  
    `# ...`  
  `end`  
`end`

**3\. Streamline the Main Builder** Once the state, grammar, and HTML generation are encapsulated within the component, the monolithic Builder methods are reduced to simple delegation points. The Builder no longer needs to juggle instance variables like @columns or @was\_columns.

`class Builder`  
  `# The table method now acts strictly as a router`  
  `def table(*args, &block)`  
    `name, caption = name_and_content(args)`  
      
    `# Instantiate the component, letting it manage its own lifecycle`  
    `component = TableComponent.new(self, subject, name, caption, &block)`  
      
    `# Emit the encapsulated result back to the main buffer`  
    `emit(component.render)`  
  `end`  
`end`

**4\. Extend to Other Complex Structures** This identical pattern applies to chart. A ChartComponent would hold its own @series and @levels arrays and expose band, line, and level methods. The main Builder remains entirely ignorant of what a "band" is or how it maps to a data point, returning to its true job: managing the document output flow.

---

*User prompt: How would your example implementation above compare to a loosely-coupled one?*

Response: The component-based refactor creates local isolation by organizing the state into objects, but it remains tightly coupled to HTML generation. A loosely-coupled architecture separates *what* is being described from *how* it is rendered by introducing an intermediate data structure.

| Feature | Component Objects (Tightly Coupled) | AST Pipeline (Loosely Coupled) |
| :---- | :---- | :---- |
| **Primary Goal** | Encapsulate state and rendering logic for a specific domain concept. | Decouple syntax parsing from output generation entirely. |
| **Execution Phase** | Evaluates the DSL and generates strings in a single pass. | Parses to an Abstract Syntax Tree (AST), then compiles the AST to strings in a separate pass. |
| **Output Responsibility** | Every component hardcodes its own HTML output (\<table...). | The generator handles all HTML formatting; the syntax parser only builds the tree. |
| **Introspection** | Difficult. The DSL executes immediately, leaving no traversable data structure behind. | Trivial. The AST can be inspected, filtered, or optimized before any HTML is generated. |
| **Target Flexibility** | Bound to HTML. To output JSON, CSV, or PDF, you must rewrite the components. | Highly flexible. Swap the HTML generator for a JSON generator; the DSL and parser remain identical. |

**The Cost of Coupling** In the TableComponent example, the object acts as both the grammar rule (defining what column means) and the template (defining how a \<th\> looks). If you want to change your DSL to output a command-line interface instead of a web page, you have to rip open and rewrite the entire component.

**The Power of Loosely-Coupled ASTs** In a loosely-coupled pipeline, executing a table block simply generates an isolated node: \[:table, "Users", \[\[:column, "Name"\], \[:column, "Age"\]\]\].

Because this intermediate tree exists independently, you can easily alter the system. You could write a filter that traverses the tree and automatically appends a "Row Number" column to every table node in the application. With the tightly-coupled object approach, that kind of global interception is impossible without monkey-patching the component class itself.

Component isolation tames immediate procedural complexity, but pipeline decoupling unlocks long-term architectural leverage.

---

*User prompt: So with an ast it's easier to add an API to a web app?*

Response: Using an AST fundamentally simplifies adding an API because it decouples the structure of your data from its final output format. Instead of writing separate views for web and API, you can route the exact same intermediate tree to different generators.

**Swap Generators, Not Logic** When a request hits your application, the DSL parses into an AST. If the client asks for HTML, you pass that AST to your HTML Generator. If the client asks for JSON, you pass the exact same AST to a JSON Generator.

**Single Source of Truth** You define the data structures and domain logic once in your DSL. An AST node representing a table structure compiles to a literal HTML \<table\> tag for the browser, but that exact same node translates into a structured array of serialized objects for an API endpoint.

**Targeted Pruning** Because the AST is just a traversable data structure, you can intercept it before generation. You can easily write a filter for your API pipeline that automatically strips out UI-specific nodes (like a button, stylesheet, or icon) that have no meaning in a JSON payload, leaving only pure data for the API consumer.

---

