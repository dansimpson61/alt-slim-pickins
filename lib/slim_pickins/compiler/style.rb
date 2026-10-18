# frozen_string_literal: true

require_relative '../transform'

module SlimPickins
  module Compiler
    # The theme-role companion (`.style`). Where `.layout` says how things sit,
    # `.style` says how the theme speaks — `measure wide`, `gap loose` — and
    # compiles to the `:root` custom properties the theme already owns. The
    # leading line names the surface and its archetype (`publication
    # editorial`); both are labels, and the roles beneath them carry the
    # styling.
    class Style
      MEASURE_TOKENS = { narrow: '55ch', wide: '72ch' }.freeze
      GAP_TOKENS = { tight: '0.5rem', loose: '1.5rem' }.freeze
      DENSITY_TOKENS = { compact: '1.35', airy: '1.7' }.freeze

      # Each role maps to the theme's custom property and its token scale.
      ROLES = {
        measure: ['--measure', MEASURE_TOKENS],
        gap: ['--gap', GAP_TOKENS],
        density: ['--lead', DENSITY_TOKENS]
      }.freeze

      def self.compile(source, path: '(style)')
        new.compile(source, path: path)
      end

      def self.compiled_stylesheet(source, provenance:, path: '(style)')
        css = compile(source, path: path)
        return css if css.empty?

        "/* Compiled #{provenance} */\n\n#{css}"
      end

      def compile(source, path: '(style)')
        return '' if source.to_s.strip.empty?

        ruby = Transform.call(source, path: path)
        builder = Builder.new
        builder.instance_eval(ruby, path, 1)
        builder.to_css
      end

      class Builder
        def initialize
          @roles = {}
          @surface = nil
          @archetype = nil
        end

        def with_line(lineno)
          yield
        end

        # The leading line is the surface and its archetype — `publication
        # editorial` — two bare names no role answers. Captured before any role
        # is declared, so an unknown word after a role is an honest miss. Its
        # block is the role declarations beneath it, evaluated in place.
        def method_missing(name, *args, &block)
          if @roles.empty? && args.size <= 1 && args.all? { |arg| arg.is_a?(Symbol) }
            @surface = name
            @archetype = args.first
            instance_eval(&block) if block
            return
          end

          super
        end

        def respond_to_missing?(_name, _include_private = false) = true

        def measure(token) = (@roles[:measure] = token)
        def gap(token) = (@roles[:gap] = token)
        def density(token) = (@roles[:density] = token)

        def to_css
          declarations = ROLES.filter_map do |role, (property, tokens)|
            token = @roles[role]
            next unless token

            value = tokens[token.to_sym] || raise(ArgumentError, "Unknown #{role} token: `#{token}`")
            "  #{property}: #{value};"
          end
          return '' if declarations.empty?

          ":root {\n#{declarations.join("\n")}\n}"
        end
      end
    end
  end

  # Public entrypoint, mirroring `SlimPickins::Layout`.
  module Style
    def self.compile(source, path: '(style)', **_theme_tokens)
      Compiler::Style.compile(source, path: path)
    end

    def self.compiled_stylesheet(source, provenance:, path: '(style)', **_theme_tokens)
      Compiler::Style.compiled_stylesheet(source, provenance: provenance, path: path)
    end
  end
end
