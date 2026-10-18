# frozen_string_literal: true

require 'cgi'
require_relative 'subject'
require_relative 'inference'
require_relative 'generator'
require_relative 'words'

module SlimPickins
  # The runtime — nothing else. A page evaluates into a tree of semantic
  # nodes (`Node[word, attributes, children]`) and the Generator walks the tree
  # to HTML. The vocabulary lives in Words, extended in here; the gatherers are
  # the words that collect their children as declarations, and they live in
  # Words with the rest; the presentation lives in the Generator. What is
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
      @contents = nil       # the page's own nodes, while a tin renders
      @head_nodes = []      # words that belong in <head>, wherever they are said
      @nodes = []
      @self_titled = false  # the route took its title from the subject's own `title`
      @family_definitions = {}
      define_app_words
    end

    # An app's words become real singleton methods, for the same reason the
    # built-ins are real methods: a call site should not be able to tell them
    # apart, and an unknown word should still fail with its own name.
    def define_app_words
      SlimPickins::Word.registry.each do |word, klass|
        next if SlimPickins::Word.contained?(word)

        define_singleton_method(word) do |*args, **kwargs, &block|
          klass.new(self, args, kwargs, block).evaluate
        end
      end
      return unless @library

      @library.compiled_partials.each do |word, klass|
        next if SlimPickins::Word.contained?(word)

        define_singleton_method(word) do |*args, **kwargs, &block|
          klass.new(self, args, kwargs, block).evaluate
        end
      end

      Array(@library.words).each do |mod|
        next unless mod.is_a?(Module)

        extend mod
        mod.ancestors.each do |ancestor|
          next unless ancestor.is_a?(Module)

          ancestor.public_instance_methods(false).each do |m|
            define_singleton_method(m, ancestor.instance_method(m))
          end
        end
      end
      @library.partials.each do |word, source|
        next if SlimPickins::Word.contained?(word)

        if source.match?(/\A(?:\s*|#.*?\n)*def\b/)
          ruby = @library.compiled_partial(word)&.compilation&.ruby || Transform.call(source, path: "partials/#{word}.sp")
          eval_with(ruby, "partials/#{word}.sp", source.lines)
        end
      end
    end
    private :define_app_words

    # An in-buffer domain word defined with `def <word>, *params`.
    # Flexible argument binding:
    #   - Positional args map in order to declared parameter names.
    #   - Contract-aware routing maps name vs content when declared.
    #   - Named kwargs map by key, order-independent.
    #   - Undeclared named args forward into chain scope.
    #   - Omitted declared parameters default to nil.
    def self.bind_parameters(param_names, args, kwargs, subject, contract: nil)
      bound = {}

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

      if contract && contract.name != :none && contract.content && param_names.size >= 2
        name_param = param_names[0]
        content_param = param_names[1]
        bound[name_param] ||= args.find { |a| a.is_a?(Symbol) }
        bound[content_param] ||= args.find { |a| !a.nil? && !a.is_a?(Symbol) }
      elsif contract && contract.name != :none && !contract.content && param_names.size >= 1
        bound[param_names[0]] ||= args.find { |a| a.is_a?(Symbol) }
      elsif contract && contract.content && contract.name == :none && param_names.size >= 1
        bound[param_names[0]] ||= args.find { |a| !a.nil? && !a.is_a?(Symbol) } || args.first
      else
        args.each_with_index do |arg, i|
          next if i >= param_names.size || bound.key?(param_names[i])

          val = if arg.is_a?(Symbol)
                  if contract && (contract.name != :none || contract.subject == :shift) && i.zero?
                    arg
                  else
                    subject.has?(arg) ? subject.fetch(arg) : arg
                  end
                elsif arg.is_a?(Proc)
                  arg.call
                else
                  arg
                end
          bound[param_names[i]] = val
        end
      end

      param_names.each do |p|
        bound[p.to_sym] = nil unless bound.key?(p.to_sym)
      end

      bound
    end

    def define_local_word(word_name, param_names = [], &definition_block)
      word_name = word_name.to_sym
      param_names = Array(param_names).map(&:to_sym)

      if SlimPickins::Word.contained?(word_name)
        SlimPickins::Word.parents_of(word_name).each do |parent|
          @family_definitions[parent] ||= {}
          @family_definitions[parent][word_name] = [param_names, definition_block]
        end
        return
      end

      define_single_local_word(word_name, param_names, &definition_block)
    end

    def define_single_local_word(word_name, param_names, &definition_block)
      word_name = word_name.to_sym
      param_names = Array(param_names).map(&:to_sym)
      contract = @library&.compiled_partial(word_name)&.instance_variable_get(:@contract) || CONTRACTS[word_name]

      define_singleton_method(word_name) do |*args, **kwargs, &caller_block|
        bound = Builder.bind_parameters(param_names, args, kwargs, subject, contract: contract)

        target_param = if contract
                         (contract.name != :none && param_names.size >= 1) ? param_names[0] : nil
                       else
                         param_names[0]
                       end

        content_param = if contract
                          if contract.content
                            (contract.name != :none && param_names.size >= 2) ? param_names[1] : (param_names.size >= 1 ? param_names[0] : nil)
                          end
                        else
                          param_names[1]
                        end

        target_val = target_param ? bound[target_param] : (bound[:target] || bound[:subject] || bound[:name])
        content_val = content_param ? bound[content_param] : bound[:content]
        name_val = target_val || bound[:variant] || bound[:name] || (args.first if args.first.is_a?(Symbol))

        shifts = contract&.subject == :shift || contract&.name == :subject
        shift_target = if shifts && name_val
                         if contract&.modifiers&.include?(:variant)
                           subject.has?(name_val) ? name_val : nil
                         else
                           name_val
                         end
                       end

        if shift_target && subject.has?(shift_target)
          target_obj = subject.fetch(shift_target)
          tgt = target_obj.is_a?(Subject) ? target_obj : Subject.new(target_obj, described_as: "this #{shift_target}")
          bound[:target] ||= target_obj
          bound[:noun] ||= tgt.noun
          if contract&.id
            bound[:id] ||= kwargs.fetch(:id) { tgt.has?(:id) ? "#{tgt.noun}-#{tgt.fetch(:id)}" : card_id }
          end
        elsif contract&.id
          bound[:id] ||= kwargs.fetch(:id) { card_id }
        end

        raw_content = content_val.is_a?(Proc) ? nil : content_val
        if contract&.label
          bound[:label] ||= kwargs.fetch(:label) { label_for(name_val, raw_content) }
          bound[content_param] ||= bound[:label] if content_param && bound[content_param].nil?
        elsif name_val || content_val
          inferred_label = kwargs[:label] || raw_content || (name_val ? label_for(name_val, nil) : nil)
          bound[:label] ||= inferred_label if inferred_label
        end

        if contract && (contract.modifiers.include?(:variant) || contract.name == :variant)
          bound[:variant] ||= kwargs[:variant] || (name_val && !subject.has?(name_val) ? name_val : nil)
        end

        if contract&.name == :attribute && content_val.nil? && name_val && subject.has?(name_val)
          content_val = subject.fetch(name_val)
          bound[content_param] = content_val if content_param
          bound[:content] = content_val if bound.key?(:content)
        end

        contract&.modifiers&.each do |modifier|
          unless bound.key?(modifier)
            found, val = chain.container_value(modifier)
            bound[modifier] = found ? val : nil
          end
        end

        bound[:name] = name_val if contract&.name != :none || bound.key?(:name)

        if word_name == :fact
          fn_val = bound[:attribute] || (args.first if args.first.is_a?(Symbol))
          if fn_val
            f_val = content_val.nil? ? (subject.has?(fn_val) ? subject.fetch(fn_val) : nil) : content_val
            f_val = f_val.call if f_val.is_a?(Proc)
            f_kind = format_of({ name: fn_val, as: nil })
            bound[:label] ||= label_for(fn_val, nil)
          else
            f_val = args[0].is_a?(Proc) ? args[0].call : args[0]
            f_kind = nil
            bound[:label] ||= args[1]
          end
          bound[:value] = Generator.format(f_kind, f_val)
        elsif word_name == :metric
          mn_val = bound[:attribute] || (args.first if args.first.is_a?(Symbol))
          if mn_val
            m_val = subject.has?(mn_val) ? subject.fetch(mn_val) : nil
            m_val = m_val.call if m_val.is_a?(Proc)
            m_lbl = label_for(mn_val, content_val.is_a?(Proc) ? content_val.call : content_val)
            m_kind = kwargs[:as] || (subject.has?(mn_val) ? subject.format_for(mn_val) : nil)
            bound[:label] ||= m_lbl
          else
            m_val = args[0].is_a?(Proc) ? args[0].call : args[0]
            m_lbl = args[1] || 'Metric'
            m_kind = kwargs[:as]
            bound[:label] = m_lbl
          end
          bound[:value] = Generator.format(m_kind, m_val)
        elsif word_name == :snippet
          s_lang = bound[:notation] || (args.first if args.first.is_a?(Symbol))
          s_body = bound[:body] || (content_val.nil? ? args.find { |a| !a.nil? && !a.is_a?(Symbol) } : content_val)
          s_body = s_body.call if s_body.is_a?(Proc)
          bound[:notation] = s_lang
          bound[:body] = s_body
        end

        body_block = lambda do
          if content_param && bound[content_param].is_a?(Proc)
            said = bound[content_param].call
            bound[content_param] = said
            bound[:label] = said if (contract&.label || bound.key?(:label)) && !said.nil? && !%i[fact metric].include?(word_name)
          elsif bound[:content].is_a?(Proc)
            said = bound[:content].call
            bound[:content] = said
            bound[:label] = said if (contract&.label || bound.key?(:label)) && !said.nil? && !%i[fact metric].include?(word_name)
          end

          captured = caller_block ? with_family(word_name) { capture(&caller_block) } : []

          chain.with(bound, described_as: "this #{word_name}", overlay: true) do
            with_splice(captured) { definition_block.call }
          end
        end

        body = if contract&.empty && !empty_active?
                 []
               else
                 capture do
                   if shifts && shift_target
                     about(shift_target) { body_block.call }
                   else
                     body_block.call
                   end
                 end
               end

        if body.size == 1 && body.first.is_a?(Node)
          root = Builder.box_root(body)
          if root && root.attributes.is_a?(Hash)
            # The one mutation in the runtime, and it writes to the hash the node
            # holds rather than to the node, which is why a frozen `Data` is fine.
            if Library.builtin_partial_paths.key?(word_name)
              root.attributes[:class_base] = word_name
            else
              was = root.attributes[:app_class]
              root.attributes[:app_class] = was ? "#{was} #{word_name}" : word_name
            end
          end
        end

        body.each { |n| emit_node(n) }
      end
    end

    def with_family(family_parent)
      return yield unless family_parent

      parent_sym = family_parent.to_sym
      ruby_family = SlimPickins::Word.family_for(parent_sym)
      local_family = @family_definitions[parent_sym] || {}

      return yield if ruby_family.empty? && local_family.empty?

      previous_methods = {}
      added = []

      begin
        ruby_family.each do |child_name, klass|
          next unless klass

          if singleton_class.method_defined?(child_name)
            previous_methods[child_name] = singleton_class.instance_method(child_name)
            singleton_class.remove_method(child_name)
          end
          define_singleton_method(child_name) do |*args, **kwargs, &block|
            klass.new(self, args, kwargs, block).evaluate
          end
          added << child_name
        end

        local_family.each do |child_name, (param_names, definition_block)|
          if singleton_class.method_defined?(child_name)
            previous_methods[child_name] = singleton_class.instance_method(child_name)
            singleton_class.remove_method(child_name)
          end
          define_single_local_word(child_name, param_names, &definition_block)
          added << child_name
        end

        yield
      ensure
        added.each do |child_name|
          singleton_class.remove_method(child_name) if singleton_class.method_defined?(child_name)
          if previous_methods.key?(child_name)
            define_singleton_method(child_name, previous_methods[child_name])
          end
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
      @spliced = [] if path.to_s.include?('partials/')
      view = path && File.basename(path.to_s, '.sp')
      frame = @library&.frame_for(view)
      is_substance = path && !path.to_s.include?('partials/') && !path.to_s.end_with?('.frame') && !path.to_s.end_with?('.tin')

      if is_substance && frame
        substance_nodes = capture { eval_with(ruby, path, source&.lines) }
        if substance_nodes.any? { |n| n.is_a?(Node) && n.word == :page }
          @nodes = substance_nodes
        else
          stow_contents(substance_nodes)
          frame_name = @library.dir ? "#{view || File.basename(@library.dir)}.frame" : 'frame'
          frame_compilation = Compilation.of(frame, frame_name, library: @library)
          frame_compilation.refuse!(frame_name)
          frame_nodes = capture { eval_with(frame_compilation.ruby, frame_name, frame.lines) }
          raise Error, 'this frame never says `contents`' if @contents

          @nodes = frame_nodes
        end
      else
        eval_with(ruby, path, source&.lines)
      end
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
      return false unless node.is_a?(Node)

      node.word == :empty || CONTRACTS[node.attributes[:class_base]]&.empty
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
      if subject.has?(plural)
        val = subject.fetch(plural)
        return val if Inference.collection?(val) || val.nil?

        raise Error, "#{subject.describe}'s #{plural} is not a collection to go through"
      end
      return subject.object if Inference.collection?(subject.object)
      return nil if subject.object.nil? # nothing has nothing to go through

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
      empty = Inference.nothing_in?(value) # nil is nothing, as an empty list is
      description = if name.is_a?(Symbol) || name.is_a?(String)
                      "this #{name}"
                    elsif value.respond_to?(:describe)
                      value.describe
                    else
                      "this #{value.class.name.downcase}"
                    end

      # The restore is scoped to where `was` is a real value. A method-level
      # `ensure` also runs on the early return above, where `was` is an
      # unassigned local and therefore nil — and the guard that covered that
      # (`@empty_active = was unless was.nil?`) read as a check against
      # impossible state rather than the control-flow fix it actually was.
      was = @empty_active
      begin
        @empty_active = empty
        # Every word that changes what "it" is also names it, for everything
        # beneath — `page portfolio` names `portfolio` as `each holding`
        # names `holding` (2026-10-04, the scoping rules).
        named = name if name.is_a?(Symbol) || name.is_a?(String)
        [value, empty, naming(named, value) { @chain.with(value, described_as: description, &block) }]
      ensure
        @empty_active = was
      end
    end

    # Precedence, each level owned by whoever knows most: the page knows this
    # instance, the app knows its domain, the language knows only English.
    def label_for(name, given)
      given || subject.label_for(name) || Inference.label(name)
    end

    # --- the context accessors the words read ------------------------------

    def empty_active? = @empty_active
    # Whether the route took its title from the subject's own `title` rather
    # than being told one — the self-titling rule `prose` reads, so markdown
    # prose begins after the heading that is already spoken as the page title.
    def self_titled? = @self_titled
    def head_nodes = @head_nodes

    def in_head(node) = @head_nodes << node

    # The page's view name, as the tin and Spiff lookups know it.
    def view_name = @path && File.basename(@path.to_s, '.sp')

    # The stylesheets a page gets without saying so, in precedence order:
    # slim-pickins' own, then the view's `[view].css` if it has one, else the
    # app's `[app].css`.
    #
    # A page that says `stylesheet` itself is not overruled — its word is
    # said later and lands later in the head — so this is a default and not a
    # replacement. The vocabulary covers the shape; reaching past it is the
    # escape hatch.
    def inferred_stylesheets
      @library ? @library.stylesheets_for(view_name, path: @path, url: @library.public_url) : []
    end

    # A name, for everything beneath: the nearest naming wins, and the one it
    # shadowed comes back when the block ends. `bind`/`unbind` were a flat
    # hash, so an inner `each account` under an outer one deleted the outer
    # binding on its way out instead of restoring it.
    def naming(name, value)
      return yield if name.nil?

      name = name.to_sym
      had, was = @bindings.key?(name), @bindings[name]
      @bindings[name] = value
      yield
    ensure
      if name
        had ? @bindings[name] = was : @bindings.delete(name)
      end
    end

    # The frame's splice point — the contents word takes what the route stowed.
    # A route stows its body lazily (a Proc evaluated under the live subject at
    # the moment `contents` is said); a `page` stows already-rendered nodes.
    def stow_contents(body) = @contents = body
    def contents_stowed? = !@contents.nil?

    def take_contents
      body = @contents
      @contents = nil
      body.respond_to?(:call) ? body.call : body
    end

    # Evaluate a block in the word's own context — what a gatherer's
    # collection phase needs.
    def evaluate(&block) = nest(&block)

    # The tin is chrome inside the page, so `page` still owns the document and
    # the tin never repeats it. No tin at all is a real answer: the page is
    # standalone and carries its own chrome.
    #
    # Which tin is the library's business, not the builder's — a page may wear
    # its own (`[view].tin`) instead of its app's (`[app].tin`), and the rule
    # for that lives in one place rather than here.
    #
    # An error in the tin names the tin, not the page — `tin` when the library
    # was built in memory and there is no file to name, which is honest: there
    # is no path, and inventing one would send a reader looking for a file
    # that never existed.
    def wrapped_in_frame(&block)
      return capture(&block) if @path.to_s.end_with?('.frame') || @path.to_s.end_with?('.tin')

      view = @path && File.basename(@path.to_s, '.sp')
      frame = @library&.frame_for(view)
      return capture(&block) unless frame

      # The body is stowed lazily — a Proc, not rendered nodes — so `contents`
      # splices it under the live subject the route's signature already bound.
      stow_contents(-> { capture(&block) })
      path = @library.dir ? "#{view || File.basename(@library.dir)}.frame" : 'frame'
      compilation = Compilation.of(frame, path, library: @library)
      compilation.refuse!(path)
      nodes = capture { eval_with(compilation.ruby, path, frame.lines) }
      raise Error, 'this frame never says `contents`' if @contents

      nodes
    end
    alias_method :wrapped_in_tin, :wrapped_in_frame

    # The route's signature — the new `page`. The transform emits a route's
    # leading sentence as `route(...)`, with the filename already supplying the
    # word. This is where the signature runs: bind the subject, compute the
    # title, and hand the body to the frame — which now owns the envelope —
    # spliced lazily at `contents`.
    def route(*args, **kwargs, &block)
      favicon = kwargs.key?(:favicon) ? kwargs[:favicon] : nil
      name, title = name_and_content(args)
      heading = nil

      inferred_stylesheets.each { |path| in_head(Node[:stylesheet, { path: path }, []]) }
      layout_stylesheet_url.each { |url| in_head(Node[:stylesheet, { path: url }, []]) }

      value, empty, body = about(name) do
        heading = (title.is_a?(Proc) ? title.call : title)
        # Self-titling: a route that names a subject and says no title takes
        # the subject's own `title` — a document's first heading — and marks
        # itself, so markdown prose begins after that heading rather than
        # repeating it. A subject that answers no `title` falls through to the
        # humanised name.
        if heading.nil? && name && subject.has?(:title)
          heading = subject.fetch(:title)
          @self_titled = true unless heading.nil?
        end
        heading ||= Inference.label(name)
        wrapped_in_frame(&block)
      end

      emit_node(Node[:page, { heading: heading, head: head_nodes, favicon: favicon }, prune(body, empty)])
      value
    end

    # The compiled `.layout` beside this route, as the URL the frame's `<head>`
    # links — `/assets/<basename>.css`, the same convention the studio serves.
    def layout_stylesheet_url
      path = @library && Library.layout_path(view_name, path: @path)
      return [] unless path

      ["/assets/#{File.basename(path, File.extname(path))}.css"]
    end

    private

    # Every place the grammar's Ruby runs — the page, a partial, the tin.
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
      while root.word == :choose && root.children.size == 1 && root.children.first.is_a?(Node)
        root = root.children.first
      end
      root
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
    def html(string) = emit_node(Node[:raw, {}, [string]]) # trusted markup — you escape it
    def element(name, attributes = {}, children = []) = Node[:tag, { name: name, attrs: attributes }, children]
    def tag(name, *args, **kwargs, &block)
      name = name.to_sym
      content = nil
      passed_children = nil
      attrs = {}

      args.each do |arg|
        if arg.is_a?(Hash)
          attrs.merge!(arg)
        elsif arg.is_a?(Array)
          passed_children = arg
        else
          content = arg.nil? ? nil : Generator.plain(arg)
        end
      end
      attrs.merge!(kwargs)

      has_content = !content.nil? && !content.empty?

      children = if block
                   captured = capture(&block)
                   has_content ? [content, *captured] : captured
                 elsif passed_children
                   passed_children
                 elsif has_content
                   [content]
                 else
                   []
                 end

      emit_node(element(name, attrs, children))
    end
    def arguments(args) = name_and_content(args)
  end
end
