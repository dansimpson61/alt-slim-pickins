expects variant, content: true, children: any, id: true, shape: encloses


box .name, id: .id
  choose
    when .content
      heading .content
  children
