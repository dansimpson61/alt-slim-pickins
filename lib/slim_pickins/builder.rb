# frozen_string_literal: true

require 'cgi'
require_relative 'subject'
require_relative 'inference'
require_relative 'generator'
require_relative 'words'

module SlimPickins
  # The runtime — nothing else. A page evaluates into a tree of semantic
  # nodes (`[:word, attributes, children]`) and the Generator walks the tree
  # to HTML. The vocabulary lives in Words, extended in here; the gatherers
  # live in components.rb; the presentation lives in the Generator. What is
  # left for this class is the evaluation: the subject chain, the bindings,
  # the gatherer stack, the capture and pruning of children, and the escape
  # hatch every word — built-in or an app's own — is written with.
  class Builder
    def initialize(page, library = nil)
      @library = library || Library.builtin
      @chain = Chain.new(page, builder: self)
      @empty_active = false # set while the named subject is an empty collection
      @bindings = {}        # `each holding` binds `holding` for reaching out
      @gatherers = []       # the components whose children are declarations
      @lines = []           # the sentence being evaluated, so an error can name it
      @contents = nil       # the page's own nodes, while a layout renders
      @head_nodes = []      # words that belong in <head>, wherever they are said
      define_app_words
    end

    # An app's words become real singleton methods, for the same reason the
    # built-ins are real methods: a call site should not be able to tell them
    # apart, and an unknown word should still fail with its own name.
def define_app_words
  SlimPickins::Word.registry.each do |word, klass|
    define_singleton_method(word) do |*args, **kwargs, &block|
      klass.new(self, args, kwargs, block).evaluate
    end
  end
  return unless @library

  Array(@library.words).each { |mod| extend mod }
  @library.partials.each do |word, source|
    if source.match?(/\A\s*def\s+/m)
      eval_with(Transform.call(source, path: "partials/#{word}.sp"), "partials/#{word}.sp", source.lines)
    end
  end
