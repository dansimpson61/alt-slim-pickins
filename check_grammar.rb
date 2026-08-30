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

src = File.read("/home/dan/dev/alt-slim-pickins/DESIGN.md")
problems = 0; checked = 0
src.scan(/^```\n(.*?)^```/m).flatten.each do |block|
  block.lines.each do |raw|
    line = raw.chomp.sub(/\s+#.*\z/, "").rstrip
    next if line.strip.empty? || line.include?("names, content")
    body = line.strip
    word, _, rest = body.partition(" ")
    unless word =~ WORD
      puts "  BAD WORD  #{body.inspect}"; problems += 1; next
    end
    checked += 1
    ranks = split_args(rest).map { |a| [a, kind_of(a)] }
    ranks.each { |a, r| (puts "  UNKNOWN ARG  #{a.inspect} in #{body.inspect}"; problems += 1) if r.nil? }
    seq = ranks.map(&:last).compact
    unless seq == seq.sort
      puts "  ORDER  #{body.inspect} ranks=#{seq.inspect}"; problems += 1
    end
  end
end
puts "\n#{checked} sentences checked, #{problems} problems"
