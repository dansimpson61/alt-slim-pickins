# frozen_string_literal: true

require 'cgi'

module Roth
  # roth's two charts, drawn on the server.
  #
  # The vocabulary's `chart` word draws a single series and no more; ROADMAP
  # Phase 8 exists to redraft it against a real need, and this is that need.
  # Stacked bands, a tax overlay, bracket shading and a hover layer are past
  # what one word should carry, so they are roth's own words — which is the
  # Phase 6 answer, applied.
  #
  # Two things fall out of drawing this in Ruby rather than in the browser:
  #
  #   - It has a `viewBox`, so it is responsive for free. roth's client-drawn
  #     chart measures `clientWidth` once at load and never redraws on resize.
  #   - The balance chart exists at all. It is the one the specification asked
  #     for — Traditional against Roth over time — and its data has been on the
  #     wire the whole time, thrown away by `extractSeries`.
  class Chart
    W = 800
    H = 320
    # The top strip holds the key.
    M = { l: 64, r: 16, t: 34, b: 40 }.freeze

    INNER_W = W - M[:l] - M[:r]
    INNER_H = H - M[:t] - M[:b]

    def initialize(years, standard_deduction: 0, brackets: [], baseline: nil)
      @years = years
      @standard_deduction = standard_deduction.to_f
      @brackets = brackets
      @baseline = baseline
    end

    # What the hand-written page drew: where each year's income comes from,
    # with the tax it attracts laid over it.
    #
    # The do-nothing line is drawn whenever there is one. roth put it behind a
    # "Show Baseline" checkbox because a script had to redraw for it; drawn on
    # the server there is nothing to defer, and a control the reader does not
    # have to find is one fewer control.
    def income
      bands = [[:base_income, 'stack-base'], [:social_security, 'stack-ss'],
               [:rmd, 'stack-rmd'], [:conversion, 'stack-conv']]
      tops = @years.map { |y| bands.sum { |name, _| value(y, name) } }
      tops += @baseline.map { |y| value(y, :gross_income) } if @baseline
      scale = nice([tops.max, @standard_deduction].max)

      overlays = [['Federal tax', 'tax-line']]
      overlays << ['Do nothing', 'baseline-line'] if @baseline

      svg('income', deduction_band(scale) + bracket_bands(scale) +
                    stacked(bands, scale) + baseline_line(scale) +
                    line(@years.map { |y| value(y, :federal_tax) }, scale, 'tax-line') +
                    frame(scale) + key(bands, overlays) + hover(scale, bands))
    end

    # What the specification asked for and nobody built: the wealth story.
    def balances
      bands = [[:trad_end, 'stack-trad'], [:roth_end, 'stack-roth']]
      top = @years.map { |y| bands.sum { |name, _| value(y, name) } }.max
      scale = nice(top)

      svg('balances', stacked(bands, scale) + frame(scale) + key(bands) + hover(scale, bands))
    end

    private

    def baseline_line(scale)
      return '' unless @baseline

      line(@baseline.map { |y| value(y, :gross_income) }, scale, 'baseline-line')
    end

    # roth built its legend in the browser, out of divs, beside the picture.
    # Drawn here it is part of the picture it describes, and it survives the
    # fragment swap for free.
    # `overlays` is passed rather than inferred, so the key can only ever
    # describe what the caller actually drew. Inferring it put a "Do nothing"
    # swatch on the balance chart, which has no such line.
    def key(bands, overlays = [])
      entries = bands.map { |name, css| [@years.first.label_for(name), css] } + overlays

      at = M[:l].to_f
      entries.map do |text, css|
        mark = if css.end_with?('-line')
                 %(<line class="#{css}" x1="#{f at}" y1="13" x2="#{f(at + 12)}" y2="13" />)
               else
                 %(<rect class="#{css}" x="#{f at}" y="8" width="12" height="10" />)
               end
        body = mark + label(at + 17, 17, text, 'series-label')
        at += 17 + (text.length * 6.1) + 18
        body
      end.join
    end

    def value(year, name) = year.public_send(name).to_f

    def count = @years.size

    def x(index) = count > 1 ? M[:l] + (index.to_f / (count - 1)) * INNER_W : M[:l] + INNER_W / 2.0
    def y(value, scale) = M[:t] + INNER_H - (scale.zero? ? 0 : (value / scale) * INNER_H)

    def svg(kind, body)
      %(<svg class="chart-canvas chart-canvas--#{kind}" viewBox="0 0 #{W} #{H}" ) +
        %(preserveAspectRatio="xMidYMid meet" role="img">#{body}</svg>)
    end

    # Cumulative lower and upper curves, one polygon per band.
    def stacked(bands, scale)
      floors = Array.new(count, 0.0)
      bands.map do |name, css|
        tops = @years.each_with_index.map { |yr, i| floors[i] + value(yr, name) }
        polygon = area(floors, tops, scale)
        floors = tops
        %(<path class="#{css}" d="#{polygon}" />)
      end.join
    end

    def area(lower, upper, scale)
      up = upper.each_with_index.map { |v, i| "#{i.zero? ? 'M' : 'L'}#{f x(i)},#{f y(v, scale)}" }
      down = lower.each_with_index.to_a.reverse.map { |v, i| "L#{f x(i)},#{f y(v, scale)}" }
      "#{up.join(' ')} #{down.join(' ')} Z"
    end

    def line(values, scale, css)
      d = values.each_with_index.map { |v, i| "#{i.zero? ? 'M' : 'L'}#{f x(i)},#{f y(v, scale)}" }
      %(<path class="#{css}" d="#{d.join(' ')}" />)
    end

    def deduction_band(scale)
      return '' unless @standard_deduction.positive?

      top = y(@standard_deduction, scale)
      %(<rect class="band-deduction" x="#{M[:l]}" y="#{f top}" ) +
        %(width="#{INNER_W}" height="#{f(y(0, scale) - top)}" />) +
        label(M[:l] + 4, top + 11, 'Standard deduction', 'band-label')
    end

    # The brackets are thresholds on taxable income; the chart's axis is gross,
    # so each one sits a standard deduction higher than its own number.
    def bracket_bands(scale)
      @brackets.each_cons(2).map do |(low, rate), (high, _)|
        top = y(@standard_deduction + high, scale)
        bottom = y(@standard_deduction + low, scale)
        # A band wholly above the plot is drawn nowhere a reader can see it.
        # The viewBox clips the rect either way; the label is what leaks.
        next '' if bottom < M[:t] || bottom - top < 8

        %(<rect class="band-bracket" x="#{M[:l]}" y="#{f top}" ) +
          %(width="#{INNER_W}" height="#{f(bottom - top)}" />) +
          label(M[:l] + 4, top + 10, "#{(rate * 100).round}%", 'band-label')
      end.join
    end

    def frame(scale)
      axes = %(<line class="axis" x1="#{M[:l]}" y1="#{M[:t]}" x2="#{M[:l]}" y2="#{M[:t] + INNER_H}" />) +
             %(<line class="axis" x1="#{M[:l]}" y1="#{M[:t] + INNER_H}" ) +
             %(x2="#{M[:l] + INNER_W}" y2="#{M[:t] + INNER_H}" />)
      axes + y_ticks(scale) + x_ticks
    end

    def y_ticks(scale)
      (0..5).map do |i|
        v = scale * i / 5.0
        at = y(v, scale)
        %(<line class="axis" x1="#{M[:l] - 5}" y1="#{f at}" x2="#{M[:l]}" y2="#{f at}" />) +
          label(8, at + 4, "$#{(v / 1000).round}k", 'series-label')
      end.join
    end

    def x_ticks
      @years.each_with_index.filter_map do |yr, i|
        next unless i.zero? || i == count - 1 || (i % 5).zero?

        label(x(i) - 8, M[:t] + INNER_H + 16, yr.year.to_s, 'series-label')
      end.join
    end

    # One transparent column per year, carrying its own numbers. The script
    # only has to read attributes and place a box — it never recomputes a
    # scale, and it never touches the geometry.
    def hover(_scale, bands)
      width = count > 1 ? INNER_W.to_f / (count - 1) : INNER_W
      @years.each_with_index.map do |yr, i|
        parts = bands.map { |name, _| "#{yr.label_for(name)}: #{money(value(yr, name))}" }
        %(<rect class="chart-hit" x="#{f(x(i) - width / 2)}" y="#{M[:t]}" ) +
          %(width="#{f width}" height="#{INNER_H}" ) +
          %(data-year="#{CGI.escapeHTML(yr.year.to_s)}" ) +
          %(data-detail="#{CGI.escapeHTML(parts.join(' | '))}" />)
      end.join
    end

    def label(at_x, at_y, text, css)
      %(<text class="#{css}" x="#{f at_x}" y="#{f at_y}">#{CGI.escapeHTML(text.to_s)}</text>)
    end

    def money(v) = "$#{v.round.to_s.reverse.scan(/\d{1,3}/).join(',').reverse}"

    def f(n) = format('%.1f', n)

    # A round number a little above the data, so the axis reads in whole steps.
    def nice(max)
      return 1.0 if max.nil? || max <= 0

      step = 10**Math.log10(max / 5.0).floor
      [1, 2, 2.5, 5, 10].each do |m|
        return (max / (step * m)).ceil * step * m if max / (step * m) <= 5
      end
      max
    end
  end
end
