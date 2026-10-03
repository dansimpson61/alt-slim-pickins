# frozen_string_literal: true

module SlimPickins
  # A semantic node: one word, what it was told, and what it holds.
  #
  # This is the most-travelled datum in the runtime. The Builder evaluates a page
  # into a tree of these and the Generator walks the tree to HTML, and for the
  # project's first month it was a bare three-element Array read positionally —
  # `node[0]`, `node[1][:class_base]`, `root[2].size` — while the project reached
  # for `Struct` seven times elsewhere (`Sentence`, the parse `Node`, `Contract`,
  # `Violation`, `Promise`, `Convention`, `Entry`). DAYTRIP-0.4.0h named that
  # under the Ode's *give traveling data a name*.
  #
  # The name earns more than legibility, because the Array had two real
  # ambiguities and this removes both:
  #
  #   - **A node and a list of nodes were both Arrays.** `body.size == 1 &&
  #     body.first.is_a?(Array)` was asking "is this one node or several?", which
  #     `is_a?(Node)` answers directly. The same question is asked in
  #     `Builder#promote` and `PartialWord`, and it was asked that way in both.
  #   - **Two unrelated triples looked alike.** `Markdown` has its own positional
  #     `[:element, …]` nodes, read with `node[0]` and `node[1]` in the same
  #     Generator. Nothing but the surrounding method distinguished them.
  #
  # Construction stays positional — `Node[:box, attrs, children]` — because
  # `Data` supports it and because the thirty-one sites that build nodes read
  # better as a triple than as three keywords. Reading is by name everywhere.
  #
  # `Data` is frozen, so a node cannot be rebuilt in place. Nothing did: the one
  # mutation in the runtime is `root.attributes[:app_class] = …`, which writes to
  # the hash the node holds rather than to the node, and that still works.
  Node = Data.define(:word, :attributes, :children) do
    # `children` is a list of nodes, or of lists of them for `each` — one per
    # iteration. Flattening it used to risk splicing a node's own three elements
    # into the list, because a node was an Array; it cannot now.
    def to_s = "#{word} node"
  end
end
