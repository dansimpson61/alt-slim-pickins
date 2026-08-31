# frozen_string_literal: true

require 'cgi'

module SlimPickins
  # Inline SVG for `chart`, redrafted in Phase 8 against roth's two real charts.
  #
  # The first draft was a guess: it took a flat array of numbers, drew one
  # polyline, and its VOCABULARY entry claimed to infer "axes, scale and
  # legend from the data" while emitting none of the three. `over:` became a
  # `data-over` attribute nothing read. No page ever needed a readable chart,
  # so nothing said otherwise.
  #
  # What the redraft is: **the same shape as `table`.** A table declares its
  # columns and the rows come from the subject; a chart declares its series and
  # the points come from the subject. No new idea, and no new syntax.
  #
  # This module is geometry only. Which attribute, what it is called and how a
  # value should read are the Builder's business, because those are the three
  # things the app contract already answers.
  module Charting
    module_function

    W = 800
    H = 320
    M = { l: 64, r: 16, t: 34, b: 40 }.freeze
    INNER_W = W - M[:l] - M[:r]
    INNER_H = H - M[:t] - M[:b]

    # series — [{ kind: :band | :line, label:, points: [Float], shown: [String] }]
    # levels — [{ label:, value: Float }]
    # across — the x-axis labels, one per point
    def render(series:, levels: [], across: [], caption: nil)
      bands = series.select { |s| s[:kind] == :band }
      lines = series.select { |s| s[:kind] == :line }
      count = across.size
      return '' if count.zero? || series.empty?

      scale = nice(ceiling(bands, lines, levels))
      body = zones(levels, scale) +
             stacked(bands, scale, count) +
             overlays(lines, scale, count) +
             frame(scale, across) +
             key(series) +
             hover(series, across)

      title = caption ? "<title>#{CGI.escapeHTML(caption.to_s)}</title>" : ''
      %(<svg class="chart" viewBox="0 0 #{W} #{H}" preserveAspectRatio="xMidYMid meet" ) +
        %(role="img">#{title}#{body}</svg>)
    end

    # --- scale ------------------------------------------------------------

    # The data sets the scale; a reference does not. Letting levels in meant
    # roth's top tax bracket, at $760k against $200k of income, stretched the
    # axis fourfold and pressed every band flat along the bottom. A threshold
    # far above the data is not informative, so it is clipped instead.
    def ceiling(bands, lines, _levels)
      stacked_tops = if bands.empty?
                       []
                     else
                       bands.first[:points].each_index.map { |i| bands.sum { |b| b[:points][i].to_f } }
                     end
      (stacked_tops + lines.flat_map { |l| l[:points] }).map(&:to_f).max || 0
    end

    # A round number a little above the data, so the axis reads in whole steps.
    def nice(max)
      return 1.0 if max.nil? || max <= 0

      step = 10**Math.log10(max / 5.0).floor
      [1, 2, 2.5, 5, 10].each do |m|
        return (max / (step * m)).ceil * step * m if max / (step * m) <= 5
      end
      max.to_f
    end

    def x(index, count)
      count > 1 ? M[:l] + (index.to_f / (count - 1)) * INNER_W : M[:l] + INNER_W / 2.0
    end

    def y(value, scale) = M[:t] + INNER_H - (scale.zero? ? 0 : (value / scale) * INNER_H)

    # --- marks ------------------------------------------------------------

    # Cumulative lower and upper curves, one polygon per band.
    def stacked(bands, scale, count)
      floors = Array.new(count, 0.0)
      bands.each_with_index.map do |band, i|
        tops = band[:points].each_with_index.map { |v, j| floors[j] + v.to_f }
        path = area(floors, tops, scale, count)
        floors = tops
        %(<path class="chart-band chart-band--#{i}" d="#{path}" />)
      end.join
    end

    def area(lower, upper, scale, count)
      up = upper.each_with_index.map { |v, i| "#{i.zero? ? 'M' : 'L'}#{f x(i, count)},#{f y(v, scale)}" }
      down = lower.each_with_index.to_a.reverse.map { |v, i| "L#{f x(i, count)},#{f y(v, scale)}" }
      "#{up.join(' ')} #{down.join(' ')} Z"
    end

    def overlays(lines, scale, count)
      lines.each_with_index.map do |line, i|
        d = line[:points].each_with_index.map do |v, j|
          "#{j.zero? ? 'M' : 'L'}#{f x(j, count)},#{f y(v.to_f, scale)}"
        end
        %(<path class="chart-line chart-line--#{i}" d="#{d.join(' ')}" />)
      end.join
    end

    # A horizontal reference, labelled in place rather than in the key —
    # a threshold is read against the data, not looked up.
    # The rule always draws; the label only where it will not sit on another.
    # roth's tax brackets bunch up at the bottom of a high-income chart —
    # "12%" landed four pixels from "Standard deduction" — and two labels on
    # top of each other say less than one.
    def zones(levels, scale)
      # Declaration order decides which label survives a crowd, so the page
      # keeps the say: roth writes its standard deduction before its brackets
      # because that is the line a reader is looking for.
      placed = []
      levels.map { |l| [y(l[:value].to_f, scale), l[:label]] }
            .select { |at, _| at >= M[:t] && at <= M[:t] + INNER_H }
            .map do |at, label|
              legible = label && placed.none? { |other| (other - at).abs < 12 }
              placed << at if legible
              %(<line class="chart-level" x1="#{M[:l]}" y1="#{f at}" ) +
                %(x2="#{M[:l] + INNER_W}" y2="#{f at}" />) +
                (legible ? text(M[:l] + 4, at - 3, label, 'chart-note') : '')
            end.join
    end

    # --- furniture --------------------------------------------------------

    def frame(scale, across)
      %(<line class="chart-axis" x1="#{M[:l]}" y1="#{M[:t]}" x2="#{M[:l]}" y2="#{M[:t] + INNER_H}" />) +
        %(<line class="chart-axis" x1="#{M[:l]}" y1="#{M[:t] + INNER_H}" ) +
        %(x2="#{M[:l] + INNER_W}" y2="#{M[:t] + INNER_H}" />) +
        ticks(scale) + across_labels(across)
    end

    def ticks(scale)
      (0..5).map do |i|
        v = scale * i / 5.0
        at = y(v, scale)
        %(<line class="chart-axis" x1="#{M[:l] - 5}" y1="#{f at}" x2="#{M[:l]}" y2="#{f at}" />) +
          text(8, at + 4, short(v), 'chart-tick')
      end.join
    end

    # Every label where they fit, otherwise the ends and every fifth.
    def across_labels(across)
      every = across.size <= 12 ? 1 : 5
      across.each_with_index.filter_map do |label, i|
        next unless i.zero? || i == across.size - 1 || (i % every).zero?

        text(x(i, across.size) - 8, M[:t] + INNER_H + 16, label, 'chart-tick')
      end.join
    end

    # Drawn inside the picture it describes, so it survives however the page
    # is assembled and never disagrees with what was actually drawn.
    def key(series)
      at = M[:l].to_f
      series.each_with_index.map do |s, i|
        kind = s[:kind] == :band ? "chart-band chart-band--#{count_of(series, s, :band)}" : "chart-line chart-line--#{count_of(series, s, :line)}"
        mark = if s[:kind] == :band
                 %(<rect class="#{kind}" x="#{f at}" y="8" width="12" height="10" />)
               else
                 %(<line class="#{kind}" x1="#{f at}" y1="13" x2="#{f(at + 12)}" y2="13" />)
               end
        body = mark + text(at + 17, 17, s[:label], 'chart-tick')
        at += 17 + (s[:label].to_s.length * 6.1) + 18
        body
      end.join
    end

    def count_of(series, this, kind) = series.select { |s| s[:kind] == kind }.index(this)

    # One transparent column per point, carrying its own numbers.
    #
    # The `<title>` is the whole tooltip: browsers show it on hover, for free,
    # with no script and no empty div waiting to be filled. roth spent forty
    # lines of JavaScript and a mount point on this. The `data-` attributes
    # stay for anyone who wants a richer one, and a script that reads them
    # never has to recompute a scale.
    def hover(series, across)
      width = across.size > 1 ? INNER_W.to_f / (across.size - 1) : INNER_W
      across.each_with_index.map do |label, i|
        detail = series.map { |s| "#{s[:label]}: #{s[:shown][i]}" }.join(' | ')
        # Held inside the plot. Centred columns spill past both ends, and with
        # few points they spill a long way — the first one started at -116.
        left = [x(i, across.size) - width / 2, M[:l]].max
        right = [x(i, across.size) + width / 2, M[:l] + INNER_W].min
        %(<rect class="chart-hit" x="#{f left}" y="#{M[:t]}" ) +
          %(width="#{f(right - left)}" height="#{INNER_H}" ) +
          %(data-at="#{CGI.escapeHTML(label.to_s)}" ) +
          %(data-detail="#{CGI.escapeHTML(detail)}">) +
          %(<title>#{CGI.escapeHTML("#{label} — #{detail}")}</title></rect>)
      end.join
    end

    # --- bits -------------------------------------------------------------

    def text(at_x, at_y, body, css)
      %(<text class="#{css}" x="#{f at_x}" y="#{f at_y}">#{CGI.escapeHTML(body.to_s)}</text>)
    end

    # An axis reads in thousands and millions or it does not read at all.
    def short(v)
      return '0' if v.zero?
      return format('%gm', (v / 1_000_000.0).round(2)) if v.abs >= 1_000_000
      return format('%gk', (v / 1000.0).round(1)) if v.abs >= 1000

      format('%g', v.round(2))
    end

    def f(n) = format('%.1f', n)
  end
end