end
private :define_app_words

    # An in-buffer domain word defined with `def <word>, *params`.
    # Flexible argument binding:
    #   - Positional args map in order to declared parameter names.
    #   - Named kwargs map by key, order-independent.
    #   - Undeclared named args forward into chain scope.
    #   - Omitted declared parameters default to nil.
    def define_local_word(word_name, param_names = [], &definition_block)
      word_name = word_name.to_sym
      param_names = Array(param_names).map(&:to_sym)

      define_singleton_method(word_name) do |*args, **kwargs, &caller_block|
        bound = {}
        args.each_with_index do |arg, i|
          val = if arg.is_a?(Symbol)
                  subject.has?(arg) ? subject.fetch(arg) : arg
                elsif arg.is_a?(Proc)
                  arg.call
                else
                  arg
                end
          bound[param_names[i]] = val if i < param_names.size
        end

        kwargs.each do |k, v|
          val = if v.is_a?(Symbol)
                  subject.has?(v) ? subject.fetch(v) : v
                elsif v.is_a?(Proc)
                  v.call
                else
                  v
                end
          bound[k.to_sym] = val
        end

        param_names.each do |p|
          bound[p.to_sym] = nil unless bound.key?(p.to_sym)
        end

        evaluate_proc = lambda do
          if caller_block
            captured = capture(&caller_block)
            with_splice(captured) { definition_block.call }
          else
            definition_block.call
          end
        end

        chain.with(bound, described_as: "this #{word_name}", overlay: true) do
          evaluate_proc.call
        end
      end
    end



    # Words are real methods, so an unknown word fails with its own name.
    # The only thing method_missing serves is a binding introduced by `each`,
    # which is dynamic by nature and cannot be a defined method.
    # Reaching out by name: `order.number` inside a nested loop, or
    # `pattern.title` at the top of a page. A binding from `each` wins, then
    # the subject chain — whose floor is the page, so locals and helpers are
    # reachable here for the same reason `.foo` reaches them.
    def method_missing(name, *args)
      if args.empty?
        # Wrapped, so `order.number` and `pattern.title` read the same whether
        # the thing behind them is a struct, a hash or a plain object.
        return Subject.new(@bindings[name], described_as: "this #{name}") if @bindings.key?(name)
        return Subject.new(subject.fetch(name), described_as: "this #{name}") if subject.has?(name)
      end

      raise Error, "there is no word `#{name}`"
    end

    def respond_to_missing?(name, include_private = false)
      @bindings.key?(name) || subject.has?(name) || super
    end

    def render(ruby, path, source: nil)
      @nodes = []
      eval_with(ruby, path, source&.lines)
      @nodes
    end

    # `.foo` compiles to this.
    def subject = @chain.current

    # The subject chain itself, for words that iterate rows the way `table`
    # does.
    def chain = @chain

    # --- the surface -------------------------------------------------------
    #
    # Everything below is public, and it is the whole of what a word may use —
    # the built-in vocabulary (words.rb) and an app's own words alike. There
    # is no other surface; this is the dogfood made true: the vocabulary is
    # written with exactly what apps get. What remains private is the
    # evaluation plumbing no word needs: nest,
    # define_app_words, and the line stack (with_line, eval_with, locate).

    # Every word hands its node to the current collection — the body's, or the
    # head's for the words that belong there. It returns the node, so words
    # can compose: `tag(:div, {}, [tag(:p, {}, [])])` nests.
    def emit_node(node)
      @nodes << node
      node
    end

    def capture(&block)
      was = @nodes
      @nodes = []
      nest(&block)
      @nodes
    ensure
      @nodes = was
    end

    # A word's own children, as nodes — the capture above, by its hatch name.

    # The paper's "conditionally pruning an AST": an empty collection keeps
    # only the `empty` node that names it; anything else keeps everything but.
    # The promoted `empty` is a paragraph whose box carries the word's name,
    # so the selector reads the declaration, not the old node kind.
    def prune(children, empty)
      if empty
        children.select { |n| empty_node?(n) }
      else
        children.reject { |n| empty_node?(n) }
      end
    end

    def empty_node?(node)
      return false unless node.is_a?(Array)

      node[0] == :empty || CONTRACTS[node[1][:class_base]]&.empty
    end

    # --- presentation helpers ---------------------------------------------

    # `as:` said in the page, else the app's own answer, else what the value's
    # shape can tell us — the same three levels as labels, owned by the same
    # three people.
    def format_of(column, row = nil)
      column[:as] || Subject.new(row || subject.object).format_for(column[:name])
    end

    # The same three levels as everywhere else — the page said it, or the app
    # said it, or English — except that here "the app" is the row rather than
    # whatever holds the collection. `format_of` had always asked the row;
    # labels asked the enclosing subject, and a table of Years read its headers
    # off the Projection that merely held them: "Irmaa applied cost".
    def label_of(column, row = nil)
      column[:header] ||
        (row && Subject.new(row).label_for(column[:name])) ||
        subject.label_for(column[:name]) ||
        Inference.label(column[:name])
    end

    def alignment_of(column, sample)
      kind = format_of(column, sample) || Inference.presentation(column[:sample])
      %i[money percent number].include?(kind) ? 'column--numeric' : nil
    end

    # `each holding` looks for `holdings` on the subject. When the subject is
    # itself the collection — as it is under `section accounts`, which is what
    # lets `empty` know what is empty — it iterates that instead.
    def collection_for(name)
      plural = Inference.plural(name).to_sym
      return subject.fetch(plural) if subject.has?(plural)
      return subject.object if Inference.collection?(subject.object)

      raise Error, "#{subject.describe} has no #{plural} to go through"
    end

    # `card` infers its DOM id from the subject, so no page writes `id .id`.
    def card_id
      return nil unless subject.has?(:id)

      "#{subject.noun}-#{subject.fetch(:id)}"
    end

    # --- the gathering mechanism, written once -----------------------------
    #
    # The registering words route through the stack of open gatherers — the
    # one collect-and-restore the lore counted four times. A nested gatherer
    # pushes and pops; the outer one's collection is untouched, which is the
    # save-and-restore each word used to do by hand (and `choice` never did).
    def register!(kind, item, what)
      target = open_gatherer(kind)
      raise Error, "#{what} belongs inside #{kind::INSIDE}" unless target

      target.collect(item)
    end

    def open_gatherer(kind)
      @gatherers.reverse.find { |g| g.is_a?(kind) }
    end

    # A gatherer addressed by its word name — how a vocabulary partial's
    # children find their collector.
    def open_gatherer_named(word)
      @gatherers.reverse.find { |g| g.respond_to?(:word) && g.word == word.to_sym }
    end

    # The nodes a `children` word splices — set by a partial around its body.
    def with_splice(nodes)
      was = @spliced
      @spliced = nodes
      yield
    ensure
      @spliced = was
    end

    def spliced = @spliced

    def with_gatherer(gatherer)
      @gatherers.push(gatherer)
      yield
    ensure
      @gatherers.pop
    end

    def chain = @chain

    # Names are Symbols, content is anything else. This is why argument order
    # never has to be counted.
    def name_and_content(args)
      [args.find { |a| a.is_a?(Symbol) }, args.find { |a| !a.nil? && !a.is_a?(Symbol) }]
    end

    # A word that names a subject shifts the chain for its children. A word
    # that names nothing leaves the chain alone, which is what makes
    # `page scenario` followed by a bare `form` mean the obvious thing.
    # Returns [value, empty?, children] so the caller can prune by the
    # situation.
    def about(name, &block)
      return [nil, false, yield] if name.nil?

      # A word that names no subject leaves the chain alone. A word that names
      # one that is not there is an error — skipping quietly would report the
      # missing attribute later, on a line that is not the cause.
      value = name.is_a?(Symbol) || name.is_a?(String) ? subject.fetch(name) : name
      empty = Inference.collection?(value) && Inference.nothing_in?(value)
      was = @empty_active
      @empty_active = empty
      description = if name.is_a?(Symbol) || name.is_a?(String)
                      "this #{name}"
                    elsif value.respond_to?(:describe)
                      value.describe
                    else
                      "this #{value.class.name.downcase}"
                    end
      [value, empty, @chain.with(value, described_as: description, &block)]
    ensure
      @empty_active = was unless was.nil?
    end

    # Precedence, each level owned by whoever knows most: the page knows this
    # instance, the app knows its domain, the language knows only English.
    def label_for(name, given)
      given || subject.label_for(name) || Inference.label(name)
    end

    # --- the context accessors the words read ------------------------------

    def empty_active? = @empty_active
    def head_nodes = @head_nodes

    def in_head(node) = @head_nodes << node

    def bind(name, value) = @bindings[name] = value
    def unbind(name) = @bindings.delete(name)

    # The layout's splice point — the contents word takes what page stowed.
    def stow_contents(nodes) = @contents = nodes
    def contents_stowed? = !@contents.nil?

    def take_contents
      nodes = @contents
      @contents = nil
      nodes
    end

    # Evaluate a block in the word's own context — what a gatherer's
    # collection phase needs.
    def evaluate(&block) = nest(&block)

    # The layout is chrome inside the page, so `page` still owns the document
    # and the layout never repeats it.
    def wrapped_in_layout(&block)
      return capture(&block) unless @library&.layout

      stow_contents(capture(&block))
      compilation = Compilation.of(@library.layout, 'layout.sp')
      compilation.refuse!('layout.sp')
      nodes = capture { eval_with(compilation.ruby, 'layout.sp', @library.layout.lines) }
      raise Error, 'this layout never says `contents`' if @contents

      nodes
    end

    private

    # Every place the grammar's Ruby runs — the page, a partial, the layout.
    # It remembers where, so an error the words raise can be located there.
    def eval_with(ruby, path, source_lines)
      was_path = @path
      was_lines = @source_lines
      @path = path
      @source_lines = source_lines
      instance_eval(ruby, path, 1)
    ensure
      @path = was_path
      @source_lines = was_lines
    end

    # The transform wraps every compiled sentence in this, so the builder
    # always knows which sentence is evaluating. An error is located here —
    # where the line is still on the stack — so a runtime error names the
    # line the way a syntax error names it.
    def with_line(lineno)
      @lines.push(lineno)
      yield
    rescue Error => e
      raise locate(e)
    ensure
      @lines.pop
    end

    def locate(error)
      return error if error.located?

      line = @lines.last
      error.locate(@path, line, line && @source_lines && @source_lines[line - 1]&.strip)
    end

    def nest(&block)
      instance_eval(&block) if block
    end

    # The word's box: the node a single-root body will render. `choose` is
    # presentation-transparent — its branches render in its place, and the
    # generator splices it away — so the box passes through it.
    def self.box_root(body)
      root = body.first
      while root[0] == :choose && root[2].size == 1 && root[2].first.is_a?(Array)
        root = root[2].first
      end
      root
    end

    # `render_partial` lived here until 2026-09-17: a second implementation
    # of partial rendering, superseded by `PartialWord#evaluate` and called by
    # nothing — its only mentions were two comments and a test asserting it
    # stayed private. It built `PartialGatherer`, a constant defined nowhere,
    # so it could not have run. Deleted under dan's ruling that the
    # partial-gatherer road be repaired rather than left half-built; what the
    # road needed instead was `Word#word`, so `inside:` can find its gatherer.


    # The optionality spelling (dan, 2026-09-02): slots a preamble declares —
    # name, content, each modifier — are keys of the parameters subject, nil
    # when the call did not say them. A preamble-less partial keeps the old
    # subject: whatever the call carried, nothing more.
    #
    # Two declarations derive a slot from the situation, the way the Ruby
    # words they replace did: `# id: true` names the subject's id (`card`),
    # `# label: true` the app contract's label (`section`'s heading). The
    # derivation is runtime inference — a page never writes either.
    def parameters_for(contract, name, content, kwargs)
      return { content: content, name: name }.merge(kwargs) unless contract

      declared = {}
      declared[:name] = name if contract.name != :none
      declared[:content] = content if contract.content
      contract.modifiers.each do |modifier|
        if kwargs.key?(modifier)
          declared[modifier] = kwargs[modifier]
        else
          found, val = @chain.container_value(modifier)
          declared[modifier] = found ? val : nil
        end
      end
      declared[:id] = card_id if contract.id
      declared[:label] = label_for(name, content) if contract.label
      declared
    end

    def evaluate_body(evaluate, parameters, word, push, contract)
      if push
        @chain.with(parameters, described_as: "this #{word}", overlay: !contract.nil?) { evaluate.call }
      else
        evaluate.call
      end
    end

    # --- the escape hatch -------------------------------------------------
    #
    # The language has no `div`, deliberately. When an app needs something the
    # vocabulary has no word for — a `<video>`, a third-party embed — it adds
    # a *word*, in Ruby, through `Library.new(words: SomeModule)`. That keeps
    # the founding claim intact: extending the language adds vocabulary, never
    # syntax, and a call site still cannot tell where a word came from.
    #
    # An app word may use the whole public surface above — the same surface
    # words.rb and the components are written with. There is no other.

    public

    def token(word, variant = nil) = Generator.token(word, variant)
    def html(string) = emit_node([:raw, {}, [string]]) # trusted markup — you escape it
    def element(name, attributes = {}, children = []) = [:tag, { name: name, attrs: attributes }, children]
    def tag(name, attributes = {}, children = [], &block)
      emit_node(element(name, attributes, block ? capture(&block) : children))
    end
    def arguments(args) = name_and_content(args)
  end
end
