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
  group "Vocabulary"
    list
      each word
        item
          link_to .name, to: word, word: .name
