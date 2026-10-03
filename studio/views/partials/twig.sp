expects takes: nodes, shape: encloses

# A list of nodes and, under each, its own children — the same word again.
#
# Rooted at `list` rather than `item` because `item` must be lexically inside a
# `list`, which a recursive partial cannot promise its caller. So the recursion
# carries the whole list, and a node with no children renders an empty one.
#
# The collection arrives as `nodes:` rather than by shifting the subject with a
# `box`: `box`'s name slot is a variant, so `box roots` says a variant named
# `roots` that nothing could ever style, and `check_styles` refuses it. Saying
# what is passed is both honest and shorter.
#
# Each node is a `link` to its own detail card, and that link is the whole
# selection mechanism — `:target` in the theme does what two ad-hoc listeners did.
list
  each node, from: .nodes
    item
      link .named, .anchor
      span word, .variant
      span preview, .preview
      twig nodes: .children
