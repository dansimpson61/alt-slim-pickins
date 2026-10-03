expects shape: encloses

# The Why pane: one card per node, and the theme shows the one the tree points at.
#
# `card node` sits here rather than inside `why_card` on purpose. The `card_id`
# convention builds the DOM id from the word and its subject, and a partial
# promotes its own name over the word — so a `card` inside `why_card.sp` is
# identified as `why_card-`, with nothing to say. Said here, it is `node-n_0`,
# which is exactly what `twig`'s link points at.
box
  heading "Provenance and the Why Pane"
  fact precedence, "four tiers"
  each node, from: .details
    card node
      why_card
