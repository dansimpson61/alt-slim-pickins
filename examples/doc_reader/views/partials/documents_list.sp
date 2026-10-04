empty "Nothing here."
list
  each document
    item
      link .title, to: .href
      text .name
