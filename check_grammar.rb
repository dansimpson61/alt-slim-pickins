require 'set'
# Checks every sentence in DESIGN.md's fenced blocks against the grammar table.
# Rank: name(0) < content(1) < modifier(2). Ranks must never decrease.
# Morphology under test: a dot means data, a bare word is language.
WORD = /\A[a-z][a-z_]*\z/
KINDS = {
  0 => /\A[a-z][a-z_]*\z/,                        # bare name
  1 => /\A(".*"|\.[a-z_]+\??|[a-z_]+(\.[a-z_]+)+\??)\z/, # data — always dotted
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
docs = ARGV.empty? ? %w[DESIGN.md VOCABULARY.md PORTFOLIO.md CONTENT.md FIGURES.md].map { |f| File.join(here, f) } : ARGV
problems = 0; checked = 0

# Every word used in a sentence must be defined in VOCABULARY.md, so the two
# documents cannot drift apart silently.
vocab = File.read(File.join(here, "VOCABULARY.md")).scan(/^### `([a-z_]+)`/).flatten.to_set
used = Hash.new { |h, k| h[k] = [] }

docs.each do |doc|
  File.read(doc).scan(/^```\n(.*?)^```/m).flatten.each do |block|
    next if block.include?("names, content")   # the schema itself, not a sentence
    block.lines.each do |raw|
      line = raw.chomp.sub(/\s+#.*\z/, "").rstrip
      next if line.strip.empty?
      body = line.strip
      where = File.basename(doc)
      word, _, rest = body.partition(" ")
      unless word =~ WORD
        puts "  BAD WORD  #{where}: #{body.inspect}"; problems += 1; next
      end
      checked += 1
      used[word] << where
      ranks = split_args(rest).map { |a| [a, kind_of(a)] }
      ranks.each { |a, r| (puts "  UNKNOWN ARG  #{where}: #{a.inspect} in #{body.inspect}"; problems += 1) if r.nil? }
      seq = ranks.map(&:last).compact
      unless seq == seq.sort
        puts "  ORDER  #{where}: #{body.inspect} ranks=#{seq.inspect}"; problems += 1
      end
    end
  end
end
(used.keys.to_set - vocab).sort.each do |w|
  puts "  UNDEFINED WORD  #{w.inspect} used in #{used[w].uniq.join(', ')} but not in VOCABULARY.md"
  problems += 1
end
(vocab - used.keys.to_set).sort.each do |w|
  puts "  UNEXEMPLIFIED  #{w.inspect} defined but has no sentence"
  problems += 1
end
puts "\n#{checked} sentences checked, #{vocab.size} words defined, #{problems} problems"
