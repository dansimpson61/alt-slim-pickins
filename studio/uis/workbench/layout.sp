# The workbench's frame, and the reason it is a layout rather than a partial:
# the shelf is chrome. Every destination in this UI sits beside the same
# library, and `page` infers this file, so no page mentions the shelf or the
# assets — which is what "declared once" means here.
#
# It is also why a page must *not* say `sidebar_layout` itself: nesting one
# inside this one wrapped the page in the layout's sidebar column and squeezed
# the workbench into 250px. The layout owns the two-column frame; a page owns
# its own work.
stylesheet "/assets/slim-pickins.css"
script "/assets/stimulus.umd.js"
script "/assets/studio.js"
main_menu
sidebar_layout
  library
  contents
foot
