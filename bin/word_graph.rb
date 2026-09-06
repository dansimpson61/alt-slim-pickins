#!/usr/bin/env ruby
# frozen_string_literal: true

# The vocabulary, drawn. Every word is a node; an edge means "this word's
# definition says that word". The graph is derived from the code itself —
# the partials are parsed with the project's own Transform, the primitives
# are read out of words.rb — so the picture cannot drift from the truth.
#
#   ruby bin/word_graph.rb        # writes word_graph.html
#
# Two states: `now`, measured, and `proposed`, which is KERNEL.md's rounds
# applied. The proposed half is a drawing of a plan, not a measurement, and
# every node it invents is marked as such.
#
# There is no JavaScript. The layout is computed here, the edges are static
# SVG, and the interaction is `:hover` and `:checked` — Ruby > CSS > JS, in
# that order of reach.

require 'cgi'
require_relative '../lib/slim_pickins'

module WordGraph
  module_function

  VOCABULARY = File.expand_path('../lib/vocabulary', __dir__)
  WORDS_RB   = File.expand_path('../lib/slim_pickins/words.rb', __dir__)

  # --- what is true now --------------------------------------------------

  def partials
    @partials ||= Dir[File.join(VOCABULARY, '*.sp')].sort.to_h do |path|
      [File.basename(path, '.sp').to_sym, File.read(path)]
    end
  end

  # A partial's dependencies are the words its sentences name — read with the
  # language's own parser rather than a regex, so the edge list is exactly
  # what the runtime will evaluate.
  def dependencies_of(source)
    used = []
    walk = lambda { |nodes| nodes.each { |n| used << n.word.to_sym; walk.call(n.children) } }
    walk.call(SlimPickins::Transform.tree(source))
    used.uniq
  end

  # Each Ruby word's method, comments and all — what hovering a primitive
  # should show.
  def ruby_bodies
    @ruby_bodies ||= begin
      src = File.read(WORDS_RB)
      src.scan(/\n((?:^    #[^\n]*\n)*^    def ([a-z_]+).*?)(?=\n^    (?:#|def )|\n^  end)/m)
         .to_h { |body, name| [name.to_sym, body.gsub(/^    /, '').rstrip] }
    end
  end

  def source_for(word)
    partials[word] || ruby_bodies[word] || "(no definition found for `#{word}`)"
  end

  # --- the proposal ------------------------------------------------------
  #
  # KERNEL.md's rounds, as data. Marked `proposed` wherever it invents.

  # The element primitive. Now public, not privileged.
  PRIMITIVE = :tag

  # These leave the kernel outright — their consumers can just say `tag` instead.
  ABSORBED = %i[figcaption summary].freeze

  # The Riff: Empower with Love.
  # With `tag` public, nearly all structural and contextual words become partials
  # written over `tag` or other atoms.
  PROMOTED = {
    box:    %i[tag],
    paragraph: %i[tag],
    fact:      %i[tag],
    metric:    %i[tag],
    field:     %i[tag input],
    checkbox:  %i[tag input],
    textarea:  %i[tag],
    choice:    %i[tag],
    # The new additions to the riff:
    heading:   %i[tag],
    span:      %i[tag],
    group:     %i[tag],
    nav:       %i[tag],
    grid:      %i[tag],
    image:     %i[tag],
    link:      %i[tag],
    snippet:   %i[tag],
    form:      %i[tag],
    input:     %i[tag],
    hidden:    %i[tag],
    button:    %i[tag],
    option:    %i[tag]
  }.freeze

  # Nothing is merely a candidate anymore. We're going all the way.
  CANDIDATES = [].freeze

  # The true irreducible floor.
  FLOOR = {
    control:     %i[each choose when otherwise children contents],
    document:    %i[page stylesheet meta script icon],
    computation: %i[prose chart band line level],
    context:     [], # formerly heading, span, group (now promoted)
    primitive:   %i[tag]
  }.freeze

  # --- the model ---------------------------------------------------------

  Node = Struct.new(:word, :kind, :role, :deps, :indegree, :source, :note,
                    keyword_init: true)

  def build(mode)
    proposed = mode == :proposed
    nodes = {}

    SlimPickins::CONTRACTS.each_key do |word|
      next if proposed && ABSORBED.include?(word)

      is_partial = partials.key?(word) || (proposed && PROMOTED.key?(word))
      deps =
        if proposed && PROMOTED.key?(word) then PROMOTED[word]
        elsif partials.key?(word) then dependencies_of(partials[word])
        else []
        end
      deps = deps.reject { |d| proposed && ABSORBED.include?(d) }
      deps += [PRIMITIVE] if proposed && ABSORBED.any? { |a| original_deps(word).include?(a) }

      nodes[word] = Node.new(
        word: word, kind: is_partial ? :partial : :ruby,
        role: role_for(word, proposed), deps: deps.uniq, indegree: 0,
        source: source_for(word),
        note: proposed && PROMOTED.key?(word) ? 'proposed: promoted to a partial over `tag`' : nil
      )
    end

    if proposed
      nodes[PRIMITIVE] = Node.new(
        word: PRIMITIVE, kind: :ruby, role: :primitive, deps: [], indegree: 0,
        source: privileged_primitive_sketch,
        note: 'proposed: fully public primitive, empowering developers to drop down to elements when needed'
      )
    end

    nodes.each_value { |n| n.deps.each { |d| nodes[d]&.indegree += 1 } }
    nodes
  end

  def original_deps(word)
    partials.key?(word) ? dependencies_of(partials[word]) : []
  end

  def role_for(word, proposed)
    return :primitive if word == PRIMITIVE
    return :promoted  if partials.key?(word)
    return :moves     if proposed && PROMOTED.key?(word)
    return :moves     if !proposed && (PROMOTED.key?(word) || ABSORBED.include?(word))
    return :candidate if CANDIDATES.include?(word)

    FLOOR.each { |kind, list| return kind if list.include?(word) }
    :unreached
  end

  def privileged_primitive_sketch
    <<~RUBY
      # PROPOSED — "Empower with Love".
      #
      # The one element primitive. Fully public, so developers are
      # empowered to write `tag div, class: "flex"` when they need it,
      # rather than being blocked by the framework's distrust.
      #
      # Because `tag` is public, almost every structural and layout 
      # word in the language becomes a .sp partial built on top of it.
      #
      #   box        ->  tag div
      #   paragraph     ->  tag p
      #   heading       ->  tag h2
      #   span          ->  tag span
      #
      # It already exists as Ruby, on the Builder's escape-hatch
      # surface. Now it is simply exposed:

      def tag(name, attributes = {}, children = [], &block)
        emit_node(element(name, attributes, block ? capture(&block) : children))
      end
    RUBY
  end

  # --- layout ------------------------------------------------------------
  #
  # Layered: a word sits one level above the highest word it composes over,
  # so the floor is literally the floor. Computed here, in Ruby, because a
  # layout that arrives as data needs no script to place it.

  def layers_for(nodes)
    depth = {}
    resolve = lambda do |word, seen|
      return 0 if seen.include?(word)

      node = nodes[word]
      return 0 if node.nil? || node.deps.empty?

      depth[word] ||= 1 + node.deps.map { |d| resolve.call(d, seen + [word]) }.max
    end
    nodes.each_key { |w| depth[w] = resolve.call(w, []) }
    depth
  end

  W = 1680
  BAND = 210
  MARGIN = 90

  def positions(nodes)
    depth = layers_for(nodes)
    used, unused = nodes.values.partition { |n| n.indegree.positive? || depth[n.word].positive? }
    rows = used.group_by { |n| depth[n.word] }
    placed = {}

    rows.keys.sort.each do |level|
      row = rows[level].sort_by { |n| [-n.indegree, n.word.to_s] }
      y = MARGIN + ((rows.keys.max - level) * BAND)
      step = (W - (MARGIN * 2)) / [row.size, 1].max.to_f
      row.each_with_index do |n, i|
        # Stagger alternate nodes so long labels in a dense row never collide.
        placed[n.word] = [MARGIN + (step * (i + 0.5)), y + (i.even? ? 0 : 34)]
      end
    end

    # The words no partial has ever reached, parked below in their own band.
    top = rows.keys.max
    base = MARGIN + ((top + 1) * BAND)
    per_row = 13
    unused.sort_by { |n| n.word.to_s }.each_with_index do |n, i|
      step = (W - (MARGIN * 2)) / per_row.to_f
      placed[n.word] = [MARGIN + (step * ((i % per_row) + 0.5)), base + ((i / per_row) * 62)]
    end

    # Three captions, so the picture's regions name themselves.
    bands = [
      [MARGIN - 46, 'Composed', 'written in terms of the words below'],
      [MARGIN + (top * BAND) - 78, 'The floor', 'everything above stands on these'],
      [base - 84, 'Unreached', 'Ruby no partial composes over']
    ]
    [placed, base + (((unused.size / per_row) + 1) * 62), bands]
  end

  def radius(node)
    # Size says consequence: how many words are written in terms of this one.
    14 + Math.sqrt(node.indegree) * 11
  end

  # --- rendering ---------------------------------------------------------

  ROLE_LABEL = {
    primitive:   'the element primitive (now public)',
    control:     'floor — controls evaluation',
    document:    'floor — acts on the whole document',
    computation: 'floor — computes',
    context:     'floor — needs walk context',
    promoted:    'written in the language (.sp)',
    moves:       'composition — leaves the kernel',
    candidate:   'Tier 3 — argued, not decided',
    unreached:   'Ruby, and no partial composes over it'
  }.freeze

  def esc(text) = CGI.escapeHTML(text.to_s)

  def render_state(mode, nodes)
    placed, height, bands = positions(nodes)
    id = mode.to_s

    captions = bands.map do |y, title, sub|
      %(<div class="rule" style="top:#{y.round}px"></div>) +
        %(<div class="band" style="top:#{y.round}px">#{esc(title)}<small>#{esc(sub)}</small></div>)
    end

    edges = nodes.each_value.flat_map do |n|
      n.deps.filter_map do |d|
        next unless placed[n.word] && placed[d]

        x1, y1 = placed[n.word]
        x2, y2 = placed[d]
        %(<path class="edge e-#{id}-#{n.word} e-#{id}-#{d}" d="M#{x1.round} #{y1.round} ) +
          %(C#{x1.round} #{((y1 + y2) / 2).round}, #{x2.round} #{((y1 + y2) / 2).round}, #{x2.round} #{y2.round}" />)
      end
    end

    dots = nodes.each_value.map do |n|
      x, y = placed[n.word]
      r = radius(n)
      %(<div class="node role-#{n.role} kind-#{n.kind}" id="n-#{id}-#{n.word}" ) +
        %(style="left:#{x.round}px; top:#{y.round}px; --r:#{r.round}px">) +
        %(<span class="dot"></span><span class="label">#{esc(n.word)}</span></div>)
    end

    panels = nodes.each_value.map do |n|
      %(<div class="panel" id="p-#{id}-#{n.word}">) +
        %(<header><b>#{esc(n.word)}</b>) +
        %(<span class="tag t-#{n.kind}">#{n.kind == :partial ? '.sp partial' : 'Ruby'}</span>) +
        %(<span class="tag t-role">#{esc(ROLE_LABEL[n.role])}</span></header>) +
        (n.note ? %(<p class="note">#{esc(n.note)}</p>) : '') +
        %(<div class="meta">composed over by <b>#{n.indegree}</b> word#{n.indegree == 1 ? '' : 's'}) +
        (n.deps.any? ? %( · says #{n.deps.map { |d| "<code>#{esc(d)}</code>" }.join(', ')}) : '') +
        %(</div><pre>#{esc(n.source)}</pre></div>)
    end

    hover = nodes.each_key.map do |w|
      "#n-#{id}-#{w}:hover ~ #p-#{id}-#{w} { opacity: 1; visibility: visible; }\n" \
      "#n-#{id}-#{w}:hover ~ svg .e-#{id}-#{w} { stroke: var(--hot); stroke-width: 2.4; opacity: 1; }\n" \
      "#n-#{id}-#{w}:hover { z-index: 40; }"
    end

    counts = nodes.each_value.group_by(&:kind).transform_values(&:size)
    [<<~HTML, hover.join("\n")]
      <div class="scroller" id="stage-#{id}">
        <section class="stage" style="height:#{height.round}px">
          <div class="tally">
            <b>#{counts[:ruby].to_i}</b> in Ruby · <b>#{counts[:partial].to_i}</b> in the language
          </div>
          #{captions.join("\n    ")}
          #{dots.join("\n    ")}
          <svg viewBox="0 0 #{W} #{height.round}" width="#{W}" height="#{height.round}" aria-hidden="true">#{edges.join}</svg>
          #{panels.join("\n    ")}
        </section>
      </div>
    HTML
  end

  def call
    now = build(:now)
    proposed = build(:proposed)
    now_html, now_css = render_state(:now, now)
    prop_html, prop_css = render_state(:proposed, proposed)
    template(now_html, prop_html, [now_css, prop_css].join("\n"), now, proposed)
  end
end

require_relative 'word_graph_template'

# Requireable, so the census below can be taken without writing a file.
if __FILE__ == $PROGRAM_NAME
  out = File.expand_path('../word_graph.html', __dir__)
  File.write(out, WordGraph.call)
  puts "wrote #{File.basename(out)}"
end
