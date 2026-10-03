# frozen_string_literal: true

require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/conventions'

# The Inspect surface's data, and the page that says it.
#
# This module was 436 lines of HTML builder. DAYTRIP-0.4.0k measured it before
# rewriting it, and the audit's description — "a 255-line method that is mostly
# one HTML heredoc: 39 raw tags, 37 hardcoded hex colours" — was wrong in all
# three particulars:
#
#   - `page_for` was 254 lines of which **200 were an inline `<style>` block**.
#     It was 79% CSS, not HTML.
#   - 23 distinct tags, not 39.
#   - **26 of the 37 hex values were `var(--role, #fallback)` fallbacks** on 16
#     theme roles the surface already used correctly. They existed because this
#     document linked no stylesheet — while `error_page_for`, ten lines below in
#     the same file, linked the theme and needed none. The remaining 11 were five
#     tier palettes, which are semantic rather than decorative and are now
#     `badge` variants owned by the theme.
#
# So the fix was not to invent vocabulary. Every class the surface needs already
# had a word — `badge`, `card`, `list`, `item`, `snippet`, `title`, `empty`,
# `flash`, `fact`, `span`, `link`. The two that had none, the surface and its
# panes, are a *layout*, which is Spiff's business and now lives in
# `studio/views/inspect.spiff`. Selection is `:target`, so there is no
# JavaScript: a node is a link to its own card, and three static rules in the
# theme do what two ad-hoc listeners used to.
#
# What is left here is the one thing Ruby was actually needed for — turning a
# semantic tree into nouns a page can say.
module StudioInspector
  VIEWS = File.expand_path('views', __dir__)

  # What the Why pane says about one convention. `owner` is the four-tier
  # precedence this surface exists to show, and it is a presentation of `grade`
  # rather than a second fact about it.
  OWNERS = { domain: 'App Contract', shape: 'Language (Shape)',
             structural: 'Language (Structure)', axiomatic: 'Theme' }.freeze

  # The four grades are asked as predicates rather than compared as values,
  # because `choose` takes no data and `when` takes a question — so the page says
  # `when .shape?` and the theme colours the badge variant that answers.
  Why = Struct.new(:name, :grade, :owner, :decides, :when_silent, :override, keyword_init: true) do
    def structural? = grade == :structural
    def shape? = grade == :shape
    def domain? = grade == :domain
    def axiomatic? = grade == :axiomatic
    def describe = "the " + name.to_s + " convention"
  end

  # One attribute of a node, as a row. The complex payloads a word carries —
  # rows, columns, a table's foot — are the node's own children and are shown as
  # those rather than inspected as values.
  NESTED = %i[rows columns foot].freeze

  Fact = Struct.new(:attribute, :value, keyword_init: true)

  # A node as the surface speaks of it.
  Node = Struct.new(:id, :named, :variant, :preview, :why, :facts, :children, keyword_init: true) do
    # Where this node's detail card is, which is the whole selection mechanism.
    #
    # `card node` infers its DOM id from its subject — the `card_id` convention,
    # "the DOM id, as `word-id`" — so this destination has to agree with what that
    # convention produces. Two halves of one page meeting in the middle like this
    # is worth a test, and it has one.
    def anchor = "#node-" + id.to_s
    def why_count = why.size
    def describe = "the #{named} node"
  end

  module_function

  # The semantic tree as nested nodes. A bare three-element Array is a node; an
  # Array of them is a list of children, which is why the shape is tested before
  # it is read.
  def nodes_of(tree, prefix: 'n')
    Array(tree).each_with_index.flat_map do |node, index|
      id = "#{prefix}_#{index}"
      next [] unless node.is_a?(Array) && !node.empty?
      next nodes_of(node, prefix: id) unless node.first.is_a?(Symbol)

      [node_from(node, id)]
    end
  end

  def node_from(node, id)
    type, attrs, children = node[0], node[1] || {}, node[2] || []
    word = (attrs[:class_base] || type).to_sym
    # A table carries its rows as an attribute rather than as children, and they
    # are children in every sense the reader cares about.
    children = attrs[:rows] if type == :table && attrs[:rows].is_a?(Array) && children.empty?

    Node.new(id: id, named: ":#{type}", variant: (word.to_s unless word == type),
             preview: preview_of(attrs), why: why_of(word),
             facts: attrs.reject { |key, _| NESTED.include?(key) }
                         .map { |key, value| Fact.new(attribute: key.to_s, value: value.inspect) },
             children: nodes_of(Array(children), prefix: id))
  end

  # What the node shows of itself in one line, in the order the reader is most
  # likely to recognise it by.
  def preview_of(attrs) = (attrs[:body] || attrs[:heading] || attrs[:name] || attrs[:variant])&.to_s

  def why_of(word)
    contract = SlimPickins::CONTRACTS[word]
    Array(contract&.infers).filter_map do |name|
      convention = SlimPickins::Conventions::ALL.find { |candidate| candidate.name == name }
      next unless convention

      Why.new(name: ":#{convention.name}", grade: convention.grade,
              owner: OWNERS.fetch(convention.grade, 'Language'), decides: convention.decides,
              when_silent: convention.when_silent, override: convention.override)
    end
  end

  # Every node, depth first, for the pane that shows one card per node.
  def flatten(nodes) = nodes.flat_map { |node| [node, *flatten(node.children)] }

  def library = @library ||= SlimPickins::Library.from(VIEWS)

  def page_for(tree, source: '')
    roots = nodes_of(tree)
    render('inspect.sp', roots: roots, details: flatten(roots), node_count: flatten(roots).size,
                         source: source)
  end

  def error_page_for(error) = render('refusal.sp', message: error.message)

  def render(view, **locals)
    SlimPickins.render(File.read(File.join(VIEWS, view)), path: "studio/views/#{view}",
                       locals: locals, library: library)
  end
end
