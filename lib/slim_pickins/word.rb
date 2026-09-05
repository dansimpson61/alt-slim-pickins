# frozen_string_literal: true

require_relative 'contracts'

module SlimPickins
  class Word
    class << self
      def registry
        @registry ||= {}
      end

      def inherited(subclass)
return unless subclass.name
name = subclass.name.split('::').last
unless name.nil? || name == "AppWord" || name == "Gatherer" || name == "PartialWord"
  word_name = name.gsub(/([A-Z]+)([A-Z][a-z])/,'_').
                   gsub(/([a-z\d])([A-Z])/,'_').
                   tr("-", "_").
                   downcase.to_sym
  registry[word_name] = subclass
end
      end

      def word_name
        name.split('::').last.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
             gsub(/([a-z\d])([A-Z])/,'\1_\2').
             tr("-", "_").
             downcase.to_sym
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
    def sprite_symbols = @builder.sprite_symbols
    def in_head(node) = @builder.in_head(node)
    def use_icon(name) = @builder.use_icon(name)
    def collection_for(name) = @builder.collection_for(name)
    def bind(name, value) = @builder.bind(name, value)
    def unbind(name) = @builder.unbind(name)
    def spliced = @builder.spliced
    def contents_stowed? = @builder.contents_stowed?
    def take_contents = @builder.take_contents
  end
end

    class Encloses < Word
      def evaluate
        name, content = arguments(@args)
        attrs = {}
        attrs[:name] = name if name
        attrs[:label] = label_for(name, content) if name && content
        attrs.merge!(@kwargs)
        emit_node([self.class.word_name, attrs, capture(&@block)])
      end
    end

    class Says < Word
      def evaluate
        name, content = arguments(@args)
        attrs = {}
        attrs[:name] = name if name
        attrs[:content] = content if content
        attrs.merge!(@kwargs)
        emit_node([self.class.word_name, attrs, []])
      end
    end
