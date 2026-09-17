# frozen_string_literal: true

# The interface kata: the words a studio UI is written with.
#
# This is the one place a studio UI may reach for the escape hatch, and it is
# small on purpose. The hatch exists for what the language cannot yet say —
# `data-*` attributes for the render seam, and the relation between a box and
# its siblings, which sp has no word for yet. Everything else a UI says is the
# language's own vocabulary, written in the language.
#
# A UI is a module that `include`s this one, so every UI gets these words and
# an agent's own are added beside them. (The Builder `extend`s the UI module,
# so what carries these words to a page is the ancestor chain — `include`,
# never `extend`.) The vocabulary question — whether any of these deserves
# promotion out of the app and into the language — is the point of building
# several UIs: two UIs that both need a word are evidence, and one UI that
# needs it is a page's own business.
#
# The naming rule: a word here says what a thing *is*, never how it looks. The
# stylesheet decides how it looks, the class the box already carries is the
# handle, and `box` + a class is the designed tool for managing display real
# estate rather than a workaround.
module StudioUI
  # Which UI is speaking, for the words that mint URLs. Thread-local, not a
  # module global: several UIs' pages render in one process — the census
  # renders every UI's pages — and a global would let the last UI loaded
  # decide what the first UI's links say.
  def self.current = Thread.current[:studio_ui] || Uis.default_ui

  def self.current=(ui)
    Thread.current[:studio_ui] = ui
  end

  # The render seam, and the only JavaScript in the studio. A form cannot say
  # `data-*` attributes in the language, so the word is written in Ruby; the
  # fields it encloses stay pure language, and the iframes are reached by the
  # names the language already emits (see assets/studio_controller.js).
  def wired_form(*, **, &block)
    tag(:form, { class: 'form',
                 'data-controller' => 'render',
                 'data-action' => 'input->render#input submit->render#submit:prevent',
                 'method' => 'post', 'action' => '/render' },
        [], &block)
  end

  # A link whose `href` the app mints, so a UI can only link to itself. There
  # are two spellings because there are two kinds of destination: a named
  # route from the UI's own `paths` (`to: load, id: .id`), or a path the
  # payload already minted (`path: .try_path`), which carries its own `:ui`
  # and is substituted like any other template.
  #
  # The templates live in `about.rb` and the routes read the same table, so a
  # view never holds a route — which is the only reason several UIs can
  # coexist without a hardcoded `/docs/...` sending a visitor from one into
  # another. `link` names a literal destination; a destination only the app
  # can mint is not one, so this is the hatch doing what the hatch is for.
  def link_to(*args, to: nil, path: nil, variant: nil, active: false, **bindings)
    # A string argument is the label; a bare name would be a *subject*, and
    # `links .name, ...` reaches the chain instead — the same split `link`
    # makes between its content and its name. `arguments` is not used here
    # because a label is content, not a name to resolve.
    label = args.grep(String).last
    ui = StudioUI.current or raise Error, '`link_to` was called before a UI was selected'
    template = path || ui.paths.fetch(to) { raise Error, "the UI `#{ui.name}` has no `#{to}` path" }
    # The UI names itself, so a view never spells `ui:` and cannot spell it
    # wrong; an explicit binding would only be a second way to say it.
    href = ui.path(template, **{ ui: ui.name }.merge(bindings))

    children = label.nil? ? [] : [label]
    classes = [variant ? token(:link, variant) : 'link', active ? 'link--active' : nil].compact.join(' ')
    tag(:a, { class: classes, href: href, 'aria-current': active ? 'page' : nil }, children)
  end
end
