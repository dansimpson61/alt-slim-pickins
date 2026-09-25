# frozen_string_literal: true

require_relative '../transform'

module SlimPickins
  module Compiler
    # Translates a high-level spatial manifesto (.design) into modern, high-grade CSS:
    # Container Queries (@container), CSS Grid (minmax), and fluid clamp() scaling.
    #
    # Sandi Metz & Jim Weirich architecture:
    # - Small, single-purpose DSL evaluation contexts (Surface, Stage, Zone).
    # - Injected, themeable token dictionaries (Air, Balance, Frame, Cadence, Treatment).
    # - 100% compatible with SlimPickins::Transform.
    class DesignIdiom
      AIR_TOKENS = {
        tight: 'clamp(0.5rem, 1.5cqi, 0.875rem)',
        balanced: 'clamp(1rem, 2.5cqi, 1.75rem)',
        generous: 'clamp(1.5rem, 4cqi, 3rem)'
      }.freeze

      BALANCE_TOKENS = {
        subordinate: { lead: 'minmax(14rem, 1fr)', companion: 'minmax(0, 3fr)' },
        equal:       { lead: 'minmax(0, 1fr)',      companion: 'minmax(0, 1fr)' },
        dominant:    { lead: 'minmax(0, 3fr)',      companion: 'minmax(14rem, 1fr)' }
      }.freeze

      FRAME_TOKENS = {
        quiet: {
          'background' => 'var(--surface-soft, #f9f8f5)',
          'border' => '1px solid var(--rule, #e5e1d8)',
          'border-radius' => 'var(--radius, 4px)',
          'padding' => 'clamp(0.75rem, 1.5cqi, 1rem)'
        },
        lifted: {
          'background' => 'var(--surface, #ffffff)',
          'box-shadow' => '0 2px 8px rgba(0, 0, 0, 0.08)',
          'border-radius' => 'var(--radius, 4px)',
          'padding' => 'clamp(1rem, 2cqi, 1.5rem)'
        },
        bordered: {
          'border' => '1px solid var(--rule, #e5e1d8)',
          'border-radius' => 'var(--radius, 4px)',
          'padding' => 'clamp(0.75rem, 1.5cqi, 1rem)'
        },
        flat: {
          'background' => 'transparent',
          'border' => 'none',
          'padding' => '0'
        }
      }.freeze

      CADENCE_TOKENS = {
        compact: '0.35rem',
        regular: '0.75rem',
        relaxed: '1.25rem'
      }.freeze

      TREATMENT_TOKENS = {
        editorial: {
          'max-width' => '65ch',
          'line-height' => '1.7',
          'font-size' => '1.05rem'
        },
        prose: {
          'max-width' => '70ch',
          'line-height' => '1.6'
        },
        code: {
          'font-family' => 'var(--font-mono, monospace)',
          'font-size' => '0.9rem'
        },
        tabular: {
          'font-variant-numeric' => 'tabular-nums'
        }
      }.freeze

      DEFAULT_COLLAPSE_THRESHOLD = '48rem'

      attr_reader :air_tokens, :balance_tokens, :frame_tokens, :cadence_tokens, :treatment_tokens

      def self.compile(source, path: '(design)', **theme_tokens)
        new(**theme_tokens).compile(source, path: path)
      end

      def initialize(air_tokens: AIR_TOKENS, balance_tokens: BALANCE_TOKENS,
                     frame_tokens: FRAME_TOKENS, cadence_tokens: CADENCE_TOKENS,
                     treatment_tokens: TREATMENT_TOKENS)
        @air_tokens = air_tokens
        @balance_tokens = balance_tokens
        @frame_tokens = frame_tokens
        @cadence_tokens = cadence_tokens
        @treatment_tokens = treatment_tokens
      end

      def compile(source, path: '(design)')
        return '' if source.to_s.strip.empty?

        ruby = Transform.call(source, path: path)
        builder = RootBuilder.new(self)
        builder.instance_eval(ruby, path, 1)
        builder.to_css
      end

      # --- DSL Evaluation Contexts -----------------------------------------

      class BaseBuilder
        def initialize(compiler)
          @compiler = compiler
          @lines = []
        end

        def with_line(lineno)
          @lines.push(lineno)
          yield
        ensure
          @lines.pop
        end
      end

      class RootBuilder < BaseBuilder
        def initialize(compiler)
          super(compiler)
          @surfaces = []
        end

        def surface(name, &block)
          surface_builder = SurfaceBuilder.new(@compiler, name.to_sym)
          surface_builder.instance_eval(&block) if block
          @surfaces << surface_builder
        end

        def to_css
          @surfaces.map(&:to_css).reject(&:empty?).join("\n\n")
        end
      end

      class SurfaceBuilder < BaseBuilder
        attr_reader :name, :stages, :zones

        def initialize(compiler, name)
          super(compiler)
          @name = name
          @stages = []
          @zones = []
        end

        def stage(stage_name = nil, &block)
          sb = StageBuilder.new(@compiler, @name, stage_name || @name)
          sb.instance_eval(&block) if block
          @stages << sb
        end

        def zone(zone_name, &block)
          zb = ZoneBuilder.new(@compiler, @name, zone_name.to_sym)
          zb.instance_eval(&block) if block
          @zones << zb
        end

        def to_css
          rules = [
            ".surface-#{@name} { display: block; width: 100%; }"
          ]
          rules.concat(@stages.map(&:to_css))
          rules.concat(@zones.map(&:to_css))
          rules.reject(&:empty?).join("\n\n")
        end
      end

      class StageBuilder < BaseBuilder
        attr_reader :surface_name, :stage_name

        def initialize(compiler, surface_name, stage_name)
          super(compiler)
          @surface_name = surface_name
          @stage_name = stage_name
          @air_level = nil
          @flank_rule = nil
          @stack_rule = nil
        end

        def air(level)
          level_sym = level.to_sym
          @air_level = @compiler.air_tokens.fetch(level_sym) do
            raise ArgumentError, "Unknown air token: `#{level}`"
          end
        end

        def flank(lead_zone, beside:, balance: :equal, collapse_at: DEFAULT_COLLAPSE_THRESHOLD)
          balance_sym = balance.to_sym
          tracks = @compiler.balance_tokens.fetch(balance_sym) do
            raise ArgumentError, "Unknown balance token: `#{balance}`"
          end

          @flank_rule = {
            lead: lead_zone.to_sym,
            companion: beside.to_sym,
            tracks: tracks,
            collapse_at: collapse_at
          }
        end

        def stack(*zones, air: nil)
          air(air) if air
          @stack_rule = { zones: zones.map(&:to_sym) }
        end

        def to_css
          rules = []
          target = ".stage-#{@stage_name}, body"

          # Container Query Context & Air
          rules << <<~CSS.strip
            #{target} {
              container-type: inline-size;
              container-name: #{@stage_name};
              display: grid;
              align-items: start;
              padding: #{@air_level || '0'};
              gap: #{@air_level || '0'};
            }
          CSS

          if @flank_rule
            lead = @flank_rule[:lead]
            companion = @flank_rule[:companion]
            cols = "#{@flank_rule[:tracks][:lead]} #{@flank_rule[:tracks][:companion]}"

            rules << <<~CSS.strip
              #{target} {
                grid-template-columns: #{cols};
              }

              .stage-#{@stage_name} > h1:first-child,
              body > h1:first-child {
                grid-column: 1 / -1;
              }
            CSS

            rules << <<~CSS.strip
              .stage-#{@stage_name} > .#{lead},
              .stage-#{@stage_name} > .zone-#{lead},
              body > .#{lead},
              body > .zone-#{lead} {
                grid-column: 1;
              }

              .stage-#{@stage_name} > .#{companion},
              .stage-#{@stage_name} > .zone-#{companion},
              body > .#{companion},
              body > .zone-#{companion} {
                grid-column: 2;
              }
            CSS

            rules << <<~CSS.strip
              @container #{@stage_name} (inline-size < #{@flank_rule[:collapse_at]}) {
                #{target} {
                  grid-template-columns: 100%;
                }
                .stage-#{@stage_name} > .#{lead},
                .stage-#{@stage_name} > .zone-#{lead},
                .stage-#{@stage_name} > .#{companion},
                .stage-#{@stage_name} > .zone-#{companion},
                body > .#{lead},
                body > .zone-#{lead},
                body > .#{companion},
                body > .zone-#{companion} {
                  grid-column: 1;
                }
              }
            CSS
          elsif @stack_rule
            rules << <<~CSS.strip
              #{target} {
                display: flex;
                flex-direction: column;
              }
            CSS
          end

          rules.reject(&:empty?).join("\n\n")
        end
      end

      class ZoneBuilder < BaseBuilder
        attr_reader :surface_name, :zone_name

        def initialize(compiler, surface_name, zone_name)
          super(compiler)
          @surface_name = surface_name
          @zone_name = zone_name
          @properties = {}
          @child_gap = nil
        end

        def air(level)
          level_sym = level.to_sym
          spacing = @compiler.air_tokens.fetch(level_sym) do
            raise ArgumentError, "Unknown air token: `#{level}`"
          end
          @properties['padding'] = spacing
          @properties['gap'] = spacing
        end

        def frame(kind)
          kind_sym = kind.to_sym
          frame_props = @compiler.frame_tokens.fetch(kind_sym) do
            raise ArgumentError, "Unknown frame token: `#{kind}`"
          end
          @properties.merge!(frame_props)
        end

        def cadence(kind)
          kind_sym = kind.to_sym
          gap = @compiler.cadence_tokens.fetch(kind_sym) do
            raise ArgumentError, "Unknown cadence token: `#{kind}`"
          end
          @child_gap = gap
        end

        def treatment(kind)
          kind_sym = kind.to_sym
          treatment_props = @compiler.treatment_tokens.fetch(kind_sym) do
            raise ArgumentError, "Unknown treatment token: `#{kind}`"
          end
          @properties.merge!(treatment_props)
        end

        def to_css
          rules = []
          target = ".stage-#{@surface_name} > .#{@zone_name},\n.stage-#{@surface_name} > .zone-#{@zone_name},\nbody > .#{@zone_name},\nbody > .zone-#{@zone_name}"

          unless @properties.empty?
            props_str = @properties.map { |k, v| "  #{k}: #{v};" }.join("\n")
            rules << <<~CSS.strip
              #{target} {
              #{props_str}
              }
            CSS
          end

          if @child_gap
            rules << <<~CSS.strip
              #{target} {
                display: flex;
                flex-direction: column;
                gap: #{@child_gap};
              }
            CSS
          end

          rules.reject(&:empty?).join("\n\n")
        end
      end
    end
  end

  # Public entrypoint
  module DesignIdiom
    def self.compile(source, path: '(design)', **theme_tokens)
      Compiler::DesignIdiom.compile(source, path: path, **theme_tokens)
    end
  end
end
