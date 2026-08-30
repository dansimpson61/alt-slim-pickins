# frozen_string_literal: true

require_relative 'errors'

module SlimPickins
  # A subject is whatever `.foo` asks. Every subject is wrapped so that a
  # missing attribute raises in the language's terms instead of resolving to
  # nothing.
  class Subject
    def initialize(object, described_as: nil)
      @object = object
      @described_as = described_as
    end

    attr_reader :object

    def describe
      return 'nothing' if @object.nil?

      @described_as || "this #{@object.class.name.split('::').last.downcase}"
    end

    def nothing? = @object.nil?

    # The one optional half of the contract. An app that knows its own
    # vocabulary can say so; one that does not gets a humanised name.
    # `ss_primary_amount` means something specific to roth, and roth is the
    # only thing that knows it.
    def label_for(attribute)
      return nil unless @object.respond_to?(:label_for)

      @object.label_for(attribute)
    end

    # The same shape as label_for, for the same reason: a number's shape
    # cannot say whether it is money.
    def format_for(attribute)
      return nil unless @object.respond_to?(:format_for)

      @object.format_for(attribute)
    end

    # One definition of "has", used by both fetch and respond_to?. They
    # disagreed once — fetch understood hash keys and respond_to? did not — and
    # a hash-backed subject behaved differently from a struct-backed one.
    def has?(attribute)
      return false if @object.nil?
      return @object.key?(attribute) || @object.key?(attribute.to_s) if @object.is_a?(Hash)

      @object.respond_to?(attribute)
    end

    def fetch(attribute)
      raise Nothing.new(attribute, self) if @object.nil?
      raise UnknownAttribute.new(attribute, self) unless has?(attribute)

      if @object.is_a?(Hash)
        return @object.key?(attribute) ? @object[attribute] : @object[attribute.to_s]
      end

      @object.public_send(attribute)
    end

    def method_missing(name, *args)
      return fetch(name) if args.empty?

      super
    end

    def respond_to_missing?(name, include_private = false)
      has?(name) || super
    end
  end

  # The page is the outermost subject — VBA's implied Application. Its
  # attributes are the locals and helpers the app provides, which is why
  # resolution needs only one rule instead of three.
  class Page
    def initialize(locals: {}, helpers: nil)
      @locals = locals.transform_keys(&:to_sym)
      @helpers = helpers
    end

    def members = @locals.keys

    # Only respond_to_missing? is overridden. Overriding respond_to? as well
    # makes the two call each other for ever.
    def respond_to_missing?(name, include_private = false)
      @locals.key?(name.to_sym) || !!@helpers&.respond_to?(name) || super
    end

    def method_missing(name, *args)
      return @locals[name.to_sym] if @locals.key?(name.to_sym)
      return @helpers.public_send(name, *args) if @helpers&.respond_to?(name)

      super
    end
  end

  # The chain itself. `.foo` always means the innermost subject; there is
  # always one, because the page sits at the bottom.
  class Chain
    def initialize(page)
      @stack = [Subject.new(page, described_as: 'this page')]
    end

    def current = @stack.last

    def with(object, described_as: nil)
      @stack.push(Subject.new(object, described_as: described_as))
      yield
    ensure
      @stack.pop
    end

    def depth = @stack.size
  end
end
