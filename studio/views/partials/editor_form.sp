# One button, two panes — the recorded burr's resolution (2026-09-15).
# Its why, preserved: one form can target only one iframe natively, so the
# studio used to need two Render buttons. A Stimulus controller now
# intercepts input and submit (live, debounced) and writes one response
# into both iframes; the form's own action still posts to /render, so
# without JavaScript the visual pane renders the old way, honestly.

wired_form
  textarea source, rows: 4, required: true
  textarea data, "Data (JSON)", rows: 2
  button primary, "Render", type: "submit"
