aside
  group "Studio"
    list
      item
        link "Playground", to: "/"
  group "Guides"
    list
      each guide
        item
          link .name, to: .path
  group "Vocabulary"
    list
      each word
        item
          link .name, to: .path
