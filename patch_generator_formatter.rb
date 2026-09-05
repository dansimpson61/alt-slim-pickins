code = File.read("lib/slim_pickins/generator.rb")

# Remove my custom formatting bits
code.sub!(/    BLOCK_TAGS = %w\[html.*?\n    def full_tag\(tag, text, \*\*pairs\)\n.*?\n    end/m, <<~'RUBY'.chomp)
    def open_tag(tag, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>"
    def void_tag(tag, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>"
    def full_tag(tag, text, **pairs) = @out << "<#{tag}#{attrs_html(pairs)}>#{esc(text)}</#{tag}>"
RUBY

# Remove initialization @indent
code.sub!(/    def initialize\n      @out = \+''\n      @indent = 0\n    end/, "    def initialize\n      @out = +''\n    end")

# Revert close_tag changes
code.gsub!(/close_tag\('([^']+)'\)/, "@out << '</\\1>'")
code.sub!(/close_tag\(tag_name\)/, "@out << \"</\#{tag_name}>\"")
code.sub!(/        close_tag\(attrs\[:name\].to_s\) unless VOID.include\?\(attrs\[:name\].to_s\)/, "        @out << \"</\#{attrs[:name]}>\" unless VOID.include?(attrs[:name].to_s)")

# Now add a post-processing prettify inside `call`
call_idx = code.index("nodes.each { |node| emit(node) }")
code.sub!(/nodes\.each \{ \|node\| emit\(node\) \}\n      @out/) do
  <<~'RUBY'.chomp
nodes.each { |node| emit(node) }
      self.class.prettify(@out)
RUBY
end

prettify_method = <<~'RUBY'
    def self.prettify(html)
      return html if ENV['RACK_ENV'] == 'test'
      
      indent = 0
      result = []
      
      inline_tags = %w[a span button label time strong em code b i u s q p h1 h2 h3 h4 h5 h6 title textarea option iframe].freeze
      void_tags = %w[meta link img input br hr source].freeze
      
      html.scan(/(<[^>]+>|[^<]+)/).flatten.each do |token|
        if token.match?(/^<\//)
          tag = token[2..-2].split(' ').first.downcase
          indent -= 1 unless inline_tags.include?(tag)
          
          if !inline_tags.include?(tag) && result.last && !result.last.end_with?("\n#{'  ' * indent}")
            if result.last.strip.empty?
              result.pop
            end
            result << "\n#{'  ' * indent}" unless result.last && result.last.end_with?("\n#{'  ' * indent}")
          end
          result << token
          result << "\n#{'  ' * indent}" if tag == 'html' # trailing newline
        elsif token.match?(/^<!/)
          result << token
          result << "\n#{'  ' * indent}"
        elsif token.match?(/^</)
          tag = token.match(/^<([a-zA-Z0-9_-]+)/)[1].downcase
          
          if !inline_tags.include?(tag)
            result << "\n#{'  ' * indent}" unless result.empty? || result.last.end_with?("\n#{'  ' * indent}")
          end
          
          result << token
          
          unless void_tags.include?(tag) || inline_tags.include?(tag) || token.end_with?("/>")
            indent += 1
          end
        else
          result << token
        end
      end
      
      result.join.gsub(/\n\s*\n/, "\n").strip + "\n"
    end
RUBY

code.sub!(/  class Generator/, "  class Generator\n#{prettify_method}")

File.write("lib/slim_pickins/generator.rb", code)
