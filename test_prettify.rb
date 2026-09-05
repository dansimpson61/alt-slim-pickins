def prettify(html)
  indent = 0
  result = []
  
  # split by tags, but keep text nodes
  tokens = html.scan(/(<[^>]+>|[^<]+)/).flatten
  
  inline_tags = %w[a span button label time strong em code b i u s q p h1 h2 h3 h4 h5 h6 title textarea option]
  void_tags = %w[meta link img input br hr source iframe]
  
  tokens.each do |token|
    if token.match?(/^<\//)
      # closing tag
      tag = token[2..-2].downcase
      indent -= 1 unless inline_tags.include?(tag)
      result << "\n#{'  ' * indent}" if result.last && result.last.end_with?("\n") == false && !inline_tags.include?(tag) && result.last.strip.empty? == false
      result << token
    elsif token.match?(/^<!/)
      # doctype or comment
      result << token
      result << "\n#{'  ' * indent}"
    elsif token.match?(/^</)
      # opening tag
      tag = token.match(/^<([a-zA-Z0-9_-]+)/)[1].downcase
      result << "\n#{'  ' * indent}" unless result.empty? || result.last.end_with?("\n") || inline_tags.include?(tag)
      result << token
      
      unless void_tags.include?(tag) || inline_tags.include?(tag) || token.end_with?("/>")
        indent += 1
      end
    else
      # text node
      text = token.strip
      if text.empty?
        # do nothing, skip empty text
      else
        result << text
      end
    end
  end
  
  result.join.gsub(/\n\s*\n/, "\n").strip
end

html = '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Slim-Pickins Studio</title><link rel="stylesheet" href="/assets/slim-pickins.css"></head><body><h1>Slim-Pickins Studio</h1><div class="region sidebar_layout"><aside class="aside vocabulary"><h2 class="aside-title">Vocabulary</h2><a href="/docs/iframe" class="link">iframe</a><a href="/docs/split_pane" class="link">split_pane</a><a href="/docs/sidebar" class="link">sidebar</a></aside><div class="region split_pane"><section class="section editor"><h2 class="section-title">Write .sp Code</h2><form class="form editor_form" action="/render" method="post" target="preview"><div class="field"><label for="source">Source</label><textarea id="source" name="source" rows="4" required="required">page &quot;Slim-Pickins Studio&quot;
  heading &quot;Hello World&quot;
</textarea></div><button type="submit" class="button">Render Visual</button><button type="submit" formaction="/render_html" formtarget="html_preview" class="button">Render HTML</button></form></section></div></div></body></html>'

puts prettify(html)
