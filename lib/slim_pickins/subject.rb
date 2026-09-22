# frozen_string_literal: true

require_relative 'errors'

module SlimPickins
  # A subject is whatever `.foo` asks. Every subject is wrapped so that a
  # missing attribute raises in the language's terms instead of resolving to
  # nothing.
  class Subject
    # `fallback` is the subject beneath this one, answered when this subject
    # does not hold the attribute. Only a partial's parameters use it — an
    # overlay — so a declared partial's slots are its scope and the rest of
    # the world stays visible.
    def initialize(object, described_as: nil, fallback: nil)
      @object = object
      @described_as = described_as
      @fallback = fallback
    end

    attr_reader :object, :fallback

    def to_s
      @object.to_s
    end

    def to_str
      @object.respond_to?(:to_str) ? @object.to_str : @object.to_s
    end

    def overlay? = !@fallback.nil?

    def describe
      return 'nothing' if @object.nil?

      @described_as || "this #{@object.class.name.split('::').last.downcase}"
    end

    def nothing? = @object.nil?

    # What to call this subject in an id or a class. Anonymous structs have no
    # class name, so the name the chain gave it wins when there is one.
    def noun
      return @described_as.sub(/\Athis /, '') if @described_as

      @object.class.name&.split('::')&.last&.downcase || 'item'
    end

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
      if @object.is_a?(Hash)
        return true if @object.key?(attribute) || @object.key?(attribute.to_s)
        if attribute.to_s.end_with?('?')
          base = attribute.to_s.chomp('?')
          return true if @object.key?(base.to_sym) || @object.key?(base)
        end
      elsif !@object.nil? && @object.respond_to?(attribute)
        return true
      end
      @fallback ? @fallback.has?(attribute) : false
    end

    def fetch(attribute)
      if @object.is_a?(Hash)
        if @object.key?(attribute)
          return @object[attribute]
        elsif @object.key?(attribute.to_s)
          return @object[attribute.to_s]
        elsif attribute.to_s.end_with?('?')
          base = attribute.to_s.chomp('?')
          return @object[base.to_sym] if @object.key?(base.to_sym)
          return @object[base] if @object.key?(base)
        end
      elsif !@object.nil? && @object.respond_to?(attribute)
        return @object.public_send(attribute)
      end
      return @fallback.fetch(attribute) if @fallback

      raise Nothing.new(attribute, self) if @object.nil?

      raise UnknownAttribute.new(attribute, self)
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
      return true if @locals.key?(name.to_sym)
      if name.to_s.end_with?('?')
        base = name.to_s.chomp('?').to_sym
        return true if @locals.key?(base)
      end
      !!@helpers&.respond_to?(name) || super
    end

    def method_missing(name, *args)
      return @locals[name.to_sym] if @locals.key?(name.to_sym)
      if name.to_s.end_with?('?')
        base = name.to_s.chomp('?').to_sym
        return @locals[base] if @locals.key?(base)
      end
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

    # `overlay:` pushes a subject that falls through to the one beneath for
    # anything it does not answer itself — a partial's declared slots are
    # scope, the rest of the chain stays visible.
    def with(object, described_as: nil, overlay: false)
      fallback = overlay ? @stack.last : nil
      @stack.push(Subject.new(object, described_as: described_as, fallback: fallback))
      yield
    ensure
      @stack.pop
    end

    def depth = @stack.size

    def container_value(modifier)
      curr = @stack.last
      while curr&.fallback
        if curr.object.is_a?(Hash)
          return [true, curr.object[modifier]] if curr.object.key?(modifier)
          return [true, curr.object[modifier.to_s]] if curr.object.key?(modifier.to_s)
        end
        curr = curr.fallback
      end
      [false, nil]
    end
  end
end
