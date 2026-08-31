# frozen_string_literal: true

require 'cgi'

module SlimPickins
  # A deliberately small markdown renderer, and no new dependency.
  #
  # It is safe by construction: everything is HTML-escaped *first*, and only
  # then are a fixed set of markdown patterns turned into tags. No input can
  # produce a tag that is not in that set, which is why `prose` has no
  # "trust me" spelling and the language needs no escaping sigil.
  module Markdown
    module_function

    def render(source)
      blocks(CGI.escapeHTML(source.to_s)).join
    end

    def blocks(escaped)
      escaped.split(/\n{2,}/).filter_map do |block|
        block = block.strip
        next if block.empty?

        case block
        when /\A(\#{1,6})\s+(.*)\z/m
          level = Regexp.last_match(1).size + 1
          "<h#{level}>#{spans(Regexp.last_match(2))}</h#{level}>"
        when /\A[-*]\s+/
          items = block.split("\n").map { |l| "<li>#{spans(l.sub(/\A[-*]\s+/, ''))}</li>" }
          "<ul>#{items.join}</ul>"
        when /\A&gt;\s?/
          "<blockquote>#{spans(block.gsub(/^&gt;\s?/, ''))}</blockquote>"
        else
          "<p>#{spans(block)}</p>"
        end
      end
    end

    def spans(text)
      text.gsub(/`([^`]+)`/, '<code>\1</code>')
          .gsub(/\*\*([^*]+)\*\*/, '<strong>\1</strong>')
          .gsub(/(?<!\*)\*([^*]+)\*(?!\*)/, '<em>\1</em>')
          .gsub(/\[([^\]]+)\]\(([^)\s]+)\)/) { %(<a href="#{CGI.escapeHTML($2)}">#{$1}</a>) }
          .gsub("\n", ' ')
    end

    # `prose plain, .notes` — no markup at all, just paragraphs.
    def plain(source)
      CGI.escapeHTML(source.to_s).split(/\n{2,}/).filter_map do |b|
        b = b.strip
        "<p>#{b.gsub("\n", ' ')}</p>" unless b.empty?
      end.join
    end
  end
end
