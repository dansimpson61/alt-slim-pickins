aside
  group "Studio"
    list
      item
        link "Playground", to: "/"
      item
        link "Status", to: "/status"
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
