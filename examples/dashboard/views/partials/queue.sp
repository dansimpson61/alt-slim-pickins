choose
  when .first_item
    text .queue_intro
    card first_item, first_item.path
      badge .status_variant, .status
      text .purpose
      choose
        when .next_line
          text .next_line
      actions path: .path, return_to: "/triage"
        choose
          when .offer_commit
            action "Commit", to: "/actions/commit", variant: primary
        action "Set dormant", to: "/actions/status", status: "dormant", variant: neutral
        action "Archive", to: "/actions/archive", variant: neutral
        action "Skip 30d", to: "/actions/skip", variant: neutral
  otherwise
    text "All caught up. Nothing needs attention."
