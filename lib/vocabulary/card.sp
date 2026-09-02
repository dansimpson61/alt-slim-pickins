# name: variant
# content: true
# children: any
# id: true
# shape: encloses

region .name, id: .id
  choose
    when .content
      heading .content
  children
