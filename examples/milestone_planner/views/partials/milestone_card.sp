card
  title .title
  choose
    when .completed
      badge ok, "Complete"
    when .blocked
      badge blocker, "Blocked"
    when .at_risk
      badge warning, "At Risk"
    otherwise
      badge pending, "In Progress"
  text .description
  time .due_date
  grid metrics, columns: 3
    metric total_tasks, "Total Tasks"
    metric completed_tasks, "Completed"
    metric progress, "Progress %"
  actions
    link milestone, "View Tasks", to: "/milestones/#{milestone.id}"
