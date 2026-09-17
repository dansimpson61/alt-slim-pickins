# frozen_string_literal: true

require 'cgi'

module SlimPickins
  # A deliberately small markdown renderer, and no new dependency.
  #
  # It is safe by construction: everything is HTML-escaped *first*, and only
  # then are a fixed set of markdown patterns turned into tags. No input can
  # produce a tag that is not in that set, which is why `prose` has no
  # "trust me" spelling and the language needs no escaping sigil.
  #
  # It grows only what this repo's documents actually use — fences, tables,
  # ordered lists — and nothing else. No general markdown engine, no form
  # with no consumer: what the docs do not write, prose does not speak.
  module Markdown
    module_function

    # A fence line is ``` plus an optional language tag. The tag is read so
    # the fence's own lines never leak into the code, and then dropped: no
    # document distinguishes languages (measured 2026-09-09), and a class
    # with no consumer is kruft. The body is already escaped, so nothing
    # the tag says can matter to safety either.
    FENCE = %r{\A```[^\n`]*\z}

    HEADING = %r{\A\#{1,6}\s+}
    UNORDERED = %r{\A[-*]\s+}
    ORDERED = %r{\A\d+\.\s+}
    QUOTE = %r{\A&gt;\s?}

    # A list item line sits at column zero; a continuation is indented; a
    # nested item is an indented dash.
    ITEM_LINE = %r{\A(?:[-*]|\d+\.)\s}
    INDENTED = %r{\A\s+\S}
    NESTED_ITEM = %r{\A\s+[-*]\s+}

    def render(source)
      blocks(CGI.escapeHTML(source.to_s)).join
    end

    def blocks(escaped)
      lines = escaped.lines
      out = []
      i = 0
      while i < lines.size
        if FENCE.match?(lines[i].chomp)
          body, i = fence_body(lines, i)
          out << fenced(body)
        else
          block, i = gather_block(lines, i)
          out << block_of(block) unless block.empty?
        end
      end
      out
    end

    # The code between an opening fence and its close. An unterminated fence
    # runs to the end of the document — still escaped, still code, and the
    # only cost is one `<pre>` that never closes.
    def fence_body(lines, i)
      body = []
      i += 1
      while i < lines.size && !FENCE.match?(lines[i].chomp)
        body << lines[i]
        i += 1
      end
      [body.join.chomp, i + 1]
    end

    # A block is the run of non-blank lines between fences. The blank lines
    # that end it are consumed with it — a block boundary must advance, or
    # the walk never does. A fence never waits for a blank line.
    def gather_block(lines, i)
      block = []
      if lines[i].match?(HEADING) || lines[i].chomp.match?(/\A---\s*\z/)
        block << lines[i]
        i += 1
      else
        while i < lines.size && !lines[i].strip.empty? && !FENCE.match?(lines[i].chomp)
          break if lines[i].match?(HEADING) || lines[i].chomp.match?(/\A---\s*\z/)
          block << lines[i]
          i += 1
        end
      end
      i += 1 while i < lines.size && lines[i].strip.empty?
      [block.join.strip, i]
    end

    def fenced(body)
      "<pre><code>#{body}</code></pre>"
    end

    def block_of(block)
      lines = block.split("\n")
      return '<hr>' if block.match?(/\A---\s*\z/)
      return table(lines) if lines.size > 1 && separator_row?(lines[1])
      return heading(block) if block.match?(HEADING)
      return unordered_list(lines) if block.match?(UNORDERED)
      return ordered_list(block, lines) if block.match?(ORDERED)
      return blockquote(block) if block.match?(QUOTE)

      "<p>#{spans(lines.map(&:strip).join(' '))}</p>"
    end

    def heading(block)
      level = block[HEADING].count('#') + 1
      "<h#{level}>#{spans(block.sub(HEADING, ''))}</h#{level}>"
    end

    def unordered_list(lines)
      "<ul>#{items(lines, UNORDERED)}</ul>"
    end

    # Every list in the repo starts at 1 (measured 2026-09-09); `start` is
    # the form's own semantics, not a feature beyond it — a list that opens
    # at 4 says so, the way markdown does.
    def ordered_list(block, lines)
      start = block[/\A(\d+)\./, 1].to_i
      "<ol#{%( start="#{start}") unless start == 1}>#{items(lines, ORDERED)}</ol>"
    end

    # One walker for both lists, because the documents write them the same
    # way: a marker line opens an item, an indented line continues it (the
    # docs' bullets are long — 271 indented continuations, measured), and an
    # indented dash opens one level of nesting, of which the corpus has
    # exactly one — the roadmap's own record. Nothing is ever dropped: a
    # line the walker cannot place is folded into the item above it.
    def items(lines, marker)
      out = []
      i = 0
      while i < lines.size
        body = +spans(lines[i].sub(marker, ''))
        i += 1
        continuations = []
        nested_lines = []
        while i < lines.size && !lines[i].match?(ITEM_LINE)
          line = lines[i]
          if line.match?(NESTED_ITEM)
            indent = line[/\A\s+/]
            nested_lines << line.sub(/\A#{indent}/, '')
            i += 1
            while i < lines.size && lines[i].match?(/\A\s/)
              nested_lines << lines[i].sub(/\A\s{1,#{indent.length}}/, '')
              i += 1
            end
          else
            continuations << line.strip
            i += 1
          end
        end
        body << " #{spans(continuations.join(' '))}" unless continuations.empty?
        body << "<ul>#{items(nested_lines, UNORDERED)}</ul>" unless nested_lines.empty?
        out << "<li>#{body}</li>"
      end
      out.join
    end

    def blockquote(block)
      "<blockquote>#{spans(block.gsub(/^&gt;\s?/, ''))}</blockquote>"
    end

    # --- tables ---------------------------------------------------------------

    # A separator row is pipes and dash runs, nothing else. The dash run
    # carries the table's shape, and the alignment colons are rendered — `table`
    # below reads them into `align="…"`. (This comment said the opposite until
    # 2026-09-17, and the code beside it was right: a comment is a second home
    # for a truth, and this one had drifted.)
    def separator_row?(line)
      return false unless line.include?('|')

      cells(line).all? { |cell| cell.strip.match?(%r{\A:?-+:?\z}) }
    end

    def table(lines)
      header = cells(lines[0])
      width = header.size
      
      alignments = cells(lines[1]).map do |cell|
        c = cell.strip
        if c.start_with?(':') && c.end_with?(':')
          ' align="center"'
        elsif c.end_with?(':')
          ' align="right"'
        elsif c.start_with?(':')
          ' align="left"'
        else
          ''
        end
      end

      head = header.each_with_index.map { |c, col| "<th#{alignments[col] || ''}>#{spans(c.strip)}</th>" }.join
      body = lines.drop(2).map do |row|
        row_cells = cells(row)
        # A short row is padded to the header's width — the header owns the
        # table's shape. An over-long row keeps its extra cells; nothing is
        # dropped. Neither happens in the repo's documents.
        row_cells += [''] * (width - row_cells.size) if row_cells.size < width
        row_cells.each_with_index.map { |c, col| "<td#{alignments[col] || ''}>#{spans(c.strip)}</td>" }.join
      end
      "<table><thead><tr>#{head}</tr></thead><tbody>" \
        "#{body.map { |r| "<tr>#{r}</tr>" }.join}</tbody></table>"
    end

    # A row's cells: split on pipes that sit outside `code` spans — the
    # content is already escaped, so backticks are the only fences left. The
    # leading and trailing empty cells a row's outer pipes produce are
    # dropped; an empty cell in the middle is real and survives.
    def cells(row)
      cells = []
      cell = +''
      in_code = false
      row.each_char do |ch|
        if ch == '`'
          in_code = !in_code
        elsif ch == '|' && !in_code
          cells << cell
          cell = +''
          next
        end
        cell << ch
      end
      cells << cell
      cells.shift if cells.first&.empty?
      cells.pop if cells.last&.empty?
      cells
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
