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

      POSTURE_TOKENS = {
        shelf:     'minmax(14rem, 19rem)',
        workspace: 'minmax(0, 3fr)',
        mirror:    'minmax(0, 2fr)',
        aside:     'minmax(16rem, 1fr)',
        equal:     'minmax(0, 1fr)'
      }.freeze

      COLLAPSE_TOKENS = {
        tight: '26rem',
        cozy:  '48rem',
        roomy: '56rem',
        wide:  '64rem'
      }.freeze

      DEFAULT_COLLAPSE_TOKEN = :cozy

      attr_reader :air_tokens, :balance_tokens, :posture_tokens, :frame_tokens, :cadence_tokens, :treatment_tokens, :collapse_tokens

      def self.compile(source, path: '(design)', **theme_tokens)
        new(**theme_tokens).compile(source, path: path)
      end

      # One pipeline for "design source becomes labeled CSS," used by every
      # caller instead of each compiling and commenting its own way. Empty
      # source stays empty — no comment over nothing.
      def self.compiled_stylesheet(source, provenance:, path: '(design)', **theme_tokens)
        css = compile(source, path: path, **theme_tokens)
        return css if css.empty?

        "/* Compiled #{provenance} */\n\n#{css}"
      end

      def initialize(air_tokens: AIR_TOKENS, balance_tokens: BALANCE_TOKENS,
                     posture_tokens: POSTURE_TOKENS, frame_tokens: FRAME_TOKENS,
                     cadence_tokens: CADENCE_TOKENS, treatment_tokens: TREATMENT_TOKENS,
                     collapse_tokens: COLLAPSE_TOKENS)
        @air_tokens = air_tokens
        @balance_tokens = balance_tokens
        @posture_tokens = posture_tokens
        @frame_tokens = frame_tokens
        @cadence_tokens = cadence_tokens
        @treatment_tokens = treatment_tokens
        @collapse_tokens = collapse_tokens
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
          @default_stage = nil
        end

        def default_stage
          @default_stage ||= begin
            sb = StageBuilder.new(@compiler, @name, @name)
            @stages << sb
            sb
          end
        end

        def air(level)
          default_stage.air(level)
        end

        def horizon(*zones, &block)
          default_stage.horizon(*zones, &block)
        end

        def flank(lead_zone, beside:, balance: :equal, collapse: DEFAULT_COLLAPSE_TOKEN)
          default_stage.flank(lead_zone, beside: beside, balance: balance, collapse: collapse)
        end

        def stack(*zones, air: nil)
          default_stage.stack(*zones, air: air)
        end

        def stage(stage_name = nil, &block)
          sb = if (stage_name.nil? || stage_name.to_sym == @name.to_sym) && @default_stage && !@default_stage.has_rules?
                 @default_stage
               else
                 StageBuilder.new(@compiler, @name, stage_name || @name).tap { |s| @stages << s }
               end
          sb.instance_eval(&block) if block
          sb
        end

        def zone(zone_name, &block)
          zb = ZoneBuilder.new(@compiler, @name, zone_name.to_sym)
          zb.instance_eval(&block) if block
          @zones << zb
          zb
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
        attr_reader :surface_name, :stage_name, :air_level, :flank_rule, :stack_rule, :horizon_rule

        def initialize(compiler, surface_name, stage_name)
          super(compiler)
          @surface_name = surface_name
          @stage_name = stage_name
          @air_level = nil
          @flank_rule = nil
          @stack_rule = nil
          @horizon_rule = nil
        end

        def has_rules?
          !(@air_level.nil? && @flank_rule.nil? && @stack_rule.nil? && @horizon_rule.nil?)
        end

        def air(level)
          level_sym = level.to_sym
          @air_level = @compiler.air_tokens.fetch(level_sym) do
            raise ArgumentError, "Unknown air token: `#{level}`"
          end
        end

        def flank(lead_zone, beside:, balance: :equal, collapse: DEFAULT_COLLAPSE_TOKEN)
          balance_sym = balance.to_sym
          tracks = @compiler.balance_tokens.fetch(balance_sym) do
            raise ArgumentError, "Unknown balance token: `#{balance}`"
          end
          collapse_value = @compiler.collapse_tokens.fetch(collapse.to_sym) do
            raise ArgumentError, "Unknown collapse token: `#{collapse}`"
          end

          @flank_rule = {
            lead: lead_zone.to_sym,
            companion: beside.to_sym,
            tracks: tracks,
            collapse_at: collapse_value
          }
        end

        def stack(*zones, air: nil)
          air(air) if air
          @stack_rule = { zones: zones.map(&:to_sym) }
        end

        def horizon(*zones, &block)
          hb = HorizonBuilder.new(@compiler, zones)
          hb.instance_eval(&block) if block

          tracks = hb.postures.map do |role|
            if role.is_a?(String)
              role
            else
              @compiler.posture_tokens.fetch(role.to_sym) do
                raise ArgumentError, "Unknown posture token: `#{role}`"
              end
            end
          end

          @horizon_rule = {
            zones: hb.zones,
            tracks: tracks,
            collapse_at: hb.collapse_threshold
          }
        end

        def to_css
          rules = []
          targets = if @stage_name.to_sym == @surface_name.to_sym
                      [".stage-#{@stage_name}",
                       ".#{@stage_name}",
                       ".surface-#{@surface_name}",
                       "body:has(> .sidebar_layout) > .sidebar_layout",
                       ".sidebar_layout:has(> .library)",
                       "body:not(:has(> .sidebar_layout))"]
                    else
                      [".stage-#{@stage_name}", ".#{@stage_name}"]
                    end
          target = targets.join(', ')

          # Container Query Context & Air
          rules << <<~CSS.strip
            #{target} {
              container-type: inline-size;
              container-name: #{@stage_name};
              display: grid;
              align-items: start;
              padding: #{@air_level || '0'};
              gap: #{@air_level || '0'};
              box-sizing: border-box;
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

              #{targets.map { |t| "#{t} > h1:first-child" }.join(",\n")} {
                grid-column: 1 / -1;
              }
            CSS

            lead_sels = targets.map { |t| "#{t} > .#{lead},\n#{t} > .zone-#{lead}" }.join(",\n")
            companion_sels = targets.map { |t| "#{t} > .#{companion},\n#{t} > .zone-#{companion}" }.join(",\n")

            rules << <<~CSS.strip
              #{lead_sels} {
                grid-column: 1;
              }

              #{companion_sels} {
                grid-column: 2;
              }
            CSS

            rules << <<~CSS.strip
              @container #{@stage_name} (inline-size < #{@flank_rule[:collapse_at]}) {
                #{target} {
                  grid-template-columns: 100%;
                }
                #{lead_sels},
                #{companion_sels} {
                  grid-column: 1;
                }
              }
            CSS
          elsif @horizon_rule
            zones = @horizon_rule[:zones]
            cols = @horizon_rule[:tracks].join(' ')

            rules << <<~CSS.strip
              #{target} {
                grid-template-columns: #{cols};
              }

              #{targets.map { |t| "#{t} > h1:first-child" }.join(",\n")} {
                grid-column: 1 / -1;
              }

              #{targets.map { |t| "#{t} > .panes" }.join(",\n")} {
                display: contents;
              }
            CSS

            # Sandi Metz hygiene baseline: prevent flex/grid item overflow blowout
            hygiene_sels = zones.flat_map do |zone|
              targets.map { |t| "#{t} > .#{zone},\n#{t} > .zone-#{zone}" } + [".#{zone}", ".zone-#{zone}"]
            end.uniq.join(",\n")

            rules << <<~CSS.strip
              #{hygiene_sels} {
                min-height: 0;
                min-width: 0;
              }
            CSS

            # Explicit column placement for each zone (1-indexed)
            zones.each_with_index do |zone, index|
              col_idx = index + 1
              zone_sels = targets.map do |t|
                "#{t} > .#{zone},\n#{t} > .zone-#{zone},\n#{t} > * > .#{zone},\n#{t} > * > .zone-#{zone}"
              end.join(",\n")

              rules << <<~CSS.strip
                #{zone_sels} {
                  grid-column: #{col_idx};
                }
              CSS
            end

            # Container Query Collapse
            all_zone_sels = zones.flat_map do |zone|
              targets.map do |t|
                "#{t} > .#{zone},\n#{t} > .zone-#{zone},\n#{t} > * > .#{zone},\n#{t} > * > .zone-#{zone}"
              end
            end.join(",\n")

            rules << <<~CSS.strip
              @container #{@stage_name} (inline-size < #{@horizon_rule[:collapse_at]}) {
                #{target} {
                  grid-template-columns: 100%;
                }
                #{all_zone_sels} {
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

      class HorizonBuilder < BaseBuilder
        attr_reader :zones, :postures, :collapse_threshold

        def initialize(compiler, zones)
          super(compiler)
          @zones = zones.map(&:to_sym)
          @postures = Array.new(@zones.size, :equal)
          @collapse_threshold = compiler.collapse_tokens.fetch(DEFAULT_COLLAPSE_TOKEN)
        end

        def posture(*roles)
          if roles.size != @zones.size
            raise ArgumentError, "horizon with #{@zones.size} zones (#{@zones.join(', ')}) expected #{@zones.size} postures, got #{roles.size} (#{roles.join(', ')})"
          end
          @postures = roles.map(&:to_sym)
        end

        def collapse(level)
          @collapse_threshold = @compiler.collapse_tokens.fetch(level.to_sym) do
            raise ArgumentError, "Unknown collapse token: `#{level}`"
          end
        end
      end

      class ZoneBuilder < BaseBuilder
        attr_reader :surface_name, :zone_name, :properties, :child_gap,
                    :scroll_kind, :presence_kind, :focus_kind

        def initialize(compiler, surface_name, zone_name)
          super(compiler)
          @surface_name = surface_name
          @zone_name = zone_name
          @properties = {}
          @child_gap = nil
          @scroll_kind = nil
          @presence_kind = nil
          @focus_kind = nil
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

        def scroll(kind)
          @scroll_kind = kind.to_sym
        end

        def presence(kind)
          @presence_kind = kind.to_sym
        end

        def focus(kind)
          @focus_kind = kind.to_sym
        end

        def to_css
          rules = []
          targets = [
            ".stage-#{@surface_name} > .#{@zone_name}",
            ".stage-#{@surface_name} > .zone-#{@zone_name}",
            ".stage-#{@surface_name} .#{@zone_name}",
            "body > .#{@zone_name}",
            "body > .zone-#{@zone_name}",
            ".#{@zone_name}",
            ".zone-#{@zone_name}"
          ]
          target = targets.join(",\n")

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

          if @scroll_kind == :internal
            rules << <<~CSS.strip
              #{target} {
                overflow-y: auto;
                overscroll-behavior: contain;
                min-height: 0;
              }

              #{targets.map { |t| "#{t} .tab-panel" }.join(",\n")} {
                max-height: var(--panel-height, 28rem);
                overflow-y: auto;
                overflow-x: hidden;
                overscroll-behavior: contain;
              }
            CSS
          end

          if @presence_kind == :steady
            rules << <<~CSS.strip
              #{target} {
                position: sticky;
                top: var(--gap, 0.75rem);
                align-self: start;
                height: calc(100dvh - var(--menu-height, 2.75rem) - var(--footer-height, 2rem) - var(--gap-loose, 1.5rem));
                max-height: calc(100dvh - var(--menu-height, 2.75rem) - var(--footer-height, 2rem) - var(--gap-loose, 1.5rem));
                overflow: hidden;
                box-sizing: border-box;
              }

              #{targets.map { |t| "#{t} .tabs" }.join(",\n")} {
                display: flex;
                flex-direction: column;
                height: 100%;
                min-height: 0;
              }

              #{targets.map { |t| "#{t} .tabs-content" }.join(",\n")} {
                flex: 1 1 0;
                min-height: 0;
                height: 100%;
              }

              #{targets.map { |t| "#{t} .tab-panel" }.join(",\n")} {
                height: 100%;
                min-height: 0;
                overflow-y: auto;
              }

              #{targets.map { |t| "#{t} iframe,\n#{t} .iframe" }.join(",\n")} {
                width: 100%;
                height: 100%;
                border: none;
              }
            CSS
          end

          if @focus_kind == :primary
            rules << <<~CSS.strip
              #{target} {
                display: flex;
                flex-direction: column;
                min-height: 0;
              }

              #{targets.map { |t| "#{t} textarea,\n#{t} .form textarea" }.join(",\n")} {
                width: 100%;
                font-family: var(--face-mono, monospace);
                font-size: var(--size-small, 0.875rem);
                line-height: var(--lead-tight, 1.25);
                background: var(--surface, #ffffff);
                border: var(--rule-width, 1px) solid var(--rule, #e5e1d8);
                border-radius: var(--radius, 4px);
                padding: var(--step, 0.25rem) var(--gap, 0.75rem);
                box-sizing: border-box;
                resize: vertical;
              }

              #{targets.map { |t| "#{t} .field:nth-of-type(1) textarea" }.join(",\n")} {
                min-height: var(--editor-source-height, 12rem);
              }

              #{targets.map { |t| "#{t} .field:nth-of-type(2) textarea" }.join(",\n")} {
                min-height: var(--editor-design-height, 9rem);
              }

              #{targets.map { |t| "#{t} .field:nth-of-type(3) textarea" }.join(",\n")} {
                min-height: var(--editor-data-height, 6rem);
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

    def self.compiled_stylesheet(source, provenance:, path: '(design)', **theme_tokens)
      Compiler::DesignIdiom.compiled_stylesheet(source, provenance: provenance, path: path, **theme_tokens)
    end
  end
end
