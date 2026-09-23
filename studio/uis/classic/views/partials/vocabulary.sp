aside
  group "Studio"
    list
      item
        link_to "Playground", to: home
      item
        link_to "Status", to: status
  group "Guides"
    list
      each guide
        item
          link_to .name, to: guide, name: .name
  group "UI"
    list
      each entry, from: .ui_names
        item
          link_to .title, to: switch, name: .name, active: .current
  each tier, from: .vocabulary_tiers
    group .title
      note quiet, .question
      list
        each word, from: .words
          item
            link_to .name, to: word, word: .name, active: .active
            badge neutral, .badge, if: .badge
