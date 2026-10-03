expects shape: encloses

# The Semantic Tree pane: every node the page evaluated to, nested as it nests.
#
# Its name is the Spiff's zone name, which is what makes `zone tree` in
# `inspect.spiff` target a real class rather than a guess.
box
  heading "Semantic Tree"
  fact nodes, .node_count
  twig nodes: .roots
