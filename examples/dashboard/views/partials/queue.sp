choose
  when .first_item
    text .queue_intro
    card first_item.path
      badge first_item.status_variant, first_item.status
      text first_item.purpose
      choose
        when first_item.next_line
          text first_item.next_line
      choose
        when first_item.offer_commit
          action "Commit", to: "/actions/commit", path: first_item.path, return_to: "/triage", variant: primary
      dormant "Set dormant", path: first_item.path
      action "Archive", to: "/actions/archive", path: first_item.path, return_to: "/triage", variant: neutral
      action "Skip 30d", to: "/actions/skip", path: first_item.path, return_to: "/triage", variant: neutral
  otherwise
    text "All caught up. Nothing needs attention."
