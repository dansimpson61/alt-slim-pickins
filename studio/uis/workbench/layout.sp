# The workbench's frame, and the reason it is a layout rather than a partial:
# the shelf is chrome. Every destination in this UI sits beside the same
# library, and `page` infers this file, so no page mentions the shelf or the
# assets — which is what "declared once" means here.
#
# It is also why a page must *not* say `shell` itself: a page that wrapped one
# inside this one nested its work in the shell's own grid and squeezed the
# workbench into a single column. The layout owns the frame; a page owns its
# own work.
stylesheet "/assets/slim-pickins.css"
stylesheet "/assets/workbench.css"
script "/assets/stimulus.umd.js"
script "/assets/studio.js"
main_menu
shell
  library
  contents
foot
