# frozen_string_literal: true

require_relative 'contracts'

module SlimPickins
  class Word
    class << self
      def registry
        SlimPickins::Word.instance_variable_get(:@registry) || SlimPickins::Word.instance_variable_set(:@registry, {})
      end

      def family_registry
        SlimPickins::Word.instance_variable_get(:@family_registry) ||
          SlimPickins::Word.instance_variable_set(:@family_registry, {})
      end

      def parent_registry
        SlimPickins::Word.instance_variable_get(:@parent_registry) ||
          SlimPickins::Word.instance_variable_set(:@parent_registry, {})
      end

      def register_family(parent, child, klass = nil)
        parent = parent.to_sym
        child = child.to_sym
        family_registry[parent] ||= {}
        family_registry[parent][child] = klass
        parent_registry[child] ||= []
        parent_registry[child] << parent unless parent_registry[child].include?(parent)
      end

      def family_for(parent)
        family_registry[parent.to_sym] || {}
      end

      def parents_of(child)
        parents = parent_registry[child.to_sym]
        parents.is_a?(Array) ? parents : [parents].compact
      end

      def parent_of(child)
        parents_of(child).first
      end

      def contained?(child)
        parents_of(child).any?
      end

      def inherited(subclass)
        return unless subclass.name

        parts = subclass.name.split('::')
        name = parts.last
        return if name.nil? || %w[AppWord Gatherer PartialWord Encloses Says Registers Head].include?(name)

        word_name = name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
                         gsub(/([a-z\d])([A-Z])/, '\1_\2').
                         tr('-', '_').
                         downcase.to_sym
        SlimPickins::Word.registry[word_name] = subclass

        if parts.size > 3 && parts[-3] == 'Words'
          parent_name = parts[-2].gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
                                  gsub(/([a-z\d])([A-Z])/, '\1_\2').
                                  tr('-', '_').
                                  downcase.to_sym
          register_family(parent_name, word_name, subclass)
        end
      end

      def word_name
        name.split('::').last.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
             gsub(/([a-z\d])([A-Z])/, '\1_\2').
             tr('-', '_').
             downcase.to_sym
      end

      def maps(mapping = nil)
        if mapping
          @mapping = (@mapping || {}).merge(mapping)
        end
        @mapping || {}
      end

      def contract(**kwargs)
        if (parents = parents_of(word_name)).any?
          kwargs[:parents] ||= parents.dup
        end
        @contract = Contract.new(**kwargs)
      end

      def get_contract
        @contract || Contract.new
      end
    end

    def initialize(builder, args, kwargs, block)
      @builder = builder
      @args = args
      @kwargs = kwargs
      @block = block
      @collected = []
    end

    # The word's own name, as the other side of the gathering road asks for it:
    # `open_gatherer_named` matches `g.word`, and until 2026-09-17 no Word
    # instance answered it, so its candidate list was empty by construction and
    # a partial declaring `inside:` could never find its gatherer. A partial's
    # class is anonymous — `Class.new(PartialWord)` — so it answers with the
    # name the Library gave it rather than deriving one from a class name it
    # does not have.
    def word
      self.class.respond_to?(:partial_name) ? self.class.partial_name : self.class.word_name
    end

    def unpack_arguments
      name_val, content_val = arguments(@args)
      c = self.class.get_contract
      mapping = self.class.maps

      attrs = {}

      if name_val && c.name != :none
        key = mapping[:name] || c.name
        key = :name if key == :attribute || key == :subject
        attrs[key] = name_val
      end

      if c.content
        key = mapping[:content] || :content
        if key == :label || key == :legend || key == :alt
          attrs[key] = label_for(name_val, content_val)
        elsif content_val
          attrs[key] = content_val
        end
      end

      attrs.merge!(@kwargs)
      attrs
    end

    def evaluate
      raise NotImplementedError
    end

    def collect(item)
      @collected << item
    end

    def with_open
      @builder.with_family(word) do
        @builder.with_gatherer(self) { @builder.evaluate(&@block) }
      end
    end

    def arguments(args) = @builder.arguments(args)

    # Content that waited to be read where its sentence landed — read now.
    def landed(content) = content.is_a?(Proc) ? content.call : content

    private

    def subject = @builder.subject
    def chain = @builder.chain
    def label_for(...) = @builder.label_for(...)
    def label_of(...) = @builder.label_of(...)
    def format_of(...) = @builder.format_of(...)
    def alignment_of(...) = @builder.alignment_of(...)
    def capture(&block) = @builder.capture(&block)
    def emit_node(node) = @builder.emit_node(node)
    def register!(...) = @builder.register!(...)
    def open_gatherer(...) = @builder.open_gatherer(...)
    def about(...) = @builder.about(...)
    def prune(...) = @builder.prune(...)
    def empty_active? = @builder.empty_active?
    def wrapped_in_frame(&block) = @builder.wrapped_in_frame(&block)
    alias_method :wrapped_in_tin, :wrapped_in_frame
    def head_nodes = @builder.head_nodes
    def in_head(node) = @builder.in_head(node)

    # The stylesheets this page gets without saying so, in precedence order.
    def inferred_stylesheets = @builder.inferred_stylesheets
    def collection_for(name) = @builder.collection_for(name)
    def naming(...) = @builder.naming(...)
    def spliced = @builder.spliced
    def contents_stowed? = @builder.contents_stowed?
    def take_contents = @builder.take_contents
  end

class Encloses < Word
  def evaluate
    children = @builder.with_family(word) { capture(&@block) }
    emit_node(Node[self.class.word_name, unpack_arguments, children])
  end
end

class Says < Word
  def evaluate
    emit_node(Node[self.class.word_name, unpack_arguments, []])
  end
end

class Registers < Word
  class << self
    def registers_to(target, type:)
      @register_target = target
      @register_type = type
    end
    attr_reader :register_target, :register_type
  end

  def evaluate
    register!(self.class.register_target, unpack_arguments, self.class.register_type)
  end
end
class Head < Word
  def evaluate
    in_head(Node[self.class.word_name, unpack_arguments, []])
  end
end

end
