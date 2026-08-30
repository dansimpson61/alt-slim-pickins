# Checks every sentence in DESIGN.md's fenced blocks against the grammar table.
# Rank: name(0) < content(1) < modifier(2). Ranks must never decrease.
# Morphology under test: a dot means data, a bare word is language.
WORD = /\A[a-z][a-z_]*\z/
KINDS = {
  0 => /\A[a-z][a-z_]*\z/,                        # bare name
  1 => /\A(".*"|\.[a-z_]+\??|[a-z_]+(\.[a-z_]+)+\??|[a-z_]+\?)\z/, # data
  2 => /\A[a-z_]+:\s*.+\z/                        # modifier:
}

def split_args(s)
  parts, buf, depth, q = [], +"", 0, false
  s.each_char do |c|
    if c == '"' then q = !q; buf << c
    elsif q then buf << c
    elsif c == ',' && depth.zero? then parts << buf.strip; buf = +""
    else depth += 1 if c == '('; depth -= 1 if c == ')'; buf << c end
  end
  parts << buf.strip unless buf.strip.empty?
  parts
end

def kind_of(arg)
  KINDS.each { |rank, re| return rank if arg =~ re }
  nil
end

# Untagged fences hold sentences and are checked. Tag a fence (```html) to
# exclude it — that is how a document shows output rather than grammar.
here = File.expand_path(__dir__)
docs = ARGV.empty? ? %w[DESIGN.md VOCABULARY.md].map { |f| File.join(here, f) } : ARGV
problems = 0; checked = 0

docs.each do |doc|
  File.read(doc).scan(/^```\n(.*?)^```/m).flatten.each do |block|
    block.lines.each do |raw|
      line = raw.chomp.sub(/\s+#.*\z/, "").rstrip
      next if line.strip.empty? || line.include?("names, content")
      body = line.strip
      where = File.basename(doc)
      word, _, rest = body.partition(" ")
      unless word =~ WORD
        puts "  BAD WORD  #{where}: #{body.inspect}"; problems += 1; next
      end
      checked += 1
      ranks = split_args(rest).map { |a| [a, kind_of(a)] }
      ranks.each { |a, r| (puts "  UNKNOWN ARG  #{where}: #{a.inspect} in #{body.inspect}"; problems += 1) if r.nil? }
      seq = ranks.map(&:last).compact
      unless seq == seq.sort
        puts "  ORDER  #{where}: #{body.inspect} ranks=#{seq.inspect}"; problems += 1
      end
    end
  end
end
puts "\n#{checked} sentences checked, #{problems} problems"
