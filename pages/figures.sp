page review, "Dashboard UI review"
  fact reviewed_on, .reviewed_on
  fact reviewer

  prose .introduction

  grid metrics, columns: 3
    metric surfaces_reviewed, "Surfaces"
    metric findings_open, "Open findings"
    metric worst_severity, "Worst severity"

  section surfaces, "Every surface, as reviewed"
    empty "No screenshots captured yet."

    each surface
      card
        title .name

        figure .caption
          image .screenshot, alt: .name

        list plain
          each finding
            item
              badge .severity
              text .summary
              fact surface, surface.name

        actions
          link open, "Open the live page"

  section "Reading the severities"
    list plain
      item
        badge blocker
        text "Blocks the task outright."
      item
        badge warning
        text "Works, but costs the reader."
      item
        badge polish
        text "Cosmetic."

