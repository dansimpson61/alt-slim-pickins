# frozen_string_literal: true

require_relative 'contracts'

module SlimPickins
  class Word
    class << self
      def registry
        SlimPickins::Word.instance_variable_get(:@registry) || SlimPickins::Word.instance_variable_set(:@registry, {})
      end

      def inherited(subclass)
return unless subclass.name
name = subclass.name.split('::').last
unless name.nil? || %w[AppWord Gatherer PartialWord Encloses Says Registers Head].include?(name)
  word_name = name.gsub(/([A-Z]+)([A-Z][a-z])/,'_').
                   gsub(/([a-z\d])([A-Z])/,'_').
                   tr("-", "_").
                   downcase.to_sym
  SlimPickins::Word.registry[word_name] = subclass
end
      end

      def word_name
        name.split('::').last.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
             gsub(/([a-z\d])([A-Z])/,'\1_\2').
             tr("-", "_").
             downcase.to_sym
      end

      def maps(mapping = nil)
        if mapping
          @mapping = (@mapping || {}).merge(mapping)
        end
        @mapping || {}
      end

      def contract(**kwargs)
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
      @builder.with_gatherer(self) { @builder.evaluate(&@block) }
    end

    def arguments(args) = @builder.arguments(args)

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
    def wrapped_in_layout(&block) = @builder.wrapped_in_layout(&block)
    def head_nodes = @builder.head_nodes
    def in_head(node) = @builder.in_head(node)
    def collection_for(name) = @builder.collection_for(name)
    def bind(name, value) = @builder.bind(name, value)
    def unbind(name) = @builder.unbind(name)
    def spliced = @builder.spliced
    def contents_stowed? = @builder.contents_stowed?
    def take_contents = @builder.take_contents
  end

class Encloses < Word
  def evaluate
    emit_node([self.class.word_name, unpack_arguments, capture(&@block)])
  end
end

class Says < Word
  def evaluate
    emit_node([self.class.word_name, unpack_arguments, []])
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
    in_head([self.class.word_name, unpack_arguments, []])
  end
end

end
