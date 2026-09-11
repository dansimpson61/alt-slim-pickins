choose
  when .first_item
    text .queue_intro
    card first_item.path
      badge first_item.status_variant, first_item.status
      text first_item.purpose
      choose
        when first_item.next_line
          text first_item.next_line
      actions path: first_item.path, return_to: "/triage"
        choose
          when first_item.offer_commit
            action "Commit", to: "/actions/commit", variant: primary
        action "Set dormant", to: "/actions/status", status: "dormant", variant: neutral
        action "Archive", to: "/actions/archive", variant: neutral
        action "Skip 30d", to: "/actions/skip", variant: neutral
  otherwise
    text "All caught up. Nothing needs attention."
