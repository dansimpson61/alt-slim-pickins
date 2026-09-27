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
    FENCE = %r{\A\s*```[^\n`]*\z}

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
      stripped = source.to_s.sub(/\A---\s*\n.*?\n---\s*(\n|\z)/m, '')
      blocks(CGI.escapeHTML(stripped)).join
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
      fence_indent = lines[i][/\A\s*/]
      body = []
      i += 1
      while i < lines.size && !FENCE.match?(lines[i].chomp)
        line = lines[i]
        line = line.sub(/\A\s{1,#{fence_indent.length}}/, '') if fence_indent && !fence_indent.empty?
        body << line
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
        collected = [lines[i].sub(marker, '')]
        i += 1
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
            collected << line.strip
            i += 1
          end
        end
        # An item's text is read as one piece and given to `spans` once. It
        # used to be two calls — the marker line, then its continuations —
        # which broke any code span that wrapped: the opening backtick landed
        # in one call and the closing backtick in the other, so the span never
        # closed and the backticks rendered as literal text with a stray
        # `<code>` between them. Six passages rendered that way; a paragraph,
        # which always joined before spanning, did not.
        body = spans(collected.join(' '))
        body << "<ul>#{items(nested_lines, UNORDERED)}</ul>" unless nested_lines.empty?
        out << "<li>#{body}</li>"
      end
      out.join
    end

    def blockquote(block)
      content = block.gsub(/^&gt; ?/, '')
      paras = content.split(/\n\s*\n/)
      if paras.size > 1
        "<blockquote>#{paras.map { |p| "<p>#{spans(p)}</p>" }.join}</blockquote>"
      elsif content.include?("\n") && content.lines.all? { |l| l.strip.match?(/\A\*\*[^*]+(\*\*:|:\*\*)/) }
        "<blockquote>#{content.lines.map { |l| spans(l.strip) }.join('<br>')}</blockquote>"
      else
        "<blockquote>#{spans(content)}</blockquote>"
      end
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

    # The one character a document cannot contain, used to hold a code span's
    # place while the text around it is read for links and emphasis. It has to
    # be a mask rather than a walk, because the forms nest: a link's text is
    # often a code span (`[`word`](word)`), and emphasis often wraps one
    # (`**word (`word`)**`). A mask lets each form be read against text the
    # others have already been taken out of, so nothing is parsed twice.
    PLACEHOLDER = "\u0000"

    CODE = /`+[^`]+?`+/

    def spans(text)
      code = []
      masked = matched_backticks(text).reverse.reduce(text.dup) do |rest, (open_at, content_at, close_at, close_end)|
        code.unshift(text[content_at...close_at])
        rest[open_at...close_end] = PLACEHOLDER
        rest
      end

      out = markup(masked)
      code.each { |content| out.sub!(PLACEHOLDER) { "<code>#{content}</code>" } }
      out.gsub("\n", ' ')
    end

    # The markup that may appear *around* a code span: links, images,
    # emphasis. Code is already masked out, so `**this**` inside a span is
    # never read as bold — rendered as bold it would be a lie about what the
    # page says.
    #
    # Precedence matters between the forms: `[![alt](pic)](dest)` is a linked
    # image, and a pattern that tried the link first would read `![alt` as its
    # text and swallow the image.
    IMAGE = /!\[(?<alt>[^\]]*)\]\((?<src>[^)\s]+)\)/m
    # A link's text may hold one nested image pair — `[![alt](pic)](dest)` is
    # how a linked image is written — and the mask may stand in for a code
    # span, which is how `[`word`](word)` reads.
    LINK = /\[(?<text>(?:!?\[[^\[\]]*\])?[^\[\]]*)\]\((?<href>[^)\s]+)\)/m

    def markup(text)
      # Image before link: `[![alt](pic)](dest)` is a linked image, and a link
      # pattern that saw it first would read `![alt` as its own text.
      with_images = text.gsub(IMAGE) do
        m = Regexp.last_match
        %(<img src="#{CGI.escapeHTML(m[:src])}" alt="#{CGI.escapeHTML(m[:alt])}">)
      end
      with_images.gsub(LINK) do
        m = Regexp.last_match
        %(<a href="#{CGI.escapeHTML(m[:href])}">#{markup(m[:text])}</a>)
      end.gsub(/\*\*([^*]+)\*\*/) { "<strong>#{Regexp.last_match(1)}</strong>" }
                  .gsub(/(?<!\*)\*([^*]+)\*(?!\*)/) { "<em>#{Regexp.last_match(1)}</em>" }
                  .gsub(/  +\n/, '<br>')
    end

    # Every matched code span in the text, as [open_at, content_at, close_at,
    # close_end]. This is CommonMark's rule and it has to be a scan rather
    # than a pattern: a span opens on a run of backticks and closes on the
    # next run of *the same length*, so a shorter run inside it is content.
    #
    # The pattern it replaced, /`([^`]+)`/, could express only the
    # length-one case, which made a whole class of sentence unwritable — any
    # sentence that had to quote three backticks, starting with this repo's
    # own fence pattern. It also paired the first backtick with the last,
    # which silently welded `.`/`#` into one span whose content was `./`.
    #
    # A run with no partner of its length is left as written, so a fence line
    # — a lone run of three — survives untouched.
    def matched_backticks(text)
      runs = []
      text.to_enum(:scan, /`+/).each do
        runs << [Regexp.last_match.begin(0), Regexp.last_match[0].length]
      end

      pairs = []
      index = 0
      while index < runs.size
        at, length = runs[index]
        closing = index + 1
        closing += 1 while closing < runs.size && runs[closing][1] != length
        if closing < runs.size
          close_at = runs[closing][0]
          pairs << [at, at + length, close_at, close_at + length]
          index = closing + 1
        else
          index += 1
        end
      end
      pairs
    end

    # `prose plain, .notes` — no markup at all, just paragraphs.
    def plain(source)
      stripped = source.to_s.sub(/\A---\s*\n.*?\n---\s*(\n|\z)/m, '')
      CGI.escapeHTML(stripped).split(/\n{2,}/).filter_map do |b|
        b = b.strip
        "<p>#{b.gsub("\n", ' ')}</p>" unless b.empty?
      end.join
    end
  end
end
