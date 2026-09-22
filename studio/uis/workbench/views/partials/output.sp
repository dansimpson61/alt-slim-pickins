# The artifact: what the page you are writing actually is.
#
# The presentation is the app's, like the raw-HTML pane's tidy wrapper in the
# classic UI — a pane's presentation is part of its payload, or the first pane
# to stop using the shared route loses it.
box
  tabs
    tab "Visual", active: true
      iframe preview
    tab "HTML"
      iframe html_preview
    tab "Inspect"
      iframe inspect_preview
