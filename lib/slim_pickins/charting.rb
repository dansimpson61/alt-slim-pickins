# frozen_string_literal: true

module SlimPickins
  # Minimal inline SVG for `chart`. This is the entry VOCABULARY.md marks as a
  # guess: it has more irreducible configuration than any other word, and
  # ROADMAP Phase 8 exists to redraft it against a real charting need or cut
  # it. What is here is enough to render, and deliberately no more.
  module Charting
    module_function

    W = 320
    H = 120

    def render(kind, series, over: nil, label: nil)
      values = Array(series).map(&:to_f)
      return '' if values.empty?

      body = case kind
             when :line, :area then line(values, kind)
             when :bar         then bars(values)
             when :pie         then pie(values)
             else                   line(values, :line)
             end
      title = label ? "<title>#{CGI.escapeHTML(label.to_s)}</title>" : ''
      axis = over ? %( data-over="#{CGI.escapeHTML(Array(over).join(','))}") : ''
      %(<svg class="chart chart--#{kind}" viewBox="0 0 #{W} #{H}" role="img"#{axis}>#{title}#{body}</svg>)
    end

    def scale(values)
      low = [values.min, 0].min
      high = values.max
      span = (high - low).zero? ? 1.0 : (high - low)
      [low, span]
    end

    def line(values, kind)
      low, span = scale(values)
      step = values.size > 1 ? W.to_f / (values.size - 1) : W.to_f
      points = values.each_with_index.map do |v, i|
        format('%.1f,%.1f', i * step, H - ((v - low) / span * (H - 10)) - 5)
      end
      if kind == :area
        %(<polygon points="0,#{H} #{points.join(' ')} #{W},#{H}" />)
      else
        %(<polyline fill="none" points="#{points.join(' ')}" />)
      end
    end

    def bars(values)
      low, span = scale(values)
      width = W.to_f / values.size
      values.each_with_index.map do |v, i|
        height = (v - low) / span * (H - 10)
        format('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" />',
               i * width + 1, H - height, width - 2, height)
      end.join
    end

    def pie(values)
      total = values.sum
      return '' if total.zero?

      radius = H / 2.0 - 4
      cx = W / 2.0
      cy = H / 2.0
      angle = -Math::PI / 2
      values.each_with_index.map do |v, i|
        sweep = v / total * 2 * Math::PI
        x1 = cx + radius * Math.cos(angle)
        y1 = cy + radius * Math.sin(angle)
        angle += sweep
        x2 = cx + radius * Math.cos(angle)
        y2 = cy + radius * Math.sin(angle)
        large = sweep > Math::PI ? 1 : 0
        format('<path class="slice slice--%d" d="M%.1f,%.1f L%.1f,%.1f A%.1f,%.1f 0 %d,1 %.1f,%.1f Z" />',
               i, cx, cy, x1, y1, radius, radius, large, x2, y2)
      end.join
    end
  end
end
