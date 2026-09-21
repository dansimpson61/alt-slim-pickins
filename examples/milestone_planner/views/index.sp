page "Milestone Planner"
  card
    title "Roadmap & Project Horizon"
    text "Track development milestones, blocked issues, and task completions across phases."
    section stats, "Overview Metrics"
      grid metrics, columns: 4
        metric total_milestones, "Milestones"
        metric completed_milestones, "Completed"
        metric total_tasks, "Total Tasks"
        metric overall_progress, "Progress %"

  section milestones, "Milestones"
    empty "No milestones currently active."
    each milestone
      milestone_card
