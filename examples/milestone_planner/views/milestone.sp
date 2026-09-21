page "Milestone Detail"
  actions
    link home, "← Back to Planner", to: "/"
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

  form to: "/milestones/#{milestone.id}/tasks", method: post
    group "Add Task"
      input title, placeholder: "Task description..."
      choice owner, "Assignee"
        option dan, "Dan"
        option gemini, "Gemini"
        option agent, "Agent"
      actions
        button "Add Task"

  section tasks, "Tasks"
    empty "No tasks defined for this milestone yet."
    each task
      task_card
