card
  title .title
  choose
    when .done?
      badge ok, "Done"
    when .blocked?
      badge blocker, "Blocked"
    when .at_risk?
      badge warning, "At Risk"
    otherwise
      badge pending, "Pending"
  fact owner, .owner
  form to: "/tasks/#{task.id}/toggle", method: post
    choose
      when .done?
        button "Mark Pending"
      otherwise
        button "Mark Done"
