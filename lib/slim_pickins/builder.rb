# frozen_string_literal: true

require 'cgi'
require_relative 'subject'
require_relative 'inference'
require_relative 'generator'
require_relative 'words'
require_relative 'components'

module SlimPickins
  # The runtime — nothing else. A page evaluates into a tree of semantic
  # nodes (`[:word, attributes, children]`) and the Generator walks the tree
  # to HTML. The vocabulary lives in Words, extended in here; the gatherers
  # live in components.rb; the presentation lives in the Generator. What is
  # left for this class is the evaluation: the subject chain, the bindings,
  # the gatherer stack, the capture and pruning of children, and the escape
  # hatch every word — built-in or an app's own — is written with.
  class Builder
    include Words

    WORDS = Words::WORDS # the vocabulary's one list, for callers that look here

    def initialize(page, library = nil)
      @library = library
      @chain = Chain.new(page)
      @empty_active = false # set while the named subject is an empty collection
      @bindings = {}        # `each holding` binds `holding` for reaching out
      @gatherers = []       # the components whose children are declarations
      @contents = nil       # the page's own nodes, while a layout renders
      @head_nodes = []      # words that belong in <head>, wherever they are said
      @icons_used = []      # so the sprite carries only the symbols a page uses
      define_app_words
    end

    # An app's words become real singleton methods, for the same reason the
    # built-ins are real methods: a call site should not be able to tell them
    # apart, and an unknown word should still fail with its own name.
    def define_app_words
      return unless @library

      Array(@library.words).each { |mod| extend mod }
      @library.partials.each_key do |word|
        define_singleton_method(word) do |*args, &block|
          render_partial(word, args, &block)
        end
      end
    end
    private :define_app_words

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

    def render(ruby, path)
      @nodes = []
      instance_eval(ruby, path, 1)
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
    # evaluation plumbing no word needs: nest, render_partial,
    # define_app_words.

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
    def children(&block) = capture(&block)

    # The paper's "conditionally pruning an AST": an empty collection keeps
    # only the `empty` node that names it; anything else keeps everything but.
    def prune(children, empty)
      empty ? children.select { |n| n.first == :empty } : children.reject { |n| n.first == :empty }
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
      return subject.fetch(plural) if subject.respond_to?(plural)
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
      [args.find { |a| a.is_a?(Symbol) }, args.find { |a| !a.is_a?(Symbol) }]
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
      value = subject.fetch(name)
      empty = Inference.collection?(value) && Inference.nothing_in?(value)
      was = @empty_active
      @empty_active = empty
      [value, empty, @chain.with(value, described_as: "this #{name}", &block)]
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
    def sprite_symbols = @icons_used.dup

    def in_head(node) = @head_nodes << node
    def use_icon(name) = @icons_used << name

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
      nodes = capture { instance_eval(Transform.call(@library.layout, path: 'layout.sp'), 'layout.sp', 1) }
      raise Error, 'this layout never says `contents`' if @contents

      nodes
    end

    private

    def nest(&block)
      instance_eval(&block) if block
    end

    # A partial takes the current subject, like any word that names none, and
    # shifts it when it names one — the same rule as `section`.
    def render_partial(word, args, &block)
      name, = name_and_content(args)
      source = @library.source_for(word)
      ruby = Transform.call(source, path: "partials/#{word}.sp")
      value, empty, children = about(name) { capture { instance_eval(ruby, "partials/#{word}.sp", 1) } }
      @nodes.concat(prune(children, empty))
      value
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
