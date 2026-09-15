# frozen_string_literal: true

# The studio's one JS seam, written in Ruby because the language's form
# word cannot say data-* attributes — and the escape hatch exists for
# exactly this. `wired_form` opens the form a Stimulus controller listens
# on and captures its children, so the fields themselves stay pure
# language: a call site cannot tell this word from a built-in.
module StudioWords
  # The burr's resolution (2026-09-15). Its why, preserved: one form can
  # target only one iframe natively, so the studio used to need two Render
  # buttons. The `render` controller now intercepts input and submit —
  # live, debounced — and writes one response into both iframes, found by
  # the names the language already emits. The form's own action still
  # posts to /render, so without JavaScript the visual pane renders
  # natively: the old behavior, honestly degraded.
  def wired_form(*, **, &block)
    # `class: 'form'` — the editor_form partial's promotion adds its own
    # class, so the wired form carries both, exactly once each.
    tag(:form, { class: 'form',
                 'data-controller' => 'render',
                 'data-action' => 'input->render#input submit->render#submit:prevent',
                 'method' => 'post', 'action' => '/render', 'target' => 'preview' },
        [], &block)
  end
end
