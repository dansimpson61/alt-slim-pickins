code = File.read("lib/slim_pickins/generator.rb")

code.sub!(/    def initialize\n      @out = \+''\n    end/) do
  <<~'RUBY'
    def initialize
      @out = +''
      @indent = 0
    end
  RUBY
end

# Find the # --- bits --- section
bits_idx = code.index("# --- bits -------------------------------------------------------------")

new_bits = <<~'RUBY'
    # --- bits -------------------------------------------------------------

    BLOCK_TAGS = %w[html head body div section article aside nav header footer ul ol li dl dt dd table thead tbody tfoot tr form fieldset blockquote pre].freeze
    INLINE_TAGS = %w[a span button label time strong em code b i u s q p h1 h2 h3 h4 h5 h6 title textarea option iframe].freeze

    def indent_str
      "  " * @indent
    end

    def newline
      @out << "\n#{indent_str}" unless @out.empty? || @out.end_with?("\n#{indent_str}")
    end

    def open_tag(tag, **pairs)
      newline if BLOCK_TAGS.include?(tag.to_s)
      @out << "<#{tag}#{attrs_html(pairs)}>"
      @indent += 1 if BLOCK_TAGS.include?(tag.to_s)
    end

    def void_tag(tag, **pairs)
      newline if BLOCK_TAGS.include?(tag.to_s)
      @out << "<#{tag}#{attrs_html(pairs)}>"
    end

    def close_tag(tag)
      @indent -= 1 if BLOCK_TAGS.include?(tag.to_s)
      newline if BLOCK_TAGS.include?(tag.to_s)
      @out << "</#{tag}>"
    end

    def full_tag(tag, text, **pairs)
      newline if BLOCK_TAGS.include?(tag.to_s)
      @out << "<#{tag}#{attrs_html(pairs)}>#{esc(text)}</#{tag}>"
    end
  end
end
RUBY

code = code[0...bits_idx] + new_bits

# Now replace explicit string closes for BLOCK_TAGS
code.gsub!(/@out << '<\/html>'/, "close_tag('html')")
code.gsub!(/@out << '<\/head>'/, "close_tag('head')")
code.gsub!(/@out << '<\/body>'/, "close_tag('body')")
code.gsub!(/@out << '<\/nav>'/, "close_tag('nav')")
code.gsub!(/@out << '<\/div>'/, "close_tag('div')")
code.gsub!(/@out << '<\/tr>'/, "close_tag('tr')")
code.gsub!(/@out << '<\/thead>'/, "close_tag('thead')")
code.gsub!(/@out << '<\/tbody>'/, "close_tag('tbody')")
code.gsub!(/@out << '<\/tfoot>'/, "close_tag('tfoot')")
code.gsub!(/@out << '<\/table>'/, "close_tag('table')")
code.gsub!(/@out << '<\/dl>'/, "close_tag('dl')")
code.gsub!(/@out << '<\/pre>'/, "close_tag('pre')")
code.gsub!(/@out << '<\/form>'/, "close_tag('form')")
code.gsub!(/@out << '<\/fieldset>'/, "close_tag('fieldset')")

# also fix region which does @out << "</\#{tag_name}>"
code.sub!(/@out << "<\/\#\{tag_name\}>"/, "close_tag(tag_name)")

# fix emit
code.sub!(/        @out << "<\/\#\{attrs\[:name\]\}>" unless VOID.include\?\(attrs\[:name\]\.to_s\)/, "        close_tag(attrs[:name].to_s) unless VOID.include?(attrs[:name].to_s)")

File.write("lib/slim_pickins/generator.rb", code)
